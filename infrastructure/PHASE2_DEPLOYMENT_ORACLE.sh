#!/bin/bash
################################################################################
# Phase 2 Deployment - Oracle Environment
# Purpose: Complete deployment of Go, Anthropic CLI, and infrastructure
# Date: July 5, 2026
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure"
LOG_DIR="/var/log/phase2"
LOG_FILE="$LOG_DIR/phase2-deployment-$(date +%Y%m%d-%H%M%S).log"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}========================================${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

create_log_dir() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
    print_info "Logging to: $LOG_FILE"
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

################################################################################
# Phase 2 Installation Steps
################################################################################

install_go() {
    print_header "Step 1: Installing Go 1.26.4"

    local tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" RETURN

    print_info "Downloading Go installation script..."
    if curl -fsSL -o "$tmpdir/GO_INSTALLATION_SETUP.sh" \
        "${REPO_URL}/GO_INSTALLATION_SETUP.sh"; then
        print_success "Downloaded Go installation script"
    else
        print_error "Failed to download Go installation script"
        return 1
    fi

    chmod +x "$tmpdir/GO_INSTALLATION_SETUP.sh"

    print_info "Running Go installation..."
    if bash "$tmpdir/GO_INSTALLATION_SETUP.sh" 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Go 1.26.4 installed successfully"

        # Verify
        export PATH="/usr/local/go/bin:$PATH"
        if go version 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Go verification passed"
            return 0
        else
            print_error "Go verification failed"
            return 1
        fi
    else
        print_error "Go installation failed"
        return 1
    fi
}

install_anthropic_cli() {
    print_header "Step 2: Installing Anthropic CLI"

    local tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" RETURN

    print_info "Downloading Anthropic CLI installation script..."
    if curl -fsSL -o "$tmpdir/ANTHROPIC_CLI_SETUP.sh" \
        "${REPO_URL}/ANTHROPIC_CLI_SETUP.sh"; then
        print_success "Downloaded Anthropic CLI installation script"
    else
        print_error "Failed to download Anthropic CLI installation script"
        return 1
    fi

    chmod +x "$tmpdir/ANTHROPIC_CLI_SETUP.sh"

    # Get API key
    local api_key="${ANTHROPIC_API_KEY:-}"
    if [ -z "$api_key" ]; then
        print_warning "ANTHROPIC_API_KEY not set"
        print_info "Enter Anthropic API key (or press Enter to skip):"
        read -r -p "> " api_key || api_key=""
    fi

    if [ -n "$api_key" ]; then
        export ANTHROPIC_API_KEY="$api_key"
        print_info "Running Anthropic CLI installation with API key..."
    else
        print_warning "Running installation without API key configuration"
    fi

    if bash "$tmpdir/ANTHROPIC_CLI_SETUP.sh" 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Anthropic CLI installed successfully"

        # Verify
        export PATH="/usr/local/bin:$PATH"
        if anthropic --version 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Anthropic CLI verification passed"
            return 0
        else
            print_error "Anthropic CLI verification failed"
            return 1
        fi
    else
        print_error "Anthropic CLI installation failed"
        return 1
    fi
}

install_1password_cli() {
    print_header "Step 3: Installing 1Password CLI"

    local distro=$(detect_distro)
    print_info "Detected Linux distribution: $distro"

    case "$distro" in
        ubuntu|debian)
            print_info "Installing for Debian/Ubuntu..."
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(lsb_release -cs) stable main" | \
                sudo tee /etc/apt/sources.list.d/1password.list

            sudo apt update
            if sudo apt install -y 1password-cli 2>&1 | tee -a "$LOG_FILE"; then
                print_success "1Password CLI installed successfully"
                return 0
            else
                print_error "Failed to install 1Password CLI"
                return 1
            fi
            ;;
        rhel|centos|fedora|ol)
            print_info "Installing for RHEL/CentOS/Oracle Linux..."
            if sudo dnf install -y 1password-cli 2>&1 | tee -a "$LOG_FILE"; then
                print_success "1Password CLI installed successfully"
                return 0
            else
                print_error "Failed to install 1Password CLI"
                return 1
            fi
            ;;
        *)
            print_warning "Unknown distribution: $distro"
            print_info "Installing from binary..."

            local arch=$(uname -m)
            if [ "$arch" = "x86_64" ]; then
                arch="amd64"
            elif [ "$arch" = "aarch64" ]; then
                arch="arm64"
            fi

            local tmpdir=$(mktemp -d)
            trap "rm -rf $tmpdir" RETURN

            curl -fsSL -o "$tmpdir/op.zip" \
                "https://cache.agilebits.com/download/OPM7/LINUX/1password-cli-linux-${arch}.zip"

            unzip -q "$tmpdir/op.zip" -d "$tmpdir"
            sudo mv "$tmpdir/op" /usr/local/bin/
            sudo chmod +x /usr/local/bin/op

            if op --version &>/dev/null; then
                print_success "1Password CLI installed successfully"
                return 0
            else
                print_error "1Password CLI verification failed"
                return 1
            fi
            ;;
    esac
}

