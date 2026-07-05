#!/usr/bin/env python3
"""
Six-Digit Para System Code Generator
Generates unique hierarchical codes for cross-platform document organization

Format: YYMMDD-XXXX
- YYMMDD: Date component (year-month-day)
- XXXX: Sequential 4-digit counter per day (0001-9999)

Example: 260705-0001, 260705-0002, etc.
"""

import os
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Tuple

class ParaSystemCodeGenerator:
    def __init__(self, storage_dir: str = "/var/lib/para-codes"):
        """Initialize para system with persistent storage"""
        self.storage_dir = Path(storage_dir)
        self.storage_dir.mkdir(parents=True, exist_ok=True)
        self.codes_file = self.storage_dir / "generated-codes.json"
        self.counters_file = self.storage_dir / "daily-counters.json"
        self._load_data()

    def _load_data(self):
        """Load existing codes and counters"""
        self.codes = {}
        self.counters = {}

        if self.codes_file.exists():
            with open(self.codes_file) as f:
                self.codes = json.load(f)

        if self.counters_file.exists():
            with open(self.counters_file) as f:
                self.counters = json.load(f)

    def _save_data(self):
        """Persist codes and counters"""
        with open(self.codes_file, 'w') as f:
            json.dump(self.codes, f, indent=2)
        with open(self.counters_file, 'w') as f:
            json.dump(self.counters, f, indent=2)

    def generate_code(self, category: str = "general", description: str = "") -> str:
        """
        Generate new para system code

        Args:
            category: Document category (general, backup, file, pdf, invoice, etc.)
            description: Optional description for reference

        Returns:
            Unique code in format YYMMDD-XXXX
        """
        now = datetime.now()
        date_part = now.strftime("%y%m%d")

        # Get current counter for this date
        if date_part not in self.counters:
            self.counters[date_part] = 0

        self.counters[date_part] += 1
        counter = self.counters[date_part]

        if counter > 9999:
            raise ValueError(f"Daily counter exceeded for {date_part}")

        # Generate code
        code = f"{date_part}-{counter:04d}"

        # Store metadata
        self.codes[code] = {
            "generated_at": now.isoformat(),
            "category": category,
            "description": description,
            "date": date_part,
            "sequence": counter,
            "platforms": {}  # Will track where this code is used
        }

        self._save_data()
        return code

    def register_code_usage(self, code: str, platform: str, reference_id: str,
                          url: str = ""):
        """
        Register where a code is being used

        Args:
            code: The para system code
            platform: Where it's being used (bookstack, craft, ticktick, raindrop, paperless)
            reference_id: ID in that platform
            url: Direct link to item in platform
        """
        if code not in self.codes:
            raise ValueError(f"Code {code} not found")

        self.codes[code]["platforms"][platform] = {
            "reference_id": reference_id,
            "url": url,
            "registered_at": datetime.now().isoformat()
        }

        self._save_data()

    def get_code_info(self, code: str) -> Dict:
        """Get full information about a code and its cross-platform locations"""
        if code not in self.codes:
            return None

        return self.codes[code]

    def list_codes_by_category(self, category: str):
        """List all codes for a specific category"""
        return {
            code: info for code, info in self.codes.items()
            if info.get("category") == category
        }

    def get_daily_codes(self, date_str: str = None):
        """Get all codes generated on a specific date (format: YYMMDD)"""
        if not date_str:
            date_str = datetime.now().strftime("%y%m%d")

        return {
            code: info for code, info in self.codes.items()
            if info.get("date") == date_str
        }

    def create_cross_reference(self, code: str) -> Dict:
        """Create a cross-reference object for linking across platforms"""
        if code not in self.codes:
            return None

        info = self.codes[code]
        links = {}

        for platform, details in info.get("platforms", {}).items():
            links[platform] = {
                "name": self._platform_name(platform),
                "url": details.get("url"),
                "reference": details.get("reference_id")
            }

        return {
            "code": code,
            "category": info.get("category"),
            "description": info.get("description"),
            "created": info.get("generated_at"),
            "platforms": links
        }

    def _platform_name(self, platform: str) -> str:
        """Get human-readable platform name"""
        names = {
            "bookstack": "Bookstack",
            "craft": "Craft Docs",
            "ticktick": "TickTick",
            "raindrop": "Raindrop.io",
            "paperless": "Paperless-NGX"
        }
        return names.get(platform, platform)


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    import sys

    generator = ParaSystemCodeGenerator()

    if len(sys.argv) < 2:
        print("Usage: python3 para-system.py <command> [args]")
        print("\nCommands:")
        print("  generate <category> [description]  - Generate new code")
        print("  info <code>                        - Get code information")
        print("  register <code> <platform> <ref>   - Register code usage")
        print("  list <category>                    - List codes by category")
        print("  daily [YYMMDD]                     - Get today's codes")
        sys.exit(1)

    command = sys.argv[1]

    if command == "generate":
        category = sys.argv[2] if len(sys.argv) > 2 else "general"
        description = sys.argv[3] if len(sys.argv) > 3 else ""
        code = generator.generate_code(category, description)
        print(f"Generated: {code}")

    elif command == "info":
        code = sys.argv[2]
        info = generator.get_code_info(code)
        if info:
            print(json.dumps(info, indent=2))
        else:
            print(f"Code {code} not found")

    elif command == "register":
        code = sys.argv[2]
        platform = sys.argv[3]
        ref = sys.argv[4]
        url = sys.argv[5] if len(sys.argv) > 5 else ""
        generator.register_code_usage(code, platform, ref, url)
        print(f"Registered {code} on {platform}")

    elif command == "list":
        category = sys.argv[2] if len(sys.argv) > 2 else "general"
        codes = generator.list_codes_by_category(category)
        print(json.dumps(codes, indent=2))

    elif command == "daily":
        date = sys.argv[2] if len(sys.argv) > 2 else None
        codes = generator.get_daily_codes(date)
        print(json.dumps(codes, indent=2))
