# ChatGPT Plugin: 1Password CLI Manager - Download & Installation

**Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Updated:** July 10, 2024

## 📥 Download Links

### Option 1: Quick Install (Recommended)
```
Direct URL: https://github.com/shannonjlove/1password-cli-skill/raw/main/ai-plugin.json
```

Use this URL directly in ChatGPT to install the plugin.

### Option 2: Download Package

#### Linux/macOS (Compressed Tar)
```
📦 chatgpt-plugin-1password-cli.tar.gz (11 KB)

Download: https://github.com/shannonjlove/1password-cli-skill/releases/download/v1.0.0/chatgpt-plugin-1password-cli.tar.gz

Extract:
tar -xzf chatgpt-plugin-1password-cli.tar.gz
cd chatgpt-plugin
```

#### Windows (ZIP Archive)
```
📦 chatgpt-plugin-1password-cli.zip (14 KB)

Download: https://github.com/shannonjlove/1password-cli-skill/releases/download/v1.0.0/chatgpt-plugin-1password-cli.zip

Extract:
Right-click → Extract All
cd chatgpt-plugin
```

## 🚀 Installation Methods

### Method 1: ChatGPT Web Interface (Easiest)

1. **Open ChatGPT:** https://chat.openai.com
2. **Go to Settings:**
   - Click your profile → Settings
   - Select "Features" → "Plugins"
   - Click "Plugin store" or "Manage plugins"

3. **Search for Plugin:**
   - Click "Install an unverified plugin"
   - Enter: `https://github.com/shannonjlove/1password-cli-skill/raw/main/ai-plugin.json`
   - Click "Install"

4. **Enable Plugin:**
   - In chat, select GPT-4 or latest model
   - Click plugin icon
   - Enable "1Password CLI Manager"

### Method 2: ChatGPT Plugin Store (When Available)

1. **Open ChatGPT Plugin Store**
2. **Search:** "1Password CLI Manager"
3. **Click:** "Install"
4. **Authorize:** Grant access when prompted

### Method 3: Manual Local Installation

**Prerequisites:**
```bash
# Ensure you have Python 3.7+
python3 --version

# Ensure 1Password CLI is installed
op --version
```

**Setup:**

1. **Extract files:**
   ```bash
   tar -xzf chatgpt-plugin-1password-cli.tar.gz
   cd chatgpt-plugin
   ```

2. **Start local server:**
   ```bash
   python3 -m http.server 8000
   # Server running at http://localhost:8000
   ```

3. **Install in ChatGPT:**
   - Settings → Plugins → "Install an unverified plugin"
   - Enter: `http://localhost:8000/ai-plugin.json`
   - Click "Install"

4. **Keep server running** while using the plugin

## 📋 Package Contents

After extraction, you'll find:

```
chatgpt-plugin/
├── ai-plugin.json                    # Plugin manifest (16 lines)
├── openapi.yaml                      # API specification (250+ lines)
├── CHATGPT_PLUGIN_GUIDE.md          # Complete usage guide (400+ lines)
├── manifest.json                     # Metadata (150+ lines)
├── README.md                         # Quick reference (300+ lines)
└── logo.png                          # Plugin icon (placeholder)
```

**Total:** 5 files, ~14 KB

## 🔧 System Requirements

### Minimum Requirements

- **ChatGPT:** ChatGPT Plus (plugin access required)
- **1Password CLI:** v2.34.1 or later
- **System:** Linux, macOS, or Windows (WSL)
- **Bash:** v4.0 or later
- **Internet:** For ChatGPT connection

### Installation Prerequisites

```bash
# Check ChatGPT Plus: https://chat.openai.com (requires subscription)

# Check 1Password CLI
op --version
# Output should show v2.34.1+

# Authenticate with 1Password
op account add
# Follow prompts to sign in

# Verify authentication
op account get
# Should display your 1Password account
```

## ⚙️ Configuration

### First-Time Setup (5 minutes)

