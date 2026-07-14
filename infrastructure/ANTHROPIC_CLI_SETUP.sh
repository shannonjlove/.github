#!/bin/bash
################################################################################
# Anthropic CLI Installation Setup
# Purpose: Install Anthropic CLI on VPS and Oracle environments
# Supports: Linux x86_64, ARM64
# Date: July 5, 2026
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ANTHROPIC_VERSION="0.9.0"
GITHUB_REPO="anthropics/anthropic-cli"
INSTALL_DIR="/usr/local/bin"
API_KEY="${ANTHROPIC_API_KEY:-}"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}"
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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

check_existing_anthropic() {
    if command -v anthropic &> /dev/null; then
        local current_version=$(anthropic --version 2>/dev/null | awk '{print $NF}' || echo "unknown")
        print_warning "Anthropic CLI is already installed: v$current_version"
        read -p "Do you want to upgrade to Anthropic CLI v${ANTHROPIC_VERSION}? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping installation"
            return 1
        fi
    fi
    return 0
}

download_anthropic() {
    local arch=$1
    local download_url="https://github.com/${GITHUB_REPO}/releases/download/v${ANTHROPIC_VERSION}/anthropic-cli_${ANTHROPIC_VERSION}_Linux_${arch}.tar.gz"

    print_info "Downloading Anthropic CLI v${ANTHROPIC_VERSION} for architecture: $arch"
    print_info "Download URL: $download_url"

    # Create temp directory
    local tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT

    cd "$tmpdir"

    print_info "Downloading Anthropic CLI..."
    if ! curl -fsSL -o anthropic.tar.gz "$download_url"; then
        print_error "Failed to download Anthropic CLI from $download_url"
        print_info "Trying alternative download location..."
        # Try alternative
        if ! wget -q "$download_url" -O anthropic.tar.gz 2>/dev/null; then
            print_error "Could not download Anthropic CLI binary"
            exit 1
        fi
    fi

    print_success "Downloaded Anthropic CLI"

    # Return the full path to the tarball
    echo "$tmpdir/anthropic.tar.gz"
}

install_anthropic() {
    local tarball=$1

    print_info "Removing existing Anthropic CLI (if any)..."
    if [ -f "${INSTALL_DIR}/anthropic" ]; then
        rm -f "${INSTALL_DIR}/anthropic"
        print_success "Removed old Anthropic CLI"
    fi

    print_info "Extracting Anthropic CLI to $INSTALL_DIR..."
    tar -xzf "$tarball" -C "${INSTALL_DIR}/"

    if [ -f "${INSTALL_DIR}/anthropic" ]; then
        chmod +x "${INSTALL_DIR}/anthropic"
        print_success "Anthropic CLI extracted successfully"
    else
        print_error "Anthropic CLI extraction failed"
        exit 1
    fi
}

configure_api_key() {
    # Try to get API key from environment variable
    if [ -z "$API_KEY" ]; then
        print_warning "ANTHROPIC_API_KEY environment variable not set"
        read -p "Enter Anthropic API key (or press Enter to skip): " -r API_KEY
        if [ -z "$API_KEY" ]; then
            print_info "Skipping API key configuration"
            return 0
        fi
    fi

    # Determine target shell profile
    local shell_profile=""

    if [ -f "/root/.bashrc" ]; then
        shell_profile="/root/.bashrc"
    elif [ -f "/root/.bash_profile" ]; then
        shell_profile="/root/.bash_profile"
    elif [ -f "/root/.zshrc" ]; then
        shell_profile="/root/.zshrc"
    fi

    if [ -z "$shell_profile" ]; then
        print_warning "Could not detect shell profile"
        return
    fi

    print_info "Configuring API key in $shell_profile..."

    # Check if API key is already configured
    if grep -q "ANTHROPIC_API_KEY" "$shell_profile"; then
        print_info "API key already configured in shell profile"
    else
        # Add API key to shell profile
        cat >> "$shell_profile" << EOF

# Anthropic CLI configuration (added $(date '+%Y-%m-%d'))
export ANTHROPIC_API_KEY="${API_KEY}"
EOF
        print_success "Added API key to shell profile"
    fi
}

