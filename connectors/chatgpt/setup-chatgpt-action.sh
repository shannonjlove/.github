#!/bin/bash
# ChatGPT Custom Action Automated Setup Script
# This script automates the creation of ChatGPT Custom Actions for sjl-mcp-filesystem

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}ChatGPT Custom Action Setup${NC}"
echo -e "${BLUE}================================${NC}"

# Configuration
ACTION_NAME="SJL MCP Filesystem"
ACTION_DESCRIPTION="Read and write files with automatic backups"
SERVER_URL="https://72.61.74.250:8813"
BEARER_TOKEN="${SJL_WRITE_TOKEN:-9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687}"

# Directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="${SCRIPT_DIR}/chatgpt-configs"
mkdir -p "${CONFIG_DIR}"

echo -e "${GREEN}✓${NC} Configuration:"
echo "  Action Name: ${ACTION_NAME}"
echo "  Server URL: ${SERVER_URL}"
echo "  Config Directory: ${CONFIG_DIR}"

# Function to create JSON config
create_action_config() {
    local output_file="${CONFIG_DIR}/custom-action-config.json"

    cat > "${output_file}" << 'EOF'
{
  "name": "SJL MCP Filesystem",
  "description": "Read and write files with automatic backups",
  "url": "https://72.61.74.250:8813",
  "auth": {
    "type": "bearer",
    "token_env_var": "SJL_WRITE_TOKEN"
  },
  "tools": [
    {
      "id": "read-file",
      "name": "Read File",
      "enabled": true
    },
    {
      "id": "write-file",
      "name": "Write File",
      "enabled": true
    },
    {
      "id": "list-directory",
      "name": "List Directory",
      "enabled": true
    },
    {
      "id": "search-files",
      "name": "Search Files",
      "enabled": true
    },
    {
      "id": "get-file-info",
      "name": "Get File Info",
      "enabled": true
    },
    {
      "id": "create-directory",
      "name": "Create Directory",
      "enabled": true
    },
    {
      "id": "delete-file",
      "name": "Delete File",
      "enabled": false
    }
  ]
}
EOF

    echo -e "${GREEN}✓${NC} Created: ${output_file}"
}

# Function to create environment setup script
create_env_setup() {
    local output_file="${CONFIG_DIR}/setup-env.sh"

    cat > "${output_file}" << 'EOF'
#!/bin/bash
# Environment setup for ChatGPT connectors

# Set the SJL MCP Filesystem token
export SJL_WRITE_TOKEN="9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"

# Set ChatGPT API configuration
export CHATGPT_API_URL="https://api.openai.com/v1"
export CHATGPT_MCP_SERVER="https://72.61.74.250:8813"

# Optional: Set logging level
export LOG_LEVEL="INFO"

echo "Environment configured for ChatGPT connectors"
echo "SJL_WRITE_TOKEN: ${SJL_WRITE_TOKEN:0:20}..."
echo "CHATGPT_MCP_SERVER: ${CHATGPT_MCP_SERVER}"
EOF

    chmod +x "${output_file}"
    echo -e "${GREEN}✓${NC} Created: ${output_file}"
}

# Function to create deployment script
create_deployment_script() {
    local output_file="${CONFIG_DIR}/deploy-custom-action.sh"

    cat > "${output_file}" << 'EOF'
#!/bin/bash
# Deploy ChatGPT Custom Action
# This script guides you through the deployment process

set -e

echo "ChatGPT Custom Action Deployment"
echo "=================================="
echo ""
echo "This script will help you deploy the SJL MCP Filesystem as a ChatGPT Custom Action"
echo ""

# Step 1: Environment
echo "Step 1: Setting up environment..."
source "$(dirname "$0")/setup-env.sh"

# Step 2: Validate configuration
echo ""
echo "Step 2: Validating configuration..."
if [ -z "${SJL_WRITE_TOKEN}" ]; then
    echo "❌ Error: SJL_WRITE_TOKEN not set"
    exit 1
fi

# Test connection
echo "Testing connection to MCP server..."
curl -s -H "Authorization: Bearer ${SJL_WRITE_TOKEN}" \
    https://72.61.74.250:8813/health > /dev/null && \
    echo "✅ Connection successful" || \
    echo "⚠️  Connection failed - server may be down"

# Step 3: Display setup instructions
echo ""
echo "Step 3: Manual Setup in ChatGPT"
echo "================================"
echo ""
echo "Follow these steps in ChatGPT:"
echo ""
echo "1. Go to https://chatgpt.com"
echo "2. Click profile icon → Settings"
echo "3. Go to Integrations → Actions"
echo "4. Click 'Create new action'"
echo ""
echo "5. Fill in:"
echo "   Name: SJL MCP Filesystem"
echo "   Description: Read and write files with automatic backups"
echo "   URL: https://72.61.74.250:8813"
echo ""
echo "6. Paste the OpenAPI schema (see openapi-schema.json)"
echo ""
echo "7. Set Authentication:"
echo "   Type: Bearer"
echo "   Token: ${SJL_WRITE_TOKEN}"
echo ""
echo "8. Click Save"
echo ""
echo "9. Test in ChatGPT chat:"
echo '   "List files in /home/user/.github/infrastructure/"'
echo ""
echo "✅ Setup complete!"
EOF

    chmod +x "${output_file}"
    echo -e "${GREEN}✓${NC} Created: ${output_file}"
}

