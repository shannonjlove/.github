# Gemini MCP Filesystem Integration Setup
**For:** Google Gemini  
**Date:** July 5, 2026  
**VPS Host:** 72.61.74.250:8813

---

## Quick Start

Gemini can access your VPS filesystem and execute commands through the remote executor MCP service.

### Connection Details

```
Host: 72.61.74.250
Port: 8813
Protocol: HTTP with Bearer Token Authentication
API Key: 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
URL: http://72.61.74.250:8813
```

---

## What Gemini Can Do

With MCP filesystem access, Gemini can:

1. **Read Files** - Access any file on the VPS
2. **Execute Commands** - Run bash commands directly
3. **Generate Para Codes** - Create YYMMDD-XXXX codes for documents
4. **Query Para System** - Look up existing codes and their platforms
5. **Monitor Infrastructure** - Check service status, logs, and health

---

## Setup Instructions for Gemini

### Option 1: Google AI Studio (Simple)

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Create a new project
3. In project settings, add custom tools/APIs
4. Configure HTTP endpoint:
   - **Endpoint:** `http://72.61.74.250:8813`
   - **Auth Type:** Bearer Token
   - **Token:** `9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687`

### Option 2: Google Cloud Vertex AI (Production)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Vertex AI API
3. Create service account with HTTP API access permissions
4. Add custom tool:
   ```
   {
     "type": "function",
     "function": {
       "name": "vps_executor",
       "description": "Execute commands on remote VPS",
       "parameters": {
         "type": "object",
         "properties": {
           "command": {
             "type": "string",
             "description": "Command to execute"
           }
         },
         "required": ["command"]
       }
     }
   }
   ```
5. Configure backend:
   - **URL:** `http://72.61.74.250:8813/execute`
   - **Method:** POST
   - **Headers:** `Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687`

---

## Common Tasks

### Generate a Para Code

**Prompt to Gemini:**
> Execute this command: `cd /home/user/.github/infrastructure/event-logging && python3 para_system.py generate invoice "My invoice description"`

**Expected Response:** 
```
Generated: 260705-XXXX
```

### List Para Codes by Category

**Prompt:**
> Execute: `cd /home/user/.github/infrastructure/event-logging && python3 para_system.py list invoice`

### Get Infrastructure Status

**Prompt:**
> Check if the remote executor is running: `systemctl status remote-executor`

### Read a File

**Prompt:**
> Read the file `/home/user/.github/infrastructure/HANDOFF.md`

---

## Para System Reference

The VPS uses a unified para code system across 5 platforms:

**Format:** YYMMDD-XXXX  
**Example:** 260705-0001 (First item created July 5, 2026)

**Categories:**
- invoice
- receipt
- contract
- document
- backup
- file
- pdf
- general

**Storage:** `/var/lib/para-codes/generated-codes.json`

**Platforms Linked:**
1. Bookstack (http://localhost:8000)
2. Craft Docs
3. TickTick
4. Raindrop.io
5. Paperless-NGX (http://localhost:8080)

---

## File Locations on VPS

```
/home/user/.github/infrastructure/
├── event-logging/
│   ├── para_system.py           # Code generation
│   ├── cross_platform_linker.py # Platform linking
│   ├── paperless_para_system.py # Paperless integration
│   ├── platform_sync_service.py # Sync daemon
│   └── bookstack_event_logger.py
├── dashboard/
│   └── index.html               # Real-time dashboard
├── websocket-server/
│   └── realtime-events.py       # WebSocket on port 9000
├── security/
│   ├── 1password-setup.sh
│   └── 1PASSWORD_QUICK_START.md
├── notification/
│   └── twilio-sms-config.sh
├── HANDOFF.md                   # Main documentation
└── CROSS_PLATFORM_LINKING_SETUP.md
```

---

## API Endpoints

### Execute Command
```
POST http://72.61.74.250:8813/execute
Headers:
  Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
  Content-Type: application/json

Body:
{
  "command": "ls -la /home/user/.github/infrastructure/"
}
```

### Test Connection
```bash
curl -X POST \
  -H "Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687" \
  -H "Content-Type: application/json" \
  -d '{"command":"whoami"}' \
  http://72.61.74.250:8813/execute
```

---

## Security Notes

1. **Bearer Token is sensitive** - Do not share in logs or public code
2. **Commands execute as root** - Be careful with destructive operations
3. **No command output limit** - Large responses may timeout
4. **File system is full access** - Can read/write anywhere on VPS

---

## Troubleshooting

### Connection refused
- Verify VPS is online: `ping 72.61.74.250`
- Check if port 8813 is open: `curl http://72.61.74.250:8813`

### Authentication failed
- Verify token: `9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687`
- Check Bearer token format in header

### Command timeout
- Try simpler commands first
- Check if service is running: `systemctl status remote-executor`

### Para code not found
- Verify directory: `cd /home/user/.github/infrastructure/event-logging`
- Check code exists: `python3 para_system.py list all`

---

## Documentation References

| Document | Purpose |
|----------|---------|
| HANDOFF.md | Complete system documentation |
| CROSS_PLATFORM_LINKING_SETUP.md | Para system and linking details |
| PHASE2_TEST_REPORT.md | Testing progress and requirements |
| 1PASSWORD_QUICK_START.md | Credential management |

---

## Support

For issues or questions:
- Check the VPS logs: `sudo journalctl -u remote-executor.service -f`
- Review infrastructure status: `/home/user/.github/infrastructure/`
- Reference main handoff: `/home/user/.github/infrastructure/HANDOFF.md`

---

**Ready for Gemini integration!** 🚀
