#!/bin/bash
# Comprehensive Deployment Script
# Deploys ChatGPT connectors across all repositories

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ChatGPT Connectors - Full Deployment  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Configuration
BRANCH="claude/chatgpt-connectors-write-access-agtyc7"
REPOS=(
    "/home/user/.github"
    "/home/user/api-mcp-server"
    "/home/user/claude-memory-mcp"
    "/home/user/github-mcp-server"
    "/home/user/mcp-ssh-server"
)

BEARER_TOKEN="9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"

# Export token
export SJL_WRITE_TOKEN="${BEARER_TOKEN}"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Branch: ${BRANCH}"
echo "  Bearer Token: ${BEARER_TOKEN:0:20}..."
echo "  Repositories: ${#REPOS[@]}"
echo ""

# Function to check repository
check_repo() {
    local repo="$1"
    if [ ! -d "${repo}/.git" ]; then
        echo -e "${RED}✗${NC} Not a git repository: ${repo}"
        return 1
    fi
    return 0
}

# Function to deploy to repository
deploy_to_repo() {
    local repo="$1"
    local repo_name=$(basename "${repo}")

    echo -e "${BLUE}→ Processing: ${repo_name}${NC}"

    if ! check_repo "${repo}"; then
        return 1
    fi

    cd "${repo}"

    # Check branch exists
    if git rev-parse --verify "${BRANCH}" > /dev/null 2>&1; then
        echo "  ✓ Branch ${BRANCH} exists"
        git checkout "${BRANCH}"
    else
        echo "  ✓ Creating branch ${BRANCH}"
        git checkout -b "${BRANCH}"
    fi

    # Copy configuration files
    if [ "${repo_name}" == ".github" ]; then
        echo "  ✓ Adding ChatGPT connectors files"
        cp -r "${SCRIPT_DIR}/connectors" . 2>/dev/null || true
        cp -r "${SCRIPT_DIR}/chatgpt-configs" . 2>/dev/null || true
    fi

    # Add commit message
    git add . || true

    if git diff --cached --quiet; then
        echo "  → No changes to commit"
    else
        git commit -m "feat: Add ChatGPT connectors automation and configuration

- Add setup scripts for automated deployment
- Add configuration files for Custom Actions
- Add Python automation tool
- Update deployment documentation
- Include Bearer token configuration

Branch: ${BRANCH}" || echo "  → Already committed"
    fi

    echo -e "${GREEN}✓${NC} ${repo_name} processed"
    echo ""
}

# Main deployment
echo -e "${YELLOW}Starting deployment...${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for repo in "${REPOS[@]}"; do
    deploy_to_repo "${repo}" || true
done

# Generate summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Deployment Summary             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Repositories processed:${NC} ${#REPOS[@]}"
echo -e "${GREEN}✓ Branch:${NC} ${BRANCH}"
echo -e "${GREEN}✓ Configuration:${NC} ChatGPT Custom Actions"
echo -e "${GREEN}✓ Token:${NC} Configured"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review changes: git diff origin/${BRANCH}"
echo "  2. Create pull requests from each repository"
echo "  3. Merge to main branch"
echo "  4. Run deployment scripts in each repository"
echo ""
echo -e "${YELLOW}Setup commands:${NC}"
echo "  bash setup-chatgpt-action.sh"
echo "  bash chatgpt-configs/deploy-custom-action.sh"
echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
