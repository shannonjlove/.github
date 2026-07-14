# VPS Infrastructure Automation - Handoff Document

**Date:** July 5, 2026  
**Branch:** `claude/mcp-filesystem-crash-loop-nt1h0b`  
**Status:** Implementation Complete, Testing Phase

---

## Executive Summary

Complete VPS automation infrastructure system implemented with 5-platform bidirectional linking:
- ✅ SMS notifications (Twilio)
- ✅ iOS automation (Scriptable.app)
- ✅ Real-time dashboard (HTML + Chart.js)
- ✅ Event logging (Bookstack)
- ✅ WebSocket server (port 9000)
- ✅ Security layer (1Password CLI)
- ✅ Cross-platform linking (Bookstack, Craft Docs, TickTick, Raindrop.io, Paperless-NGX)
- ✅ Para system (YYMMDD-XXXX codes)

**Next Phase:** Configuration, testing, and deployment on actual VPS

---

## Current State

### Completed Components

**Core Infrastructure:**
- SMS gateway (Twilio) with helper scripts
- iOS automation (file management + PDF processing)
- Real-time dashboard with WebSocket integration
- Bookstack event logging with Year/Month/Day hierarchy
- WebSocket server for live updates
- 1Password CLI vault management
- Remote command executor (port 8813)

**Cross-Platform Linking (NEW):**
- Para system code generator (YYMMDD-XXXX format)
- Cross-platform linker (create items on all 5 platforms with same code)
- Paperless-NGX para system integration
- Platform sync service (bidirectional daemon)

### File Locations

All infrastructure code in: `/home/user/.github/infrastructure/`

```
infrastructure/
├── notification/
│   ├── twilio-sms-config.sh
│
├── ios-automation/
│   ├── file-management.js
│   └── pdf-paperless.js
│
├── event-logging/
│   ├── bookstack-event-logger.py
│   ├── para-system.py (NEW)
│   ├── cross-platform-linker.py (NEW)
│   ├── paperless-para-system.py (NEW)
│   └── platform-sync-service.py (NEW)
│
├── websocket-server/
│   └── realtime-events.py
│
├── dashboard/
│   ├── index.html (dashboard UI)
│   └── system-map.html (architecture diagram)
│
├── security/
│   ├── 1password-setup.sh
│   └── 1PASSWORD_QUICK_START.md
│
├── COMPLETE_SETUP_GUIDE.md
├── SYSTEM_ARCHITECTURE_CHART.md
└── CROSS_PLATFORM_LINKING_SETUP.md (NEW)
```

### Git Status

```bash
# Current branch
git branch  # claude/mcp-filesystem-crash-loop-nt1h0b

# Recent commits
git log --oneline -5
# 3d35b96 Add cross-platform linking with unified para system
# (previous system setup commits)

# All changes committed and pushed
git status  # working tree clean
```

---

## What Needs to Be Done

### Phase 1: Configuration (IMMEDIATE)

1. **1Password Setup**
   ```bash
   sudo bash /home/user/.github/infrastructure/security/1password-setup.sh
   op signin
   # Create "Infrastructure" vault in 1Password app
   # Add items: Twilio, Bookstack, Paperless-NGX, Remote Executor, Raindrop, TickTick, Craft
   ```

2. **API Credentials**
   - [ ] Twilio: Account SID, Auth Token, Phone Number, Recipient (+1.718.208.3290)
   - [ ] Bookstack: Base URL, API Token, API Secret
   - [ ] Paperless-NGX: URL, API Token
   - [ ] Craft Docs: API Token, User ID
   - [ ] TickTick: API Token
   - [ ] Raindrop.io: API Token

3. **Environment Variables**
   ```bash
   # Load from 1Password
   eval "$(load-1password-env)"
   
   # Or set manually for testing
   export BOOKSTACK_URL="http://localhost:8000"
   export BOOKSTACK_API_TOKEN="..."
   export PAPERLESS_URL="http://localhost:8080"
   export PAPERLESS_TOKEN="..."
   ```

### Phase 2: Testing (THIS WEEK)

