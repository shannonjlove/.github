#!/bin/bash
# Phase 1: System Baseline for Stateless Laptop Node
# Minimal local setup: Homebrew, Python 3.11, Node, Git, SSH, Tailscale
# S3 storage will be mounted, not stored locally

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 1: Stateless Laptop Node - System Baseline${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Setup: Minimal local config + mount points for S3${NC}\n"

# Step 1: Check system
echo -e "${BOLD}[1/6] Checking system...${NC}"
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}ERROR: Requires Apple Silicon (arm64). You have: $ARCH${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Apple Silicon M1${NC}"

# Step 2: Install Homebrew
echo -e "\n${BOLD}[2/6] Installing Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo -e "${GREEN}✓ Homebrew already installed${NC}"
fi

# Step 3: Install minimal development tools
echo -e "\n${BOLD}[3/6] Installing development tools...${NC}"
PACKAGES=(
    "git"
    "gh"
    "python@3.11"
    "node@20"
    "rclone"
    "tailscale"
    "curl"
    "jq"
)

for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $pkg"
    else
        echo "  Installing $pkg..."
        brew install "$pkg"
    fi
done

# Step 4: Create local mount points for S3
echo -e "\n${BOLD}[4/6] Creating S3 mount points...${NC}"
MOUNT_POINTS=(
    "$HOME/PARA"
    "$HOME/projects"
    "$HOME/.claude-memory"
    "$HOME/Documents"
)

for mount_point in "${MOUNT_POINTS[@]}"; do
    if [ ! -d "$mount_point" ]; then
        mkdir -p "$mount_point"
        echo -e "  ${GREEN}✓${NC} Created $mount_point"
    else
        echo -e "  ${YELLOW}⚠${NC} $mount_point already exists"
    fi
done

# Step 5: Configure git
echo -e "\n${BOLD}[5/6] Configuring Git...${NC}"
if [ -z "$(git config --global user.email)" ]; then
    git config --global user.name "Shannon Love"
    git config --global user.email "sjlove@shannonjeffreylove.com"
    git config --global init.defaultBranch main
    echo -e "${GREEN}✓ Git configured${NC}"
else
    echo -e "${GREEN}✓ Git already configured${NC}"
fi

# Step 6: Update shell configuration
echo -e "\n${BOLD}[6/6] Updating shell configuration...${NC}"
ZSHRC="$HOME/.zshrc"

if ! grep -q "# Stateless Laptop Node Configuration" "$ZSHRC"; then
    cat >> "$ZSHRC" << 'EOF'

# Stateless Laptop Node Configuration
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python 3.11
export PATH="$(pyenv root)/shims:$PATH" 2>/dev/null || true
eval "$(pyenv init -)" 2>/dev/null || true

# Node 20
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"

# Aliases
alias ll='ls -la'
alias py='python3.11'
alias python='python3.11'

# Check rclone mounts on shell start
check_mounts() {
    echo "Checking S3 mounts..."
    for mount in PARA projects .claude-memory; do
        if mount | grep -q "$HOME/$mount"; then
            echo "  ✓ ~/$mount mounted"
        else
            echo "  ⚠ ~/$mount not mounted (run: rclone mount idrive-e2:shannonjlove/...)"
        fi
    done
}

# Tailscale status
check_tailscale() {
    if tailscale ip -4 &>/dev/null; then
        IP=$(tailscale ip -4 | head -1)
        echo "✓ Tailscale: $IP"
    else
        echo "⚠ Tailscale: Not connected (run: tailscale up)"
    fi
}
EOF
    echo -e "${GREEN}✓ Shell configuration updated${NC}"
fi

# Reload shell
source "$ZSHRC"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 1 Complete: System Ready for S3 Mounting${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Mount Points Created:${NC}"
for mount_point in "${MOUNT_POINTS[@]}"; do
    echo "  $mount_point (ready for S3 mount)"
done
echo -e "\n${BOLD}Next:${NC}"
echo "1. Reload shell: ${BLUE}source ~/.zshrc${NC}"
echo "2. Verify tools: ${BLUE}python3.11 --version && node --version && rclone --version${NC}"
echo "3. Run Phase 2: ${BLUE}bash scripts/m1-stateless/phase-2-s3-mount.sh${NC}"
