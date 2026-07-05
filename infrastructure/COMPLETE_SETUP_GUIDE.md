# Complete System Setup Guide

Comprehensive guide for Twilio SMS, iOS Shortcuts, Real-time Dashboard, and Bookstack Integration.

---

## Overview

This system provides:
1. **SMS Notifications** - Twilio integration for text alerts
2. **iOS Automation** - Scriptable.app scripts for file management
3. **Real-Time Dashboard** - HTML dashboard with live system metrics
4. **Bookstack Integration** - Automatic logging of all system events

---

## Part 1: Twilio SMS Setup

### Prerequisites
- Twilio account (free trial available)
- API credentials (Account SID, Auth Token, Phone Number)
- Phone number to receive alerts: **+1.718.208.3290**

### Installation

1. **Run setup script:**
```bash
sudo bash /home/user/.github/infrastructure/notification/twilio-sms-config.sh
```

2. **Get Twilio credentials:**
   - Visit https://www.twilio.com/console
   - Sign up for free account
   - Create Project
   - Get: Account SID, Auth Token, Twilio Phone Number

3. **Configure credentials:**
```bash
sudo nano /etc/twilio/config.sh
```

Fill in:
```bash
export TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxx"
export TWILIO_AUTH_TOKEN="your-auth-token"
export TWILIO_PHONE_NUMBER="+1234567890"  # Your Twilio number
export SMS_RECIPIENT="+1.718.208.3290"    # (already set)
```

4. **Test SMS:**
```bash
send-sms "Test message from VPS"
notify-sms "Test notification"
```

### Using SMS in Scripts

**In Python:**
```python
import subprocess
subprocess.run([
    "python3", "/usr/local/bin/send-sms",
    "Backup completed: 2.4GB in 45 minutes"
])
```

**In Bash:**
```bash
notify-sms "System alert: Disk usage at 85%"
```

### Integrate with Existing Scripts

**Update backup script:**
```bash
# After backup completes, send SMS
notify-sms "✅ Backup complete: ${SIZE} GB"
```

**Update log pruning:**
```bash
# After pruning completes
notify-sms "📁 Logs pruned: Freed ${FREED_SPACE} GB"
```

---

## Part 2: iOS Automation (Scriptable.app)

### Prerequisites
- iPhone with iOS 14+
- Scriptable app (download from App Store - free)
- VPS accessible from iPhone (via VPN or public network)

### Installation

1. **Install Scriptable.app:**
   - Open App Store on iPhone
   - Search "Scriptable"
   - Install (free app by Simon B. Støvring)

2. **Add File Management Script:**
   - Open Scriptable
   - Tap "+" (create new script)
   - Copy entire content from: `/home/user/.github/infrastructure/ios-automation/file-management.js`
   - Paste into Scriptable
   - Name it "📁 File Manager"
   - Save

3. **Add PDF to Paperless Script:**
   - Create new script
   - Copy content from: `/home/user/.github/infrastructure/ios-automation/pdf-paperless.js`
   - Name it "📄 PDF → Paperless"
   - Save

4. **Create iOS Shortcut:**
   - Open Apple Shortcuts app
   - Create new shortcut
   - Add "Run Script" action
   - Select "Scriptable" → "📁 File Manager"
   - Add to Home Screen for quick access

### Using iOS Scripts

**File Management:**
- Rename files with auto-date naming
- Add tags and metadata
- Upload to Bookstack
- Send to Paperless-NGX

**PDF Processing:**
- Capture PDF from Files
- Extract text with OCR
- Auto-categorize
- Upload to Paperless-NGX
- Track in Bookstack

### iOS Shortcut Examples

**Quick Upload to Bookstack:**
```
1. Get file from Files app
2. Run Scriptable: "📁 File Manager"
3. Select "📄 Upload to Bookstack"
4. Enter page title
5. Done - logged to Bookstack
```

**PDF to Paperless:**
```
1. Get PDF from Files or Photos
2. Run Scriptable: "📄 PDF → Paperless"
3. Select "📁 Select from Files"
4. Enter metadata
5. Done - scanned and indexed
```

---

## Part 3: Real-Time Dashboard

### Setup

1. **Serve Dashboard:**
```bash
# Simple Python server
cd /home/user/.github/infrastructure/dashboard
python3 -m http.server 8000
```

Or serve from nginx:
```bash
# Copy to nginx
sudo cp index.html /var/www/html/dashboard/
# Access at: http://your-vps-ip/dashboard/
```

