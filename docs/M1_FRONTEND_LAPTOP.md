# MacBook M1 Frontend Laptop: Pure Thin Client for shannonjlove.cloud

## Architecture Overview

Your MacBook M1 is a **pure frontend/thin client** for shannonjlove.cloud. The laptop has **zero local development tools**, **zero local storage**, and **zero stateful data**. All work happens remotely on Nexus or sOs via SSH and web UIs.

```
MacBook M1 (Frontend)
├── Local: SSH keys, Claude config (non-sync)
├── Network: Tailscale VPN
└── Everything else: Nexus (100.115.66.75) or sOs (100.67.229.94)
    ├── Development environment
    ├── S3 storage (PARA, projects, memories)
    ├── Web services (NPM, Memory API)
    └── Compute resources
```

## What's NOT on Your Laptop

**Development Tools:**
- ✗ Python (use `ssh nexus` for Python work)
- ✗ Node.js (use remote SSH)
- ✗ Go, Rust, etc. (all remote)

**Storage:**
- ✗ rclone mounts (use web UI or SSH)
- ✗ S3 buckets locally (everything on Nexus)
- ✗ PARA folders (mounted on Nexus)
- ✗ Project repositories (cloned on Nexus)

**Data:**
- ✗ Conversation history (on Nexus S3)
- ✗ Code (on Nexus)
- ✗ Working files (on Nexus)

## What IS on Your Laptop

**Frontend Tools:**
- ✓ Homebrew (package manager)
- ✓ Git (version control)
- ✓ Tailscale (VPN to cloud)
- ✓ OpenSSH (SSH client)
- ✓ Claude CLI (MCP access to cloud servers)
- ✓ curl, wget (HTTP tools)

**Local Config (Never Synced):**
- ✓ `~/.ssh/` — SSH keys and config
- ✓ `~/.claude/` — Claude Code settings
- ✓ `~/.gitconfig` — Git user info

## Setup Phases

### Phase 1: Minimal System (~5 minutes)

Installs only Homebrew, Git, Tailscale, and SSH. No development tools.

```bash
bash scripts/m1-frontend/phase-1-minimal.sh
```

### Phase 2: Cloud Connectivity (~5 minutes)

Connects to Tailscale VPN, configures SSH aliases to Nexus/sOs, verifies cloud access.

```bash
bash scripts/m1-frontend/phase-2-cloud.sh
```

Requires:
- Manual Tailscale authentication: `tailscale up`
- SSH key generation or restoration from password manager

### Phase 3: Frontend Tools (~3 minutes)

Installs Claude CLI and creates local-only configuration.

```bash
bash scripts/m1-frontend/phase-3-frontend.sh
```

### Full Setup

```bash
bash scripts/m1-frontend/install-all.sh
```

Total time: ~15 minutes (mostly waiting for Tailscale auth)

## How to Use This Setup

### Accessing Development Environment

**SSH into Nexus** (primary development host):
```bash
ssh nexus
# Now you're in Ubuntu 22.04 on Nexus
# Full Python, Node, Go, Rust, etc. available
cd ~/projects
git clone <repo>
# Work here
```

**SSH into sOs** (Oracle Cloud ARM64):
```bash
ssh sos
# Use for ARM64-specific work
```

**Desktop via WebTop** (remote X11 desktop):
```bash
ssh webtop
# Open http://localhost:3000 in browser
# Full XFCE desktop inside browser
```

### Accessing Data

**PARA, Projects, Memories:**
```bash
# Option 1: Web UI
# https://memory.shannonjlove.cloud (Tailscale-only)
# https://npm.shannonjlove.cloud (public)

# Option 2: SSH into Nexus and access locally
ssh nexus
ls ~/PARA/
ls ~/projects/
ls ~/.claude-memory/
```

### Claude Code with Cloud MCP

Claude CLI automatically tunnels to cloud MCP servers:

```bash
claude mcp list
# Shows: claude-memory (via SSH tunnel to Nexus:8100)
#        local-agent (via SSH tunnel to Nexus:8101)
```

Use Claude Code to:
- Search memories across Claude + ChatGPT conversations
- Chat with local-agent (Ollama-backed LLM)
- Access memory APIs via MCP

## Storage Architecture

| Component | Location | Sync | Backup |
|---|---|---|---|
| Code | Nexus `~/projects/` | Git → GitHub | Yes (GitHub) |
| PARA | Nexus S3 (idrive e2) | rclone daemon | Yes (S3) |
| Memories | Nexus S3 + SQLite FTS | Auto (mcp) | Yes (S3) |
| Laptop config | Local `~/.ssh/`, `~/.claude/` | Never | Manual (password manager) |

