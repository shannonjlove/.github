#!/bin/bash
# === SJL-MCP Connector Setup Script ===
# Automates the entire VPS setup for Claude Code remote access
# Usage: bash setup-mcp-connector.sh

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║   SJL-MCP Connector Setup for Claude Code Remote   ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

echo "📋 Step 1: Generating API Key"
echo "================================"
API_KEY=$(openssl rand -hex 32)
echo "✅ Generated: $API_KEY"
echo ""

echo "📋 Step 2: Updating /etc/podman/secrets/sjl-mcp.env"
echo "=================================================="
echo "Current contents:"
cat /etc/podman/secrets/sjl-mcp.env
echo ""
echo "Adding authentication..."

# Backup the original file
cp /etc/podman/secrets/sjl-mcp.env /etc/podman/secrets/sjl-mcp.env.backup

# Add auth variables
cat >> /etc/podman/secrets/sjl-mcp.env << EOF

# MCP Connector Authentication (Added $(date -Iseconds))
MCP_AUTH_ENABLED=true
MCP_API_KEY=$API_KEY
EOF

echo "✅ Updated environment file"
echo ""

echo "📋 Step 3: Restarting sjl-mcp-quadlet.service"
echo "=============================================="
systemctl restart sjl-mcp-quadlet.service
sleep 3

# Check status
if systemctl is-active --quiet sjl-mcp-quadlet.service; then
    echo "✅ Service restarted successfully"
else
    echo "❌ Service failed to start!"
    echo "Rolling back changes..."
    cp /etc/podman/secrets/sjl-mcp.env.backup /etc/podman/secrets/sjl-mcp.env
    systemctl restart sjl-mcp-quadlet.service
    exit 1
fi
echo ""

echo "📋 Step 4: Testing Connectivity"
echo "================================"

# Test without auth
echo -n "Testing without auth: "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8811/health; then
    echo " (expected: 401 or similar)"
fi
echo ""

# Test with auth
echo -n "Testing with auth: "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $API_KEY" http://localhost:8811/health)
echo "$RESPONSE"
if [ "$RESPONSE" == "200" ]; then
    echo "✅ Authentication successful!"
else
    echo "⚠️  Unexpected response code: $RESPONSE"
fi
echo ""

echo "📋 Step 5: Saving Configuration for Claude Code Setup"
echo "====================================================="
cat > /tmp/sjl-mcp-connector-config.txt << CONFEOF
=== SJL-MCP Connector Configuration ===
Generated: $(date)

VPS Details:
- Host: 72.61.74.250
- Port: 8811
- URL: http://72.61.74.250:8811

Authentication:
- Type: API Key (Bearer Token)
- API Key: $API_KEY

Next Steps in Claude Code:
1. Go to Settings → App → Connectors
2. Click "Add Connector" / "Add Server"
3. Fill in:
   - Name: sjl-mcp-direct
   - Type: HTTP
   - URL: http://72.61.74.250:8811
   - Header: Authorization: Bearer $API_KEY
4. Enable and Save

Testing the Connector:
curl -H "Authorization: Bearer $API_KEY" http://72.61.74.250:8811/health
CONFEOF

echo "✅ Configuration saved to: /tmp/sjl-mcp-connector-config.txt"
cat /tmp/sjl-mcp-connector-config.txt
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║          ✅ SETUP COMPLETE!                        ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "📌 IMPORTANT: Save this API Key securely!"
echo "🔑 API Key: $API_KEY"
echo ""
echo "Next: Add the connector in Claude Code settings"
echo "     Settings → App → Connectors → Add Server"
echo ""
