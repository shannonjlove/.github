# PARA System - Cloud Structure Mirror

Map your local PARA system to match `shannonjlove.cloud` infrastructure organization.

## Directory Structure Template

```
~/PARA/
├── 1-PROJECTS/
│   ├── [mx9y96]-macbook-m1-onboarding/
│   │   ├── README.md
│   │   ├── PROGRESS.md
│   │   ├── notes/
│   │   ├── deliverables/
│   │   ├── scripts/               # Setup scripts
│   │   ├── config/                # Configuration files
│   │   └── docs/                  # Project documentation
│   │
│   ├── [pr0801]-claude-memory-mcp/
│   ├── [pr0802]-github-mcp-server/
│   └── [pr0803]-apple-notes-mcp/
│
├── 2-AREAS/
│   ├── dev001-development-ai/
│   │   ├── README.md             # Area charter
│   │   ├── goals.md              # Quarterly goals
│   │   ├── standards.md          # Code standards, practices
│   │   ├── tools/                # Development tools setup
│   │   ├── mcp-servers/          # MCP server configs
│   │   └── languages/            # Python, TypeScript, etc.
│   │
│   ├── inf002-infrastructure-cloud/
│   │   ├── README.md             # Infrastructure overview
│   │   ├── ARCHITECTURE.md       # System design docs
│   │   ├── 01-DEPLOYMENT/        # Deployment scripts (mirror: Hybrid-Cloud)
│   │   │   ├── hostinger/        # Nexus VM configs
│   │   │   ├── oracle/           # sOs VM configs
│   │   │   └── macos/            # MacBook configs
│   │   ├── 02-CONTAINERS/        # Container definitions (mirror: Hybrid-Cloud)
│   │   │   ├── ai-mcp-servers/   # MCP containers
│   │   │   ├── services/         # Service containers
│   │   │   └── quadlets/         # Podman Quadlets
│   │   ├── networking/           # Tailscale, DNS, NFS
│   │   ├── security/             # Credentials, keys, policies
│   │   └── monitoring/           # Logs, alerts, status
│   │
│   ├── knw003-personal-knowledge/
│   │   ├── README.md             # Knowledge management charter
│   │   ├── memory-system/        # Claude memory setup
│   │   ├── context-snapshots/    # Complex context saves
│   │   ├── templates/            # Reusable templates
│   │   └── research/             # Research notes
│   │
│   ├── wrt004-writing-documentation/
│   │   ├── README.md             # Writing standards
│   │   ├── guides/               # How-to guides
│   │   ├── architecture/         # Architecture docs
│   │   ├── api/                  # API documentation
│   │   └── templates/            # Doc templates
│   │
│   └── hlth005-health-fitness/
│       ├── README.md
│       ├── goals/
│       ├── tracking/
│       └── resources/
│
├── 3-RESOURCES/
│   ├── coding/
│   │   ├── python/
│   │   ├── typescript/
│   │   ├── bash/
│   │   ├── mcp-protocol/
│   │   ├── api-design/
│   │   └── testing/
│   │
│   ├── infrastructure/
│   │   ├── tailscale/
│   │   ├── podman/
│   │   ├── nfs/
│   │   ├── ssl-certificates/
│   │   └── networking/
│   │
│   ├── cloud-providers/
│   │   ├── hostinger/            # Hostinger VPS (Nexus)
│   │   ├── oracle-cloud/         # Oracle Cloud (sOs)
│   │   └── cloudflare/           # DNS and CDN
│   │
│   ├── ai-platforms/
│   │   ├── claude/
│   │   ├── openai/
│   │   ├── ollama/
│   │   └── cursor/
│   │
│   ├── tools/
│   │   ├── claude-code/
│   │   ├── vs-code/
│   │   ├── git/
│   │   └── terminal/
│   │
│   └── personal/
│       ├── templates/
│       ├── checklists/
│       └── references/
│
├── 4-ARCHIVE/
│   ├── 2026-Q2/
│   │   ├── [ar2602-001]-claude-memory-v2/
│   │   ├── [ar2602-002]-search-optimization/
│   │   └── ...
│   │
│   └── 2026-Q1/
│       ├── [ar2601-001]-repo-setup/
│       └── ...
│
├── 0-SYSTEM/
│   ├── README.md                  # PARA overview
│   ├── MANUAL-V8.md              # PARA manual
│   ├── CODE-REGISTRY.md          # Project code assignments
│   ├── CONTEXTS.md               # Claude context snapshots
│   ├── WEEKLY-TEMPLATE.md        # Weekly review template
│   ├── sync-config.json          # Memory/cloud sync settings
│   │
│   ├── templates/
│   │   ├── project-start.md      # New project template
│   │   ├── area-update.md        # Area update template
│   │   ├── weekly-review.md      # Weekly review template
│   │   └── memory-snapshot.md    # Context snapshot template
│   │
│   ├── scripts/
│   │   ├── sync-to-cloud.sh      # NFS sync script
│   │   ├── backup-memories.sh    # Memory backup
│   │   ├── weekly-archive.sh     # Archive completed work
│   │   └── health-check.sh       # System status
│   │
│   └── reference/
│       ├── git-workflow.md       # Git conventions
│       ├── code-standards.md     # Coding standards
│       └── commit-messages.md    # Commit format guide
│
└── .github/
    └── workflows/                 # GitHub Actions
        ├── sync-to-cloud.yml
        └── archive-quarterly.yml
```

