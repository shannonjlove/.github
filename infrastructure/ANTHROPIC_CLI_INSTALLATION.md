# Anthropic CLI Installation Guide
**Purpose:** Install Anthropic CLI on VPS and Oracle environments  
**Date:** July 5, 2026  
**API Key Location:** 1Password Infrastructure vault (stored securely)

---

## Quick Start

### Option 1: Automated Installation (Recommended)

**On VPS (72.61.74.250):**
```bash
curl -fsSL https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/ANTHROPIC_CLI_SETUP.sh | sudo bash
```

**On Oracle (or any Linux system):**
```bash
chmod +x ANTHROPIC_CLI_SETUP.sh
sudo bash ANTHROPIC_CLI_SETUP.sh
```

### Option 2: Manual Installation

**Step 1: Download Anthropic CLI Binary**
```bash
# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi
if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi

# Download latest release from GitHub
curl -fsSL -O https://github.com/anthropics/anthropic-cli/releases/download/v0.9.0/anthropic-cli_0.9.0_Linux_${ARCH}.tar.gz
```

**Step 2: Install Binary**
```bash
# Extract
tar -xzf anthropic-cli_0.9.0_Linux_${ARCH}.tar.gz

# Copy to PATH
sudo mv anthropic /usr/local/bin/
sudo chmod +x /usr/local/bin/anthropic

# Verify
anthropic --version
```

**Step 3: Configure API Key**
```bash
# Create configuration directory
mkdir -p ~/.anthropic

# Add API key to environment
export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"

# Or add to shell profile for persistence (use actual key from 1Password)
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"' >> ~/.bashrc
source ~/.bashrc
```

---

## Installation Methods

### Method 1: From GitHub Releases (Recommended)

```bash
# Get latest version
LATEST_VERSION=$(curl -s https://api.github.com/repos/anthropics/anthropic-cli/releases/latest | jq -r '.tag_name')

# Detect architecture
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH="amd64"
[ "$ARCH" = "aarch64" ] && ARCH="arm64"

# Download and install
sudo mkdir -p /usr/local/bin
curl -fsSL -o /tmp/anthropic.tar.gz \
  https://github.com/anthropics/anthropic-cli/releases/download/${LATEST_VERSION}/anthropic-cli_${LATEST_VERSION#v}_Linux_${ARCH}.tar.gz

sudo tar -xzf /tmp/anthropic.tar.gz -C /usr/local/bin/
sudo chmod +x /usr/local/bin/anthropic

# Verify
anthropic --version
```

### Method 2: Build from Source (Requires Go 1.26.4)

```bash
# Prerequisites
# - Go 1.26.4 installed (see GO_INSTALLATION_GUIDE.md)
# - git installed

# Clone repository
git clone https://github.com/anthropics/anthropic-cli.git
cd anthropic-cli

# Build
go build -o anthropic ./cmd/anthropic

# Install
sudo mv anthropic /usr/local/bin/
sudo chmod +x /usr/local/bin/anthropic

# Verify
anthropic --version
```

### Method 3: Using Package Manager (if available)

**Ubuntu/Debian:**
```bash
# Coming soon - package manager support
sudo apt install anthropic-cli  # Once available in repositories
```

---

## API Key Configuration

### Method 1: Environment Variable (Recommended)

```bash
# Add to ~/.bashrc or ~/.zshrc
export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"

# Reload shell
source ~/.bashrc
```

### Method 2: Configuration File

```bash
# Create config directory
mkdir -p ~/.anthropic

# Create config file
cat > ~/.anthropic/config.json << 'EOF'
{
  "api_key": "sk-ant-YOUR-API-KEY-HERE"
}
EOF

# Secure permissions
chmod 600 ~/.anthropic/config.json
```

### Method 3: 1Password Integration

```bash
# Load from 1Password vault
export ANTHROPIC_API_KEY=$(op item get "Anthropic CLI" --vault Infrastructure --field api_key)

# Add to shell profile for automatic loading
echo 'export ANTHROPIC_API_KEY=$(op item get "Anthropic CLI" --vault Infrastructure --field api_key)' >> ~/.bashrc
```

---

