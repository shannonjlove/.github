# ChatGPT Custom Action Setup - Copy-Paste Ready

## Step-by-Step Instructions

### 1. Go to ChatGPT Settings
- Open: https://chatgpt.com
- Click profile icon (bottom left)
- Select: **Settings**
- Go to: **Integrations**

### 2. Create New Action
- Click: **Actions** (left menu)
- Click: **Create new action**

---

## COPY-PASTE VALUES

### Step 3: Basic Information

**Name:**
```
SJL MCP Filesystem
```

**Description:**
```
Read and write files with automatic backups
```

**Action URL:**
```
https://72.61.74.250:8813
```

---

### Step 4: OpenAPI Schema

In the **Schema** field, paste this entire JSON:

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "SJL MCP Filesystem Service",
    "description": "Model Context Protocol (MCP) filesystem service providing secure, authenticated file access with read/write capabilities",
    "version": "1.0.0",
    "contact": {
      "name": "Infrastructure Team",
      "url": "https://github.com/shannonjlove"
    }
  },
  "servers": [
    {
      "url": "https://72.61.74.250:8813",
      "description": "SJL MCP Filesystem Service - Production"
    }
  ],
  "security": [
    {
      "bearerAuth": []
    }
  ],
  "paths": {
    "/api/tools/call": {
      "post": {
        "summary": "Call MCP Tools",
        "description": "Call any available MCP tool/method on the filesystem service",
        "operationId": "callMcpTool",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/MpcRequest"
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Tool call successful",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MpcResponse"
                }
              }
            }
          },
          "400": {
            "description": "Invalid request"
          },
          "401": {
            "description": "Unauthorized - Invalid or missing Bearer token"
          },
          "429": {
            "description": "Rate limit exceeded"
          },
          "500": {
            "description": "Internal server error"
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "MpcRequest": {
        "type": "object",
        "required": ["jsonrpc", "method", "params", "id"],
        "properties": {
          "jsonrpc": {
            "type": "string",
            "const": "2.0",
            "description": "JSON-RPC version"
          },
          "method": {
            "type": "string",
            "const": "tools/call",
            "description": "MCP method to call"
          },
          "params": {
            "type": "object",
            "required": ["name", "arguments"],
            "properties": {
              "name": {
                "type": "string",
                "enum": [
                  "read_file",
                  "write_file",
                  "delete_file",
                  "list_directory",
                  "search_files",
                  "get_file_info",
                  "create_directory"
                ],
                "description": "Tool/method name to call"
              },
              "arguments": {
                "type": "object",
                "description": "Tool-specific arguments (varies by tool)"
              }
            }
          },
          "id": {
            "type": "string",
            "description": "Unique request identifier"
          }
        }
      },
      "MpcResponse": {
        "type": "object",
        "properties": {
          "jsonrpc": {
            "type": "string"
          },
          "id": {
            "type": "string"
          },
          "result": {
            "type": "object",
            "description": "Success result containing tool output"
          },
          "error": {
            "type": "object",
            "properties": {
              "code": {
                "type": "integer"
              },
              "message": {
                "type": "string"
              },
              "data": {
                "type": "object"
              }
            }
          }
        }
      }
    },
    "securitySchemes": {
      "bearerAuth": {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
        "description": "Bearer token authentication. Format: 'Bearer YOUR-TOKEN-HERE'"
      }
    }
  },
  "x-chatgpt": {
    "tools": [
      {
        "id": "read-file",
        "name": "Read File",
        "description": "Read content from a file",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "Absolute path to file (e.g., /home/user/.github/infrastructure/script.sh)"
            },
            "encoding": {
              "type": "string",
              "enum": ["utf-8", "base64"],
              "default": "utf-8",
              "description": "File encoding"
            }
          },
          "required": ["path"]
        }
      },
      {
        "id": "write-file",
        "name": "Write File",
        "description": "Write content to a file (create or overwrite)",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "Absolute path to file (e.g., /home/user/.github/infrastructure/script.sh)"
            },
            "content": {
              "type": "string",
              "description": "File content to write"
            },
            "mode": {
              "type": "string",
              "default": "644",
              "description": "File permissions (e.g., 644, 755)"
            },
            "create_dirs": {
              "type": "boolean",
              "default": true,
              "description": "Create parent directories if they don't exist"
            },
            "backup_existing": {
              "type": "boolean",
              "default": true,
              "description": "Backup existing file before overwrite"
            }
          },
          "required": ["path", "content"]
        }
      },
      {
        "id": "list-directory",
        "name": "List Directory",
        "description": "List contents of a directory",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "Directory path (e.g., /home/user/.github/infrastructure/)"
            },
            "recursive": {
              "type": "boolean",
              "default": false,
              "description": "List recursively"
            },
            "filter": {
              "type": "string",
              "description": "Glob pattern filter (e.g., *.sh)"
            }
          },
          "required": ["path"]
        }
      },
      {
        "id": "search-files",
        "name": "Search Files",
        "description": "Search for files by name or content pattern",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "Search path"
            },
            "pattern": {
              "type": "string",
              "description": "Search pattern (glob or regex)"
            },
            "search_type": {
              "type": "string",
              "enum": ["name", "content", "regex"],
              "default": "name",
              "description": "Type of search"
            },
            "recursive": {
              "type": "boolean",
              "default": true,
              "description": "Search recursively"
            }
          },
          "required": ["path", "pattern"]
        }
      },
      {
        "id": "get-file-info",
        "name": "Get File Info",
        "description": "Get metadata about a file without reading content",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "File path"
            }
          },
          "required": ["path"]
        }
      },
      {
        "id": "delete-file",
        "name": "Delete File",
        "description": "Delete a file or directory",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "File or directory path to delete"
            },
            "recursive": {
              "type": "boolean",
              "default": false,
              "description": "Recursively delete directories and contents"
            }
          },
          "required": ["path"]
        }
      },
      {
        "id": "create-directory",
        "name": "Create Directory",
        "description": "Create a new directory",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {
              "type": "string",
              "description": "Directory path to create"
            },
            "mode": {
              "type": "string",
              "default": "755",
              "description": "Directory permissions"
            }
          },
          "required": ["path"]
        }
      }
    ]
  }
}
```

### Step 5: Authentication

**Authentication Type:** Select `Bearer`

**Token:** Paste this exact value (including `Bearer` prefix)
```
Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687
```

### Step 6: Save & Test

1. Click **Save**
2. In a ChatGPT chat, type:
   ```
   List files in /home/user/.github/infrastructure/
   ```
3. Should return file listing ✅

---

## Available Tools After Setup

Once saved, you'll have access to 7 tools:

1. **Read File** - Read file contents
2. **Write File** - Create/modify files (with automatic backup)
3. **List Directory** - Show directory contents
4. **Search Files** - Find files by pattern
5. **Get File Info** - Get file metadata
6. **Delete File** - Remove files (optional)
7. **Create Directory** - Make new directories

---

## Troubleshooting

**Schema validation error?**
- Make sure entire JSON block is pasted (no truncation)
- Check for extra spaces or line breaks

**Unauthorized (401)?**
- Verify Bearer token is correct
- Token should start with "Bearer " prefix

**Rate limited (429)?**
- Wait 1 hour before retrying
- Service allows 1000 requests/hour

---

**Setup file location:** `/home/user/chatgpt-connectors-bundles/CHATGPT_SETUP_READY.md`
