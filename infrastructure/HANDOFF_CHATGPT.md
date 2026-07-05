# ChatGPT MCP Filesystem Integration Setup
**For:** OpenAI ChatGPT / GPT-4  
**Date:** July 5, 2026  
**VPS Host:** 72.61.74.250:8813

---

## Quick Start

ChatGPT can access your VPS filesystem and execute commands through the remote executor MCP service using the custom actions feature.

### Connection Details

```
Host: 72.61.74.250
Port: 8813
Protocol: HTTP with Bearer Token Authentication
API Key: 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
URL: http://72.61.74.250:8813
```

---

## What ChatGPT Can Do

With MCP filesystem access, ChatGPT can:

1. **Execute VPS Commands** - Run bash commands directly
2. **Read Files** - Access documentation and logs
3. **Generate Para Codes** - Create YYMMDD-XXXX codes
4. **Query Infrastructure** - Check system status and metrics
5. **Provide Real-time Information** - Access live data from VPS

---

## Setup Instructions for ChatGPT

### Option 1: ChatGPT Web (Custom GPT)

1. Go to [ChatGPT](https://chatgpt.com/) and log in
2. Click on your profile → "My GPTs"
3. Click "Create a GPT"
4. Name it: "VPS Infrastructure Assistant"
5. In the configuration, add actions:

**Action 1: Execute Command**
```json
{
  "type": "openapi",
  "auth": {
    "type": "bearer",
    "token": "9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687"
  },
  "servers": [
    {
      "url": "http://72.61.74.250:8813"
    }
  ],
  "paths": {
    "/execute": {
      "post": {
        "operationId": "executeCommand",
        "summary": "Execute a command on the VPS",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "command": {
                    "type": "string",
                    "description": "The bash command to execute"
                  }
                },
                "required": ["command"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Command executed successfully"
          }
        }
      }
    }
  }
}
```

### Option 2: OpenAI API Integration (Developers)

**Prerequisites:**
- OpenAI API key with GPT-4 or later
- Python client library: `pip install openai`

**Setup Code:**
```python
from openai import OpenAI

client = OpenAI(api_key="your-openai-api-key")

# Define the VPS tool
vps_tool = {
    "type": "function",
    "function": {
        "name": "execute_vps_command",
        "description": "Execute commands on the remote VPS at 72.61.74.250:8813",
        "parameters": {
            "type": "object",
            "properties": {
                "command": {
                    "type": "string",
                    "description": "The command to execute on VPS"
                }
            },
            "required": ["command"]
        }
    }
}

# Use in chat
response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {
            "role": "user",
            "content": "What para codes exist in the system?"
        }
    ],
    tools=[vps_tool]
)
```

**Function Implementation:**
```python
import requests

def execute_vps_command(command: str) -> str:
    headers = {
        "Authorization": "Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687",
        "Content-Type": "application/json"
    }
    response = requests.post(
        "http://72.61.74.250:8813/execute",
        json={"command": command},
        headers=headers
    )
    return response.json().get("output", "No output")
```

---

## Common ChatGPT Prompts

### Get Infrastructure Status
> Check the status of the remote executor service and report back. Execute: `systemctl status remote-executor`

### List Today's Para Codes
> What para codes were created today? Execute: `cd /home/user/.github/infrastructure/event-logging && python3 para_system.py daily`

### Generate New Para Code
> Create a new para code for an invoice. Execute: `cd /home/user/.github/infrastructure/event-logging && python3 para_system.py generate invoice "New vendor invoice"`

### Read Documentation
> Read and summarize the main infrastructure handoff: `/home/user/.github/infrastructure/HANDOFF.md`

### Check Platform Sync
> How is the platform synchronization status? Execute: `cd /home/user/.github/infrastructure/event-logging && python3 platform_sync_service.py --report`

### Monitor Logs
> Show recent activity from the remote executor. Execute: `sudo journalctl -u remote-executor.service -n 50 --no-pager`

---

## Para System Details

**Code Format:** YYMMDD-XXXX (e.g., 260705-0001)
- YY = Year (26 = 2026)
- MM = Month (07 = July)
- DD = Day (05 = 5th)
- XXXX = Sequential counter (0001, 0002, etc.)

**Categories:**
```
invoice, receipt, contract, document, backup, file, pdf, general
```

**Query Examples:**
```bash
# List all invoices
python3 para_system.py list invoice

# Get specific code info
python3 para_system.py info 260705-0001

# Generate new code
python3 para_system.py generate category "Description"

# Get today's codes
python3 para_system.py daily
```

---

## VPS Architecture

```
Remote Executor (MCP)
    ↓ (HTTP Bearer Token)
72.61.74.250:8813
    ↓
/home/user/.github/infrastructure/
    ├── event-logging/
    │   ├── para_system.py           ← Para code generation
    │   ├── cross_platform_linker.py ← 5-platform linking
    │   ├── paperless_para_system.py ← Paperless integration
    │   ├── platform_sync_service.py ← Sync daemon
    │   └── bookstack_event_logger.py
    ├── dashboard/
    │   └── index.html               ← Real-time UI (port 9000)
    ├── security/
    │   └── 1password-setup.sh       ← Credential management
    └── HANDOFF*.md                  ← Documentation
```

---

## Linked Platforms

Your para codes automatically link across 5 platforms:

1. **Bookstack** - http://localhost:8000
   - Wiki/documentation platform
   - Para code in page title + HTML links section

2. **Craft Docs**
   - Note-taking and writing
   - Para code in metadata + markdown links

3. **TickTick**
   - Task management
   - Para code in task title + description links

4. **Raindrop.io**
   - Bookmark and collection manager
   - Para code in title + description

5. **Paperless-NGX** - http://localhost:8080
   - Document management
   - Para code as tags + correspondent + document type

---

## API Reference

### Execute Command

**Endpoint:** `POST http://72.61.74.250:8813/execute`

**Headers:**
```
Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
Content-Type: application/json
```

**Request Body:**
```json
{
  "command": "cd /home/user/.github/infrastructure/event-logging && python3 para_system.py generate test 'Test item'"
}
```

**Response:**
```json
{
  "status": "success",
  "output": "Generated: 260705-0001",
  "exit_code": 0
}
```

### Test Connection (curl)
```bash
curl -X POST \
  -H "Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687" \
  -H "Content-Type: application/json" \
  -d '{"command":"whoami"}' \
  http://72.61.74.250:8813/execute
```

---

## Security Best Practices

1. **Bearer Token Confidentiality**
   - Never expose in logs or error messages
   - Don't include in code commits
   - Use environment variables in production

2. **Command Safety**
   - ChatGPT has root-level access
   - Avoid destructive commands (rm, dd, etc.)
   - Commands are logged in systemd journal

3. **Rate Limiting**
   - Keep commands focused and efficient
   - Timeout after 30 seconds for hung commands

---

## Troubleshooting

### Connection Error
**Test:** 
```bash
curl http://72.61.74.250:8813/
```
**If fails:** VPS may be unreachable or port blocked

### Authentication Failed
- Verify Bearer token is exactly: `9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687`
- Check header format: `Authorization: Bearer <token>`

### Command Timeout
- Service may be overloaded
- Try: `systemctl status remote-executor`
- Check logs: `journalctl -u remote-executor.service -f`

### Para Code Issues
- Verify Python is installed: `python3 --version`
- Check directory: `cd /home/user/.github/infrastructure/event-logging && ls -la`

---

## Documentation References

| Document | Purpose |
|----------|---------|
| **HANDOFF.md** | Complete system documentation and roadmap |
| **CROSS_PLATFORM_LINKING_SETUP.md** | Para system and 5-platform linking details |
| **PHASE2_TEST_REPORT.md** | Current testing status and requirements |
| **1PASSWORD_QUICK_START.md** | Credential and vault management |
| **HANDOFF_GEMINI.md** | Gemini integration setup |
| **HANDOFF_PERPLEXITY.md** | Perplexity integration setup |

---

## Advanced Usage

### Create System Monitoring GPT

Create a custom GPT that:
1. Monitors infrastructure health daily
2. Generates reports on para code usage
3. Alerts if services are down
4. Suggests optimization based on logs

**Prompt Template:**
```
You are an infrastructure monitoring assistant with access to a VPS at 72.61.74.250:8813.

Daily, check:
1. Remote executor service status
2. Total para codes generated (this month, today)
3. Platform sync status
4. Recent errors in logs
5. Disk space and resource usage

Generate a daily report and recommend actions if needed.
```

### Create Documentation Bot

Create a GPT that answers questions about:
- How to generate para codes
- Which platform codes are synced to
- System architecture and components
- Setup procedures for new platforms

---

## Getting Help

1. **Check VPS Logs:** `sudo journalctl -u remote-executor.service -f`
2. **Review Main Documentation:** `/home/user/.github/infrastructure/HANDOFF.md`
3. **Test API Directly:** Use curl to test connection
4. **System Status:** `systemctl status remote-executor`

---

**Ready for ChatGPT integration!** 🚀

For questions or integration help, reference the main HANDOFF.md and CROSS_PLATFORM_LINKING_SETUP.md documents.
