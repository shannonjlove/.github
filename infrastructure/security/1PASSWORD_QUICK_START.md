# 1Password CLI Quick Start

Secure credential management for your VPS infrastructure.

---

## Installation

```bash
sudo bash /home/user/.github/infrastructure/security/1password-setup.sh
```

## Initial Setup

### 1. Sign In to 1Password

```bash
op signin
# Or with biometric (if available)
op signin --biometric
```

### 2. Create "Infrastructure" Vault

In 1Password desktop or web app:
1. Create new vault named "Infrastructure"
2. Share with server (if organization account)

### 3. Add Your Credentials

**Twilio SMS:**
```
Name: Twilio
Type: Login
Username: your-account-id
Password: [Account SID]
Custom Fields:
  - Auth Token: [your-token]
  - Phone Number: [+1234567890]
  - Recipient Phone: [+1.718.208.3290]
```

**Bookstack API:**
```
Name: Bookstack
Type: Login
Username: admin
Password: [Base URL - http://localhost:8000]
Custom Fields:
  - API Token: [token-id]
  - API Secret: [secret]
```

**Paperless-NGX:**
```
Name: Paperless-NGX
Type: Login
Username: admin
Password: [API Token]
Custom Fields:
  - URL: [http://localhost:8080]
```

**Remote Executor:**
```
Name: Remote Executor
Type: Secure Note
Fields:
  - API URL: [http://72.61.74.250:8813]
  - API Key: [your-api-key]
  - Port: [8813]
```

---

## Using Credentials in Scripts

### Bash Scripts

**Get single secret:**
```bash
ACCOUNT_SID=$(op read "op://Infrastructure/Twilio/Account SID")
```

**Load all Twilio credentials:**
```bash
eval "$(get-twilio-creds)"
# Now use: $TWILIO_ACCOUNT_SID, $TWILIO_AUTH_TOKEN, etc.
```

**Load all credentials:**
```bash
eval "$(load-1password-env)"
```

**In a cron job:**
```bash
0 2 * * * eval "$(load-1password-env)" && /path/to/backup.sh
```

### Python Scripts

```python
import os
import subprocess

# Get credential
result = subprocess.run(
    ['op', 'read', 'op://Infrastructure/Bookstack/API Token'],
    capture_output=True, text=True
)
api_token = result.stdout.strip()

# Use in environment
os.environ['BOOKSTACK_API_TOKEN'] = api_token

# Or in command
import subprocess
subprocess.run(['op', 'run', '--', 'python3', 'my_script.py'])
```

### iOS Scriptable.js

```javascript
async function getSecret(vault, item, field) {
  let cmd = `op read "op://${vault}/${item}/${field}"`;
  let result = await sendVPSCommand(cmd);
  return result.stdout.trim();
}

// Usage
let bookstackToken = await getSecret('Infrastructure', 'Bookstack', 'API Token');
```

---

## Common Commands

### View All Items in Vault
```bash
op item list --vault Infrastructure
```

### View Item Details
```bash
op item get "Twilio" --vault Infrastructure
```

### Create New Item (CLI)
```bash
op item create \
  --vault Infrastructure \
  --title "New Service" \
  --category=login \
  username=admin \
  password="secret123"
```

### Edit Item
```bash
op item edit "Twilio" \
  --vault Infrastructure \
  "Password=new-account-sid"
```

### Get Just One Field
```bash
op read "op://Infrastructure/Twilio/Account SID"
```

### List All Fields in Item
```bash
op item get "Twilio" --vault Infrastructure --format json | jq .fields
```

---

## Integration Examples

### Update Twilio Config from 1Password

Before running setup script:
```bash
eval "$(get-twilio-creds)"
sudo bash /home/user/.github/infrastructure/notification/twilio-sms-config.sh
```

### Run Bookstack Event Logger
```bash
eval "$(get-bookstack-creds)"
python3 /home/user/.github/infrastructure/event-logging/bookstack-event-logger.py \
  "backup" \
  '{"size":"2.4GB"}'
```

### Backup with 1Password Credentials
```bash
#!/bin/bash
# load-creds-and-backup.sh

eval "$(load-1password-env)"

# Now all credentials are in environment
/home/user/.github/infrastructure/backup/backup-to-b2.sh
notify-sms "Backup complete: $BACKUP_SIZE GB"
```

---

## Security Features

✅ **Biometric Authentication** - Unlock with fingerprint/face
✅ **Encrypted Storage** - AES-256 encryption
✅ **Audit Trail** - All access logged in 1Password
✅ **Session Management** - Auto-timeout after inactivity
✅ **No Shell History** - Credentials never saved in bash history
✅ **Secure Sharing** - Share vault with team members
✅ **Recovery Codes** - Access without password if needed

---

## Troubleshooting

### "op: command not found"
```bash
sudo apt-get update && sudo apt-get install -y 1password-cli
```

### "You must sign in to perform this action"
```bash
op signin
# Or clear cached session:
op signout
op signin
```

### "Item not found"
```bash
# Check vault name and item name (case-sensitive)
op item list --vault Infrastructure
```

### "Permission denied" on helper scripts
```bash
sudo chmod +x /usr/local/bin/get-*
sudo chmod +x /usr/local/bin/load-*
```

### SSH Integration Issues
For remote SSH access, you may need to configure agent:
```bash
export OP_SSH_KEYS_POLICY=ignore
ssh -i $(op read op://Infrastructure/SSH\ Key/private\ key) user@host
```

---

## Best Practices

1. **Never Commit Credentials** - Keep `.env` files in .gitignore
2. **Use Vault Sharing** - For team access, share vault not individual secrets
3. **Rotate Regularly** - Update credentials every 90 days
4. **Enable 2FA** - Require second factor for 1Password account
5. **Backup Recovery Code** - Store securely in case of account lockout
6. **Audit Access** - Review 1Password activity logs monthly
7. **Use Specific Permissions** - Don't share admin credentials unnecessarily

---

## Advanced Usage

### Generate Secure Passwords
```bash
op run --env-file=/tmp/env.txt -- openssl rand -base64 32
```

### Backup Vault
```bash
op vault get Infrastructure --format json > ~/backup-vault.json
```

### Monitor for Changes
```bash
op item get "Twilio" --vault Infrastructure --format json | jq '.updated_at'
```

### Integrate with CI/CD
```yaml
# GitHub Actions example
- name: Load credentials
  run: |
    eval "$(op signin --account shannonjlove)"
    export BOOKSTACK_API_TOKEN=$(op read op://Infrastructure/Bookstack/API\ Token)
```

---

## Resources

- **1Password CLI Docs**: https://developer.1password.com/docs/cli/
- **1Password Web**: https://1password.com
- **Recovery**: https://support.1password.com/

---

All credentials now protected, encrypted, and auditable. ✅
