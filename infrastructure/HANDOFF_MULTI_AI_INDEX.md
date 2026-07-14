# Multi-AI Integration Index
**Central Hub for AI Model Access to VPS Infrastructure**  
**Date:** July 5, 2026

---

## Overview

Your VPS infrastructure at **72.61.74.250:8813** provides MCP (Model Context Protocol) filesystem access for multiple AI models. Each AI can execute commands, read files, and interact with your para system independently.

---

## AI Integration Guides

### 🤖 Claude (Anthropic)
**Status:** ✅ Active and Operational

**Setup:** Already configured in `.claude/mcp.json`
- **Host:** 72.61.74.250:8813
- **Auth:** Bearer Token (see credentials below)
- **Access:** Full filesystem and command execution

**Documentation:** Review `HANDOFF.md` for complete system details

---

### 🔍 Perplexity AI
**Status:** 📋 Ready for Setup

**Purpose:** Research-focused access to VPS knowledge base

**Setup Guide:** See `HANDOFF_PERPLEXITY.md`

**Key Capabilities:**
- Search VPS documentation and logs
- Query para system for codes
- Monitor infrastructure health
- Retrieve historical data

**Quick Start:**
1. Go to Perplexity.ai settings
2. Add custom HTTP tool
3. Configure endpoint and Bearer token (see below)

---

### 🤖 Gemini (Google)
**Status:** 📋 Ready for Setup

**Purpose:** Command execution and infrastructure automation

**Setup Guide:** See `HANDOFF_GEMINI.md`

**Key Capabilities:**
- Direct command execution
- File read/write operations
- Generate para codes
- Monitor service status

**Quick Start:**
1. Access Google AI Studio or Vertex AI
2. Create custom tool/function
3. Configure HTTP endpoint
4. Use Bearer token authentication

---

### 💬 ChatGPT (OpenAI)
**Status:** 📋 Ready for Setup

**Purpose:** Multi-purpose VPS assistant with advanced reasoning

**Setup Guide:** See `HANDOFF_CHATGPT.md`

**Key Capabilities:**
- Execute commands with reasoning
- Complex infrastructure tasks
- Report generation
- System monitoring and alerts

**Quick Start:**
1. Go to ChatGPT custom GPTs or API
2. Add function tool
3. Configure VPS endpoint
4. Start with prompts (see guide for examples)

---

## Shared Credentials & Configuration

### Connection Details (All AIs)

```
Host:        72.61.74.250
Port:        8813
Protocol:    HTTP
Auth Type:   Bearer Token
Endpoint:    http://72.61.74.250:8813/execute

Bearer Token:
9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
```

### API Endpoint Format

All models use the same endpoint:

**POST** `http://72.61.74.250:8813/execute`

**Headers:**
```
Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687
Content-Type: application/json
```

**Body:**
```json
{
  "command": "your-bash-command-here"
}
```

---

## Para System Access (All Models)

All AI models can interact with the para code system:

**Generate Para Code:**
```bash
cd /home/user/.github/infrastructure/event-logging && python3 para_system.py generate <category> "<description>"
```

**Query Para Code:**
```bash
cd /home/user/.github/infrastructure/event-logging && python3 para_system.py info <code>
```

**List by Category:**
```bash
python3 para_system.py list <category>
```

**Get Today's Codes:**
```bash
python3 para_system.py daily
```

---

## File Structure for References

```
/home/user/.github/infrastructure/

DOCUMENTATION FILES:
├── HANDOFF.md                          ← Main system documentation
├── HANDOFF_MULTI_AI_INDEX.md           ← This file (central hub)
├── HANDOFF_CLAUDE.md                   ← Claude/Claude Code specific
├── HANDOFF_GEMINI.md                   ← Gemini setup guide
├── HANDOFF_PERPLEXITY.md               ← Perplexity setup guide
├── HANDOFF_CHATGPT.md                  ← ChatGPT setup guide
├── CROSS_PLATFORM_LINKING_SETUP.md     ← Para system details
├── PHASE2_TEST_REPORT.md               ← Testing status
└── 1PASSWORD_QUICK_START.md            ← Credential management

INFRASTRUCTURE DIRECTORIES:
├── event-logging/
│   ├── para_system.py
│   ├── cross_platform_linker.py
│   ├── paperless_para_system.py
│   ├── platform_sync_service.py
│   └── bookstack_event_logger.py
├── dashboard/
├── websocket-server/
├── security/
└── notification/

STORAGE:
└── /var/lib/para-codes/
    └── generated-codes.json
```

---

## Quick Reference by AI Model

### For Claude Code
```
File: .claude/mcp.json
Status: ✅ Active
Action: Just start using it!
```

### For Gemini
```
File: HANDOFF_GEMINI.md
Status: 📋 Needs Setup
Action: Follow Google AI Studio or Vertex AI integration steps
```

### For Perplexity
```
File: HANDOFF_PERPLEXITY.md
Status: 📋 Needs Setup
Action: Add custom HTTP tool in Perplexity settings
```

### For ChatGPT
```
File: HANDOFF_CHATGPT.md
Status: 📋 Needs Setup
Action: Create Custom GPT or use OpenAI API
```

---

## Common Tasks Across All Models

All models can perform these tasks with the same commands:

### Get System Status
```bash
systemctl status remote-executor
```

