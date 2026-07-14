#!/bin/bash
#
# MCP Server Crash Loop Fix - Automated Deployment Script
# Usage: ./deploy-mcp-fix.sh [VPS_IP] [BACKUP_DIR]
# Default: ./deploy-mcp-fix.sh 100.115.66.75 /opt/sjl-mcp-backup
#

set -e

VPS_IP="${1:-100.115.66.75}"
BACKUP_BASE_DIR="${2:-/opt/sjl-mcp-backup}"
TIMESTAMP=$(date +%s)
BACKUP_DIR="${BACKUP_BASE_DIR}-${TIMESTAMP}"

echo "🚀 MCP Server Crash Loop Fix - Automated Deployment"
echo "=================================================="
echo "VPS IP: $VPS_IP"
echo "Backup Dir: $BACKUP_DIR"
echo ""

# Step 1: Assess current system state
echo "1️⃣  Assessing current system state..."
ssh root@$VPS_IP << 'ASSESS_EOF'
  echo "=== System Information ==="
  uname -a
  echo ""
  echo "=== Node.js Version ==="
  node --version || echo "Node not found"
  echo ""
  echo "=== Current sjl-mcp.service ==="
  cat /etc/systemd/system/sjl-mcp.service 2>/dev/null || echo "Service file not found"
  echo ""
  echo "=== Service Status ==="
  systemctl status sjl-mcp.service --no-pager 2>/dev/null || echo "Service not running"
  echo ""
  echo "=== Recent Crashes (last 30 lines) ==="
  journalctl -u sjl-mcp.service -n 30 --no-pager 2>/dev/null || echo "No logs available"
  echo ""
  echo "=== Existing MCP Directory ==="
  ls -la /opt/sjl-mcp 2>/dev/null || echo "Directory does not exist"
ASSESS_EOF

echo ""
echo "2️⃣  Deploying enhanced server with crash loop fix..."
echo ""

ssh root@$VPS_IP << DEPLOY_EOF
  set -e

  # Create backup directory
  mkdir -p $BACKUP_DIR
  echo "📦 Backup directory: $BACKUP_DIR"

  # Stop service safely
  echo "⏹️  Stopping sjl-mcp.service..."
  systemctl stop sjl-mcp.service 2>/dev/null || true
  sleep 2

  # Back up existing files
  if [ -d /opt/sjl-mcp ]; then
    echo "💾 Backing up existing files..."
    cp -r /opt/sjl-mcp/* $BACKUP_DIR/ 2>/dev/null || true
  fi

  # Create fresh directory
  mkdir -p /opt/sjl-mcp
  mkdir -p /var/log/sjl-mcp
  chmod 755 /var/log/sjl-mcp

  # Deploy enhanced server
  echo "📝 Writing enhanced-filesystem-server.js..."
  cat > /opt/sjl-mcp/enhanced-filesystem-server.js << 'SERVER_CODE'
#!/usr/bin/env node
/**
 * Enhanced Filesystem MCP Server with Crash Loop Prevention
 */
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const LOG_DIR = process.env.LOG_DIR || '/var/log/sjl-mcp';
const LOG_FILE = path.join(LOG_DIR, `server-\${Date.now()}.log`);

if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

class EnhancedFilesystemServer {
  constructor() {
    this.server = new Server(
      { name: 'sjl-mcp-file', version: '1.0.0' },
      { capabilities: { tools: {
        read_file: { name: 'read_file', description: 'Read content from a file', inputSchema: {
          type: 'object', properties: {
            path: { type: 'string', description: 'File path' },
            encoding: { type: 'string', enum: ['utf-8', 'base64'], default: 'utf-8' },
            lines: { type: 'number', description: 'Limit to first N lines' },
            offset: { type: 'number', description: 'Byte offset to start from' }
          }, required: ['path'] } },
        write_file: { name: 'write_file', description: 'Write content to a file', inputSchema: {
          type: 'object', properties: {
            path: { type: 'string' }, content: { type: 'string' },
            mode: { type: 'string', default: '644' },
            create_dirs: { type: 'boolean', default: false },
            backup_existing: { type: 'boolean', default: false }
          }, required: ['path', 'content'] } },
        list_directory: { name: 'list_directory', description: 'List directory contents', inputSchema: {
          type: 'object', properties: {
            path: { type: 'string' },
            recursive: { type: 'boolean', default: false },
            filter: { type: 'string', description: 'Glob pattern' }
          }, required: ['path'] } }
      }} }
    );
    this.heartbeatInterval = null;
    this.isShuttingDown = false;
    this.startTime = Date.now();
    this.requestCount = 0;
  }

