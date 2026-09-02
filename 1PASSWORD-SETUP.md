# 1Password CLI Setup Guide for Secrets Management

Complete guide for setting up 1Password CLI for secure secret and environment variable management across MCP repositories.

## Table of Contents

1. [Installation](#installation)
2. [Authentication](#authentication)
3. [Vault Setup](#vault-setup)
4. [Secret Management](#secret-management)
5. [Environment Variable Configuration](#environment-variable-configuration)
6. [Usage Examples](#usage-examples)
7. [GitHub Actions Integration](#github-actions-integration)
8. [Security Best Practices](#security-best-practices)
9. [Troubleshooting](#troubleshooting)

## Installation

### Verify Installation

```bash
# Check 1Password CLI version
op --version

# Should display: 2.34.1 (or latest version)
```

The 1Password CLI is already installed at `/usr/bin/op`.

### Install on Other Machines

#### Ubuntu/Debian

```bash
# Add 1Password repository
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo apt-key add -
echo "deb https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list

# Update and install
sudo apt-get update
sudo apt-get install -y 1password-cli
```

#### macOS

```bash
brew install 1password-cli
```

#### Other Systems

Visit: https://developer.1password.com/docs/cli/get-started/#install

## Authentication

### Step 1: Add Your 1Password Account

```bash
# Interactive setup
op account add

# Follow prompts to sign in with your 1Password account
# You'll need your email, master password, and sign-in address
```

### Step 2: Verify Authentication

```bash
# Check current authentication
op account get

# Should display your 1Password account details
```

### Step 3: Set Up Service Account (for CI/CD)

For automated deployments in GitHub Actions, use a service account instead of personal credentials:

1. Go to 1Password web interface
2. Settings → Developers → Service Accounts
3. Create a new service account
4. Generate an access token
5. Copy the token (you'll only see it once)
6. Store in GitHub repository secrets as `OP_SERVICE_ACCOUNT_TOKEN`

## Vault Setup

### Create Development Vault

```bash
# Create vault for development secrets
op vault create "Development Secrets"

# Verify creation
op vault list
```

### Create Staging Vault

```bash
# Create vault for staging secrets (separate from development)
op vault create "Staging Secrets"
```

### Create Production Vault

```bash
# Create vault for production secrets (highest security)
op vault create "Production Secrets"

# Restrict access to this vault in 1Password web interface
# Settings → Manage Team Members → Adjust permissions
```

### List All Vaults

```bash
# View all available vaults
op vault list

# View detailed vault information
op vault list --format json | jq '.[] | {id, name}'
```

## Secret Management

### Adding Secrets to Vaults

#### Method 1: Interactive Creation

```bash
# Create a new secret interactively
op item create \
  --vault "Development Secrets" \
  --title "github-credentials" \
  --category "api_credential"

# Follow prompts to enter fields
```

#### Method 2: Direct Command

```bash
# Create API credential with token
op item create \
  --vault "Development Secrets" \
  --title "github-credentials" \
  --category "api_credential" \
  token="ghp_1234567890abcdef"

# Verify creation
op item get "github-credentials" --vault "Development Secrets"
```

#### Method 3: Using Environment Variables

```bash
# Set secret from environment variable
export GITHUB_TOKEN="ghp_your_token_here"

op item create \
  --vault "Development Secrets" \
  --title "github-credentials" \
  --category "api_credential" \
  token="$GITHUB_TOKEN"
```

### Example Secrets to Create

Create these secrets in "Development Secrets" vault:

```bash
# GitHub credentials
op item create \
  --vault "Development Secrets" \
  --title "github-credentials" \
  --category "api_credential" \
  token="your_github_token"

# NPM credentials
op item create \
  --vault "Development Secrets" \
  --title "npm-credentials" \
  --category "api_credential" \
  token="your_npm_token"

# Claude API credentials
op item create \
  --vault "Development Secrets" \
  --title "claude-credentials" \
  --category "api_credential" \
  api_key="your_claude_api_key"

# Database credentials (if applicable)
op item create \
  --vault "Development Secrets" \
  --title "database-connection" \
  --category "database" \
  connection_string="postgresql://user:pass@localhost:5432/db" \
  username="dbuser" \
  password="dbpass"

# SSH credentials (if applicable)
op item create \
  --vault "Development Secrets" \
  --title "ssh-credentials" \
  --category "ssh_key" \
  private_key="$(cat ~/.ssh/id_rsa)" \
  public_key="$(cat ~/.ssh/id_rsa.pub)"

# OAuth credentials
op item create \
  --vault "Development Secrets" \
  --title "oauth-credentials" \
  --category "api_credential" \
  client_id="your_client_id" \
  client_secret="your_client_secret"
```

### Viewing Secrets

```bash
# List all secrets in a vault
op item list --vault "Development Secrets"

# View specific secret
op item get "github-credentials" --vault "Development Secrets"

# Get specific field from secret
op item get "github-credentials" \
  --vault "Development Secrets" \
  --fields "token"

# View secret in JSON format
op item get "github-credentials" \
  --vault "Development Secrets" \
  --format json | jq '.'
```

### Updating Secrets

```bash
# Update a field in a secret
op item edit "github-credentials" \
  --vault "Development Secrets" \
  token="new_github_token"
```

### Deleting Secrets

```bash
# Delete a secret (moves to trash)
op item delete "github-credentials" \
  --vault "Development Secrets"
```

## Environment Variable Configuration

### Using the Secrets Manager Script

The `profile/secrets-manager.sh` script provides comprehensive secret management:

```bash
# Make script executable (already done)
chmod +x .github/profile/secrets-manager.sh

# Show help
./.github/profile/secrets-manager.sh help

# Check setup
./.github/profile/secrets-manager.sh check

# List secrets in a vault
./.github/profile/secrets-manager.sh list "Development Secrets"

# Export all secrets to .env file
./.github/profile/secrets-manager.sh export "Development Secrets" .env

# Validate required secrets
./.github/profile/secrets-manager.sh validate "Development Secrets"
```

### Loading Secrets into Environment

#### Option 1: Using 1Password References

In your `.env` file, use 1Password references:

```bash
# .env or .env.development
GITHUB_TOKEN=op://Development Secrets/github-credentials/token
NPM_TOKEN=op://Development Secrets/npm-credentials/token
CLAUDE_API_KEY=op://Development Secrets/claude-credentials/api_key
```

Then load into shell:

```bash
# Evaluate 1Password references and load to environment
eval "$(op run --no-masking -- env)"

# Or use the secrets manager script
./.github/profile/secrets-manager.sh load development
```

#### Option 2: Direct Export

```bash
# Export specific secret to environment variable
export GITHUB_TOKEN=$(op item get "github-credentials" \
  --vault "Development Secrets" \
  --fields "token")

# Verify it loaded
echo $GITHUB_TOKEN
```

#### Option 3: Using op run Command

```bash
# Run command with secrets injected as environment variables
op run --env-file=.env.development -- npm run build

# Or with Python
op run --env-file=.env.development -- python3 src/server.py
```

## Usage Examples

### Example 1: Development Workflow

```bash
# 1. Authenticate
op account get

# 2. List available secrets
./.github/profile/secrets-manager.sh list "Development Secrets"

# 3. Load environment variables
./.github/profile/secrets-manager.sh load development

# 4. Run application with secrets
op run --env-file=.env.development -- npm start
```

### Example 2: Deploying with Secrets

```bash
# 1. Export secrets to temporary .env file
./.github/profile/secrets-manager.sh export "Development Secrets" .env.temp

# 2. Run deployment script with secrets
./.github/profile/deploy.sh deploy api-mcp-server

# 3. Clean up temporary file
shred -vfz -n 10 .env.temp
```

### Example 3: Rotating Secrets

```bash
# 1. Generate new token in GitHub/NPM/etc

# 2. Update in 1Password
./.github/profile/secrets-manager.sh rotate \
  "Development Secrets" \
  "github-credentials" \
  "token" \
  "new_ghp_token_value"

# 3. Redeploy affected services
./.github/profile/deploy.sh deploy github-mcp-server
```

### Example 4: Checking Secret Expiry

```bash
# View secret creation/modification dates
op item get "github-credentials" \
  --vault "Development Secrets" \
  --format json | jq '.createdAt, .updatedAt'
```

## GitHub Actions Integration

### Setting Up CI/CD Secrets

#### Step 1: Create Service Account

1. Sign in to 1Password
2. Go to Settings → Developers → Service Accounts
3. Click "Create service account"
4. Give it a name: "GitHub Actions CI/CD"
5. Generate access token
6. Copy the token (save it now!)

#### Step 2: Add Repository Secret

```bash
# Using GitHub CLI
gh secret set OP_SERVICE_ACCOUNT_TOKEN --body "paste_your_token_here"

# Or via GitHub web interface:
# 1. Go to Settings → Secrets and variables → Actions
# 2. Click "New repository secret"
# 3. Name: OP_SERVICE_ACCOUNT_TOKEN
# 4. Value: (paste the service account token)
```

#### Step 3: Use in Workflow

The `.github/workflows/1password-deploy.yml` workflow is already configured to use the secrets.

See [GitHub Actions Integration](#github-actions-integration) section below.

### Workflow Example

```yaml
name: Build with 1Password Secrets

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Load 1Password Secrets
        uses: 1Password/load-secrets-action@v2
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
      
      - name: Build with secrets
        run: npm run build
        env:
          # Secrets are automatically available
          GITHUB_TOKEN: ${{ env.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ env.NPM_TOKEN }}
```

## Security Best Practices

### ✅ DO

- ✅ Use service accounts for CI/CD (never personal accounts)
- ✅ Rotate secrets regularly (monthly for API keys, quarterly for passwords)
- ✅ Store 1Password access token in repository secrets only
- ✅ Use `.gitignore` to prevent committing secrets
- ✅ Enable 1Password audit logging
- ✅ Review access logs regularly
- ✅ Use different vaults for different environments
- ✅ Restrict vault access via 1Password permission system
- ✅ Verify secret integrity before deployment
- ✅ Use `shred` or similar to securely delete temporary .env files

### ❌ DON'T

- ❌ Never commit `.env` files to git
- ❌ Never store secrets in plaintext files
- ❌ Never share 1Password access tokens
- ❌ Never use personal 1Password accounts for automation
- ❌ Never log secrets to console or files
- ❌ Never commit private SSH keys or certificates
- ❌ Never use weak or default passwords
- ❌ Never store secrets in comments or documentation
- ❌ Never disable 1Password MFA
- ❌ Never share vault access unless necessary

### Secret Rotation Schedule

```
API Keys (GitHub, NPM):       Every 90 days
Database Passwords:           Every 120 days
SSH Keys:                     Every 365 days (or on compromise)
Service Account Tokens:       Every 60 days
OAuth Client Secrets:         Every 90 days
```

### Audit Logging

```bash
# Generate audit report
./.github/profile/secrets-manager.sh audit 7

# View recent activity
tail -50 ~/.1password/audit.log
```

## Troubleshooting

### Issue: "Not signed into 1Password"

```bash
# Solution: Authenticate first
op account add

# Or verify existing authentication
op account get
```

### Issue: "Secret not found in vault"

```bash
# List all secrets in vault
op item list --vault "Development Secrets"

# Check exact secret name
op item get "github-credentials" \
  --vault "Development Secrets"
```

### Issue: "Permission denied to vault"

```bash
# Check your 1Password permissions
op account get

# In 1Password web interface, verify vault access:
# Settings → Manage Team Members → Check permissions for your user
```

### Issue: ".env file not being loaded"

```bash
# Verify file exists and is readable
ls -la .env

# Check file permissions
chmod 600 .env

# Source the file explicitly
source .env

# Verify variables are set
env | grep GITHUB_TOKEN
```

### Issue: "op run: command not found"

```bash
# Ensure you're using latest 1Password CLI
op --version

# Update if needed
sudo apt-get update && sudo apt-get install --only-upgrade 1password-cli
```

### Issue: Service account token expired in CI/CD

```bash
# Generate new service account token in 1Password web interface
# Settings → Developers → Service Accounts → Token details → Generate new token

# Update GitHub repository secret
gh secret set OP_SERVICE_ACCOUNT_TOKEN --body "new_token"
```

### Debug Mode

```bash
# Enable debug logging
DEBUG=1 ./.github/profile/secrets-manager.sh check

# View detailed logs
cat .secrets-logs/secrets-manager.log
```

## Useful Commands Reference

```bash
# Authentication
op account add                              # Sign in
op account get                              # Check current account

# Vaults
op vault list                               # List all vaults
op vault create "Vault Name"               # Create new vault

# Items/Secrets
op item list --vault "Vault Name"          # List secrets
op item get "Item Name" --vault "Vault"    # View secret
op item create --vault "Vault" --title "Name"  # Create secret
op item edit "Item" --vault "Vault" field=value  # Update secret
op item delete "Item" --vault "Vault"      # Delete secret

# Environment Variables
op run --env-file=.env -- command          # Run with .env
eval "$(op run --no-masking -- env)"       # Load to current shell

# Scripting
op item get "Item" --vault "Vault" --fields "field"  # Get field value
op item list --vault "Vault" --format json  # JSON output
op item get "Item" --vault "Vault" --format json    # JSON details
```

## Getting Help

- 1Password CLI Documentation: https://developer.1password.com/docs/cli/
- 1Password Support: https://support.1password.com/
- GitHub Actions Integration: https://github.com/1Password/load-secrets-action

---

Last Updated: 2024-07-10
Version: 1.0
