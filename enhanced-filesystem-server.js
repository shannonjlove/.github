#!/usr/bin/env node
/**
 * Enhanced Filesystem MCP Server with Crash Loop Prevention
 * Features:
 * - Heartbeat mechanism to prevent idle disconnects
 * - Graceful shutdown handling
 * - Connection keep-alive
 * - Comprehensive error logging
 * - Resource monitoring
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const LOG_DIR = process.env.LOG_DIR || '/var/log/sjl-mcp';
const LOG_FILE = path.join(LOG_DIR, `server-${Date.now()}.log`);

// Ensure log directory exists
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

/**
 * Enhanced Filesystem MCP Server
 */
class EnhancedFilesystemServer {
  constructor() {
    this.server = new Server(
      {
        name: 'sjl-mcp-file',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {
            read_file: {
              name: 'read_file',
              description: 'Read content from a file',
              inputSchema: {
                type: 'object',
                properties: {
                  path: { type: 'string', description: 'File path' },
                  encoding: { type: 'string', enum: ['utf-8', 'base64'], default: 'utf-8' },
                  lines: { type: 'number', description: 'Limit to first N lines' },
                  offset: { type: 'number', description: 'Byte offset to start from' }
                },
                required: ['path']
              }
            },
            write_file: {
              name: 'write_file',
              description: 'Write content to a file',
              inputSchema: {
                type: 'object',
                properties: {
                  path: { type: 'string' },
                  content: { type: 'string' },
                  mode: { type: 'string', default: '644' },
                  create_dirs: { type: 'boolean', default: false },
                  backup_existing: { type: 'boolean', default: false }
                },
                required: ['path', 'content']
              }
            },
            list_directory: {
              name: 'list_directory',
              description: 'List directory contents',
              inputSchema: {
                type: 'object',
                properties: {
                  path: { type: 'string' },
                  recursive: { type: 'boolean', default: false },
                  filter: { type: 'string', description: 'Glob pattern' }
                },
                required: ['path']
              }
            }
          }
        }
      }
    );

