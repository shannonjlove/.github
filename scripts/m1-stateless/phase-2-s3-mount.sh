#!/bin/bash
# Phase 2: S3 Mounting via rclone (idrive e2)
# Mount ~/PARA, ~/projects, ~/.claude-memory from S3
# All storage is remote; laptop only has mount points

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Phase 2: Mount S3 Storage via rclone${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Verify rclone installed
if ! command -v rclone &> /dev/null; then
    echo -e "${RED}ERROR: rclone not installed. Run Phase 1 first.${NC}"
    exit 1
fi

echo -e "\n${BLUE}This phase mounts idrive e2 S3 buckets as local directories${NC}\n"

# Step 1: Configure rclone for idrive e2
echo -e "${BOLD}[1/4] Configuring rclone for idrive e2...${NC}"
RCLONE_CONFIG="$HOME/.config/rclone/rclone.conf"
mkdir -p "$HOME/.config/rclone"

if ! grep -q "\[idrive-e2\]" "$RCLONE_CONFIG" 2>/dev/null; then
    echo -e "\n${YELLOW}Manual step required:${NC}"
    echo "rclone needs idrive e2 credentials. Two options:"
    echo ""
    echo "  Option 1: Already configured in ~/.aws/credentials"
    echo "    Run: ${BLUE}rclone config create idrive-e2 s3${NC}"
    echo "    Then answer prompts (use AWS credentials)"
    echo ""
    echo "  Option 2: Restore from backup"
    echo "    Copy rclone.conf from another machine to:"
    echo "    ${BLUE}$RCLONE_CONFIG${NC}"
    echo ""
    read -p "Press Enter after configuring rclone..."
fi

if grep -q "\[idrive-e2\]" "$RCLONE_CONFIG"; then
    echo -e "${GREEN}✓ rclone idrive-e2 configured${NC}"
else
    echo -e "${RED}ERROR: rclone not configured${NC}"
    exit 1
fi

# Step 2: Test S3 connectivity
echo -e "\n${BOLD}[2/4] Testing S3 connectivity...${NC}"
if rclone ls idrive-e2: &>/dev/null; then
    echo -e "${GREEN}✓ S3 access verified${NC}"
else
    echo -e "${RED}ERROR: Cannot access S3. Check credentials.${NC}"
    exit 1
fi

# Step 3: Create rclone mounts
echo -e "\n${BOLD}[3/4] Setting up rclone mounts...${NC}"

# VFS cache configuration
VFS_CACHE_DIR="$HOME/.cache/rclone"
mkdir -p "$VFS_CACHE_DIR"

# Function to mount S3 bucket
mount_s3() {
    local local_path=$1
    local s3_path=$2
    local name=$3

    # Check if already mounted
    if mount | grep -q "$local_path"; then
        echo -e "  ${GREEN}✓${NC} $name already mounted"
        return
    fi

    # Create mount script
    local mount_script="/tmp/mount-$name.sh"
    cat > "$mount_script" << MOUNT_EOF
#!/bin/bash
rclone mount $s3_path "$local_path" \
  --daemon \
  --vfs-cache-mode writes \
  --vfs-cache-max-size 5G \
  --vfs-read-ahead 128k \
  --attr-timeout 0s \
  --dir-cache-time 1h \
  --allow-non-empty \
  --allow-other \
  --log-file "$HOME/.cache/rclone/${name}.log" \
  2>&1
MOUNT_EOF
    chmod +x "$mount_script"

    echo "  Mounting $name..."
    if bash "$mount_script"; then
        sleep 2
        if mount | grep -q "$local_path"; then
            echo -e "  ${GREEN}✓${NC} $name mounted at $local_path"
        else
            echo -e "  ${YELLOW}⚠${NC} Mount started but verifying..."
            sleep 1
            mount | grep "$local_path" && echo -e "  ${GREEN}✓${NC} $name now visible"
        fi
    fi
}

# Mount all S3 buckets
mount_s3 "$HOME/PARA" "idrive-e2:shannonjlove/para" "PARA"
mount_s3 "$HOME/projects" "idrive-e2:shannonjlove/projects" "projects"
mount_s3 "$HOME/.claude-memory" "idrive-e2:shannonjlove/memories" "memories"
mount_s3 "$HOME/Documents" "idrive-e2:shannonjlove/documents" "documents"

# Step 4: Verify mounts
echo -e "\n${BOLD}[4/4] Verifying mounts...${NC}"
MOUNTED=0
TOTAL=4

for mount_point in "$HOME/PARA" "$HOME/projects" "$HOME/.claude-memory" "$HOME/Documents"; do
    if mount | grep -q "$mount_point"; then
        echo -e "  ${GREEN}✓${NC} $(basename $mount_point)"
        ((MOUNTED++))
    else
        echo -e "  ${RED}✗${NC} $(basename $mount_point)"
    fi
done

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}Phase 2 Complete: S3 Mounted ($MOUNTED/$TOTAL)${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "\n${BOLD}S3 Mounts:${NC}"
mount | grep rclone || echo "  (none mounted yet)"
echo -e "\n${BOLD}Mounted Directories:${NC}"
ls -ld $HOME/PARA $HOME/projects $HOME/.claude-memory 2>/dev/null | awk '{print "  " $NF}'
echo -e "\n${BOLD}Cache Location:${NC}"
echo "  $VFS_CACHE_DIR"
echo -e "\n${BOLD}Next:${NC}"
echo "1. Verify mounts: ${BLUE}mount | grep rclone${NC}"
echo "2. Check PARA: ${BLUE}ls -la ~/PARA/${NC}"
echo "3. Run Phase 3: ${BLUE}bash scripts/m1-stateless/phase-3-config.sh${NC}"
