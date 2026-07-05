# Anthropic CLI Integration Guide
**Purpose:** Use Anthropic CLI with para system and platform synchronization  
**Date:** July 5, 2026

---

## Overview

Anthropic CLI enables direct access to Claude models from VPS and Oracle environments, providing:

- Unified AI access across all platforms
- Integration with para code system (YYMMDD-XXXX format)
- Batch processing and automation support
- Real-time API responses for sync service
- Command-line tool for scripts and services

---

## Setup Prerequisites

1. **Anthropic CLI installed** - See ANTHROPIC_CLI_INSTALLATION.md
2. **Go 1.26.4 installed** - See GO_INSTALLATION_GUIDE.md
3. **API key configured** - Available in 1Password Infrastructure vault
4. **Python 3.8+** - For script integration

---

## API Key Management

### Load API Key from 1Password

```bash
# Manually load key
export ANTHROPIC_API_KEY=$(op item get "Anthropic CLI" --vault Infrastructure --field api_key)

# Verify it's loaded
echo $ANTHROPIC_API_KEY | head -c 20
```

### Add to Shell Profile

```bash
# Edit ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# Anthropic CLI API Key
export ANTHROPIC_API_KEY="sk-ant-YOUR-API-KEY-HERE"
EOF

source ~/.bashrc
```

---

## Basic Usage

### List Available Models

```bash
anthropic models list

# Output:
# claude-3-5-sonnet-20241022
# claude-3-opus-20250219
# claude-3-5-haiku-20241022
```

### Send a Simple Message

```bash
anthropic message --model claude-3-5-sonnet \
  "Generate a para code for a test invoice"

# Output:
# Generated para code: 260705-0001
```

### With Options

```bash
anthropic message \
  --model claude-3-5-sonnet \
  --max-tokens 1024 \
  --temperature 0.5 \
  "Your prompt here"
```

### Get JSON Output

```bash
anthropic message \
  --model claude-3-5-sonnet \
  --output json \
  "Respond with valid JSON" | jq '.content[0].text'
```

---

## Integration with Para System

### Generate Para Code via CLI

```bash
# Generate a para code for an invoice
anthropic message --model claude-3-5-sonnet \
  "Generate a YYMMDD-XXXX format code for invoice dated $(date +%y%m%d)"

# Use the output to create a para code
PARA_CODE=$(anthropic message --model claude-3-5-sonnet \
  "Generate only a YYMMDD-XXXX para code for invoice: 260705-" \
  | grep -oE "[0-9]{6}-[0-9]{4}")

echo "Generated para code: $PARA_CODE"
```

### Document Summarization

```bash
# Summarize a document using Claude
cat /path/to/document.txt | anthropic message --model claude-3-5-sonnet \
  "Summarize this document in 3 bullet points"
```

### Extract Structured Data

```bash
# Extract invoice details as JSON
anthropic message --model claude-3-5-sonnet --output json \
  'Extract invoice data from this text and return as JSON: {
    "invoice_number": "...",
    "amount": "...",
    "date": "..."
  }
  
  Text: Invoice #001 for $1,500 dated 2026-07-05'
```

---

## Python Integration

### Simple API Call

```python
#!/usr/bin/env python3
import subprocess
import json
import os

def call_anthropic(prompt, model="claude-3-5-sonnet", max_tokens=1024):
    """Call Anthropic CLI and return response text"""
    cmd = [
        "anthropic", "message",
        "--model", model,
        "--max-tokens", str(max_tokens),
        prompt
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        raise Exception(f"API error: {result.stderr}")
    
    return result.stdout.strip()

# Usage
response = call_anthropic("Generate a test para code")
print(response)
```

### JSON Response Parsing

```python
#!/usr/bin/env python3
import subprocess
import json

def call_anthropic_json(prompt, model="claude-3-5-sonnet"):
    """Call Anthropic CLI and parse JSON response"""
    cmd = [
        "anthropic", "message",
        "--model", model,
        "--output", "json",
        prompt
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        raise Exception(f"API error: {result.stderr}")
    
    response_json = json.loads(result.stdout)
    return response_json['content'][0]['text']

# Usage
response_text = call_anthropic_json(
    'Return JSON with keys "para_code", "category", "description"'
)
data = json.loads(response_text)
print(data)
```

