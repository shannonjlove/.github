#!/bin/bash
################################################################################
# Phase 2 Validation - Testing and Verification
# Purpose: Validate Phase 2 deployment and API connectivity
# Date: July 5, 2026
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESULTS_FILE="phase2-validation-results-$(date +%Y%m%d-%H%M%S).txt"
PASSED=0
FAILED=0

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}" | tee -a "$RESULTS_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$RESULTS_FILE"
    echo -e "${BLUE}========================================${NC}" | tee -a "$RESULTS_FILE"
}

print_test() {
    echo -e "${BLUE}▶ $1${NC}" | tee -a "$RESULTS_FILE"
}

print_pass() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$RESULTS_FILE"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$RESULTS_FILE"
    ((FAILED++))
}

print_skip() {
    echo -e "${YELLOW}⊘ $1${NC}" | tee -a "$RESULTS_FILE"
}

print_section() {
    echo "" | tee -a "$RESULTS_FILE"
    echo -e "${BLUE}─────────────────────────────────────${NC}" | tee -a "$RESULTS_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$RESULTS_FILE"
    echo -e "${BLUE}─────────────────────────────────────${NC}" | tee -a "$RESULTS_FILE"
}

check_command() {
    local cmd=$1
    local name=$2

    print_test "Checking for $name..."
    if command -v "$cmd" &>/dev/null; then
        local version=$("$cmd" --version 2>&1 | head -1)
        print_pass "Found: $name - $version"
        return 0
    else
        print_fail "Not found: $name"
        return 1
    fi
}

test_api_connectivity() {
    local api_name=$1
    local test_cmd=$2
    local description=$3

    print_test "$description"

    if eval "$test_cmd" &>/dev/null; then
        print_pass "$api_name API connectivity verified"
        return 0
    else
        print_fail "$api_name API connectivity failed"
        return 1
    fi
}

################################################################################
# Validation Tests
################################################################################

validate_installations() {
    print_section "INSTALLATION VALIDATION"

    check_command "go" "Go"
    check_command "anthropic" "Anthropic CLI"
    check_command "op" "1Password CLI"
}

validate_go() {
    print_section "GO LANGUAGE VALIDATION"

    print_test "Go version check..."
    local go_version=$(go version)
    echo "  $go_version" | tee -a "$RESULTS_FILE"

    if echo "$go_version" | grep -q "go1.26.4"; then
        print_pass "Go 1.26.4 verified"
    else
        print_fail "Expected Go 1.26.4 but got: $go_version"
    fi

    print_test "GOROOT check..."
    local goroot="${GOROOT:-}"
    if [ -n "$goroot" ]; then
        print_pass "GOROOT set: $goroot"
    else
        print_fail "GOROOT not set"
    fi

    print_test "GOPATH check..."
    local gopath="${GOPATH:-}"
    if [ -n "$gopath" ]; then
        print_pass "GOPATH set: $gopath"
    else
        print_fail "GOPATH not set"
    fi

    print_test "Go environment..."
    go env | head -5 | tee -a "$RESULTS_FILE"
}

validate_anthropic_cli() {
    print_section "ANTHROPIC CLI VALIDATION"

    print_test "Anthropic CLI version check..."
    if anthropic --version &>/dev/null; then
        local version=$(anthropic --version)
        echo "  $version" | tee -a "$RESULTS_FILE"
        print_pass "Anthropic CLI version: $version"
    else
        print_fail "Anthropic CLI version check failed"
        return 1
    fi

    print_test "Anthropic CLI help check..."
    if anthropic --help &>/dev/null; then
        print_pass "Anthropic CLI help available"
    else
        print_fail "Anthropic CLI help failed"
    fi
}

