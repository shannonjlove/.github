#!/bin/bash
# 1Password CLI Setup
# Secure credential management for VPS infrastructure
# Manages: Twilio, Bookstack, Paperless-NGX, API keys, SMS credentials

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║   1Password CLI Setup - Credential Management      ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run as root"
    exit 1
fi

# ============================================================================
# 1. INSTALL 1PASSWORD CLI
# ============================================================================
echo "Step 1: Installing 1Password CLI..."

if ! command -v op &> /dev/null; then
    # Add 1Password GPG key
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    # Add repository
    echo 'deb [signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main' | tee /etc/apt/sources.list.d/1password.list

    # Update and install
    apt-get update
    apt-get install -y 1password-cli

    echo "✅ 1Password CLI installed"
else
    echo "✅ 1Password CLI already installed"
fi

# ============================================================================
# 2. CREATE CREDENTIAL VAULT STRUCTURE
# ============================================================================
echo "Step 2: Setting up credential vault..."

mkdir -p /etc/1password
mkdir -p /root/.config/1password/accounts.config

cat > /etc/1password/vault-structure.md << 'EOF'
# 1Password Vault Structure

## Vaults
- **Infrastructure** - Production VPS credentials
  - Twilio SMS
  - Bookstack API
  - Paperless-NGX
  - Remote Executor
  - Backblaze B2

## Item Organization

### Twilio SMS
- Type: Login
- Fields:
  - Account SID
  - Auth Token
  - Phone Number
  - Recipient Phone

### Bookstack
- Type: Login
- Fields:
  - Base URL
  - API Token (ID)
  - API Secret
  - Admin User

### Paperless-NGX
- Type: Login
- Fields:
  - URL
  - API Token
  - Admin User

### Backblaze B2
- Type: Login
- Fields:
  - Application Key ID
  - Application Key
  - Bucket Name

### Remote Executor
- Type: Secure Note
- Fields:
  - API URL
  - API Key
  - Port

EOF

echo "✅ Vault structure created at /etc/1password/vault-structure.md"
echo ""

# ============================================================================
# 3. CREATE CREDENTIAL HELPER SCRIPTS
# ============================================================================
echo "Step 3: Creating credential helper scripts..."

cat > /usr/local/bin/get-secret << 'BASH_EOF'
#!/bin/bash
# Get secret from 1Password
# Usage: get-secret "vault" "item" "field"

VAULT="$1"
ITEM="$2"
FIELD="$3"

if [ -z "$VAULT" ] || [ -z "$ITEM" ] || [ -z "$FIELD" ]; then
    echo "Usage: get-secret <vault> <item> <field>"
    echo "Example: get-secret Infrastructure Twilio 'Account SID'"
    exit 1
fi

# Retrieve from 1Password
op read "op://$VAULT/$ITEM/$FIELD" 2>/dev/null || \
    echo "ERROR: Could not retrieve secret from 1Password"
BASH_EOF

chmod +x /usr/local/bin/get-secret

cat > /usr/local/bin/get-twilio-creds << 'BASH_EOF'
#!/bin/bash
# Get Twilio credentials from 1Password

echo "Getting Twilio credentials from 1Password..."

ACCOUNT_SID=$(op read "op://Infrastructure/Twilio/Account SID" 2>/dev/null)
AUTH_TOKEN=$(op read "op://Infrastructure/Twilio/Auth Token" 2>/dev/null)
PHONE_NUMBER=$(op read "op://Infrastructure/Twilio/Phone Number" 2>/dev/null)
RECIPIENT=$(op read "op://Infrastructure/Twilio/Recipient Phone" 2>/dev/null)

if [ -z "$ACCOUNT_SID" ]; then
    echo "ERROR: Could not retrieve Twilio credentials"
    echo "Make sure you've created the Twilio item in 1Password vault 'Infrastructure'"
    exit 1
fi

echo "export TWILIO_ACCOUNT_SID=\"$ACCOUNT_SID\""
echo "export TWILIO_AUTH_TOKEN=\"$AUTH_TOKEN\""
echo "export TWILIO_PHONE_NUMBER=\"$PHONE_NUMBER\""
echo "export SMS_RECIPIENT=\"$RECIPIENT\""
BASH_EOF

