# 1Password CLI Deployment Guide

This guide describes how to deploy MCP servers using the 1Password CLI for secure secret management.

## Overview

The deployment infrastructure consists of:
- **1Password CLI**: Command-line tool for secret management
- **Deploy Script** (`profile/deploy.sh`): Automated deployment orchestration
- **GitHub Actions Workflow** (`workflows/1password-deploy.yml`): CI/CD integration
- **Configuration** (`1password-config.json`): Centralized deployment configuration

## Prerequisites

### Local Development

1. **Install 1Password CLI**:
   ```bash
   # On Ubuntu/Debian
   curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo apt-key add -
   echo "deb https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
   sudo apt-get update
   sudo apt-get install -y 1password-cli
   
   # Verify installation
   op --version
   ```

2. **Authenticate with 1Password**:
   ```bash
   op account add
   ```

### GitHub Actions

For GitHub Actions workflows, you need:
- 1Password account with service account credentials
- GitHub repository secrets configured:
  - `OP_SERVICE_ACCOUNT_TOKEN`: 1Password service account token for CI/CD

## Configuration

### 1Password Setup

1. **Create a Vault** for MCP deployments:
   ```bash
   op vault create "MCP Deployment"
   ```

2. **Add Secrets** to the vault:
   ```bash
   # NPM credentials
   op item create \
     --vault "MCP Deployment" \
     --title "npm-credentials" \
     --category "api_credential" \
     token="your-npm-token"
   
   # GitHub credentials
   op item create \
     --vault "MCP Deployment" \
     --title "github-credentials" \
     --category "api_credential" \
     token="your-github-token"
   ```

3. **View Vault Contents**:
   ```bash
   op item list --vault "MCP Deployment"
   ```

### Local Environment

Create `.env.1password.template` in each MCP server directory:

```bash
# api-mcp-server/.env.1password.template
NPM_TOKEN=op://MCP Deployment/npm-credentials/token
GITHUB_TOKEN=op://MCP Deployment/github-credentials/token
REGISTRY_URL=https://registry.npmjs.org
```

## Usage

### Deployment Script

Run the deployment script from the project root:

```bash
# Check 1Password CLI and authentication
./.github/profile/deploy.sh check

# Sign into 1Password
./.github/profile/deploy.sh signin

# Deploy all MCP servers
./.github/profile/deploy.sh deploy all

# Deploy specific server
./.github/profile/deploy.sh deploy api-mcp-server
./.github/profile/deploy.sh deploy claude-memory-mcp
./.github/profile/deploy.sh deploy github-mcp-server
./.github/profile/deploy.sh deploy mcp-ssh-server

# List available vaults
./.github/profile/deploy.sh vaults

# List items in a vault
./.github/profile/deploy.sh list-items "MCP Deployment"
```

### GitHub Actions

Trigger deployment through the GitHub UI:

1. Go to **Actions** → **Deploy with 1Password Secrets**
2. Click **Run workflow**
3. Select:
   - **Server**: Which MCP server(s) to deploy
   - **Environment**: development, staging, or production
4. Click **Run workflow**

Or via GitHub CLI:

```bash
gh workflow run 1password-deploy.yml \
  -f server=api-mcp-server \
  -f environment=production
```

## Secret Management

### Adding New Secrets

1. **Create secret in 1Password**:
   ```bash
   op item create \
     --vault "MCP Deployment" \
     --title "new-secret" \
     --category "api_credential" \
     field_name="secret_value"
   ```

2. **Update environment template**:
   ```bash
   # Add to .env.1password.template
   NEW_VAR=op://MCP Deployment/new-secret/field_name
   ```

3. **Re-run deployment**:
   ```bash
   ./.github/profile/deploy.sh deploy <server>
   ```

### Secret Rotation

1. **Update secret in 1Password**:
   ```bash
   op item edit "secret-name" --vault "MCP Deployment" field_name="new_value"
   ```

