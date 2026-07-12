#!/bin/bash
# Verification Script for Frontend MacBook M1
# Check: Tailscale, SSH, Cloud access, Claude CLI

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Frontend MacBook M1 Verification${NC}"
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
echo -e "\n${BOLD}Phase 1: Minimal System${NC}"
[ "$(uname -m)" = "arm64" ] && check_pass "Apple Silicon M1" || check_fail "Not on Apple Silicon"
command -v brew &>/dev/null && check_pass "Homebrew" || check_fail "Homebrew"
command -v git &>/dev/null && check_pass "Git" || check_fail "Git"
command -v curl &>/dev/null && check_pass "curl" || check_fail "curl"

# Phase 2: Cloud connectivity
echo -e "\n${BOLD}Phase 2: Cloud Connectivity${NC}"
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
    check_warn "Nexus not reachable"
fi

if ping -c 1 100.67.229.94 >/dev/null 2>&1; then
    check_pass "sOs reachable"
else
    check_warn "sOs not reachable"
fi

# Phase 3: Frontend tools
echo -e "\n${BOLD}Phase 3: Frontend Tools${NC}"
command -v claude &>/dev/null && check_pass "Claude CLI" || check_fail "Claude CLI"
[ -d "$HOME/.claude" ] && check_pass ".claude directory" || check_warn ".claude missing"
[ -f "$HOME/.ssh/config" ] && check_pass "SSH config" || check_warn "SSH config missing"
[ -f "$HOME/.ssh/id_rsa" ] && check_pass "SSH key" || check_warn "SSH key missing"
command -v git &>/dev/null && [ -f "$HOME/.gitconfig" ] && check_pass "Git config" || check_warn "Git config missing"

# Verify NO local dev tools
echo -e "\n${BOLD}Verify Frontend-Only (No Local Dev):${NC}"
! command -v python3 &>/dev/null && check_pass "No Python (use remote SSH)" || check_warn "Python found (use remote)"
! command -v node &>/dev/null && check_pass "No Node (use remote SSH)" || check_warn "Node found (use remote)"
! command -v rclone &>/dev/null && check_pass "No rclone (use web UI)" || check_warn "rclone found (use web UI)"

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
        echo -e "${GREEN}${BOLD}✓ Perfect! Frontend MacBook M1 fully configured${NC}"
        echo ""
        echo "Your MacBook is:"
        echo "  ✅ Pure Frontend to shannonjlove.cloud"
        echo "  ✅ No local development tools"
        echo "  ✅ No local storage (stateless)"
        echo "  ✅ Connected to Nexus/sOs via Tailscale"
        echo "  ✅ Ready for SSH and web access"
    else
        echo -e "${YELLOW}${BOLD}⚠ Setup mostly complete, some items need attention${NC}"
        echo ""
        [ ! -f "$HOME/.ssh/id_rsa" ] && echo "  Generate SSH key: ${BLUE}ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa${NC}"
        ! tailscale ip -4 &>/dev/null && echo "  Connect Tailscale: ${BLUE}tailscale up${NC}"
    fi
else
    echo -e "${RED}${BOLD}✗ Setup incomplete${NC}"
    echo ""
    echo "Fix failures above, then re-run:"
    echo "  ${BLUE}bash scripts/m1-frontend/verify-setup.sh${NC}"
fi

echo ""
echo -e "${BOLD}Access Cloud Services:${NC}"
echo "  SSH:       ${BLUE}ssh nexus${NC} (development host)"
echo "  SSH:       ${BLUE}ssh sos${NC} (compute node)"
echo "  Web:       https://npm.shannonjlove.cloud (public)"
echo "  Web:       https://memory.shannonjlove.cloud (Tailscale-only)"
echo ""
echo -e "${BOLD}Disaster Recovery:${NC}"
echo "  If MacBook fails, you've lost nothing:"
echo "  1. Get new MacBook"
echo "  2. Run setup (Phases 1-3)"
echo "  3. Restore SSH keys from password manager"
echo "  4. All work/data lives on Nexus/sOs"
echo ""
