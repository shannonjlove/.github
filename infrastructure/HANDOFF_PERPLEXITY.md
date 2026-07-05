# Perplexity MCP Filesystem Integration Setup
**For:** Perplexity AI  
**Date:** July 5, 2026  
**VPS Host:** 72.61.74.250:8813

---

## Quick Start

Perplexity can access your VPS filesystem and execute commands through the remote executor MCP service.

### Connection Details

```
Host: 72.61.74.250
Port: 8813
Protocol: HTTP with Bearer Token Authentication
API Key: 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
URL: http://72.61.74.250:8813
```

---

## What Perplexity Can Do

With MCP filesystem access, Perplexity can:

1. **Search VPS Knowledge Base** - Access documentation and logs
2. **Execute Infrastructure Commands** - Run queries on the system
3. **Access Para System** - Query unified code system
4. **Monitor Service Status** - Check health of all platforms
5. **Retrieve System Information** - Get real-time infrastructure metrics

---

## Setup Instructions for Perplexity

### Step 1: Access Perplexity Settings

1. Go to [Perplexity.ai](https://www.perplexity.ai/)
2. Open your profile/settings
3. Navigate to "API & Integrations" or "Custom Tools"

### Step 2: Add Custom HTTP Tool

Create a new custom tool with:

**Basic Info:**
- **Name:** VPS Filesystem Access
- **Description:** Execute commands and read files from VPS infrastructure

**Connection Details:**
- **Endpoint Type:** HTTP REST API
- **Base URL:** `http://72.61.74.250:8813`
- **Authentication Type:** Bearer Token
- **Bearer Token:** `9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687`

**API Methods:**

```json
{
  "methods": [
    {
      "name": "execute_command",
      "method": "POST",
      "path": "/execute",
      "description": "Execute bash commands on VPS",
      "parameters": [
        {
          "name": "command",
          "type": "string",
          "required": true,
          "description": "Command to execute"
        }
      ]
    },
    {
      "name": "read_file",
      "method": "POST",
      "path": "/read",
      "description": "Read file contents",
      "parameters": [
        {
          "name": "path",
          "type": "string",
          "required": true,
          "description": "File path to read"
        }
      ]
    }
  ]
}
```

### Step 3: Test Connection

Ask Perplexity:
> Execute this command: `whoami`

Expected response should show the output from the VPS.

---

## Common Use Cases

### Research Para Codes

**Ask Perplexity:**
> What para codes exist in the system? Execute: `cd /home/user/.github/infrastructure/event-logging && python3 para_system.py daily`

### Check Infrastructure Health

**Ask:**
> Is the remote executor service running? Execute: `systemctl status remote-executor`

### Access Documentation

**Ask:**
> Read and summarize the main infrastructure documentation: `/home/user/.github/infrastructure/HANDOFF.md`

### Find Recent Para Codes

**Ask:**
> List all invoice codes created today: `cd /home/user/.github/infrastructure/event-logging && python3 para_system.py list invoice`

### Monitor Platform Status

**Ask:**
> Check if Bookstack is accessible: `curl -s http://localhost:8000/api/docs | head -20`

---

## Para System Quick Reference

**Format:** YYMMDD-XXXX  
**Storage:** `/var/lib/para-codes/generated-codes.json`

**Example Query:**
```bash
cd /home/user/.github/infrastructure/event-logging
python3 para_system.py info 260705-0001
```

**Categories Available:**
- invoice, receipt, contract, document, backup, file, pdf, general

---

## VPS Directory Structure

```
/home/user/.github/infrastructure/
├── event-logging/           → Para system scripts
├── dashboard/               → Real-time web dashboard
├── websocket-server/        → WebSocket events (port 9000)
├── security/                → 1Password integration
├── notification/            → Twilio SMS gateway
├── HANDOFF.md              → Complete documentation
├── CROSS_PLATFORM_LINKING_SETUP.md
├── PHASE2_TEST_REPORT.md   → Testing status
└── /var/lib/para-codes/    → Code storage
```

---

## Integration Points

**Platforms Linked to Para Codes:**
1. **Bookstack** - http://localhost:8000 (Document wiki)
2. **Craft Docs** - API integration
3. **TickTick** - Task management
4. **Raindrop.io** - Bookmark manager
5. **Paperless-NGX** - http://localhost:8080 (Document management)

**Each para code creates entries across all 5 platforms with bidirectional links.**

---

## Raw API Reference

### Execute Command
```
POST http://72.61.74.250:8813/execute
Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
Content-Type: application/json

{
  "command": "your-command-here"
}
```

### Example Commands

```bash
# Get today's para codes
cd /home/user/.github/infrastructure/event-logging && python3 para_system.py daily

# Generate a new code
python3 para_system.py generate document "My document"

# Check service health
systemctl status remote-executor
journalctl -u remote-executor.service -n 50

# View para code storage
cat /var/lib/para-codes/generated-codes.json

# Check platform sync status
cd /home/user/.github/infrastructure/event-logging && python3 platform_sync_service.py --report
```

---

## Security Considerations

1. **Token Security:** Never commit the token to public repositories
2. **Command Execution:** Runs with elevated privileges - be specific in commands
3. **Data Access:** Full filesystem read/write access to VPS
4. **Logging:** All commands are logged in systemd journal

---

## Troubleshooting

### Tool Not Connecting
- Test directly: `curl -X POST -H "Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687" -H "Content-Type: application/json" -d '{"command":"whoami"}' http://72.61.74.250:8813/execute`
- Check VPS status: Verify IP 72.61.74.250 is reachable

### Timeout Errors
- Try simpler commands first
- Check service logs: `sudo journalctl -u remote-executor.service -f`

### Para Code Issues
- Verify directory exists: `ls -la /var/lib/para-codes/`
- Check Python installation: `python3 --version`

---

## Advanced: Custom Prompting

### For Research Tasks
> Search the VPS documentation for information about [topic]. Commands to try:
> - `grep -r "[keyword]" /home/user/.github/infrastructure/`
> - Read relevant files and summarize

### For System Monitoring
> Generate a health report for the infrastructure. Execute:
> - `systemctl list-units --type=service | grep -E "(remote|sync|bookstack)"`
> - `journalctl -u remote-executor.service --since="1 hour ago" | tail -20`

---

## Documentation Files

| File | Content |
|------|---------|
| HANDOFF.md | Complete system guide |
| CROSS_PLATFORM_LINKING_SETUP.md | Para system details |
| PHASE2_TEST_REPORT.md | Test status and requirements |
| 1PASSWORD_QUICK_START.md | Credential management |
| HANDOFF_GEMINI.md | Gemini setup guide |
| HANDOFF_CHATGPT.md | ChatGPT setup guide |

---

**Ready for Perplexity integration!** 🚀
