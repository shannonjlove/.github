#!/bin/bash
# Setup daily backup to Backblaze B2
# Requires: Backblaze B2 account, API credentials, and b2 CLI tool

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║   Backblaze B2 Daily Backup Setup                 ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run as root"
    exit 1
fi

# ============================================================================
# 1. INSTALL B2 CLI TOOL
# ============================================================================
echo "Step 1: Installing Backblaze B2 CLI..."

if ! command -v b2 &> /dev/null; then
    pip3 install b2 || apt-get update && apt-get install -y python3-pip && pip3 install b2
    echo "✅ B2 CLI installed"
else
    echo "✅ B2 CLI already installed"
fi

echo ""

# ============================================================================
# 2. CREATE BACKUP CONFIGURATION
# ============================================================================
echo "Step 2: Creating backup configuration..."

# Create configuration directory
mkdir -p /etc/backblaze-backup
chmod 700 /etc/backblaze-backup

cat > /etc/backblaze-backup/backup.conf << 'EOF'
# Backblaze B2 Backup Configuration
# Fill in with your B2 account credentials

B2_ACCOUNT_ID=""
B2_APPLICATION_KEY=""
B2_BUCKET_NAME=""

# Directories to backup (space-separated)
BACKUP_DIRS="/var/podman /home/user/.github/infrastructure /etc/systemd/system"

# Backup retention in days
RETENTION_DAYS=90

# Compression (true/false)
COMPRESS_BACKUP=true

# Email for notifications (optional)
BACKUP_EMAIL=""
EOF

chmod 600 /etc/backblaze-backup/backup.conf

echo "✅ Configuration file created at /etc/backblaze-backup/backup.conf"
echo "   ACTION REQUIRED: Edit and fill in your B2 credentials"
echo ""

# ============================================================================
# 3. CREATE BACKUP SCRIPT
# ============================================================================
echo "Step 3: Creating backup script..."

cat > /var/podman/backups/daily-backup.sh << 'BACKUP_EOF'
#!/bin/bash
# Daily backup to Backblaze B2

set -e

source /etc/backblaze-backup/backup.conf

if [ -z "$B2_ACCOUNT_ID" ] || [ -z "$B2_APPLICATION_KEY" ] || [ -z "$B2_BUCKET_NAME" ]; then
    echo "ERROR: Backblaze credentials not configured in /etc/backblaze-backup/backup.conf"
    exit 1
fi

BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="vps-backup-$BACKUP_DATE"
LOG_FILE="/var/log/backblaze-backup-$BACKUP_DATE.log"

{
    echo "Starting backup: $BACKUP_NAME"
    echo "Time: $(date)"
    echo ""

    # Authenticate with B2
    echo "Authenticating with B2..."
    b2 authorize-account "$B2_ACCOUNT_ID" "$B2_APPLICATION_KEY"

    # Create tar archive
    echo "Creating archive..."
    if [ "$COMPRESS_BACKUP" = "true" ]; then
        tar --exclude='*.tmp' --exclude='*cache*' -czf "/tmp/$BACKUP_NAME.tar.gz" $BACKUP_DIRS
        BACKUP_FILE="/tmp/$BACKUP_NAME.tar.gz"
    else
        tar --exclude='*.tmp' --exclude='*cache*' -cf "/tmp/$BACKUP_NAME.tar" $BACKUP_DIRS
        BACKUP_FILE="/tmp/$BACKUP_NAME.tar"
    fi

    ARCHIVE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Archive created: $ARCHIVE_SIZE"
    echo ""

    # Upload to B2
    echo "Uploading to B2 bucket: $B2_BUCKET_NAME..."
    b2 file-info "$B2_BUCKET_NAME/$BACKUP_NAME.tar.gz" > /dev/null 2>&1 && \
        echo "File already exists in B2" || \
        b2 upload-file "$B2_BUCKET_NAME" "$BACKUP_FILE" "$BACKUP_NAME.tar.gz"

    echo "✅ Backup completed successfully"
    echo ""

    # Cleanup old local archive
    rm -f "$BACKUP_FILE"

    # List recent backups in B2
    echo "Recent backups in B2:"
    b2 list-file-names "$B2_BUCKET_NAME" | head -10

    # Cleanup old backups (older than retention days)
    echo ""
    echo "Cleaning up old backups (older than $RETENTION_DAYS days)..."
    b2 list-file-names "$B2_BUCKET_NAME" | while read -r file; do
        FILE_DATE=$(echo "$file" | grep -oP '\d{4}-\d{2}-\d{2}' | head -1)
        if [ -n "$FILE_DATE" ]; then
            FILE_EPOCH=$(date -d "$FILE_DATE" +%s 2>/dev/null || echo 0)
            CURRENT_EPOCH=$(date +%s)
            DAYS_OLD=$(( (CURRENT_EPOCH - FILE_EPOCH) / 86400 ))

            if [ "$DAYS_OLD" -gt "$RETENTION_DAYS" ]; then
                echo "Deleting old backup: $file (${DAYS_OLD} days old)"
                b2 delete-file-version "$B2_BUCKET_NAME" "$file" || true
            fi
        fi
    done

    echo ""
    echo "Backup completed: $BACKUP_DATE"

} | tee -a "$LOG_FILE"

# Send notification if email configured
if [ -n "$BACKUP_EMAIL" ]; then
    tail -20 "$LOG_FILE" | mail -s "Backblaze Backup Report: $BACKUP_NAME" "$BACKUP_EMAIL" 2>/dev/null || true
fi
BACKUP_EOF

chmod +x /var/podman/backups/daily-backup.sh
mkdir -p /var/podman/backups
echo "✅ Backup script created at /var/podman/backups/daily-backup.sh"
echo ""

# ============================================================================
# 4. CREATE SYSTEMD SERVICE & TIMER
# ============================================================================
echo "Step 4: Creating systemd service and timer..."

cat > /etc/systemd/system/backblaze-backup.service << EOF
[Unit]
Description=Backblaze B2 Daily Backup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/var/podman/backups/daily-backup.sh
StandardOutput=journal
StandardError=journal
TimeoutStartSec=3600

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/backblaze-backup.timer << EOF
[Unit]
Description=Daily Backblaze B2 Backup Timer
Requires=backblaze-backup.service

[Timer]
OnCalendar=daily
OnBootSec=15min
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable backblaze-backup.timer
echo "✅ Systemd timer configured"
echo ""

# ============================================================================
# 5. FINAL INSTRUCTIONS
# ============================================================================
echo "╔════════════════════════════════════════════════════╗"
echo "║          ✅ SETUP COMPLETE - ACTION REQUIRED      ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "To complete the setup:"
echo ""
echo "1. Get Backblaze B2 credentials:"
echo "   - Create a B2 account at https://www.backblaze.com/b2/cloud-storage/"
echo "   - Create a bucket for backups"
echo "   - Generate application key with bucket access"
echo ""
echo "2. Configure credentials:"
echo "   sudo nano /etc/backblaze-backup/backup.conf"
echo "   Fill in:"
echo "     B2_ACCOUNT_ID="
echo "     B2_APPLICATION_KEY="
echo "     B2_BUCKET_NAME="
echo ""
echo "3. Test the backup (manual run):"
echo "   sudo /var/podman/backups/daily-backup.sh"
echo ""
echo "4. Start daily timer:"
echo "   sudo systemctl start backblaze-backup.timer"
echo ""
echo "5. Verify timer status:"
echo "   sudo systemctl list-timers backblaze-backup.timer"
echo ""
echo "6. View backup logs:"
echo "   sudo journalctl -u backblaze-backup.service -f"
echo ""