# Function to create Python automation script
create_python_automation() {
    local output_file="${CONFIG_DIR}/chatgpt-action-manager.py"

    cat > "${output_file}" << 'EOF'
#!/usr/bin/env python3
"""
ChatGPT Custom Action Manager
Automates creation and management of ChatGPT Custom Actions for sjl-mcp-filesystem
"""

import json
import os
import sys
from dataclasses import dataclass
from typing import Optional

@dataclass
class CustomAction:
    name: str = "SJL MCP Filesystem"
    description: str = "Read and write files with automatic backups"
    server_url: str = "https://72.61.74.250:8813"
    bearer_token: str = ""

    @classmethod
    def from_env(cls):
        """Create CustomAction from environment variables"""
        return cls(
            bearer_token=os.getenv('SJL_WRITE_TOKEN', '')
        )

    def to_config(self) -> dict:
        """Convert to ChatGPT configuration format"""
        return {
            "name": self.name,
            "description": self.description,
            "server_url": self.server_url,
            "authentication": {
                "type": "bearer",
                "token": self.bearer_token
            },
            "tools": [
                "read_file",
                "write_file",
                "list_directory",
                "search_files",
                "get_file_info",
                "create_directory"
            ]
        }

    def validate(self) -> bool:
        """Validate configuration"""
        if not self.bearer_token:
            print("❌ Error: Bearer token not set")
            return False
        if not self.server_url.startswith('https://'):
            print("❌ Error: Server URL must use HTTPS")
            return False
        return True

    def test_connection(self) -> bool:
        """Test connection to MCP server"""
        try:
            import urllib.request
            req = urllib.request.Request(
                f"{self.server_url}/health",
                headers={"Authorization": f"Bearer {self.bearer_token}"}
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                return response.status == 200
        except Exception as e:
            print(f"❌ Connection failed: {e}")
            return False

    def save_config(self, filepath: str):
        """Save configuration to file"""
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            json.dump(self.to_config(), f, indent=2)
        print(f"✅ Configuration saved to {filepath}")

def main():
    print("ChatGPT Custom Action Manager")
    print("=" * 50)
    print()

    # Load configuration
    action = CustomAction.from_env()

    # Validate
    if not action.validate():
        sys.exit(1)

    # Test connection
    print("Testing connection to MCP server...")
    if action.test_connection():
        print("✅ Connection successful")
    else:
        print("⚠️  Connection test failed")

    # Save configuration
    config_path = os.path.expanduser("~/.chatgpt/actions/sjl-mcp-filesystem.json")
    action.save_config(config_path)

    # Display summary
    print()
    print("Configuration Summary:")
    print(f"  Action: {action.name}")
    print(f"  Server: {action.server_url}")
    print(f"  Tools: 6 available")
    print()
    print("Next steps:")
    print("  1. Go to ChatGPT Settings → Integrations → Actions")
    print("  2. Click 'Create new action'")
    print("  3. Paste the configuration")
    print("  4. Set Bearer token authentication")
    print("  5. Save and test")

if __name__ == "__main__":
    main()
EOF

    chmod +x "${output_file}"
    echo -e "${GREEN}✓${NC} Created: ${output_file}"
}

# Function to create comprehensive setup guide
create_setup_guide() {
    local output_file="${CONFIG_DIR}/CHATGPT_AUTOMATION_GUIDE.md"

    cat > "${output_file}" << 'EOF'
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
EOF

    echo -e "${GREEN}✓${NC} Created: ${output_file}"
}

# Run all creation functions
echo ""
echo -e "${YELLOW}Creating configuration files...${NC}"
create_action_config
create_env_setup
create_deployment_script
create_python_automation
create_setup_guide

# Summary
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Files created in: ${CONFIG_DIR}"
echo ""
echo "Next steps:"
echo "  1. Review: CHATGPT_AUTOMATION_GUIDE.md"
echo "  2. Run:    bash deploy-custom-action.sh"
echo "  3. Follow: Manual setup instructions in ChatGPT"
echo ""
