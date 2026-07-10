#!/bin/bash
# Phase 2: PARA System Setup
# Creates directory structure, initializes git, sets up Manual v8
# Safe to run multiple times - idempotent

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 2: PARA System Setup${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

PARA_ROOT="$HOME/PARA"

# Step 1: Create PARA directory structure
echo -e "\n${BOLD}[1/4] Creating PARA directory structure...${NC}"
mkdir -p "$PARA_ROOT"/{1-PROJECTS,2-AREAS,3-RESOURCES,4-ARCHIVE,0-SYSTEM}
echo -e "${GREEN}✓ Directory structure created${NC}"

# Step 2: Initialize git repository (if not already initialized)
echo -e "\n${BOLD}[2/4] Initializing git repository...${NC}"
if [ ! -d "$PARA_ROOT/.git" ]; then
    cd "$PARA_ROOT"
    git init
    git config user.name "Shannon Love"
    git config user.email "sjlove@shannonjeffreylove.com"
    echo -e "${GREEN}✓ Git initialized${NC}"
else
    echo -e "${GREEN}✓ Git already initialized${NC}"
fi

# Step 3: Create .gitignore
echo -e "\n${BOLD}[3/4] Creating .gitignore...${NC}"
GITIGNORE="$PARA_ROOT/.gitignore"
if [ ! -f "$GITIGNORE" ]; then
    cat > "$GITIGNORE" << 'EOF'
# System files
.DS_Store
.AppleDouble
.LSOverride
.Spotlight-V100
.Trashes

# Claude Code
.claude/settings.local.json
.claude/session-cache.json

# Development
.venv/
venv/
node_modules/
__pycache__/
*.pyc
.pytest_cache/

# Logs and temporary
*.log
*.swp
*.swo
*~
.tmp/

# Local configuration
*.local
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
EOF
    echo -e "${GREEN}✓ .gitignore created${NC}"
else
    echo -e "${GREEN}✓ .gitignore already exists${NC}"
fi

# Step 4: Create initial PARA files and make first commit
echo -e "\n${BOLD}[4/4] Creating PARA system files...${NC}"
cd "$PARA_ROOT"

# Create README
if [ ! -f "$PARA_ROOT/README.md" ]; then
    cat > "$PARA_ROOT/README.md" << 'EOF'
# PARA System - Manual Version 8

This is your personal knowledge management system using the PARA method with six-digit code tracking:

- **1-PROJECTS/** - Active projects with six-digit codes (time-bound, specific outcomes)
- **2-AREAS/** - Ongoing areas of responsibility (roles, skills, interests)
- **3-RESOURCES/** - Reference materials and information
- **4-ARCHIVE/** - Completed projects and old materials, organized by code
- **0-SYSTEM/** - Meta files, templates, code registry, and system documentation

## Six-Digit Code System

All projects and areas have unique codes for systematic organization and reference.

**View codes**: `0-SYSTEM/CODE-REGISTRY.md`

**Format**: `[XXXXXX]-project-name/` or `code###-area-name/`

## Quick Start

1. View the Manual v8 guide: `0-SYSTEM/MANUAL-V8.md`
2. Check project codes: `0-SYSTEM/CODE-REGISTRY.md`

## Git Workflow

```bash
# Check status
git status

# Weekly review
git add .
git commit -m "weekly: PARA review $(date +%Y-W%V)"

# Push to cloud (when available)
git push origin main
```

## Sync Locations

- **Local**: `~/PARA/`
- **Cloud**: Backed up to iCloud Drive via `~/Library/CloudStorage/` symlink
- **Git**: Can be pushed to GitHub private repository

---

Last updated: $(date)
EOF
    echo -e "${GREEN}✓ README.md created${NC}"
fi

# Create project codes registry
if [ ! -f "$PARA_ROOT/0-SYSTEM/CODE-REGISTRY.md" ]; then
    cat > "$PARA_ROOT/0-SYSTEM/CODE-REGISTRY.md" << 'EOF'
# Six-Digit Code Registry

Reference system for all projects, areas, and major initiatives.

## Format: XXXXXX

Each code is a unique six-digit identifier for systematic organization.

### Project Codes (1-PROJECTS/)
```
mx9y96  - MacBook M1 Onboarding
```

### Area Codes (2-AREAS/)
```
dev001  - Development & AI
inf002  - Infrastructure & Cloud
knw003  - Personal Knowledge
wrt004  - Writing & Documentation
hlth005 - Health & Fitness
```

### Archive Codes (4-ARCHIVE/)
```
ar2601  - 2026-Q1 Completed
ar2602  - 2026-Q2 Completed
```

---

Usage: Prefix folders with [CODE] or reference in README
Example: `1-PROJECTS/[mx9y96]-macbook-m1-onboarding/`
EOF
    echo -e "${GREEN}✓ Code registry created${NC}"
fi

# Create MANUAL-V8.md template
if [ ! -f "$PARA_ROOT/0-SYSTEM/MANUAL-V8.md" ]; then
    cat > "$PARA_ROOT/0-SYSTEM/MANUAL-V8.md" << 'EOF'
# PARA Manual - Version 8

Complete guide to your personal knowledge system.

## Six-Digit Code System

All projects, areas, and major initiatives have unique six-digit codes for systematic reference.

**Format**: `XXXXXX` (alphanumeric)

**Usage**:
- Projects: `[CODE]-project-name/`
- Areas: Reference in area header
- Archives: `[CODE]-description/`

**Example**:
```
1-PROJECTS/
├── [mx9y96]-macbook-m1-onboarding/
├── [pr0801]-claude-memory-upgrade/
└── [pr0802]-github-integration/

2-AREAS/
├── dev001-development-ai/
└── inf002-infrastructure-cloud/
```

See `0-SYSTEM/CODE-REGISTRY.md` for your code assignments.

## The Four Categories

### 1. PROJECTS (1-PROJECTS/)
**Definition**: Specific, time-bound efforts with clear outcomes

**Examples**:
- M1 MacBook Setup (this onboarding)
- Building a new feature
- Writing a guide or article
- Organizing a system

**Lifespan**: Weeks to months, then archived when complete

**Files to keep**:
- Project planning document
- Meeting notes
- Code/work artifacts
- Final deliverables

**Review**: Every Sunday, mark progress

### 2. AREAS (2-AREAS/)
**Definition**: Ongoing responsibilities and domains of your life

**Examples**:
- Development & AI
- Infrastructure & Cloud
- Personal Knowledge
- Writing & Documentation
- Health & Fitness

**Lifespan**: Ongoing, reviewed quarterly

**Files to keep**:
- Area overview/mission
- Goals and standards
- Current challenges
- Resource lists

**Review**: Every week, check if areas need attention

### 3. RESOURCES (3-RESOURCES/)
**Definition**: Useful information for reference

**Examples**:
- Coding style guides
- MCP protocol documentation
- Infrastructure best practices
- Personal templates

**Lifespan**: Until no longer useful

**Files to keep**:
- Anything useful for future reference

**Review**: Quarterly, delete outdated materials

### 4. ARCHIVE (4-ARCHIVE/)
**Definition**: Completed projects and old materials

**Structure**:
```
4-ARCHIVE/
├── 2026-Q2/
│   ├── completed-project-1/
│   └── completed-project-2/
└── 2025-Q4/
    └── ...
```

**Lifespan**: Forever (reference only)

**Review**: Never (but easily searchable)

## System Files (0-SYSTEM/)

### MANUAL-V8.md (this file)
Your system guide and reference

### README.md
PARA overview and quick start

### CONTEXTS.md
Claude context snapshots for complex projects

### sync-config.json
Memory and cloud synchronization settings

### templates/
Reusable templates for projects, areas, and reviews

## Weekly Workflow

**Sunday Evening (30 minutes)**

```bash
cd ~/PARA

# 1. Review all projects for status
ls 1-PROJECTS/

# 2. Update 2-AREAS with current state
# - Any areas need attention?
# - Any challenges this week?
# - Progress on goals?

# 3. Review 3-RESOURCES
# - Delete anything outdated
# - Add anything discovered

# 4. Commit changes
git add .
git commit -m "weekly: PARA review $(date +%Y-W%V)"

# 5. (Optional) Push to cloud
git push origin main
```

## Project Lifecycle

### Starting a Project
1. Assign six-digit code from `CODE-REGISTRY.md`
2. Create folder: `1-PROJECTS/[CODE]-project-name/`
3. Create `README.md` with:
   - Project code and name
   - Goal and outcomes
   - Timeline and status
   - Resources needed
4. Add to git: `git add 1-PROJECTS/[CODE]-project-name/`

**Example**:
```
# Project: MacBook M1 Onboarding
Code: mx9y96
Goal: Complete M1 setup with PARA system and Claude integration
Timeline: 2 weeks
Status: In Progress
```

### During Project
- Update status in README.md
- Add notes, meetings, decisions
- Weekly review: check if on track

### Completing Project
1. Mark completion in README.md
2. Move to archive: `mv 1-PROJECTS/project-name/ 4-ARCHIVE/2026-Q3/`
3. Commit: `git commit -m "archive: project-name completed"`

## Quick Reference

### Common Commands
```bash
# See what's in each section
cd ~/PARA && ls -la

# Find a resource
grep -r "search-term" 3-RESOURCES/

# See recent changes
git log --oneline -10

# Check uncommitted changes
git status
```

### Integration with Claude Code
- Use `/memories` command to save context
- Reference PARA structure in prompts
- Save project-specific contexts to `0-SYSTEM/CONTEXTS.md`

## Tips

1. **Keep it simple** - PARA is a container, not a system
2. **Weekly review** - 30 minutes every Sunday keeps things running
3. **Archive often** - Clear out completed work regularly
4. **One location** - Don't duplicate projects across folders
5. **Git tracking** - Commit changes to keep history

## Next Steps

1. [ ] Familiarize yourself with this manual
2. [ ] Create your first Area for current work
3. [ ] Start a project in 1-PROJECTS/
4. [ ] Set up weekly review calendar event
5. [ ] Read "Building a Second Brain" by Tiago Forte (PARA origin)

---

**Last Updated**: $(date)
**Version**: 8.0
**Your PARA Root**: ~/PARA/
EOF
    echo -e "${GREEN}✓ MANUAL-V8.md created${NC}"
fi

# Create initial commit if repository is new
if [ -z "$(cd "$PARA_ROOT" && git log -1 --oneline 2>/dev/null)" ]; then
    cd "$PARA_ROOT"
    git add .
    git commit -m "init: PARA system structure (Manual v8)" || echo "No changes to commit"
    echo -e "${GREEN}✓ Initial commit created${NC}"
fi

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 2 Complete: PARA System Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}PARA System created at:${NC} ${BLUE}~/PARA/${NC}"
echo -e "\n${BOLD}Key Directories:${NC}"
echo "  1-PROJECTS/   - Active projects"
echo "  2-AREAS/      - Ongoing responsibilities"
echo "  3-RESOURCES/  - Reference materials"
echo "  4-ARCHIVE/    - Completed work"
echo "  0-SYSTEM/     - Meta files"
echo -e "\n${BOLD}Next Steps:${NC}"
echo "1. Read the manual: ${BLUE}cat ~/PARA/0-SYSTEM/MANUAL-V8.md${NC}"
echo "2. (Optional) Link repos: ${BLUE}ln -s ~/projects/claude-memory-mcp ~/PARA/1-PROJECTS/${NC}"
echo "3. Run Phase 3: ${BLUE}bash scripts/m1-onboarding/phase-3-claude.sh${NC}"