1. **Install plugin** (see above)
2. **Start ChatGPT conversation**
3. **Ask ChatGPT:**
   ```
   "Check if my 1Password CLI is properly configured"
   ```
4. **Follow recommendations** if any

### Environment Setup

The plugin reads from your local 1Password CLI:

```bash
# Make sure 1Password CLI is installed
which op

# Make sure you're authenticated
op account get

# Create vaults (if needed)
op vault create "Development Secrets"
op vault create "Staging Secrets"
op vault create "Production Secrets"
```

## 🎯 Quick Start After Installation

### 5-Minute Quick Start

```bash
# 1. Verify plugin is working
# In ChatGPT, ask: "Check my setup"

# 2. Create vault (optional)
op vault create "Development Secrets"

# 3. Add a secret
op item create --vault "Development Secrets" \
  --title "github-credentials" \
  --category "api_credential" \
  token="ghp_your_token_here"

# 4. Use in ChatGPT
# Ask: "List all secrets in Development Secrets vault"
```

### First Deployment

```bash
# 1. Add multiple secrets
op item create --vault "Development Secrets" --title "npm-credentials" \
  --category "api_credential" token="npm_your_token"

op item create --vault "Development Secrets" --title "claude-credentials" \
  --category "api_credential" api_key="sk_your_key"

# 2. Validate in ChatGPT
# Ask: "Validate all required secrets exist in Development Secrets"

# 3. Deploy application
# Ask: "Deploy api-mcp-server to development with secrets"
```

## 🆘 Installation Troubleshooting

### Issue: "Plugin installation failed"

**Solution:**
```
1. Clear ChatGPT cache: Settings → Clear chat history
2. Disable VPN if active
3. Try in incognito mode
4. Verify ChatGPT Plus is active
```

### Issue: "Plugin not responding"

**Solution:**
```
1. Restart ChatGPT
2. Check 1Password CLI: op account get
3. Check internet connection
4. Try manual installation (see Method 3 above)
```

### Issue: "1Password CLI not found"

**Solution:**
```bash
# Install 1Password CLI
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo apt-key add -
echo "deb https://downloads.1password.com/linux/debian/amd64 stable main" | \
  sudo tee /etc/apt/sources.list.d/1password.list
sudo apt-get update && sudo apt-get install -y 1password-cli

# Or on macOS
brew install 1password-cli

# Verify
op --version
```

### Issue: "Not authenticated with 1Password"

**Solution:**
```bash
# Sign in to 1Password
op account add

# Follow prompts:
# - Email address
# - Master password
# - 1Password web address

# Verify authentication
op account get
```

## 📖 Documentation

### Included Documentation

1. **README.md** (Quick reference)
   - Feature overview
   - Usage examples
   - Common tasks

2. **CHATGPT_PLUGIN_GUIDE.md** (Complete guide)
   - Installation instructions
   - Detailed examples
   - Advanced features
   - Troubleshooting
   - Security best practices

3. **ai-plugin.json** (Plugin manifest)
   - Plugin metadata
   - API configuration
   - Installation info

4. **openapi.yaml** (API specification)
   - Endpoint definitions
   - Request/response schemas
   - Security settings

5. **manifest.json** (Extended metadata)
   - Version information
   - Feature descriptions
   - System requirements

### External Documentation

- **Setup Guide:** `.github/1PASSWORD-SETUP.md`
- **Implementation:** `.github/1PASSWORD-IMPLEMENTATION-SUMMARY.md`
- **Deployment:** `.github/DEPLOYMENT.md`
- **1Password CLI Docs:** https://developer.1password.com/docs/cli/

## 🔒 Security & Privacy

### Security Features

- ✅ Secrets stored in encrypted 1Password vault
- ✅ Local execution (not sent to servers)
- ✅ Role-based access control
- ✅ Comprehensive audit logging
- ✅ No data storage in chat

### Privacy

- ✅ Your secrets never leave your system
- ✅ Plugin only coordinates with local 1Password CLI
- ✅ Chat history doesn't contain actual secret values
- ✅ All encryption handled by 1Password

