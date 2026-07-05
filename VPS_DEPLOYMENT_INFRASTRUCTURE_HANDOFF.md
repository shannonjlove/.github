# VPS Deployment Infrastructure - Project Handoff

**Session Date:** July 4, 2026  
**Branch:** `claude/podlet-vps-install-1n0gb0`  
**Target Repo:** `shannonjlove/hybrid-personal-cloud-server-infrastructure`

---

## Project Overview

Complete, production-ready VPS deployment infrastructure using Podman, Quadlet, and systemd-based hybrid cloud server management.

---

## Project Structure

```
.
├── scripts/
│   ├── refresh-all.sh          # Master service refresh script
│   ├── deploy.sh               # Container deployment automation
│   └── health-check.sh         # System/service monitoring
├── containers/
│   └── example.container       # Quadlet template (for copying)
├── systemd/                    # Systemd units (empty, for user files)
├── config/                     # Configuration directory (empty)
├── docs/
│   ├── DEPLOYMENT-GUIDE.md     # Complete VPS setup guide
│   └── MCP-SERVER-SETUP.md     # Hardened MCP filesystem server
├── .github/workflows/
│   └── deploy.yml              # GitHub Actions CI/CD pipeline
├── .env.example                # Environment variables template
├── README.md                   # Project overview
├── .gitignore                  # Proper Node.js + deployment secrets
└── LICENSE                     # Preserved from original
```

---

## Scripts

### refresh-all.sh (Master Service Refresh)
- Regenerates Quadlet-derived systemd units with `podman-system-generator`
- Runs `systemctl daemon-reload`
- Restarts systemd-journald and ssh services
- Restarts all running Podman containers
- Restarts all running Docker containers
- Logs to `/var/log/refresh-all.log`

### deploy.sh (Container Lifecycle Management)
- Actions: `deploy`, `start`, `stop`, `restart`, `logs`, `status`
- Manages individual container lifecycle
- Usage: `./scripts/deploy.sh mcp-server logs`

### health-check.sh (System Monitoring)
- Checks systemd status
- Verifies Podman/Docker installation and running containers
- Checks key services (ssh, systemd-journald)
- Verifies MCP socket existence
- Reports disk usage
- Logs refresh-all last run

---

## Documentation

### DEPLOYMENT-GUIDE.md
Comprehensive guide covering:
- Prerequisites (Ubuntu 22.04+, Podman, nodejs, npm)
- Initial setup and service accounts
- Creating and deploying containers
- Managing services with scripts
- Setting up MCP server
- Monitoring with journalctl
- Log rotation strategy
- Networking and port mapping
- Troubleshooting
- Security hardening
- Backup strategies

### MCP-SERVER-SETUP.md
Detailed MCP filesystem server configuration:
- Installation in `/srv/sjl/hardened-mcp-filesystem`
- Node.js project setup
- Config with read/write root enforcement
- Systemd service creation
- MCP client configuration
- Audit logging (JSONL format)
- Security best practices
- Troubleshooting guide

---

## GitHub Actions Workflow (deploy.yml)

**Features:**
- Validates Quadlet files (`.container`, `.network`, `.volume`)
- Validates shell scripts with `bash -n`
- Validates JSON configs with `jq`
- Deploys to VPS on push to `main`
- Uses `rsync` for deployment
- Runs `refresh-all.sh` on VPS after sync

**Requires GitHub secrets:**
- `DEPLOY_KEY` — SSH private key
- `DEPLOY_USER` — SSH user
- `DEPLOY_HOST` — VPS hostname/IP

---

## Security Implementation

✅ **Implemented:**
- `.env` excluded from git (use `.env.example`)
- Audit logging for filesystem operations (MCP server)
- Service account separation (non-root where possible)
- Read/write root scoping (not system-wide)
- Quadlet validation in CI/CD

⚠️ **Configure Before Production:**
- Set `allowDelete: false` in MCP config (disabled by default)
- Use restricted writable extensions (`.container`, `.yaml`, etc)
- Enable log rotation for audit logs
- Configure GitHub Actions secrets securely
- Set up firewall rules and network policies

---

## Deployment Pattern

```
GitHub Repo (main branch)
    ↓
GitHub Actions (CI/CD validation)
    ↓
rsync to VPS (/srv/sjl/vps-deployment)
    ↓
refresh-all.sh (regenerate systemd units)
    ↓
systemctl daemon-reload
    ↓
podman restart <containers>
```

---

## Next Steps

1. ✅ Code committed to `claude/podlet-vps-install-1n0gb0`
2. Create empty GitHub repo: `shannonjlove/hybrid-personal-cloud-server-infrastructure`
3. Push code from current branch to new repo
4. Set up GitHub Actions secrets for deployment
5. Create initial Quadlet container definitions in `containers/`
6. Configure MCP server following `docs/MCP-SERVER-SETUP.md`
7. Test `refresh-all.sh` on target VPS
8. Configure log rotation for audit logs and service logs

---

**Status:** Ready to push to GitHub  
**Repository:** https://github.com/shannonjlove/hybrid-personal-cloud-server-infrastructure
