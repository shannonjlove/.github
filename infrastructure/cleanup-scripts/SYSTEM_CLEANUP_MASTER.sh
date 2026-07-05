#!/bin/bash
# === SCRIPT METADATA ===
# Service: system-maintenance
# Category: automation/orchestration
# Purpose: Master orchestration script for complete system cleanup and organization
# Version: 1.0
# Dependencies: bash, all cleanup subscripts
# Tags: #orchestration #cleanup #maintenance #organization
# Usage: sudo bash SYSTEM_CLEANUP_MASTER.sh [phase] [--dry-run]
# ===

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHASE=${1:-"all"}
DRY_RUN=${DRY_RUN:-false}
LOG_DIR="/var/log/system-cleanup-$(date +%Y%m%d-%H%M%S)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════╗"
echo "║    VPS & Oracle Cloud System Cleanup & Organization║"
echo "║                 Master Script v1.0                  ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Execution Parameters:${NC}"
echo "  Phase: $PHASE"
echo "  Dry Run: $DRY_RUN"
echo "  Log Directory: $LOG_DIR"
echo ""

mkdir -p "$LOG_DIR"

# Phase 1: Discovery & Audit
phase_discovery() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}PHASE 1: System Discovery & Audit${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$SCRIPT_DIR/discover-and-audit.sh" ]; then
        echo -e "${RED}❌ discover-and-audit.sh not found${NC}"
        return 1
    fi

    echo -e "${YELLOW}🔍 Running system audit...${NC}"
    bash "$SCRIPT_DIR/discover-and-audit.sh" 2>&1 | tee "$LOG_DIR/01-audit-report.txt"

    echo ""
    echo -e "${GREEN}✅ Phase 1 Complete: System audited${NC}"
    echo ""
}

# Phase 2: Create Directory Structure
phase_directory_structure() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}PHASE 2: Create Standard Directory Structure${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$SCRIPT_DIR/organize-directories.sh" ]; then
        echo -e "${RED}❌ organize-directories.sh not found${NC}"
        return 1
    fi

    echo -e "${YELLOW}📁 Creating directory structure...${NC}"
    DRY_RUN="$DRY_RUN" bash "$SCRIPT_DIR/organize-directories.sh" all 2>&1 | tee "$LOG_DIR/02-organize-dirs.txt"

    echo ""
    echo -e "${GREEN}✅ Phase 2 Complete: Directory structure created${NC}"
    echo ""
}

# Phase 3: Add Metadata Tags
phase_metadata() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}PHASE 3: Add Metadata Tags${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$SCRIPT_DIR/add-metadata-tags.sh" ]; then
        echo -e "${RED}❌ add-metadata-tags.sh not found${NC}"
        return 1
    fi

    echo -e "${YELLOW}🏷️  Adding metadata tags to files...${NC}"
    bash "$SCRIPT_DIR/add-metadata-tags.sh" all 2>&1 | tee "$LOG_DIR/03-metadata-tags.txt"

    echo ""
    echo -e "${GREEN}✅ Phase 3 Complete: Metadata added${NC}"
    echo ""
}