validate_1password_cli() {
    print_section "1PASSWORD CLI VALIDATION"

    print_test "1Password CLI version check..."
    if op --version &>/dev/null; then
        local version=$(op --version)
        echo "  $version" | tee -a "$RESULTS_FILE"
        print_pass "1Password CLI version: $version"
    else
        print_fail "1Password CLI version check failed"
        return 1
    fi

    print_test "1Password CLI help check..."
    if op --help &>/dev/null; then
        print_pass "1Password CLI help available"
    else
        print_fail "1Password CLI help failed"
    fi

    print_test "1Password authentication status..."
    if op whoami &>/dev/null; then
        local user=$(op whoami)
        echo "  Signed in as: $user" | tee -a "$RESULTS_FILE"
        print_pass "1Password signed in: $user"
    else
        print_skip "1Password not signed in (requires: op signin)"
    fi
}

validate_api_connectivity() {
    print_section "API CONNECTIVITY VALIDATION"

    print_test "Anthropic API - List models..."
    if anthropic models list &>/dev/null; then
        local count=$(anthropic models list 2>/dev/null | wc -l)
        print_pass "Anthropic API available ($count models)"
    else
        print_fail "Anthropic API connectivity failed"
        print_skip "Try setting: export ANTHROPIC_API_KEY=<your-key>"
    fi

    print_test "Anthropic API - Simple message..."
    if timeout 10 anthropic message --model claude-3-5-sonnet "test" &>/dev/null; then
        print_pass "Anthropic API message test passed"
    else
        print_fail "Anthropic API message test failed"
    fi
}

validate_environment_variables() {
    print_section "ENVIRONMENT VARIABLES VALIDATION"

    print_test "PATH contains Go binaries..."
    if echo "$PATH" | grep -q "go/bin\|/usr/local/go"; then
        print_pass "PATH includes Go binaries"
    else
        print_fail "PATH does not include Go binaries"
    fi

    print_test "ANTHROPIC_API_KEY check..."
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        local key_preview=$(echo "$ANTHROPIC_API_KEY" | head -c 20)
        echo "  Key preview: $key_preview..." | tee -a "$RESULTS_FILE"
        print_pass "ANTHROPIC_API_KEY is set"
    else
        print_skip "ANTHROPIC_API_KEY not set (required for API access)"
    fi

    print_test "Load 1Password function check..."
    if type load-1password-env &>/dev/null; then
        print_pass "load-1password-env function available"
    else
        print_skip "load-1password-env function not found"
    fi
}

validate_shell_configuration() {
    print_section "SHELL CONFIGURATION VALIDATION"

    local shell_profile="${HOME}/.bashrc"
    [ "$(id -u)" = "0" ] && shell_profile="/root/.bashrc"

    print_test "Shell profile check: $shell_profile..."
    if [ -f "$shell_profile" ]; then
        print_pass "Shell profile exists"

        print_test "Checking for Go configuration..."
        if grep -q "export.*GOROOT\|export.*GOPATH" "$shell_profile"; then
            print_pass "Go configuration found in shell profile"
        else
            print_fail "Go configuration not found in shell profile"
        fi

        print_test "Checking for Anthropic CLI configuration..."
        if grep -q "export PATH.*usr/local/bin\|ANTHROPIC" "$shell_profile"; then
            print_pass "Anthropic CLI configuration found in shell profile"
        else
            print_fail "Anthropic CLI configuration not found in shell profile"
        fi

        print_test "Checking for 1Password helpers..."
        if grep -q "load-1password-env" "$shell_profile"; then
            print_pass "1Password helpers found in shell profile"
        else
            print_fail "1Password helpers not found in shell profile"
        fi
    else
        print_fail "Shell profile not found: $shell_profile"
    fi
}

validate_para_system() {
    print_section "PARA SYSTEM VALIDATION"

    print_test "Para system location check..."
    if [ -d "/home/user/.github/infrastructure/event-logging" ]; then
        print_pass "Para system directory found"

        print_test "Para system Python module check..."
        if [ -f "/home/user/.github/infrastructure/event-logging/para_system.py" ]; then
            print_pass "para_system.py found"

            print_test "Para system storage check..."
            if [ -d "/var/lib/para-codes" ]; then
                print_pass "Para code storage directory found"
                local count=$([ -f "/var/lib/para-codes/generated-codes.json" ] && \
                    grep -o '"code"' "/var/lib/para-codes/generated-codes.json" 2>/dev/null | wc -l || echo "0")
                echo "  Codes stored: $count" | tee -a "$RESULTS_FILE"
            else
                print_fail "Para code storage directory not found"
            fi
        else
            print_fail "para_system.py not found"
        fi
    else
        print_fail "Para system directory not found"
    fi
}

