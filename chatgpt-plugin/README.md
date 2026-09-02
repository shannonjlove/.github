# 1Password CLI Manager - ChatGPT Plugin

**Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Last Updated:** July 10, 2024

ChatGPT plugin for managing secrets and environment variables using 1Password CLI. Supports secure secret management, deployment automation, and audit logging across multiple environments.

## 🚀 Quick Start

### Installation (1 minute)

1. **Open ChatGPT** → Settings → Plugins
2. Click **"Install an unverified plugin"**
3. Enter URL:
   ```
   https://github.com/shannonjlove/1password-cli-skill/raw/main/ai-plugin.json
   ```
4. Click **Install**

### First Use (5 minutes)

1. **Verify Setup:**
   ```
   "Check if my 1Password CLI is properly configured"
   ```

2. **Create Vault:**
   ```
   "Create a new vault called Development Secrets"
   ```

3. **Add Secret:**
   ```
   "Add a GitHub token to Development Secrets
    with title github-credentials and token: ghp_xxxxx"
   ```

4. **List Secrets:**
   ```
   "List all secrets in Development Secrets vault"
   ```

## ✨ Features

### 🔐 Secret Management
- List all secrets in vaults
- Create new secrets
- Update/rotate credentials
- Validate required secrets exist
- Delete secrets

### 🚀 Deployment
- Deploy MCP servers with automatic secret injection
- Support for dev/staging/production environments
- Pre-deployment validation
- Deployment status checking

### 📊 Monitoring
- Audit reports of all secret access
- Access logs and activity tracking
- Security compliance reporting
- Unauthorized access detection

### 🛠️ Automation
- Automatic secret injection into deployments
- Environment-specific configurations
- Secret rotation workflows
- Export to .env files

## 📖 Usage Examples

### Example 1: Check Setup
```
User: "Check if 1Password CLI is installed and authenticated"

ChatGPT:
✓ CLI installed: Yes (v2.34.1)
✓ Authenticated: Yes
✓ Accessible vaults: 3
  - Development Secrets
  - Staging Secrets
  - Production Secrets
```

### Example 2: List and Validate
```
User: "List all secrets in Development Secrets vault
       and validate github-credentials, npm-credentials exist"

ChatGPT:
Vault: Development Secrets
Secrets found: 5
├── github-credentials ✓ (VALID)
├── npm-credentials ✓ (VALID)
├── claude-credentials ✗ (MISSING)
├── database-connection
└── ssh-credentials

Status: 2/3 required secrets found
Recommendation: Add claude-credentials
```

### Example 3: Deploy Server
```
User: "Deploy api-mcp-server to development with secrets"

ChatGPT:
1. Validating secrets... ✓
2. Preparing deployment... ✓
3. Injecting secrets... ✓
4. Starting server... ✓

Deployment Status: SUCCESS
Server: api-mcp-server
Environment: development
Secret variables: 5
Deployment ID: 1234567890
```

### Example 4: Rotate Credential
```
User: "Update GitHub token in Development Secrets to ghp_new_token"

ChatGPT:
Updating secret: github-credentials

Status: ✓ SUCCESS
Vault: Development Secrets
Item: github-credentials
Field: token
Updated at: 2024-07-10 08:15:32 UTC

Recommendation: Redeploy services using this credential
```

### Example 5: Generate Report
```
User: "Generate an audit report of secret access last 7 days"

ChatGPT:
Audit Report: Last 7 Days
Total events: 42
Access events: 38
Modifications: 4

Top accessed secrets:
1. github-credentials (12 accesses)
2. npm-credentials (8 accesses)
3. database-connection (6 accesses)

Modifications:
- github-credentials: Updated 2x
- npm-credentials: Updated 1x
- ssh-credentials: Updated 1x

Security: No suspicious activity detected ✓
```

## 🎯 Common Tasks

| Task | Ask ChatGPT |
|------|-------------|
| Check setup | "Check if 1Password CLI is configured" |
| List secrets | "List all secrets in Development Secrets" |
| Add secret | "Create a new secret in Development vault" |
| Rotate token | "Update GitHub token in my vault" |
| Deploy app | "Deploy api-mcp-server to development" |
| Validate | "Validate all required secrets exist" |
| Audit | "Generate audit report last 7 days" |
| Export | "Export Development Secrets to .env" |

## 🔒 Security Best Practices

### ✅ DO

- Use ChatGPT plugin to manage secrets securely
- Rotate credentials every 60-90 days
- Validate secrets before deployment
- Use separate vaults for each environment
- Monitor audit logs regularly
- Restrict production vault access

### ❌ DON'T

- Never ask for plaintext secret values
- Don't create vaults without access controls
- Don't export secrets to unencrypted files
- Don't share vault access freely
- Don't store secrets in chat history
- Don't bypass security validations

## 📋 Supported Operations

### Secrets API

```
Operations:
- GET /secrets/list           - List all secrets
- GET /secrets/get            - Get specific secret
- POST /secrets/validate      - Validate required secrets
- POST /secrets/rotate        - Rotate credential
```

