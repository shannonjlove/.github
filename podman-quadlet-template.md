# Podman Quadlet Template - Canonical Reference

**Document Version:** 2.0 – Production-Ready  
**Last Updated:** 2026-07-04  
**Purpose:** Canonical template for system-wide Podman Quadlet container management

---

## Overview

Goal: Transition from potentially exposed container landscapes to hardened, multi-network designs where only Nginx Proxy Manager (NPM) publishes ports 80, 443, and 81 to the host. Web applications are reachable only through NPM; databases and caches reside on internal networks with no external routes.

Audience: System administrators or DevOps engineers managing a Podman-based host.

---

## Target Architecture

Four dedicated Podman bridge networks serve specific trust zones:

| Network Name | Purpose | Isolation Level |
|---|---|---|
| `frontend-net` | Public ingress; NPM only | Isolated from host (`--opt isolate=1`) |
| `app-net` | Backend web apps (proxied by NPM) | Default bridge (outbound Internet) |
| `db-net` | Databases, message brokers | Internal (`--internal`) + isolated |
| `infra-net` | Admin/MCP/internal tooling | Isolated from host (`--opt isolate=1`) |

**Rationale:**
- `frontend-net` isolates NPM from the host while allowing Internet access via `app-net`
- `db-net` uses `--internal` to prevent external access; databases reachable only by containers on both `app-net` and `db-net`
- `infra-net` houses administrative services not exposed publicly; accessible via localhost proxy or VPN

---

## Network Creation

```bash
podman network create --opt isolate=1 frontend-net
podman network create --opt isolate=1 app-net
podman network create --opt isolate=1 --internal db-net
podman network create --opt isolate=1 infra-net
```

**Tip:** Use `podman network exists` in scripts to avoid re-run errors.

---

## Quadlet Configuration Templates

All Quadlets reside in `/etc/containers/systemd/` and are managed by systemd.

### Template: Public Ingress Service (Nginx Proxy Manager)

```ini
[Unit]
Description=Nginx Proxy Manager
Documentation=https://nginxproxymanager.com/setup
After=network-online.target
Wants=network-online.target

[Container]
Image=docker.io/jc21/nginx-proxy-manager:latest
ContainerName=nginx-proxy-manager
PublishPort=80:80
PublishPort=443:443
PublishPort=81:81
Volume=/var/podman/nginx-proxy-manager/data:/data
Volume=/var/podman/nginx-proxy-manager/letsencrypt:/etc/letsencrypt
Networks=frontend-net,app-net
AutoUpdate=registry
HealthCheck=curl -f http://localhost/ || exit 1
Environment=TZ=UTC

[Service]
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Security Notes:**
- Port 81 (admin UI) should be firewalled to trusted IPs only
- Consider binding with `PublishPort=127.0.0.1:81:81` and reverse-proxy through NPM or SSH tunnel

### Template: Database Service

```ini
[Unit]
Description={SERVICE_NAME} MariaDB
After=network-online.target

[Container]
Image=docker.io/library/mariadb:10.11
ContainerName={SERVICE_NAME}-db
Network=db-net
EnvironmentFile=/etc/podman/secrets/{SERVICE_NAME}-db.env
Volume=/var/podman/{SERVICE_NAME}/db:/var/lib/mysql
HealthCheck=mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD

[Service]
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Environment File Template:** `/etc/podman/secrets/{SERVICE_NAME}-db.env`

```
MYSQL_ROOT_PASSWORD=CHANGE_ME_ROOT
MYSQL_DATABASE={SERVICE_NAME}
MYSQL_USER={SERVICE_NAME}
MYSQL_PASSWORD=CHANGE_ME_APP
```

Set permissions: `chmod 600` and owned by root.

### Template: Application Service

```ini
[Unit]
Description={SERVICE_NAME} Application
After=network-online.target {SERVICE_NAME}-db.service
Wants={SERVICE_NAME}-db.service

[Container]
Image={REGISTRY}/{SERVICE_NAME}:latest
ContainerName={SERVICE_NAME}
Networks=app-net,db-net
EnvironmentFile=/etc/podman/secrets/{SERVICE_NAME}.env
Volume=/var/podman/{SERVICE_NAME}/config:/config
HealthCheck=curl -f http://localhost || exit 1

[Service]
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Environment File Template:** `/etc/podman/secrets/{SERVICE_NAME}.env`

```
APP_URL=https://{SERVICE_DOMAIN}
DB_HOST={SERVICE_NAME}-db
DB_DATABASE={SERVICE_NAME}
DB_USERNAME={SERVICE_NAME}
DB_PASSWORD=CHANGE_ME_APP
```

**Important:** App containers use database container names as hostnames because they're on the same network; Podman's internal DNS resolves them.

### Template: Internal Tool Service (infra-net)

```ini
[Unit]
Description={TOOL_NAME}
After=network-online.target