## Cloud Infrastructure Mirror Mapping

### Local ↔ Cloud Alignment

| Local (PARA) | Cloud (shannonjlove.cloud) | Purpose |
|--------------|---------------------------|---------|
| `2-AREAS/inf002/01-DEPLOYMENT/` | `01-DEPLOYMENT/` | Deployment scripts |
| `2-AREAS/inf002/02-CONTAINERS/` | `02-CONTAINERS/` | Container configs |
| `2-AREAS/inf002/networking/` | Cloud VPN/NFS setup | Network config |
| `3-RESOURCES/infrastructure/` | Documentation | Reference docs |
| `1-PROJECTS/[code]/scripts/` | Project-specific scripts | Implementation |
| `0-SYSTEM/scripts/` | Cloud root `scripts/` | System automation |

### Deployment Structure

```
2-AREAS/inf002-infrastructure-cloud/
└── 01-DEPLOYMENT/
    ├── hostinger/
    │   ├── quadlets/
    │   │   ├── memory-agent.container
    │   │   ├── local-agent.container
    │   │   └── ollama.container
    │   ├── scripts/
    │   │   ├── deploy-memory-agent-v2.sh
    │   │   ├── deploy-local-agent.sh
    │   │   └── configure-npm-memory.sh
    │   └── config/
    │       ├── npm.env
    │       └── nfs-exports.conf
    │
    └── oracle/
        ├── quadlets/
        │   ├── webtop.container
        │   └── claude-memory.container
        ├── scripts/
        │   └── deploy-shared-context-sos-webtop.sh
        └── nfs-mounts/
            └── shared-context.conf
```

### Container Definitions

```
2-AREAS/inf002-infrastructure-cloud/
└── 02-CONTAINERS/
    └── ai-mcp-servers/
        ├── claude-memory/
        │   ├── server.py
        │   ├── seed-memories/
        │   └── Dockerfile
        ├── memory-agent/
        │   ├── app.py
        │   ├── requirements.txt
        │   └── docker-compose.yml
        ├── local-agent/
        │   ├── main.py
        │   └── requirements.txt
        └── apple-notes-mcp/
            ├── src/
            └── package.json
```

## Synchronization Rules

### Local → Cloud

Files that should sync to `/mnt/shared-context`:
- `1-PROJECTS/[code]/deliverables/`
- `0-SYSTEM/CONTEXTS.md`
- `0-SYSTEM/CODE-REGISTRY.md`
- `2-AREAS/*/standards.md`
- `3-RESOURCES/` (reference docs)

Files that stay local:
- `.env` files (credentials)
- Personal notes in `2-AREAS/`
- Draft work in projects

### Cloud → Local

Pull from cloud:
- Updated deployment scripts
- Container configurations
- Infrastructure documentation
- Shared memory contexts

## Integration Points

### GitHub Sync
```bash
# Commit structure includes area/project codes
git commit -m "feat(dev001)[mx9y96]: add feature"
git commit -m "docs(inf002): update deployment guide"
git commit -m "archive(ar2602)[pr0801]: complete project"
```

### Claude Code Integration
```bash
# Store context with path structure
/memories create "[mx9y96] Architecture Design" "~/PARA/1-PROJECTS/[mx9y96]-*/docs/"
/memories create "[dev001] Standards" "~/PARA/2-AREAS/dev001-*/standards.md"
```

### Cloud Storage
```bash
# Mirror path structure on cloud
~/PARA/1-PROJECTS/[mx9y96]-*/
↓ syncs to ↓
/mnt/shared-context/para/1-projects/[mx9y96]-*/
```

## Quick Setup

Run these commands to create the full structure:

```bash
# Create all directories
mkdir -p ~/PARA/{1-PROJECTS,2-AREAS,3-RESOURCES,4-ARCHIVE,0-SYSTEM}/{templates,scripts,reference}

# Mirror cloud structure
mkdir -p ~/PARA/2-AREAS/inf002-infrastructure-cloud/{01-DEPLOYMENT,02-CONTAINERS}/{hostinger,oracle,ai-mcp-servers}

# Initialize git
cd ~/PARA
git init
git add .
git commit -m "init: PARA cloud mirror structure"
```

---

**Purpose**: Align local PARA organization with cloud infrastructure for seamless sync and consistency.

**Last Updated**: July 10, 2026  
**System**: PARA Manual v8 + Cloud Mirror Structure
