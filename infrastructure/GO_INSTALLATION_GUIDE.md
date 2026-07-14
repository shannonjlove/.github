# Go Language Installation Guide
**Purpose:** Install Go 1.26.4 on VPS and Oracle environments  
**Date:** July 5, 2026  
**Go Version:** 1.26.4

---

## Quick Start

### Option 1: Automated Installation (Recommended)

**On VPS (72.61.74.250):**
```bash
# Download and run the installation script
curl -fsSL https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/GO_INSTALLATION_SETUP.sh | sudo bash
```

**On Oracle (or any Linux system):**
```bash
# Make script executable
chmod +x GO_INSTALLATION_SETUP.sh

# Run as root
sudo bash GO_INSTALLATION_SETUP.sh
```

### Option 2: Manual Installation

**Step 1: Download Go**
```bash
# Detect architecture (amd64 or arm64)
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi

# Download Go 1.26.4
curl -fsSL -O https://go.dev/dl/go1.26.4.linux-${ARCH}.tar.gz
```

**Step 2: Install Go**
```bash
# Remove existing installation (if any)
sudo rm -rf /usr/local/go

# Extract to /usr/local
sudo tar -C /usr/local -xzf go1.26.4.linux-${ARCH}.tar.gz

# Clean up
rm go1.26.4.linux-${ARCH}.tar.gz
```

**Step 3: Configure PATH**
```bash
# Add Go to your shell profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verify
go version
```

---

## Installation Methods

### Method 1: Direct Command (Fastest)

```bash
sudo rm -rf /usr/local/go && \
curl -fsSL https://go.dev/dl/go1.26.4.linux-amd64.tar.gz | \
sudo tar -C /usr/local -xzf -
```

### Method 2: Using Package Manager

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install golang-go
```

**RHEL/CentOS/Fedora:**
```bash
sudo dnf install golang
```

### Method 3: Using Script (Recommended for VPS/Oracle)

```bash
# Copy script to VPS
scp infrastructure/GO_INSTALLATION_SETUP.sh root@72.61.74.250:/tmp/

# SSH into VPS
ssh root@72.61.74.250

# Run installation
sudo bash /tmp/GO_INSTALLATION_SETUP.sh
```

---

## Remote Installation via MCP

**Using the remote executor on VPS (72.61.74.250:8813):**

```bash
curl -X POST \
  -H "Authorization: Bearer 9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e6073770bf5687" \
  -H "Content-Type: application/json" \
  -d '{
    "command": "rm -rf /usr/local/go && curl -fsSL https://go.dev/dl/go1.26.4.linux-amd64.tar.gz | tar -C /usr/local -xzf - && echo $PATH"
  }' \
  http://72.61.74.250:8813/execute
```

---

## Verification

### Check Go Installation

```bash
# Version
go version
# Expected: go version go1.26.4 linux/amd64

# Environment
go env
# Shows GOROOT, GOPATH, etc.

# Test program
go run -h
```

### Test Go Functionality

```bash
# Create a test program
mkdir -p ~/test-go
cd ~/test-go

cat > hello.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from Go!")
}
EOF

# Run it
go run hello.go
```

---

## Configuration

### Environment Variables

**Automatic (after script runs):**
```bash
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
```

**Manual setup in ~/.bashrc:**
```bash
# Add these lines to ~/.bashrc or ~/.zshrc
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Reload
source ~/.bashrc
```

### Go Workspace

```bash
# Create Go workspace
mkdir -p ~/go/{bin,pkg,src}

# Set permissions
chmod -R 755 ~/go
```

---

## Troubleshooting

### "go: command not found"

**Solution 1: Update PATH**
```bash
# Check if Go is installed
ls -la /usr/local/go/bin/go

# Add to PATH
export PATH=/usr/local/go/bin:$PATH

# Verify
go version
```

**Solution 2: Wrong Installation Directory**
```bash
# Find Go installation
find / -name "go" -type f 2>/dev/null | grep bin

# Update PATH accordingly
```

### Architecture Mismatch

```bash
# Check your architecture
uname -m

# Download correct version
# amd64 for x86_64
# arm64 for aarch64

# Download and install for your arch
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH="amd64"
[ "$ARCH" = "aarch64" ] && ARCH="arm64"

curl -fsSL https://go.dev/dl/go1.26.4.linux-${ARCH}.tar.gz | \
  sudo tar -C /usr/local -xzf -
```

### Permission Denied

```bash
# Ensure correct permissions
sudo chown -R root:root /usr/local/go