configure_environment() {
    print_header "Step 4: Configuring Environment"

    local shell_profile="${HOME}/.bashrc"

    # Determine correct shell profile for root or regular user
    if [ "$(id -u)" = "0" ]; then
        shell_profile="/root/.bashrc"
    fi

    if [ ! -f "$shell_profile" ]; then
        print_warning "Shell profile not found: $shell_profile"
        print_info "Creating shell profile..."
        touch "$shell_profile"
    fi

    print_info "Adding environment configuration to $shell_profile..."

    # Add Go configuration
    if ! grep -q "export PATH=.*go.*bin" "$shell_profile"; then
        cat >> "$shell_profile" << 'EOF'

# Go Language Configuration
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
EOF
        print_success "Added Go configuration"
    fi

    # Add Anthropic CLI configuration
    if ! grep -q "export PATH=/usr/local/bin" "$shell_profile"; then
        cat >> "$shell_profile" << 'EOF'

# Anthropic CLI Configuration
export PATH=/usr/local/bin:$PATH
EOF
        print_success "Added Anthropic CLI configuration"
    fi

    # Add 1Password helper functions
    if ! grep -q "load-1password-env" "$shell_profile"; then
        cat >> "$shell_profile" << 'EOF'

# 1Password Helper Functions
load-1password-env() {
    export ANTHROPIC_API_KEY=$(op item get "Anthropic CLI" --vault Infrastructure --field api_key 2>/dev/null || echo "")
    export BOOKSTACK_URL=$(op item get Bookstack --vault Infrastructure --field base_url 2>/dev/null || echo "")
    export BOOKSTACK_TOKEN=$(op item get Bookstack --vault Infrastructure --field api_token 2>/dev/null || echo "")
    [ -n "$ANTHROPIC_API_KEY" ] && echo "✓ Anthropic API key loaded"
}

# Convenience aliases
alias go-version='go version && echo "GOROOT: $GOROOT" && echo "GOPATH: $GOPATH"'
alias anthropic-version='anthropic --version'
alias op-signin='op signin --account shannonjeffreylove.1password.com'
alias op-test='op whoami'
EOF
        print_success "Added 1Password helper functions"
    fi

    # Source profile
    if [ -f "$shell_profile" ]; then
        # shellcheck source=/dev/null
        . "$shell_profile" 2>/dev/null || true
        print_success "Environment configuration complete"
    fi
}

verify_installations() {
    print_header "Step 5: Verifying All Installations"

    local all_ok=true

    # Check Go
    print_info "Checking Go installation..."
    export PATH="/usr/local/go/bin:$PATH"
    if go version &>/dev/null; then
        go_version=$(go version)
        print_success "Go: $go_version"
    else
        print_error "Go verification failed"
        all_ok=false
    fi

    # Check Anthropic CLI
    print_info "Checking Anthropic CLI installation..."
    if anthropic --version &>/dev/null; then
        anthropic_version=$(anthropic --version)
        print_success "Anthropic CLI: $anthropic_version"
    else
        print_error "Anthropic CLI verification failed"
        all_ok=false
    fi

    # Check 1Password CLI
    print_info "Checking 1Password CLI installation..."
    if op --version &>/dev/null; then
        op_version=$(op --version)
        print_success "1Password CLI: $op_version"
    else
        print_error "1Password CLI verification failed"
        all_ok=false
    fi

    if [ "$all_ok" = true ]; then
        print_success "All installations verified successfully"
        return 0
    else
        print_error "Some installations failed verification"
        return 1
    fi
}

test_api_connectivity() {
    print_header "Step 6: Testing API Connectivity"

    # Test Anthropic API
    print_info "Testing Anthropic API..."
    if anthropic models list &>/dev/null; then
        print_success "Anthropic API connectivity verified"
    else
        print_warning "Anthropic API test failed (may require API key)"
    fi

    # Test 1Password
    print_info "Testing 1Password CLI..."
    if command -v op &>/dev/null; then
        print_success "1Password CLI operational"
        print_info "Next step: op signin --account shannonjeffreylove.1password.com"
    else
        print_warning "1Password CLI not available"
    fi
}

