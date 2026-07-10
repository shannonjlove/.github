#!/bin/bash
# Phase 4: Local AI Stack Setup
# Installs Ollama, memory-agent, local-agent, and apple-notes-mcp
# Safe to run multiple times - idempotent

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 4: Local AI Stack Setup${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Step 1: Install and start Ollama
echo -e "\n${BOLD}[1/5] Setting up Ollama (LLM Engine)...${NC}"
if ! command -v ollama &> /dev/null; then
    echo "Installing Ollama..."
    brew install ollama
    echo -e "${GREEN}✓ Ollama installed${NC}"
else
    echo -e "${GREEN}✓ Ollama already installed${NC}"
fi

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/generate &>/dev/null; then
    echo "Starting Ollama daemon..."
    launchctl load ~/Library/LaunchAgents/com.local.ollama.plist 2>/dev/null || \
        nohup ollama serve > /tmp/ollama.log 2>&1 &
    sleep 2
    echo -e "${GREEN}✓ Ollama started${NC}"
else
    echo -e "${GREEN}✓ Ollama already running${NC}"
fi

# Pull qwen2.5:7b model
echo "Pulling qwen2.5:7b model (this may take a few minutes)..."
ollama pull qwen2.5:7b

# Step 2: Setup Tailscale VPN
echo -e "\n${BOLD}[2/5] Setting up Tailscale VPN connection...${NC}"
if ! command -v tailscale &> /dev/null; then
    echo "Installing Tailscale..."
    brew install tailscale
    echo -e "${GREEN}✓ Tailscale installed${NC}"
else
    echo -e "${GREEN}✓ Tailscale already installed${NC}"
fi

# Check if already connected
if tailscale ip -4 &>/dev/null; then
    IP=$(tailscale ip -4 | head -1)
    echo -e "${GREEN}✓ Tailscale connected (${IP})${NC}"
else
    echo -e "${YELLOW}⚠ Tailscale not connected yet${NC}"
    echo "Run this command to authenticate: ${BLUE}tailscale up${NC}"
fi

# Step 3: Setup claude-memory MCP server
echo -e "\n${BOLD}[3/5] Setting up claude-memory MCP server...${NC}"
if [ ! -f "$HOME/.local/lib/claude-memory/server.py" ]; then
    # Try to symlink from installed claude-memory-mcp
    if [ -d "$HOME/projects/claude-memory-mcp" ]; then
        mkdir -p "$HOME/.local/lib/claude-memory"
        ln -sf "$HOME/projects/claude-memory-mcp/src/server_fastmcp.py" \
               "$HOME/.local/lib/claude-memory/server.py"
        echo -e "${GREEN}✓ claude-memory linked${NC}"
    else
        echo -e "${YELLOW}⚠ claude-memory-mcp not found at ~/projects/claude-memory-mcp${NC}"
        echo "Install with: git clone https://github.com/shannonjlove/claude-memory-mcp ~/projects/claude-memory-mcp"
    fi
else
    echo -e "${GREEN}✓ claude-memory already set up${NC}"
fi

# Step 4: Setup memory-agent (REST API)
echo -e "\n${BOLD}[4/5] Setting up memory-agent (FastAPI)...${NC}"
MEMORY_AGENT_DIR="$HOME/projects/Hybrid-Personal-Cloud-Server-Infrastructure/02-CONTAINERS/ai-mcp-servers/memory-agent"
if [ -d "$MEMORY_AGENT_DIR" ]; then
    if [ ! -d "$MEMORY_AGENT_DIR/venv" ]; then
        echo "Creating virtual environment for memory-agent..."
        cd "$MEMORY_AGENT_DIR"
        python3.11 -m venv venv
        source venv/bin/activate
        pip install fastapi uvicorn aiofiles pydantic
        deactivate
        echo -e "${GREEN}✓ memory-agent environment set up${NC}"
    else
        echo -e "${GREEN}✓ memory-agent venv already exists${NC}"
    fi
else
    echo -e "${YELLOW}⚠ memory-agent not found${NC}"
    echo "Clone Hybrid-Personal-Cloud-Server-Infrastructure to: ${BLUE}~/projects/${NC}"
fi

# Step 5: Setup apple-notes-mcp
echo -e "\n${BOLD}[5/5] Setting up apple-notes-mcp...${NC}"
APPLE_NOTES_DIR="$HOME/projects/apple-notes-mcp"
if [ -d "$APPLE_NOTES_DIR" ]; then
    cd "$APPLE_NOTES_DIR"
    if ! command -v bun &> /dev/null; then
        echo "Installing Bun..."
        brew install bun
    fi
    echo "Installing apple-notes-mcp dependencies..."
    bun install 2>/dev/null || true
    echo -e "${GREEN}✓ apple-notes-mcp ready${NC}"
else
    echo -e "${YELLOW}⚠ apple-notes-mcp not found${NC}"
    echo "Clone to: ${BLUE}git clone https://github.com/shannonjlove/apple-notes-mcp ~/projects/apple-notes-mcp${NC}"
fi

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 4 Complete: Local AI Stack Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Services Status:${NC}"
curl -s http://localhost:11434/api/generate &>/dev/null && echo "  ${GREEN}✓${NC} Ollama" || echo "  ${RED}✗${NC} Ollama"
[ -f "$HOME/.local/lib/claude-memory/server.py" ] && echo "  ${GREEN}✓${NC} claude-memory" || echo "  ${RED}✗${NC} claude-memory"
[ -d "$MEMORY_AGENT_DIR" ] && echo "  ${GREEN}✓${NC} memory-agent" || echo "  ${RED}✗${NC} memory-agent"
[ -d "$APPLE_NOTES_DIR" ] && echo "  ${GREEN}✓${NC} apple-notes-mcp" || echo "  ${RED}✗${NC} apple-notes-mcp"
echo -e "\n${BOLD}Next Steps:${NC}"
echo "1. Connect Tailscale: ${BLUE}tailscale up${NC}"
echo "2. Start memory-agent: ${BLUE}cd $MEMORY_AGENT_DIR && source venv/bin/activate && python3.11 -m uvicorn app:app --port 8100${NC}"
echo "3. Run Phase 5: ${BLUE}bash scripts/m1-onboarding/phase-5-cloud.sh${NC}"
