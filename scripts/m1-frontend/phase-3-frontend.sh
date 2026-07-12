#!/bin/bash
# Phase 3: Frontend Tools for MacBook M1
# Setup: Claude CLI, Browser config, local-only config (never sync to S3)
# Everything else accessed via cloud SSH/APIs

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 3: Frontend Tools (Claude CLI, SSH Config)${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Setup: Claude Code CLI, SSH keys, local config${NC}"
echo -e "${YELLOW}⚠ Local config NEVER syncs to cloud${NC}\n"

# Step 1: Install Claude CLI
echo -e "${BOLD}[1/3] Installing Claude Code CLI...${NC}"
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓ Claude CLI installed${NC}"
else
    echo -e "${GREEN}✓ Claude CLI already installed${NC}"
fi

# Step 2: Claude configuration (LOCAL only)
echo -e "\n${BOLD}[2/3] Creating Claude Code configuration...${NC}"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cat > "$CLAUDE_DIR/settings.json" << 'EOF'
{
  "profile": "frontend",
  "shell": "zsh",
  "permission_mode": "user",
  "workspace": {
    "root": "~/projects",
    "auto_detect_repos": false
  },
  "mcpServers": {
    "claude-memory-cloud": {
      "command": "bash",
      "args": ["-c", "ssh nexus -L 8100:localhost:8100 sleep 999999"],
      "disabled": false,
      "env": {
        "MEMORY_API": "http://localhost:8100"
      }
    },
    "local-agent": {
      "command": "bash",
      "args": ["-c", "ssh nexus -L 8101:localhost:8101 sleep 999999"],
      "disabled": false,
      "env": {
        "AGENT_API": "http://localhost:8101"
      }
    }
  }
}
EOF
    echo -e "${GREEN}✓ Created Claude settings${NC}"
else
    echo -e "${GREEN}✓ Claude settings already exist${NC}"
fi

# Step 3: SSH keys and local config
echo -e "\n${BOLD}[3/3] SSH and Git Configuration...${NC}"
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Git config
if [ ! -f "$HOME/.gitconfig" ]; then
    git config --global user.name "Frontend User"
    git config --global user.email "frontend@shannonjlove.cloud"
    echo -e "${GREEN}✓ Git config created${NC}"
else
    echo -e "${GREEN}✓ Git config already exists${NC}"
fi

# Prevent accidental sync of credentials
cat >> "$HOME/.gitignore_global" 2>/dev/null || cat > "$HOME/.gitignore_global" << 'EOF'
# Local config (never sync)
.claude/settings.local.json
.ssh/
.aws/
.env
.env.local
EOF
git config --global core.excludesfile "$HOME/.gitignore_global"

echo -e "${GREEN}✓ Local credentials protected${NC}"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 3 Complete: Frontend Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Local Configuration (Non-Sync):${NC}"
echo "  ~/.claude/              - Claude Code settings"
echo "  ~/.ssh/                 - SSH keys and config"
echo "  ~/.gitconfig            - Git user settings"
echo ""
echo -e "${BOLD}Claude Code with Cloud MCP Servers:${NC}"
echo "  • claude-memory via SSH tunnel to Nexus:8100"
echo "  • local-agent via SSH tunnel to Nexus:8101"
echo ""
echo -e "${BOLD}Development Workflow:${NC}"
echo "  1. SSH into Nexus or sOs: ${BLUE}ssh nexus${NC}"
echo "  2. Clone and work in remote environment"
echo "  3. Use Claude Code to connect to cloud MCP servers"
echo "  4. Access PARA, projects, memories via web or remote SSH"
echo ""
echo -e "${BOLD}Browser Access:${NC}"
echo "  • https://npm.shannonjlove.cloud (public)"
echo "  • https://memory.shannonjlove.cloud (Tailscale-only)"
echo ""
echo -e "${BOLD}If SSH Key Missing:${NC}"
echo "  1. Generate: ${BLUE}ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa${NC}"
echo "  2. Add public key to Nexus/sOs authorized_keys"
echo "  3. Restore from password manager if available"
echo ""
echo -e "${BOLD}Next:${NC}"
echo "1. Test SSH: ${BLUE}ssh nexus hostname${NC}"
echo "2. Run verification: ${BLUE}bash scripts/m1-frontend/verify-setup.sh${NC}"