### Batch Processing

```python
#!/usr/bin/env python3
import subprocess
import json
from datetime import datetime

def process_batch_documents(documents):
    """Process multiple documents with Claude"""
    results = []
    
    for doc in documents:
        cmd = [
            "anthropic", "message",
            "--model", "claude-3-5-sonnet",
            "--output", "json",
            f"Categorize this document and generate a para code: {doc}"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            response = json.loads(result.stdout)
            para_code = response['content'][0]['text']
            results.append({
                'document': doc,
                'para_code': para_code,
                'timestamp': datetime.now().isoformat()
            })
    
    return results

# Usage
documents = [
    "Invoice #001 for $1,500",
    "Receipt from office supplies",
    "Test document"
]

results = process_batch_documents(documents)
print(json.dumps(results, indent=2))
```

---

## Bash Integration

### Helper Function

```bash
# Add to ~/.bashrc

# Call Claude with a prompt
claude() {
    local prompt="${@:-}"
    if [ -z "$prompt" ]; then
        echo "Usage: claude 'Your prompt here'"
        return 1
    fi
    anthropic message --model claude-3-5-sonnet "$prompt"
}

# Call Claude and get JSON
claude-json() {
    local prompt="${@:-}"
    if [ -z "$prompt" ]; then
        echo "Usage: claude-json 'Your prompt here'"
        return 1
    fi
    anthropic message --model claude-3-5-sonnet --output json "$prompt"
}

# Generate a para code
generate-para-code() {
    local category="${1:-general}"
    local description="${2:-Test}"
    
    claude "Generate a YYMMDD-XXXX para code for category: $category, description: $description. Return only the code."
}

# Usage
# claude "What is a para code?"
# generate-para-code "invoice" "Monthly retainer"
```

### Pipeline Processing

```bash
#!/bin/bash

# Process directory of text files with Claude
process_documents() {
    local directory="$1"
    
    for file in "$directory"/*.txt; do
        [ -f "$file" ] || continue
        
        echo "Processing: $file"
        content=$(cat "$file")
        
        para_code=$(anthropic message --model claude-3-5-sonnet \
            "Generate para code for: $content")
        
        echo "$file -> $para_code"
    done
}

# Usage
process_documents /path/to/documents
```

---

## Sync Service Integration

### Use Anthropic CLI in Python Sync Service

```python
# In platform_sync_service.py

import subprocess
import json
from datetime import datetime

class AnthropicHelper:
    """Helper for Anthropic CLI calls"""
    
    @staticmethod
    def generate_para_code(category, description):
        """Generate a para code using Claude"""
        prompt = f"""Generate a YYMMDD-XXXX para code for:
        Category: {category}
        Description: {description}
        
        Return ONLY the code in format YYMMDD-XXXX"""
        
        cmd = [
            "anthropic", "message",
            "--model", "claude-3-5-sonnet",
            "--max-tokens", "50",
            prompt
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            return None
    
    @staticmethod
    def summarize_content(content, max_tokens=500):
        """Summarize content using Claude"""
        cmd = [
            "anthropic", "message",
            "--model", "claude-3-5-sonnet",
            "--max-tokens", str(max_tokens),
            f"Summarize: {content}"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            return None

# Usage in sync service
def sync_with_claude_enhancement():
    helper = AnthropicHelper()
    
    # Generate para codes for new documents
    para_code = helper.generate_para_code("receipt", "Office supplies")
    summary = helper.summarize_content("Document content here")
    
    return {
        'para_code': para_code,
        'summary': summary,
        'timestamp': datetime.now().isoformat()
    }
```

---

## Real-Time Dashboard Updates

### Stream Responses

```bash
#!/bin/bash

# Monitor para code generation
monitor_para_generation() {
    local watch_dir="/var/lib/para-codes"
    
    while true; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking para codes..."
        
        # Get latest codes
        tail -5 "$watch_dir/generated-codes.json" | jq '.[-1]'
        
        # Generate new code
        new_code=$(anthropic message --model claude-3-5-sonnet \
            "Generate a para code for: $(date)")
        
        echo "Latest: $new_code"
        
        sleep 60  # Check every minute
    done
}
```

