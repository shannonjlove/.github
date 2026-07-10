# ChatGPT Custom Action Setup - SJL MCP Filesystem

## Overview

This guide enables ChatGPT (via Custom Actions) to read and write files through the **sjl-mcp-filesystem** service with Bearer token authentication.

**Service Details:**
- **Host:** `72.61.74.250`
- **Port:** `8813`
- **Protocol:** HTTPS
- **Authentication:** Bearer Token (JWT)

## Prerequisites

1. **Bearer Token** - Obtain from the infrastructure team
2. **ChatGPT Plus/Enterprise** - Custom Actions require paid tier
3. **File Access Paths** - Must be within approved directories:
   - `/home/user/.github/infrastructure/`
   - `/home/user/.github/infrastructure/event-logging/`
   - `/var/lib/para-codes/`
   - `/var/log/phase2/`

## Setup Instructions

### Step 1: Access ChatGPT Custom Actions

1. Go to [ChatGPT.com](https://chatgpt.com)
2. Click your **Profile** → **Settings**
3. Navigate to **Developer Settings** → **Custom Actions**
4. Click **Create new action** or **Import from URL**

### Step 2: Configure the Action

#### Option A: Manual Configuration

1. **Name:** `SJL MCP Filesystem`
2. **Description:** `Model Context Protocol filesystem service for reading and writing files`

#### Option B: Import Schema

1. Click **Import from URL**
2. Paste this URL: `https://raw.githubusercontent.com/shannonjlove/.github/claude/chatgpt-connectors-write-access-agtyc7/connectors/chatgpt/openapi-schema.json`
3. Click **Import**

### Step 3: Configure Authentication

1. In the **Authentication** section, select **API Key**
2. Set **Auth Type** to **Bearer Token**
3. **Header Name:** `Authorization`
4. **Token Value:** `Bearer YOUR-TOKEN-HERE` (obtain from infrastructure team)

**Alternative - Environment Variable:**
```
If your ChatGPT integration supports env vars, set:
SJL_MCP_TOKEN=Bearer YOUR-TOKEN-HERE
```

### Step 4: Set the API Endpoint

1. **Base URL:** `https://72.61.74.250:8813`
2. **API Endpoint:** `/api/tools/call`
3. Click **Test connection** to verify

### Step 5: Configure Tool Settings

In the **Tools** section, ensure these tools are enabled:

- ✅ **read_file** - Read file content
- ✅ **write_file** - Write/create files (requires write permission token)
- ✅ **list_directory** - List directory contents
- ✅ **search_files** - Search for files
- ✅ **get_file_info** - Get file metadata
- ✅ **delete_file** - Delete files (use with caution)
- ✅ **create_directory** - Create directories

### Step 6: Save and Test

1. Click **Create Action**
2. Test with a simple query:
   ```
   "List the files in /home/user/.github/infrastructure/"
   ```

## Usage Examples

### Example 1: Read a Deployment Script

```
User: "Can you read the PHASE2_DEPLOY_ALL.sh script from /home/user/.github/infrastructure/?"

ChatGPT will:
1. Call read_file with path: /home/user/.github/infrastructure/PHASE2_DEPLOY_ALL.sh
2. Retrieve and display the script content
3. Allow you to ask questions about it
```

### Example 2: Create a New Configuration File

```
User: "Create a new deployment configuration file at /home/user/.github/infrastructure/deploy-config.json with the following settings: ..."

ChatGPT will:
1. Call write_file with the specified path and content
2. Set appropriate file permissions (default 644)
3. Optionally backup the existing file
4. Confirm the write was successful
```

### Example 3: Search for Deployment Scripts

```
User: "Find all shell scripts in the infrastructure directory"

ChatGPT will:
1. Call search_files with pattern: *.sh
2. Return list of matching files
3. Allow you to read or modify them
```

## Write Access Configuration

### Enabling Write Operations

The connector is configured with **write access enabled**. Here's what that means:

**Write-Enabled Tools:**
- `write_file` - Create and modify files
- `delete_file` - Remove files (use carefully!)
- `create_directory` - Create new directories

**Write-Protected Paths (Read-Only):**
- `/etc/` (system configuration)
- `/usr/` (system binaries)
- `/root/` (restricted access)

**Write-Enabled Paths:**
- `/home/user/.github/infrastructure/` ✅
- `/home/user/.github/infrastructure/event-logging/` ✅
- `/var/lib/para-codes/` ✅
- `/var/log/phase2/` ✅

### Security Considerations

1. **Token Protection:**
   - Never share your Bearer token
   - Rotate tokens every 90 days
   - Use separate tokens per environment

2. **File Backups:**
   - Enable `backup_existing: true` when writing critical files
   - Backups are stored in `.backups/` subdirectory

3. **Audit Logging:**
   - All operations are logged server-side
   - Monitor access logs for suspicious activity

4. **Permissions:**
   - Be explicit with file permissions (default: 644)
   - Executable scripts should use 755

## Troubleshooting

### "Authentication Failed" Error

**Issue:** Invalid or missing Bearer token

**Solutions:**
1. Verify token format: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
2. Check token hasn't expired
3. Regenerate token from infrastructure team
4. Update in ChatGPT settings

### "Connection Refused" Error

**Issue:** Can't reach the MCP service

**Solutions:**
1. Verify endpoint: `https://72.61.74.250:8813/health`
2. Check network connectivity
3. Verify firewall allows port 8813
4. Service may be temporarily unavailable (check status page)

### "File Not Found" Error

**Issue:** Trying to read/write non-existent path

**Solutions:**
1. Always use absolute paths (e.g., `/home/user/.github/infrastructure/file.sh`)
2. Verify file exists before reading
3. Enable `create_dirs: true` when writing to new directories

### "Permission Denied" Error

**Issue:** Insufficient permissions for operation

**Solutions:**
1. Check if path is in write-enabled list (see above)
2. Verify file permissions on server
3. Contact infrastructure team for access to restricted paths

### "Rate Limited" Error

**Issue:** Too many requests (max 1000/hour)

**Solutions:**
1. Implement request batching
2. Cache file reads when possible
3. Use `get_file_info` to check existence without reading content
4. Wait 1 hour before retrying

## Advanced Configuration

### Custom Request Headers

If your ChatGPT setup allows custom headers, you can add:

```json
{
  "header_name": "X-Request-ID",
  "header_value": "chatgpt-{timestamp}"
}
```

### Rate Limiting Configuration

Default limits (per token):
- 1000 requests per hour
- 10 concurrent requests
- 100 requests per minute burst

Contact infrastructure team to increase limits if needed.

### TLS/SSL Verification

The service uses standard HTTPS (TLS 1.2+). Certificate verification is enabled by default.

To verify certificate:
```bash
openssl s_client -connect 72.61.74.250:8813 -showcerts
```

## Support

### Escalation Path

1. **Basic Issues:** Check Troubleshooting section above
2. **Token Problems:** Contact infrastructure team
3. **Service Issues:** SSH to VPS and check service status:
   ```bash
   ssh root@72.61.74.250 "systemctl status sjl-mcp-file"
   ```
4. **Advanced Issues:** Review service logs:
   ```bash
   ssh root@72.61.74.250 "journalctl -u sjl-mcp-file -n 50"
   ```

### Documentation

- **OpenAPI Schema:** See `openapi-schema.json` in this directory
- **Technical Reference:** See `SJL_MCP_TOOL_TECHNICAL_HANDOFF.md` in parent directory
- **Service Guide:** See `SJL_MCP_FILESYSTEM_HANDOFF.md` in parent directory

## Security Best Practices

### Token Management

✅ **DO:**
- Store token in ChatGPT's secure settings
- Rotate tokens every 90 days
- Use separate tokens for different ChatGPT instances
- Log all file access operations

❌ **DON'T:**
- Share tokens via email or chat
- Commit tokens to version control
- Use the same token across multiple users
- Log tokens in debug output

### File Access

✅ **DO:**
- Use absolute paths only
- Verify paths are whitelisted
- Enable backups for important files
- Document changes made via ChatGPT

❌ **DON'T:**
- Write to system directories
- Overwrite critical infrastructure files without backup
- Use overly permissive file permissions (644 is default)
- Execute arbitrary commands (use write_file + manual execution)

## Next Steps

1. ✅ Set up ChatGPT Custom Action (steps 1-6 above)
2. ✅ Configure Bearer token authentication
3. ✅ Test read access with example files
4. ✅ Test write access with non-critical files
5. ✅ Enable for production use after validation

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-07-10 | Initial release - ChatGPT custom action with write access |

## Support Contact

For issues or questions:
- **Infrastructure Team:** infrastructure@shannonjlove.com
- **Service Status:** https://72.61.74.250:8813/health
- **Documentation:** This directory

---

**Last Updated:** July 10, 2026  
**Next Review:** After ChatGPT integration testing
