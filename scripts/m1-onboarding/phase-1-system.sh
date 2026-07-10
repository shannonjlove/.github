#!/bin/bash
# Phase 1: System Baseline Setup
# Installs macOS updates, Homebrew, Python 3.11, Node 20, and core development tools
# Safe to run multiple times - idempotent

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 1: System Baseline Setup${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Step 1: Check if running on Apple Silicon
echo -e "\n${BOLD}[1/6] Checking system architecture...${NC}"
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}ERROR: This script is for Apple Silicon (arm64). You have: $ARCH${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Running on Apple Silicon${NC}"

# Step 2: Install Homebrew (if not present)
echo -e "\n${BOLD}[2/6] Installing Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo -e "${GREEN}✓ Homebrew already installed${NC}"
fi

# Add Homebrew to PATH for this session
eval "$(/opt/homebrew/bin/brew shellenv)"

# Step 3: Update Homebrew and install core tools
echo -e "\n${BOLD}[3/6] Installing core development tools...${NC}"
echo "Updating Homebrew..."
brew update

PACKAGES=(
    "git"
    "gh"
    "node@20"
    "python@3.11"
    "uv"
    "pyenv"
    "pipx"
    "bun"
    "curl"
    "wget"
    "jq"
)

for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $pkg (already installed)"
    else
        echo "  Installing $pkg..."
        brew install "$pkg"
    fi
done

# Step 4: Configure Python 3.11
echo -e "\n${BOLD}[4/6] Configuring Python 3.11...${NC}"
if ! pyenv versions | grep -q 3.11; then
    echo "Setting up pyenv for Python 3.11..."
    eval "$(pyenv init -)"
fi
echo -e "${GREEN}✓ Python 3.11 configured${NC}"

# Step 5: Configure git globally (if not already done)
echo -e "\n${BOLD}[5/6] Configuring git...${NC}"
if [ -z "$(git config --global user.email)" ]; then
    echo "Setting git user configuration..."
    git config --global user.name "Shannon Love"
    git config --global user.email "sjlove@shannonjeffreylove.com"
    git config --global init.defaultBranch main
    echo -e "${GREEN}✓ Git configured${NC}"
else
    echo -e "${GREEN}✓ Git already configured${NC}"
fi

# Step 6: Update ~/.zshrc with shell configuration
echo -e "\n${BOLD}[6/6] Updating shell configuration...${NC}"
ZSHRC="$HOME/.zshrc"

# Backup original zshrc if it exists
if [ -f "$ZSHRC" ] && ! grep -q "# Claude M1 Onboarding Configuration" "$ZSHRC"; then
    cp "$ZSHRC" "${ZSHRC}.backup"
    echo -e "${GREEN}✓ Created backup: ${ZSHRC}.backup${NC}"
fi

# Add configuration block (idempotent)
if ! grep -q "# Claude M1 Onboarding Configuration" "$ZSHRC"; then
    cat >> "$ZSHRC" << 'EOF'

# Claude M1 Onboarding Configuration
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python 3.11 (primary)
export PATH="$(pyenv root)/shims:$PATH"
eval "$(pyenv init -)"

# Node 20
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"

# Aliases
alias ll='ls -la'
alias py='python3.11'
alias python='python3.11'

# Local AI Stack status (optional, comment out if not needed)
alias ai-status='curl -s http://localhost:11434/api/generate &>/dev/null && echo "✓ Ollama running" || echo "✗ Ollama down"; curl -s http://127.0.0.1:8100/health &>/dev/null && echo "✓ Memory Agent running" || echo "✗ Memory Agent down"'
EOF
    echo -e "${GREEN}✓ Shell configuration updated${NC}"
else
    echo -e "${GREEN}✓ Shell configuration already present${NC}"
fi

# Final step: Reload shell configuration
source "$ZSHRC"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 1 Complete: System Baseline Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Next Steps:${NC}"
echo "1. Reload your shell: ${BLUE}source ~/.zshrc${NC}"
echo "2. Verify installation: ${BLUE}python3.11 --version && node --version && git --version${NC}"
echo "3. Run Phase 2: ${BLUE}bash scripts/m1-onboarding/phase-2-para.sh${NC}"
