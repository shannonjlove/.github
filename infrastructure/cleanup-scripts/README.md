# System Cleanup & Organization Scripts

**Purpose**: Comprehensive VPS and Oracle Cloud file organization, metadata tagging, and cleanup  
**Status**: Ready for deployment  
**Version**: 1.0

---

## Scripts Overview

### 1. discover-and-audit.sh
**Purpose**: Audit current system state and identify organization needs

**What it does**:
- Scans all directories recursively
- Identifies orphaned/unorganized files
- Checks for missing metadata
- Analyzes permissions
- Generates comprehensive audit report

**Usage**:
```bash
bash discover-and-audit.sh
```

**Output**: Detailed audit report with recommendations

---

### 2. organize-directories.sh
**Purpose**: Create standard directory structure for all services

**What it does**:
- Creates `/var/podman/[service]/config/`
- Creates `/var/podman/[service]/data/`
- Creates `/var/podman/[service]/logs/`
- Generates `metadata.yaml` template
- Generates `README.md` documentation
- Sets proper permissions

**Usage**:
```bash
# Dry run (no changes)
DRY_RUN=true bash organize-directories.sh

# Apply all services
bash organize-directories.sh all

# Apply specific service
bash organize-directories.sh nginx-proxy-manager
```

**Services**:
- nginx-proxy-manager
- sjl-mcp-quadlet
- memory-agent
- sjl-file-api
- mcp-filesystem
- basic-memory
- bookstack
- paperless
- rclone-mcp
- rclone-rc
- pibn
- tailscale

---

### 3. add-metadata-tags.sh
**Purpose**: Add metadata tags to all configuration files

**What it does**:
- Tags YAML files with metadata comments
- Tags JSON files with `_metadata` field
- Tags shell scripts with metadata header
- Updates all important files with service/category/purpose info

**Usage**:
```bash
# Tag specific service
bash add-metadata-tags.sh nginx-proxy-manager

# Tag all services
bash add-metadata-tags.sh all
```

**Metadata Fields**:
```yaml
Service: service-name
Category: configuration/script/data
Purpose: What this file does
Version: 1.0
Tags: #service #category #type
```

---

### 4. SYSTEM_CLEANUP_MASTER.sh
**Purpose**: Master orchestration script for complete cleanup

**What it does**:
- Runs all phases sequentially
- Generates comprehensive logs
- Validates each phase
- Creates final documentation
- Produces audit trail

**Usage**:
```bash
# Run all phases
sudo bash SYSTEM_CLEANUP_MASTER.sh all

# Run specific phase
sudo bash SYSTEM_CLEANUP_MASTER.sh 1  # discovery
sudo bash SYSTEM_CLEANUP_MASTER.sh 2  # directory
sudo bash SYSTEM_CLEANUP_MASTER.sh 3  # metadata
sudo bash SYSTEM_CLEANUP_MASTER.sh 4  # validation
sudo bash SYSTEM_CLEANUP_MASTER.sh 5  # documentation

# Dry run
DRY_RUN=true sudo bash SYSTEM_CLEANUP_MASTER.sh all
```

**Phases**:
1. **Discovery**: Audit current state
2. **Directory**: Create standard structure
3. **Metadata**: Add metadata tags
4. **Validation**: Verify everything
5. **Documentation**: Generate docs

**Output**: 
- Logs in `/var/log/system-cleanup-TIMESTAMP/`
- Summary reports for each phase
- Final verification report

---

## Directory Structure Created

```
/var/podman/
├── nginx-proxy-manager/
│   ├── config/          # Configuration files
│   ├── data/            # Application data
│   ├── logs/            # Service logs
│   ├── metadata.yaml    # Service metadata
│   └── README.md        # Documentation
├── sjl-mcp-quadlet/
│   ├── config/
│   ├── data/
│   ├── logs/
│   ├── metadata.yaml
│   └── README.md
├── [12 more services...]
└── shared/
    ├── scripts/         # Automation scripts
    ├── backups/         # Backup files
    └── certs/           # SSL certificates

/etc/podman/secrets/
├── nginx-proxy-manager.env
├── sjl-mcp.env
├── [12 more .env files...]
└── metadata.yaml

/opt/
├── sjl-mcp/
│   ├── src/
│   ├── config/
│   ├── tests/
│   ├── docs/
│   ├── metadata.yaml
│   └── README.md
└── [other applications]/
```

---

## Metadata Schema

Every directory and important file now has metadata:

### Directory Metadata (metadata.yaml)
```yaml
metadata:
  version: "1.0"
  created: "2026-07-05T00:00:00Z"
  service: "service-name"
  container_name: "container-name"

directory:
  purpose: "Service data and configuration"
  owner: "root"
  group: "root"

contents:
  config: "Configuration files"
  data: "Application data"
  logs: "Service logs"

tags:
  - "production"
  - "service-name"
  - "infrastructure"
```

### File Metadata (embedded)
```yaml
# === FILE METADATA ===
# Service: service-name
# Container: container-name
# Category: configuration
# Purpose: What this file does
# Version: 1.0
# Last Updated: 2026-07-05T00:00:00Z
# Tags: #service #category #type
# ===
```

---

