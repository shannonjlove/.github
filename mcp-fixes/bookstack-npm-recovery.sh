#!/bin/bash
#
# BookStack + Nginx Proxy Manager Recovery Script
# Restores public accessibility by recovering/rebuilding NPM configuration
#

set -e

VPS_IP="${1:-100.115.66.75}"
NPM_BACKUP="${2:-/opt/sjl/npm-backup}"

echo "🚀 BookStack + Nginx Proxy Manager Recovery"
echo "==========================================="
echo "VPS IP: $VPS_IP"
echo "NPM Backup: $NPM_BACKUP"
echo ""

# Diagnose current state
echo "🔍 Diagnosing current state..."
ssh root@$VPS_IP << 'DIAG_EOF'
  set -e

  echo "📋 Service Status:"
  systemctl status nginx-proxy-manager.service 2>/dev/null || echo "  NPM service: NOT FOUND"
  systemctl status bookstack.service 2>/dev/null || echo "  BookStack service: NOT FOUND"

  echo ""
  echo "📂 Directory Status:"
  ls -lh /opt/sjl/npm/ 2>/dev/null || echo "  /opt/sjl/npm/: NOT FOUND"
  ls -lh /opt/sjl/bookstack/ 2>/dev/null || echo "  /opt/sjl/bookstack/: NOT FOUND"

  echo ""
  echo "🔐 Port Status:"
  echo -n "  Port 80 (HTTP): "
  ss -tlnp 2>/dev/null | grep :80 || echo "NOT LISTENING"
  echo -n "  Port 443 (HTTPS): "
  ss -tlnp 2>/dev/null | grep :443 || echo "NOT LISTENING"
  echo -n "  Port 81 (NPM admin): "
  ss -tlnp 2>/dev/null | grep :81 || echo "NOT LISTENING"

  echo ""
  echo "🐳 Container Status:"
  podman ps -a 2>/dev/null | grep -E "npm|bookstack" || echo "  No containers found"
DIAG_EOF

echo ""
echo "✅ Diagnosis complete. Proceeding with recovery..."
echo ""

# Stop services
echo "🛑 Stopping services..."
ssh root@$VPS_IP << 'STOP_EOF'
  systemctl stop nginx-proxy-manager.service 2>/dev/null || true
  systemctl stop bookstack.service 2>/dev/null || true
  podman stop npm 2>/dev/null || true
  podman stop bookstack 2>/dev/null || true
  sleep 2
STOP_EOF

# Restore or recreate NPM
echo "📦 Restoring Nginx Proxy Manager..."
ssh root@$VPS_IP << 'RESTORE_EOF'
  set -e

  # Check if backup exists
  if [ -d /opt/sjl/npm-backup ] && [ "$(ls -A /opt/sjl/npm-backup)" ]; then
    echo "  ✅ Found NPM backup, restoring..."
    rm -rf /opt/sjl/npm
    cp -r /opt/sjl/npm-backup /opt/sjl/npm
    chown -R root:root /opt/sjl/npm
    chmod -R 755 /opt/sjl/npm
  else
    echo "  ⚠️  No backup found, creating fresh NPM setup..."
    mkdir -p /opt/sjl/npm/data /opt/sjl/npm/letsencrypt /opt/sjl/npm/config
    cat > /opt/sjl/npm/docker-compose.yml << 'NPM_COMPOSE'
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
NPM_COMPOSE

    echo "  Created docker-compose.yml"
  fi

  echo "✅ NPM setup ready"
RESTORE_EOF

# Start services
echo "🚀 Starting Nginx Proxy Manager..."
ssh root@$VPS_IP << 'START_EOF'
  cd /opt/sjl/npm
  docker-compose up -d
  sleep 5

  echo "✅ NPM started"

  # Verify
  echo ""
  echo "📊 Post-recovery status:"
  docker-compose ps
START_EOF

# Configure BookStack proxy (if needed)
echo ""
echo "⚙️  Configuring BookStack proxy..."
ssh root@$VPS_IP << 'PROXY_EOF'
  set -e

  # Check if BookStack container exists
  if podman ps -a | grep -q bookstack; then
    BOOKSTACK_IP=$(podman inspect bookstack -f '{{.NetworkSettings.IPAddress}}' 2>/dev/null || echo "172.17.0.2")
  else
    BOOKSTACK_IP="127.0.0.1:8080"
  fi

  echo "  BookStack endpoint: $BOOKSTACK_IP"
  echo "  NPM admin: http://localhost:81"
  echo ""
  echo "  ⚠️  Manual step required:"
  echo "    1. Access NPM admin at: http://100.115.66.75:81"
  echo "    2. Add proxy host for bookstack.shannonjlove.cloud"
  echo "    3. Forward to: $BOOKSTACK_IP:80"
  echo "    4. Enable SSL with Let's Encrypt"
PROXY_EOF

# Verify ports
echo ""
echo "🔍 Verifying ports..."
ssh root@$VPS_IP << 'VERIFY_EOF'
  sleep 3
  echo "  Port 80: $(ss -tlnp 2>/dev/null | grep :80 | wc -l) listener(s)"
  echo "  Port 443: $(ss -tlnp 2>/dev/null | grep :443 | wc -l) listener(s)"
  echo "  Port 81: $(ss -tlnp 2>/dev/null | grep :81 | wc -l) listener(s)"
VERIFY_EOF

echo ""
echo "✅ Recovery Complete!"
echo ""
echo "📚 Next Steps:"
echo "  1. Access NPM admin: http://100.115.66.75:81"
echo "  2. Configure proxy for bookstack.shannonjlove.cloud"
echo "  3. Test access: curl -I https://bookstack.shannonjlove.cloud"
echo ""
