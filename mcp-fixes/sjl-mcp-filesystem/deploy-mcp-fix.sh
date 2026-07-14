#!/bin/bash
#
# MCP Server Crash Loop Fix - Automated Deployment Script
# Deploys enhanced filesystem server with heartbeat mechanism and crash loop prevention
#

set -e

VPS_IP="${1:-100.115.66.75}"
BACKUP_BASE_DIR="${2:-/opt/sjl-mcp-backup}"
TIMESTAMP=$(date +%s)
BACKUP_DIR="${BACKUP_BASE_DIR}-${TIMESTAMP}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 MCP Server Crash Loop Fix - Automated Deployment"
echo "=================================================="
echo "VPS IP: $VPS_IP"
echo "Backup Dir: $BACKUP_DIR"
echo "Script Dir: $SCRIPT_DIR"
echo ""

# Deploy to VPS
ssh root@$VPS_IP << DEPLOY_EOF
  set -e

  # Create backup directory
  mkdir -p ${BACKUP_DIR}
  echo "📦 Backing up existing files..."
  [ -d /opt/sjl-mcp ] && cp -r /opt/sjl-mcp/* ${BACKUP_DIR}/ 2>/dev/null || echo "  (No existing files to backup)"

  # Stop service
  echo "🛑 Stopping sjl-mcp.service..."
  systemctl stop sjl-mcp.service 2>/dev/null || echo "  (Service not running)"
  sleep 2

  # Create directories
  echo "📁 Creating directories..."
  mkdir -p /opt/sjl-mcp /var/log/sjl-mcp
  chmod 755 /var/log/sjl-mcp

  # Deploy server and service files
  echo "📝 Deploying enhanced filesystem server..."
  cat > /opt/sjl-mcp/enhanced-filesystem-server.js << 'SERVER_EOF'
$(cat ${SCRIPT_DIR}/enhanced-filesystem-server.js)
SERVER_EOF

  chmod +x /opt/sjl-mcp/enhanced-filesystem-server.js

  echo "⚙️  Deploying systemd service configuration..."
  cat > /etc/systemd/system/sjl-mcp.service << 'SERVICE_EOF'
$(cat ${SCRIPT_DIR}/sjl-mcp-file-enhanced.service)
SERVICE_EOF

  chmod 644 /etc/systemd/system/sjl-mcp.service

  # Start service
  echo "🚀 Starting sjl-mcp.service..."
  systemctl daemon-reload
  systemctl enable sjl-mcp.service
  systemctl start sjl-mcp.service

  sleep 3

  echo ""
  echo "✅ Deployment complete!"
  echo ""
  echo "📊 Service Status:"
  systemctl status sjl-mcp.service --no-pager || true
  echo ""
  echo "📋 Recent Logs:"
  journalctl -u sjl-mcp.service -n 10 --no-pager || true
DEPLOY_EOF

echo ""
echo "🎉 Deployment Complete!"
echo ""
echo "📚 Next Steps:"
echo "  1. Verify the service is running: ssh root@${VPS_IP} 'systemctl status sjl-mcp.service'"
echo "  2. Monitor logs: ssh root@${VPS_IP} 'journalctl -u sjl-mcp.service -f'"
echo "  3. Check heartbeat (should see every 30s): ssh root@${VPS_IP} 'tail -f /var/log/sjl-mcp/server-*.log'"
echo ""
