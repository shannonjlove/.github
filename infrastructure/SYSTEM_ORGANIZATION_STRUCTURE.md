# VPS & Oracle Cloud System Organization Structure

**Objective**: Standardized file organization, proper directory structure, metadata tagging  
**Date**: 2026-07-05  
**Status**: 🔄 READY FOR IMPLEMENTATION

---

## Standard Directory Structure

### VPS Root Organization

```
/var/podman/                          # All container data
├── nginx-proxy-manager/
│   ├── config/                       # Config files
│   ├── data/                         # Database/app data
│   └── logs/                         # Service logs
├── sjl-mcp-quadlet/
│   ├── config/
│   ├── data/
│   └── logs/
├── [service-name]/
│   ├── config/
│   ├── data/
│   └── logs/
└── shared/                           # Shared resources
    ├── backups/
    ├── scripts/
    └── certs/

/etc/podman/secrets/                  # All .env files
├── nginx-proxy-manager.env
├── sjl-mcp.env
├── [service-name].env
└── .gitkeep

/opt/                                 # Application source code
├── sjl-mcp/
│   ├── src/
│   ├── config/
│   ├── docker-compose.yml.backup/
│   └── README.md
├── bookstack/
├── paperless/
└── [application]/

/home/user/.github/                   # Infrastructure as Code
├── podman-quadlets/                  # Quadlet templates
├── infrastructure/                   # Organization & scripts
│   ├── cleanup-scripts/
│   ├── organization-plans/
│   ├── metadata-templates/
│   └── directory-structure/
├── documentation/                    # System docs
└── backups/                          # Configuration backups

/root/.                               # System configuration
├── .bashrc
├── .profile
├── .ssh/
├── .aws/                             # AWS credentials (if used)
├── .oci/                             # Oracle Cloud credentials
└── .cloudflare/                      # Cloudflare API keys

/home/                                # User data
├── user/
│   ├── Documents/
│   ├── Downloads/
│   ├── Projects/
│   ├── Backups/
│   └── Archives/
└── [other-users]/
```

---

## File Organization by Category

### 1. Container Configuration Files

**Location**: `/var/podman/[service]/config/`

```
nginx-proxy-manager/config/
├── proxy-hosts.json           # Proxy host definitions
├── redirection-hosts.json     # Redirections
├── access-lists.json          # Access control lists
├── dead-hosts.json            # Dead hosts config
├── streams.json               # Stream config
├── certificates.json          # SSL certificates
└── metadata.yaml              # Service metadata

bookstack/config/
├── .env                       # Environment variables
├── database.sqlite           # SQLite DB
└── metadata.yaml

sjl-mcp/config/
├── .env
├── settings.json             # MCP settings
├── api-keys.json             # API key storage
└── metadata.yaml
```

### 2. Service Data Files

**Location**: `/var/podman/[service]/data/`

```
paperless/data/
├── documents/                 # OCR'd documents
├── thumbnails/                # Generated thumbnails
├── archive/                   # Original uploads
└── metadata.yaml

sjl-mcp/data/
├── uploads/                   # User uploaded files
├── cache/                     # Temporary cache
└── metadata.yaml

memory-agent/data/
├── memories.json              # Stored memories
├── conversations/             # Conversation logs
└── metadata.yaml
```

### 3. Application Source Code

**Location**: `/opt/[service]/`

```
sjl-mcp/
├── src/
│   ├── server.py             # Main server
│   ├── handlers/              # Request handlers
│   ├── models/                # Data models
│   └── utils/                 # Utilities
├── config/
│   ├── config.yaml           # Application config
│   └── logging.yaml          # Logging config
├── docs/
│   ├── README.md
│   ├── API.md
│   └── DEPLOYMENT.md
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── .env.example              # Example env file
├── requirements.txt          # Python dependencies
├── Dockerfile                # Container definition
├── docker-compose.yml.bak    # Backup of original
└── metadata.yaml             # Project metadata
```

### 4. System Configuration Files

**Location**: `/root/.config/` or `/etc/`

```
/root/.config/
├── systemd/                   # User systemd config
├── podman/                    # Podman config
├── ssh/                       # SSH settings
└── metadata.yaml

/etc/podman/
├── secrets/                   # All .env files
├── networks/                  # Network definitions
└── metadata.yaml
```

### 5. Backup Files

**Location**: `/var/podman/shared/backups/`