## Secure Credential Storage

**IMPORTANT:** Never commit actual API keys to Git. Store secrets in:
1. **1Password** (recommended) - Use `op item get` to load at runtime
2. **Environment variables** - Set via shell profile or CI/CD secrets
3. **Secret management system** - Use your organization's credential manager

Example with environment file (do NOT commit):
```bash
# ~/.anthropic/.env (gitignored)
export ANTHROPIC_API_KEY="your-actual-key-here"

# Then source it:
source ~/.anthropic/.env
```

---

## Verification

### Check Installation

```bash
# Version
anthropic --version

# Help
anthropic --help

# API connectivity
anthropic --list-models
```

### Test API Access

```bash
# Simple test
anthropic message --model claude-3-5-sonnet --max-tokens 100 "Hello, world!"

# Get model information
anthropic models list

# Show API key (verify it's loaded)
echo $ANTHROPIC_API_KEY | head -c 20
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
curl -fsSL https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/ANTHROPIC_CLI_SETUP.sh | sudo bash

# Option B: Download first, then run
wget https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/ANTHROPIC_CLI_SETUP.sh
chmod +x ANTHROPIC_CLI_SETUP.sh
sudo bash ./ANTHROPIC_CLI_SETUP.sh
```

### Step 3: Configure API Key

```bash
# Add to root's shell profile
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"' >> /root/.bashrc
source /root/.bashrc
```

### Step 4: Verify Installation

```bash
anthropic --version
anthropic models list
```

---

## Oracle Environment Installation

### Prerequisites

- Root or sudo access
- Internet connectivity
- Go 1.26.4 installed (optional, for source build)
- ~100MB disk space

### Installation Steps

```bash
# 1. Update system
sudo yum update -y  # For RHEL/CentOS
# or
sudo apt update     # For Ubuntu/Debian

# 2. Download and install binary
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH="amd64"
[ "$ARCH" = "aarch64" ] && ARCH="arm64"

curl -fsSL -o /tmp/anthropic.tar.gz \
  https://github.com/anthropics/anthropic-cli/releases/download/v0.9.0/anthropic-cli_0.9.0_Linux_${ARCH}.tar.gz

sudo tar -xzf /tmp/anthropic.tar.gz -C /usr/local/bin/
sudo chmod +x /usr/local/bin/anthropic

# 3. Configure API key
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"' >> ~/.bashrc
source ~/.bashrc

# 4. Verify
anthropic --version
anthropic models list

# 5. Test with simple prompt
anthropic message --model claude-3-5-sonnet --max-tokens 100 "Test"
```

---

## Post-Installation

### 1. Update Shell Profile

Add to `~/.bashrc`, `~/.bash_profile`, or `~/.zshrc`:

```bash
# Anthropic CLI
export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"
export PATH=/usr/local/bin:$PATH

# Optional: Anthropic CLI completion (if available)
# eval "$(anthropic completion bash)"
```

### 2. Common Commands

```bash
# List available models
anthropic models list

# Send a message
anthropic message --model claude-3-5-sonnet "Your prompt here"

# With options
anthropic message --model claude-3-5-sonnet --max-tokens 1024 --temperature 0.5 "Your prompt"

# Use in scripts
anthropic message --model claude-3-5-sonnet --output json "JSON query" | jq '.content[0].text'
```

### 3. Integration with Python/Node Scripts

**Python Example:**
```python
import subprocess
import json

def call_anthropic(prompt, model="claude-3-5-sonnet"):
    cmd = [
        "anthropic", "message",
        "--model", model,
        "--max-tokens", "1024",
        "--output", "json",
        prompt
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return json.loads(result.stdout)

response = call_anthropic("Hello, Claude!")
print(response['content'][0]['text'])
```

**Bash Example:**
```bash
#!/bin/bash

prompt="$1"
model="${2:-claude-3-5-sonnet}"

anthropic message --model "$model" --max-tokens 1024 "$prompt"
```

---

## Troubleshooting

### "anthropic: command not found"

