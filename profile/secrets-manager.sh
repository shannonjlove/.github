#!/bin/bash
# 1Password Secrets Manager
# Comprehensive secret and environment variable management

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_FILE="${PROJECT_ROOT}/.github/1password-secrets-config.yaml"
LOG_DIR="${PROJECT_ROOT}/.secrets-logs"
LOG_FILE="${LOG_DIR}/secrets-manager.log"
SECRETS_CACHE="${LOG_DIR}/.secrets-cache"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[${timestamp}]${NC} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_warn() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] [WARN]${NC} $*" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR]${NC} $*" | tee -a "$LOG_FILE"; }
log_debug() { [[ "${DEBUG:-0}" == "1" ]] && log "DEBUG" "$@"; }

# Check if op CLI is installed
check_op_cli() {
    if ! command -v op &> /dev/null; then
        log_error "1Password CLI (op) is not installed"
        return 1
    fi
    log_info "1Password CLI found: $(op --version)"
    return 0
}

# Check authentication status
check_authentication() {
    if ! op account get >/dev/null 2>&1; then
        log_error "Not authenticated with 1Password"
        log_info "Run: op account add"
        return 1
    fi
    local account=$(op account get --format json | jq -r '.email' 2>/dev/null)
    log_info "Authenticated as: $account"
    return 0
}

# Get secret from 1Password
get_secret() {
    local vault="$1"
    local item="$2"
    local field="${3:-password}"

    if op item get "$item" --vault "$vault" --fields "$field" 2>/dev/null; then
        log_debug "Retrieved secret: $item/$field from vault: $vault"
        return 0
    else
        log_warn "Could not retrieve $item/$field from vault $vault"
        return 1
    fi
}

# Load all secrets into environment variables
load_secrets_to_env() {
    local environment="${1:-development}"

    log_info "Loading secrets for environment: $environment"

    case "$environment" in
        development|staging|production)
            ;;
        *)
            log_error "Invalid environment: $environment"
            return 1
            ;;
    esac

    # This would parse the YAML config and load secrets
    # For now, just load from template files
    local count=0
    local failures=0

    if [ -f "${PROJECT_ROOT}/.github/profile/.env.${environment}" ]; then
        log_info "Loading from .env.${environment}"
        source "${PROJECT_ROOT}/.github/profile/.env.${environment}"
        count=$((count + 1))
    fi

    log_info "Loaded $count environment files, $failures failures"
    return $([[ $failures -eq 0 ]] && echo 0 || echo 1)
}

# Export secrets to .env file
export_secrets_to_file() {
    local vault="$1"
    local output_file="${2:-.env}"

    if [ -f "$output_file" ]; then
        log_warn "Output file exists: $output_file (backing up to ${output_file}.bak)"
        cp "$output_file" "${output_file}.bak"
    fi

    log_info "Exporting secrets from vault: $vault"

    touch "$output_file"
    chmod 600 "$output_file"

    # List all items in vault and export
    local items=$(op item list --vault "$vault" --format json 2>/dev/null | jq -r '.[].id' 2>/dev/null)

    local count=0
    while read -r item_id; do
        local item_data=$(op item get "$item_id" --vault "$vault" --format json 2>/dev/null)
        local item_name=$(echo "$item_data" | jq -r '.title' 2>/dev/null)

        # Extract all fields
        local fields=$(echo "$item_data" | jq -r '.fields[]? | "\(.label)=\(.value)"' 2>/dev/null)
        if [ -n "$fields" ]; then
            echo "# From item: $item_name" >> "$output_file"
            echo "$fields" >> "$output_file"
            count=$((count + 1))
        fi
    done <<< "$items"

    log_info "Exported $count items to $output_file"
    log_warn "IMPORTANT: Keep .env file secure! Add to .gitignore"
}

# Validate secrets
validate_secrets() {
    local vault="${1:-development}"

    log_info "Validating secrets in vault: $vault"

    local required_fields=(
        "github-token"
        "npm-token"
        "claude-api-key"
    )

    local missing=0
    for field in "${required_fields[@]}"; do
        if ! op item get "$field" --vault "$vault" >/dev/null 2>&1; then
            log_error "Missing required secret: $field"
            missing=$((missing + 1))
        else
            log_info "✓ Found: $field"
        fi
    done

    if [ $missing -gt 0 ]; then
        log_error "Validation failed: $missing required secrets missing"
        return 1
    fi

    log_info "✓ All required secrets found"
    return 0
}

# List all secrets in a vault
list_secrets() {
    local vault="${1:-development}"

    log_info "Secrets in vault: $vault"
    echo
    op item list --vault "$vault" --format json 2>/dev/null | jq -r '.[] | "\(.title) (\(.category))"' | while read -r item; do
        echo "  • $item"
    done
    echo
}

# View secret details
view_secret() {
    local vault="$1"
    local item="$2"

    log_info "Secret details: $item"
    echo

    op item get "$item" --vault "$vault" --format json 2>/dev/null | jq '.fields[] | "\(.label): \(.value)"' -r
    echo
}

