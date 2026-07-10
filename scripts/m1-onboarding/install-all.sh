#!/bin/bash
# Complete M1 Onboarding - All Phases
# Runs all setup phases sequentially with error handling
# Safe to re-run - each phase is idempotent

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_TIME=$(date +%s)

# Colors for sections
print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${BOLD}>>> $1${NC}"
}

# Main installation flow
print_header "MacBook M1 Complete Onboarding"
echo "This script will run all 5 phases sequentially."
echo "Each phase is safe to re-run and will skip already-completed steps."
echo ""
echo -e "${YELLOW}Note: You may be prompted for your sudo password.${NC}"
echo ""
read -p "Press Enter to begin, or Ctrl+C to cancel..."

# Phase 1: System Baseline
print_section "Phase 1: System Baseline (2-3 hours expected)"
if bash "$SCRIPT_DIR/phase-1-system.sh"; then
    echo -e "${GREEN}✓ Phase 1 Complete${NC}"
else
    echo -e "${RED}✗ Phase 1 Failed${NC}"
    exit 1
fi

# Reload shell for environment updates
source "$HOME/.zshrc" 2>/dev/null || true

# Phase 2: PARA System
print_section "Phase 2: PARA System Setup (1-2 hours expected)"
if bash "$SCRIPT_DIR/phase-2-para.sh"; then
    echo -e "${GREEN}✓ Phase 2 Complete${NC}"
else
    echo -e "${RED}✗ Phase 2 Failed${NC}"
    exit 1
fi

# Phase 3: Claude Code
print_section "Phase 3: Claude Code Installation (1-2 hours expected)"
if bash "$SCRIPT_DIR/phase-3-claude.sh"; then
    echo -e "${GREEN}✓ Phase 3 Complete${NC}"
else
    echo -e "${RED}✗ Phase 3 Failed${NC}"
    exit 1
fi

# Phase 4: Local AI Stack
print_section "Phase 4: Local AI Stack (2-3 hours expected - Ollama download is large)"
if bash "$SCRIPT_DIR/phase-4-ai-stack.sh"; then
    echo -e "${GREEN}✓ Phase 4 Complete${NC}"
else
    echo -e "${RED}✗ Phase 4 Failed (some components may still be usable)${NC}"
    # Don't exit here - cloud setup can still work
fi

# Phase 5: Cloud Connectivity
print_section "Phase 5: Cloud Infrastructure Connectivity (1-2 hours expected)"
if bash "$SCRIPT_DIR/phase-5-cloud.sh"; then
    echo -e "${GREEN}✓ Phase 5 Complete${NC}"
else
    echo -e "${RED}✗ Phase 5 Failed (cloud features will be unavailable)${NC}"
    # Don't exit - setup is still mostly complete
fi

# Final verification
print_section "Verification"
bash "$SCRIPT_DIR/verify-setup.sh"

# Calculate elapsed time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

print_header "Installation Complete!"
echo -e "${BOLD}Elapsed Time:${NC} ${MINUTES}m ${SECONDS}s"
echo ""
echo -e "${BOLD}Summary:${NC}"
echo "  • System baseline: Ready"
echo "  • PARA system: ~/PARA/"
echo "  • Claude Code: Installed and configured"
echo "  • Local AI stack: Ollama, memory services ready"
echo "  • Cloud connectivity: Tailscale and NFS configured"
echo ""
echo -e "${BOLD}Quick Start Commands:${NC}"
echo "  1. Start Ollama: ${BLUE}ollama serve &${NC}"
echo "  2. Connect Tailscale: ${BLUE}tailscale up${NC}"
echo "  3. Mount cloud storage: ${BLUE}sudo /tmp/mount-shared-context.sh${NC}"
echo "  4. Start development: ${BLUE}cd ~/PARA/1-PROJECTS && claude${NC}"
echo ""
echo -e "${BOLD}Documentation:${NC}"
echo "  • Setup guide: ${BLUE}docs/M1_ONBOARDING.md${NC}"
echo "  • PARA manual: ${BLUE}~/PARA/0-SYSTEM/MANUAL-V8.md${NC}"
echo "  • Troubleshooting: ${BLUE}docs/M1_TROUBLESHOOTING.md${NC}"
echo ""
echo -e "${GREEN}${BOLD}You're all set! Welcome to your new MacBook M1 development environment.${NC}"
