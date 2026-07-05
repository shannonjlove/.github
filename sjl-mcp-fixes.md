# SJL MCP Crash Loop Fix

## Issue
The sjl-mcp-claude (now sjl-mcp-quadlet) container was in a crash loop due to an incompatible FastMCP() constructor call.

## Root Cause
The FastMCP() constructor in `/opt/sjl-mcp/server.py` was being called with unsupported keyword arguments:
```python
mcp = FastMCP(
    name="SJL MCP Server",
    version="1.3",                    # ❌ Not supported
    description="Claude + Oracle..."  # ❌ Not supported
)
```

The current fastmcp version only supports the `name=` parameter.

## Solution Applied
Removed unsupported parameters from FastMCP() constructor and upgraded server.py with:
- Proper error handling and logging
- File read size limits (1 MB max)
- Better OCI compartment handling
- Safer subprocess execution
- Removed unused imports (boto3, Optional)

### Fixed FastMCP Call
```python
mcp = FastMCP(name="SJL MCP Server")
```

## Deployment
- **VPS Path**: `/opt/sjl-mcp/server.py`
- **Quadlet**: `/etc/containers/systemd/sjl-mcp-quadlet.container`
- **Service**: `sjl-mcp-quadlet.service`

### Restart Command
```bash
sudo systemctl daemon-reload
sudo systemctl restart sjl-mcp-quadlet.service
```

## Status
✅ **FIXED** - Service now runs without crash loop (as of 2026-07-05 03:57:18 UTC)

## Changes
- FastMCP() constructor syntax corrected
- Code quality improvements (logging, error handling, security)
- Better environment variable validation at startup
- OCI configuration improvements with fallback handling
