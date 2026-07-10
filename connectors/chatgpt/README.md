# ChatGPT Connectors - SJL MCP Filesystem Service

This directory contains everything needed to integrate ChatGPT with the **sjl-mcp-filesystem** service, enabling read and write access to files through ChatGPT's Custom Actions feature.

## What's Included

### Documentation

- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Step-by-step guide for setting up ChatGPT Custom Actions
- **[README.md](./README.md)** - This file

### Configuration Files

- **[openapi-schema.json](./openapi-schema.json)** - OpenAPI schema for the MCP Filesystem API
  - Complete API specification
  - All 7 tools defined with parameters
  - ChatGPT-specific extensions
  
- **[action-config-example.json](./action-config-example.json)** - Example ChatGPT Custom Action configuration
  - Reference settings for each tool
  - Security configuration
  - Rate limiting and error handling

### Code Examples

- **[python-client-example.py](./python-client-example.py)** - Python client library
  - Command-line interface for testing
  - Reusable `MCPFilesystemClient` class
  - Full error handling

## Quick Start

### For ChatGPT Users

1. Read [SETUP_GUIDE.md](./SETUP_GUIDE.md)
2. Obtain Bearer token from infrastructure team
3. Create ChatGPT Custom Action with the OpenAPI schema
4. Configure authentication with your token
5. Test with example queries

### For Developers

1. Review [openapi-schema.json](./openapi-schema.json) for API specification
2. Study [python-client-example.py](./python-client-example.py) for integration patterns
3. Implement client in your preferred language
4. Test with the command-line examples

## Service Details

| Property | Value |
|----------|-------|
| **Host** | `72.61.74.250` |
| **Port** | `8813` |
| **Protocol** | HTTPS |
| **Authentication** | Bearer Token (JWT) |
| **API Endpoint** | `/api/tools/call` |

## Capabilities

### Read Operations (No Confirmation)

- ✅ **read_file** - Read file content
- ✅ **list_directory** - List directory contents
- ✅ **search_files** - Search by name, content, or regex
- ✅ **get_file_info** - Get file metadata

### Write Operations (Requires Confirmation)

- ✅ **write_file** - Create/modify files with automatic backups
- ✅ **create_directory** - Create directories
- ✅ **delete_file** - Delete files (optional, disabled by default)

## File Access Paths

### Write-Enabled Paths ✅
```
/home/user/.github/infrastructure/
/home/user/.github/infrastructure/event-logging/
/var/lib/para-codes/
/var/log/phase2/
```

### Read-Only Paths
```
/usr/local/go/
/usr/local/bin/
/var/log/
```

### Blocked Paths ❌
```
/etc/
/root/
/sys/
/proc/
```

## Usage Examples

### Reading a Script

```
User: "Read the PHASE2_DEPLOY_ALL.sh script from /home/user/.github/infrastructure/"

ChatGPT calls: read_file(path: "/home/user/.github/infrastructure/PHASE2_DEPLOY_ALL.sh")
Returns: Full script content
```

### Creating a Configuration File

```
User: "Create a new deployment config at /home/user/.github/infrastructure/config.json with these settings: ..."

ChatGPT calls: write_file(
  path: "/home/user/.github/infrastructure/config.json",
  content: "{ ... }",
  mode: "644",
  backup_existing: true
)
Returns: Success confirmation with metadata
```

### Searching for Files

```
User: "Find all shell scripts in the infrastructure directory"

ChatGPT calls: search_files(
  path: "/home/user/.github/infrastructure/",
  pattern: "*.sh",
  search_type: "name"
)
Returns: List of matching files
```

## Authentication Setup

### Method 1: ChatGPT UI (Recommended)

1. Open ChatGPT Settings → Developer Settings → Custom Actions
2. Create new action with OpenAPI schema
3. Set Authentication Type: **Bearer Token**
4. Paste token from infrastructure team

### Method 2: Environment Variable

