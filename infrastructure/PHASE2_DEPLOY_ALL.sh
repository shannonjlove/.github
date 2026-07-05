#!/bin/bash
################################################################################
# Phase 2 Deploy All - Master Orchestrator
# Purpose: Deploy Phase 2 to both VPS and Oracle environments
# Date: July 5, 2026
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
VPS_HOST="72.61.74.250"
VPS_USER="root"
ORACLE_HOST="${ORACLE_HOST:-oracle-instance}"
ORACLE_USER="${ORACLE_USER:-root}"
REPO_URL="https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure"
LOCAL_LOG_DIR="./phase2-deployment-logs"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ $1${NC}" | sed 's/.$/║/'
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
}

print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

create_local_log_dir() {
    mkdir -p "$LOCAL_LOG_DIR"
    print_success "Created local log directory: $LOCAL_LOG_DIR"
}

check_ssh_connectivity() {
    local host=$1
    local user=$2
    local name=$3

    print_info "Testing SSH connectivity to $name ($user@$host)..."

    if ssh -o ConnectTimeout=5 "$user@$host" "echo 'SSH connection OK'" &>/dev/null; then
        print_success "SSH connectivity verified: $name"
        return 0
    else
        print_error "SSH connection failed to $name"
        return 1
    fi
}

deploy_to_vps() {
    print_section "DEPLOYING TO VPS (72.61.74.250)"

    local vps_log="$LOCAL_LOG_DIR/vps-deployment.log"

    if ! check_ssh_connectivity "$VPS_HOST" "$VPS_USER" "VPS"; then
        print_error "Cannot connect to VPS. Skipping..."
        return 1
    fi

    print_info "Downloading and running VPS deployment script..."

    ssh -v "$VPS_USER@$VPS_HOST" << 'EOFVPS' 2>&1 | tee "$vps_log"
set -euo pipefail

# Download deployment script
echo "Downloading VPS deployment script..."
tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

curl -fsSL -o "$tmpdir/PHASE2_DEPLOYMENT_VPS.sh" \
    "https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/PHASE2_DEPLOYMENT_VPS.sh"

chmod +x "$tmpdir/PHASE2_DEPLOYMENT_VPS.sh"

# Run deployment
bash "$tmpdir/PHASE2_DEPLOYMENT_VPS.sh"
EOFVPS

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "VPS deployment completed successfully"
        print_info "Log file: $vps_log"
        return 0
    else
        print_error "VPS deployment failed"
        print_info "Check log file: $vps_log"
        return 1
    fi
}

deploy_to_oracle() {
    print_section "DEPLOYING TO ORACLE"

    if [ -z "$ORACLE_HOST" ] || [ "$ORACLE_HOST" = "oracle-instance" ]; then
        print_warning "Oracle host not configured"
        print_info "Set ORACLE_HOST environment variable to deploy to Oracle"
        print_info "Example: export ORACLE_HOST=192.168.1.100"
        return 1
    fi

    local oracle_log="$LOCAL_LOG_DIR/oracle-deployment.log"

    if ! check_ssh_connectivity "$ORACLE_HOST" "$ORACLE_USER" "Oracle"; then
        print_error "Cannot connect to Oracle. Skipping..."
        return 1
    fi

    print_info "Downloading and running Oracle deployment script..."

    ssh -v "$ORACLE_USER@$ORACLE_HOST" << 'EFORACLE' 2>&1 | tee "$oracle_log"
set -euo pipefail

# Download deployment script
echo "Downloading Oracle deployment script..."
tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

curl -fsSL -o "$tmpdir/PHASE2_DEPLOYMENT_ORACLE.sh" \
    "https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/PHASE2_DEPLOYMENT_ORACLE.sh"

chmod +x "$tmpdir/PHASE2_DEPLOYMENT_ORACLE.sh"

# Run deployment
bash "$tmpdir/PHASE2_DEPLOYMENT_ORACLE.sh"
EFORACLE

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_success "Oracle deployment completed successfully"
        print_info "Log file: $oracle_log"
        return 0
    else
        print_error "Oracle deployment failed"
        print_info "Check log file: $oracle_log"
        return 1
    fi
}

