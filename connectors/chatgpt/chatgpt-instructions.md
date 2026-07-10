# ChatGPT Custom Action Setup Instructions

## Step-by-Step Guide to Enable SJL MCP Filesystem in ChatGPT

### Prerequisites
- ✅ ChatGPT Plus or Enterprise subscription
- ✅ Bearer token from infrastructure team
- ✅ Access to https://chatgpt.com/gpts/editor

### Setup Process (5 minutes)

#### Step 1: Navigate to Custom Actions
1. Go to [ChatGPT.com](https://chatgpt.com)
2. Click **Profile icon** (bottom left)
3. Select **Settings**
4. Navigate to **Developer Settings** → **Custom Actions**
5. Click **+ Create new action**

#### Step 2: Basic Information
Fill in the action details:

| Field | Value |
|-------|-------|
| **Name** | `SJL MCP Filesystem` |
| **Description** | `Model Context Protocol filesystem service for reading and writing files` |
| **Logo URL** | (Optional) |
| **Category** | `Infrastructure` or `Utilities` |

#### Step 3: API Configuration

**Set the API endpoint:**

| Field | Value |
|-------|-------|
| **Base URL** | `https://72.61.74.250:8813` |
| **API Endpoint Path** | `/api/tools/call` |
| **Content Type** | `application/json` |
| **Request Method** | `POST` |

#### Step 4: Authentication Configuration

1. Click **Authentication** section
2. Select **Auth Type:** `Bearer Token`
3. Set **Header Name:** `Authorization`
4. Set **Token Value:** `Bearer YOUR-TOKEN-HERE`
   - Replace `YOUR-TOKEN-HERE` with actual token from infrastructure team
   - Full format example: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**Or use environment variable:**
```json
{
  "auth_type": "bearer",
  "header": "Authorization",
  "token_env": "SJL_MCP_TOKEN"
}
```

#### Step 5: Import OpenAPI Schema (Recommended)

**Option A: Direct URL**
1. Click **Import Schema**
2. Select **From URL**
3. Enter: `https://raw.githubusercontent.com/shannonjlove/.github/claude/chatgpt-connectors-write-access-agtyc7/connectors/chatgpt/openapi-schema.json`
4. Click **Import**

**Option B: Manual Upload**
1. Copy contents of `openapi-schema.json` from this directory
2. Click **Manual Setup**
3. Paste the JSON schema
4. Click **Import**

#### Step 6: Enable Tools/Methods

Verify these tools are enabled:

- ✅ **read_file**
  - Purpose: Read file content
  - Requires auth: Yes
  - Write capable: No

- ✅ **write_file**
  - Purpose: Create/modify files
  - Requires auth: Yes
  - Write capable: **YES**
  - Confirm before execution: **RECOMMENDED**

- ✅ **list_directory**
  - Purpose: List directory contents
  - Requires auth: Yes
  - Write capable: No

- ✅ **search_files**
  - Purpose: Search for files
  - Requires auth: Yes
  - Write capable: No

- ✅ **get_file_info**
  - Purpose: Get file metadata
  - Requires auth: Yes
  - Write capable: No

- ⚠️ **delete_file** (OPTIONAL)
  - Purpose: Delete files
  - Requires auth: Yes
  - Write capable: **YES** (DESTRUCTIVE)
  - Status: **DISABLED by default** (enable only if needed)

- ✅ **create_directory**
  - Purpose: Create directories
  - Requires auth: Yes
  - Write capable: Yes

#### Step 7: Test Connection

1. Click **Test Connection**
2. You should see:
   ```
   ✅ Connection successful
   ✅ Authentication verified
   ✅ API responding normally
   ```

**If connection fails:**
- Verify bearer token is correct
- Check token starts with `Bearer `
- Verify token hasn't expired
- Check firewall allows port 8813

#### Step 8: Advanced Settings (Optional)

**Rate Limiting:**
```
Requests per hour: 1000
Concurrent requests: 10
Burst limit: 100
```

**Timeout:**
```
Request timeout: 30 seconds
Connection timeout: 10 seconds
```

**Error Handling:**
```
Retry on failure: Enabled
Max retries: 3
Exponential backoff: Enabled
```

**Logging:**
```
Log requests: Disabled (for security)
Log responses: Enabled
Log errors: Enabled
Log tokens: NEVER
```

#### Step 9: Security Configuration

**Allowed Paths:**
```
✅ /home/user/.github/infrastructure/
✅ /home/user/.github/infrastructure/event-logging/
✅ /var/lib/para-codes/
✅ /var/log/phase2/
```

**Blocked Paths:**
```
❌ /etc/
❌ /root/
❌ /sys/
❌ /proc/
```

**Confirmation Settings:**
```
Write operations: Require confirmation
Delete operations: Require confirmation
System paths: Block access
```

#### Step 10: Save and Publish

1. Click **Save Action**
2. Name the action: `SJL MCP Filesystem`
3. Click **Publish** (or **Save Draft** to test first)

### First Test

Try these commands in ChatGPT:

#### Test 1: List Files (Safe, Read-Only)
```
"List the files in /home/user/.github/infrastructure/"
```

Expected response:
```
Listing directory: /home/user/.github/infrastructure/
- PHASE2_DEPLOY_ALL.sh
- README.md
- config.json
...
```

#### Test 2: Read a File (Read-Only)
```
"Read the PHASE2_DEPLOY_ALL.sh file from /home/user/.github/infrastructure/ and summarize what it does"
```

Expected response:
```
[Script content retrieved]
This script handles Phase 2 deployment by...
```

#### Test 3: Create a Test File (Write Operation)
```
"Create a test file at /home/user/.github/infrastructure/test-chatgpt.txt with content: 'This file was created by ChatGPT via SJL MCP Filesystem on [date]'"
```

Expected response:
```
✅ File created successfully
Path: /home/user/.github/infrastructure/test-chatgpt.txt
Size: 123 bytes
Permissions: 644
Backup: None (new file)
```

#### Test 4: Search for Files (Read-Only)
```
"Find all shell scripts (.sh files) in /home/user/.github/infrastructure/"
```

Expected response:
```
Found 5 shell scripts:
- PHASE2_DEPLOY_ALL.sh
- deploy.sh
- setup.sh
...
```

### Troubleshooting During Setup

#### "Invalid Schema" Error
- **Cause:** Malformed OpenAPI schema
- **Solution:** Use the pre-provided `openapi-schema.json` file
- **Alternative:** Manually configure each tool

#### "Authentication Failed" Error
- **Cause:** Invalid bearer token
- **Solution:**
  1. Check token starts with `Bearer `
  2. Verify token hasn't expired
  3. Regenerate token from infrastructure team
  4. Test with curl: 
     ```bash
     curl -H "Authorization: $SJL_MCP_TOKEN" \
       https://72.61.74.250:8813/api/tools/call
     ```

#### "Connection Refused" Error
- **Cause:** Service not accessible
- **Solution:**
  1. Check if service is running: `ssh root@72.61.74.250 "systemctl status sjl-mcp-file"`
  2. Verify firewall: `ssh root@72.61.74.250 "ufw status | grep 8813"`
  3. Check network: `ping 72.61.74.250`

#### "Invalid Endpoint" Error
- **Cause:** Wrong API path
- **Solution:** Ensure endpoint is `/api/tools/call` (with leading slash)

#### "Timeout" Error
- **Cause:** Service taking too long to respond
- **Solution:**
  1. Check service logs: `ssh root@72.61.74.250 "journalctl -u sjl-mcp-file -n 20"`
  2. Verify server resources: `ssh root@72.61.74.250 "top -b -n1"`
  3. Retry the request

### After Successful Setup

1. ✅ Use `read_file` for reading scripts and configs
2. ✅ Use `write_file` for creating/modifying files
3. ✅ Use `list_directory` to explore structure
4. ✅ Use `search_files` to find files
5. ⚠️ Be careful with `delete_file` (disabled by default)

### Best Practices

**DO:**
- ✅ Test with read-only operations first
- ✅ Ask ChatGPT to confirm before writing
- ✅ Create backups of important files
- ✅ Use absolute paths
- ✅ Keep token secure and rotate regularly

**DON'T:**
- ❌ Write to system directories (/etc/, /root/, etc.)
- ❌ Delete files without backup
- ❌ Share your token
- ❌ Commit token to version control
- ❌ Use relative paths

### Configuration Checklist

- [ ] Bearer token obtained from infrastructure team
- [ ] Custom Action created in ChatGPT settings
- [ ] Base URL set to `https://72.61.74.250:8813`
- [ ] API endpoint set to `/api/tools/call`
- [ ] Bearer token configured in authentication
- [ ] OpenAPI schema imported successfully
- [ ] All 7 tools enabled and visible
- [ ] Test connection passes
- [ ] Read test successful (list files)
- [ ] Write test successful (create test file)
- [ ] Action saved and published

### Quick Reference

```
Service: sjl-mcp-filesystem
Host: 72.61.74.250
Port: 8813
Protocol: HTTPS
Auth: Bearer Token (JWT)
Endpoint: /api/tools/call

Rate Limit: 1000 requests/hour
Timeout: 30 seconds
Max File Size: 50 MB

Write-Enabled Paths:
  /home/user/.github/infrastructure/
  /var/lib/para-codes/
  /var/log/phase2/
```

### Getting Help

1. **Setup issues:** See SETUP_GUIDE.md
2. **API documentation:** See openapi-schema.json
3. **Code examples:** See python-client-example.py
4. **Service status:** https://72.61.74.250:8813/health

### Support

Infrastructure Team: infrastructure@shannonjlove.com

---

**Last Updated:** July 10, 2026
