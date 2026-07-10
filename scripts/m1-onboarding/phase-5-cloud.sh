#!/bin/bash
# Phase 5: Cloud Infrastructure Connectivity
# Sets up Tailscale NFS mounting, SSH aliases, and cloud sync
# Safe to run multiple times - idempotent

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 5: Cloud Infrastructure Connectivity${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Step 1: Verify Tailscale connection
echo -e "\n${BOLD}[1/3] Verifying Tailscale VPN connection...${NC}"
if ! command -v tailscale &> /dev/null; then
    echo -e "${RED}✗ Tailscale not installed${NC}"
    echo "Install with: ${BLUE}brew install tailscale${NC}"
    exit 1
fi

if ! tailscale ip -4 &>/dev/null; then
    echo -e "${RED}✗ Tailscale not connected${NC}"
    echo "Connect with: ${BLUE}tailscale up${NC}"
    exit 1
fi

TAILSCALE_IP=$(tailscale ip -4 | head -1)
echo -e "${GREEN}✓ Tailscale connected (${TAILSCALE_IP})${NC}"

# Verify connectivity to Nexus
if ping -c 1 100.115.66.75 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Nexus reachable (100.115.66.75)${NC}"
else
    echo -e "${YELLOW}⚠ Nexus not currently reachable${NC}"
    echo "This may be normal if Nexus is offline. Continuing..."
fi

# Step 2: Setup SSH aliases
echo -e "\n${BOLD}[2/3] Setting up SSH aliases...${NC}"
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"

# Backup original if needed
if [ -f "$SSH_CONFIG" ] && ! grep -q "# M1 Onboarding Cloud Aliases" "$SSH_CONFIG"; then
    cp "$SSH_CONFIG" "${SSH_CONFIG}.backup"
    echo -e "${GREEN}✓ Created backup: ${SSH_CONFIG}.backup${NC}"
fi

# Add SSH aliases (idempotent)
if ! grep -q "# M1 Onboarding Cloud Aliases" "$SSH_CONFIG"; then
    cat >> "$SSH_CONFIG" << 'EOF'

# M1 Onboarding Cloud Aliases
Host nexus
  HostName 100.115.66.75
  User ubuntu
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking accept-new
  HostKeyAlgorithms +ssh-rsa

Host sos
  HostName 100.67.229.94
  User ubuntu
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking accept-new
  HostKeyAlgorithms +ssh-rsa

Host webtop
  HostName 100.67.229.94
  User root
  IdentityFile ~/.ssh/id_rsa
  LocalForward 3000 127.0.0.1:3000
  LocalForward 3001 127.0.0.1:3001
  StrictHostKeyChecking accept-new
EOF
    chmod 600 "$SSH_CONFIG"
    echo -e "${GREEN}✓ SSH aliases configured${NC}"
else
    echo -e "${GREEN}✓ SSH aliases already configured${NC}"
fi

# Step 3: Setup NFS mounting (macOS specific)
echo -e "\n${BOLD}[3/3] Setting up NFS mount for shared context...${NC}"

# Create mount point
if [ ! -d "/mnt/shared-context" ]; then
    echo "Creating NFS mount point..."
    sudo mkdir -p /mnt/shared-context
    echo -e "${GREEN}✓ Mount point created${NC}"
else
    echo -e "${GREEN}✓ Mount point already exists${NC}"
fi

# Create mount script (safer than editing /etc/fstab on macOS)
MOUNT_SCRIPT="/tmp/mount-shared-context.sh"
cat > "$MOUNT_SCRIPT" << 'EOF'
#!/bin/bash
# Mount NFS shared context from Nexus

NEXUS_IP="100.115.66.75"
MOUNT_POINT="/mnt/shared-context"
REMOTE_PATH="/mnt/shared-context"

echo "Attempting to mount NFS from Nexus ($NEXUS_IP)..."

# Unmount if already mounted
if mount | grep -q "$MOUNT_POINT"; then
    echo "Already mounted"
    exit 0
fi

# Try NFS v4
sudo mount -t nfs -o nfsvers=4,proto=tcp,hard,timeo=300,retrans=2 \
    "$NEXUS_IP:$REMOTE_PATH" "$MOUNT_POINT" 2>/dev/null && \
    echo "✓ NFS mounted successfully" && exit 0

# Fallback to NFS v3
sudo mount -t nfs -o nfsvers=3,proto=tcp,hard,timeo=300,retrans=2 \
    "$NEXUS_IP:$REMOTE_PATH" "$MOUNT_POINT" 2>/dev/null && \
    echo "✓ NFS mounted successfully (v3)" && exit 0

echo "⚠ Could not mount NFS. Nexus may be offline or NFS export not available."
exit 1
EOF

chmod +x "$MOUNT_SCRIPT"

# Try to mount
echo "Testing NFS mount..."
if sudo "$MOUNT_SCRIPT"; then
    # Verify mount
    if mount | grep -q "$MOUNT_POINT"; then
        echo -e "${GREEN}✓ NFS mounted to /mnt/shared-context${NC}"
    fi
else
    echo -e "${YELLOW}⚠ NFS mount failed (Nexus may be offline)${NC}"
    echo "Mount manually when Nexus is available:"
    echo "${BLUE}sudo $MOUNT_SCRIPT${NC}"
fi

# Create symlink to shared memories
if [ -d "/mnt/shared-context/claude-memories" ]; then
    if [ ! -L "$HOME/.claude-memory-cloud" ]; then
        ln -s /mnt/shared-context/claude-memories "$HOME/.claude-memory-cloud"
        echo -e "${GREEN}✓ Created symlink to cloud memories${NC}"
    fi
fi

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 5 Complete: Cloud Connectivity Ready${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}Cloud Configuration:${NC}"
echo "  Tailscale IP: $TAILSCALE_IP"
echo "  Nexus: 100.115.66.75 (ssh nexus)"
echo "  sOs: 100.67.229.94 (ssh sos)"
echo "  NFS Mount: /mnt/shared-context"
echo -e "\n${BOLD}Next Steps:${NC}"
echo "1. Verify cloud access: ${BLUE}ssh nexus hostname${NC}"
echo "2. Check NFS mount: ${BLUE}ls -la /mnt/shared-context${NC}"
echo "3. Run verification: ${BLUE}bash scripts/m1-onboarding/verify-setup.sh${NC}"