  log(level, message, data = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = { timestamp, level, message, uptime: Date.now() - this.startTime, requestCount: this.requestCount, ...data };
    fs.appendFileSync(LOG_FILE, JSON.stringify(logEntry) + '\n');
    const logStr = `[\${timestamp}] [\${level}] \${message}`;
    console.error(Object.keys(data).length > 0 ? logStr + ' ' + JSON.stringify(data) : logStr);
  }

  async start() {
    try {
      this.log('info', 'Server initializing...');
      process.on('SIGINT', () => this.gracefulShutdown());
      process.on('SIGTERM', () => this.gracefulShutdown());
      process.on('SIGHUP', () => this.gracefulShutdown());
      this.setupToolHandlers();
      this.startHeartbeat();
      setInterval(() => {
        if (!this.isShuttingDown) {
          const usage = process.memoryUsage();
          this.log('debug', 'Resource usage', { memory: {
            heapUsed: Math.round(usage.heapUsed / 1024 / 1024) + 'MB',
            heapTotal: Math.round(usage.heapTotal / 1024 / 1024) + 'MB',
            rss: Math.round(usage.rss / 1024 / 1024) + 'MB'
          }, requests: this.requestCount });
        }
      }, 60000);
      const transport = new StdioServerTransport();
      transport.onclose = () => this.log('warn', 'Transport closed by client');
      transport.onerror = (error) => this.log('error', 'Transport error', { error: error.message });
      await this.server.connect(transport);
      this.log('info', 'Server started successfully with enhanced stability');
      if (process.send) process.send('ready');
      await new Promise(() => {});
    } catch (error) {
      this.log('error', 'Fatal initialization error', { error: error.message });
      process.exit(1);
    }
  }

