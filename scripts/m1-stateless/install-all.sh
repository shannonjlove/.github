#!/bin/bash
# Stateless Laptop Node - Complete Setup
# MacBook M1 as a thin client for shannonjlove.cloud
# All storage on idrive e2 S3, local config only

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
print_header "MacBook M1 Stateless Laptop Node Setup"
echo "Architecture: Thin client for shannonjlove.cloud"
echo "Storage: idrive e2 S3 (mounted via rclone)"
echo "Local: Configuration only (.claude, .ssh, .aws)"
echo ""
echo "Phases (Phases 2-3 require manual steps):"
echo "  1. System baseline (Homebrew, Python, Node)"
echo "  2. S3 mounting (rclone + idrive e2)"
echo "  3. Local config (Claude, SSH, AWS credentials)"
echo "  4. Cloud connectivity (Tailscale, verification)"
echo ""
echo "Total time: ~3-4 hours (mostly waiting for S3 mounts)"
echo ""
read -p "Press Enter to begin, or Ctrl+C to cancel..."

# Phase 1
print_phase "Phase 1: System Baseline"
if bash "$SCRIPT_DIR/phase-1-system.sh"; then
    echo -e "${GREEN}✓ Phase 1 Complete${NC}"
    source "$HOME/.zshrc" 2>/dev/null || true
else
    echo -e "${RED}✗ Phase 1 Failed${NC}"
    exit 1
fi

# Phase 2
print_phase "Phase 2: S3 Mounting"
if bash "$SCRIPT_DIR/phase-2-s3-mount.sh"; then
    echo -e "${GREEN}✓ Phase 2 Complete${NC}"
else
    echo -e "${YELLOW}⚠ Phase 2 had issues (may need manual rclone config)${NC}"
fi

# Phase 3
print_phase "Phase 3: Local Configuration"
if bash "$SCRIPT_DIR/phase-3-config.sh"; then
    echo -e "${GREEN}✓ Phase 3 Complete${NC}"
else
    echo -e "${YELLOW}⚠ Phase 3 had issues (setup partial credentials manually)${NC}"
fi

# Phase 4
print_phase "Phase 4: Cloud Connectivity"
if bash "$SCRIPT_DIR/phase-4-cloud.sh"; then
    echo -e "${GREEN}✓ Phase 4 Complete${NC}"
else
    echo -e "${YELLOW}⚠ Phase 4 complete (may need to connect Tailscale manually)${NC}"
fi

# Verification
print_phase "Final Verification"
bash "$SCRIPT_DIR/verify-setup.sh"

# Summary
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

print_header "✓ Stateless Laptop Node Ready"
echo "Elapsed Time: ${MINUTES}m ${SECONDS}s"
echo ""
echo -e "${BOLD}Architecture Summary:${NC}"
echo "  Local Storage:      ~/.claude/, ~/.ssh/, ~/.aws/ (configuration only)"
echo "  Remote Storage:     idrive e2 S3 via rclone mounts"
echo "  Cloud Integration:  Tailscale VPN + shannonjlove.cloud"
echo "  Backup Strategy:    All data lives in S3, laptop is stateless"
echo ""
echo -e "${BOLD}Mount Points:${NC}"
echo "  ~/PARA/             → idrive e2 S3 (PARA system)"
echo "  ~/projects/         → idrive e2 S3 (code repositories)"
echo "  ~/.claude-memory/   → idrive e2 S3 (conversation history)"
echo ""
echo -e "${BOLD}Quick Start:${NC}"
echo "  • Check mounts:     ${BLUE}mount | grep rclone${NC}"
echo "  • Verify setup:     ${BLUE}bash scripts/m1-stateless/verify-setup.sh${NC}"
echo "  • Start coding:     ${BLUE}cd ~/projects && git clone ...${NC}"
echo "  • View memories:    ${BLUE}cd ~/.claude-memory && ls${NC}"
echo ""
echo -e "${BOLD}If MacBook Breaks:${NC}"
echo "  1. Get new MacBook"
echo "  2. Run setup (all phases again)"
echo "  3. Restore SSH keys from password manager"
echo "  4. Restore AWS credentials from password manager"
echo "  5. All other data automatically restored from S3"
echo ""
echo -e "${GREEN}${BOLD}You're all set! Welcome to your stateless laptop node.${NC}"