---

## Error Handling

### Graceful Fallbacks

```python
#!/usr/bin/env python3
import subprocess
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def safe_anthropic_call(prompt, model="claude-3-5-sonnet", max_retries=3):
    """Call Anthropic CLI with error handling and retries"""
    
    for attempt in range(max_retries):
        try:
            cmd = [
                "anthropic", "message",
                "--model", model,
                "--max-tokens", "1024",
                prompt
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                return result.stdout.strip()
            else:
                logger.warning(f"API error (attempt {attempt+1}): {result.stderr}")
                
        except subprocess.TimeoutExpired:
            logger.warning(f"Timeout (attempt {attempt+1})")
        except Exception as e:
            logger.error(f"Error (attempt {attempt+1}): {e}")
        
        if attempt < max_retries - 1:
            # Exponential backoff
            import time
            time.sleep(2 ** attempt)
    
    logger.error(f"Failed after {max_retries} attempts")
    return None

# Usage
response = safe_anthropic_call("Generate a para code")
if response:
    print(response)
else:
    print("Failed to get response from Claude")
```

---

## Security Best Practices

### Environment Variable Security

```bash
# Use separate profiles for sensitive operations
export ANTHROPIC_API_KEY="sk-ant-..."
export HISTCONTROL=ignorespace  # Don't save commands with leading space

# Secure the key
(  # Note: leading space prevents history recording
 anthropic message --model claude-3-5-sonnet "test"
)

# Verify key is set but don't print full value
echo "API key configured: $(echo $ANTHROPIC_API_KEY | head -c 20)..."
```

### File Permissions

```bash
# Create config directory with restricted permissions
mkdir -p ~/.anthropic
chmod 700 ~/.anthropic

# Store config securely
cat > ~/.anthropic/config.json << 'EOF'
{
  "api_key": "sk-ant-...",
  "default_model": "claude-3-5-sonnet"
}
EOF

chmod 600 ~/.anthropic/config.json
```

---

## Testing and Verification

### Test API Connectivity

```bash
#!/bin/bash

test_anthropic_api() {
    echo "Testing Anthropic CLI API..."
    
    # Test 1: Version
    if anthropic --version &>/dev/null; then
        echo "✓ Anthropic CLI installed"
    else
        echo "✗ Anthropic CLI not found"
        return 1
    fi
    
    # Test 2: Models
    if anthropic models list &>/dev/null; then
        echo "✓ API authentication working"
    else
        echo "✗ API authentication failed"
        return 1
    fi
    
    # Test 3: Simple message
    response=$(anthropic message --model claude-3-5-sonnet "test" 2>/dev/null)
    if [ -n "$response" ]; then
        echo "✓ Message API working"
        echo "  Response: ${response:0:50}..."
    else
        echo "✗ Message API failed"
        return 1
    fi
    
    echo "All tests passed!"
    return 0
}

# Run tests
test_anthropic_api
```

---

## Troubleshooting

### Common Issues

**"anthropic: command not found"**
```bash
# Check installation
ls -la /usr/local/bin/anthropic
echo $PATH

# Add to PATH if needed
export PATH=/usr/local/bin:$PATH
```

**"API key not found"**
```bash
# Verify key is set
echo $ANTHROPIC_API_KEY

# If empty, configure it
export ANTHROPIC_API_KEY="sk-ant-..."
```

**"Model not found"**
```bash
# List available models
anthropic models list

# Use correct model name
anthropic message --model claude-3-5-sonnet "test"
```

---

## Next Steps

1. **Install Anthropic CLI** - Run ANTHROPIC_CLI_SETUP.sh
2. **Configure API Key** - Use 1Password or environment variable
3. **Test with para system** - Generate YYMMDD-XXXX codes
4. **Integrate with sync service** - Add Claude enhancement
5. **Deploy to both environments** - VPS and Oracle

---

**Ready to integrate Anthropic CLI!** 🚀

Use these guides to connect Claude API with your para system and platform synchronization.
