#!/bin/bash
# Twilio SMS Configuration Setup
# Installs Twilio CLI and configures SMS notifications

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║   Twilio SMS Notification Setup                    ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run as root"
    exit 1
fi

# ============================================================================
# 1. INSTALL TWILIO CLI
# ============================================================================
echo "Step 1: Installing Twilio CLI..."

if ! command -v twilio &> /dev/null; then
    npm install -g twilio-cli
    echo "✅ Twilio CLI installed"
else
    echo "✅ Twilio CLI already installed"
fi

# ============================================================================
# 2. INSTALL TWILIO PYTHON SDK
# ============================================================================
echo "Step 2: Installing Twilio Python SDK..."

pip3 install twilio || apt-get update && apt-get install -y python3-pip && pip3 install twilio

echo "✅ Twilio Python SDK installed"
echo ""

# ============================================================================
# 3. CREATE CONFIGURATION
# ============================================================================
echo "Step 3: Creating Twilio configuration..."

mkdir -p /etc/twilio
cat > /etc/twilio/config.sh << 'EOF'
# Twilio SMS Configuration
# Get these from https://www.twilio.com/console

export TWILIO_ACCOUNT_SID=""
export TWILIO_AUTH_TOKEN=""
export TWILIO_PHONE_NUMBER=""  # Your Twilio phone number (e.g., +1234567890)
export SMS_RECIPIENT="+1.718.208.3290"  # Destination phone for alerts
EOF

chmod 600 /etc/twilio/config.sh

echo "✅ Configuration file created: /etc/twilio/config.sh"
echo ""

# ============================================================================
# 4. CREATE PYTHON SMS UTILITY
# ============================================================================
echo "Step 4: Creating Python SMS utility..."

cat > /usr/local/bin/send-sms << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
Send SMS via Twilio
Usage: send-sms "Your message here"
"""

import sys
import os
from twilio.rest import Client

# Load configuration
config_file = '/etc/twilio/config.sh'
if os.path.exists(config_file):
    with open(config_file) as f:
        for line in f:
            if line.startswith('export '):
                key, value = line.replace('export ', '').split('=', 1)
                os.environ[key] = value.strip().strip('"')

account_sid = os.getenv('TWILIO_ACCOUNT_SID')
auth_token = os.getenv('TWILIO_AUTH_TOKEN')
from_number = os.getenv('TWILIO_PHONE_NUMBER')
to_number = os.getenv('SMS_RECIPIENT')

if not all([account_sid, auth_token, from_number, to_number]):
    print("ERROR: Twilio credentials not configured")
    print("Edit /etc/twilio/config.sh and add your credentials")
    sys.exit(1)

client = Client(account_sid, auth_token)

message_text = ' '.join(sys.argv[1:]) if len(sys.argv) > 1 else "Test message"

try:
    message = client.messages.create(
        body=message_text,
        from_=from_number,
        to=to_number
    )
    print(f"✅ SMS sent: {message.sid}")
except Exception as e:
    print(f"❌ Error sending SMS: {e}")
    sys.exit(1)
PYTHON_EOF

chmod +x /usr/local/bin/send-sms

echo "✅ SMS utility created: /usr/local/bin/send-sms"
echo ""

# ============================================================================
# 5. CREATE BASH SMS WRAPPER
# ============================================================================
echo "Step 5: Creating Bash SMS wrapper..."

cat > /usr/local/bin/notify-sms << 'BASH_EOF'
#!/bin/bash
# Wrapper for sending SMS notifications from bash scripts

message="$1"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
hostname=$(hostname)

# Format: [HOSTNAME] [TIMESTAMP] Message
formatted_msg="[$hostname] $timestamp: $message"

# Send if SMS is configured
if [ -f /etc/twilio/config.sh ]; then
    source /etc/twilio/config.sh
    if [ -n "$TWILIO_ACCOUNT_SID" ]; then
        send-sms "$formatted_msg" 2>/dev/null || true
    fi
fi
BASH_EOF

chmod +x /usr/local/bin/notify-sms

echo "✅ SMS wrapper created: /usr/local/bin/notify-sms"
echo ""

# ============================================================================
# 6. FINAL INSTRUCTIONS
# ============================================================================
echo "╔════════════════════════════════════════════════════╗"
echo "║          ✅ SETUP COMPLETE - ACTION REQUIRED      ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "To enable SMS notifications:"
echo ""
echo "1. Get Twilio credentials:"
echo "   - Go to https://www.twilio.com/console"
echo "   - Create free account (includes $10 free credit)"
echo "   - Copy: Account SID, Auth Token, Phone Number"
echo ""
echo "2. Configure Twilio:"
echo "   sudo nano /etc/twilio/config.sh"
echo "   Fill in:"
echo "     TWILIO_ACCOUNT_SID=\"your-sid\""
echo "     TWILIO_AUTH_TOKEN=\"your-token\""
echo "     TWILIO_PHONE_NUMBER=\"+1234567890\"  # Twilio's number"
echo "     SMS_RECIPIENT=\"+1.718.208.3290\"    # Already set"
echo ""
echo "3. Test SMS:"
echo "   send-sms \"Test message from VPS\""
echo "   notify-sms \"Test message from bash\""
echo ""
echo "4. Use in scripts:"
echo "   notify-sms \"Backup completed: 2.4GB\""
echo "   notify-sms \"⚠️  High disk usage: 85%\""
echo ""