1. **Para System Testing**
   ```bash
   cd /home/user/.github/infrastructure/event-logging
   
   # Generate para code
   python3 para-system.py generate invoice "Test invoice"
   # Should return: 260705-0001
   
   # Check info
   python3 para-system.py info 260705-0001
   
   # List by category
   python3 para-system.py list invoice
   ```

2. **Bookstack Integration**
   ```bash
   # Test event logging
   eval "$(get-bookstack-creds)"
   python3 bookstack-event-logger.py backup '{"size":"2.4GB","duration":"45min"}'
   # Check Bookstack for logged event
   ```

3. **Cross-Platform Linking**
   ```bash
   # Manual test
   python3 -c "
   from cross_platform_linker import CrossPlatformLinker
   linker = CrossPlatformLinker()
   
   # Test with para code
   para_code = '260705-0001'
   bookstack = linker.create_bookstack_item('Test Item', 'Content', para_code=para_code)
   print(bookstack)
   "
   ```

4. **Paperless Integration**
   ```bash
   # Test with sample document
   python3 -c "
   from paperless_para_system import PaperlessPara
   paperless = PaperlessPara()
   
   result = paperless.upload_document_with_para(
       file_path='/tmp/test.pdf',
       title='Test',
       category='document'
   )
   print(result)
   "
   ```

5. **Sync Service**
   ```bash
   # Test sync (one-time)
   python3 platform-sync-service.py
   
   # Check report
   python3 platform-sync-service.py --report
   
   # Install as service
   sudo python3 platform-sync-service.py --install
   sudo systemctl start platform-sync.service
   sudo journalctl -u platform-sync.service -f
   ```

### Phase 3: Deployment (NEXT WEEK)

1. **Start All Services**
   ```bash
   # 1. Twilio SMS
   eval "$(get-twilio-creds)"
   send-sms "System startup test"
   
   # 2. WebSocket server
   sudo systemctl start realtime-events.service
   
   # 3. Dashboard
   cd /home/user/.github/infrastructure/dashboard
   python3 -m http.server 8000
   
   # 4. Platform sync
   sudo systemctl start platform-sync.service
   ```

2. **Test End-to-End**
   - [ ] Generate para code
   - [ ] Create item on all 5 platforms
   - [ ] Verify cross-platform links exist
   - [ ] Check sync service logs
   - [ ] Access dashboard
   - [ ] Test SMS notification
   - [ ] Check Bookstack events

3. **Deploy iOS Automation**
   - [ ] Copy `file-management.js` to Scriptable.app
   - [ ] Copy `pdf-paperless.js` to Scriptable.app
   - [ ] Create iOS Shortcuts linking to scripts
   - [ ] Test file upload to Bookstack
   - [ ] Test PDF to Paperless

---

## Current Issues (from VPS testing)

### Issue 1: File Paths
- **Problem:** Scripts run from wrong directory (`/root/` instead of `/home/user/.github/infrastructure/event-logging/`)
- **Solution:** Always run from correct directory:
  ```bash
  cd /home/user/.github/infrastructure/event-logging
  python3 para-system.py ...
  ```

### Issue 2: 1Password Environment
- **Problem:** `load-1password-env: command not found`
- **Solution:** Run 1Password setup first:
  ```bash
  sudo bash /home/user/.github/infrastructure/security/1password-setup.sh
  op signin
  ```

### Issue 3: Module Imports
- **Problem:** Cross-platform scripts import each other (para_system, etc.)
- **Solution:** Ensure all scripts in same directory and Python path is set

---

## Key Concepts

### Para System (YYMMDD-XXXX)
- **Format:** 260705-0001, 260705-0002, etc.
- **Storage:** `/var/lib/para-codes/generated-codes.json`
- **Usage:** Single code per item across all 5 platforms
- **Benefits:** Unified reference, easy searching, automatic linking

### Platform Integration Points
```
Bookstack:    Pages with para code in title + HTML links section
Craft Docs:   Blocks with para code metadata + markdown links
TickTick:     Tasks with para code in title + description links
Raindrop.io:  Bookmarks with para code in title + description
Paperless:    Documents with para code as tag + correspondent + document type + notes
```

### Sync Service
- **Runs every 5 minutes** (in watch mode)
- **Auto-creates missing platform entries** for codes
- **Updates all cross-platform links** automatically
- **Logs to:** `/var/log/platform-sync/sync-*.log`
- **State file:** `/var/log/platform-sync/platform-sync-state.json`