create_deployment_report() {
    print_header "Step 7: Creating Deployment Report"

    local report_file="${LOG_DIR}/PHASE2_DEPLOYMENT_REPORT.txt"

    cat > "$report_file" << EOF
================================================================================
PHASE 2 DEPLOYMENT REPORT - ORACLE
================================================================================

Deployment Date: $(date)
Hostname: $(hostname)
Architecture: $(uname -m)
Kernel: $(uname -r)
Distribution: $(detect_distro)

================================================================================
INSTALLATION STATUS
================================================================================

Go 1.26.4:
  Version: $(go version 2>/dev/null || echo "Not installed")
  GOROOT: ${GOROOT:-Not set}
  GOPATH: ${GOPATH:-Not set}

Anthropic CLI:
  Version: $(anthropic --version 2>/dev/null || echo "Not installed")
  Status: $(command -v anthropic &>/dev/null && echo "Installed" || echo "Not installed")

1Password CLI:
  Version: $(op --version 2>/dev/null || echo "Not installed")
  Status: $(command -v op &>/dev/null && echo "Installed" || echo "Not installed")

================================================================================
ENVIRONMENT CONFIGURATION
================================================================================

PATH: $PATH
GOROOT: ${GOROOT:-Not set}
GOPATH: ${GOPATH:-Not set}
ANTHROPIC_API_KEY: $([ -n "${ANTHROPIC_API_KEY:-}" ] && echo "Set" || echo "Not set")
Shell Profile: ~/.bashrc

================================================================================
NEXT STEPS
================================================================================

1. Reload shell configuration:
   source ~/.bashrc

2. Sign in to 1Password:
   op signin --account shannonjeffreylove.1password.com
   op whoami

3. Create Infrastructure vault items (in 1Password):
   - Anthropic CLI (API key)
   - Bookstack (URL, token, secret)
   - Paperless-NGX (URL, token)
   - Craft Docs (token, user ID)
   - TickTick (token)
   - Raindrop.io (token)
   - Remote Executor (host, port, key)

4. Load environment variables:
   load-1password-env

5. Test para code generation:
   anthropic message --model claude-3-5-sonnet \
     "Generate a YYMMDD-XXXX para code"

6. Continue with platform integration testing (see PHASE2_READINESS.md)

================================================================================
TROUBLESHOOTING
================================================================================

If Go installation failed:
  - Check /var/log/phase2-deployment-*.log for details
  - Verify disk space: df -h
  - Try manual installation using GO_INSTALLATION_GUIDE.md

If Anthropic CLI installation failed:
  - Ensure Go is installed first
  - Check API key format (should start with sk-ant-)
  - See ANTHROPIC_CLI_INSTALLATION.md troubleshooting section

If 1Password CLI installation failed:
  - Verify internet connectivity
  - Check if 1password-cli is available in distribution repos
  - Try binary installation as described in 1PASSWORD_QUICK_START.md

================================================================================
LOG FILES
================================================================================

Main log: $LOG_FILE
Report: $report_file

================================================================================
EOF

    print_success "Deployment report created: $report_file"
    cat "$report_file" | tee -a "$LOG_FILE"
}

################################################################################
# Main Deployment
################################################################################

main() {
    print_header "PHASE 2 DEPLOYMENT - ORACLE ENVIRONMENT"

    check_root
    create_log_dir

    print_info "Starting Phase 2 deployment..."
    print_info "All output will be logged to: $LOG_FILE"
    echo ""

    if install_go && \
       install_anthropic_cli && \
       install_1password_cli && \
       configure_environment && \
       verify_installations && \
       test_api_connectivity && \
       create_deployment_report; then

        print_header "PHASE 2 DEPLOYMENT COMPLETE"
        print_success "All components installed and verified successfully"
        print_info "Deployment report: $LOG_DIR/PHASE2_DEPLOYMENT_REPORT.txt"
        print_info "Full log file: $LOG_FILE"
        return 0
    else
        print_header "PHASE 2 DEPLOYMENT FAILED"
        print_error "Some components failed to install or verify"
        print_info "Check log file for details: $LOG_FILE"
        return 1
    fi
}

################################################################################
# Entry Point
################################################################################

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat << EOF
Usage: $0 [OPTIONS]

Phase 2 Deployment Script for Oracle Environment

OPTIONS:
  -h, --help              Show this help message
  --skip-1password        Skip 1Password CLI installation
  --api-key KEY           Set Anthropic API key

ENVIRONMENT VARIABLES:
  ANTHROPIC_API_KEY       Anthropic API key for authentication

EXAMPLES:
  # Standard deployment
  sudo bash $0

  # With API key
  ANTHROPIC_API_KEY="sk-ant-..." sudo bash $0

  # Skip 1Password
  sudo bash $0 --skip-1password

EOF
    exit 0
fi

main "$@"
