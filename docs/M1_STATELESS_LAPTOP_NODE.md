# MacBook M1 as Stateless Laptop Node

Architecture for MacBook M1 as a development client in the shannonjlove.cloud ecosystem.

**Key Principle**: The laptop is replaceable. All persistent state lives in **idrive e2 S3**. The MacBook is just a thin terminal/interface.

## Architecture Overview

```
MacBook M1 (Stateless Workstation)
├── LOCAL (Non-sync, Machine-specific)
│   ├── ~/.claude/               # Claude Code config
│   ├── ~/.ssh/                  # SSH keys (private, never synced)
│   ├── ~/.aws/                  # AWS credentials
│   ├── ~/.gitconfig             # Git user config
│   ├── /opt/homebrew/           # System tools (Python, Node, etc.)
│   ├── ~/Library/Caches/        # Application caches
│   └── /tmp/                    # Temporary build artifacts
│
├── MOUNTED via rclone (S3-backed VFS)
│   ├── ~/PARA/                  ↔ s3://shannonjlove/para/
│   ├── ~/projects/              ↔ s3://shannonjlove/projects/
│   ├── ~/.claude-memory/        ↔ s3://shannonjlove/memories/
│   └── ~/Documents/             ↔ s3://shannonjlove/documents/
│
└── REMOTE (Cloud infrastructure)
    ├── Tailscale VPN (100.x.x.x)
    ├── Nexus (100.115.66.75:8100) - memory-agent
    ├── sOs (100.67.229.94) - Oracle Cloud
    └── idrive e2 S3 - canonical storage
```

## Setup Philosophy

### What If the Laptop Breaks?
✅ **Everything works from another machine** - just clone this setup.

### What Gets Backed Up?
✅ **idrive e2 S3** - canonical source of truth.

### What's Private to This Laptop?
✅ **SSH keys, AWS credentials** - kept local, never synced.

### What Gets Cached Locally?
✅ **Development tools, package caches** - recreated on setup.

## Storage Mapping

### PARA System
```
Local Mount:        ~/PARA/
↓ via rclone ↓
S3 Location:        s3://shannonjlove/para/
├── 1-PROJECTS/
├── 2-AREAS/
├── 3-RESOURCES/
├── 4-ARCHIVE/
└── 0-SYSTEM/
```

### Projects & Repositories
```
Local Mount:        ~/projects/
↓ via rclone ↓
S3 Location:        s3://shannonjlove/projects/
├── claude-memory-mcp/
├── github-mcp-server/
├── apple-notes-mcp/
└── [other repositories]/
```

### Claude Memory
```
Local Mount:        ~/.claude-memory/
↓ via rclone ↓
S3 Location:        s3://shannonjlove/memories/
├── conversations/
├── summaries/
└── context-snapshots/
```

### Documents & Media
```
Local Mount:        ~/Documents/
↓ via rclone ↓
S3 Location:        s3://shannonjlove/documents/
├── articles/
├── research/
└── media/
```

## Local Configuration Only

### ~/.claude/settings.json
```json
{
  "profile": "default",
  "shell": "zsh",
  "workspace": {
    "root": "~/projects",
    "auto_detect_repos": true
  },
  "mcpServers": {
    "claude-memory": {
      "command": "python3.11",
      "args": ["${HOME}/.local/lib/claude-memory/server.py"],
      "env": {
        "MEMORY_ROOT": "${HOME}/.claude-memory"
      }
    }
  }
}
```

### ~/.gitconfig
```
[user]
    name = Shannon Love
    email = sjlove@shannonjeffreylove.com
[core]
    editor = nano
[init]
    defaultBranch = main
```

### ~/.ssh/config
```
Host nexus
    HostName 100.115.66.75
    User ubuntu
    IdentityFile ~/.ssh/id_rsa

Host sos
    HostName 100.67.229.94
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
```

### ~/.aws/credentials
```
[default]
aws_access_key_id = YOUR_IDRIVE_E2_KEY
aws_secret_access_key = YOUR_IDRIVE_E2_SECRET
```

### ~/.config/rclone/rclone.conf
```
[idrive-e2]
type = s3
provider = Other
access_key_id = YOUR_KEY
secret_access_key = YOUR_SECRET
endpoint = your-idrive-e2-endpoint.com
region = us-east-1
```

## Installation Sequence

### Phase 1: System Baseline
- macOS updates
- Homebrew, Python 3.11, Node 20
- Git, SSH setup
- Tailscale VPN

### Phase 2: Development Tools
- Claude Code CLI
- VS Code
- rclone
- AWS CLI

### Phase 3: S3 Mounting
- Configure rclone for idrive e2
- Create mount points
- Mount ~/PARA, ~/projects, ~/.claude-memory
- Verify S3 access

