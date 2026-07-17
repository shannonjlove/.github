# BookStack + Nginx Proxy Manager Recovery Guide

**Status**: 🔴 CRITICAL - Public Access Down  
**Root Cause**: Nginx Proxy Manager crashed after configuration loss  
**Target**: VPS @ 100.115.66.75  
**Impact**: bookstack.shannonjlove.cloud unreachable  

---

## 🚨 Current Issue

BookStack is **not publicly accessible** despite DNS resolving correctly:

```
DNS Resolution: ✅ 72.61.74.250
Port 80 (HTTP): ❌ Timeout (firewall drop)
Port 443 (HTTPS): ❌ Connection Refused (no service listening)
Port 81 (NPM Admin): ❌ Unknown
```

**Root Cause**: Nginx Proxy Manager crashed when configuration switched from `/opt/sjl/npm/` (with persistent data/certs) to empty Podman volumes, losing all proxy configurations.

---

## 🔧 Quick Fix (5-10 minutes)

### Option 1: Automated Recovery Script

```bash
cd mcp-fixes
chmod +x bookstack-npm-recovery.sh
./bookstack-npm-recovery.sh
```

The script will:
1. Diagnose current state
2. Restore NPM from backup OR create fresh setup
3. Start all services
4. Report BookStack endpoint
5. Guide manual proxy configuration

### Option 2: Manual Recovery

**Step 1: Check Current State**
```bash
ssh root@100.115.66.75 << 'EOF'
  echo "=== Service Status ==="
  systemctl status nginx-proxy-manager.service
  systemctl status bookstack.service

  echo ""
  echo "=== Port Listeners ==="
  ss -tlnp | grep -E ':80|:81|:443'

  echo ""
  echo "=== Container Status ==="
  podman ps -a | grep -E 'npm|bookstack'

  echo ""
  echo "=== Directory Status ==="
  ls -lh /opt/sjl/npm/
  ls -lh /opt/sjl/bookstack/
EOF
```

**Step 2: Stop Services**
```bash
ssh root@100.115.66.75 << 'EOF'
  systemctl stop nginx-proxy-manager.service 2>/dev/null || true
  systemctl stop bookstack.service 2>/dev/null || true
  podman stop npm bookstack 2>/dev/null || true
  sleep 2
EOF
```

**Step 3: Restore NPM from Backup**

If backup exists at `/opt/sjl/npm-backup`:
```bash
ssh root@100.115.66.75 << 'EOF'
  rm -rf /opt/sjl/npm
  cp -r /opt/sjl/npm-backup /opt/sjl/npm
  chown -R root:root /opt/sjl/npm
  chmod -R 755 /opt/sjl/npm
  
  cd /opt/sjl/npm
  docker-compose up -d
EOF
```

Or, create fresh NPM setup:
```bash
ssh root@100.115.66.75 << 'EOF'
  mkdir -p /opt/sjl/npm/{data,letsencrypt,config}
  
  cat > /opt/sjl/npm/docker-compose.yml << 'COMPOSE'
version: '3.9'

services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: npm
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
      - ./config:/config
    environment:
      DB_SQLITE_FILE: "/data/database.sqlite"
    networks:
      - default

networks:
  default:
    driver: bridge
COMPOSE

  cd /opt/sjl/npm
  docker-compose up -d
EOF
```

**Step 4: Verify Services Are Running**
```bash
ssh root@100.115.66.75 << 'EOF'
  # Check NPM is listening
  sleep 5
  ss -tlnp | grep -E ':80|:81|:443'
  
  # Check logs
  cd /opt/sjl/npm
  docker-compose logs npm | tail -20
EOF
```

**Step 5: Configure Proxy**

Access NPM admin panel:
```
http://100.115.66.75:81
```

Default credentials (first time):
- Email: `admin@example.com`
- Password: `changeme`

Then:
1. Click **Proxy Hosts** → **Add Proxy Host**
2. Domain: `bookstack.shannonjlove.cloud`
3. Scheme: `http`
4. Forward Hostname/IP: `172.17.0.2` (or `127.0.0.1:8080` for host network)
5. Forward Port: `80`
6. Block Common Exploits: ✅ Enable
7. SSL: Enable Let's Encrypt (auto-generate)
8. Save

---

## 🔍 Diagnosis Reference

### Check NPM Status
```bash
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose ps'
```

### View NPM Logs
```bash
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose logs -f npm'
```

### Check BookStack Status
```bash
ssh root@100.115.66.75 'podman ps -a | grep bookstack'
```

### Find BookStack IP
```bash
ssh root@100.115.66.75 'podman inspect bookstack -f "{{.NetworkSettings.IPAddress}}"'
```

### Test Local BookStack Access
```bash
ssh root@100.115.66.75 'curl -I http://localhost:8080'
# Should return 200 OK or 302 redirect
```

### Test Public Access
```bash
curl -I https://bookstack.shannonjlove.cloud
# Should return 200 OK after proxy is configured
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: Port 80 Still Timing Out After Recovery

**Cause**: Firewall rule or NPM not actually listening

**Solution**:
```bash
# Verify NPM container is running
ssh root@100.115.66.75 'docker ps | grep npm'

