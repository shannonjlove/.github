# Podman Quadlets Migration Checklist

## Summary
✅ **Phase 1 Complete**: Service discovery & standardization  
✅ **Phase 2 Complete**: Conversion of all Docker Compose services to quadlets  
🔄 **Phase 3 Ready**: Deployment & verification

---

## Services Converted (12 Total)

### ✅ Already Standardized (3)
- [x] nginx-proxy-manager.container - Reverse proxy
- [x] sjl-mcp-quadlet.container - Filesystem & infrastructure MCP
- [x] memory-agent.container - Long-term memory management

### ✅ Docker Compose → Quadlet (9)
- [x] sjl-file-api.container - File upload/management
- [x] mcp-filesystem.container - MCP filesystem service
- [x] basic-memory.container - MCP memory service
- [x] rclone-mcp.container - Cloud storage (MCP)
- [x] rclone-rc.container - File synchronization
- [x] bookstack.container - Knowledge base/documentation
- [x] paperless.container - Document management/OCR
- [x] pibn.container - Infrastructure monitoring
- [x] tailscale.container - VPN connectivity

---

## Pre-Deployment Verification

### 1. Backup Current Configuration
```bash
# Backup Docker Compose files
sudo cp -r /opt /opt.backup-$(date +%Y%m%d)

# Backup current systemd state
systemctl list-units --type=service > ~/services.backup.txt

# Backup existing quadlets (if any)
sudo cp -r /etc/containers/systemd /etc/containers/systemd.backup-$(date +%Y%m%d)
```

### 2. Verify Quadlet Files
```bash
# Check all quadlets are present and valid syntax
for f in /home/user/.github/podman-quadlets/*.container; do
  echo "Checking $(basename $f)..."
  podman inspect $(basename $f .container) 2>/dev/null || echo "  (not yet deployed)"
done
```

---

## Deployment Steps

### Phase 1: Infrastructure Setup

#### Step 1a: Create Networks
```bash
sudo podman network create --opt isolate=1 frontend-net || true
sudo podman network create --opt isolate=1 app-net || true
sudo podman network create --opt isolate=1 infra-net || true

# Verify networks
sudo podman network ls
```

#### Step 1b: Create Directory Structure
```bash
# Data directories for all services
for service in nginx-proxy-manager sjl-mcp memory-agent sjl-file-api \
               mcp-filesystem basic-memory rclone-mcp rclone-rc \
               bookstack paperless pibn tailscale; do
  sudo mkdir -p /var/podman/$service/{config,data,logs}
  sudo chown root:root /var/podman/$service
  sudo chmod 755 /var/podman/$service
done

# Secrets directory
sudo mkdir -p /etc/podman/secrets
sudo chmod 700 /etc/podman/secrets
```

#### Step 1c: Create Secrets from Existing Configs
For each service, extract credentials from existing Docker Compose files:

```bash
# Example: Extract from existing Docker Compose
sudo bash -c 'cat /opt/sjl-mcp/docker-compose.yml | grep -A 50 "environment:" | \
  grep -E "^\s+[A-Z_]+=" | sed "s/^\s*//" | sed "s/'//g" \
  > /etc/podman/secrets/sjl-mcp.env'

# Set proper permissions
sudo chmod 600 /etc/podman/secrets/*.env
```

**Required Secrets** (create these before deploying):
- [ ] `/etc/podman/secrets/nginx-proxy-manager.env`
- [ ] `/etc/podman/secrets/sjl-mcp.env`
- [ ] `/etc/podman/secrets/memory-agent.env`
- [ ] `/etc/podman/secrets/sjl-file-api.env`
- [ ] `/etc/podman/secrets/mcp-filesystem.env`
- [ ] `/etc/podman/secrets/basic-memory.env`
- [ ] `/etc/podman/secrets/rclone-mcp.env`
- [ ] `/etc/podman/secrets/rclone-rc.env`
- [ ] `/etc/podman/secrets/bookstack.env`
- [ ] `/etc/podman/secrets/paperless.env`
- [ ] `/etc/podman/secrets/pibn.env`
- [ ] `/etc/podman/secrets/tailscale.env`

---

### Phase 2: Deploy Quadlets

#### Step 2a: Copy Quadlet Files
```bash
# Copy all standardized quadlets to systemd
sudo cp /home/user/.github/podman-quadlets/*.container /etc/containers/systemd/

# Verify copies
ls -la /etc/containers/systemd/*.container | wc -l
```

#### Step 2b: Reload Systemd
```bash
sudo systemctl daemon-reload

# Verify systemd sees all units
systemctl list-unit-files | grep -E "\.service" | wc -l
```

---

### Phase 3: Start Services (Careful Startup Order)

#### Step 3a: Start Infrastructure Services
```bash
# Start networking-dependent services first
sudo systemctl enable --now nginx-proxy-manager.service
sleep 5  # Give nginx time to start

# Status check
sudo systemctl status nginx-proxy-manager.service
```

#### Step 3b: Start Core MCP & Infrastructure
```bash
# Start in dependency order
sudo systemctl enable --now tailscale.service
sleep 3
sudo systemctl enable --now pibn.service
sleep 3
sudo systemctl enable --now rclone-rc.service
sudo systemctl enable --now rclone-mcp.service
sleep 5
```