[Container]
Image={REGISTRY}/{TOOL_NAME}:latest
ContainerName={TOOL_NAME}
Network=infra-net
EnvironmentFile=/etc/podman/secrets/{TOOL_NAME}.env
Volume=/var/podman/{TOOL_NAME}/config:/config

[Service]
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

## Secure Secret Management

- **Never** embed secrets in Quadlet files or scripts
- Use `EnvironmentFile` pointing to files outside the service directory
- Set strict permissions: `chmod 600` on all secret files, owned by root
- For additional security, consider Podman Secrets (rootful) or systemd credentials

---

## Migration Workflow

### Pre-Migration
1. Back up current container data (volumes)
2. Verify NPM health and export configurations
3. Create networks (see Network Creation section)
4. Prepare volume directories with correct ownership

### Deployment Order
1. **Database Layer**: Deploy all `*-db.service` units
   ```bash
   systemctl daemon-reload
   systemctl start {service}-db.service
   systemctl status {service}-db.service
   ```

2. **Application Layer**: Deploy app services after DBs are healthy
   ```bash
   systemctl start {service}.service
   systemctl status {service}.service
   ```

3. **Proxy Configuration**: Log into NPM admin UI (port 81)
   - Add proxy hosts pointing to container names
   - Example: `docs.shannonjlove.cloud` → `http://bookstack:80`

4. **Verification**: Confirm connectivity across networks

### Post-Migration Hardening
- Firewall port 81 to trusted IPs
- Remove all host port bindings except NPM
- Verify no PublishPort directives on non-NPM containers
- Test inter-network connectivity

---

## Verification Commands

```bash
# List networks and inspect membership
podman network ls
podman network inspect frontend-net app-net db-net infra-net

# Show container network assignments
podman ps --format "{{.Names}} {{.Networks}}"

# Verify service health
systemctl status {service}-db {service} --no-pager

# Check recent logs
journalctl -u {service} -n 50 --no-pager

# Test DNS resolution from app container
podman exec {service} ping {service}-db
```

---

## Troubleshooting

| Symptom | Likely Cause | Solution |
|---|---|---|
| App cannot reach DB | DB not on correct network | Ensure both containers on `db-net`; use container name as `DB_HOST` |
| NPM cannot proxy to app | App missing `app-net` attachment | Verify app is on `app-net`; use port 80 in NPM backend |
| No external access from app | Missing outbound NAT | `app-net` should not be `--internal` |
| Admin UI (81) exposed | Missing firewall rule | Block port 81 except for trusted IPs |
| Health checks failing | Container startup issues | Check logs: `journalctl -u {service} --no-pager` |

---

## Rollback Procedure

If issues arise:
1. Stop affected Quadlet services
2. Restore from volume backups if needed
3. Networks can remain for later use
4. Revert to previous container configurations

---

## Template Variables Reference

Replace these variables when creating service-specific Quadlet files:

- `{SERVICE_NAME}`: Lowercase service identifier (e.g., `bookstack`, `paperless`)
- `{REGISTRY}`: Container registry (e.g., `docker.io`, `lscr.io`)
- `{SERVICE_DOMAIN}`: Full domain name for web access
- `{TOOL_NAME}`: Internal tool name (e.g., `portainer`, `mcp-gateway`)

---

## Security Checklist

- [ ] All secret files have `chmod 600` permissions
- [ ] Secret files owned by `root` user
- [ ] No plaintext passwords in Quadlet files
- [ ] `db-net` marked as `--internal`
- [ ] Port 81 firewalled to trusted IPs only
- [ ] All container volumes backed up pre-migration
- [ ] No PublishPort directives on non-NPM services
- [ ] Health checks defined for all services
- [ ] Network isolation verified with `podman network inspect`

---

## Quick Reference: Service Templates by Type

### Web Application Stack
- **DB Service**: `db-net` only
- **App Service**: `app-net` + `db-net`
- **NPM Proxy**: Points app container by name to `app-net`

### Internal Admin Tools
- **Infra Services**: `infra-net` only
- **Access**: Via localhost proxy or VPN
- **Exposure**: Never published to host

### Stateless Services
- **Cache/Message Broker**: `db-net`
- **Accessed by**: Services also on `db-net`

---

## Related Resources

- [Podman Networking Documentation](https://docs.podman.io/en/latest/markdown/podman-network.1.html)
- [Quadlets Documentation](https://podman.io/blogs/2023/12/19/quadlet-intro.html)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)

---

**Note:** Keep this template synchronized across all infrastructure documentation systems. Update version number on substantive changes.
