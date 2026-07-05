# System Backup and Log Management

Complete solution for maintaining system health through automated log pruning and Backblaze B2 backups.

## Overview

This infrastructure provides two complementary systems:

1. **Log Pruning** - Automatically removes logs older than 30 days
2. **Backblaze Backup** - Daily automated backups of critical directories to B2 cloud storage

---

## Part 1: System Log Pruning (30-Day Retention)

### What It Does

- Removes log files older than 30 days from `/var/log`
- Compresses logs aged 7-30 days to save space
- Vacuums systemd journal logs
- Generates daily pruning reports
- Runs automatically via cron every day at 2:00 AM

### Installation

#### 1. Setup Cron Job
```bash
sudo bash /home/user/.github/infrastructure/setup-log-pruning-cron.sh
```

This will:
- Add daily cron job at 2:00 AM
- Create pruning reports in `/var/log/`

#### 2. Manual Test (Optional)
```bash
sudo /home/user/.github/infrastructure/cleanup-scripts/prune-old-logs.sh
```

### Log Location

- Pruning reports: `/var/log/prune-logs-*.report`
- System logs (being pruned): `/var/log/`
- Container logs: `/var/podman/`

### Disk Space Savings

The script will:
- Delete files older than 30 days
- Compress 7-30 day old logs with gzip
- Vacuum journalctl (systemd logs)

Typical savings: 30-50% disk usage reduction in `/var/log`

### Verify Cron Configuration

```bash
# View scheduled cron jobs
crontab -l

# View cron execution logs
sudo tail -f /var/log/syslog | grep CRON

# Check last pruning report
sudo ls -lh /var/log/prune-logs-*.report | head -5
```

---

## Part 2: Backblaze B2 Daily Backups

### What It Does

- Creates daily tar archives of critical directories
- Uploads to Backblaze B2 cloud storage
- Automatically deletes old backups after 90 days
- Provides email notifications (optional)
- Logs all operations to systemd journal

### Directories Backed Up

Default:
- `/var/podman` - All containerized services
- `/home/user/.github/infrastructure` - Infrastructure code
- `/etc/systemd/system` - Systemd service definitions

*(Customizable in configuration)*

### Prerequisites

1. Backblaze B2 Account
   - Sign up at https://www.backblaze.com/b2/cloud-storage/
   - Free tier: 10 GB storage + 1 GB/day download

2. B2 Credentials
   - Account ID
   - Application Key
   - Bucket name (create in B2 console)

### Installation

#### Step 1: Run Setup Script
```bash
sudo bash /home/user/.github/infrastructure/backup-scripts/setup-backblaze-backup.sh
```

This will:
- Install B2 CLI tool
- Create configuration directory
- Create backup script and systemd timer

#### Step 2: Configure Credentials
```bash
sudo nano /etc/backblaze-backup/backup.conf
```

Add your B2 credentials:
```bash
B2_ACCOUNT_ID="your-account-id"
B2_APPLICATION_KEY="your-app-key"
B2_BUCKET_NAME="your-bucket-name"
```

Save with Ctrl+X, Y, Enter

#### Step 3: Test Backup (Manual)
```bash
sudo /var/podman/backups/daily-backup.sh
```

Output should show:
```
Starting backup: vps-backup-2026-01-15_14-30-45
Creating archive...
Archive created: 2.4G
Uploading to B2 bucket: my-backups...
✅ Backup completed successfully
```

#### Step 4: Enable Daily Backups
```bash
sudo systemctl start backblaze-backup.timer
```

Verify it's running:
```bash
sudo systemctl status backblaze-backup.timer
```

### Backup Schedule

- **Time:** Daily at 2:00 AM UTC (configurable)
- **Backup format:** TAR.GZ (compressed)
- **Retention:** 90 days in B2
- **Size estimate:** 2-5 GB per backup (depends on service sizes)

### Monitoring Backups

#### View Timer Status
```bash
sudo systemctl list-timers backblaze-backup.timer
```

#### View Backup Logs
```bash
# Recent backup logs
sudo journalctl -u backblaze-backup.service -n 50

# Follow backup progress (live)
sudo journalctl -u backblaze-backup.service -f

# View logs from specific date
sudo journalctl -u backblaze-backup.service --since "2026-01-15" --until "2026-01-16"
```

#### Check B2 Backups Manually
```bash
# List all backups in B2
b2 authorize-account <ACCOUNT_ID> <APP_KEY>
b2 list-file-names <BUCKET_NAME>

# Check specific backup details
b2 file-info <BUCKET_NAME> vps-backup-2026-01-15_02-00-00.tar.gz
```