verify_deployments() {
    print_section "VERIFYING DEPLOYMENTS"

    local vps_ok=true
    local oracle_ok=true

    # Verify VPS
    print_info "Verifying VPS installations..."
    if ssh "$VPS_USER@$VPS_HOST" << 'EOFVPS' &>/dev/null; then
        go version
        anthropic --version
        op --version
EOFVPS
        print_success "VPS installations verified"
    else
        print_error "VPS verification failed"
        vps_ok=false
    fi

    # Verify Oracle (if configured)
    if [ -n "$ORACLE_HOST" ] && [ "$ORACLE_HOST" != "oracle-instance" ]; then
        print_info "Verifying Oracle installations..."
        if ssh "$ORACLE_USER@$ORACLE_HOST" << 'EFORACLE' &>/dev/null; then
            go version
            anthropic --version
            op --version
EFORACLE
            print_success "Oracle installations verified"
        else
            print_error "Oracle verification failed"
            oracle_ok=false
        fi
    fi

    if [ "$vps_ok" = true ]; then
        print_success "All verified deployments successful"
        return 0
    else
        print_error "Some deployments failed verification"
        return 1
    fi
}

create_summary_report() {
    print_section "CREATING SUMMARY REPORT"

    local report_file="$LOCAL_LOG_DIR/PHASE2_DEPLOYMENT_SUMMARY.txt"

    cat > "$report_file" << EOF
================================================================================
PHASE 2 DEPLOYMENT SUMMARY
================================================================================

Deployment Date: $(date)
Master Script: PHASE2_DEPLOY_ALL.sh

================================================================================
DEPLOYMENT TARGETS
================================================================================

VPS:
  Host: $VPS_HOST
  User: $VPS_USER
  Status: $([ -f "$LOCAL_LOG_DIR/vps-deployment.log" ] && echo "Deployed" || echo "Not deployed")
  Log: $LOCAL_LOG_DIR/vps-deployment.log

Oracle:
  Host: ${ORACLE_HOST:-Not configured}
  User: $ORACLE_USER
  Status: $([ -f "$LOCAL_LOG_DIR/oracle-deployment.log" ] && echo "Deployed" || echo "Not deployed")
  Log: $LOCAL_LOG_DIR/oracle-deployment.log

================================================================================
INSTALLED COMPONENTS
================================================================================

All Environments:
  ✓ Go 1.26.4
  ✓ Anthropic CLI v0.9.0
  ✓ 1Password CLI
  ✓ Environment configuration
  ✓ Helper functions

================================================================================
NEXT STEPS
================================================================================

1. Configure 1Password on both environments:
   ssh root@$VPS_HOST
   op signin --account shannonjeffreylove.1password.com

2. Create Infrastructure vault items in 1Password

3. Load environment variables:
   source ~/.bashrc
   load-1password-env

4. Test API connectivity:
   anthropic models list
   anthropic message --model claude-3-5-sonnet "test"

5. Start Phase 2 testing:
   - Test para code generation
   - Test platform API connectivity
   - Test cross-platform linking

See PHASE2_READINESS.md for detailed Phase 2 testing procedures

================================================================================
LOG FILES
================================================================================

Local logs directory: $LOCAL_LOG_DIR/

VPS deployment log:
  $LOCAL_LOG_DIR/vps-deployment.log

$([ -f "$LOCAL_LOG_DIR/oracle-deployment.log" ] && echo "Oracle deployment log:" && echo "  $LOCAL_LOG_DIR/oracle-deployment.log" || echo "Oracle deployment: Not configured")

================================================================================
QUICK REFERENCE
================================================================================

SSH to VPS:
  ssh root@$VPS_HOST

SSH to Oracle:
  ssh $ORACLE_USER@${ORACLE_HOST:-<configure ORACLE_HOST>}

Check Go installation (from either system):
  go version
  go env

Check Anthropic CLI:
  anthropic --version
  anthropic models list

Sign in to 1Password:
  op signin --account shannonjeffreylove.1password.com

Load environment from 1Password:
  load-1password-env

Generate para code:
  anthropic message --model claude-3-5-sonnet \\
    "Generate a YYMMDD-XXXX para code"

================================================================================
EOF

    print_success "Summary report created: $report_file"
    cat "$report_file"
}

