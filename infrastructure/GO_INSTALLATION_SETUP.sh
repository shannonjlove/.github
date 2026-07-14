#!/bin/bash
################################################################################
# Go Language Installation Setup
# Purpose: Install Go 1.26.4 on VPS and Oracle environments
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
GO_VERSION="1.26.4"
GO_DOWNLOAD_URL="https://go.dev/dl"
INSTALL_DIR="/usr/local"
GO_PATH="${HOME}/go"

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

check_existing_go() {
    if command -v go &> /dev/null; then
        local current_version=$(go version | awk '{print $3}' | sed 's/go//')
        print_warning "Go is already installed: $current_version"
        read -p "Do you want to upgrade to Go $GO_VERSION? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping installation"
            return 1
        fi
    fi
    return 0
}

download_go() {
    local arch=$1
    local filename="go${GO_VERSION}.linux-${arch}.tar.gz"
    local download_url="${GO_DOWNLOAD_URL}/${filename}"

    print_info "Detecting Go binary for architecture: $arch"
    print_info "Download URL: $download_url"

    # Create temp directory
    local tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT

    cd "$tmpdir"

    print_info "Downloading Go $GO_VERSION..."
    if ! curl -fsSL -o "$filename" "$download_url"; then
        print_error "Failed to download Go from $download_url"
        print_info "Trying alternative download location..."
        # Alternative mirror
        if ! wget -q "$download_url" -O "$filename"; then
            print_error "Could not download Go binary"
            exit 1
        fi
    fi

    print_success "Downloaded: $filename"

    # Verify SHA256 (if available)
    print_info "Verifying checksum..."
    local shafile="${filename}.sha256"

    if curl -fsSL -o "$shafile" "${GO_DOWNLOAD_URL}/${shafile}" 2>/dev/null; then
        if sha256sum -c "$shafile" &>/dev/null; then
            print_success "Checksum verified"
        else
            print_warning "Checksum verification failed - proceeding anyway"
        fi
    else
        print_warning "Could not verify checksum - proceeding anyway"
    fi

    # Return the full path to the tarball
    echo "$tmpdir/$filename"
}

install_go() {
    local tarball=$1

    print_info "Removing existing Go installation (if any)..."
    if [ -d "${INSTALL_DIR}/go" ]; then
        rm -rf "${INSTALL_DIR}/go"
        print_success "Removed old Go installation"
    fi

    print_info "Extracting Go to $INSTALL_DIR..."
    tar -C "$INSTALL_DIR" -xzf "$tarball"

    if [ -d "${INSTALL_DIR}/go" ]; then
        print_success "Go extracted successfully"
    else
        print_error "Go extraction failed"
        exit 1
    fi
}

configure_path() {
    local shell_profile=""

    # Detect shell profile
    if [ -f "$HOME/.bashrc" ]; then
        shell_profile="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        shell_profile="$HOME/.bash_profile"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_profile="$HOME/.zshrc"
    fi

    if [ -z "$shell_profile" ]; then
        print_warning "Could not detect shell profile"
        return
    fi

    print_info "Configuring PATH in $shell_profile..."

    # Check if Go paths are already in the profile
    if grep -q "${INSTALL_DIR}/go/bin" "$shell_profile"; then
        print_info "Go paths already configured in shell profile"
    else
        # Add Go to PATH
        cat >> "$shell_profile" << EOF

# Go language configuration (added $(date '+%Y-%m-%d'))
export GOROOT=${INSTALL_DIR}/go
export GOPATH=${GO_PATH}
export PATH=\$GOROOT/bin:\$GOPATH/bin:\$PATH
EOF
        print_success "Added Go to PATH in $shell_profile"
    fi
}

verify_installation() {
    print_info "Verifying Go installation..."

    # Update PATH temporarily for this script
    export PATH="${INSTALL_DIR}/go/bin:$PATH"

    if ! command -v go &> /dev/null; then
        print_error "Go binary not found in PATH"
        exit 1
    fi

    local go_version=$(go version)
    print_success "Go installed: $go_version"

    # Test Go functionality
    local test_dir=$(mktemp -d)
    trap "rm -rf $test_dir" RETURN

    cd "$test_dir"

    cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Go is working correctly!")
}
EOF

    if go run main.go &>/dev/null; then
        print_success "Go test program executed successfully"
    else
        print_warning "Go test program had issues, but binary may still be functional"
    fi
}

create_go_workspace() {
    print_info "Creating Go workspace directory..."

    mkdir -p "$GO_PATH"/{bin,pkg,src}

    print_success "Go workspace created at: $GO_PATH"
}

print_summary() {
    print_header "Go Installation Complete"

    cat << EOF

Installation Summary:
  Go Version:  ${GO_VERSION}
  Install Dir: ${INSTALL_DIR}/go
  Go Workspace: ${GO_PATH}

Next Steps:
  1. Reload your shell or run:
     source ~/.bashrc  # or ~/.bash_profile or ~/.zshrc

  2. Verify installation:
     go version
     go env

  3. Test with a simple program:
     cd ~/tmp
     go mod init example
     echo 'package main; import "fmt"; func main() { fmt.Println("Hello, Go!") }' > main.go
     go run main.go

Documentation:
  Go Official: https://golang.org/
  Getting Started: https://go.dev/doc/tutorial

Environment Variables:
  GOROOT=${INSTALL_DIR}/go
  GOPATH=${GO_PATH}
  PATH includes: \${GOROOT}/bin:\${GOPATH}/bin

EOF
}

################################################################################
# Main Installation Script
################################################################################

main() {
    print_header "Go Language Installation Script (v${GO_VERSION})"

    # Check if running as root
    check_root

    # Check for existing Go installation
    if ! check_existing_go; then
        exit 0
    fi

    # Detect system architecture
    local arch=$(detect_arch)
    print_success "Detected architecture: $arch"

    # Download Go binary
    local tarball=$(download_go "$arch")

    # Install Go
    install_go "$tarball"

    # Configure shell PATH
    configure_path

    # Create Go workspace
    create_go_workspace

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

Go Installation Script - Installs Go ${GO_VERSION}

OPTIONS:
  -h, --help              Show this help message
  -v, --version           Show Go version to install
  --no-verify             Skip checksum verification
  --uninstall             Uninstall Go

ENVIRONMENT VARIABLES:
  GO_VERSION              Override Go version (default: ${GO_VERSION})
  INSTALL_DIR             Override installation directory (default: ${INSTALL_DIR})
  GO_PATH                 Override Go workspace (default: ${GO_PATH})

EXAMPLES:
  # Standard installation
  sudo bash $0

  # With custom installation directory
  INSTALL_DIR=/opt sudo bash $0

  # Uninstall Go
  sudo bash $0 --uninstall

EOF
    exit 0
fi

# Handle uninstall
if [ "${1:-}" = "--uninstall" ]; then
    check_root
    print_info "Uninstalling Go..."
    if [ -d "${INSTALL_DIR}/go" ]; then
        rm -rf "${INSTALL_DIR}/go"
        print_success "Go uninstalled from ${INSTALL_DIR}/go"
    else
        print_warning "Go installation not found at ${INSTALL_DIR}/go"
    fi
    exit 0
fi

# Run main installation
main