2. **Verify update**:
   ```bash
   op item get "secret-name" --vault "MCP Deployment" --fields "field_name"
   ```

3. **Redeploy affected server**:
   ```bash
   ./.github/profile/deploy.sh deploy <server>
   ```

## Environments

The deployment configuration supports three environments:

### Development
- Vault: `MCP Deployment`
- Timeout: 5 minutes
- Approval: Not required

### Staging
- Vault: `Staging Secrets`
- Timeout: 10 minutes
- Approval: Not required

### Production
- Vault: `Production Secrets`
- Timeout: 15 minutes
- Approval: Required (manual approval in workflow)

## Troubleshooting

### Authentication Issues

```bash
# Check current authentication
op account get

# Re-authenticate
op account add

# Verify vault access
op vault list
```

### Secret Not Found

```bash
# List all items in vault
./.github/profile/deploy.sh list-items "MCP Deployment"

# Check specific secret
op item get "secret-name" --vault "MCP Deployment"

# Verify field name
op item get "secret-name" --vault "MCP Deployment" --fields all
```

### Deployment Logs

```bash
# View deployment logs
tail -f .deployment.log

# Search logs for errors
grep ERROR .deployment.log
```

### Service Account Token Issues (CI/CD)

```bash
# Generate new service account token in 1Password web interface
# Settings → Integrations → Service Accounts → Create Token

# Update GitHub repository secret
gh secret set OP_SERVICE_ACCOUNT_TOKEN --body "your-new-token"
```

## Security Best Practices

1. **Never commit secrets**:
   - Add `.env*` to `.gitignore`
   - Use 1Password references instead

2. **Rotate secrets regularly**:
   - Set reminders to update credentials
   - Track rotation in 1Password

3. **Limit vault access**:
   - Use role-based access control in 1Password
   - Grant minimum required permissions

4. **Audit deployments**:
   - Check GitHub Actions logs
   - Review 1Password activity logs
   - Monitor deployment records

5. **Use service accounts for CI/CD**:
   - Never use personal account tokens
   - Rotate service account tokens regularly
   - Limit service account permissions

## Advanced Configuration

### Custom Deployment Scripts

Extend the deployment script for custom logic:

```bash
# In .github/profile/deploy.sh, add custom function
custom_deploy() {
    local server="$1"
    log "Running custom deployment for $server"
    
    # Add custom deployment logic here
    # Access secrets via get_secret function
    # Example:
    # TOKEN=$(get_secret "MCP Deployment" "some-secret" "token")
}
```

### Multi-Vault Setup

For complex deployments, use multiple vaults:

```bash
# Development secrets
op vault create "Development Secrets"

# Staging secrets
op vault create "Staging Secrets"

# Production secrets (with stronger access controls)
op vault create "Production Secrets"
```

### Integration with CI/CD Pipelines

Connect with other CI/CD tools:

```bash
# GitHub Actions (documented above)
.github/workflows/1password-deploy.yml

# GitLab CI/CD
# Add .gitlab-ci.yml with 1password-cli integration

# Jenkins
# Add Jenkinsfile with 1password authentication
```

## Support and Resources

- 1Password CLI Documentation: https://developer.1password.com/docs/cli/
- 1Password GitHub Integration: https://developer.1password.com/docs/integrations/github-actions/
- MCP Repository: https://github.com/shannonjlove/

## Deployment Checklist

Before deploying to production:

- [ ] Verify all secrets are configured in 1Password
- [ ] Test deployment in development environment
- [ ] Check deployment logs for errors
- [ ] Verify deployed services are running
- [ ] Test service functionality
- [ ] Monitor error logs and metrics
- [ ] Document any configuration changes
- [ ] Notify team of deployment

## Version History

- **v1.0** (2024-07-10): Initial 1Password CLI deployment infrastructure
  - Basic deployment script
  - GitHub Actions workflow
  - Configuration templates
  - Documentation

---

Last Updated: 2024-07-10
