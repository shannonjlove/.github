# ChatGPT Plugin: 1Password CLI Manager

Complete guide for installing and using the 1Password CLI Manager plugin in ChatGPT.

**Version:** 1.0.0  
**Status:** Production Ready  
**Last Updated:** July 10, 2024

## Overview

The 1Password CLI Manager is a ChatGPT plugin that enables you to:

- 🔐 Manage secrets and credentials
- 🚀 Deploy applications with secure secret injection
- 📋 List and validate secrets in 1Password vaults
- 🔄 Rotate credentials safely
- 📊 Generate audit reports
- 🛠️ Configure multi-environment deployments

## Installation

### Method 1: Install via ChatGPT Plugin Store

1. Open ChatGPT and go to the Plugin Store
2. Search for **"1Password CLI Manager"**
3. Click **"Install"**
4. Authorize the plugin to access your system

### Method 2: Manual Installation

1. Go to ChatGPT Settings → Plugins
2. Click **"Install an unverified plugin"**
3. Enter the plugin URL:
   ```
   https://raw.githubusercontent.com/shannonjlove/1password-cli-skill/main/ai-plugin.json
   ```
4. Click **"Install"**

### Method 3: Development Mode (Local)

```bash
# 1. Clone the repository
git clone https://github.com/shannonjlove/1password-cli-skill.git
cd 1password-cli-skill

# 2. Start local server
python3 -m http.server 8000

# 3. In ChatGPT Plugin Settings, add:
# http://localhost:8000/ai-plugin.json
```

## Getting Started

### First Time Setup

1. **Authenticate with 1Password**
   - Ensure 1Password CLI is installed: `op --version`
   - Sign in: `op account add`

2. **Ask ChatGPT**
   ```
   "List all vaults in my 1Password account"
   ```
   The plugin will show available vaults

3. **Create or Select a Vault**
   ```
   "Create a new vault called Development Secrets"
   ```

4. **Add Your First Secret**
   ```
   "Add a GitHub token to Development Secrets vault
   with title github-credentials and token value: ghp_xxxxx"
   ```

### Common Use Cases

#### Use Case 1: Check Deployment Setup

```
User: "Check if my 1Password CLI is properly configured"

ChatGPT will:
- Verify CLI installation
- Check authentication
- List accessible vaults
- Show deployment status
```

#### Use Case 2: List and Validate Secrets

```
User: "List all secrets in Development Secrets vault
       and validate that github-credentials, npm-credentials,
       and claude-credentials exist"

ChatGPT will:
- List all secrets in the vault
- Validate required secrets
- Show which secrets are missing (if any)
- Provide recommendations
```

#### Use Case 3: Deploy Application

```
User: "Deploy api-mcp-server to development environment
       with secrets from Development Secrets vault"

ChatGPT will:
- Verify all required secrets exist
- Initiate deployment
- Inject secrets automatically
- Provide deployment status
```

#### Use Case 4: Rotate Credentials

```
User: "Rotate the GitHub token in Development Secrets vault.
       New token is: ghp_xxxxx"

ChatGPT will:
- Update the token safely
- Verify update succeeded
- Suggest redeploying dependent services
```

#### Use Case 5: Generate Audit Report

```
User: "Generate an audit report of all secret access
       in the last 7 days"

ChatGPT will:
- Create comprehensive audit report
- Show all access events
- Identify unusual activity
- Provide security recommendations
```

## Available Commands

The plugin supports these operations through natural language:

### Secret Management

| Command | Description | Example |
|---------|-------------|---------|
| List secrets | Get all secrets in a vault | "List all secrets in Development Secrets" |
| Get secret | Retrieve specific secret | "Get the github-credentials secret" |
| Create secret | Add new secret | "Create a new npm-credentials secret" |
| Update secret | Modify secret value | "Update the token in github-credentials" |
| Delete secret | Remove secret | "Delete the old-api-key secret" |
| Validate secrets | Check required secrets exist | "Validate Development Secrets vault" |
| Rotate credential | Update credential safely | "Rotate the GitHub token" |

### Vault Management

| Command | Description | Example |
|---------|-------------|---------|
| List vaults | Show all vaults | "List all my 1Password vaults" |
| Check setup | Verify configuration | "Check if 1Password CLI is configured" |
| Audit secrets | Generate audit report | "Show audit log for Development Secrets" |