#### Step 3c: Start Application Services
```bash
# Start app tier services
for service in sjl-mcp-quadlet sjl-file-api mcp-filesystem basic-memory \
               memory-agent bookstack paperless; do
  sudo systemctl enable --now $service.service
  sleep 2
  sudo systemctl status $service.service --no-pager | tail -2
done
```

---

## Verification & Testing

### Service Status
```bash
# Check all services
sudo systemctl list-units --type=service --state=running | grep -E "\.(service|container)"

# Check specific service
sudo systemctl status sjl-mcp-quadlet.service
```

### Health Checks
```bash
# View container health status
podman ps --format "table {{.Names}}\t{{.Status}}"

# Check specific container health
podman inspect --format='{{.State.Health.Status}}' sjl-mcp

# View detailed health
podman healthcheck run sjl-mcp
```

### Logs
```bash
# Systemd journal
sudo journalctl -u sjl-mcp-quadlet.service -f
sudo journalctl -u nginx-proxy-manager.service -f

# Container logs
podman logs -f sjl-mcp
podman logs -f nginx-proxy-manager --tail 50
```

### Network Connectivity
```bash
# Verify networks are isolated
sudo podman network inspect app-net | grep -A 50 "Containers"

# Test inter-container connectivity (if needed)
podman exec sjl-mcp curl -s http://memory-agent:8812/health || echo "Connection failed"
```

### API Tests
```bash
# Test MCP filesystem on port 8811
curl -s http://127.0.0.1:8811/health | jq .

# Test nginx reverse proxy
curl -s http://localhost:81 | head -20

# Test file API
curl -s http://127.0.0.1:3000/health
```

---

## Rollback Procedure

If anything goes wrong:

```bash
# Stop all services
sudo systemctl stop '*.service' 2>/dev/null || true

# Remove current quadlets
sudo rm /etc/containers/systemd/*.container

# Restore from backup
sudo cp -r /etc/containers/systemd.backup-*/* /etc/containers/systemd/

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart '*.service'

# Verify restoration
systemctl status nginx-proxy-manager.service
```

---

## Post-Deployment Cleanup

Once all services are verified as working:

```bash
# Disable old Docker Compose services (if any were systemd-managed)
sudo systemctl disable docker-compose.service 2>/dev/null || true

# Archive Docker Compose files (keep as reference)
sudo mkdir -p /opt/.archive
sudo mv /opt/*/docker-compose.yml /opt/.archive/ 2>/dev/null || true

# Clean up old containers
sudo podman container prune -f
sudo podman image prune -f

# Verify no stray containers remain
podman ps -a
```

---

## Troubleshooting

### Container Won't Start
```bash
# Check logs
podman logs <container-name>

# Check systemd journal
journalctl -u <service-name>.service -n 50

# Check resource constraints
free -h
df -h
```

### Network Connectivity Issues
```bash
# Check network exists
podman network ls

# Verify container is on correct network
podman inspect <container> | grep NetworkSettings -A 30

# Test DNS resolution
podman exec <container> getent hosts <hostname>
```

### Health Check Failures
```bash
# Run health check manually
podman healthcheck run <container>

# Check health check command in quadlet
grep HealthCheck /etc/containers/systemd/<service>.container

# Test health check command directly
podman exec <container> curl -f http://localhost:PORT/ || echo "Failed"
```

### File Permission Issues
```bash
# Check volume mount permissions
ls -la /var/podman/<service>/

# Check secrets permissions
ls -la /etc/podman/secrets/

# Fix if needed
sudo chown 1000:1000 /var/podman/<service>/  # For non-root containers
sudo chmod 755 /var/podman/<service>/
```

---

## Maintenance After Migration

### Regular Tasks
- Weekly: Check logs for errors (`journalctl -u *.service --since "1 week ago"`)
- Monthly: Run `podman auto-update` to refresh images
- Quarterly: Review network isolation and add/remove routes as needed
- Yearly: Update documentation with any configuration changes

### Monitoring
```bash
# Set up log monitoring
journalctl -u '*.service' -f | grep -i error

# Monitor resource usage
watch -n 5 'podman stats --no-stream'

# Check for stale processes
ps aux | grep -E "docker|podman|container" | grep -v grep
```

### Automatic Updates
All quadlets have `AutoUpdate=registry` enabled:
```bash
# Check available updates
podman auto-update --dry-run

# Apply updates
sudo podman auto-update

# Restart affected services
sudo systemctl restart '*.service'
```

---

## Documentation & Reference

- Quadlets: `/home/user/.github/podman-quadlets/`
- Systemd Units: `/etc/containers/systemd/`
- Configuration: `/etc/podman/secrets/`
- Data: `/var/podman/`
- Logs: `journalctl -u <service>.service`

---

## Sign-Off

- [ ] All quadlets created and committed to repo
- [ ] Networks created and verified isolated
- [ ] Data directories created with proper permissions
- [ ] Secrets created from existing configurations
- [ ] All services started and health checks passing
- [ ] Inter-service connectivity verified
- [ ] API endpoints responding correctly
- [ ] Old Docker Compose files archived
- [ ] Monitoring and logging confirmed
- [ ] Team trained on new systemd-based management

**Deployed by**: (fill in name)  
**Date**: (fill in date)  
**Status**: ⏳ Ready for deployment
