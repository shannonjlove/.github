# Phase 2 Execution Guide
**Date:** July 5, 2026  
**Status:** 🚀 Ready to Execute

---

## Overview

Phase 2 consists of automated deployment to VPS and Oracle environments with comprehensive validation. All scripts are production-ready and handle errors gracefully.

---

## 📦 Phase 2 Scripts

### 1. PHASE2_DEPLOY_ALL.sh (Master Orchestrator)
**Size:** 13 KB | **Type:** Interactive + Non-interactive

Controls deployment to both VPS and Oracle from a single master script.

#### Interactive Mode
```bash
bash PHASE2_DEPLOY_ALL.sh
# Menu-driven deployment with options
```

#### Non-Interactive Modes
```bash
# Deploy to VPS only
bash PHASE2_DEPLOY_ALL.sh --vps-only

# Deploy to Oracle only
export ORACLE_HOST=192.168.1.100
bash PHASE2_DEPLOY_ALL.sh --oracle-only

# Deploy to both
export ORACLE_HOST=192.168.1.100 ANTHROPIC_API_KEY="sk-ant-..."
bash PHASE2_DEPLOY_ALL.sh --all

# Verify existing deployments
bash PHASE2_DEPLOY_ALL.sh --verify
```

### 2. PHASE2_DEPLOYMENT_VPS.sh (VPS Deployment)
**Size:** 14 KB | **Type:** Standalone executable

Can be run directly on VPS or via SSH from master orchestrator.

#### Steps Performed
1. Download and install Go 1.26.4
2. Download and install Anthropic CLI v0.9.0
3. Install 1Password CLI
4. Configure shell environment (PATH, GOROOT, GOPATH)
5. Add helper functions (load-1password-env)
6. Verify all installations
7. Test API connectivity
8. Generate deployment report

#### Expected Output
```
Deployment starts...
✓ Go 1.26.4 installed successfully
✓ Anthropic CLI installed successfully
✓ 1Password CLI installed successfully
✓ Environment configuration complete
✓ All installations verified successfully
✓ Anthropic API connectivity verified
✓ Deployment report created: /root/PHASE2_DEPLOYMENT_REPORT.txt
```

### 3. PHASE2_DEPLOYMENT_ORACLE.sh (Oracle Deployment)
**Size:** 17 KB | **Type:** Standalone executable

Detects Linux distribution and installs accordingly.

#### Distribution Detection
- Ubuntu/Debian → apt
- RHEL/CentOS/Oracle Linux → dnf
- Other → Binary installation

#### Same Components as VPS
- Go 1.26.4
- Anthropic CLI v0.9.0
- 1Password CLI
- Environment variables
- Helper functions

### 4. PHASE2_VALIDATION.sh (Testing & Validation)
**Size:** 13 KB | **Type:** Standalone executable

Validates Phase 2 deployment post-installation.

#### Tests Performed
- Installation verification (Go, Anthropic CLI, 1Password)
- Go environment validation (GOROOT, GOPATH, version)
- Anthropic CLI API connectivity
- 1Password CLI authentication status
- Environment variables check
- Shell configuration verification
- Para system availability
- Para code generation testing
- Detailed test report generation

#### Run Validation
```bash
# Full validation
bash PHASE2_VALIDATION.sh

# Quick check only
bash PHASE2_VALIDATION.sh --quick

# API connectivity only
bash PHASE2_VALIDATION.sh --api-only
```

---

## 🚀 Quick Start

### Option A: Interactive Deployment (Recommended)

```bash
# From local machine with SSH access
bash PHASE2_DEPLOY_ALL.sh

# Menu appears:
# 1) Deploy to VPS only
# 2) Deploy to Oracle only
# 3) Deploy to both VPS and Oracle
# 4) Verify existing deployments
# 5) View deployment logs
```

### Option B: Automated Deployment (Both Systems)

```bash
# VPS only (IP is fixed)
bash PHASE2_DEPLOY_ALL.sh --vps-only

# Both systems
export ORACLE_HOST=192.168.1.100
export ANTHROPIC_API_KEY="sk-ant-YOUR-KEY-HERE"
bash PHASE2_DEPLOY_ALL.sh --all
```