### Deployment

| Command | Description | Example |
|---------|-------------|---------|
| Deploy server | Deploy with secrets | "Deploy api-mcp-server to development" |
| Export environment | Create .env file | "Export Development Secrets to .env" |
| Check deployment | Verify setup | "Check deployment configuration" |

## Security Best Practices

### ✅ DO

```
✓ "Rotate my GitHub token in 1Password"
  (Use the plugin to safely update credentials)

✓ "Generate an audit report of secret access"
  (Monitor who accessed what)

✓ "Validate that all required secrets exist before deploying"
  (Prevent deployment with missing secrets)

✓ "Export secrets to .env for development only"
  (Keep secrets secure during development)

✓ "Use separate vaults for dev/staging/prod"
  (Isolate credentials by environment)
```

### ❌ DON'T

```
✗ "Send me the GitHub token as plain text"
  (Don't ask for plaintext secret exposure)

✗ "Create a new vault without access controls"
  (Always set proper permissions)

✗ "Export all secrets to a text file"
  (Avoid creating unencrypted secret files)

✗ "Give everyone access to Production Secrets vault"
  (Restrict production access strictly)

✗ "Store secrets in chat history"
  (Never copy secrets into conversation)
```

## Integration with Development Workflow

### Local Development

1. Ask ChatGPT to check your vault:
   ```
   "Check Development Secrets vault status"
   ```

2. Export secrets for local development:
   ```
   "Export Development Secrets to .env for local development"
   ```

3. Use the exported environment:
   ```bash
   source .env
   npm start
   ```

### Deployment Pipeline

1. Validate before deployment:
   ```
   "Validate all required secrets exist in Development Secrets"
   ```

2. Deploy application:
   ```
   "Deploy api-mcp-server to development with secrets"
   ```

3. Verify deployment:
   ```
   "Check deployment status for api-mcp-server"
   ```

### Credential Rotation

1. Generate new credential (in GitHub/NPM/etc)

2. Ask ChatGPT to update:
   ```
   "Update the GitHub token in Development Secrets vault to: ghp_xxxxx"
   ```

3. Redeploy if needed:
   ```
   "Redeploy api-mcp-server with updated secrets"
   ```

## Supported Environments

The plugin supports three environments:

### Development
- **Vault:** Development Secrets
- **Security:** Low
- **Use:** Local development
- **Secret Example:** `github-credentials`, `npm-credentials`

### Staging
- **Vault:** Staging Secrets
- **Security:** Medium
- **Use:** Pre-production testing
- **Secret Example:** Production database credentials

### Production
- **Vault:** Production Secrets
- **Security:** High
- **Use:** Production deployment
- **Secret Example:** Encrypted production API keys

Ask ChatGPT:
```
"List secrets in Staging Secrets vault"
"Deploy to production environment"
```

## Supported MCP Servers

The plugin can deploy these servers:

- `api-mcp-server` - Node.js/TypeScript
- `claude-memory-mcp` - Python
- `github-mcp-server` - Go
- `mcp-ssh-server` - TypeScript

Ask ChatGPT:
```
"Deploy api-mcp-server to development"
"Deploy all servers to staging"
"Check deployment status"
```

## Troubleshooting

### Issue: "Plugin not working"

**Solution:**
```
Ask: "Check if my 1Password CLI is properly configured"

ChatGPT will diagnose:
- CLI installation status
- Authentication status
- Vault accessibility
- Suggested fixes
```

### Issue: "Secret not found"

**Solution:**
```
Ask: "List all secrets in Development Secrets vault
     and check if github-credentials exists"

ChatGPT will:
- List all secrets
- Search for the specific secret
- Suggest the correct name if found
```

### Issue: "Permission denied"

**Solution:**
```
Ask: "Check my vault permissions"

ChatGPT will show:
- Current permissions
- Accessible vaults
- Restricted vaults
- How to request access
```

### Issue: "Deployment failed"

**Solution:**
```
Ask: "Validate all required secrets before deploying
     and tell me what's missing"

ChatGPT will:
- Check each required secret
- List missing credentials
- Suggest which secrets to add
```

