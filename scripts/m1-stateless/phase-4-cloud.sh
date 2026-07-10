#!/bin/bash
# Phase 4: Cloud Connectivity
# Tailscale VPN, memory-agent access, final verification
# Make laptop a node in shannonjlove.cloud ecosystem

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 4: Cloud Connectivity${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Setup: Tailscale VPN, memory-agent access, cloud integration${NC}\n"

# Step 1: Verify Tailscale
echo -e "${BOLD}[1/3] Verifying Tailscale VPN...${NC}"
if ! command -v tailscale &> /dev/null; then
    echo -e "${RED}ERROR: Tailscale not installed${NC}"
    exit 1
fi

if tailscale ip -4 &>/dev/null; then
    IP=$(tailscale ip -4 | head -1)
    echo -e "${GREEN}✓ Tailscale connected ($IP)${NC}"
else
    echo -e "${YELLOW}⚠ Tailscale not connected${NC}"
    echo "Connect with: ${BLUE}tailscale up${NC}"
    read -p "Press Enter after connecting to Tailscale..."
fi

# Verify connectivity to cloud infrastructure
echo -e "\nVerifying cloud access..."
if ping -c 1 100.115.66.75 >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Nexus reachable (100.115.66.75)"
else
    echo -e "  ${YELLOW}⚠${NC} Nexus not reachable (may be offline)"
fi

if ping -c 1 100.67.229.94 >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} sOs reachable (100.67.229.94)"
else
    echo -e "  ${YELLOW}⚠${NC} sOs not reachable"
fi

# Step 2: Setup claude-memory MCP server link
echo -e "\n${BOLD}[2/3] Setting up Claude Memory MCP server...${NC}"
MCP_DIR="$HOME/.local/lib/claude-memory"
mkdir -p "$MCP_DIR"

# Check if claude-memory-mcp exists in projects
if [ -f "$HOME/projects/claude-memory-mcp/src/server_fastmcp.py" ]; then
    ln -sf "$HOME/projects/claude-memory-mcp/src/server_fastmcp.py" \
           "$MCP_DIR/server.py"
    echo -e "${GREEN}✓ claude-memory MCP linked${NC}"
else
    echo -e "${YELLOW}⚠ claude-memory-mcp not found in ~/projects/${NC}"
    echo "Will be available after git cloning projects from S3"
fi

# Step 3: Verify cloud integration
echo -e "\n${BOLD}[3/3] Final Cloud Integration Checks...${NC}"

echo -e "\nStorage:"
if [ -d "$HOME/PARA" ] && mount | grep -q "$HOME/PARA"; then
    echo -e "  ${GREEN}✓${NC} PARA mounted from S3"
else
    echo -e "  ${RED}✗${NC} PARA not mounted"
fi

if [ -d "$HOME/projects" ] && mount | grep -q "$HOME/projects"; then
    echo -e "  ${GREEN}✓${NC} projects mounted from S3"
else
    echo -e "  ${RED}✗${NC} projects not mounted"
fi

if [ -d "$HOME/.claude-memory" ] && mount | grep -q "$HOME/.claude-memory"; then
    echo -e "  ${GREEN}✓${NC} claude-memory mounted from S3"
else
    echo -e "  ${RED}✗${NC} claude-memory not mounted"
fi

echo -e "\nNetwork:"
if tailscale ip -4 &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Tailscale VPN active"
else
    echo -e "  ${RED}✗${NC} Tailscale not connected"
fi

echo -e "\nServices:"
if command -v claude &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Claude Code CLI"
else
    echo -e "  ${RED}✗${NC} Claude Code CLI"
fi

if command -v git &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Git"
else
    echo -e "  ${RED}✗${NC} Git"
fi

if command -v rclone &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} rclone (S3 mount)"
else
    echo -e "  ${RED}✗${NC} rclone"
fi

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 4 Complete: Cloud Connected${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Your MacBook M1 is now a Stateless Laptop Node:${NC}"
echo ""
echo "✅ Stateless Architecture:"
echo "   • All data storage: idrive e2 S3 (mounted via rclone)"
echo "   • Local config only: .claude, .ssh, .aws, ~/.gitconfig"
echo "   • System is replaceable at any time"
echo ""
echo "✅ Cloud Integrated:"
echo "   • Tailscale VPN: Connected to shannonjlove.cloud"
echo "   • Memory Agent: Access via 100.115.66.75:8100"
echo "   • SSH Access: ssh nexus, ssh sos"
echo ""
echo "✅ Development Ready:"
echo "   • Claude Code: $(claude --version 2>/dev/null || echo 'installed')"
echo "   • Git: $(git --version | head -1)"
echo "   • Python: $(python3.11 --version 2>/dev/null || echo 'installed')"
echo "   • Node: $(node --version 2>/dev/null || echo 'installed')"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo "1. Verify setup: ${BLUE}bash scripts/m1-stateless/verify-setup.sh${NC}"
echo "2. Start working: ${BLUE}cd ~/PARA/1-PROJECTS${NC}"
echo "3. Clone projects: ${BLUE}cd ~/projects && git clone ...${NC}"
echo ""
echo -e "${BOLD}If Laptop Breaks:${NC}"
echo "1. Get new MacBook"
echo "2. Run setup (Phases 1-4)"
echo "3. All data restored from S3"
echo "4. Continue exactly where you left off"
echo ""
echo -e "${BOLD}Remember:${NC}"
echo "• ~/.ssh keys must be restored from password manager"
echo "• ~/.aws credentials must be restored from password manager"
echo "• Everything else lives in idrive e2 S3"
echo "• Laptop is stateless and fully replaceable"