---

## Critical Credentials (Store in 1Password)

**Vault Name:** Infrastructure

**Items needed:**
1. Twilio (Account SID, Auth Token, Phone Number, Recipient)
2. Bookstack (Base URL, API Token, API Secret)
3. Paperless-NGX (URL, API Token)
4. Craft Docs (API Token, User ID)
5. TickTick (API Token)
6. Raindrop.io (API Token)
7. Remote Executor (API URL, API Key, Port)

**Never commit credentials to git!** Use 1Password vault instead.

---

## Testing Checklist

### Unit Tests
- [ ] Para code generation (generates unique codes)
- [ ] Para code retrieval (stores and retrieves correctly)
- [ ] Bookstack API connectivity
- [ ] Paperless API connectivity
- [ ] Craft Docs API connectivity
- [ ] TickTick API connectivity
- [ ] Raindrop API connectivity

### Integration Tests
- [ ] Create item on Bookstack with para code
- [ ] Create item on Craft with same para code
- [ ] Create task on TickTick with same para code
- [ ] Create bookmark on Raindrop with same para code
- [ ] Upload document to Paperless with para code
- [ ] Verify all 5 platforms have cross-platform links

### End-to-End Tests
- [ ] Para system generates code
- [ ] Code registered on all platforms
- [ ] Links created bidirectionally
- [ ] Sync service updates missing platforms
- [ ] Event logging works
- [ ] SMS notifications fire
- [ ] Dashboard updates in real-time

---

## How to Continue

1. **Understand the Architecture**
   - Read: `COMPLETE_SETUP_GUIDE.md`
   - Read: `SYSTEM_ARCHITECTURE_CHART.md`
   - Read: `CROSS_PLATFORM_LINKING_SETUP.md`

2. **Configure 1Password**
   - Run: `sudo bash /home/user/.github/infrastructure/security/1password-setup.sh`
   - Create vault and add credentials

3. **Test Para System**
   - Navigate: `cd /home/user/.github/infrastructure/event-logging`
   - Run: `python3 para-system.py generate test "Test"`
   - Check: `python3 para-system.py info <code>`

4. **Test Each Platform**
   - Start with Bookstack (simplest API)
   - Move to Paperless (requires document files)
   - Test cross-platform linking

5. **Deploy Services**
   - Install systemd services one by one
   - Test each service independently
   - Then test integration

6. **Monitor & Debug**
   - Watch service logs: `sudo journalctl -u platform-sync.service -f`
   - Check para code storage: `cat /var/lib/para-codes/generated-codes.json`
   - Review sync state: `cat /var/log/platform-sync/platform-sync-state.json`

---

## Documentation

| Document | Purpose |
|----------|---------|
| `COMPLETE_SETUP_GUIDE.md` | Full system setup (Twilio, iOS, Dashboard, Bookstack, WebSocket) |
| `SYSTEM_ARCHITECTURE_CHART.md` | System architecture, services, networking, APIs |
| `CROSS_PLATFORM_LINKING_SETUP.md` | Para system, cross-platform linking, installation |
| `1PASSWORD_QUICK_START.md` | 1Password CLI usage for credentials |

---

## Contact Points

- **Main branch:** `claude/mcp-filesystem-crash-loop-nt1h0b`
- **VPS IP:** 72.61.74.250
- **SMS recipient:** +1.718.208.3290
- **User email:** sjlove@shannonjeffreylove.com

---

## Success Criteria

System is ready for production when:

1. ✅ All credentials configured in 1Password vault
2. ✅ Para system generates and tracks codes correctly
3. ✅ Items can be created on all 5 platforms with same code
4. ✅ Cross-platform links are bidirectional and working
5. ✅ Sync service runs continuously without errors
6. ✅ SMS notifications send successfully
7. ✅ iOS scripts execute and upload files
8. ✅ Dashboard displays real-time updates
9. ✅ Bookstack logs all events correctly
10. ✅ Paperless documents are tagged with para codes

---

**Ready for next session!** 🚀

All code committed to `claude/mcp-filesystem-crash-loop-nt1h0b` and pushed to remote.
