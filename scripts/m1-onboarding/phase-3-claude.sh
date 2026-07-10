#!/bin/bash
# Phase 3: Claude Code Installation & Configuration
# Installs Claude CLI, VS Code extension, and configures MCP servers
# Safe to run multiple times - idempotent

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 3: Claude Code Installation & Configuration${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Step 1: Install Claude CLI
echo -e "\n${BOLD}[1/4] Installing Claude Code CLI...${NC}"
if ! command -v claude &> /dev/null; then
    echo "Installing @anthropic-ai/claude-code globally..."
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓ Claude CLI installed${NC}"
else
    VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Claude CLI already installed (${VERSION})${NC}"
fi

# Step 2: Create Claude Code configuration directory
echo -e "\n${BOLD}[2/4] Setting up Claude Code configuration...${NC}"
CLAUDE_CONFIG_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Create settings.json if it doesn't exist
if [ ! -f "$CLAUDE_CONFIG_DIR/settings.json" ]; then
    cat > "$CLAUDE_CONFIG_DIR/settings.json" << 'EOF'
{
  "profile": "default",
  "shell": "zsh",
  "permission_mode": "user",
  "workspace": {
    "root": "~/PARA/1-PROJECTS",
    "auto_detect_repos": true
  },
  "hooks": {
    "before_command": "echo '🚀 Command: ${CMD}'",
    "after_command": "echo '✅ Complete'"
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
    echo -e "${GREEN}✓ Created settings.json${NC}"
else
    echo -e "${YELLOW}⚠ settings.json already exists (keeping existing)${NC}"
fi

echo -e "${GREEN}✓ Claude Code configuration ready${NC}"

# Step 3: Install VS Code and Claude extension (if VS Code available)
echo -e "\n${BOLD}[3/4] Setting up VS Code integration...${NC}"

if command -v code &> /dev/null; then
    echo "Installing Claude Code extension..."
    code --install-extension Anthropic.claude-code 2>/dev/null || echo "Claude Code extension already installed"

    # Install complementary extensions
    EXTENSIONS=(
        "ms-python.python"
        "dbaeumer.vscode-eslint"
        "redhat.vscode-yaml"
        "eamodio.gitlens"
    )

    for ext in "${EXTENSIONS[@]}"; do
        code --install-extension "$ext" 2>/dev/null || true
    done

    echo -e "${GREEN}✓ VS Code extensions installed${NC}"
else
    echo -e "${YELLOW}⚠ VS Code not found. Install with: ${BLUE}brew install visual-studio-code${NC}"
fi

# Step 4: Create local directories for MCP resources
echo -e "\n${BOLD}[4/4] Preparing MCP server directories...${NC}"
mkdir -p "$HOME/.local/lib/claude-memory"
mkdir -p "$HOME/.claude-memory/conversations"
mkdir -p "$HOME/.claude-memory/summaries"

# Create Claude memory README
if [ ! -f "$HOME/.claude-memory/README.md" ]; then
    cat > "$HOME/.claude-memory/README.md" << 'EOF'
# Claude Memory Store

Local storage for Claude Code conversation history and context.

## Structure

- `conversations/` - Full conversation transcripts
- `summaries/` - Weekly auto-generated summaries
- `context-snapshots/` - Project-specific context saves

## Sync

This directory is replicated to cloud infrastructure:
- Local: `~/.claude-memory/`
- Cloud: `/mnt/shared-context/claude-memories/` (via NFS)

Keep both in sync to maintain consistent context across devices.

## Usage in Claude Code

```
# View all memories
/memories view

# Create new memory
/memories create "Topic" "Content here"

# Search memories
/memories search "keyword"
```

---

Created: $(date)
EOF
    echo -e "${GREEN}✓ Created Claude memory directories${NC}"
fi

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 3 Complete: Claude Code Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Claude Code Status:${NC}"
echo "  CLI: $(claude --version 2>/dev/null || echo 'not installed')"
echo "  Config: $CLAUDE_CONFIG_DIR/settings.json"
echo "  Workspace: ~/PARA/1-PROJECTS"
echo -e "\n${BOLD}Next Steps:${NC}"
echo "1. Verify CLI: ${BLUE}claude --help${NC}"
echo "2. (Optional) Install VS Code: ${BLUE}brew install visual-studio-code${NC}"
echo "3. Run Phase 4: ${BLUE}bash scripts/m1-onboarding/phase-4-ai-stack.sh${NC}"
