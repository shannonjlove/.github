#!/bin/bash
# Phase 2: Cloud Connectivity for Frontend MacBook M1
# Setup: Tailscale VPN, SSH config to Nexus/sOs, cloud access verification
# All actual work happens on remote nodes via SSH or web UI

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 2: Cloud Connectivity (Frontend)${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BLUE}Setup: Tailscale VPN, SSH config, cloud access${NC}\n"

# Step 1: Tailscale installation and connection
echo -e "${BOLD}[1/3] Tailscale VPN Setup...${NC}"
if ! command -v tailscale &> /dev/null; then
    echo -e "${YELLOW}Installing Tailscale...${NC}"
    brew install tailscale
fi

# Start Tailscale daemon if not running
if ! pgrep -x tailscaled > /dev/null; then
    echo -e "${YELLOW}Starting Tailscale daemon...${NC}"
    sudo tailscaled &
    sleep 2
fi

# Connect to Tailscale network
if tailscale ip -4 &>/dev/null; then
    IP=$(tailscale ip -4 | head -1)
    echo -e "${GREEN}✓ Tailscale connected ($IP)${NC}"
else
    echo -e "${YELLOW}⚠ Tailscale not yet authenticated${NC}"
    echo "Run: ${BLUE}tailscale up${NC}"
    echo "Then complete auth in browser and return here"
    read -p "Press Enter after connecting to Tailscale..."

    if ! tailscale ip -4 &>/dev/null; then
        echo -e "${RED}ERROR: Tailscale connection failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Tailscale connected${NC}"
fi

# Step 2: SSH configuration
echo -e "\n${BOLD}[2/3] SSH Configuration...${NC}"
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_DIR/config" ]; then
    cat > "$SSH_DIR/config" << 'EOF'
# shannonjlove.cloud infrastructure
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

# Check for SSH key
if [ ! -f "$SSH_DIR/id_rsa" ]; then
    echo -e "${YELLOW}⚠ No SSH key found${NC}"
    echo "Generate with: ${BLUE}ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa${NC}"
    read -p "Press Enter after generating SSH key..."
fi

# Step 3: Verify cloud connectivity
echo -e "\n${BOLD}[3/3] Cloud Connectivity Verification...${NC}"

echo -e "\nVerifying Nexus (primary container host)..."
if ping -c 1 100.115.66.75 >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Nexus reachable (100.115.66.75)"
else
    echo -e "  ${RED}✗${NC} Nexus not reachable"
fi

echo -e "\nVerifying sOs (compute node)..."
if ping -c 1 100.67.229.94 >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} sOs reachable (100.67.229.94)"
else
    echo -e "  ${RED}✗${NC} sOs not reachable"
fi

echo -e "\n${BOLD}Cloud Services:${NC}"
echo -e "  Memory Agent:     http://nexus:8100 (via SSH tunnel)"
echo -e "  Local Agent:      http://nexus:8101 (Ollama chat, via SSH tunnel)"
echo -e "  NPM Web UI:       https://npm.shannonjlove.cloud"
echo -e "  Memory Web UI:    https://memory.shannonjlove.cloud (Tailscale-only)"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 2 Complete: Cloud Connected${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}You are now a Frontend to shannonjlove.cloud:${NC}"
echo ""
echo "Access cloud services:"
echo "  • SSH:       ${BLUE}ssh nexus${NC} (Ubuntu, development)"
echo "  • SSH:       ${BLUE}ssh sos${NC} (Oracle ARM64)"
echo "  • WebTop:    ${BLUE}ssh webtop${NC} (Desktop in browser)"
echo "  • APIs:      Via Tailscale mesh (100.64.0.0/10)"
echo ""
echo "All work happens remotely:"
echo "  • Code:      SSH into Nexus and develop there"
echo "  • PARA:      Access via web UI or remote mount"
echo "  • Memory:    Web UI or MCP access via cloud"
echo "  • Compute:   Use Nexus or sOs resources"
echo ""
echo -e "${BOLD}Next:${NC}"
echo "1. Run Phase 3: ${BLUE}bash scripts/m1-frontend/phase-3-frontend.sh${NC}"