## Execution Workflow

### Quick Start (Recommended)

```bash
# Step 1: Audit current state (no changes)
bash discover-and-audit.sh

# Step 2: Review recommendations
# (Read the audit report and decide to proceed)

# Step 3: Run master cleanup
sudo bash SYSTEM_CLEANUP_MASTER.sh all

# Step 4: Verify results
sudo systemctl status *.service
podman ps -a
```

### Step-by-Step (Manual Control)

```bash
# Phase 1: Discover
bash discover-and-audit.sh
# Review output and recommendations

# Phase 2: Create directories (dry run first)
DRY_RUN=true bash organize-directories.sh all
# Review what would be created

# Phase 2: Create directories (for real)
bash organize-directories.sh all

# Phase 3: Add metadata
bash add-metadata-tags.sh all

# Phase 4: Validation (manual)
find /var/podman -name metadata.yaml | wc -l
systemctl status *.service
```

---

## Safety & Rollback

### Before Running
1. **Backup everything**:
   ```bash
   sudo tar -czf /var/podman/shared/backups/pre-cleanup-backup.tar.gz /var/podman /etc/podman
   ```

2. **Take snapshot** (if on supported filesystem):
   ```bash
   sudo lvcreate -L10G -s -n vps_backup /dev/vg0/vps_data
   ```

3. **Document current state**:
   ```bash
   systemctl list-units --type=service > current-services.txt
   ```

### If Something Goes Wrong

```bash
# Restore from backup
sudo tar -xzf /var/podman/shared/backups/pre-cleanup-backup.tar.gz -C /

# Restart services
sudo systemctl daemon-reload
sudo systemctl restart *.service

# Verify restoration
systemctl status *.service
```

---

## Validation Checklist

After running cleanup, verify:

- [ ] All 12 services have `/var/podman/[service]/config/` directory
- [ ] All 12 services have `/var/podman/[service]/data/` directory
- [ ] All 12 services have `/var/podman/[service]/logs/` directory
- [ ] All services have `metadata.yaml` file
- [ ] All services have `README.md` file
- [ ] Directory permissions are 755
- [ ] File permissions are 644
- [ ] Secrets permissions are 600
- [ ] All services start without errors
- [ ] All health checks passing
- [ ] All volume mounts working correctly
- [ ] Systemd logs show no errors

---

## Log Output Example

```
╔════════════════════════════════════════════════════╗
║    VPS & Oracle Cloud System Cleanup & Organization║
║                 Master Script v1.0                  ║
╚════════════════════════════════════════════════════╝

PHASE 1: System Discovery & Audit
═════════════════════════════════
🔍 Running system audit...
[Detailed audit output...]

PHASE 2: Create Standard Directory Structure
═════════════════════════════════════════════
📁 Creating directory structure...
Processing service: nginx-proxy-manager
  📁 Creating /var/podman/nginx-proxy-manager/config/
  📁 Creating /var/podman/nginx-proxy-manager/data/
  📁 Creating /var/podman/nginx-proxy-manager/logs/
  📝 Creating metadata.yaml
  📖 Creating README.md
  ✅ nginx-proxy-manager organized

[... more services ...]

PHASE 3: Add Metadata Tags
═════════════════════════
🏷️ Adding metadata tags to files...
Processing service: nginx-proxy-manager
  🏷️  Tagging /var/podman/nginx-proxy-manager/config/proxy-hosts.json

[... more files ...]

PHASE 4: Verification & Validation
════════════════════════════════════
✅ All services verified
✅ Permissions correct
✅ Metadata present

✅ CLEANUP & ORGANIZATION COMPLETE!
```

---

## Troubleshooting

### Service won't start after cleanup
```bash
# Check service status
sudo systemctl status [service].service

# View error logs
sudo journalctl -u [service].service -n 50

# Check volume mounts
sudo podman inspect [service] | grep -A 10 Mounts

# Restore if needed
sudo systemctl stop [service].service
# Restore file from backup
sudo systemctl start [service].service
```

### Permission denied errors
```bash
# Fix permissions
sudo chmod 755 /var/podman/[service]/
sudo chmod 644 /var/podman/[service]/*/*
sudo chmod 600 /etc/podman/secrets/*.env
```

### Metadata not applied
```bash
# Check what was tagged
find /var/podman -name "metadata.yaml" | wc -l

# Re-run tagging
bash add-metadata-tags.sh [service]
```

---

## Oracle Cloud Integration

For Oracle Cloud:

```bash
# Create Oracle-specific directory structure
mkdir -p /var/podman/oracle/{instances,buckets,config}

# Add OCI metadata
cat > /var/podman/oracle/metadata.yaml << 'EOF'
oracle_cloud:
  compartment: "your-compartment-id"
  region: "your-region"
  config_location: "/root/.oci/config"
  instances: []
  buckets: []
EOF
```

---

## Next Steps

1. ✅ Run discovery audit
2. ✅ Run master cleanup script
3. ✅ Verify all services healthy
4. ✅ Test backup/restore
5. ✅ Document any custom changes
6. ✅ Set up automated metadata updates

---

**Maintained by**: Claude Code  
**Last Updated**: 2026-07-05  
**Version**: 1.0
