# PARA Six-Digit Code System

Systematic reference and tracking system for all projects, areas, and organizational elements.

## Overview

Each project, area, and major initiative receives a unique **six-digit alphanumeric code** for:
- Systematic cross-referencing
- Git branch naming (`claude/[CODE]-description`)
- Memory tagging and context tracking
- Archive organization by code
- Integration across cloud infrastructure

## Code Format

**Structure**: `XXXXXX` (6 characters, alphanumeric)

**Patterns**:
- **Project codes**: `pr####` or mixed alphanumeric (e.g., `mx9y96`)
- **Area codes**: `[category]###` (e.g., `dev001`, `inf002`)
- **Archive codes**: `ar[YY][QQ]` (e.g., `ar2601` = 2026 Q1)
- **Initiative codes**: `init##` (e.g., `init01`)

## Current Code Registry

### Projects (1-PROJECTS/)

| Code | Name | Status | Git Branch |
|------|------|--------|-----------|
| `mx9y96` | MacBook M1 Onboarding | Active | `claude/macbook-m1-onboarding-mx9y96` |
| `pr0801` | claude-memory-mcp enhancements | Backlog | TBD |
| `pr0802` | github-mcp-server expansion | Backlog | TBD |
| `pr0803` | apple-notes-mcp refactor | Backlog | TBD |

### Areas (2-AREAS/)

| Code | Area | Focus |
|------|------|-------|
| `dev001` | Development & AI | Claude Code, MCP servers, Python development |
| `inf002` | Infrastructure & Cloud | Hybrid cloud, Tailscale, Podman, NFS |
| `knw003` | Personal Knowledge | PARA system, memory management, context |
| `wrt004` | Writing & Documentation | Guides, READMEs, architectural docs |
| `hlth005` | Health & Fitness | Personal wellness tracking |

### Archive (4-ARCHIVE/)

| Code | Period | Contents |
|------|--------|----------|
| `ar2602` | 2026 Q2 | claude-memory v2 migration, search optimization |
| `ar2601` | 2026 Q1 | Repository setup, initial MCP implementations |

### Initiatives (Ongoing)

| Code | Initiative | Related Areas |
|------|-----------|---------------|
| `init01` | Universal Memory MCP Framework | dev001, knw003 |
| `init02` | Hybrid Cloud Optimization | inf002, dev001 |
| `init03` | MacBook M1 Full Stack | mx9y96, dev001, inf002 |

## Usage Patterns

### Project Folders

```bash
# Create project with code
mkdir -p ~/PARA/1-PROJECTS/[mx9y96]-macbook-m1-onboarding

# Project structure
[mx9y96]-macbook-m1-onboarding/
├── README.md              # Contains code in header
├── PROGRESS.md            # Week-by-week tracking
├── notes/                 # Meeting notes, decisions
├── deliverables/          # Final outputs
└── [code]-specific files
```

### Project README Header

```markdown
# [mx9y96] MacBook M1 Onboarding

**Code**: mx9y96  
**Status**: Active  
**Timeline**: 2 weeks  
**Areas**: dev001, inf002, knw003  

[Rest of README...]
```

### Git Branch Naming

```bash
# Branch follows code system
git checkout -b claude/[mx9y96]-macbook-m1-onboarding-setup

# Short form for working branches
git checkout -b feature/mx9y96-phase-4-ai-stack
```

### Memory/Context Tagging

```bash
# Save context with code reference
/memories create "[mx9y96] Progress Update" "Content..."

# Search by code
/memories search "mx9y96"

# Multi-code contexts
/memories create "[mx9y96][init03] Integration Status" "..."
```

### Cloud Integration

```bash
# Archive paths include codes
/mnt/shared-context/projects/mx9y96-macbook-m1-onboarding/

# Memory organization
/mnt/shared-context/claude-memories/projects/mx9y96/

# Session tracking
/mnt/shared-context/sessions/[CODE]/YYYY-MM-DD.md
```

## Code Assignment Process

When starting a new project:

1. **Reserve Code**: Add to `CODE-REGISTRY.md` with date
2. **Create Folder**: `1-PROJECTS/[CODE]-descriptive-name/`
3. **Document**: Add code to project README header
4. **Branch**: Create git branch with code pattern
5. **Track**: Tag memories and contexts with code
6. **Archive**: Move to `4-ARCHIVE/[CODE]/` when complete

## Searching by Code

### In Terminal

```bash
# Find all files referencing a code
cd ~/PARA
grep -r "mx9y96" .

# List all projects with code
ls 1-PROJECTS/ | grep "mx9y96"

# Check git history for code
git log --grep="mx9y96"
```

### In Claude Code

```bash
# View project by code
claude view ~/PARA/1-PROJECTS/[mx9y96]*/

# Search memories
/memories search "[mx9y96]"

# List project files
/files list ~/PARA/1-PROJECTS/[mx9y96]*/
```

## Maintenance

### Weekly Review

During Sunday PARA review:
1. Check active project codes
2. Update status for each code
3. Mark codes ready to archive
4. Reserve new codes if needed

### Quarterly Cleanup

1. Archive completed projects with code
2. Update `CODE-REGISTRY.md`
3. Create new archive section: `ar[YY][QQ]`
4. Commit with code reference: `archive: [CODE] project-name`

## Benefits

✅ **Systematic**: Consistent naming across all systems  
✅ **Traceable**: Find all related work via code  
✅ **Scalable**: Works across MacBook, cloud, repositories  
✅ **Memorable**: Six digits easy to reference verbally  
✅ **Integrated**: Links PARA to git, memory, cloud infrastructure  

## Example Workflow

```bash
# 1. Start new project with code
code="pr0804"
project="feature-x-enhancement"
mkdir -p ~/PARA/1-PROJECTS/[$code]-$project

# 2. Create README with code
cat > ~/PARA/1-PROJECTS/[$code]-$project/README.md << EOF
# [$code] Feature X Enhancement

**Code**: $code
**Area**: dev001
...
EOF

# 3. Create git branch
git checkout -b feature/$code-implementation

# 4. Tag memories as you work
/memories create "[$code] Day 1 Planning" "Notes..."

# 5. Archive when complete
mv ~/PARA/1-PROJECTS/[$code]-$project ~/PARA/4-ARCHIVE/2026-Q3/
git commit -m "archive: [$code] $project"
```

---

**Last Updated**: July 10, 2026  
**System**: PARA Manual v8 with Six-Digit Codes  
**Base Reference**: MacBook M1 Onboarding (mx9y96)