```bash
export SJL_MCP_TOKEN="Bearer YOUR-TOKEN-HERE"
# Python client will use this automatically
python3 python-client-example.py --list /home/user/.github/infrastructure/
```

### Method 3: Command-line (Development)

```bash
python3 python-client-example.py \
  --token "YOUR-TOKEN-HERE" \
  --read /path/to/file
```

## Security

### Token Management

- **Storage:** Use ChatGPT's secure settings, not local files
- **Rotation:** Rotate every 90 days
- **Sharing:** Never share via email or chat
- **Logging:** Tokens are never logged or output

### File Operations

- **Backups:** Automatic backups created before file modifications
- **Permissions:** Default 644 for files, 755 for directories
- **Audit:** All operations logged server-side
- **Confirmation:** Write operations require explicit confirmation

### Network Security

- **TLS 1.2+:** Required for all connections
- **Certificate Verification:** Enabled by default
- **Rate Limiting:** 1000 requests/hour per token
- **Timeout:** 30 seconds per request

## Troubleshooting

### "Unauthorized" Error

**Problem:** Bearer token validation fails

**Solutions:**
1. Verify token format: `Bearer eyJhbGc...` (starts with "Bearer ")
2. Check token hasn't expired (contact infrastructure team)
3. Regenerate token if needed
4. Update token in ChatGPT settings

### "Connection Refused"

**Problem:** Can't reach service at 72.61.74.250:8813

**Solutions:**
1. Check network connectivity
2. Verify firewall allows port 8813
3. Service may be temporarily unavailable (check status)
4. SSH to server: `ssh root@72.61.74.250 "systemctl status sjl-mcp-file"`

### "Path Not Found"

**Problem:** File or directory doesn't exist

**Solutions:**
1. Verify absolute path (not relative)
2. Use `--list` to verify directory exists
3. Check path is in write-enabled list (above)
4. File may have been deleted recently

### "Permission Denied"

**Problem:** Operation not allowed on path

**Solutions:**
1. Verify path is in write-enabled list
2. Check if token has necessary permissions
3. Contact infrastructure team for restricted paths
4. Some paths are read-only by design

### "Rate Limited"

**Problem:** Too many requests (max 1000/hour)

**Solutions:**
1. Wait 1 hour before retrying
2. Implement request batching or caching
3. Use `get_file_info` instead of reading full content
4. Contact infrastructure team to increase limits

## Integration Examples

### With Python Applications

```python
from chatgpt_connectors import MCPFilesystemClient

client = MCPFilesystemClient(token="Bearer YOUR-TOKEN")

# Read
script_content = client.read_file("/home/user/.github/infrastructure/deploy.sh")

# Write
client.write_file(
    path="/home/user/.github/infrastructure/config.json",
    content='{"key": "value"}',
    backup_existing=True
)

# List
files = client.list_directory("/home/user/.github/infrastructure/")

# Search
matches = client.search_files(
    path="/home/user/.github/infrastructure/",
    pattern="*.sh"
)
```

### With Bash Scripts

```bash
#!/bin/bash

TOKEN="Bearer YOUR-TOKEN-HERE"
HOST="72.61.74.250:8813"

# Read file
curl -X POST https://$HOST/api/tools/call \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "read_file",
      "arguments": {
        "path": "/home/user/.github/infrastructure/script.sh"
      }
    },
    "id": "1"
  }'

# Write file
curl -X POST https://$HOST/api/tools/call \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "write_file",
      "arguments": {
        "path": "/home/user/.github/infrastructure/new-file.sh",
        "content": "#!/bin/bash\necho Hello",
        "mode": "755"
      }
    },
    "id": "2"
  }'
```

### With JavaScript/Node.js