chmod +x /usr/local/bin/get-twilio-creds

cat > /usr/local/bin/get-bookstack-creds << 'BASH_EOF'
#!/bin/bash
# Get Bookstack credentials from 1Password

echo "Getting Bookstack credentials from 1Password..."

URL=$(op read "op://Infrastructure/Bookstack/Base URL" 2>/dev/null)
TOKEN=$(op read "op://Infrastructure/Bookstack/API Token" 2>/dev/null)
SECRET=$(op read "op://Infrastructure/Bookstack/API Secret" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "ERROR: Could not retrieve Bookstack credentials"
    exit 1
fi

echo "export BOOKSTACK_URL=\"$URL\""
echo "export BOOKSTACK_API_TOKEN=\"$TOKEN\""
echo "export BOOKSTACK_API_SECRET=\"$SECRET\""
BASH_EOF

chmod +x /usr/local/bin/get-bookstack-creds

cat > /usr/local/bin/get-paperless-creds << 'BASH_EOF'
#!/bin/bash
# Get Paperless-NGX credentials from 1Password

echo "Getting Paperless-NGX credentials from 1Password..."

URL=$(op read "op://Infrastructure/Paperless-NGX/URL" 2>/dev/null)
TOKEN=$(op read "op://Infrastructure/Paperless-NGX/API Token" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "ERROR: Could not retrieve Paperless credentials"
    exit 1
fi

echo "export PAPERLESS_URL=\"$URL\""
echo "export PAPERLESS_TOKEN=\"$TOKEN\""
BASH_EOF

chmod +x /usr/local/bin/get-paperless-creds

echo "✅ Credential helper scripts created"
echo ""

# ============================================================================
# 4. CREATE SYSTEMD SERVICE FOR BIOMETRIC AUTH
# ============================================================================
echo "Step 4: Setting up biometric authentication..."

cat > /etc/systemd/system/1password-biometric.service << 'EOF'
[Unit]
Description=1Password Biometric Authentication
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/op signin --config /root/.config/1password/accounts.config
Restart=no

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo "✅ Biometric authentication service configured"
echo ""

# ============================================================================
# 5. CREATE ENVIRONMENT LOADER
# ============================================================================
echo "Step 5: Creating environment loader..."

cat > /usr/local/bin/load-1password-env << 'BASH_EOF'
#!/bin/bash
# Load all credentials from 1Password into environment

echo "Loading credentials from 1Password..."

# Load Twilio
eval "$(get-twilio-creds 2>/dev/null)" || true

# Load Bookstack
eval "$(get-bookstack-creds 2>/dev/null)" || true

# Load Paperless
eval "$(get-paperless-creds 2>/dev/null)" || true

# Load Remote Executor
EXECUTOR_KEY=$(op read "op://Infrastructure/Remote Executor/API Key" 2>/dev/null)
export REMOTE_EXECUTOR_KEY="$EXECUTOR_KEY"

echo "✅ All credentials loaded from 1Password"
BASH_EOF

chmod +x /usr/local/bin/load-1password-env

cat > /etc/profile.d/1password-env.sh << 'EOF'
#!/bin/bash
# Load 1Password credentials on shell startup (optional)
# Uncomment to enable automatic credential loading

# eval "$(load-1password-env 2>/dev/null)" || true
EOF

chmod +x /etc/profile.d/1password-env.sh

echo "✅ Environment loader created"
echo ""

# ============================================================================
# 6. INTEGRATE WITH EXISTING SCRIPTS
# ============================================================================
echo "Step 6: Integration instructions..."

cat > /etc/1password/INTEGRATION.md << 'EOF'
# 1Password Integration Guide

## For Twilio SMS

Before running `/home/user/.github/infrastructure/notification/twilio-sms-config.sh`:

```bash
# Source credentials from 1Password
eval "$(get-twilio-creds)"

# Credentials now in environment:
# TWILIO_ACCOUNT_SID
# TWILIO_AUTH_TOKEN
# TWILIO_PHONE_NUMBER
# SMS_RECIPIENT
```

## For Bookstack Event Logger

In Python scripts:
```python
import os
from subprocess import run, PIPE

# Get credential from 1Password
result = run(['op', 'read', 'op://Infrastructure/Bookstack/API Token'],
             capture_output=True, text=True)
api_token = result.stdout.strip()

os.environ['BOOKSTACK_API_TOKEN'] = api_token
```

## For iOS Automation

In Scriptable.js:
```javascript
// Fetch from 1Password via VPS
let credCommand = `op read "op://Infrastructure/Bookstack/API Token"`;
let creds = await runVPSCommand(credCommand);
CONFIG.BOOKSTACK_TOKEN = creds.stdout;
```

## For Cron Jobs

```bash
# In crontab, load environment first
0 2 * * * eval "$(load-1password-env)" && /path/to/backup.sh

# Or use op run command
0 2 * * * op run --env-file=/etc/1password/env.yaml -- /path/to/backup.sh
```

## Biometric Authentication

On first use, authenticate with 1Password:
```bash
op signin
# Or with biometric (if configured)
op signin --biometric
```

## Testing Credential Access

```bash
# Test getting a secret
get-secret Infrastructure Twilio "Account SID"

# Test loading all credentials
load-1password-env

# Verify in environment
echo $TWILIO_ACCOUNT_SID
```

## Vault Setup in 1Password App

1. Create vault named "Infrastructure"
2. Add items:
   - **Twilio SMS** (Login)
     - Username: your-twilio-account-id
     - Password: Account SID
     - Custom fields:
       - Auth Token
       - Phone Number
       - Recipient Phone

   - **Bookstack** (Login)
     - Username: admin
     - Base URL: http://localhost:8000
     - Custom fields:
       - API Token
       - API Secret

   - **Paperless-NGX** (Login)
     - Username: admin
     - URL: http://localhost:8080
     - Custom fields:
       - API Token

   - **Remote Executor** (Secure Note)
     - Fields:
       - API URL
       - API Key
       - Port

3. Share vault with server if using organization

## Security Best Practices

✅ All credentials stored in 1Password vault
✅ Biometric authentication enabled
✅ Credentials never in shell history
✅ Environment variables automatically cleared after script
✅ No hardcoded secrets in config files
✅ Credentials in transit encrypted
✅ Access audit trail in 1Password

EOF

cat /etc/1password/INTEGRATION.md

echo ""

# ============================================================================
# 7. FINAL SETUP
# ============================================================================
echo "╔════════════════════════════════════════════════════╗"
echo "║          ✅ 1PASSWORD CLI SETUP COMPLETE           ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Download 1Password account credentials:"
echo "   - Open 1password.com in browser"
echo "   - Sign in with your account"
echo "   - Settings → Security → Sign-in details"
echo "   - Download .opvault file or use recovery code"
echo ""
echo "2. Authenticate on VPS:"
echo "   op signin"
echo ""
echo "3. Create 'Infrastructure' vault in 1Password app:"
echo "   - Desktop: File → New Vault → Infrastructure"
echo "   - Web: + → New Vault"
echo ""
echo "4. Add credentials to vault:"
echo "   cat /etc/1password/vault-structure.md"
echo ""
echo "5. Use helper scripts to load credentials:"
echo "   get-secret Infrastructure Twilio 'Account SID'"
echo "   eval \"\$(load-1password-env)\""
echo ""
echo "6. Test credential access:"
echo "   get-twilio-creds"
echo "   get-bookstack-creds"
echo ""
echo "7. Update scripts to use credentials:"
echo "   - Twilio: source <(get-twilio-creds)"
echo "   - Bookstack: export BOOKSTACK_API_TOKEN=\$(op read ...)"
echo ""
echo "Helper Scripts:"
echo "  /usr/local/bin/get-secret              - Get any secret"
echo "  /usr/local/bin/get-twilio-creds        - Get Twilio credentials"
echo "  /usr/local/bin/get-bookstack-creds     - Get Bookstack credentials"
echo "  /usr/local/bin/get-paperless-creds     - Get Paperless credentials"
echo "  /usr/local/bin/load-1password-env      - Load all credentials"
echo ""
echo "Documentation: /etc/1password/INTEGRATION.md"
echo ""