### Option C: Manual Per-Environment

#### VPS Deployment
```bash
# SSH to VPS
ssh root@72.61.74.250

# Download and run
curl -fsSL https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/PHASE2_DEPLOYMENT_VPS.sh | \
  ANTHROPIC_API_KEY="sk-ant-YOUR-KEY-HERE" bash
```

#### Oracle Deployment
```bash
# SSH to Oracle
ssh root@<oracle-ip>

# Download and run
curl -fsSL https://raw.githubusercontent.com/shannonjlove/.github/main/infrastructure/PHASE2_DEPLOYMENT_ORACLE.sh | \
  ANTHROPIC_API_KEY="sk-ant-YOUR-KEY-HERE" bash
```

---

## 📋 Prerequisites

### Before Running Phase 2

1. **Have SSH access to both systems**
   ```bash
   # Verify VPS connectivity
   ssh root@72.61.74.250 "echo 'Connected'"
   
   # Set Oracle host
   export ORACLE_HOST=<oracle-ip>
   ssh root@$ORACLE_HOST "echo 'Connected'"
   ```

2. **Have Anthropic API key ready**
   - Provided by user in earlier session
   - Format: `sk-ant-...`
   - Can be stored in 1Password after deployment

3. **Ensure sufficient disk space**
   - Go: ~200 MB
   - Anthropic CLI: ~50 MB
   - Total: ~250 MB per system

### Configuration for Oracle

If deploying to Oracle, set environment variable:
```bash
export ORACLE_HOST=192.168.1.100
export ORACLE_USER=root  # or your SSH user
```

---

## 📊 Deployment Timeline

### Single System Deployment
- **Go Installation:** 2-3 minutes
- **Anthropic CLI Installation:** 1-2 minutes
- **1Password CLI Installation:** 1-2 minutes
- **Configuration:** 1 minute
- **Verification:** 1 minute
- **Total:** ~8-10 minutes per system

### Both Systems (Parallel)
- **Combined time:** ~15-20 minutes

---

## 🔍 Monitoring & Logs

### Log Files

**VPS Deployment:**
```
/var/log/phase2-deployment-YYYYMMDD-HHMMSS.log
/root/PHASE2_DEPLOYMENT_REPORT.txt
```

**Oracle Deployment:**
```
/var/log/phase2/phase2-deployment-YYYYMMDD-HHMMSS.log
/var/log/phase2/PHASE2_DEPLOYMENT_REPORT.txt
```

**Local Master Script:**
```
./phase2-deployment-logs/vps-deployment.log
./phase2-deployment-logs/oracle-deployment.log
./phase2-deployment-logs/PHASE2_DEPLOYMENT_SUMMARY.txt
```

### View Deployment Progress

```bash
# On VPS
tail -f /var/log/phase2-deployment-*.log

# On Oracle
tail -f /var/log/phase2/phase2-deployment-*.log

# From local machine (interactive mode)
# Menu option 5: View deployment logs
```

---

## ✅ Success Criteria

### Deployment Complete When

1. ✅ Go `go version` shows `go1.26.4`
2. ✅ Anthropic CLI `anthropic --version` works
3. ✅ 1Password CLI `op --version` works
4. ✅ `anthropic models list` returns models
5. ✅ Environment variables set (PATH, GOROOT, GOPATH)
6. ✅ Shell helpers available (`load-1password-env`)

### Validation Check

```bash
# Run on each system after deployment
bash PHASE2_VALIDATION.sh

# Should show:
# Total Tests: X
# Passed: X
# Failed: 0
# Success Rate: 100%
```

---

## 🔑 API Key Configuration

### During Deployment

Set via environment variable:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
bash PHASE2_DEPLOYMENT_VPS.sh
```

### After Deployment

#### Option 1: Via 1Password (Recommended)

```bash
# SSH to system
ssh root@72.61.74.250

# Sign in to 1Password
op signin --account shannonjeffreylove.1password.com

# Create API key item
op item create --vault Infrastructure \
  --category "API Credential" \
  --title "Anthropic CLI" \
  api_key="sk-ant-..."

