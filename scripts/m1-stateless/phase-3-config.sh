#!/bin/bash
# Phase 3: Local Configuration (Minimal, Non-Sync)
# Setup: Claude Code, SSH, AWS credentials, git config
# Everything stays local and is never synced to S3

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 3: Local Configuration (Non-Sync)${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Setup: Claude Code, SSH keys, AWS credentials${NC}"
echo -e "${YELLOW}⚠ These files NEVER sync to S3${NC}\n"

# Step 1: Install Claude CLI
echo -e "${BOLD}[1/4] Installing Claude Code CLI...${NC}"
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓ Claude CLI installed${NC}"
else
    echo -e "${GREEN}✓ Claude CLI already installed${NC}"
fi

# Step 2: Create Claude configuration (LOCAL)
echo -e "\n${BOLD}[2/4] Creating Claude Code configuration...${NC}"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cat > "$CLAUDE_DIR/settings.json" << 'EOF'
{
  "profile": "default",
  "shell": "zsh",
  "permission_mode": "user",
  "workspace": {
    "root": "~/projects",
    "auto_detect_repos": true
  },
  "mcpServers": {
    "claude-memory": {
      "command": "python3.11",
      "args": ["${HOME}/.local/lib/claude-memory/server.py"],
      "disabled": false,
      "env": {
        "MEMORY_ROOT": "${HOME}/.claude-memory"
      }
    }
  }
}
EOF
    echo -e "${GREEN}✓ Created Claude settings${NC}"
else
    echo -e "${GREEN}✓ Claude settings already exist${NC}"
fi

# Add to .gitignore to prevent accidental sync
cat >> "$HOME/.gitignore_global" << 'EOF'
# Never sync local configuration
.claude/settings.local.json
.aws/
.ssh/
EOF

# Step 3: SSH Configuration (LOCAL)
echo -e "\n${BOLD}[3/4] Setting up SSH configuration...${NC}"
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_DIR/config" ]; then
    cat > "$SSH_DIR/config" << 'EOF'
Host nexus
    HostName 100.115.66.75
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking accept-new
    HostKeyAlgorithms +ssh-rsa

Host sos
    HostName 100.67.229.94
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking accept-new
    HostKeyAlgorithms +ssh-rsa

Host webtop
    HostName 100.67.229.94
    User root
    IdentityFile ~/.ssh/id_rsa
    LocalForward 3000 127.0.0.1:3000
    LocalForward 3001 127.0.0.1:3001
    StrictHostKeyChecking accept-new
EOF
    chmod 600 "$SSH_DIR/config"
    echo -e "${GREEN}✓ SSH config created${NC}"
else
    echo -e "${GREEN}✓ SSH config already exists${NC}"
fi

# Generate SSH key if needed
if [ ! -f "$SSH_DIR/id_rsa" ]; then
    echo -e "${YELLOW}⚠ No SSH key found${NC}"
    echo "Generate with: ${BLUE}ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa${NC}"
    read -p "Press Enter after generating SSH key..."
fi

# Step 4: AWS Credentials (LOCAL)
echo -e "\n${BOLD}[4/4] AWS S3 Credentials Configuration...${NC}"
AWS_DIR="$HOME/.aws"
mkdir -p "$AWS_DIR"
chmod 700 "$AWS_DIR"

if [ ! -f "$AWS_DIR/credentials" ]; then
    echo -e "${YELLOW}⚠ AWS credentials file not found${NC}"
    echo ""
    echo "Required for rclone S3 access:"
    echo "  1. Get idrive e2 credentials"
    echo "  2. Create: ${BLUE}$AWS_DIR/credentials${NC}"
    echo ""
    echo "Format:"
    cat << 'CREDS'
[default]
aws_access_key_id = YOUR_IDRIVE_E2_KEY
aws_secret_access_key = YOUR_IDRIVE_E2_SECRET
CREDS
    echo ""
    read -p "Press Enter after setting up credentials..."
else
    echo -e "${GREEN}✓ AWS credentials configured${NC}"
fi

chmod 600 "$AWS_DIR/credentials"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 3 Complete: Local Configuration Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Configuration Locations (LOCAL, NON-SYNC):${NC}"
echo "  ~/.claude/              - Claude Code settings"
echo "  ~/.ssh/                 - SSH keys & config"
echo "  ~/.aws/credentials      - S3 credentials"
echo "  ~/.gitconfig_global     - Git user settings"
echo -e "\n${BOLD}These directories are PRIVATE to this laptop${NC}"
echo "They are NOT synced to S3 or backed up to cloud."
echo ""
echo -e "${BOLD}To Recover These Files on Another Machine:${NC}"
echo "  1. Restore SSH keys from password manager"
echo "  2. Restore AWS credentials from password manager"
echo "  3. Restore CloudFlare/1Password configs"
echo "  4. Everything else comes from S3 (PARA, projects, etc.)"
echo ""
echo -e "${BOLD}Next:${NC}"
echo "1. Verify Claude: ${BLUE}claude --help${NC}"
echo "2. Test SSH: ${BLUE}ssh nexus hostname${NC}"
echo "3. Run Phase 4: ${BLUE}bash scripts/m1-stateless/phase-4-cloud.sh${NC}"
