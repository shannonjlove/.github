# Cross-Platform Linking & Para System Setup

Bidirectional linking across Bookstack, Craft Docs, TickTick, Raindrop.io, and Paperless-NGX with unified six-digit para system code organization.

---

## Overview

The para system assigns unique six-digit codes to all items across platforms:

**Format: YYMMDD-XXXX**
- `YYMMDD` - Date component (year-month-day)
- `XXXX` - Sequential counter per day (0001-9999)

**Example codes:**
- `260705-0001` - First item created on July 5, 2026
- `260705-0042` - 42nd item created on July 5, 2026
- `260706-0001` - First item created on July 6, 2026

Every item created across all platforms gets the same para code, enabling instant cross-platform linking.

---

## Architecture

### 1. Para System Code Generator (`para-system.py`)
Generates and manages unique para codes with persistent storage.

**Features:**
- Generates YYMMDD-XXXX codes
- Tracks where each code is used (which platforms)
- Stores metadata (category, description, creation time)
- Persists to `/var/lib/para-codes/`

**Usage:**
```bash
# Generate new code
python3 para-system.py generate invoice "Monthly invoice from vendor"
# Output: 260705-0001

# Get code information (all cross-platform references)
python3 para-system.py info 260705-0001

# Register code usage (automatically done by other systems)
python3 para-system.py register 260705-0001 bookstack page-123 http://...

# List codes by category
python3 para-system.py list invoice

# Get today's codes
python3 para-system.py daily
```

### 2. Cross-Platform Linker (`cross-platform-linker.py`)
Creates and maintains bidirectional links across all platforms.

**Features:**
- Create items on Bookstack, Craft, TickTick, Raindrop, Paperless with same para code
- Automatically registers code usage
- Updates items with cross-platform links
- Maintains bidirectional references

**Methods:**
- `create_bookstack_item()` - Create in Bookstack with para code
- `create_craft_item()` - Create in Craft Docs with para code
- `create_ticktick_task()` - Create in TickTick with para code
- `create_raindrop_item()` - Create in Raindrop.io with para code
- `create_bidirectional_links()` - Link all platforms with same code

**Example:**
```python
from cross_platform_linker import CrossPlatformLinker

linker = CrossPlatformLinker()

# Create item on all platforms with same para code
para_code = "260705-0001"
bookstack = linker.create_bookstack_item("Invoice", "Details...", para_code=para_code)
craft = linker.create_craft_item("Invoice", "Details...", para_code=para_code)
ticktick = linker.create_ticktick_task("Invoice", "Details...", para_code=para_code)
raindrop = linker.create_raindrop_item("Invoice", "http://...", para_code=para_code)

# Create bidirectional links
links = linker.create_bidirectional_links(para_code)
```

### 3. Paperless-NGX Para System (`paperless-para-system.py`)
Organizes documents in Paperless using para system codes.

**Integration Points:**
- **Tags**: Full para code + category tags + date components
- **Correspondent**: Automatically set based on category
- **Document Type**: Automatically set based on category
- **Notes**: Stores para code metadata and cross-platform links

**Tag Structure:**
```
[260705-0001]  - Full para code (searchable)
[invoice]      - Category
[260705]       - Date component
[2026]         - Year
[Month-07]     - Month
[custom-tag]   - User-provided tags
```

**Document Type Mapping:**
```
invoice    → Invoice
receipt    → Receipt
contract   → Contract
document   → Document
backup     → Archive
file       → File
pdf        → Document
general    → Miscellaneous
```

**Correspondent Mapping:**
```
invoice    → [PARA] Finance
receipt    → [PARA] Expenses
contract   → [PARA] Legal
document   → [PARA] Administrative
backup     → [PARA] System
file       → [PARA] Archive
pdf        → [PARA] Library
```

**Usage:**
```python
from paperless_para_system import PaperlessPara

paperless = PaperlessPara()

# Upload document with full para system integration
result = paperless.upload_document_with_para(
    file_path="/path/to/invoice.pdf",
    title="Vendor Invoice",
    category="invoice",
    para_code="260705-0001",  # Optional - generated if not provided
    additional_tags=["vendor-acme", "Q3-2026"]
)

# Result contains:
# - para_code: 260705-0001
# - document_id: 123
# - tags: [260705-0001, invoice, 260705, 2026, Month-07, vendor-acme, Q3-2026]
# - correspondent_id: 1
# - document_type_id: 2
# - url: http://paperless/documents/123
```

