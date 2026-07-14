#!/usr/bin/env node
/**
 * Enhanced Filesystem MCP Server with Crash Loop Prevention
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import fs from 'fs';
import fsPromises from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const LOG_DIR = process.env.LOG_DIR || '/var/log/sjl-mcp';
const LOG_FILE = path.join(LOG_DIR, `server-${Date.now()}.log`);

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
            path: { type: 'string' },
            encoding: { type: 'string', enum: ['utf-8', 'base64'], default: 'utf-8' },
            lines: { type: 'number' },
            offset: { type: 'number' }
          }, required: ['path'] } },
        write_file: { name: 'write_file', description: 'Write content to a file', inputSchema: {
          type: 'object', properties: {
            path: { type: 'string' },
            content: { type: 'string' },
            mode: { type: 'string', default: '644' },
            create_dirs: { type: 'boolean', default: false },
            backup_existing: { type: 'boolean', default: false }
          }, required: ['path', 'content'] } },
        list_directory: { name: 'list_directory', description: 'List directory contents', inputSchema: {
          type: 'object', properties: {
            path: { type: 'string' },
            recursive: { type: 'boolean', default: false },
            filter: { type: 'string' }
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
    try {
      fs.appendFileSync(LOG_FILE, JSON.stringify(logEntry) + '\n');
    } catch (err) {
      console.error('[ERROR] Failed to write to log file: ' + err.message);
    }
    const logStr = `[${timestamp}] [${level}] ${message}`;
    console.error(Object.keys(data).length > 0 ? logStr + ' ' + JSON.stringify(data) : logStr);
  }

  safeResolve(unsafePath) {
    const allowedRoot = process.env.ALLOWED_ROOT || '/opt/sjl-mcp';
    const resolvedPath = path.resolve(allowedRoot, unsafePath);
    if (!resolvedPath.startsWith(allowedRoot + path.sep) && resolvedPath !== allowedRoot) {
      throw new Error('Access denied: Path traversal detected');
    }
    return resolvedPath;
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
          default: return { content: [{ type: 'text', text: `Unknown tool: ${name}` }], isError: true };
        }
      } catch (error) {
        this.log('error', `Tool execution failed: ${name}`, { error: error.message });
        return { content: [{ type: 'text', text: `Error: ${error.message}` }], isError: true };
      }
    });
  }

  async handleReadFile(args) {
    const { path: filePath, encoding = 'utf-8', lines, offset } = args;
    const safePath = this.safeResolve(filePath);
    let content = await fsPromises.readFile(safePath, encoding);
    if (lines) content = content.split('\n').slice(0, lines).join('\n');
    if (offset) content = content.slice(offset);
    this.log('info', 'File read successfully', { path: safePath, size: content.length });
    return { content: [{ type: 'text', text: content }] };
  }

  async handleWriteFile(args) {
    const { path: filePath, content, mode = '644', create_dirs = false, backup_existing = false } = args;
    const safePath = this.safeResolve(filePath);
    const dir = path.dirname(safePath);
    if (create_dirs && !fs.existsSync(dir)) await fsPromises.mkdir(dir, { recursive: true });
    if (backup_existing && fs.existsSync(safePath)) {
      const backupPath = `${safePath}.backup-${Date.now()}`;
      await fsPromises.copyFile(safePath, backupPath);
      this.log('info', 'File backed up', { backup: backupPath });
    }
    await fsPromises.writeFile(safePath, content, 'utf-8');
    await fsPromises.chmod(safePath, parseInt(mode, 8));
    this.log('info', 'File written successfully', { path: safePath, size: content.length });
    return { content: [{ type: 'text', text: `File written successfully: ${safePath}` }] };
  }

  async handleListDirectory(args) {
    const { path: dirPath, recursive = false, filter } = args;
    const safePath = this.safeResolve(dirPath);
    const entries = await fsPromises.readdir(safePath, { withFileTypes: true });
    const result = entries.map(entry => ({ name: entry.name, type: entry.isDirectory() ? 'directory' : 'file' }))
      .filter(entry => !filter || entry.name.match(filter));
    this.log('info', 'Directory listed', { path: safePath, count: result.length });
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