test_para_code_generation() {
    print_section "PARA CODE GENERATION TEST"

    print_test "Generate test para code via Anthropic CLI..."

    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        print_skip "ANTHROPIC_API_KEY not set, skipping para code generation test"
        return
    fi

    local response=$(timeout 15 anthropic message --model claude-3-5-sonnet \
        "Generate ONLY a YYMMDD-XXXX format para code for: test invoice dated $(date +%y%m%d). Return just the code." 2>/dev/null || echo "")

    if [ -n "$response" ]; then
        echo "  Generated: $response" | tee -a "$RESULTS_FILE"
        print_pass "Para code generation successful"
    else
        print_fail "Para code generation failed"
    fi
}

################################################################################
# Summary Report
################################################################################

generate_summary() {
    print_section "VALIDATION SUMMARY"

    local total=$((PASSED + FAILED))
    local percentage=$((PASSED * 100 / total))

    echo "" | tee -a "$RESULTS_FILE"
    echo "Total Tests: $total" | tee -a "$RESULTS_FILE"
    echo "Passed: $PASSED" | tee -a "$RESULTS_FILE"
    echo "Failed: $FAILED" | tee -a "$RESULTS_FILE"
    echo "Success Rate: ${percentage}%" | tee -a "$RESULTS_FILE"
    echo "" | tee -a "$RESULTS_FILE"

    if [ "$FAILED" -eq 0 ]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}" | tee -a "$RESULTS_FILE"
        echo "Phase 2 deployment is complete and operational." | tee -a "$RESULTS_FILE"
    else
        echo -e "${YELLOW}⚠ SOME TESTS FAILED${NC}" | tee -a "$RESULTS_FILE"
        echo "Please review failures and take corrective action." | tee -a "$RESULTS_FILE"
    fi

    echo "" | tee -a "$RESULTS_FILE"
    echo "Full results saved to: $RESULTS_FILE" | tee -a "$RESULTS_FILE"
}

################################################################################
# Main Validation
################################################################################

main() {
    print_header "PHASE 2 VALIDATION & TESTING"

    echo "Started: $(date)" | tee "$RESULTS_FILE"
    echo "Host: $(hostname)" | tee -a "$RESULTS_FILE"
    echo "User: $(whoami)" | tee -a "$RESULTS_FILE"
    echo "Architecture: $(uname -m)" | tee -a "$RESULTS_FILE"
    echo "" | tee -a "$RESULTS_FILE"

    validate_installations
    validate_go
    validate_anthropic_cli
    validate_1password_cli
    validate_environment_variables
    validate_shell_configuration
    validate_api_connectivity
    validate_para_system
    test_para_code_generation

    generate_summary

    echo "" | tee -a "$RESULTS_FILE"
    echo "Completed: $(date)" | tee -a "$RESULTS_FILE"
}

################################################################################
# Entry Point
################################################################################

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat << EOF
Usage: $0 [OPTIONS]

Phase 2 Validation and Testing Script

OPTIONS:
  -h, --help              Show this help message
  --quick                 Run quick validation only
  --full                  Run full validation and tests
  --api-only              Test API connectivity only

EXAMPLES:
  # Full validation
  bash $0

  # Quick check
  bash $0 --quick

  # Test APIs only
  bash $0 --api-only

ENVIRONMENT VARIABLES:
  ANTHROPIC_API_KEY       Required for API connectivity tests

EOF
    exit 0
fi

if [ "${1:-}" = "--quick" ]; then
    validate_installations
    validate_environment_variables
elif [ "${1:-}" = "--api-only" ]; then
    validate_anthropic_cli
    validate_api_connectivity
else
    main "$@"
fi

echo ""
echo "Results: $RESULTS_FILE"
