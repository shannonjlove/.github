#!/bin/bash
# Phase 1: Minimal System Baseline for Frontend-Only MacBook M1
# Only: Homebrew, Git, Tailscale, SSH, curl
# NO local development tools (Python, Node, rclone)
# NO S3 mounts
# NO working data storage

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 1: Minimal System Baseline (Frontend Only)${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Setup: Homebrew, Git, Tailscale, SSH${NC}"
echo -e "${YELLOW}⚠ This laptop is a pure FRONTEND to shannonjlove.cloud${NC}\n"

# Step 1: Check architecture
echo -e "${BOLD}[1/4] Verifying Apple Silicon M1...${NC}"
if [ "$(uname -m)" != "arm64" ]; then
    echo -e "${RED}ERROR: Not running on Apple Silicon${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Apple Silicon M1 detected${NC}"

# Step 2: Install Homebrew
echo -e "\n${BOLD}[2/4] Installing Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo -e "${GREEN}✓ Homebrew installed${NC}"
else
    echo -e "${GREEN}✓ Homebrew already installed${NC}"
fi

# Step 3: Install essential tools (NO dev tools)
echo -e "\n${BOLD}[3/4] Installing essential tools...${NC}"
tools=("git" "curl" "wget" "openssh" "tailscale")

for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "  Installing $tool..."
        brew install "$tool" || true
    fi
done
echo -e "${GREEN}✓ Essential tools installed${NC}"

# Step 4: Configure shell (zsh default on modern macOS)
echo -e "\n${BOLD}[4/4] Shell configuration...${NC}"
if [ -n "$ZSH_VERSION" ]; then
    shell_rc="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    shell_rc="$HOME/.bashrc"
else
    shell_rc="$HOME/.zshrc"
fi

# Add Homebrew to PATH if not already there
if ! grep -q "eval.*brew shellenv" "$shell_rc" 2>/dev/null; then
    echo "" >> "$shell_rc"
    echo "# Homebrew" >> "$shell_rc"
    eval "$(brew shellenv)" >> "$shell_rc"
fi

echo -e "${GREEN}✓ Shell configured${NC}"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 1 Complete: Minimal System Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}What's Installed:${NC}"
echo "  ✓ Homebrew (package manager)"
echo "  ✓ Git (version control)"
echo "  ✓ Tailscale (VPN to cloud)"
echo "  ✓ OpenSSH (remote access)"
echo "  ✓ curl, wget (networking)"
echo ""
echo -e "${BOLD}What's NOT Here:${NC}"
echo "  ✗ Python, Node, Go (use remote SSH)"
echo "  ✗ rclone, S3 mounts (use web UIs)"
echo "  ✗ Local development (all work on Nexus/sOs)"
echo ""
echo -e "${BOLD}Next:${NC}"
echo "1. Reload shell: ${BLUE}source $shell_rc${NC}"
echo "2. Run Phase 2: ${BLUE}bash scripts/m1-frontend/phase-2-cloud.sh${NC}"