# Load from 1Password
load-1password-env
```

#### Option 2: Via Environment Variable

```bash
# Add to ~/.bashrc
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.bashrc
source ~/.bashrc
```

#### Option 3: Via Config File

```bash
# Create config
mkdir -p ~/.anthropic
cat > ~/.anthropic/config.json << 'EOF'
{
  "api_key": "sk-ant-..."
}
EOF

chmod 600 ~/.anthropic/config.json
```

---

## 🧪 Testing After Deployment

### Test 1: List Models
```bash
anthropic models list
# Should show: claude-3-5-sonnet, claude-3-opus, etc.
```

### Test 2: Send Message
```bash
anthropic message --model claude-3-5-sonnet "Hello, Claude!"
# Should return: AI response
```

### Test 3: Generate Para Code
```bash
anthropic message --model claude-3-5-sonnet \
  "Generate YYMMDD-XXXX para code for test"
# Should return: 260705-0001 format code
```

### Test 4: 1Password Integration
```bash
# Sign in
op signin --account shannonjeffreylove.1password.com

# Load credentials
load-1password-env

# Verify
echo $ANTHROPIC_API_KEY | head -c 20
```

---

## ⚠️ Troubleshooting

### "Go: command not found"

**Solution:**
```bash
# Add to PATH manually
export PATH="/usr/local/go/bin:$PATH"

# Or reload shell
source ~/.bashrc
```

### "Anthropic API key not found"

**Solution:**
```bash
# Check if set
echo $ANTHROPIC_API_KEY

# If empty, set it
export ANTHROPIC_API_KEY="sk-ant-..."

# Or load from 1Password
load-1password-env
```

### "SSH connection failed"

**Solution:**
```bash
# Check connectivity
ping 72.61.74.250

# Test SSH
ssh -v root@72.61.74.250

# If private key needed
ssh -i ~/.ssh/id_rsa root@72.61.74.250
```

### Deployment Script Fails

**Solution:**
```bash
# Check log file
tail -f /var/log/phase2-deployment-*.log

# Run validation
bash PHASE2_VALIDATION.sh

# Check specific component
go version
anthropic --version
op --version
```

---

## 📈 Next Steps After Phase 2

### Immediate (Today)
1. ✅ Run PHASE2_DEPLOY_ALL.sh
2. ✅ Run PHASE2_VALIDATION.sh on both systems
3. ✅ Verify all tests pass

### Short Term (This Week)
1. Configure 1Password vault with all 7 services
2. Test Bookstack API connectivity
3. Test Paperless-NGX API connectivity
4. Test Craft Docs, TickTick, Raindrop.io

### Medium Term (Next Week)
1. Test cross-platform linking
2. Run platform sync service
3. Verify para codes sync across all systems
4. Set up monitoring and logging

---

## 📞 Support & References

### Documentation
- PHASE2_READINESS.md - Testing procedures
- ANTHROPIC_CLI_INTEGRATION.md - API usage examples
- 1PASSWORD_QUICK_START.md - Credential setup
- GO_INSTALLATION_GUIDE.md - Go troubleshooting

### Quick Commands

```bash
# Deployment
bash PHASE2_DEPLOY_ALL.sh

# Validation
bash PHASE2_VALIDATION.sh

# Check installations
go version
anthropic --version
op --version

# Load credentials
load-1password-env

# Test API
anthropic models list
anthropic message --model claude-3-5-sonnet "test"

# SSH to systems
ssh root@72.61.74.250  # VPS
ssh root@$ORACLE_HOST  # Oracle
```

---

## 🎯 Success Checklist

- [ ] SSH access verified to VPS and Oracle
- [ ] Anthropic API key obtained
- [ ] PHASE2_DEPLOY_ALL.sh downloaded
- [ ] Deployment started (interactive or automated)
- [ ] VPS deployment completed successfully
- [ ] Oracle deployment completed successfully
- [ ] PHASE2_VALIDATION.sh run on both systems
- [ ] All validation tests passed
- [ ] 1Password signed in on both systems
- [ ] API key configured and tested
- [ ] Para code generation working
- [ ] Deployment reports reviewed

---

**Phase 2 execution ready!** 🚀

Follow the Quick Start section above to begin deployment.

Questions? Check the troubleshooting section or review the detailed documentation files.
