#!/bin/bash
# === SCRIPT METADATA ===
# Service: system-maintenance
# Category: automation/metadata
# Purpose: Add metadata tags to configuration files
# Version: 1.0
# Dependencies: bash, grep, sed
# Tags: #metadata #tagging #documentation
# Usage: bash add-metadata-tags.sh [service-name]
# ===

set -e

SERVICE=${1:-"all"}

echo "🏷️  File Metadata Tagging Script"
echo "================================"
echo ""

# Function to add metadata to YAML files
tag_yaml_file() {
    local file=$1
    local service=$2
    local category=$3

    if head -1 "$file" | grep -q "^#.*METADATA"; then
        # Already tagged
        return
    fi

    echo "  🏷️  Tagging $file"

    # Create temp file with metadata
    {
        cat << EOF
# === FILE METADATA ===
# Service: $service
# Category: $category
# Purpose: Configuration for $service service
# Version: 1.0
# Last Updated: $(date -Iseconds)
# Tags: #$service #configuration #production
# ===

EOF
        cat "$file"
    } > "${file}.tmp"

    mv "${file}.tmp" "$file"
}

# Function to add metadata to JSON files
tag_json_file() {
    local file=$1
    local service=$2
    local category=$3

    # Check if already has _metadata
    if grep -q '"_metadata"' "$file"; then
        return
    fi

    echo "  🏷️  Tagging $file"

    # Add _metadata to beginning of JSON
    {
        echo "{"
        cat << EOF
  "_metadata": {
    "service": "$service",
    "category": "$category",
    "purpose": "Configuration for $service service",
    "version": "1.0",
    "last_updated": "$(date -Iseconds)",
    "tags": ["#$service", "#configuration", "#production"]
  },
EOF
        tail -n +2 "$file"
    } > "${file}.tmp"

    mv "${file}.tmp" "$file"
}

# Function to add metadata to shell scripts
tag_shell_file() {
    local file=$1
    local service=$2
    local category=$3

    if head -5 "$file" | grep -q "SCRIPT METADATA"; then
        return
    fi

    echo "  🏷️  Tagging $file"

    {
        head -1 "$file"  # Keep shebang
        cat << EOF
# === SCRIPT METADATA ===
# Service: $service
# Category: $category
# Purpose: Script for $service operations
# Version: 1.0
# Dependencies: bash, standard linux utils
# Tags: #$service #automation #script
# ===

EOF
        tail -n +2 "$file"
    } > "${file}.tmp"

    mv "${file}.tmp" "$file"
}

# Process service configurations
if [ "$SERVICE" = "all" ]; then
    services=(nginx-proxy-manager sjl-mcp-quadlet memory-agent sjl-file-api mcp-filesystem basic-memory bookstack paperless rclone-mcp rclone-rc pibn tailscale)
else
    services=("$SERVICE")
fi

for service in "${services[@]}"; do
    service_dir="/var/podman/$service"

    if [ ! -d "$service_dir" ]; then
        echo "⚠️  Service directory not found: $service_dir"
        continue
    fi

    echo "Processing service: $service"
    echo ""

    # Tag YAML files
    if [ -d "$service_dir/config" ]; then
        find "$service_dir/config" -name "*.yaml" -o -name "*.yml" | while read file; do
            tag_yaml_file "$file" "$service" "configuration"
        done
    fi

    # Tag JSON files
    if [ -d "$service_dir/config" ]; then
        find "$service_dir/config" -name "*.json" | while read file; do
            tag_json_file "$file" "$service" "configuration"
        done
    fi

    # Tag shell scripts
    if [ -d "$service_dir/config" ]; then
        find "$service_dir/config" -name "*.sh" -type f | while read file; do
            tag_shell_file "$file" "$service" "script"
        done
    fi

    echo "  ✅ $service tagged"
    echo ""
done

echo "✅ Metadata tagging complete!"