# Check if port 80 is open
ssh root@100.115.66.75 'ss -tlnp | grep :80'

# Force NPM restart
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose restart npm'

# Check logs
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose logs npm | tail -50'
```

### Issue 2: Port 81 Not Accessible

**Cause**: NPM container failed to start or port binding issue

**Solution**:
```bash
# Check container health
ssh root@100.115.66.75 'docker inspect npm | grep -A 5 Health'

# View full logs
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose logs npm'

# Recreate container
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose down && docker-compose up -d'
```

### Issue 3: BookStack Proxy Not Working After Configuration

**Cause**: Wrong BookStack IP or port

**Solution**:
```bash
# Find correct BookStack IP
ssh root@100.115.66.75 'podman inspect bookstack -f "{{.NetworkSettings.IPAddress}}"'

# Test connectivity from NPM container
ssh root@100.115.66.75 'docker exec npm curl -I http://<BOOKSTACK_IP>:80'

# Update proxy host in NPM admin panel with correct IP
```

### Issue 4: SSL Certificate Not Issuing

**Cause**: Let's Encrypt validation failed

**Solution**:
```bash
# Check DNS
nslookup bookstack.shannonjlove.cloud

# Verify DNS points to correct IP
# Should be: 72.61.74.250

# Wait 5 minutes for DNS propagation
# Then retry in NPM admin panel (save proxy host again)

# Check NPM logs for cert errors
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose logs npm | grep -i cert'
```

---

## 🔄 Prevention: Persistent NPM Configuration

To prevent loss of NPM configuration in future:

### 1. Create Backup Directory
```bash
ssh root@100.115.66.75 << 'EOF'
  mkdir -p /opt/sjl/npm-backup
  cp -r /opt/sjl/npm/* /opt/sjl/npm-backup/
  chmod -R 755 /opt/sjl/npm-backup
EOF
```

### 2. Automate Daily Backups
```bash
# Add to crontab on VPS
ssh root@100.115.66.75 'crontab -e'

# Add this line:
# 0 2 * * * cp -r /opt/sjl/npm/* /opt/sjl/npm-backup/ 2>/dev/null

# Or use systemd timer:
ssh root@100.115.66.75 << 'EOF'
  cat > /etc/systemd/system/npm-backup.service << 'SERVICE'
[Unit]
Description=Backup Nginx Proxy Manager Configuration
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'cp -r /opt/sjl/npm/* /opt/sjl/npm-backup/'
User=root

[Install]
WantedBy=multi-user.target
SERVICE

  cat > /etc/systemd/system/npm-backup.timer << 'TIMER'
[Unit]
Description=Run NPM backup daily

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
TIMER

  systemctl daemon-reload
  systemctl enable npm-backup.timer
  systemctl start npm-backup.timer
EOF
```

### 3. Use Persistent Volumes (Recommended)

Update docker-compose.yml to use named volumes:
```yaml
volumes:
  npm-data:
  npm-certs:

services:
  npm:
    volumes:
      - npm-data:/data
      - npm-certs:/etc/letsencrypt
      - ./config:/config
```

This ensures data persists even if container is removed.

---

## ✅ Success Criteria

After recovery:

- [ ] Port 80 is listening and responds to HTTP
- [ ] Port 443 is listening and responds to HTTPS
- [ ] Port 81 is accessible for NPM admin panel
- [ ] `https://bookstack.shannonjlove.cloud` returns 200 OK
- [ ] BookStack login page loads in browser
- [ ] Users can login and access wiki content
- [ ] SSL certificate is valid (not self-signed)

---

## 📋 Recovery Checklist

```
Pre-Recovery:
☐ SSH access to 100.115.66.75 verified
☐ Backup location confirmed (/opt/sjl/npm-backup)
☐ Current state diagnosed

Recovery:
☐ Services stopped
☐ NPM restored or recreated
☐ Services started
☐ Ports verified listening

Post-Recovery:
☐ NPM admin panel accessible (port 81)
☐ Proxy host configured
☐ BookStack endpoint reachable
☐ SSL certificate active
☐ BookStack accessible at bookstack.shannonjlove.cloud
☐ Backups configured to prevent recurrence
```

---

## 🚀 Quick Reference Commands

```bash
# Run automated recovery
./bookstack-npm-recovery.sh

# Manual diagnosis
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose logs -f npm'

# Check all ports
ssh root@100.115.66.75 'ss -tlnp | grep -E ":80|:81|:443"'

# Restart NPM
ssh root@100.115.66.75 'cd /opt/sjl/npm && docker-compose restart npm'

# Verify public access
curl -I https://bookstack.shannonjlove.cloud
```

---

**Status**: 🔴 CRITICAL - Requires Immediate Action  
**ETA**: 5-10 minutes with automated script  
**Risk**: Low (NPM data can be restored from backup)  
**Last Updated**: 2026-07-17