### Vaults API

```
Operations:
- GET /vaults/list            - List all vaults
```

### Deployment API

```
Operations:
- GET /deployment/check       - Check setup status
- POST /deployment/deploy     - Deploy server
```

### Environment API

```
Operations:
- POST /environment/export    - Export to .env
```

### Audit API

```
Operations:
- GET /audit/report           - Generate report
```

## 🎮 Interactive Features

### Conversational Interface

Ask natural language questions:
```
"What secrets do I have?"
"Are all required secrets configured?"
"When was the last rotation?"
"Who accessed production secrets?"
"Show deployment history"
```

### Smart Recommendations

ChatGPT provides helpful suggestions:
```
"✓ Your github-credentials should be rotated (last updated 45 days ago)"
"⚠ Consider creating a Staging vault for pre-production testing"
"📋 Would you like to generate an audit report?"
```

### Guided Workflows

Step-by-step assistance:
```
"Let me help you deploy api-mcp-server:
1. Checking required secrets... ✓
2. Validating vault access... ✓
3. Preparing deployment...
   What environment? [development/staging/production]"
```

## 📁 Files Included

```
chatgpt-plugin/
├── ai-plugin.json                    # Plugin manifest
├── openapi.yaml                      # API specification
├── CHATGPT_PLUGIN_GUIDE.md          # Complete guide
├── manifest.json                     # Plugin metadata
├── README.md                         # This file
└── logo.png                          # Plugin icon
```

## 🔧 System Requirements

- **ChatGPT Plus** (for plugin access)
- **1Password CLI v2.34.1+**
- **Bash v4.0+**
- **1Password Account** with vault access

## 📚 Documentation

- **Plugin Guide:** See `CHATGPT_PLUGIN_GUIDE.md`
- **Setup Instructions:** See `.github/1PASSWORD-SETUP.md`
- **Implementation Details:** See `.github/1PASSWORD-IMPLEMENTATION-SUMMARY.md`
- **Deployment Guide:** See `.github/DEPLOYMENT.md`

## 🆘 Troubleshooting

### Plugin Not Working

**Ask ChatGPT:**
```
"Check if my 1Password CLI is properly configured"
```

ChatGPT will diagnose:
- CLI installation status
- Authentication status
- Vault accessibility
- Suggested fixes

### Secret Not Found

**Ask ChatGPT:**
```
"List all secrets in Development Secrets vault"
```

This shows all available secrets and helps find the right name.

### Permission Issues

**Ask ChatGPT:**
```
"Check my vault permissions"
```

This displays:
- Current access level
- Accessible vaults
- Restricted vaults
- How to request access

## 🌟 Advanced Features

### Custom Queries

```
"Show all secrets created in the last 7 days"
"Find all API credentials across all vaults"
"List secrets that need rotation"
"Compare secrets between dev and staging"
```

### Automation

```
"Create a rotation schedule for API keys"
"Generate a deployment checklist"
"Suggest best practices for secret management"
"Audit our current security setup"
```

### Integration

```
"Can you show me how to integrate this with CI/CD?"
"How do I deploy with GitHub Actions?"
"What environment variables should I use?"
```

## 📊 Supported Environments

| Environment | Vault | Security | Use Case |
|-------------|-------|----------|----------|
| Development | Development Secrets | Low | Local dev |
| Staging | Staging Secrets | Medium | Pre-prod |
| Production | Production Secrets | High | Production |

## 🎯 Supported MCP Servers

The plugin can deploy:
- `api-mcp-server` - Node.js/TypeScript
- `claude-memory-mcp` - Python
- `github-mcp-server` - Go
- `mcp-ssh-server` - TypeScript

## 💡 Tips & Tricks

1. **Ask naturally** - You can use conversational language
2. **Get details** - Ask "Tell me more" for additional information
3. **Use history** - ChatGPT remembers vault names and context
4. **Batch operations** - Handle multiple secrets in one query
5. **Get recommendations** - Ask for best practices

## 🔐 Security Features

- ✅ Encrypted secret storage (AES-256)
- ✅ Role-based access control
- ✅ Comprehensive audit logging
- ✅ Automatic access validation
- ✅ Secure credential rotation
- ✅ GDPR & SOC 2 compliance

## 📞 Support

- **Documentation:** See `CHATGPT_PLUGIN_GUIDE.md`
- **Issues:** https://github.com/shannonjlove/1password-cli-skill/issues
- **Email:** sjlove@shannonjeffreylove.com

## 📈 Roadmap

Planned improvements:
- [ ] Interactive secret creation wizard
- [ ] Real-time deployment notifications
- [ ] Enhanced audit dashboards
- [ ] Biometric authentication
- [ ] Web-based configuration UI

## 📄 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

Built with:
- ChatGPT API
- 1Password CLI
- OpenAPI specification

---

**Ready to use!** Install now and ask:  
**"Check if my 1Password CLI is properly configured"**

For complete setup, see `CHATGPT_PLUGIN_GUIDE.md`