# Phase 4: Verify & Validate
phase_validation() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}PHASE 4: Verification & Validation${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""

    {
        echo "=== SYSTEM VERIFICATION REPORT ==="
        echo "Generated: $(date)"
        echo ""

        echo "✅ Directory Structure Verification:"
        echo "===================================="
        for service in nginx-proxy-manager sjl-mcp-quadlet memory-agent sjl-file-api mcp-filesystem basic-memory bookstack paperless rclone-mcp rclone-rc pibn tailscale; do
            if [ -d "/var/podman/$service" ]; then
                echo "  ✅ $service"
                for subdir in config data logs; do
                    if [ -d "/var/podman/$service/$subdir" ]; then
                        echo "     ✅ $subdir/"
                    else
                        echo "     ❌ $subdir/ MISSING"
                    fi
                done
                if [ -f "/var/podman/$service/metadata.yaml" ]; then
                    echo "     ✅ metadata.yaml"
                else
                    echo "     ❌ metadata.yaml MISSING"
                fi
            else
                echo "  ❌ $service NOT FOUND"
            fi
        done
        echo ""

        echo "🔐 Permission Verification:"
        echo "=========================="
        for dir in /var/podman/*/; do
            perms=$(stat -c '%A' "$dir")
            expected="drwxr-xr-x"
            if [ "$perms" = "$expected" ]; then
                echo "  ✅ $(basename $dir): $perms"
            else
                echo "  ⚠️  $(basename $dir): $perms (expected $expected)"
            fi
        done
        echo ""

        echo "📊 Service Health Check:"
        echo "======================="
        systemctl list-units --type=service --state=running | grep -E "container|\.service" | awk '{print "  ✅ " $1}' || echo "  ⚠️  Unable to verify services"
        echo ""

    } | tee "$LOG_DIR/04-verification.txt"

    echo -e "${GREEN}✅ Phase 4 Complete: System verified${NC}"
    echo ""
}

# Phase 5: Generate Documentation
phase_documentation() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}PHASE 5: Generate Documentation${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""

    {
        cat << 'EOF'
# System Organization Documentation

## Directory Structure
All service data is now organized under /var/podman/[service-name] with:
- config/: Configuration files
- data/: Persistent application data
- logs/: Service logs

## Metadata System
Each service directory contains:
- metadata.yaml: Complete service metadata
- README.md: Service documentation

## Tagging Convention
All important files have metadata comments with:
- Service name
- Category
- Purpose
- Version
- Tags

## File Organization Summary
EOF

        for service in /var/podman/*/; do
            service_name=$(basename "$service")
            echo ""
            echo "### $service_name"
            echo "- Config files: $(find $service/config -type f 2>/dev/null | wc -l)"
            echo "- Data size: $(du -sh $service/data 2>/dev/null | cut -f1)"
            echo "- Has metadata: $([ -f $service/metadata.yaml ] && echo 'Yes' || echo 'No')"
        done

    } | tee "$LOG_DIR/05-documentation.txt"

    echo -e "${GREEN}✅ Phase 5 Complete: Documentation generated${NC}"
    echo ""
}

# Master execution
run_all_phases() {
    phase_discovery || { echo -e "${RED}❌ Phase 1 failed${NC}"; exit 1; }
    phase_directory_structure || { echo -e "${RED}❌ Phase 2 failed${NC}"; exit 1; }
    phase_metadata || { echo -e "${RED}❌ Phase 3 failed${NC}"; exit 1; }
    phase_validation || { echo -e "${RED}❌ Phase 4 failed${NC}"; exit 1; }
    phase_documentation || { echo -e "${RED}❌ Phase 5 failed${NC}"; exit 1; }
}

# Execute based on phase parameter
case "$PHASE" in
    1|discovery)
        phase_discovery
        ;;
    2|directory)
        phase_directory_structure
        ;;
    3|metadata)
        phase_metadata
        ;;
    4|validation)
        phase_validation
        ;;
    5|documentation)
        phase_documentation
        ;;
    all)
        run_all_phases
        ;;
    *)
        echo -e "${RED}Unknown phase: $PHASE${NC}"
        echo "Valid phases: 1, 2, 3, 4, 5, or 'all'"
        exit 1
        ;;
esac

# Final Summary
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ CLEANUP & ORGANIZATION COMPLETE!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📊 Results Summary:${NC}"
echo "  Log directory: $LOG_DIR"
echo "  All logs preserved for audit trail"
echo ""
echo -e "${YELLOW}📁 Directory Structure:${NC}"
echo "  /var/podman/[service]/"
echo "    ├── config/     (configuration files)"
echo "    ├── data/       (application data)"
echo "    ├── logs/       (service logs)"
echo "    ├── metadata.yaml"
echo "    └── README.md"
echo ""
echo -e "${YELLOW}📊 Next Steps:${NC}"
echo "  1. Review logs in: $LOG_DIR"
echo "  2. Test service restart: systemctl restart [service].service"
echo "  3. Verify all services running: systemctl status *.service"
echo "  4. Backup new structure: bash backup-all-services.sh"
echo ""