### 4. Platform Sync Service (`platform-sync-service.py`)
Real-time bidirectional synchronization daemon.

**Features:**
- Monitors all platforms for changes
- Creates missing platform entries automatically
- Updates cross-platform links continuously
- Maintains sync state and history
- Generates sync reports

**Run Modes:**
```bash
# One-time sync
python3 platform-sync-service.py

# Watch daemon (runs continuously, syncs every 5 minutes)
python3 platform-sync-service.py --watch

# Generate sync report
python3 platform-sync-service.py --report

# Install as systemd service
python3 platform-sync-service.py --install
```

**Sync Process:**
1. Detects codes that aren't synced across all 5 platforms
2. For each missing platform:
   - Extracts item data from existing platform
   - Creates entry on missing platform with same para code
   - Registers usage in para system
3. Updates all platforms with cross-platform links
4. Marks code as fully synced
5. Repeats every 5 minutes (in watch mode)

---

## Setup Instructions

### Prerequisites

```bash
# Install Python dependencies
pip3 install requests aiohttp

# Ensure 1Password credentials are loaded
eval "$(load-1password-env)"

# Or load individually
eval "$(get-bookstack-creds)"
eval "$(get-paperless-creds)"
```

### Environment Variables

```bash
# Bookstack
export BOOKSTACK_URL="http://localhost:8000"
export BOOKSTACK_API_TOKEN="your-token"
export BOOKSTACK_API_SECRET="your-secret"

# Craft Docs
export CRAFT_API_TOKEN="your-craft-token"
export CRAFT_USER_ID="your-user-id"

# TickTick
export TICKTICK_API_TOKEN="your-ticktick-token"

# Raindrop.io
export RAINDROP_API_TOKEN="your-raindrop-token"

# Paperless-NGX
export PAPERLESS_URL="http://localhost:8080"
export PAPERLESS_TOKEN="your-paperless-token"
```

### Installation

1. **Copy files to infrastructure directory:**
```bash
cp para-system.py /home/user/.github/infrastructure/event-logging/
cp cross-platform-linker.py /home/user/.github/infrastructure/event-logging/
cp paperless-para-system.py /home/user/.github/infrastructure/event-logging/
cp platform-sync-service.py /home/user/.github/infrastructure/event-logging/
```

2. **Make executable:**
```bash
chmod +x /home/user/.github/infrastructure/event-logging/*.py
```

3. **Create storage directory for para codes:**
```bash
sudo mkdir -p /var/lib/para-codes
sudo mkdir -p /var/log/platform-sync
sudo chown $USER:$USER /var/lib/para-codes /var/log/platform-sync
```

4. **Install systemd service:**
```bash
sudo python3 /home/user/.github/infrastructure/event-logging/platform-sync-service.py --install
```

5. **Start the sync service:**
```bash
sudo systemctl start platform-sync.service
sudo systemctl status platform-sync.service
sudo journalctl -u platform-sync.service -f
```

---

## Usage Examples

### Create Fully Linked Item

```python
from para_system import ParaSystemCodeGenerator
from cross_platform_linker import CrossPlatformLinker
from paperless_para_system import PaperlessPara

# Initialize systems
para_gen = ParaSystemCodeGenerator()
linker = CrossPlatformLinker()
paperless = PaperlessPara()

# Generate para code
title = "Q3 Quarterly Report"
para_code = para_gen.generate_code("document", title)

# Create on Bookstack
bookstack = linker.create_bookstack_item(
    title=title,
    content="Full quarterly report content...",
    para_code=para_code
)

# Create on Craft Docs
craft = linker.create_craft_item(
    title=title,
    content="Full quarterly report content...",
    para_code=para_code
)

# Create as TickTick task
ticktick = linker.create_ticktick_task(
    title=title,
    description="Review and distribute quarterly report",
    para_code=para_code
)

# Create as Raindrop bookmark
raindrop = linker.create_raindrop_item(
    title=title,
    url="http://example.com/quarterly-report",
    description="Q3 Quarterly Report",
    para_code=para_code
)

# Create in Paperless (if document exists)
paperless_result = paperless.upload_document_with_para(
    file_path="/path/to/report.pdf",
    title=title,
    category="document",
    para_code=para_code,
    additional_tags=["Q3-2026", "quarterly"]
)

# Create bidirectional links across all platforms
links = linker.create_bidirectional_links(para_code)

print(f"Created item {para_code} on all platforms!")
print(f"Links: {links}")
```

### Check Para Code Status