```
backups/
├── 2026-07-05/               # Date-based backups
│   ├── nginx-proxy-manager.tar.gz
│   ├── bookstack.tar.gz
│   ├── sjl-mcp.tar.gz
│   └── manifest.yaml         # Backup manifest
├── weekly/                   # Weekly archives
├── monthly/                  # Monthly archives
└── metadata.yaml             # Backup metadata
```

### 6. Scripts and Automation

**Location**: `/var/podman/shared/scripts/`

```
scripts/
├── deployment/               # Deployment scripts
│   ├── deploy-all.sh
│   ├── deploy-service.sh
│   └── rollback.sh
├── maintenance/              # Maintenance scripts
│   ├── cleanup.sh
│   ├── backup.sh
│   ├── restore.sh
│   └── health-check.sh
├── monitoring/               # Monitoring scripts
│   ├── check-services.sh
│   ├── check-resources.sh
│   └── alert-handler.sh
├── development/              # Dev scripts
│   ├── build-service.sh
│   ├── run-tests.sh
│   └── debug.sh
└── metadata.yaml             # Scripts metadata
```

---

## Metadata Schema

Every directory with important content should have a `metadata.yaml` file:

```yaml
# /var/podman/[service]/metadata.yaml
metadata:
  version: "1.0"
  created: "2026-07-05T00:00:00Z"
  last_updated: "2026-07-05T00:00:00Z"
  
service:
  name: "nginx-proxy-manager"
  container_name: "nginx-proxy-manager"
  image: "docker.io/jc21/nginx-proxy-manager:latest"
  quadlet: "/etc/containers/systemd/nginx-proxy-manager.container"
  status: "active"
  
directory:
  purpose: "Reverse proxy, SSL/TLS termination, load balancing"
  owner: "root"
  group: "root"
  permissions: "0755"
  
contents:
  config: "Nginx proxy manager configuration files"
  data: "Database and persistent application data"
  logs: "Application and access logs"
  
networks:
  - "frontend-net"
  - "app-net"
  
volumes:
  - path: "/var/podman/nginx-proxy-manager/data"
    mount: "/data"
    purpose: "Application data storage"
  - path: "/var/podman/nginx-proxy-manager/letsencrypt"
    mount: "/etc/letsencrypt"
    purpose: "SSL certificates"
    
backup:
  enabled: true
  frequency: "daily"
  retention_days: 30
  location: "/var/podman/shared/backups"
  
tags:
  - "production"
  - "frontend"
  - "infrastructure"
  - "public-facing"
  
notes: |
  - Reverse proxy for all external HTTP/HTTPS traffic
  - Manages SSL/TLS certificates via Let's Encrypt
  - Admin interface available on localhost:81
  - Requires /etc/podman/secrets/nginx-proxy-manager.env
```

---

## File Tagging Convention

All important files should have embedded metadata comments:

### YAML Files
```yaml
# === FILE METADATA ===
# Service: nginx-proxy-manager
# Container: nginx-proxy-manager
# Category: configuration
# Purpose: Proxy host definitions
# Version: 1.0
# Last Updated: 2026-07-05
# Owner: root
# Tags: #production #infrastructure #proxy
# ===

# Proxy host configuration
proxy_hosts:
  ...
```

### Shell Scripts
```bash
#!/bin/bash
# === SCRIPT METADATA ===
# Service: deployment
# Category: automation/deployment
# Purpose: Deploy all services
# Version: 1.0
# Dependencies: bash, docker, systemctl
# Tags: #deployment #automation
# Usage: bash deploy-all.sh [environment]
# ===

set -e
...
```

### Python Files
```python
"""
=== FILE METADATA ===
Service: sjl-mcp
Container: sjl-mcp-quadlet
Category: application/core
Purpose: Main MCP server implementation
Version: 1.3
Last Updated: 2026-07-05
Owner: shannon
Tags: #mcp #server #production
===
"""

import os
...
```

### JSON/Config Files
```json
{
  "_metadata": {
    "service": "bookstack",
    "container": "bookstack",
    "category": "configuration",
    "purpose": "Database configuration",
    "version": "1.0",
    "last_updated": "2026-07-05T00:00:00Z",
    "tags": ["production", "application", "database"]
  },
  "database": {
    ...
  }
}
```

---

## Organization Cleanup Tasks

### Phase 1: Audit Current State
- [ ] Scan all directories recursively
- [ ] Identify orphaned/unorganized files
- [ ] Document current file locations
- [ ] Identify missing metadata

