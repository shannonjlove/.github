#!/bin/bash
# Setup daily log pruning via cron
# Prunes logs older than 30 days every day at 2 AM

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run as root"
    exit 1
fi

CRON_SCRIPT="/home/user/.github/infrastructure/cleanup-scripts/prune-old-logs.sh"

if [ ! -f "$CRON_SCRIPT" ]; then
    echo "ERROR: Script not found at $CRON_SCRIPT"
    exit 1
fi

echo "Setting up daily log pruning..."

# Add cron job (runs daily at 2 AM)
CRON_JOB="0 2 * * * $CRON_SCRIPT"

# Check if already exists
if crontab -l 2>/dev/null | grep -q "$CRON_SCRIPT"; then
    echo "✅ Cron job already configured"
else
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job added: Daily at 2:00 AM"
fi

echo ""
echo "Cron configuration:"
crontab -l 2>/dev/null | grep "$CRON_SCRIPT" || echo "No cron job found"