```bash
# Get all information about a code
python3 para-system.py info 260705-0001

# Output:
# {
#   "generated_at": "2026-07-05T10:30:45.123456",
#   "category": "document",
#   "description": "Q3 Quarterly Report",
#   "date": "260705",
#   "sequence": 1,
#   "platforms": {
#     "bookstack": {
#       "reference_id": "page-456",
#       "url": "http://localhost:8000/pages/456",
#       "registered_at": "2026-07-05T10:30:46.123456"
#     },
#     "craft": {
#       "reference_id": "doc-789",
#       "url": "https://craft.do/docs/document/789",
#       "registered_at": "2026-07-05T10:30:47.123456"
#     },
#     ...
#   }
# }
```

### View Sync Status

```bash
# Get sync report
python3 platform-sync-service.py --report

# Output shows:
# - Which codes are fully synced
# - Which codes need syncing
# - Platform coverage statistics
# - Last sync time
```

### Find Items Across Platforms

```bash
# By para code
python3 para-system.py info 260705-0001

# By category
python3 para-system.py list invoice

# By date
python3 para-system.py daily  # Today's items
python3 para-system.py daily 260704  # July 4, 2026
```

---

## Cross-Platform Link Format

Each item shows links to all other platforms:

**In Bookstack:**
```html
<div class="cross-platform-links">
  <h4>Related Items [260705-0001]:</h4>
  <ul>
    <li><a href="https://craft.do/docs/...">Craft Docs</a></li>
    <li><a href="https://www.ticktick.com/tasks/...">TickTick</a></li>
    <li><a href="https://raindrop.io/...">Raindrop.io</a></li>
    <li><a href="http://localhost:8080/documents/...">Paperless-NGX</a></li>
  </ul>
</div>
```

**In Paperless-NGX:**
```
Notes: Para Code: 260705-0001
Category: document
Description: Q3 Quarterly Report

Cross-Platform Links:
- Bookstack: http://localhost:8000/pages/456
- Craft Docs: https://craft.do/docs/789
- TickTick: https://www.ticktick.com/tasks/abc123
- Raindrop.io: https://raindrop.io/item/xyz789
```

---

## API Keys & Credentials

### Bookstack
1. Admin Panel → API Tokens
2. Create token with permissions
3. Note: Token ID (username) + Secret (password)

### Craft Docs
1. Settings → Integrations
2. Create API token
3. Get User ID from profile

### TickTick
1. Settings → Integrations → API
2. Create API token
3. Requires enterprise account

### Raindrop.io
1. Settings → Connections → Create app
2. Authorize and get token
3. Store in 1Password

### Paperless-NGX
1. Admin → API tokens
2. Create token
3. Copy token value

**Store all in 1Password vault "Infrastructure"**

---

## Troubleshooting

### Sync service not connecting to platform

```bash
# Check if credentials are loaded
echo $BOOKSTACK_URL
echo $BOOKSTACK_API_TOKEN

# Test Bookstack connectivity
curl -H "Authorization: Token $BOOKSTACK_API_TOKEN:$BOOKSTACK_API_SECRET" \
  http://localhost:8000/api/shelves

# Check service logs
sudo journalctl -u platform-sync.service -f
```

### Para codes not syncing across platforms

```bash
# Check sync state
cat /var/log/platform-sync/platform-sync-state.json

# Force resync
python3 platform-sync-service.py

# Check individual code
python3 para-system.py info 260705-0001
```

### Paperless document upload failing

```bash
# Check API access
curl -H "Authorization: Token $PAPERLESS_TOKEN" \
  http://localhost:8080/api/documents/

# Test upload
python3 -c "
from paperless_para_system import PaperlessPara
p = PaperlessPara()
result = p.upload_document_with_para('/tmp/test.pdf', 'Test')
print(result)
"
```

---

## Monitoring

```bash
# Watch sync service
sudo journalctl -u platform-sync.service -f

# Monitor para code generation
tail -f /var/log/platform-sync/sync-*.log

# Check daily sync report
python3 platform-sync-service.py --report > /tmp/sync-report.txt
cat /tmp/sync-report.txt
```

---

## Next Steps

1. ✅ Set up 1Password credentials
2. ✅ Install para system code generator
3. ✅ Configure cross-platform linker with API keys
4. ✅ Deploy Paperless para system integration
5. ✅ Start platform sync service
6. ✅ Test cross-platform linking workflow
7. ✅ Monitor sync status and logs

---

All systems now unified with automatic cross-platform linking! 🔗