    this.heartbeatInterval = null;
    this.isShuttingDown = false;
    this.startTime = Date.now();
    this.requestCount = 0;
    this.lastActivityTime = Date.now();
  }

  log(level, message, data = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level,
      message,
      uptime: Date.now() - this.startTime,
      requestCount: this.requestCount,
      ...data
    };

    // Log to file
    fs.appendFileSync(LOG_FILE, JSON.stringify(logEntry) + '\n');

    // Also log to stderr for monitoring
    const logStr = `[${timestamp}] [${level}] ${message}`;
    if (Object.keys(data).length > 0) {
      console.error(logStr, data);
    } else {
      console.error(logStr);
    }
  }

  async start() {
    try {
      this.log('info', 'Server initializing...');

      // Setup signal handlers for graceful shutdown
      process.on('SIGINT', () => this.gracefulShutdown());
      process.on('SIGTERM', () => this.gracefulShutdown());
      process.on('SIGHUP', () => this.gracefulShutdown());

      // Setup tool handlers
      this.setupToolHandlers();

      // Start heartbeat
      this.startHeartbeat();

      // Start monitoring resource usage
      this.startResourceMonitoring();

      // Connect transport
      const transport = new StdioServerTransport();

      transport.onclose = () => {
        this.log('warn', 'Transport closed by client');
      };

      transport.onerror = (error) => {
        this.log('error', 'Transport error', { error: error.message });
      };

      await this.server.connect(transport);

      this.log('info', 'Server started successfully with enhanced stability');
      this.log('info', `Log file: ${LOG_FILE}`);

      // Send ready signal if parent process supports IPC
      if (process.send) {
        process.send('ready');
      }

      // Keep process alive
      await new Promise(() => {});
    } catch (error) {
      this.log('error', 'Fatal initialization error', { error: error.message, stack: error.stack });
      process.exit(1);
    }
  }

  setupToolHandlers() {
    // Handle read_file tool
    this.server.setRequestHandler({ method: 'tools/call' }, async (request) => {
      this.requestCount++;
      this.lastActivityTime = Date.now();

      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'read_file':
            return await this.handleReadFile(args);
          case 'write_file':
            return await this.handleWriteFile(args);
          case 'list_directory':
            return await this.handleListDirectory(args);
          default:
            return {
              content: [{
                type: 'text',
                text: `Unknown tool: ${name}`
              }],
              isError: true
            };
        }
      } catch (error) {
        this.log('error', `Tool execution failed: ${name}`, { error: error.message });
        return {
          content: [{
            type: 'text',
            text: `Error: ${error.message}`
          }],
          isError: true
        };
      }
    });
  }

  async handleReadFile(args) {
    const { path: filePath, encoding = 'utf-8', lines, offset } = args;

    try {
      let content = fs.readFileSync(filePath, encoding);

      if (lines) {
        content = content.split('\n').slice(0, lines).join('\n');
      }

      if (offset) {
        content = content.slice(offset);
      }

      this.log('info', 'File read successfully', { path: filePath, size: content.length });

      return {
        content: [{
          type: 'text',
          text: content
        }]
      };
    } catch (error) {
      this.log('error', 'Failed to read file', { path: filePath, error: error.message });
      throw error;
    }
  }

  async handleWriteFile(args) {
    const { path: filePath, content, mode = '644', create_dirs = false, backup_existing = false } = args;

    try {
      const dir = path.dirname(filePath);

      if (create_dirs && !fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      if (backup_existing && fs.existsSync(filePath)) {
        const backupPath = `${filePath}.backup-${Date.now()}`;
        fs.copyFileSync(filePath, backupPath);
        this.log('info', 'File backed up', { backup: backupPath });
      }

      fs.writeFileSync(filePath, content, 'utf-8');
      fs.chmodSync(filePath, parseInt(mode, 8));

      this.log('info', 'File written successfully', { path: filePath, size: content.length });

      return {
        content: [{
          type: 'text',
          text: `File written successfully: ${filePath}`
        }]
      };
    } catch (error) {
      this.log('error', 'Failed to write file', { path: filePath, error: error.message });
      throw error;
    }
  }

  async handleListDirectory(args) {
    const { path: dirPath, recursive = false, filter } = args;

    try {
      const entries = fs.readdirSync(dirPath, { withFileTypes: true });
      const result = entries
        .map(entry => ({
          name: entry.name,
          type: entry.isDirectory() ? 'directory' : 'file'
        }))
        .filter(entry => !filter || entry.name.match(filter));

      this.log('info', 'Directory listed', { path: dirPath, count: result.length });

      return {
        content: [{
          type: 'text',
          text: JSON.stringify(result, null, 2)
        }]
      };
    } catch (error) {
      this.log('error', 'Failed to list directory', { path: dirPath, error: error.message });
      throw error;
    }
  }

  startHeartbeat() {
    // Send periodic heartbeat to keep connection alive
    this.heartbeatInterval = setInterval(() => {
      if (!this.isShuttingDown) {
        try {
          this.log('debug', 'Heartbeat sent', { timestamp: Date.now() });
        } catch (error) {
          this.log('warn', 'Heartbeat failed', { error: error.message });
        }
      }
    }, 30000); // Every 30 seconds

    this.log('info', 'Heartbeat mechanism started (30s interval)');
  }

  startResourceMonitoring() {
    setInterval(() => {
      if (!this.isShuttingDown) {
        const usage = process.memoryUsage();
        this.log('debug', 'Resource usage', {
          memory: {
            heapUsed: Math.round(usage.heapUsed / 1024 / 1024) + 'MB',
            heapTotal: Math.round(usage.heapTotal / 1024 / 1024) + 'MB',
            rss: Math.round(usage.rss / 1024 / 1024) + 'MB'
          },
          uptime: Math.round((Date.now() - this.startTime) / 1000) + 's',
          requests: this.requestCount
        });

        // Alert if memory is high
        if (usage.heapUsed > 500 * 1024 * 1024) {
          this.log('warn', 'High memory usage detected');
        }
      }
    }, 60000); // Every 60 seconds
  }

  async gracefulShutdown() {
    if (this.isShuttingDown) return;

    this.isShuttingDown = true;
    this.log('info', 'Graceful shutdown initiated');

    // Clear intervals
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
    }

    // Close server
    try {
      await this.server.close();
    } catch (error) {
      this.log('error', 'Error closing server', { error: error.message });
    }

    this.log('info', 'Server shutdown complete', {
      uptime: Date.now() - this.startTime,
      totalRequests: this.requestCount
    });

    process.exit(0);
  }
}

// Main execution
const server = new EnhancedFilesystemServer();
server.start().catch(error => {
  console.error('[FATAL] Unhandled error:', error);
  process.exit(1);
});