# Test again
go version
```

### GOPATH Issues

```bash
# Create GOPATH structure
mkdir -p ~/go/{bin,pkg,src}

# Set GOPATH
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Verify
go env | grep GOPATH
```

---

## VPS Installation Steps

### Step 1: SSH into VPS

```bash
ssh root@72.61.74.250
```

### Step 2: Download and Run Script

```bash
# Option A: One-liner
curl -fsSL https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/GO_INSTALLATION_SETUP.sh | bash

# Option B: Download first, then run
wget https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/GO_INSTALLATION_SETUP.sh
bash GO_INSTALLATION_SETUP.sh
```

### Step 3: Verify Installation

```bash
go version
go env | grep GOROOT
```

### Step 4: Test with Project

```bash
# Create a test project
mkdir -p /home/projects/test-app
cd /home/projects/test-app

# Initialize Go module
go mod init test-app

# Create simple program
echo 'package main; import "fmt"; func main() { fmt.Println("Go works!") }' > main.go

# Run it
go run main.go
```

---

## Oracle Environment Installation

### Prerequisites

- Root or sudo access
- Internet connectivity (for downloading Go)
- ~200MB disk space

### Installation

```bash
# 1. Update system
sudo yum update -y  # For RHEL/CentOS
# or
sudo apt update     # For Ubuntu/Debian

# 2. Install Go
sudo bash GO_INSTALLATION_SETUP.sh

# 3. Verify
go version

# 4. Create workspace
mkdir -p $HOME/go/{bin,pkg,src}

# 5. Test
echo 'package main; import "fmt"; func main() { fmt.Println("Oracle Go Ready!") }' > $HOME/hello.go
go run $HOME/hello.go
```

---

## Post-Installation

### 1. Update Shell Profile

Add to `~/.bashrc`, `~/.bash_profile`, or `~/.zshrc`:

```bash
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
```

### 2. Install Common Tools

```bash
# Go linter
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Code formatter
go install golang.org/x/tools/cmd/goimports@latest

# Go module utilities
go install golang.org/x/tools/cmd/govulncheck@latest
```

### 3. Verify Common Tools

```bash
go version
go env
golangci-lint --version
goimports --version
```

---

## Uninstalling Go

**Using script:**
```bash
sudo bash GO_INSTALLATION_SETUP.sh --uninstall
```

**Manual uninstall:**
```bash
# Remove installation
sudo rm -rf /usr/local/go

# Remove GOPATH (optional)
rm -rf $HOME/go

# Remove PATH entries from shell profile
# Edit ~/.bashrc or ~/.zshrc and remove Go PATH entries
```

---

## Official Resources

| Resource | Link |
|----------|------|
| Go Home | https://golang.org/ |
| Downloads | https://go.dev/dl/ |
| Getting Started | https://go.dev/doc/tutorial |
| Language Spec | https://golang.org/ref/spec |
| Standard Library | https://golang.org/pkg/ |
| Effective Go | https://golang.org/doc/effective_go |

---

## Architecture Support

| Architecture | Binary | Status |
|--------------|--------|--------|
| x86_64 (AMD64) | go1.26.4.linux-amd64.tar.gz | ✅ Supported |
| ARM64 (aarch64) | go1.26.4.linux-arm64.tar.gz | ✅ Supported |
| ARM (32-bit) | go1.26.4.linux-armv6l.tar.gz | ⚠️ Limited support |
| PowerPC | Not available | ❌ Not supported |

---

## Security Notes

1. **Verify Downloads**
   - Script checks SHA256 checksums
   - Downloads from official go.dev domain

2. **Permissions**
   - Installation to /usr/local requires root
   - Go binary is owned by root:root

3. **Updates**
   - Run script again to upgrade Go version
   - Previous installation automatically backed up

---

## Frequently Asked Questions

**Q: Which Go version should I use?**  
A: 1.26.4 is the current version and recommended for all systems.

**Q: Can I install multiple Go versions?**  
A: Yes, use different GOROOT directories. Installation script uses /usr/local/go.

**Q: How much disk space does Go need?**  
A: ~200MB for installation + additional space for compiled projects.

**Q: Do I need GOPATH?**  
A: GOPATH is less important with Go modules (introduced in Go 1.11), but still recommended.

**Q: Can I use Go without root?**  
A: Yes, install to $HOME/go/root instead of /usr/local/go.

---

**Ready to install Go!** 🚀

Run the automated script and you'll be developing in Go in minutes.
