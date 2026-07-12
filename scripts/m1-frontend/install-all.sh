#!/bin/bash
# Frontend MacBook M1 - Complete Setup (Orchestration)
# Pure thin client for shannonjlove.cloud
# NO local development, NO S3 storage, NO stateful data

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_TIME=$(date +%s)

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
}

print_phase() {
    echo -e "\n${BOLD}>>> $1${NC}"
}

# Main
print_header "MacBook M1 Frontend Setup (Pure Thin Client)"
echo "Architecture: Frontend access layer for shannonjlove.cloud"
echo "Storage: None (stateless)"
echo "Tools: SSH, CLI only (no local dev)"
echo "Infrastructure: Nexus (100.115.66.75), sOs (100.67.229.94)"
echo ""
echo "Phases (Phases 2-3 require manual steps):"
echo "  1. System minimal (Homebrew, Git, Tailscale only)"
echo "  2. Cloud connectivity (VPN, SSH config, cloud access)"
echo "  3. Frontend tools (Claude CLI, local config only)"
echo ""
echo "Total time: ~15 minutes"
echo ""
read -p "Press Enter to begin, or Ctrl+C to cancel..."

# Phase 1
print_phase "Phase 1: Minimal System"
if bash "$SCRIPT_DIR/phase-1-minimal.sh"; then
    echo -e "${GREEN}✓ Phase 1 Complete${NC}"
    source "$HOME/.zshrc" 2>/dev/null || true
else
    echo -e "${RED}✗ Phase 1 Failed${NC}"
    exit 1
fi

# Phase 2
print_phase "Phase 2: Cloud Connectivity"
if bash "$SCRIPT_DIR/phase-2-cloud.sh"; then
    echo -e "${GREEN}✓ Phase 2 Complete${NC}"
else
    echo -e "${YELLOW}⚠ Phase 2 had issues (check Tailscale and SSH)${NC}"
fi

# Phase 3
print_phase "Phase 3: Frontend Tools"
if bash "$SCRIPT_DIR/phase-3-frontend.sh"; then
    echo -e "${GREEN}✓ Phase 3 Complete${NC}"
else
    echo -e "${YELLOW}⚠ Phase 3 had issues (check Claude CLI installation)${NC}"
fi

# Verification
print_phase "Final Verification"
bash "$SCRIPT_DIR/verify-setup.sh"

# Summary
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

print_header "✓ Frontend MacBook M1 Ready"
echo "Elapsed Time: ${MINUTES}m ${SECONDS}s"
echo ""
echo -e "${BOLD}Architecture Summary:${NC}"
echo "  Laptop Type:        Frontend/Thin Client (NO local dev or storage)"
echo "  Local Storage:      ~/.claude/, ~/.ssh/ (config only)"
echo "  Remote Access:      SSH to Nexus/sOs via Tailscale"
echo "  Cloud VPN:          Tailscale mesh to shannonjlove.cloud"
echo "  Development:        All work on Nexus or sOs (ssh nexus)"
echo "  PARA/Projects:      Access via web UI or remote SSH"
echo "  Backup Strategy:    Laptop is 100% stateless and replaceable"
echo ""
echo -e "${BOLD}How to Work:${NC}"
echo "  1. SSH into Nexus:  ${BLUE}ssh nexus${NC}"
echo "  2. Develop there:   ${BLUE}cd ~/projects && git clone ...${NC}"
echo "  3. Use Claude Code: Connected to cloud MCP servers"
echo "  4. No local code:   Everything stored on Nexus in S3"
echo ""
echo -e "${BOLD}Access Cloud:${NC}"
echo "  • Development:      ${BLUE}ssh nexus${NC} or ${BLUE}ssh sos${NC}"
echo "  • Desktop:          ${BLUE}ssh webtop${NC} (remote X11 desktop)"
echo "  • Web Services:     https://npm.shannonjlove.cloud"
echo "  • Memory API:       https://memory.shannonjlove.cloud (Tailscale)"
echo ""
echo -e "${BOLD}If MacBook Breaks:${NC}"
echo "  1. Get new MacBook"
echo "  2. Run setup (Phases 1-3, ~15 minutes)"
echo "  3. Restore SSH keys from password manager"
echo "  4. All work/data automatically on Nexus/sOs (S3-backed)"
echo ""
echo -e "${GREEN}${BOLD}You're all set! Your MacBook is a frontend to the cloud.${NC}"