### View Recent Logs
```bash
sudo journalctl -u remote-executor.service -n 50
```

### List Para Codes
```bash
cd /home/user/.github/infrastructure/event-logging && \
python3 para_system.py list all
```

### Generate New Code
```bash
cd /home/user/.github/infrastructure/event-logging && \
python3 para_system.py generate invoice "Invoice description"
```

### Check Platform Sync
```bash
cd /home/user/.github/infrastructure/event-logging && \
python3 platform_sync_service.py --report
```

### Read Documentation
```bash
cat /home/user/.github/infrastructure/HANDOFF.md
```

---

## Security Across All Models

⚠️ **Important Security Notes:**

1. **Bearer Token is Sensitive**
   - Do not expose in public logs
   - Do not share in unsecured channels
   - Each AI model should store it securely
   - Token: `9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687`

2. **Command Execution Privileges**
   - All commands run with root/elevated privileges
   - Be specific and careful with commands
   - Avoid destructive operations (rm -rf, dd, etc.)

3. **Logging & Monitoring**
   - All commands are logged in systemd journal
   - Logs can be reviewed: `sudo journalctl -u remote-executor.service`
   - Audit trail is maintained for compliance

4. **Access Control**
   - Same token for all models (consider rotating if compromised)
   - Each model has full filesystem access via this token
   - No per-model permission restrictions

---

## Integration Workflow

### Step 1: Choose Your AI Model
- Select from: Claude, Gemini, Perplexity, or ChatGPT

### Step 2: Follow Setup Guide
- Claude: Already done ✅
- Gemini: See `HANDOFF_GEMINI.md`
- Perplexity: See `HANDOFF_PERPLEXITY.md`
- ChatGPT: See `HANDOFF_CHATGPT.md`

### Step 3: Test Connection
Ask your AI: `Execute: whoami`

Expected response: Output from the VPS showing the current user.

### Step 4: Try Common Commands
Start with safe read operations:
- Check status
- List files
- Read documentation
- Query para codes

### Step 5: Use for Your Workflow
Once connected, integrate into your daily workflow for:
- Para code generation and tracking
- Infrastructure monitoring
- Documentation access
- System automation

---

## Troubleshooting Across All Models

### Connection Issues

**Test 1: Basic Connectivity**
```bash
ping 72.61.74.250
```

**Test 2: Port Accessibility**
```bash
curl http://72.61.74.250:8813/
```

**Test 3: Authentication**
```bash
curl -X POST \
  -H "Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687" \
  -H "Content-Type: application/json" \
  -d '{"command":"whoami"}' \
  http://72.61.74.250:8813/execute
```

### Service Issues

**Check Remote Executor Status:**
```bash
systemctl status remote-executor
sudo journalctl -u remote-executor.service -f
```

**Restart Service:**
```bash
sudo systemctl restart remote-executor
```

### Command Issues

**Para System Not Found:**
```bash
cd /home/user/.github/infrastructure/event-logging
ls -la para_system.py
python3 --version
```

**Module Import Errors:**
```bash
python3 -c "from para_system import ParaSystemCodeGenerator; print('OK')"
```

---

## Documentation Hierarchy

1. **START HERE:** This file (`HANDOFF_MULTI_AI_INDEX.md`)
2. **FOR YOUR AI:** Choose your AI and read its specific guide
3. **FOR DETAILS:** `HANDOFF.md` (complete system documentation)
4. **FOR PARA SYSTEM:** `CROSS_PLATFORM_LINKING_SETUP.md`
5. **FOR TESTING:** `PHASE2_TEST_REPORT.md`
6. **FOR CREDENTIALS:** `1PASSWORD_QUICK_START.md`

---

## Support & Maintenance

### Who Manages This?
- **Infrastructure Owner:** Shannon Love (sjlove@shannonjeffreylove.com)
- **VPS:** 72.61.74.250
- **Documentation:** This repository

### How to Get Help
1. Check the relevant handoff document for your AI
2. Review main `HANDOFF.md` for system architecture
3. Check VPS logs: `sudo journalctl -u remote-executor.service`
4. Test API directly with curl command above

### Monitoring Access
All AI access is logged automatically:
```bash
sudo journalctl -u remote-executor.service --since="1 hour ago"
```

---

## Summary Table

| Model | Status | Setup | Command Access | File Access | Para Codes |
|-------|--------|-------|-----------------|-------------|-----------|
| Claude | ✅ Active | Done | ✅ Full | ✅ Full | ✅ Full |
| Gemini | 📋 Ready | Needed | ✅ Will have | ✅ Will have | ✅ Will have |
| Perplexity | 📋 Ready | Needed | ✅ Will have | ✅ Will have | ✅ Will have |
| ChatGPT | 📋 Ready | Needed | ✅ Will have | ✅ Will have | ✅ Will have |

---

## Next Steps

1. **For each AI you want to set up:**
   - Read its specific handoff document
   - Follow the setup instructions
   - Test the connection
   - Start using it

2. **Monitor the infrastructure:**
   - Check logs regularly
   - Verify services are running
   - Track para code usage

3. **Keep documentation updated:**
   - Update these handoff files as things change
   - Note any issues or workarounds
   - Share improvements across AI integrations

---

**All multi-AI infrastructure ready to go!** 🚀

Start with your chosen AI and follow its specific setup guide.
