#!/bin/bash
# === SCRIPT METADATA ===
# Service: system-maintenance
# Category: automation/organization
# Purpose: Organize VPS directories to standard structure
# Version: 1.0
# Dependencies: bash, mkdir, chmod, mv
# Tags: #organization #cleanup #directories
# Usage: bash organize-directories.sh [service-name or 'all']
# ===

set -e

SERVICES_TO_ORGANIZE=("$@")
if [ ${#SERVICES_TO_ORGANIZE[@]} -eq 0 ] || [ "${SERVICES_TO_ORGANIZE[0]}" = "all" ]; then
    SERVICES_TO_ORGANIZE=(nginx-proxy-manager sjl-mcp-quadlet memory-agent sjl-file-api mcp-filesystem basic-memory bookstack paperless rclone-mcp rclone-rc pibn tailscale)
fi

echo "📁 Directory Organization Script"
echo "================================"
echo ""

DRY_RUN=${DRY_RUN:-false}

if [ "$DRY_RUN" = "true" ]; then
    echo "⚠️  DRY RUN MODE - No changes will be made"
    echo ""
fi

# Function to create directory structure
create_structure() {
    local service=$1
    local base_path="/var/podman/$service"

    echo "Processing service: $service"

    if [ ! -d "$base_path" ]; then
        echo "  ⚠️  $base_path does not exist - skipping"
        return
    fi

    # Create subdirectories if they don't exist
    for subdir in config data logs; do
        if [ ! -d "$base_path/$subdir" ]; then
            echo "  📁 Creating $base_path/$subdir/"
            if [ "$DRY_RUN" = "false" ]; then
                mkdir -p "$base_path/$subdir"
                chmod 755 "$base_path/$subdir"
            fi
        else
            echo "  ✅ $base_path/$subdir/ exists"
        fi
    done

    # Create metadata.yaml if missing
    if [ ! -f "$base_path/metadata.yaml" ]; then
        echo "  📝 Creating metadata.yaml"
        if [ "$DRY_RUN" = "false" ]; then
            cat > "$base_path/metadata.yaml" << EOF
# === FILE METADATA ===
# Service: $service
# Category: container-data
# Purpose: Service configuration and data storage
# Version: 1.0
# Last Updated: $(date -Iseconds)
# Tags: #$service #production #container
# ===

metadata:
  version: "1.0"
  created: "$(date -Iseconds)"
  service: "$service"
  container_name: "$service"

directory:
  purpose: "Container data for $service"
  owner: "root"
  group: "root"

contents:
  config: "Configuration files and settings"
  data: "Persistent application data"
  logs: "Application and system logs"

tags:
  - "production"
  - "$service"
  - "container"
EOF
        fi
    else
        echo "  ✅ metadata.yaml exists"
    fi

    # Create README if missing
    if [ ! -f "$base_path/README.md" ]; then
        echo "  📖 Creating README.md"
        if [ "$DRY_RUN" = "false" ]; then
            cat > "$base_path/README.md" << EOF
# $service Service Data

## Directory Structure

- **config/**: Configuration files and settings
- **data/**: Persistent application data
- **logs/**: Application and system logs

## Metadata

See \`metadata.yaml\` for detailed service information.

## Backup

This directory is backed up to \`/var/podman/shared/backups/\` daily.

## Management

Service is managed via systemd:
\`\`\`bash
sudo systemctl status $service.service
sudo systemctl restart $service.service
\`\`\`

View logs:
\`\`\`bash
sudo journalctl -u $service.service -f
sudo podman logs -f $service
\`\`\`
EOF
        fi
    else
        echo "  ✅ README.md exists"
    fi

    echo "  ✅ $service organized"
    echo ""
}

# Process each service
for service in "${SERVICES_TO_ORGANIZE[@]}"; do
    create_structure "$service"
done

echo "═════════════════════════════════════════"
echo "✅ Directory organization complete!"
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo "To apply changes, run:"
    echo "  bash organize-directories.sh"
fi

# Set permissions
echo ""
echo "🔐 Setting directory permissions..."

if [ "$DRY_RUN" = "false" ]; then
    chmod 755 /var/podman
    chmod 755 /var/podman/*/
    chmod 755 /var/podman/*/*/
    chmod 644 /var/podman/*/* 2>/dev/null || true
    echo "  ✅ Permissions set"
fi

echo ""
echo "📊 Final Structure:"
echo ""
echo "tree /var/podman -L 2"
if command -v tree &> /dev/null; then
    tree /var/podman -L 2 2>/dev/null || true
else
    find /var/podman -maxdepth 2 -type d | sort | sed 's|[^/]*/| |g'
fi