### Backup Cost Estimation

Backblaze B2 Pricing (as of 2026):
- **Storage:** $0.006 per GB per month
- **Download:** $0.001 per GB
- **API Calls:** $0.0004 per 1000 calls (includes list/upload)

Example for 3 GB daily backups:
- Monthly storage (keeping 90 days): ~$540 GB-months = $3.24
- Monthly API costs: ~$2-3
- **Total monthly cost:** ~$5-6

### Restore from Backup

#### 1. Download from B2
```bash
b2 authorize-account <ACCOUNT_ID> <APP_KEY>
b2 download-file-by-id <BUCKET_NAME> <FILE_ID> ./backup.tar.gz
```

#### 2. Extract Archive
```bash
tar -xzf backup.tar.gz -C /

# Or restore to specific location
mkdir -p /backup-restore
tar -xzf backup.tar.gz -C /backup-restore
```

#### 3. Verify Restored Files
```bash
ls -lah /backup-restore/var/podman
```

### Troubleshooting

#### "Backblaze credentials not configured"
```bash
# Check configuration
sudo cat /etc/backblaze-backup/backup.conf

# Update if needed
sudo nano /etc/backblaze-backup/backup.conf
```

#### "Authentication failed"
```bash
# Test B2 credentials manually
b2 authorize-account <YOUR_ACCOUNT_ID> <YOUR_APP_KEY>

# If fails, verify:
# - Account ID is correct
# - Application Key is correct (not master key)
# - Key has "listBuckets", "readBucketInfo", "writeFiles" permissions
```

#### Backup too large
```bash
# Modify BACKUP_DIRS in configuration to exclude non-essential directories
sudo nano /etc/backblaze-backup/backup.conf

# Restart timer
sudo systemctl restart backblaze-backup.timer
```

#### Email notifications not working
```bash
# Install mail utility
sudo apt-get install mailutils

# Configure email in backup.conf
BACKUP_EMAIL="your-email@example.com"

# Install sendmail (if needed)
sudo apt-get install sendmail sendmail-bin
```

---

## Combined Setup (Both Systems)

To set up both log pruning AND Backblaze backups in one go:

```bash
# 1. Setup log pruning
sudo bash /home/user/.github/infrastructure/setup-log-pruning-cron.sh

# 2. Setup Backblaze backups
sudo bash /home/user/.github/infrastructure/backup-scripts/setup-backblaze-backup.sh

# 3. Configure Backblaze credentials
sudo nano /etc/backblaze-backup/backup.conf

# 4. Test Backblaze backup manually
sudo /var/podman/backups/daily-backup.sh

# 5. Enable daily backups
sudo systemctl start backblaze-backup.timer

# 6. Verify both systems
crontab -l | grep prune-old-logs
sudo systemctl list-timers backblaze-backup.timer
```

---

## Automation Summary

| System | Schedule | Command | Status | Logs |
|--------|----------|---------|--------|------|
| Log Pruning | Daily 2:00 AM | Via cron | `crontab -l` | `/var/log/prune-logs-*.report` |
| Backblaze Backup | Daily 2:00 AM | Via systemd timer | `systemctl status backblaze-backup.timer` | `journalctl -u backblaze-backup.service` |

Both systems run automatically with no manual intervention required after setup.

---

## Files Reference

```
infrastructure/
├── cleanup-scripts/
│   └── prune-old-logs.sh              # Log pruning script (runs via cron)
├── backup-scripts/
│   └── daily-backup.sh                # Backblaze backup script (runs via systemd)
├── setup-log-pruning-cron.sh          # Cron setup utility
├── setup-backblaze-backup.sh          # Backblaze setup utility
└── BACKUP_AND_LOG_MANAGEMENT.md       # This documentation

Configuration:
├── /etc/backblaze-backup/backup.conf  # B2 credentials and settings
├── /etc/systemd/system/backblaze-backup.service  # Backup systemd service
├── /etc/systemd/system/backblaze-backup.timer    # Daily backup timer

Logs:
├── /var/log/prune-logs-*.report       # Log pruning reports
└── journalctl -u backblaze-backup.service # Backup execution logs
```

---

## Next Steps

1. ✅ Run setup scripts on VPS
2. ✅ Configure Backblaze credentials
3. ✅ Test both systems manually
4. ✅ Monitor first backup completion
5. ✅ Verify log pruning in 3 days
6. ✅ Set up email notifications (optional)