2. **Access Dashboard:**
   - From desktop: `http://72.61.74.250:8000`
   - From mobile: `http://72.61.74.250:8000` (same URL on VPN)

### Dashboard Features

**Metrics:**
- Storage usage and capacity
- Last backup time and size
- Files processed today
- System uptime

**Charts:**
- Backup history (7 days)
- File operations trend
- Real-time event log

**Real-Time Updates:**
- Shows events as they happen
- Color-coded by type (success/warning/error)
- Timestamps for all operations

### Customization

Edit `index.html` to:
- Change colors (currently purple gradient)
- Add more metrics
- Adjust refresh interval
- Add custom charts

---

## Part 4: WebSocket Server (Real-Time Events)

### Installation

1. **Install dependencies:**
```bash
pip3 install websockets
```

2. **Create systemd service:**
```bash
sudo nano /etc/systemd/system/realtime-events.service
```

Add:
```ini
[Unit]
Description=Real-Time Events Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /home/user/.github/infrastructure/websocket-server/realtime-events.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

3. **Start service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable realtime-events.service
sudo systemctl start realtime-events.service
```

4. **Verify:**
```bash
sudo systemctl status realtime-events.service
sudo journalctl -u realtime-events.service -f
```

### Publishing Events

**From Python:**
```python
import json
import websockets

async def publish_event(event_type, operation, details, status="success"):
    async with websockets.connect('ws://localhost:9000') as ws:
        await ws.send(json.dumps({
            "type": "event",
            "type": event_type,
            "operation": operation,
            "details": details,
            "status": status
        }))
```

**From Bash:**
```bash
# Publish event via HTTP (would need HTTP endpoint)
curl -X POST http://localhost:9001/event \
  -H "Content-Type: application/json" \
  -d '{"type":"backup","operation":"backup-b2","size":"2.4GB"}'
```

---

## Part 5: Bookstack Integration

### Prerequisites
- Bookstack instance running
- API token and secret
- Access to create shelves/books/pages

### Setup

1. **Get Bookstack Credentials:**
   - Login to Bookstack admin panel
   - Settings → API Tokens
   - Create new token with permissions
   - Copy Token ID and Secret

2. **Configure Event Logger:**
```bash
export BOOKSTACK_URL="http://localhost:8000"
export BOOKSTACK_API_TOKEN="your-token-id"
export BOOKSTACK_API_SECRET="your-token-secret"
```

3. **Test logging:**
```bash
python3 /home/user/.github/infrastructure/event-logging/bookstack-event-logger.py \
  "test-event" \
  '{"message": "Test event from CLI"}'
```

### Bookstack Hierarchy

Events are organized as:
```
Shelf: System Events [Year]
  └─ Book: [Month Year]
    └─ Page: Daily Log [YYYY-MM-DD]
      └─ Events (appended chronologically)
```

**Example:**
```
Shelf: System Events 2026
  └─ Book: January 2026
    └─ Page: Daily Log 2026-01-15
      ├─ [Backup] backup-b2 ✅ SUCCESS (10:30:45)
      ├─ [FileOp] file-upload ✅ SUCCESS (10:35:12)
      └─ [System] log-pruning ✅ SUCCESS (14:00:00)
```

### Event Logging

**Automatic Logging:**
Each operation automatically creates:
- Timestamp with precise time
- Status badge (SUCCESS/FAILURE/WARNING)
- Color-coded sidebar (green/red/yellow)
- Full details in expandable format
- Operation history for month

**Events Logged:**
- ✅ Backup start/completion/failure
- ✅ File uploads/renames/tags
- ✅ System maintenance (log pruning)
- ✅ iOS operations (via Scriptable)
- ✅ Paperless document processing
- ✅ User actions (via dashboard)

---

## Part 6: Complete Integration Setup

### Run Everything

**1. Terminal 1 - Twilio SMS:**
```bash
# SMS is configured, tests automatically notify
send-sms "System startup initiated"
```

**2. Terminal 2 - WebSocket Server:**
```bash
sudo systemctl start realtime-events.service
sudo journalctl -u realtime-events.service -f
```

**3. Terminal 3 - Dashboard:**
```bash
cd /home/user/.github/infrastructure/dashboard
python3 -m http.server 8000
# Access: http://localhost:8000
```

**4. Terminal 4 - Bookstack Event Logger:**
```bash
# Already integrated into scripts
# Monitors /var/log/bookstack-events/
tail -f /var/log/bookstack-events/events-*.log
```

