# Claude Desktop MCP Setup - Ready to Use

## Quick Setup (2 minutes)

### Option 1: Copy Settings File (Easiest)

1. **Download the file:**
   - `claude-settings.json` (from this bundle)

2. **Replace your Claude Desktop settings:**
   - **Mac:** `~/.claude/settings.json`
   - **Windows:** `%APPDATA%\.claude\settings.json`
   - **Linux:** `~/.claude/settings.json`

3. **Restart Claude Desktop** (close & reopen)

4. **Test it:**
   - In Claude chat, use `/mcp` command
   - Should show `sjl-mcp-filesystem` as available ✅

---

### Option 2: Manual Copy-Paste

If you have existing settings, add this section to your `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "sjl-mcp-filesystem": {
      "command": "curl",
      "args": [
        "-X",
        "POST",
        "https://72.61.74.250:8813/api/tools/call"
      ],
      "env": {
        "AUTHORIZATION": "Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"
      }
    }
  }
}
```

---

## What's Included

✅ **Server URL:** `https://72.61.74.250:8813`
✅ **Bearer Token:** Pre-configured (your token)
✅ **Authentication:** Automatic via environment variable
✅ **All 7 Tools Ready:**
- read_file
- write_file
- list_directory
- search_files
- get_file_info
- create_directory
- delete_file

---

## Testing

After setting up, test with:

```
/mcp list
```

Should show:
```
✅ sjl-mcp-filesystem - active
```

Then try in a message:
```
List files in /home/user/.github/infrastructure/
```

Should return file listing from that directory ✅

---

## Troubleshooting

**"Connection refused" error?**
- Verify server is running: `curl https://72.61.74.250:8813/health`
- Check network connectivity

**"Unauthorized" (401)?**
- Token may have expired
- Replace with new token if needed
- Edit `~/.claude/settings.json` and update `AUTHORIZATION` value

**Settings file not found?**
- Create `~/.claude/` directory first:
  ```bash
  mkdir -p ~/.claude
  ```
- Then copy settings file there

**Claude Desktop not recognizing MCP server?**
- Fully restart Claude Desktop (not just close)
- Check file is at correct path
- Verify JSON syntax is valid

---

## File Locations

- **Settings file:** `~/.claude/settings.json`
- **Logs:** `~/.claude/logs/`
- **Cache:** `~/.claude/cache/`

---

## Security Note

This file contains your Bearer token. Keep it safe:
- ✅ Store in secure location
- ❌ Don't commit to git
- ❌ Don't share with others
- 🔄 Rotate token every 90 days

---

**Setup Time:** 2 minutes
**Ready to Use:** Yes ✅
**All Tools:** Enabled ✅