show_menu() {
    print_header "PHASE 2 DEPLOYMENT OPTIONS"
    echo ""
    echo -e "${CYAN}Select deployment option:${NC}"
    echo ""
    echo -e "${BLUE}1)${NC} Deploy to VPS only (72.61.74.250)"
    echo -e "${BLUE}2)${NC} Deploy to Oracle only"
    echo -e "${BLUE}3)${NC} Deploy to both VPS and Oracle"
    echo -e "${BLUE}4)${NC} Verify existing deployments"
    echo -e "${BLUE}5)${NC} View deployment logs"
    echo -e "${BLUE}q)${NC} Quit"
    echo ""
}

view_logs() {
    if [ ! -d "$LOCAL_LOG_DIR" ]; then
        print_error "No deployment logs found"
        return
    fi

    echo -e "${CYAN}Available log files:${NC}"
    ls -lh "$LOCAL_LOG_DIR"/ 2>/dev/null || print_error "No logs found"

    read -p "View which log file? (enter filename or press Enter to skip): " log_choice

    if [ -n "$log_choice" ] && [ -f "$LOCAL_LOG_DIR/$log_choice" ]; then
        less "$LOCAL_LOG_DIR/$log_choice"
    fi
}

################################################################################
# Main Menu
################################################################################

main() {
    print_header "PHASE 2 DEPLOYMENT ORCHESTRATOR"

    create_local_log_dir

    while true; do
        show_menu
        read -p "Enter your choice [1-5 or q]: " choice

        case "$choice" in
            1)
                echo ""
                deploy_to_vps
                ;;
            2)
                echo ""
                deploy_to_oracle
                ;;
            3)
                echo ""
                deploy_to_vps
                deploy_to_oracle
                create_summary_report
                ;;
            4)
                echo ""
                verify_deployments
                ;;
            5)
                echo ""
                view_logs
                ;;
            q|Q)
                echo ""
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

################################################################################
# Non-Interactive Mode
################################################################################

if [ "${1:-}" = "--vps-only" ]; then
    create_local_log_dir
    deploy_to_vps
    exit $?
elif [ "${1:-}" = "--oracle-only" ]; then
    create_local_log_dir
    deploy_to_oracle
    exit $?
elif [ "${1:-}" = "--all" ]; then
    create_local_log_dir
    deploy_to_vps
    deploy_to_oracle
    create_summary_report
    exit 0
elif [ "${1:-}" = "--verify" ]; then
    create_local_log_dir
    verify_deployments
    exit $?
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat << EOF
Usage: $0 [OPTIONS]

Phase 2 Deployment Orchestrator for VPS and Oracle environments

INTERACTIVE MODE (default):
  $0

NON-INTERACTIVE MODES:
  $0 --vps-only          Deploy to VPS only
  $0 --oracle-only       Deploy to Oracle only
  $0 --all               Deploy to both VPS and Oracle
  $0 --verify            Verify deployments
  $0 --help              Show this help message

ENVIRONMENT VARIABLES:
  ORACLE_HOST            Oracle server IP or hostname
  ORACLE_USER            Oracle SSH user (default: root)
  ANTHROPIC_API_KEY      Anthropic API key (optional)

EXAMPLES:
  # Interactive menu
  bash $0

  # Deploy to both with API key
  ANTHROPIC_API_KEY="sk-ant-..." ORACLE_HOST=192.168.1.100 bash $0 --all

  # Deploy to VPS only
  bash $0 --vps-only

EOF
    exit 0
else
    main "$@"
fi