verify_installation() {
    print_info "Verifying Anthropic CLI installation..."

    # Update PATH temporarily for this script
    export PATH="${INSTALL_DIR}:$PATH"

    if ! command -v anthropic &> /dev/null; then
        print_error "Anthropic CLI binary not found in PATH"
        exit 1
    fi

    local cli_version=$(anthropic --version)
    print_success "Anthropic CLI installed: $cli_version"

    # Test API connectivity if key is available
    if [ ! -z "$API_KEY" ]; then
        print_info "Testing API connectivity..."
        export ANTHROPIC_API_KEY="$API_KEY"

        if anthropic models list &>/dev/null; then
            print_success "API connectivity verified"
        else
            print_warning "API connectivity test failed, but binary may still be functional"
        fi
    else
        print_info "Skipping API connectivity test (no API key configured)"
    fi
}

print_summary() {
    print_header "Anthropic CLI Installation Complete"

    cat << EOF

Installation Summary:
  CLI Version: ${ANTHROPIC_VERSION}
  Install Dir: ${INSTALL_DIR}/anthropic

Next Steps:
  1. Reload your shell or run:
     source ~/.bashrc  # or ~/.bash_profile or ~/.zshrc

  2. Verify installation:
     anthropic --version
     anthropic models list

  3. Test with a simple message:
     anthropic message --model claude-3-5-sonnet "Hello, Claude!"

Documentation:
  GitHub Repository: https://github.com/anthropics/anthropic-cli
  Claude API Docs: https://docs.anthropic.com/

Environment Variables:
  ANTHROPIC_API_KEY=${API_KEY:0:20}...

EOF
}

################################################################################
# Main Installation Script
################################################################################

main() {
    print_header "Anthropic CLI Installation Script (v${ANTHROPIC_VERSION})"

    # Check if running as root
    check_root

    # Check for existing installation
    if ! check_existing_anthropic; then
        exit 0
    fi

    # Detect system architecture
    local arch=$(detect_arch)
    print_success "Detected architecture: $arch"

    # Download Anthropic CLI binary
    local tarball=$(download_anthropic "$arch")

    # Install Anthropic CLI
    install_anthropic "$tarball"

    # Configure API key
    configure_api_key

    # Verify installation
    verify_installation

    # Print summary
    print_summary
}

################################################################################
# Script Entry Point
################################################################################

# Show usage information
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat << EOF
Usage: $0 [OPTIONS]

Anthropic CLI Installation Script - Installs Anthropic CLI v${ANTHROPIC_VERSION}

OPTIONS:
  -h, --help              Show this help message
  -v, --version           Show version to install
  --uninstall             Uninstall Anthropic CLI

ENVIRONMENT VARIABLES:
  ANTHROPIC_API_KEY       API key for authentication
  ANTHROPIC_VERSION       Override version (default: ${ANTHROPIC_VERSION})
  INSTALL_DIR             Override installation directory (default: ${INSTALL_DIR})

EXAMPLES:
  # Standard installation
  sudo bash $0

  # With API key
  ANTHROPIC_API_KEY="sk-ant-..." sudo bash $0

  # Uninstall
  sudo bash $0 --uninstall

EOF
    exit 0
fi

# Handle uninstall
if [ "${1:-}" = "--uninstall" ]; then
    check_root
    print_info "Uninstalling Anthropic CLI..."
    if [ -f "${INSTALL_DIR}/anthropic" ]; then
        rm -f "${INSTALL_DIR}/anthropic"
        print_success "Anthropic CLI uninstalled from ${INSTALL_DIR}/anthropic"
    else
        print_warning "Anthropic CLI installation not found at ${INSTALL_DIR}/anthropic"
    fi
    exit 0
fi

# Run main installation
main