```javascript
const axios = require('axios');

const client = axios.create({
  baseURL: 'https://72.61.74.250:8813',
  headers: {
    'Authorization': 'Bearer YOUR-TOKEN-HERE',
    'Content-Type': 'application/json'
  }
});

// Read file
async function readFile(path) {
  const response = await client.post('/api/tools/call', {
    jsonrpc: '2.0',
    method: 'tools/call',
    params: {
      name: 'read_file',
      arguments: { path }
    },
    id: '1'
  });
  return response.data.result.content;
}

// Write file
async function writeFile(path, content) {
  const response = await client.post('/api/tools/call', {
    jsonrpc: '2.0',
    method: 'tools/call',
    params: {
      name: 'write_file',
      arguments: {
        path,
        content,
        backup_existing: true
      }
    },
    id: '2'
  });
  return response.data.result;
}
```

## Performance

### Rate Limits

- **1000 requests/hour** per token
- **10 concurrent requests** max
- **100 requests/minute** burst limit
- **30 second** timeout per request

### Optimization Tips

1. **Batch operations:** Combine multiple file reads
2. **Cache results:** Store frequently accessed file contents
3. **Use get_file_info:** Check existence without reading full content
4. **Filter early:** Use `search_files` pattern to reduce results

### Large Files

- **Max file size:** 50 MB
- **For larger files:** Split into chunks and write sequentially
- **Binary files:** Automatically base64 encoded for transfer

## API Reference

See [openapi-schema.json](./openapi-schema.json) for complete API specification.

### Tools Available

| Tool | Purpose | Write Access |
|------|---------|--------------|
| `read_file` | Read file content | ❌ No |
| `write_file` | Create/modify files | ✅ Yes |
| `delete_file` | Delete files | ✅ Yes |
| `list_directory` | List directory contents | ❌ No |
| `search_files` | Search by pattern | ❌ No |
| `get_file_info` | Get file metadata | ❌ No |
| `create_directory` | Create directories | ✅ Yes |

## Support

### Getting Help

1. **Setup issues:** See [SETUP_GUIDE.md](./SETUP_GUIDE.md)
2. **API issues:** Check [openapi-schema.json](./openapi-schema.json)
3. **Code examples:** Review [python-client-example.py](./python-client-example.py)
4. **Service issues:** SSH to server and check logs

### Escalation Path

1. Check troubleshooting section (above)
2. Review documentation in this directory
3. Test with Python client example
4. Contact infrastructure team

### Service Status

```bash
# Check if service is running
curl https://72.61.74.250:8813/health

# SSH to server
ssh root@72.61.74.250

# Check service status
systemctl status sjl-mcp-file

# View logs
journalctl -u sjl-mcp-file -n 50 -f
```

## Development

### Testing Locally

```bash
# Set token
export SJL_MCP_TOKEN="Bearer YOUR-TOKEN-HERE"

# Test read
python3 python-client-example.py --read /home/user/.github/infrastructure/

# Test write
python3 python-client-example.py --write /tmp/test.txt "Hello World"

# Test list
python3 python-client-example.py --list /home/user/.github/infrastructure/

# Test search
python3 python-client-example.py --search /home/user/.github/ "*.sh"
```

### Building Custom Integrations

1. Start with [python-client-example.py](./python-client-example.py)
2. Understand the JSON-RPC request format
3. Implement retry logic with exponential backoff
4. Add proper error handling and logging
5. Test with all 7 tools before production

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-07-10 | Initial release - ChatGPT connectors with write access |

## License

Part of the SJL infrastructure management system.

## Contact

For questions, issues, or feature requests:
- Infrastructure Team: infrastructure@shannonjlove.com
- Service Status: https://72.61.74.250:8813/health
- Documentation: See files in this directory

---

**Last Updated:** July 10, 2026  
**Next Review:** After ChatGPT integration testing and deployment

**Note:** This directory is part of the `claude/chatgpt-connectors-write-access-agtyc7` branch. These connectors enable ChatGPT to read and write files through the sjl-mcp-filesystem service with proper authentication and security controls.
