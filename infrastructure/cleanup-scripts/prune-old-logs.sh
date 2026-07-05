#!/bin/bash
# Prune system logs older than 30 days
# Run daily via cron: 0 2 * * * /path/to/prune-old-logs.sh

set -e

LOG_RETENTION_DAYS=30
PRUNE_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
REPORT_FILE="/var/log/prune-logs-${PRUNE_TIMESTAMP// /_}.report"

echo "╔════════════════════════════════════════════════════╗"
echo "║   System Log Pruning - 30 Day Retention Policy     ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "Retention Policy: Keep logs from last $LOG_RETENTION_DAYS days"
echo "Prune Time: $PRUNE_TIMESTAMP"
echo ""

# Function to safely remove old files
prune_directory() {
    local dir="$1"
    local pattern="${2:--name '*.log'}"

    if [ ! -d "$dir" ]; then
        return
    fi

    echo "Pruning $dir..."

    # Find and delete files older than 30 days
    local count=$(find "$dir" $pattern -type f -mtime +$LOG_RETENTION_DAYS 2>/dev/null | wc -l)

    if [ "$count" -gt 0 ]; then
        find "$dir" $pattern -type f -mtime +$LOG_RETENTION_DAYS -delete 2>/dev/null || true
        echo "  ✅ Deleted $count files older than $LOG_RETENTION_DAYS days"
    else
        echo "  ℹ️  No files older than $LOG_RETENTION_DAYS days"
    fi
}

# Prune system logs
{
    echo "Log Pruning Report - $PRUNE_TIMESTAMP"
    echo "======================================="
    echo ""

    prune_directory "/var/log" "-name '*.log' -o -name '*.log.*'"
    prune_directory "/var/podman" "-name '*.log'"
    prune_directory "/var/log/systemd-cleanup" "-type f"
    prune_directory "/var/log/system-cleanup-*" "-type f"

    # Compress remaining logs from 7-30 days old
    echo ""
    echo "Compressing logs from 7-30 days..."
    find /var/log -name "*.log" -type f -mtime +7 -mtime -30 ! -name "*.gz" -exec gzip {} \; 2>/dev/null || true

    # Vacuum journal logs (systemd)
    echo "Vacuuming systemd journal..."
    journalctl --vacuum=30d 2>/dev/null || true

    echo ""
    echo "Disk usage after cleanup:"
    du -sh /var/log

} | tee -a "$REPORT_FILE"

echo ""
echo "✅ Log pruning complete. Report: $REPORT_FILE"
