# 1Password CLI Quick Start Guide
**Purpose:** Secure credential management for VPS infrastructure  
**Version:** 2.x (latest)  
**Date:** July 5, 2026

---

## Official Links

### Installation
- **1Password CLI Home:** https://developer.1password.com/docs/cli/
- **Download:** https://1password.com/downloads/command-line/
- **GitHub Releases:** https://github.com/1Password/op-js/releases

### Documentation
- **Full Documentation:** https://developer.1password.com/docs/cli/get-started/
- **Reference Guide:** https://developer.1password.com/docs/cli/reference/
- **Troubleshooting:** https://developer.1password.com/docs/cli/troubleshooting/

### API Integration
- **1Password API:** https://developer.1password.com/docs/integrations/
- **Service Account Setup:** https://developer.1password.com/docs/service-accounts/

---

## Installation

### macOS
```bash
# Using Homebrew (recommended)
brew install 1password-cli

# Or download directly
curl https://cache.agilebits.com/download/OPM7/MAC/1password-cli-latest.zip -o op.zip
unzip op.zip
sudo mv op /usr/local/bin
sudo chmod +x /usr/local/bin/op
```

### Linux (Ubuntu/Debian)
```bash
# Add 1Password repository
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(lsb_release -cs) stable main" | sudo tee /etc/apt/sources.list.d/1password.list

# Install
sudo apt update
sudo apt install 1password-cli
```

### Linux (RHEL/CentOS/Fedora)
```bash
sudo dnf install 1password-cli
```

### Windows
```powershell
# Using Chocolatey
choco install 1password-cli

# Or using Scoop
scoop install 1password
```

---

## Initial Setup

### Step 1: Sign In
```bash
op signin --account example.1password.com --email you@example.com --password
```

**What you need:**
- Account URL (from 1Password app)
- Email address
- Master password
- Sign-in code (from 1Password app)

### Step 2: Verify Installation
```bash
op --version
op whoami
```

**Expected output:**
```
op 2.x.x
example.1password.com
you@example.com
```

### Step 3: Configure Shell (Optional but Recommended)
```bash
# Add to ~/.bash_profile or ~/.zshrc
eval "$(op completion bash)"  # for bash
eval "$(op completion zsh)"   # for zsh
```

---

## Create Infrastructure Vault

### Method 1: Using 1Password App
1. Open 1Password on your computer
2. Click "+" button to create vault
3. Name it: "Infrastructure"
4. Set description: "VPS infrastructure credentials and API keys"
5. Save

### Method 2: Using CLI
```bash
# First, get your vault ID
op vault list

# Create vault
op vault create --name Infrastructure --description "VPS infrastructure credentials"
```

---

## Add Credentials to Vault

### Template for Required Items

Create these items in the "Infrastructure" vault:

**1. Twilio**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Twilio" \
  account_sid=your-sid \
  auth_token=your-token \
  phone_number=+1234567890 \
  recipient=+1718208290
```

**2. Bookstack**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Bookstack" \
  base_url=http://localhost:8000 \
  api_token=your-token \
  api_secret=your-secret
```

**3. Paperless-NGX**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Paperless-NGX" \
  url=http://localhost:8080 \
  api_token=your-token
```

**4. Craft Docs**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Craft Docs" \
  api_token=your-token \
  user_id=your-user-id
```

**5. TickTick**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "TickTick" \
  api_token=your-token
```

**6. Raindrop.io**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Raindrop.io" \
  api_token=your-token
```

**7. Remote Executor**
```bash
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Remote Executor" \
  host=72.61.74.250 \
  port=8813 \
  api_key=9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
```

---

## Load Credentials in Scripts

### Method 1: Individual Fields
```bash
# Get a specific field
BOOKSTACK_TOKEN=$(op item get Bookstack --field api_token --vault Infrastructure)
export BOOKSTACK_TOKEN

# Use in Python
os.getenv("BOOKSTACK_TOKEN")
```

### Method 2: Create Helper Functions
Add to your `.bashrc` or `.zshrc`:

```bash
# Load Twilio credentials
get-twilio-creds() {
  eval "$(op item get Twilio --vault Infrastructure --format=json | \
    jq -r '.fields[] | "export TWILIO_\(.label|ascii_upcase)=\(.value)"')"
}

# Load Bookstack credentials
get-bookstack-creds() {
  eval "$(op item get Bookstack --vault Infrastructure --format=json | \
    jq -r '.fields[] | "export BOOKSTACK_\(.label|ascii_upcase)=\(.value)"')"
}

# Load Paperless credentials
get-paperless-creds() {
  eval "$(op item get Paperless-NGX --vault Infrastructure --format=json | \
    jq -r '.fields[] | "export PAPERLESS_\(.label|ascii_upcase)=\(.value)"')"
}

# Load all credentials at once
load-1password-env() {
  get-twilio-creds
  get-bookstack-creds
  get-paperless-creds
  export CRAFT_API_TOKEN=$(op item get "Craft Docs" --field api_token --vault Infrastructure)
  export TICKTICK_API_TOKEN=$(op item get TickTick --field api_token --vault Infrastructure)
  export RAINDROP_API_TOKEN=$(op item get Raindrop.io --field api_token --vault Infrastructure)
}
```

### Method 3: Direct Environment Variable
```bash
# Set all at once
export $(op item get Bookstack --vault Infrastructure --format=json | \
  jq -r '.fields[] | "BOOKSTACK_\(.label|ascii_upcase)=\(.value)"')
```

---

## Common Commands

### List Items
```bash
# List all items in Infrastructure vault
op item list --vault Infrastructure

# Get specific item
op item get Bookstack --vault Infrastructure
```