### Best Practices

```
✓ Use strong master password for 1Password account
✓ Enable two-factor authentication
✓ Rotate credentials every 60-90 days
✓ Monitor audit logs regularly
✓ Restrict vault access via 1Password permissions
✓ Never share 1Password account access
✓ Keep 1Password CLI updated
```

## 📊 Version Information

### Current Version
```
Plugin Version: 1.0.0
Release Date: July 10, 2024
Status: Production Ready
API Version: OpenAPI 3.0.0
```

### Compatibility

| Component | Version | Status |
|-----------|---------|--------|
| ChatGPT | Plus+ | ✅ Required |
| 1Password CLI | v2.34.1+ | ✅ Tested |
| Python | 3.7+ | ✅ For local setup |
| Bash | v4.0+ | ✅ Recommended |

## 🆙 Updates & Support

### Checking for Updates

```bash
# Via GitHub
git clone https://github.com/shannonjlove/1password-cli-skill.git
cd 1password-cli-skill
git pull

# Check current version
cat chatgpt-plugin/manifest.json | grep plugin_version
```

### Getting Help

1. **Check Documentation:**
   - See `CHATGPT_PLUGIN_GUIDE.md`
   - See `README.md`

2. **Troubleshoot:**
   - Run: `op account get`
   - Ask ChatGPT: "Check my setup"

3. **Report Issues:**
   - GitHub: https://github.com/shannonjlove/1password-cli-skill/issues
   - Email: sjlove@shannonjeffreylove.com

4. **Get Support:**
   - 1Password Support: https://support.1password.com/
   - ChatGPT Support: https://help.openai.com/

## 💡 Tips for Best Results

1. **Read the guide first**
   - Understand the capabilities
   - Learn common use cases
   - Review security best practices

2. **Start simple**
   - List existing vaults
   - View existing secrets
   - Validate setup

3. **Build gradually**
   - Create one vault
   - Add secrets one by one
   - Test deployment

4. **Ask naturally**
   - Use conversational language
   - ChatGPT understands context
   - Follow up questions work well

5. **Monitor audit logs**
   - Check monthly reports
   - Review access patterns
   - Detect anomalies early

## 🎓 Learning Resources

### Quick Learning Path

1. **5 min:** Read README.md
2. **10 min:** Read Quick Start in CHATGPT_PLUGIN_GUIDE.md
3. **15 min:** Install plugin and test
4. **30 min:** Create vault and add secrets
5. **1 hour:** Deploy an application

### Deeper Learning

1. **Understand OpenAPI:** Read openapi.yaml
2. **Security:** Read `.github/1PASSWORD-SETUP.md#security`
3. **Deployment:** Read `.github/DEPLOYMENT.md`
4. **Troubleshooting:** See CHATGPT_PLUGIN_GUIDE.md#troubleshooting

## 📝 Checklist for Installation

- [ ] ChatGPT Plus active
- [ ] 1Password CLI installed (v2.34.1+)
- [ ] 1Password account created
- [ ] Authenticated: `op account get` ✓
- [ ] Downloaded plugin files
- [ ] Plugin installed in ChatGPT
- [ ] Plugin enabled in chat
- [ ] Test: "Check my setup" ✓
- [ ] Created vault: "Development Secrets"
- [ ] Added test secret
- [ ] Read documentation

## 🎉 Ready to Use!

You're all set! Start using the plugin:

```
In ChatGPT chat:

"List my 1Password vaults"
"Check if my setup is ready"
"Show me all secrets in Development Secrets vault"
"Validate all required secrets exist"
```

## 📞 Quick Support Links

- **Plugin Guide:** `CHATGPT_PLUGIN_GUIDE.md`
- **1Password CLI:** https://developer.1password.com/docs/cli/
- **ChatGPT Help:** https://help.openai.com/
- **GitHub Issues:** https://github.com/shannonjlove/1password-cli-skill/issues

---

**Questions?** See the troubleshooting section above.

**Ready?** Open ChatGPT and ask: **"Check my setup"**
