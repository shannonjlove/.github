#!/bin/bash
# Verification Script for Stateless Laptop Node

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Stateless Laptop Node Verification${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

PASS=0
WARN=0
FAIL=0

check_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASS++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARN++))
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((FAIL++))
}

# Phase 1: System
echo -e "\n${BOLD}Phase 1: System Baseline${NC}"
[ "$(uname -m)" = "arm64" ] && check_pass "Apple Silicon M1" || check_fail "Not on Apple Silicon"
command -v brew &>/dev/null && check_pass "Homebrew" || check_fail "Homebrew"
command -v python3.11 &>/dev/null && check_pass "Python 3.11" || check_fail "Python 3.11"
command -v node &>/dev/null && check_pass "Node.js" || check_fail "Node.js"
command -v git &>/dev/null && check_pass "Git" || check_fail "Git"

# Phase 2: S3 Mounts
echo -e "\n${BOLD}Phase 2: S3 Storage Mounts${NC}"
mount | grep -q "$HOME/PARA" && check_pass "PARA mounted" || check_warn "PARA not mounted"
mount | grep -q "$HOME/projects" && check_pass "projects mounted" || check_warn "projects not mounted"
mount | grep -q "$HOME/.claude-memory" && check_pass "memories mounted" || check_warn "memories not mounted"
command -v rclone &>/dev/null && check_pass "rclone installed" || check_fail "rclone"

# Phase 3: Local Configuration
echo -e "\n${BOLD}Phase 3: Local Configuration${NC}"
[ -d "$HOME/.claude" ] && check_pass ".claude directory" || check_warn ".claude missing"
[ -d "$HOME/.ssh" ] && check_pass ".ssh directory" || check_warn ".ssh missing"
[ -f "$HOME/.ssh/config" ] && check_pass "SSH config" || check_warn "SSH config missing"
[ -d "$HOME/.aws" ] && check_pass ".aws directory" || check_warn ".aws missing"
command -v claude &>/dev/null && check_pass "Claude CLI" || check_fail "Claude CLI"

# Phase 4: Cloud Connectivity
echo -e "\n${BOLD}Phase 4: Cloud Connectivity${NC}"
command -v tailscale &>/dev/null && check_pass "Tailscale installed" || check_fail "Tailscale"

if tailscale ip -4 &>/dev/null; then
    IP=$(tailscale ip -4 | head -1)
    check_pass "Tailscale connected ($IP)"
else
    check_warn "Tailscale not connected"
fi

if ping -c 1 100.115.66.75 >/dev/null 2>&1; then
    check_pass "Nexus reachable"
else
    check_warn "Nexus not reachable (may be offline)"
fi

# Storage Summary
echo -e "\n${BOLD}Storage Configuration:${NC}"
echo -e "  ${BLUE}Local (Non-Sync):${NC}"
echo "    ~/.claude/          - Claude Code settings"
echo "    ~/.ssh/             - SSH keys & config"
echo "    ~/.aws/credentials  - S3 credentials"
echo ""
echo -e "  ${BLUE}Remote (S3-Backed):${NC}"
mount | grep -q "$HOME/PARA" && echo "    ~/PARA/             ← idrive e2 S3" || echo "    ~/PARA/             (not mounted)"
mount | grep -q "$HOME/projects" && echo "    ~/projects/         ← idrive e2 S3" || echo "    ~/projects/         (not mounted)"
mount | grep -q "$HOME/.claude-memory" && echo "    ~/.claude-memory/   ← idrive e2 S3" || echo "    ~/.claude-memory/   (not mounted)"

# Summary
echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Verification Summary${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

TOTAL=$((PASS + WARN + FAIL))
echo ""
echo "  ${GREEN}Passed${NC}: $PASS/$TOTAL"
if [ $WARN -gt 0 ]; then
    echo "  ${YELLOW}Warnings${NC}: $WARN/$TOTAL"
fi
if [ $FAIL -gt 0 ]; then
    echo "  ${RED}Failed${NC}: $FAIL/$TOTAL"
fi

echo ""
if [ $FAIL -eq 0 ]; then
    if [ $WARN -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✓ Perfect! Stateless laptop node fully configured${NC}"
        echo ""
        echo "Your MacBook M1 is:"
        echo "  ✅ Stateless (all data on S3)"
        echo "  ✅ Cloud-integrated (Tailscale + shannonjlove.cloud)"
        echo "  ✅ Fully replaceable (restore from S3 + config files)"
        echo "  ✅ Production-ready"
    else
        echo -e "${YELLOW}${BOLD}⚠ Setup mostly complete, some mounts need attention${NC}"
        echo ""
        echo "To fix mounted storage:"
        echo "  ${BLUE}bash scripts/m1-stateless/phase-2-s3-mount.sh${NC}"
    fi
else
    echo -e "${RED}${BOLD}✗ Setup incomplete${NC}"
    echo ""
    echo "Re-run failed phases:"
    [ ! -f "$HOME/.ssh/config" ] && echo "  Phase 3: ${BLUE}bash scripts/m1-stateless/phase-3-config.sh${NC}"
    ! command -v tailscale &>/dev/null && echo "  Phase 1: ${BLUE}bash scripts/m1-stateless/phase-1-system.sh${NC}"
fi

echo ""