  setupToolHandlers() {
    this.server.setRequestHandler({ method: 'tools/call' }, async (request) => {
      this.requestCount++;
      const { name, arguments: args } = request.params;
      try {
        switch (name) {
          case 'read_file': return await this.handleReadFile(args);
          case 'write_file': return await this.handleWriteFile(args);
          case 'list_directory': return await this.handleListDirectory(args);
          default: return { content: [{ type: 'text', text: \`Unknown tool: \${name}\` }], isError: true };
        }
      } catch (error) {
        this.log('error', \`Tool execution failed: \${name}\`, { error: error.message });
        return { content: [{ type: 'text', text: \`Error: \${error.message}\` }], isError: true };
      }
    });
  }

  async handleReadFile(args) {
    const { path: filePath, encoding = 'utf-8', lines, offset } = args;
    let content = fs.readFileSync(filePath, encoding);
    if (lines) content = content.split('\n').slice(0, lines).join('\n');
    if (offset) content = content.slice(offset);
    this.log('info', 'File read successfully', { path: filePath, size: content.length });
    return { content: [{ type: 'text', text: content }] };
  }

  async handleWriteFile(args) {
    const { path: filePath, content, mode = '644', create_dirs = false, backup_existing = false } = args;
    const dir = path.dirname(filePath);
    if (create_dirs && !fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    if (backup_existing && fs.existsSync(filePath)) {
      const backupPath = \`\${filePath}.backup-\${Date.now()}\`;
      fs.copyFileSync(filePath, backupPath);
      this.log('info', 'File backed up', { backup: backupPath });
    }
    fs.writeFileSync(filePath, content, 'utf-8');
    fs.chmodSync(filePath, parseInt(mode, 8));
    this.log('info', 'File written successfully', { path: filePath, size: content.length });
    return { content: [{ type: 'text', text: \`File written successfully: \${filePath}\` }] };
  }

  async handleListDirectory(args) {
    const { path: dirPath, recursive = false, filter } = args;
    const entries = fs.readdirSync(dirPath, { withFileTypes: true });
    const result = entries.map(entry => ({ name: entry.name, type: entry.isDirectory() ? 'directory' : 'file' }))
      .filter(entry => !filter || entry.name.match(filter));
    this.log('info', 'Directory listed', { path: dirPath, count: result.length });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }

  startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      if (!this.isShuttingDown) {
        this.log('debug', 'Heartbeat sent', { timestamp: Date.now() });
      }
    }, 30000);
    this.log('info', 'Heartbeat mechanism started (30s interval)');
  }

  async gracefulShutdown() {
    if (this.isShuttingDown) return;
    this.isShuttingDown = true;
    this.log('info', 'Graceful shutdown initiated');
    if (this.heartbeatInterval) clearInterval(this.heartbeatInterval);
    try { await this.server.close(); } catch (error) {
      this.log('error', 'Error closing server', { error: error.message });
    }
    this.log('info', 'Server shutdown complete', { uptime: Date.now() - this.startTime, totalRequests: this.requestCount });
    process.exit(0);
  }
}

const server = new EnhancedFilesystemServer();
server.start().catch(error => {
  console.error('[FATAL] Unhandled error:', error);
  process.exit(1);
});
SERVER_CODE

  chmod +x /opt/sjl-mcp/enhanced-filesystem-server.js

  # Update systemd service
  echo "🔧 Updating systemd service..."
  cat > /etc/systemd/system/sjl-mcp.service << 'SERVICE_EOF'
[Unit]
Description=SJL MCP Filesystem Server (Enhanced)
After=network.target
Documentation=https://github.com/shannonjlove/.github

[Service]
Type=simple
User=root
WorkingDirectory=/opt/sjl-mcp
ExecStart=/usr/bin/node /opt/sjl-mcp/enhanced-filesystem-server.js
Restart=on-failure
RestartSec=10
StartLimitInterval=60
StartLimitBurst=3
Environment="NODE_OPTIONS=--max-old-space-size=512 --unhandled-rejections=strict"
Environment="LOG_DIR=/var/log/sjl-mcp"
StandardOutput=journal
StandardError=journal
SyslogIdentifier=sjl-mcp

[Install]
WantedBy=multi-user.target
SERVICE_EOF

  systemctl daemon-reload
  systemctl enable sjl-mcp.service

  echo "✅ Starting service..."
  systemctl start sjl-mcp.service

  sleep 3

  echo ""
  echo "=== Service Status ==="
  systemctl status sjl-mcp.service --no-pager || true

  echo ""
  echo "=== Recent Logs ==="
  journalctl -u sjl-mcp.service -n 15 --no-pager || true

  echo ""
  echo "✅ Deployment complete!"
DEPLOY_EOF

echo ""
echo "🎉 MCP Server Fix Deployed!"
echo "=================================================="
echo ""
echo "📊 Service Information:"
echo "   Service: sjl-mcp.service"
echo "   Binary: /opt/sjl-mcp/enhanced-filesystem-server.js"
echo "   Logs: /var/log/sjl-mcp/"
echo ""
echo "🔍 Monitoring Commands:"
echo "   Status: ssh root@$VPS_IP 'systemctl status sjl-mcp.service'"
echo "   Logs: ssh root@$VPS_IP 'journalctl -u sjl-mcp.service -f'"
echo "   Memory: ssh root@$VPS_IP 'journalctl -u sjl-mcp.service | grep \"Resource usage\"'"
echo ""
echo "💾 Backup Location:"
echo "   $BACKUP_DIR"
echo ""
echo "🔄 Rollback:"
echo "   If needed, backups are preserved at: $BACKUP_DIR"
echo ""
