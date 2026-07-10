#!/bin/bash
# 1Password CLI Deployment Script
# Securely manages secrets and deployments across MCP servers

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_ROOT}/.deployment.log"

# Functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $*" | tee -a "$LOG_FILE"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN:${NC} $*" | tee -a "$LOG_FILE"
}

check_op_cli() {
    if ! command -v op &> /dev/null; then
        error "1Password CLI (op) is not installed. Please install it first."
    fi
    log "1Password CLI found: $(op --version)"
}

check_op_signin() {
    if ! op account get >/dev/null 2>&1; then
        error "Not signed into 1Password. Please run 'op account add' first."
    fi
    log "Authenticated with 1Password"
}

get_secret() {
    local vault="$1"
    local item="$2"
    local field="${3:-password}"

    if op item get "$item" --vault "$vault" --fields "$field" 2>/dev/null; then
        return 0
    else
        warn "Could not retrieve $item from vault $vault"
        return 1
    fi
}

deploy_mcp_server() {
    local server_name="$1"
    local server_dir="$2"

    log "Deploying MCP server: $server_name"

    if [ ! -d "$server_dir" ]; then
        error "Server directory not found: $server_dir"
    fi

    cd "$server_dir"

    # Get deployment credentials from 1Password
    log "Retrieving credentials from 1Password..."

    # Create .env file with secrets from 1Password (if it exists)
    if [ -f ".env.1password.template" ]; then
        log "Generating .env from 1Password template..."
        # Parse template and substitute values
        while IFS= read -r line; do
            if [[ $line =~ ^([A-Z_]+)=op://(.+)/(.+)/(.+) ]]; then
                var_name="${BASH_REMATCH[1]}"
                vault="${BASH_REMATCH[2]}"
                item="${BASH_REMATCH[3]}"
                field="${BASH_REMATCH[4]}"

                if secret=$(get_secret "$vault" "$item" "$field"); then
                    echo "$var_name=$secret" >> .env
                else
                    warn "Skipping $var_name"
                fi
            else
                echo "$line" >> .env
            fi
        done < ".env.1password.template"
        chmod 600 .env
        log ".env file created successfully"
    fi

    log "MCP server deployment completed: $server_name"
}

list_vaults() {
    log "Available 1Password vaults:"
    op vault list --format json | jq -r '.[] | "\(.id): \(.name)"'
}

list_vault_items() {
    local vault="$1"
    log "Items in vault: $vault"
    op item list --vault "$vault" --format json | jq -r '.[] | "\(.id): \(.title)"'
}

main() {
    local command="${1:-help}"

    case "$command" in
        check)
            check_op_cli
            check_op_signin
            log "All checks passed!"
            ;;
        signin)
            log "Signing into 1Password..."
            op account add
            ;;
        deploy)
            local server="${2:-all}"
            check_op_cli
            check_op_signin

            case "$server" in
                api-mcp-server)
                    deploy_mcp_server "api-mcp-server" "$PROJECT_ROOT/api-mcp-server"
                    ;;
                claude-memory-mcp)
                    deploy_mcp_server "claude-memory-mcp" "$PROJECT_ROOT/claude-memory-mcp"
                    ;;
                github-mcp-server)
                    deploy_mcp_server "github-mcp-server" "$PROJECT_ROOT/github-mcp-server"
                    ;;
                mcp-ssh-server)
                    deploy_mcp_server "mcp-ssh-server" "$PROJECT_ROOT/mcp-ssh-server"
                    ;;
                all)
                    deploy_mcp_server "api-mcp-server" "$PROJECT_ROOT/api-mcp-server"
                    deploy_mcp_server "claude-memory-mcp" "$PROJECT_ROOT/claude-memory-mcp"
                    deploy_mcp_server "github-mcp-server" "$PROJECT_ROOT/github-mcp-server"
                    deploy_mcp_server "mcp-ssh-server" "$PROJECT_ROOT/mcp-ssh-server"
                    ;;
                *)
                    error "Unknown server: $server"
                    ;;
            esac
            ;;
        vaults)
            check_op_cli
            check_op_signin
            list_vaults
            ;;
        list-items)
            local vault="${2:-}"
            if [ -z "$vault" ]; then
                error "Usage: $0 list-items <vault-name>"
            fi
            check_op_cli
            check_op_signin
            list_vault_items "$vault"
            ;;
        help|*)
            cat << EOF
Usage: $0 <command> [options]

Commands:
  check              Check 1Password CLI installation and authentication
  signin             Sign into 1Password
  deploy [server]    Deploy MCP server(s) with secrets from 1Password
                     Servers: api-mcp-server, claude-memory-mcp,
                              github-mcp-server, mcp-ssh-server, all
  vaults             List all available 1Password vaults
  list-items <vault> List items in a specific vault
  help               Show this help message

Examples:
  $0 check
  $0 signin
  $0 deploy api-mcp-server
  $0 deploy all
  $0 vaults
  $0 list-items "Private"

Environment:
  OP_VAULT           Default vault name (optional)

EOF
            ;;
    esac
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Run main function
main "$@"