**Disaster Recovery:**
- Laptop fails → data is 100% safe on Nexus/S3
- Get new MacBook → run setup (15 min) → restore SSH keys from password manager → everything works

## Security Model

**What Never Leaves Your Laptop:**
- SSH private keys (`~/.ssh/id_rsa`)
- Cloud credentials (if any stored locally)
- 1Password/password manager config

**What Lives in Cloud (Encrypted at Rest):**
- All code (GitHub + Nexus S3)
- PARA system (idrive e2 S3)
- Conversation history (Nexus S3)
- Development artifacts (Nexus filesystem)

**Tailscale Security:**
- VPN mesh only accessible to authorized devices
- No public ports exposed on laptop
- All traffic encrypted end-to-end

## Comparison: Frontend vs. Stateless Storage

| Aspect | Frontend (NEW) | Stateless Storage (OLD) |
|---|---|---|
| Local dev tools | None | Python, Node, Git |
| S3 mounts | None | PARA, projects, memories |
| Local compute | SSH only | Local tools |
| Setup time | ~15 min | ~40 min |
| Laptop failure | ~15 min restore | ~40 min restore |
| Development model | Pure remote | Hybrid (local + remote) |
| Use case | Client-focused work | Full local dev capability |

## Workflow Examples

### Example 1: Clone and Develop a Project

```bash
# On your MacBook
ssh nexus

# On Nexus
cd ~/projects
git clone https://github.com/shannonjlove/some-repo.git
cd some-repo
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Develop here
git push origin main
```

### Example 2: Search Memories and Chat

```bash
# On your MacBook
claude mcp list
# Use Claude Code with memory MCP

# In Claude Code conversation:
# "Search my memories for AWS configuration notes"
# "Chat with local-agent about my project"
# Both use SSH tunnels to Nexus APIs
```

### Example 3: Access PARA System

```bash
# Option A: Web UI
open https://memory.shannonjlove.cloud

# Option B: SSH + browse
ssh nexus
ls ~/PARA/1-PROJECTS/
ls ~/PARA/2-AREAS/
# Read files
cat ~/PARA/1-PROJECTS/project-x/README.md
```

### Example 4: Emergency Laptop Replacement

```bash
# New MacBook arrives
bash scripts/m1-frontend/install-all.sh
# Wait 15 minutes

# Restore SSH key from 1Password
# Restore any local config from backup

ssh nexus  # Everything works exactly as before
```

## Troubleshooting

**SSH connection fails:**
- Check Tailscale: `tailscale ip -4`
- Verify Nexus is reachable: `ping 100.115.66.75`
- Check SSH key: `ls ~/.ssh/id_rsa`

**Tailscale not connecting:**
- Run: `tailscale up`
- Complete auth in browser
- Wait for daemon to sync (~10 seconds)

**Claude CLI not finding cloud MCP servers:**
- Check SSH tunnels are working: `ssh nexus -L 8100:localhost:8100 echo ok`
- Verify Nexus services are running: `ssh nexus systemctl status memory-agent`

**Can't access WebTop:**
- Verify SSH tunnel: `ssh webtop`
- Open browser to http://localhost:3000
- Credentials are in password manager

## Files

**Setup Scripts:**
- `scripts/m1-frontend/phase-1-minimal.sh` — Homebrew, Git, Tailscale
- `scripts/m1-frontend/phase-2-cloud.sh` — VPN, SSH config
- `scripts/m1-frontend/phase-3-frontend.sh` — Claude CLI, local config
- `scripts/m1-frontend/install-all.sh` — Master orchestration
- `scripts/m1-frontend/verify-setup.sh` — Health check

**Documentation:**
- `docs/M1_FRONTEND_LAPTOP.md` — This file

## Quick Reference

```bash
# Start development
ssh nexus

# Access PARA
ssh nexus ls ~/PARA/

# Search memories
claude mcp list  # Shows memory MCP
# Use in Claude Code conversation

# Desktop
ssh webtop
# Open http://localhost:3000

# Verify setup
bash scripts/m1-frontend/verify-setup.sh
```

## Philosophy

Your MacBook is a **high-fidelity UI** to shannonjlove.cloud, not a development machine. All actual work, storage, and compute live remotely. The laptop is:
- ✅ Disposable (can be replaced in 15 minutes)
- ✅ Lightweight (minimal tools, minimal config)
- ✅ Focused (SSH, browser, Claude CLI only)
- ✅ Secure (no local data, SSH keys protected)
- ✅ Fast to set up (one script, 15 minutes)