**Solution 1: Check PATH**
```bash
# Verify installation
ls -la /usr/local/bin/anthropic

# Add to PATH if missing
export PATH=/usr/local/bin:$PATH
echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

**Solution 2: Rebuild and reinstall**
```bash
# Download latest release
curl -fsSL -o /tmp/anthropic.tar.gz \
  https://github.com/anthropics/anthropic-cli/releases/download/v0.9.0/anthropic-cli_0.9.0_Linux_amd64.tar.gz

# Extract and install
sudo tar -xzf /tmp/anthropic.tar.gz -C /usr/local/bin/
sudo chmod +x /usr/local/bin/anthropic
```

### "API key not found"

**Solution:**
```bash
# Verify environment variable
echo $ANTHROPIC_API_KEY

# If empty, set it
export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"

# Add to profile permanently
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"' >> ~/.bashrc
source ~/.bashrc
```

### "API authentication failed"

**Solution 1: Verify API key**
```bash
# Check key format (should start with sk-ant-)
echo $ANTHROPIC_API_KEY | head -c 20

# Verify full key
echo $ANTHROPIC_API_KEY
```

**Solution 2: Test with explicit key**
```bash
# Test directly (use actual key from 1Password)
ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE" \
  anthropic message --model claude-3-5-sonnet "Test"
```

### "Version mismatch" or "Binary incompatibility"

**Solution: Download correct binary**
```bash
# Check architecture
uname -m

# Check Go version (if built from source)
go version

# Download matching binary
# amd64: anthropic-cli_X.X.X_Linux_amd64.tar.gz
# arm64: anthropic-cli_X.X.X_Linux_arm64.tar.gz
```

### Build from source fails

**Solution: Ensure Go is installed**
```bash
# Check Go installation
go version
# Expected: go version go1.26.4 linux/amd64

# If not installed, run Go installation guide
bash GO_INSTALLATION_SETUP.sh

# Then try building again
cd anthropic-cli
go build -o anthropic ./cmd/anthropic
```

---

## Security Notes

1. **API Key Management**
   - Never commit API keys to git
   - Store in environment variables or 1Password
   - Rotate keys periodically
   - Use separate keys for different environments

2. **File Permissions**
   - Config files should be readable only by user: `chmod 600`
   - Installation directory should be owned by root: `chown root:root /usr/local/bin/anthropic`

3. **Environment Variables**
   - Keep API keys out of shell history: `HISTCONTROL=ignorespace` then ` export ANTHROPIC_API_KEY=...`
   - Don't share .bashrc or .zshrc files with embedded keys

---

## Uninstalling Anthropic CLI

**Using script (if available):**
```bash
sudo bash ANTHROPIC_CLI_SETUP.sh --uninstall
```

**Manual uninstall:**
```bash
# Remove binary
sudo rm /usr/local/bin/anthropic

# Remove config (optional)
rm -rf ~/.anthropic

# Remove from shell profile
# Edit ~/.bashrc or ~/.zshrc and remove Anthropic CLI lines
```

---

## Official Resources

| Resource | Link |
|----------|------|
| GitHub Repository | https://github.com/anthropics/anthropic-cli |
| GitHub Releases | https://github.com/anthropics/anthropic-cli/releases |
| Anthropic CLI Docs | https://github.com/anthropics/anthropic-cli#readme |
| Claude API Docs | https://docs.anthropic.com/ |
| Models Overview | https://docs.anthropic.com/claude/reference/models-overview |

---

## Architecture Support

| Architecture | Binary | Status |
|--------------|--------|--------|
| x86_64 (AMD64) | anthropic-cli_X.X.X_Linux_amd64.tar.gz | ✅ Supported |
| ARM64 (aarch64) | anthropic-cli_X.X.X_Linux_arm64.tar.gz | ✅ Supported |
| Source Build | Requires Go 1.26.4 | ✅ Supported |

---

## Next Steps

1. **Run the installation script** on both VPS and Oracle
2. **Verify API connectivity** with `anthropic models list`
3. **Test with a simple message** to confirm end-to-end functionality
4. **Add to system automation** for para code integration
5. **Update documentation** for team reference

---

**Ready to install Anthropic CLI!** 🚀

Use ANTHROPIC_CLI_SETUP.sh for automated installation on both environments.