### Phase 2: Create Directory Structure
- [ ] Create all standard directories
- [ ] Set proper permissions (0755 for dirs, 0644 for files)
- [ ] Create `.gitkeep` for empty dirs
- [ ] Document directory purposes

### Phase 3: Move/Organize Files
- [ ] Move service data to `/var/podman/[service]/data/`
- [ ] Move configs to `/var/podman/[service]/config/`
- [ ] Move source code to `/opt/[service]/`
- [ ] Move scripts to `/var/podman/shared/scripts/`
- [ ] Move backups to `/var/podman/shared/backups/`

### Phase 4: Add Metadata
- [ ] Create `metadata.yaml` for each service directory
- [ ] Tag all configuration files with embedded metadata
- [ ] Create README files for each directory
- [ ] Document file purposes and relationships

### Phase 5: Verify & Validate
- [ ] Verify all services still function
- [ ] Confirm all volume mounts correct
- [ ] Test backup/restore procedures
- [ ] Validate metadata accuracy

### Phase 6: Documentation
- [ ] Update system documentation
- [ ] Create file organization guide
- [ ] Document metadata schema
- [ ] Create examples for new files

---

## Oracle Cloud Organization

### Compute Instances
```
/var/podman/oracle/instances/
├── metadata.yaml
├── [instance-id-1]/
│   ├── config.json
│   ├── backups/
│   └── logs/
└── [instance-id-2]/
```

### Object Storage Buckets
```
/var/podman/oracle/buckets/
├── metadata.yaml
├── [bucket-name-1]/
│   ├── config.json
│   ├── manifests/
│   └── archives/
└── [bucket-name-2]/
```

### Configuration
```
/root/.oci/
├── config                    # Main OCI config
├── metadata.yaml            # OCI metadata
└── private_key              # Private key
```

---

## Best Practices

### 1. Naming Conventions
- **Directories**: `lowercase-with-hyphens` (no spaces)
- **Files**: `descriptive-name.extension`
- **Backups**: `service-name-YYYY-MM-DD.tar.gz`
- **Scripts**: `action-target.sh` (e.g., `backup-database.sh`)

### 2. Permission Structure
```bash
# Directories: 0755 (rwxr-xr-x)
chmod 755 /var/podman/[service]

# Configuration files: 0644 (rw-r--r--)
chmod 644 /var/podman/[service]/config/*

# Secrets: 0600 (rw-------)
chmod 600 /etc/podman/secrets/*.env

# Scripts: 0755 (rwxr-xr-x)
chmod 755 /var/podman/shared/scripts/*.sh
```

### 3. Metadata Requirements
Every important directory must have:
- `metadata.yaml` - Directory and content metadata
- `README.md` - Purpose and usage documentation
- `.gitkeep` - Preserve empty directories in git

### 4. Backup Strategy
- **Daily**: Full service data backups
- **Weekly**: Archive full system state
- **Monthly**: Long-term archive
- **Location**: `/var/podman/shared/backups/`

### 5. Documentation
- Update README files when structure changes
- Document all custom directories
- Maintain metadata.yaml files
- Keep file organization guide current

---

## Implementation Commands

```bash
# Create base structure
mkdir -p /var/podman/shared/{scripts,backups,certs}
mkdir -p /var/podman/{service-name}/{config,data,logs}

# Set permissions
chmod 755 /var/podman
chmod 755 /var/podman/*/
chmod 644 /var/podman/*/*

# Create metadata template
cat > metadata.yaml << 'EOF'
metadata:
  version: "1.0"
  created: "$(date -Iseconds)"
  service: "[SERVICE_NAME]"
EOF

# Create README template
cat > README.md << 'EOF'
# [Service Name] Directory

## Purpose
[Description of directory purpose]

## Contents
- config/: Configuration files
- data/: Application data
- logs/: Service logs

## Metadata
See metadata.yaml for detailed information
EOF

# Tag files
# For each important file, add metadata comment at the top
```

---

## Validation Checklist

- [ ] All services have dedicated directories
- [ ] All configs in [service]/config/
- [ ] All data in [service]/data/
- [ ] All scripts in shared/scripts/
- [ ] All backups in shared/backups/
- [ ] All metadata.yaml files present
- [ ] All files have embedded tags/metadata
- [ ] All permissions set correctly (755/644/600)
- [ ] All services still functional
- [ ] All volume mounts working
- [ ] Documentation updated
- [ ] Backup procedures tested

---

**Status**: Ready for implementation  
**Next**: Run cleanup and organization scripts