### View Fields
```bash
# Show all fields of an item
op item get Bookstack --vault Infrastructure --format json | jq '.fields'

# Get specific field
op item get Bookstack --vault Infrastructure --field api_token
```

### Edit Items
```bash
# Edit an item (opens editor)
op item edit Bookstack --vault Infrastructure

# Update a field
op item edit Bookstack --vault Infrastructure api_token=new-value
```

### Copy to Clipboard
```bash
# Copy API token to clipboard
op item get Bookstack --vault Infrastructure --field api_token --copy
```

---

## In Python Scripts

### Simple Usage
```python
import os
import subprocess
import json

# Load credentials
def get_credential(service, field):
    cmd = f'op item get {service} --vault Infrastructure --field {field}'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

# Use it
bookstack_token = get_credential("Bookstack", "api_token")
bookstack_url = get_credential("Bookstack", "base_url")
```

### Advanced Usage with JSON
```python
import json
import subprocess

def load_1password_item(service):
    cmd = f'op item get {service} --vault Infrastructure --format=json'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return json.loads(result.stdout)

# Use it
bookstack = load_1password_item("Bookstack")
for field in bookstack['fields']:
    print(f"{field['label']}: {field['value']}")
```

---

## Service Account Setup (Advanced)

For CI/CD or unattended access:

1. Go to **1Password admin console:** https://start.1password.com/
2. Navigate to **Integrations → Service Accounts**
3. Click **Create Service Account**
4. Set name: "VPS Infrastructure"
5. Grant access to "Infrastructure" vault
6. Save the token securely
7. Use in environment variables:

```bash
export OP_SERVICE_ACCOUNT_TOKEN="your-service-account-token"
op item list --vault Infrastructure
```

---

## Troubleshooting

### "Session expired" error
```bash
op signin --account example.1password.com
# Re-enter credentials
```

### "Vault not found" error
```bash
# List available vaults
op vault list

# Make sure vault name is exactly "Infrastructure"
```

### Permission denied error
```bash
# Ensure user has access to vault
# In 1Password app: Settings → Team Management → Vault Access
```

### jq not installed error
```bash
# Install jq first
brew install jq          # macOS
sudo apt install jq      # Linux
choco install jq         # Windows
```

---

## Environment Setup for VPS

### Add to ~/.bashrc or ~/.zshrc
```bash
# Load 1Password credentials on demand
alias load-infra='eval "$(op item get "Infrastructure" --vault Infrastructure --format=json | jq -r ".fields[] | \"export \(.label|ascii_upcase)=\(.value)\"")"'

# Quick access to services
alias get-twilio='op item get Twilio --vault Infrastructure'
alias get-bookstack='op item get Bookstack --vault Infrastructure'
alias get-paperless='op item get Paperless-NGX --vault Infrastructure'

# Load all at startup (optional)
# load-1password-env
```

### Or with a Script
Create `/usr/local/bin/load-1password-env`:
```bash
#!/bin/bash
export TWILIO_ACCOUNT_SID=$(op item get Twilio --vault Infrastructure --field account_sid)
export TWILIO_AUTH_TOKEN=$(op item get Twilio --vault Infrastructure --field auth_token)
export BOOKSTACK_URL=$(op item get Bookstack --vault Infrastructure --field base_url)
export BOOKSTACK_API_TOKEN=$(op item get Bookstack --vault Infrastructure --field api_token)
export BOOKSTACK_API_SECRET=$(op item get Bookstack --vault Infrastructure --field api_secret)
export PAPERLESS_URL=$(op item get Paperless-NGX --vault Infrastructure --field url)
export PAPERLESS_TOKEN=$(op item get Paperless-NGX --vault Infrastructure --field api_token)
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/load-1password-env
```

Use it:
```bash
source load-1password-env
echo $BOOKSTACK_URL
```

---

## Security Best Practices

1. **Keep Master Password Safe**
   - Don't share your master password
   - Use a strong, unique password
   - Store recovery codes securely

2. **API Tokens in 1Password**
   - Never commit tokens to git
   - Never put in environment files
   - Always load from 1Password

3. **CLI Session Management**
   - Sessions expire for security
   - Re-authenticate when needed
   - Log out on shared machines

4. **Service Account Tokens**
   - Rotate regularly
   - Grant minimal permissions
   - Monitor access logs

5. **Audit Access**
   - Check 1Password activity log
   - Review vault sharing settings
   - Remove access when not needed

---

## Next Steps

1. **Install 1Password CLI**
   ```bash
   brew install 1password-cli
   ```

2. **Sign In**
   ```bash
   op signin
   ```

3. **Create Infrastructure Vault**
   - In 1Password app or CLI

4. **Add Your Credentials**
   - Copy each item template from above
   - Replace with your actual tokens

5. **Test Access**
   ```bash
   op item get Bookstack --vault Infrastructure
   ```

6. **Use in Scripts**
   ```bash
   eval "$(op completion bash)"
   source load-1password-env
   ```

---

## Resources

| Resource | Link |
|----------|------|
| Official 1Password CLI | https://developer.1password.com/docs/cli/ |
| Installation Guide | https://developer.1password.com/docs/cli/get-started/ |
| CLI Reference | https://developer.1password.com/docs/cli/reference/ |
| GitHub Releases | https://github.com/1Password/op-js/releases |
| Troubleshooting | https://developer.1password.com/docs/cli/troubleshooting/ |
| Service Accounts | https://developer.1password.com/docs/service-accounts/ |

---

**Ready to secure your credentials!** 🔐

Once set up, use `load-1password-env` in your scripts to access all platform credentials safely.
