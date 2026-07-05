# Podman Quadlets Infrastructure

This directory contains standardized Podman quadlet files for all containerized services running on shannonjlove.cloud infrastructure.

## Standard Schema

All quadlets follow this consistent structure:

```ini
[Unit]
Description=<Service Description>
Documentation=<URL>
After=network-online.target
Wants=network-online.target

[Container]
Image=<image:tag>
ContainerName=<name>
PublishPort=<ports if external>
Networks=<network list>
Volume=<mount points>
EnvironmentFile=<path to env file>
Environment=<inline env vars>
HealthCheck=<health check command>
AutoUpdate=registry

[Service]
Type=simple
Restart=always
RestartSec=10
TimeoutStartSec=120
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
```

## Services

### Frontend
- **nginx-proxy-manager.container** - Reverse proxy, SSL/TLS, load balancing
  - Ports: 80 (HTTP), 443 (HTTPS), 81 (Admin panel)
  - Networks: frontend-net, app-net

### Application Layer
- **sjl-mcp-quadlet.container** - VPS filesystem & infrastructure management MCP server
  - Port: 8811 (HTTP, localhost only)
  - Networks: app-net, infra-net
  
- **memory-agent.container** - Long-term memory & context management
  - Port: 8812 (HTTP, localhost only)
  - Networks: app-net

### Storage & Synchronization
- **rclone-mcp.container** - Cloud storage integration (MCP server)
  - Port: 5572 (localhost only)
  - Networks: app-net, infra-net
  
- **rclone-rc.container** - File synchronization & remote control
  - Port: 5571 (localhost only)
  - Networks: infra-net

### Infrastructure
- **pibn.container** - Monitoring & observability
  - Port: 9090 (localhost only)
  - Networks: infra-net

## Network Architecture

```
frontend-net (isolated)
  └─ nginx-proxy-manager (public-facing)

app-net (isolated)
  ├─ nginx-proxy-manager
  ├─ sjl-mcp-quadlet
  ├─ memory-agent
  └─ rclone-mcp

infra-net (isolated)
  ├─ sjl-mcp-quadlet
  ├─ rclone-mcp
  ├─ rclone-rc
  └─ pibn
```

## Deployment

### 1. Create Networks
```bash
sudo podman network create --opt isolate=1 frontend-net
sudo podman network create --opt isolate=1 app-net
sudo podman network create --opt isolate=1 infra-net
```

### 2. Create Data Directories
```bash
mkdir -p /var/podman/{nginx-proxy-manager,sjl-mcp,memory-agent,rclone-mcp,rclone-rc,pibn}/{config,data,logs}
```

### 3. Create Secrets
```bash
mkdir -p /etc/podman/secrets
chmod 700 /etc/podman/secrets
# Copy environment files (templates in ./secrets/ directory)
```

### 4. Deploy Quadlets
```bash
sudo cp *.container /etc/containers/systemd/
sudo systemctl daemon-reload
sudo systemctl enable --now nginx-proxy-manager.service
sudo systemctl enable --now sjl-mcp-quadlet.service
sudo systemctl enable --now memory-agent.service
sudo systemctl enable --now rclone-mcp.service
sudo systemctl enable --now rclone-rc.service
sudo systemctl enable --now pibn.service
```

### 5. Verify
```bash
sudo systemctl status nginx-proxy-manager.service
sudo systemctl status sjl-mcp-quadlet.service
sudo systemctl status memory-agent.service
sudo systemctl status rclone-mcp.service
sudo systemctl status rclone-rc.service
sudo systemctl status pibn.service
```

## Environment Files

Each service requires an environment file at `/etc/podman/secrets/<service-name>.env`

- Permissions: `chmod 600` (root readable only)
- Never commit to git
- Create from templates in `./secrets/` directory

### Example: sjl-mcp.env
```env
MCP_HOST=0.0.0.0
MCP_PORT=8811
OCI_CONFIG_PROFILE=default
LOG_LEVEL=info
TZ=UTC
```

## Health Checks

All services include health checks:

- **HTTP services**: `curl -f http://localhost:PORT/ || exit 1`
- **Interval**: 30s (Podman default)
- **Timeout**: 3s
- **Retries**: 3

View service health:
```bash
sudo systemctl is-active nginx-proxy-manager.service
podman inspect --format='{{.State.Health.Status}}' nginx-proxy-manager
```

## Auto-Updates

All services have `AutoUpdate=registry` enabled. Update images:

```bash
sudo podman auto-update
sudo systemctl restart nginx-proxy-manager.service
```

## Logs

View service logs:

```bash
sudo journalctl -u sjl-mcp-quadlet.service -f
sudo journalctl -u memory-agent.service -f
podman logs -f sjl-mcp-quadlet
```

## Security

✅ **Best Practices Implemented:**
- Secrets stored in `/etc/podman/secrets/` (not in git)
- Network isolation (frontend, app, infra networks)
- Health checks for all services
- Automatic restarts
- Read-only root filesystem ready (add `ReadOnlyRootFilesystem=true` if compatible)
- Non-root user support (where applicable)

⚠️ **Manual Configuration Needed:**
- API keys and credentials in .env files
- Database passwords
- OAuth tokens
- Service-specific secrets

## Rollback

Backup before changes:
```bash
sudo cp -r /etc/containers/systemd /etc/containers/systemd.backup
sudo cp -r /etc/podman/secrets /etc/podman/secrets.backup
```

Restore if needed:
```bash
sudo systemctl stop '*.service'
sudo rm /etc/containers/systemd/*.container
sudo cp -r /etc/containers/systemd.backup/* /etc/containers/systemd/
sudo systemctl daemon-reload
sudo systemctl start '*.service'
```

## Resources

- [Podman Quadlets](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Systemd Unit Files](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)
- [Container Documentation](https://docs.podman.io/)
- [SJL MCP Server](https://memory.shannonjlove.cloud/sjl-mcp/)

---

**Last Updated**: 2026-07-05  
**Maintained By**: Shannon Love <sjlove@shannonjeffreylove.com>
