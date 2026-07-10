# Tailscale Setup Guide for MCP Servers

This guide provides step-by-step instructions for setting up and using Tailscale with all MCP servers across your development environment.

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [Troubleshooting](#troubleshooting)
6. [Security Best Practices](#security-best-practices)

## Installation

### Prerequisites

- Linux/macOS/Windows system
- Root or sudo access for daemon installation
- Active Tailscale account (free tier available)

### Install Tailscale

```bash
# Linux (all distributions)
curl -fsSL https://tailscale.com/install.sh | sh

# macOS
brew install tailscale

# Windows
# Download from https://tailscale.com/download
```

### Verify Installation

```bash
tailscale --version
```

Expected output:
```
1.98.8
  tailscale commit: 1241b225bc798707d02db3570992625d3a16594f
  long version: 1.98.8-t1241b225b-g0520dfda5
  other commit: 0520dfda5d034816c38a15a8661160eb9a6d5ac4
  go version: go1.26.3 (tailscale/go e877d97384)
```

## Quick Start

### Step 1: Run Setup Script

The repository includes an automated setup script:

```bash
cd /path/to/tailscale
chmod +x setup-tailscale.sh
./setup-tailscale.sh
```

The script will:
- Check if Tailscale is installed
- Start the Tailscale daemon
- Prompt you for authentication
- Create environment configuration files
- Generate docker-compose configuration
- Create documentation

### Step 2: Authenticate with Tailscale

You have two options:

**Option A: Interactive Login**

```bash
./setup-tailscale.sh
# Follow the browser prompt to log in
```

**Option B: Automated with Auth Key**

1. Generate an auth key at https://login.tailscale.com/admin/settings/keys
2. Run the setup script with the key:

```bash
TAILSCALE_AUTH_KEY=tskey-abcd1234efgh5678ijkl9012 ./setup-tailscale.sh
```

### Step 3: Verify Tailscale Connection

```bash
# Check Tailscale status
tailscale status

# Get your Tailscale IP
tailscale ip -4
```

## Configuration

### Environment Variables

Each MCP server can be configured with environment variables:

```bash
# Core Tailscale configuration
TAILSCALE_ENABLED=true              # Enable Tailscale integration
TAILSCALE_HOSTNAME=mcp-servers      # Device hostname in Tailscale network
TAILSCALE_AUTH_KEY=<auth-key>       # Authentication key for automatic login

# Server binding
BIND_ADDRESS=0.0.0.0                # Bind to all interfaces
BIND_PORT=3000                      # Port to listen on

# Optional settings
METRICS_ENABLED=false               # Enable prometheus metrics
METRICS_PORT=9090                   # Metrics port
DEBUG=false                          # Enable debug logging
TAILSCALE_FUNNEL=false              # Enable Tailscale Funnel (public access)
```

### Using .env Files

Each MCP server has a generated `.env.tailscale` file:

```bash
# api-mcp-server/.env.tailscale
TAILSCALE_ENABLED=true
TAILSCALE_HOSTNAME=mcp-servers-api-mcp-server
TAILSCALE_IP=100.123.45.67
BIND_ADDRESS=0.0.0.0
BIND_PORT=3000
```

Load the environment variables:

```bash
# Bash
env $(cat api-mcp-server/.env.tailscale) npm start

# Zsh
export $(cat api-mcp-server/.env.tailscale | xargs) && npm start

# Fish
set -a; source api-mcp-server/.env.tailscale; set +a; npm start
```

## Usage

### Local Development

#### Start Tailscale Daemon

```bash
# The daemon is typically already running after setup
# Verify it's running:
sudo systemctl status tailscaled

# If not running, start it:
sudo systemctl start tailscaled

# Enable on boot:
sudo systemctl enable tailscaled
```

#### Run Individual MCP Server

```bash
# With environment file
cd api-mcp-server
env $(cat .env.tailscale) npm start

# Or with explicit variables
TAILSCALE_ENABLED=true BIND_ADDRESS=0.0.0.0 npm start
```

#### Docker Compose Deployment

```bash
# Start all services with Tailscale
TAILSCALE_AUTH_KEY=<your-auth-key> docker-compose -f docker-compose.tailscale.yml up -d

# View logs
docker-compose -f docker-compose.tailscale.yml logs -f

# Stop services
docker-compose -f docker-compose.tailscale.yml down
```

### Remote Access

#### Connect from Another Machine

1. Install and authenticate Tailscale on your local machine:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   tailscale login
   ```

2. Get the Tailscale IP of your MCP server:
   ```bash
   # From the server machine
   tailscale ip -4
   # Output: 100.123.45.67
   ```

3. Connect from your local machine:
   ```bash
   # Test connectivity
   ping 100.123.45.67

   # Access API
   curl http://100.123.45.67:3000/health

   # SSH access (if available)
   ssh user@100.123.45.67
   ```

#### Using with Claude Desktop

Update your Claude Desktop configuration file:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "api-mcp-remote": {
      "command": "curl",
      "args": ["http://100.123.45.67:3001"],
      "env": {
        "TAILSCALE_ENABLED": "true"
      }
    },
    "github-mcp-remote": {
      "command": "curl",
      "args": ["http://100.123.45.67:3002"],
      "env": {
        "TAILSCALE_ENABLED": "true"
      }
    }
  }
}
```

## Troubleshooting

### Issue: Tailscale Daemon Not Running

**Symptoms**: Commands like `tailscale status` fail with "not connected"

**Solution**:
```bash
# Check daemon status
sudo systemctl status tailscaled

# Start daemon
sudo systemctl start tailscaled

# Enable on boot
sudo systemctl enable tailscaled

# View daemon logs
sudo journalctl -u tailscaled -n 20
```

### Issue: Can't Connect Between Devices

**Symptoms**: `ping <tailscale-ip>` fails from another device

**Solution**:
```bash
# 1. Verify both devices are connected to Tailscale
tailscale status

# 2. Check that device names are visible
tailscale ping <hostname-or-ip>

# 3. Check Tailscale ACL rules
# Visit https://login.tailscale.com/admin/acls

# 4. Restart Tailscale daemon
sudo systemctl restart tailscaled
```

### Issue: Authentication Failed

**Symptoms**: "not authenticated" or "auth key expired" errors

**Solution**:
```bash
# For interactive login:
tailscale login

# For auth key:
# 1. Generate new key at https://login.tailscale.com/admin/settings/keys
# 2. Use the new key:
TAILSCALE_AUTH_KEY=<new-key> ./setup-tailscale.sh

# 3. Logout and re-authenticate:
tailscale logout
tailscale login
```

### Issue: MCP Server Not Accessible

**Symptoms**: Cannot connect to server on Tailscale IP

**Solution**:
```bash
# 1. Verify server is running
ps aux | grep mcp

# 2. Check if server is listening on correct address
netstat -tuln | grep 3000

# 3. Verify Tailscale configuration
env $(cat .env.tailscale) npm start

# 4. Check server logs for errors
```

### Issue: Docker Compose Not Working

**Symptoms**: Containers don't start or lose Tailscale connection

**Solution**:
```bash
# Ensure auth key is set
export TAILSCALE_AUTH_KEY=<your-key>

# Rebuild containers
docker-compose -f docker-compose.tailscale.yml build --no-cache

# Start with full output
docker-compose -f docker-compose.tailscale.yml up

# Check container logs
docker-compose -f docker-compose.tailscale.yml logs <service-name>
```

## Security Best Practices

### Authentication

1. **Use Auth Keys for CI/CD**: Create short-lived auth keys for automated deployments
   ```bash
   # Generate at https://login.tailscale.com/admin/settings/keys
   # Set expiration: 1-7 days recommended
   ```

2. **Rotate Auth Keys Regularly**: Update keys every 30-90 days

3. **Limit Device Access**: Configure Tailscale ACL rules to restrict which devices can access which services

### Network Security

1. **Bind to Specific Address**: In production, avoid binding to 0.0.0.0:
   ```bash
   BIND_ADDRESS=100.123.45.67  # Use Tailscale IP instead
   ```

2. **Use HTTPS**: Enable HTTPS in production:
   ```bash
   TAILSCALE_FUNNEL=true  # For public access through Tailscale
   ```

3. **Validate Input**: All MCP servers should validate incoming requests

### Monitoring and Logging

1. **Enable Debug Logging**: For troubleshooting:
   ```bash
   DEBUG=true TAILSCALE_DEBUG=true npm start
   ```

2. **Monitor Connections**: Check who's accessing your services:
   ```bash
   # View recent connections
   tailscale status
   
   # Check logs
   sudo journalctl -u tailscaled -f
   ```

3. **Set Up Alerts**: Configure monitoring for unauthorized access attempts

## Advanced Configuration

### Tailscale Funnel (Public Access)

To expose services publicly through Tailscale Funnel:

```bash
# Enable Funnel on a service
tailscale funnel 100.123.45.67:3000

# Disable Funnel
tailscale funnel reset 100.123.45.67:3000
```

### Subnet Routing

To route traffic from other networks:

```bash
# Enable subnet routing
sudo tailscale up --advertise-routes=10.0.0.0/8

# Accept routes
# Visit https://login.tailscale.com/admin/machines
# Enable "Use as subnet router"
```

### MagicDNS

For automatic DNS resolution:

1. Visit https://login.tailscale.com/admin/dns
2. Enable MagicDNS
3. Access servers by hostname:
   ```bash
   curl http://mcp-servers.local:3000/health
   ```

## Additional Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [Tailscale ACLs](https://tailscale.com/kb/#what-are-tailscale-acls)
- [Auth Keys](https://tailscale.com/kb/#auth-keys)
- [Tailscale API](https://tailscale.com/api)

## Support

For issues with:
- **Tailscale**: Visit https://github.com/tailscale/tailscale/issues
- **MCP Servers**: Check repository issues
- **This Integration**: File an issue with Tailscale-specific details