### Phase 4: Cloud Connectivity
- Tailscale to VPN
- SSH aliases for Nexus/sOs
- Memory-agent URL (http://100.115.66.75:8100)

### Phase 5: Verification
- All mounts working
- S3 sync active
- Cloud access verified
- Ready for use

## Daily Workflow

### Morning Startup
```bash
# Terminal opens → shell profile runs:
# 1. rclone mounts check
mount | grep rclone  # Verify all S3 mounts active

# 2. Tailscale status
tailscale ip -4     # Verify VPN connected

# 3. S3 sync check (optional)
rclone sync --dry-run ~/PARA idrive-e2:shannonjlove/para/

# Ready to work!
cd ~/PARA/1-PROJECTS
cd ~/projects
```

### During Work
```bash
# Everything you edit syncs automatically to S3
# PARA updates sync instantly
# Projects sync via git + rclone VFS cache
# Memories sync to S3 in real-time
```

### End of Day
```bash
# Optional: explicit sync to cloud
rclone sync ~/PARA idrive-e2:shannonjlove/para/
rclone sync ~/projects idrive-e2:shannonjlove/projects/

# Verify: all changes in S3
rclone ls idrive-e2:shannonjlove/para/
```

## Disaster Recovery

### If Laptop Dies
```bash
# 1. Get new MacBook (or use another computer)
# 2. Run setup (Phase 1-5)
# 3. Mount S3 storage
# 4. Everything restored from idrive e2
# 5. Continue work exactly where you left off

# Timeline: ~2 hours to full restore
```

### What's Not Recovered?
- ❌ Homebrew packages → reinstalled
- ❌ Node/Python package caches → rebuilt
- ❌ SSH keys → restore from password manager
- ❌ AWS credentials → restore from secure backup

### What's Fully Recovered?
- ✅ All PARA files
- ✅ All projects and code
- ✅ All Claude memories
- ✅ Documents and media
- ✅ Git history
- ✅ All configuration

## Performance Considerations

### rclone VFS Caching
```
~/.config/rclone/rclone.conf:

[idrive-e2]
...
cache_dir = ~/.cache/rclone
vfs_cache_mode = writes
vfs_cache_max_size = 5G
vfs_read_ahead = 128k
```

**Result**: 
- Local cache for frequently accessed files
- Transparent sync to S3
- Fast access with cloud as source of truth

### Bandwidth
- Initial mount: ~instant (streams from S3)
- File edits: sync within seconds
- Large transfers: optimized by rclone

### Latency
- PARA access: ~50ms (S3 latency)
- Projects: ~50-100ms (via git + S3)
- Memory access: ~50ms (S3 latency)
- **Acceptable** for development work

## Comparison: Old vs New Architecture

### Old (Laptop-centric)
```
MacBook (full PARA, full projects, full storage)
├── ~/PARA/ (all files local)
├── ~/projects/ (all files local)
├── ~/.claude-memory/ (all local)
└── Problem: Laptop is critical point of failure
```

### New (Cloud-centric)
```
MacBook (thin client, S3-backed)
├── ~/ (only configs, tools)
├── ~/PARA/ → idrive e2 S3
├── ~/projects/ → idrive e2 S3
├── ~/.claude-memory/ → idrive e2 S3
└── Benefit: Laptop is replaceable
```

## Security Considerations

### Never Sync to S3
- ❌ ~/.ssh/ (private keys)
- ❌ ~/.aws/credentials (access keys)
- ❌ ~/.kube/config (cluster credentials)
- ❌ 1Password config (encryption keys)

### Do Sync to S3
- ✅ PARA system (public/semi-public knowledge)
- ✅ Projects (source code)
- ✅ Memories (conversation history)
- ✅ Documents (notes, guides)

### Encryption
- S3 credentials stored locally in `~/.aws/`
- idrive e2 bucket encryption enabled
- rclone can encrypt at rest (optional)
- SSH keys never leave laptop

## Monitoring

### Check Mount Status
```bash
# Verify all mounts active
mount | grep rclone

# Expected output:
# idrive-e2:shannonjlove/para on /Users/shannon/PARA
# idrive-e2:shannonjlove/projects on /Users/shannon/projects
# idrive-e2:shannonjlove/memories on /Users/shannon/.claude-memory
```

### Monitor S3 Sync
```bash
# Check last sync time
stat ~/PARA/README.md

# List changes
rclone changes ~/PARA idrive-e2:shannonjlove/para/

# Verify file counts match
rclone size ~/PARA
rclone size idrive-e2:shannonjlove/para/
```

### Performance Monitoring
```bash
# Monitor rclone activity
rclone rc --json core/stats

# Check VFS cache usage
du -sh ~/.cache/rclone/
```

## Troubleshooting

### Mount Not Working
```bash
# Check rclone config
rclone config show idrive-e2

# Test S3 access
rclone ls idrive-e2:shannonjlove/

# Remount
sudo umount ~/PARA
rclone mount idrive-e2:shannonjlove/para ~/PARA --daemon
```

### Sync Lag
```bash
# Force immediate sync
rclone sync ~/PARA idrive-e2:shannonjlove/para/

# Check VFS cache
rclone rc --json vfs/forget
```

### Tailscale Connection Lost
```bash
# Reconnect
tailscale up

# Verify IP
tailscale ip -4
```

---

**Architecture Goal**: MacBook M1 as a stateless workstation, fully backed by idrive e2 S3, replaceable at any time.

**Last Updated**: July 10, 2026  
**System**: shannonjlove.cloud Laptop Node