## Advanced Features

### Custom Queries

Ask ChatGPT complex questions:

```
"Show me all secrets in Development Secrets that were
created in the last 7 days"

"Find all API credentials across all vaults and tell me
which ones haven't been rotated"

"Check if we have database credentials for staging and
production environments"

"Generate a report of which secrets are used by which
applications"
```

### Automation Suggestions

ChatGPT can suggest workflows:

```
"Suggest a credential rotation schedule for our APIs"

"What's the best practice for managing database credentials
across dev/staging/production?"

"Create a checklist for deploying api-mcp-server securely"
```

### Security Analysis

Ask for security recommendations:

```
"Analyze the security of our secret management setup"

"Do we have proper access controls on Production Secrets?"

"How can we improve our secret rotation practices?"
```

## API Integration

### For Developers

The plugin uses OpenAPI specification. You can:

1. **Review the API:**
   ```
   cat chatgpt-plugin/openapi.yaml
   ```

2. **Integrate with other tools:**
   ```bash
   curl -X GET "http://localhost:8000/secrets/list?vault=Development%20Secrets"
   ```

3. **Extend functionality:**
   ```bash
   # Add custom endpoints to openapi.yaml
   # Create handlers for new operations
   ```

## Configuration Files

The plugin references these configuration files:

- **ai-plugin.json** - Plugin metadata
- **openapi.yaml** - API specification
- **README.md** - Plugin documentation
- **.github/1password-config.json** - Deployment config
- **.github/1password-secrets-config.yaml** - Secrets definition

## System Requirements

- **ChatGPT Plus subscription** (for plugin access)
- **1Password CLI v2.34.1+**
- **1Password account** with vault access
- **Authentication:** `op account add`

## Environment Variables

The plugin reads these variables (for local deployment):

```
OP_SERVICE_ACCOUNT_TOKEN  # For CI/CD automation
DEPLOYMENT_ENV            # Environment (dev/staging/prod)
LOG_LEVEL                 # Logging verbosity
```

## Limitations

Current limitations of the plugin:

- ⚠️ Requires 1Password CLI installed locally
- ⚠️ Requires prior authentication with 1Password
- ⚠️ Cannot create new vaults (admin-only)
- ⚠️ Cannot modify vault permissions
- ⚠️ Read-only for some production operations

## Coming Soon

Planned improvements:

- 📋 Interactive secret creation wizard
- 🔔 Real-time deployment notifications
- 📊 Enhanced audit dashboards
- 🔐 Biometric authentication support
- 🌐 Web-based configuration interface

## Support & Documentation

### In-Plugin Help

In ChatGPT, ask:
```
"Help me understand how to use the 1Password plugin"
"What are the best practices for secret management?"
"How do I deploy with this plugin?"
```

### External Resources

- **Setup Guide:** See `.github/1PASSWORD-SETUP.md`
- **Implementation:** See `.github/1PASSWORD-IMPLEMENTATION-SUMMARY.md`
- **Deployment:** See `.github/DEPLOYMENT.md`
- **1Password Docs:** https://developer.1password.com/docs/cli/

## FAQ

**Q: Is my data secure when using this plugin?**  
A: Yes. The plugin only coordinates with 1Password CLI running locally. Secrets are encrypted in 1Password vault and never exposed.

**Q: Can I use this plugin without ChatGPT Plus?**  
A: No, plugins require ChatGPT Plus subscription.

**Q: What if I forget my 1Password master password?**  
A: You'll need to use 1Password's account recovery process. The plugin cannot bypass security.

**Q: How do I revoke plugin access?**  
A: Go to ChatGPT Settings → Plugins → Manage → Find 1Password → Remove.

**Q: Can I use this for my team?**  
A: Yes, but each team member needs their own 1Password account and ChatGPT Plus.

## Contact & Feedback

- **GitHub Issues:** https://github.com/shannonjlove/1password-cli-skill/issues
- **Email:** sjlove@shannonjeffreylove.com
- **Discussions:** https://github.com/shannonjlove/1password-cli-skill/discussions

---

**Happy secure secret management with ChatGPT! 🔐**

For complete setup instructions, see `.github/1PASSWORD-SETUP.md`
