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
