#!/bin/bash
# Install Remote Command Executor on VPS

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║   Installing Remote Command Executor for Claude    ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

echo "📋 Step 1: Generating API Key"
echo "=============================="
EXECUTOR_KEY=$(openssl rand -hex 32)
echo "✅ Generated: $EXECUTOR_KEY"
echo ""

echo "📋 Step 2: Creating directories"
echo "================================"
mkdir -p /var/podman/remote-executor/logs
chmod 755 /var/podman/remote-executor
chmod 755 /var/podman/remote-executor/logs
echo "✅ Directories created"
echo ""

echo "📋 Step 3: Creating environment file"
echo "===================================="
cat > /etc/podman/secrets/remote-executor.env << EOF
REMOTE_EXECUTOR_KEY=$EXECUTOR_KEY
EOF
chmod 600 /etc/podman/secrets/remote-executor.env
echo "✅ Environment file created"
echo ""

echo "📋 Step 4: Copying executor script"
echo "=================================="
if [ -f "/home/user/.github/infrastructure/remote-executor.py" ]; then
    cp /home/user/.github/infrastructure/remote-executor.py /var/podman/remote-executor/
    chmod 755 /var/podman/remote-executor/remote-executor.py
    echo "✅ Executor script copied"
else
    echo "⚠️  Remote executor script not found at expected location"
    echo "Make sure to copy it manually"
fi
echo ""

echo "📋 Step 5: Installing Podman quadlet"
echo "===================================="
QUADLET_DIR="/etc/containers/systemd"
mkdir -p "$QUADLET_DIR"

if [ -f "/home/user/.github/podman-quadlets/remote-executor.container" ]; then
    cp /home/user/.github/podman-quadlets/remote-executor.container "$QUADLET_DIR/"
    systemctl daemon-reload
    echo "✅ Quadlet installed"
else
    echo "⚠️  Quadlet file not found"
    echo "Make sure to copy it manually to $QUADLET_DIR/"
fi
echo ""

echo "📋 Step 6: Starting remote-executor service"
echo "=========================================="
systemctl enable remote-executor.service
systemctl start remote-executor.service
sleep 2

if systemctl is-active --quiet remote-executor.service; then
    echo "✅ Service started successfully"
else
    echo "❌ Service failed to start"
    systemctl status remote-executor.service
    exit 1
fi
echo ""

echo "📋 Step 7: Testing connectivity"
echo "==============================="
sleep 2
if curl -s http://localhost:8812/health | grep -q "ok"; then
    echo "✅ Health check passed"
else
    echo "⚠️  Health check failed"
fi
echo ""

echo "╔════════════════════════════════════════════════════╗"
echo "║          ✅ INSTALLATION COMPLETE!                ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "📌 SAVE THIS API KEY SECURELY!"
echo "🔑 API Key: $EXECUTOR_KEY"
echo ""
echo "To test from Claude Code:"
echo "  curl -X POST \\"
echo "    -H 'Authorization: Bearer $EXECUTOR_KEY' \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"command\": \"whoami\", \"shell\": false}' \\"
echo "    'http://72.61.74.250:8812/execute'"
echo ""
