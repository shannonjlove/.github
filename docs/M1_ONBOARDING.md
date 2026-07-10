# MacBook M1 Onboarding Guide

Complete onboarding for MacBook M1 with Claude Code, PARA system, and cloud infrastructure integration.

**Status**: Ready for implementation  
**Last Updated**: July 10, 2026  
**Branch**: `claude/macbook-m1-onboarding-mx9y96`

## Quick Start

```bash
# Clone this repo to your new MacBook
git clone https://github.com/shannonjlove/.github.git
cd .github
git checkout claude/macbook-m1-onboarding-mx9y96

# Run the complete setup (all phases)
bash scripts/m1-onboarding/install-all.sh

# OR run phases individually
bash scripts/m1-onboarding/phase-1-system.sh       # macOS + tools
bash scripts/m1-onboarding/phase-2-para.sh         # PARA system
bash scripts/m1-onboarding/phase-3-claude.sh       # Claude Code
bash scripts/m1-onboarding/phase-4-ai-stack.sh     # Local AI + MCP
bash scripts/m1-onboarding/phase-5-cloud.sh        # Cloud connectivity
bash scripts/m1-onboarding/verify-setup.sh         # Health check
```

## Phases

### Phase 1: System Baseline
- macOS updates and FileVault
- Homebrew and command line tools
- Python 3.11, Node 20, git configuration

**Duration**: 2-3 hours

### Phase 2: PARA System
- Directory structure at `~/PARA/`
- Git initialization with `.gitignore`
- Project symlinks and manual v8 setup

**Duration**: 1-2 hours

### Phase 3: Claude Code
- CLI installation and configuration
- VS Code extension setup
- MCP server configuration

**Duration**: 1-2 hours

### Phase 4: Local AI Stack
- Tailscale VPN connection
- Ollama LLM installation
- claude-memory stdio MCP server
- memory-agent FastAPI service (port 8100)
- local-agent chat service (port 8101)
- apple-notes-mcp integration

**Duration**: 2-3 hours

### Phase 5: Cloud Connectivity
- NFS mounting from Nexus
- Shared memory context sync
- SSH aliases for quick access

**Duration**: 1-2 hours

## Prerequisites

- New MacBook M1 (Apple Silicon)
- Tailscale account (for mesh VPN)
- GitHub account for repository access
- Homebrew installed (instructions in Phase 1)

## Architecture Overview

```
MacBook M1 (Local)
├── ~PARA/                    # Git-backed project directory
│   ├── 1-PROJECTS/           # Symlinks to repos
│   ├── 2-AREAS/              # Manual system areas
│   ├── 3-RESOURCES/          # Reference materials
│   ├── 4-ARCHIVE/            # Completed work
│   └── 0-SYSTEM/             # Meta files
│
├── Local AI Stack (Tailscale 100.x.x.x)
│   ├── Ollama (port 11434)   # LLM engine
│   ├── memory-agent (8100)   # REST file CRUD
│   ├── local-agent (8101)    # Chat with reasoning
│   └── claude-memory (stdio) # MCP server
│
└── Cloud Sync
    └── /mnt/shared-context   # NFS to Nexus (100.115.66.75)
        ├── claude-memories   # Shared memory
        └── shared-data/      # Other shared resources
```

## Supported Repos

This onboarding applies to your entire ecosystem:

- `shannonjlove/.github` - Central configuration
- `shannonjlove/github-mcp-server` - GitHub integration
- `shannonjlove/claude-memory-mcp` - Memory system
- `shannonjlove/apple-notes-mcp` - Note-taking
- `shannonjlove/Hybrid-Personal-Cloud-Server-Infrastructure` - Cloud config
- All other project repositories

## Post-Setup

### Daily Workflow
1. Terminal opens → startup script runs → services start
2. Check PARA updates: `cd ~/PARA && git status`
3. Verify AI stack: `./check-setup.sh` (optional)

### Weekly Review
- Update 2-AREAS for current status
- Archive completed items
- Create memory snapshot
- Commit PARA changes

### Memory Sync
- Local memories auto-sync to `/mnt/shared-context/`
- Cloud and local in-sync via NFS
- Available across all nodes (MacBook, Nexus, sOs, WebTop)

## Troubleshooting

See `docs/M1_TROUBLESHOOTING.md` for common issues and solutions.

## Development Notes

All scripts are idempotent — safe to run multiple times.

Scripts check for existing installations and skip if already configured:
- Won't reinstall Homebrew if present
- Won't duplicate git configs
- Won't recreate already-mounted NFS paths
- Won't re-download already-installed tools

## Next Steps

After setup completes:
1. [ ] Verify all services running: `bash verify-setup.sh`
2. [ ] Test Claude Code integration
3. [ ] Import existing memories
4. [ ] Configure PARA areas
5. [ ] Set up SSH keys for Tailscale nodes

See `MANUAL-V8.md` in `~/PARA/0-SYSTEM/` for PARA usage.