# Rotate secret
rotate_secret() {
    local vault="$1"
    local item="$2"
    local field="${3:-password}"
    local new_value="$4"

    if [ -z "$new_value" ]; then
        log_error "Usage: $0 rotate <vault> <item> <field> <new-value>"
        return 1
    fi

    log_warn "Rotating secret: $item/$field"

    if op item edit "$item" --vault "$vault" "$field=$new_value" 2>/dev/null; then
        log_info "✓ Secret rotated: $item/$field"
        return 0
    else
        log_error "Failed to rotate secret: $item/$field"
        return 1
    fi
}

# Create a new secret
create_secret() {
    local vault="$1"
    local item_name="$2"
    local category="${3:-api_credential}"

    log_info "Creating new secret: $item_name in vault: $vault"

    if op item create --vault "$vault" --title "$item_name" --category "$category" 2>/dev/null; then
        log_info "✓ Secret created: $item_name"
        return 0
    else
        log_error "Failed to create secret: $item_name"
        return 1
    fi
}

# Verify secrets integrity
verify_secrets() {
    local vault="${1:-development}"

    log_info "Verifying secrets integrity in vault: $vault"

    local all_items=$(op item list --vault "$vault" --format json 2>/dev/null | jq '.[] | .id')
    local verified=0
    local failed=0

    while read -r item_id; do
        if op item get "$item_id" --vault "$vault" >/dev/null 2>&1; then
            verified=$((verified + 1))
        else
            failed=$((failed + 1))
        fi
    done <<< "$all_items"

    log_info "Verified: $verified items, Failed: $failed items"
    return $([[ $failed -eq 0 ]] && echo 0 || echo 1)
}

# Generate audit report
audit_report() {
    local days="${1:-7}"

    log_info "Generating audit report for last $days days"
    log_info "Report saved to: ${LOG_DIR}/audit-report.txt"

    cat > "${LOG_DIR}/audit-report.txt" << EOF
1Password Secrets Audit Report
Generated: $(date +'%Y-%m-%d %H:%M:%S')

Period: Last $days days

Vaults Summary:
EOF

    op vault list --format json 2>/dev/null | jq -r '.[] | "  • \(.name): \(.id)"' >> "${LOG_DIR}/audit-report.txt"

    echo >> "${LOG_DIR}/audit-report.txt"
    echo "Activity Log:" >> "${LOG_DIR}/audit-report.txt"
    tail -50 "$LOG_FILE" >> "${LOG_DIR}/audit-report.txt"

    log_info "✓ Audit report generated"
}

# Show help
show_help() {
    cat << EOF
${BLUE}1Password Secrets Manager${NC}

Usage: $0 <command> [options]

Commands:
  check              Verify 1Password CLI and authentication
  load <env>         Load secrets for environment (dev/staging/prod)
  export <vault>     Export all secrets from vault to .env file
  list <vault>       List all secrets in vault
  view <vault> <item>  View secret details
  validate <vault>   Validate required secrets exist
  rotate <vault> <item> <field> <value>
                     Rotate a secret
  create <vault> <name> [category]
                     Create a new secret
  verify <vault>     Verify secrets integrity
  audit [days]       Generate audit report
  help               Show this help message

Examples:
  $0 check
  $0 load development
  $0 export "Development Secrets"
  $0 list "Development Secrets"
  $0 validate "Development Secrets"
  $0 rotate "Development Secrets" github-credentials token ghp_xxx
  $0 audit 7

Environment Variables:
  DEBUG=1            Enable debug logging
  OP_VAULT           Default vault name

EOF
}

# Main function
main() {
    local command="${1:-help}"

    case "$command" in
        check)
            check_op_cli && check_authentication
            ;;
        load)
            local env="${2:-development}"
            load_secrets_to_env "$env"
            ;;
        export)
            local vault="${2:-Development Secrets}"
            local output="${3:-.env}"
            export_secrets_to_file "$vault" "$output"
            ;;
        list)
            local vault="${2:-Development Secrets}"
            list_secrets "$vault"
            ;;
        view)
            if [ $# -lt 3 ]; then
                log_error "Usage: $0 view <vault> <item>"
                return 1
            fi
            view_secret "$2" "$3"
            ;;
        validate)
            local vault="${2:-Development Secrets}"
            validate_secrets "$vault"
            ;;
        rotate)
            if [ $# -lt 5 ]; then
                log_error "Usage: $0 rotate <vault> <item> <field> <new-value>"
                return 1
            fi
            rotate_secret "$2" "$3" "$4" "$5"
            ;;
        create)
            if [ $# -lt 3 ]; then
                log_error "Usage: $0 create <vault> <name> [category]"
                return 1
            fi
            create_secret "$2" "$3" "${4:-api_credential}"
            ;;
        verify)
            local vault="${2:-Development Secrets}"
            verify_secrets "$vault"
            ;;
        audit)
            local days="${2:-7}"
            audit_report "$days"
            ;;
        help|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"
