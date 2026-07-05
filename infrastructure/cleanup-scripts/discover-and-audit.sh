#!/bin/bash
# === SCRIPT METADATA ===
# Service: system-maintenance
# Category: automation/discovery
# Purpose: Audit current file organization and identify cleanup needs
# Version: 1.0
# Dependencies: bash, find, grep, awk
# Tags: #audit #discovery #cleanup #organization
# Usage: bash discover-and-audit.sh
# ===

set -e

AUDIT_DIR="/tmp/system-audit-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$AUDIT_DIR/audit-report.txt"

echo "📊 VPS & Oracle Cloud System Audit"
echo "===================================="
mkdir -p "$AUDIT_DIR"

{
    echo "=== SYSTEM AUDIT REPORT ==="
    echo "Generated: $(date)"
    echo ""

    # 1. Podman Structure
    echo "1️⃣  PODMAN DIRECTORY STRUCTURE"
    echo "=============================="
    echo ""
    echo "Current /var/podman structure:"
    ls -lah /var/podman/ 2>/dev/null || echo "  ❌ /var/podman not found"
    echo ""

    echo "Podman service directories:"
    find /var/podman -maxdepth 1 -type d ! -name "." -exec basename {} \; | sort
    echo ""

    # 2. Orphaned Files
    echo "2️⃣  ORPHANED/UNORGANIZED FILES"
    echo "=============================="
    echo ""
    echo "Files in /var/podman root (should be in service dirs):"
    find /var/podman -maxdepth 1 -type f -exec ls -lh {} \; 2>/dev/null || echo "  ✅ None found"
    echo ""

    # 3. Missing Metadata Files
    echo "3️⃣  METADATA AUDIT"
    echo "=================="
    echo ""
    echo "Directories without metadata.yaml:"
    for dir in /var/podman/*/; do
        if [ ! -f "$dir/metadata.yaml" ]; then
            echo "  ❌ $(basename $dir) - missing metadata.yaml"
        fi
    done
    echo ""

    # 4. Permission Issues
    echo "4️⃣  PERMISSION AUDIT"
    echo "===================="
    echo ""
    echo "Checking directory permissions:"
    for dir in /var/podman/*/; do
        perms=$(stat -c '%A' "$dir")
        echo "  $perms - $(basename $dir)"
    done
    echo ""

    echo "Checking secrets permissions:"
    if [ -d /etc/podman/secrets ]; then
        ls -lah /etc/podman/secrets/ | grep -E "\.env$"
    fi
    echo ""

    # 5. Application Source Code
    echo "5️⃣  APPLICATION SOURCE CODE LOCATIONS"
    echo "======================================"
    echo ""
    echo "Files in /opt/:"
    find /opt -maxdepth 2 -type f \( -name "docker-compose.yml" -o -name "*.py" -o -name "*.js" -o -name "requirements.txt" \) 2>/dev/null | head -20 || echo "  ✅ Minimal files"
    echo ""

    # 6. Backup Analysis
    echo "6️⃣  BACKUP ANALYSIS"
    echo "==================="
    echo ""
    echo "Backup locations:"
    for dir in /var/podman/shared/backups /root/backups /tmp/backups; do
        if [ -d "$dir" ]; then
            echo "  ✅ $dir"
            du -sh "$dir" 2>/dev/null
        fi
    done
    echo ""

    # 7. System Config Analysis
    echo "7️⃣  SYSTEM CONFIGURATION FILES"
    echo "==============================="
    echo ""
    echo "OCI Configuration:"
    if [ -f /root/.oci/config ]; then
        echo "  ✅ /root/.oci/config exists"
    else
        echo "  ❌ /root/.oci/config missing"
    fi
    echo ""

    echo "SSH Configuration:"
    ls -lah /root/.ssh/ 2>/dev/null | head -5 || echo "  ⚠️  /root/.ssh needs organization"
    echo ""

    # 8. Docker Compose Orphans
    echo "8️⃣  DOCKER COMPOSE FILES (TO BE ARCHIVED)"
    echo "=========================================="
    echo ""
    find /opt -name "docker-compose.yml" -o -name "docker-compose.yaml" 2>/dev/null | while read file; do
        echo "  📄 $file"
        echo "     Size: $(du -h \"$file\" | cut -f1)"
    done
    echo ""

    # 9. Service Directory Content Summary
    echo "9️⃣  SERVICE DIRECTORY CONTENT SUMMARY"
    echo "===================================="
    echo ""
    for service_dir in /var/podman/*/; do
        service=$(basename "$service_dir")
        echo "Service: $service"

        # Check subdirectories
        if [ -d "$service_dir/config" ]; then
            file_count=$(find "$service_dir/config" -type f 2>/dev/null | wc -l)
            echo "  config/: $file_count files"
        else
            echo "  config/: ❌ MISSING"
        fi

        if [ -d "$service_dir/data" ]; then
            size=$(du -sh "$service_dir/data" 2>/dev/null | cut -f1)
            echo "  data/: $size"
        else
            echo "  data/: ❌ MISSING"
        fi

        if [ -d "$service_dir/logs" ]; then
            log_count=$(find "$service_dir/logs" -type f 2>/dev/null | wc -l)
            echo "  logs/: $log_count files"
        else
            echo "  logs/: ⚠️  MISSING (can create)"
        fi

        echo ""
    done

    # 10. Recommendations
    echo "🔟 RECOMMENDATIONS FOR CLEANUP"
    echo "==============================="
    echo ""
    echo "Action Items:"
    echo "  1. Create missing subdirectories (config/, data/, logs/)"
    echo "  2. Move orphaned files to appropriate directories"
    echo "  3. Create metadata.yaml for each service"
    echo "  4. Tag configuration files with metadata comments"
    echo "  5. Archive old docker-compose.yml files"
    echo "  6. Set proper permissions (755 for dirs, 644 for files, 600 for secrets)"
    echo "  7. Create README files in each service directory"
    echo ""

} | tee "$LOG_FILE"

echo ""
echo "✅ Audit complete! Report saved to: $AUDIT_DIR/audit-report.txt"
echo ""
echo "📊 Summary Statistics:"
echo "  Total service directories: $(ls -d /var/podman/*/ 2>/dev/null | wc -l)"
echo "  Metadata files found: $(find /var/podman -name 'metadata.yaml' 2>/dev/null | wc -l)"
echo "  Total size: $(du -sh /var/podman 2>/dev/null | cut -f1)"
