#!/bin/bash
# Verification Script
# Checks that all onboarding phases completed successfully

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}MacBook M1 Setup Verification${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

PASS=0
WARN=0
FAIL=0

# Helper functions
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

# Phase 1: System Baseline
echo -e "\n${BOLD}Phase 1: System Baseline${NC}"
[ "$(uname -m)" = "arm64" ] && check_pass "Apple Silicon M1" || check_fail "Not running on Apple Silicon"
command -v brew &>/dev/null && check_pass "Homebrew installed" || check_fail "Homebrew not installed"
command -v python3.11 &>/dev/null && check_pass "Python 3.11 installed" || check_fail "Python 3.11 not installed"
command -v node &>/dev/null && check_pass "Node.js installed" || check_fail "Node.js not installed"
command -v git &>/dev/null && check_pass "Git installed" || check_fail "Git not installed"

# Phase 2: PARA System
echo -e "\n${BOLD}Phase 2: PARA System${NC}"
[ -d "$HOME/PARA" ] && check_pass "PARA directory created" || check_fail "PARA directory missing"
[ -d "$HOME/PARA/.git" ] && check_pass "PARA git initialized" || check_fail "PARA not initialized with git"
[ -f "$HOME/PARA/README.md" ] && check_pass "PARA README created" || check_fail "PARA README missing"
[ -f "$HOME/PARA/0-SYSTEM/MANUAL-V8.md" ] && check_pass "Manual v8 created" || check_warn "Manual v8 missing"

# Phase 3: Claude Code
echo -e "\n${BOLD}Phase 3: Claude Code${NC}"
command -v claude &>/dev/null && check_pass "Claude CLI installed" || check_fail "Claude CLI not installed"
[ -d "$HOME/.claude" ] && check_pass "Claude config directory exists" || check_fail "Claude config missing"
[ -f "$HOME/.claude/settings.json" ] && check_pass "Claude settings configured" || check_warn "Claude settings not configured"
[ -d "$HOME/.claude-memory" ] && check_pass "Claude memory directory created" || check_warn "Claude memory directory missing"

# Phase 4: Local AI Stack
echo -e "\n${BOLD}Phase 4: Local AI Stack${NC}"
command -v ollama &>/dev/null && check_pass "Ollama installed" || check_fail "Ollama not installed"
curl -s http://localhost:11434/api/generate &>/dev/null && check_pass "Ollama running" || check_warn "Ollama not running (start with 'ollama serve')"
[ -f "$HOME/.local/lib/claude-memory/server.py" ] && check_pass "claude-memory server installed" || check_warn "claude-memory server not found"
[ -d "$HOME/projects/Hybrid-Personal-Cloud-Server-Infrastructure" ] && check_pass "Cloud repo cloned" || check_warn "Cloud repo not found"

# Phase 5: Cloud Connectivity
echo -e "\n${BOLD}Phase 5: Cloud Connectivity${NC}"
command -v tailscale &>/dev/null && check_pass "Tailscale installed" || check_fail "Tailscale not installed"

if tailscale ip -4 &>/dev/null; then
    IP=$(tailscale ip -4 | head -1)
    check_pass "Tailscale connected ($IP)"
else
    check_warn "Tailscale not connected (run 'tailscale up')"
fi

if ping -c 1 100.115.66.75 >/dev/null 2>&1; then
    check_pass "Nexus reachable via Tailscale"
else
    check_warn "Nexus not reachable (may be offline)"
fi

if mount | grep -q "/mnt/shared-context"; then
    check_pass "NFS mount active"
else
    check_warn "NFS not mounted (run 'sudo /tmp/mount-shared-context.sh')"
fi

[ -f "$HOME/.ssh/config" ] && grep -q "Host nexus" "$HOME/.ssh/config" && check_pass "SSH aliases configured" || check_warn "SSH aliases not configured"

# Summary
echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Verification Summary${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

TOTAL=$((PASS + WARN + FAIL))
echo -e "\n${BOLD}Results:${NC}"
echo -e "  ${GREEN}Passed${NC}: $PASS/$TOTAL"
if [ $WARN -gt 0 ]; then
    echo -e "  ${YELLOW}Warnings${NC}: $WARN/$TOTAL"
fi
if [ $FAIL -gt 0 ]; then
    echo -e "  ${RED}Failed${NC}: $FAIL/$TOTAL"
fi

echo ""
if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ Setup Complete!${NC}"
    echo ""
    echo "Your MacBook M1 is ready for Claude Code development."
    echo ""
    echo -e "${BOLD}Quick Start:${NC}"
    echo "  1. Start services: ${BLUE}ollama serve &${NC}"
    echo "  2. Connect cloud: ${BLUE}tailscale up${NC}"
    echo "  3. Mount NFS: ${BLUE}sudo /tmp/mount-shared-context.sh${NC}"
    echo "  4. Open Claude Code: ${BLUE}cd ~/PARA/1-PROJECTS && claude${NC}"
else
    echo -e "${RED}${BOLD}⚠ Setup Incomplete${NC}"
    echo ""
    echo "Please review the failed items above and re-run affected phases."
fi

echo ""
