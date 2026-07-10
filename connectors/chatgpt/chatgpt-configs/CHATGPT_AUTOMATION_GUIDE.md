# ChatGPT Custom Action - Automated Setup Guide

## Overview

This package provides automated setup for the SJL MCP Filesystem as a ChatGPT Custom Action.

**What you get:**
- OpenAPI schema (ready to paste)
- Environment setup scripts
- Deployment automation
- Configuration files
- Testing utilities

## Quick Start (5 minutes)

### 1. Set Environment Variable

```bash
export SJL_WRITE_TOKEN="9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"
```

### 2. Run Setup Script

```bash
bash setup-env.sh
bash deploy-custom-action.sh
```

### 3. Manual Setup in ChatGPT

Follow the instructions printed by the deployment script.

## Files Included

### Scripts
- **setup-env.sh** - Initialize environment variables
- **deploy-custom-action.sh** - Deployment guide and testing
- **chatgpt-action-manager.py** - Python automation tool

### Configurations
- **custom-action-config.json** - ChatGPT action configuration
- **openapi-schema.json** - API specification (copy to ChatGPT)

### Documentation
- **CHATGPT_AUTOMATION_GUIDE.md** - This file
- **SETUP_GUIDE.md** - Detailed setup instructions

## Using Python Automation

```bash
# Run Python automation tool
python3 chatgpt-action-manager.py

# This will:
# 1. Validate configuration
# 2. Test server connection
# 3. Generate and save configuration
# 4. Display setup instructions
```

## Manual Setup Steps

If automation doesn't work, follow these steps:

1. **Go to ChatGPT:**
   - Navigate to https://chatgpt.com

2. **Access Settings:**
   - Click profile icon (bottom left)
   - Select "Settings"
   - Go to "Integrations"

3. **Create New Action:**
   - Click "Actions" in left menu
   - Click "Create new action"

4. **Fill Basic Info:**
   - Name: `SJL MCP Filesystem`
   - Description: `Read and write files with automatic backups`
   - URL: `https://72.61.74.250:8813`

5. **Add OpenAPI Schema:**
   - Paste entire schema from `openapi-schema.json`
   - Click "Validate"

6. **Configure Authentication:**
   - Type: `Bearer`
   - Token: `9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687`

7. **Save & Test:**
   - Click "Save"
   - In ChatGPT, try: `List files in /home/user/.github/infrastructure/`

## Available Tools

After setup, you'll have access to:

1. **Read File** - Read file contents
2. **Write File** - Create/modify files (with auto-backup)
3. **List Directory** - Show directory structure
4. **Search Files** - Find files by pattern
5. **Get File Info** - Get file metadata
6. **Create Directory** - Make new directories

## Troubleshooting

### "Command not found" error
```bash
# Make scripts executable
chmod +x *.sh

# Then run
bash deploy-custom-action.sh
```

### "Token not set" error
```bash
# Set token in current shell
export SJL_WRITE_TOKEN="9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"

# Or make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export SJL_WRITE_TOKEN="9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"' >> ~/.bashrc
```

### "Connection failed" error
1. Verify server is running
2. Check network connectivity
3. Verify token is correct
4. Try: `curl -H "Authorization: Bearer YOUR_TOKEN" https://72.61.74.250:8813/health`

## Next Steps

1. ✅ Run setup script
2. ✅ Test connection
3. ✅ Follow manual setup in ChatGPT
4. ✅ Test in ChatGPT chat
5. ✅ Start using the action!

## Security

⚠️ **Important:**
- Keep your Bearer token secret
- Don't commit token to version control
- Rotate token every 90 days
- Store in environment variables, not files

## Support

For issues:
1. Check troubleshooting section above
2. Verify all files are present
3. Check server connectivity
4. Review ChatGPT Custom Actions documentation

---

**Last Updated:** July 10, 2026
**Status:** Ready to Deploy ✅