**5. iPhone:**
- Run Scriptable scripts
- Access dashboard at: http://your-vps-ip:8000
- Receive SMS notifications

### Testing Workflow

1. **Test SMS:**
```bash
notify-sms "Testing SMS notifications"
```

2. **Test Dashboard:**
   - Open `http://localhost:8000`
   - Watch real-time updates

3. **Test iOS File Upload:**
   - Run Scriptable "📁 File Manager"
   - Select "📄 Upload to Bookstack"
   - Check Bookstack for new page

4. **Test Event Logging:**
   - Perform any operation
   - Check Bookstack Daily Log page
   - Verify timestamp and details

---

## Part 7: Daily Operations

### Morning Checklist

1. **Check Dashboard:**
   ```bash
   open http://localhost:8000  # Or visit on iPhone
   ```

2. **Review Events in Bookstack:**
   - Visit Bookstack Daily Log
   - Check for any errors or warnings

3. **Monitor SMS Alerts:**
   - Any critical alerts received?
   - Check `/var/log/realtime-events/`

### Monthly Tasks

**After 30 Days:**
1. Archive daily event logs (move old pages to archive section)
2. Generate summary report
3. Delete logs older than 30 days
4. Clean Bookstack (archive old months)

**After 90 Days:**
1. Delete Backblaze backups older than 90 days
2. Archive Bookstack event pages to separate section
3. Generate quarterly report

### Monitoring

**Real-time monitoring:**
```bash
# Watch WebSocket events
journalctl -u realtime-events.service -f

# Watch Bookstack logging
tail -f /var/log/bookstack-events/events-*.log

# Watch system operations
tail -f /var/log/system-cleanup-*.log
```

---

## Troubleshooting

### SMS Not Sending
```bash
# Check configuration
sudo cat /etc/twilio/config.sh

# Test Twilio CLI
twilio api core list-accounts

# Test directly
python3 /usr/local/bin/send-sms "Test"
```

### Dashboard Not Updating
```bash
# Check WebSocket server
sudo systemctl status realtime-events.service

# Check firewall
sudo ufw status
sudo ufw allow 9000/tcp

# Check logs
journalctl -u realtime-events.service
```

### Bookstack Events Not Logging
```bash
# Check API token
export BOOKSTACK_URL="http://localhost:8000"
export BOOKSTACK_API_TOKEN="your-token"
export BOOKSTACK_API_SECRET="your-secret"

# Test directly
python3 /home/user/.github/infrastructure/event-logging/bookstack-event-logger.py \
  "test" \
  '{"msg":"test"}'
```

### iOS Scripts Not Working
```bash
# Check VPS connectivity from iPhone
ping 72.61.74.250

# Check remote executor
curl -X POST \
  -H "Authorization: Bearer YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"command":"whoami"}' \
  http://72.61.74.250:8813/execute

# Check logs in Scriptable console
```

---

## Files Reference

```
infrastructure/
├── notification/
│   ├── twilio-sms-config.sh          # SMS setup
│   └── /usr/local/bin/send-sms       # SMS utility
│
├── ios-automation/
│   ├── file-management.js             # File operations
│   └── pdf-paperless.js               # PDF processing
│
├── event-logging/
│   └── bookstack-event-logger.py      # Event logger
│
├── websocket-server/
│   └── realtime-events.py             # WebSocket server
│
├── dashboard/
│   └── index.html                     # Dashboard UI
│
└── COMPLETE_SETUP_GUIDE.md            # This file

Configuration:
├── /etc/twilio/config.sh              # SMS credentials
├── /etc/systemd/system/realtime-events.service
├── /etc/bookstack/api.conf            # Bookstack API
└── Environment variables in shell profiles

Logs:
├── /var/log/twilio/                   # SMS logs
├── /var/log/bookstack-events/         # Event logs
├── /var/log/realtime-events/          # WebSocket logs
└── journalctl -u realtime-events.service
```

---

## Next Steps

1. ✅ Set up Twilio SMS
2. ✅ Install Scriptable on iPhone
3. ✅ Deploy dashboard HTML
4. ✅ Start WebSocket server
5. ✅ Configure Bookstack API
6. ✅ Test end-to-end workflow
7. ✅ Set up daily monitoring routine
8. ✅ Configure SMS for critical alerts

All systems working? You're ready to fully automate your VPS operations! 🚀
