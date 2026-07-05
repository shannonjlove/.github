#!/usr/bin/env python3
"""
Platform Sync Service
Real-time bidirectional synchronization between all five platforms
Monitors for changes and propagates para code links across platforms
"""

import os
import json
import asyncio
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional
import aiohttp
from para_system import ParaSystemCodeGenerator
from cross_platform_linker import CrossPlatformLinker
from paperless_para_system import PaperlessPara

class PlatformSyncService:
    def __init__(self):
        """Initialize sync service"""
        self.para_gen = ParaSystemCodeGenerator()
        self.linker = CrossPlatformLinker()
        self.paperless = PaperlessPara()

        self.sync_log = Path("/var/log/platform-sync")
        self.sync_log.mkdir(parents=True, exist_ok=True)

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.sync_log / f"sync-{datetime.now().strftime('%Y-%m-%d')}.log"),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)

        # Sync state tracking
        self.sync_state = self._load_sync_state()

    def _load_sync_state(self) -> Dict:
        """Load last sync state"""
        state_file = self.sync_log.parent / "platform-sync-state.json"
        if state_file.exists():
            with open(state_file) as f:
                return json.load(f)
        return {"last_sync": None, "synced_codes": {}}

    def _save_sync_state(self):
        """Persist sync state"""
        state_file = self.sync_log.parent / "platform-sync-state.json"
        with open(state_file, 'w') as f:
            json.dump(self.sync_state, f, indent=2)

    async def sync_all_platforms(self):
        """
        Main sync operation - check all platforms and create bidirectional links
        """
        self.logger.info("Starting platform sync...")

        try:
            # Get all para codes that need syncing
            codes_to_sync = self._get_codes_needing_sync()

            self.logger.info(f"Found {len(codes_to_sync)} codes needing sync")

            for para_code in codes_to_sync:
                await self._sync_code(para_code)

            self.sync_state["last_sync"] = datetime.now().isoformat()
            self._save_sync_state()

            self.logger.info("Platform sync completed")

        except Exception as e:
            self.logger.error(f"Sync error: {e}")

    def _get_codes_needing_sync(self) -> list:
        """Get codes that haven't been fully synced across platforms"""
        codes = []
        synced = self.sync_state.get("synced_codes", {})

        for code, info in self.para_gen.codes.items():
            platforms = set(info.get("platforms", {}).keys())

            # If not all 5 platforms, needs syncing
            if len(platforms) < 5:
                if code not in synced or synced[code].get("status") != "complete":
                    codes.append(code)

        return codes

    async def _sync_code(self, para_code: str):
        """
        Sync a specific para code across all platforms
        Creates missing platform entries and updates links
        """
        code_info = self.para_gen.get_code_info(para_code)
        if not code_info:
            return

        existing_platforms = set(code_info.get("platforms", {}).keys())
        all_platforms = {"bookstack", "craft", "ticktick", "raindrop", "paperless"}
        missing_platforms = all_platforms - existing_platforms

        self.logger.info(f"Syncing {para_code}: existing={existing_platforms}, missing={missing_platforms}")

        # For each missing platform, create entry from existing data
        for platform in missing_platforms:
            await self._create_missing_platform_entry(para_code, platform, code_info)

        # Update links on all platforms
        await self._update_all_platform_links(para_code)

        # Mark as synced
        self.sync_state["synced_codes"][para_code] = {
            "status": "complete",
            "synced_at": datetime.now().isoformat(),
            "platforms": list(all_platforms)
        }
        self._save_sync_state()

    async def _create_missing_platform_entry(self, para_code: str, platform: str,
                                             code_info: Dict):
        """
        Create entry on missing platform based on data from existing platform
        """
        try:
            title = code_info.get("description", f"Item {para_code}")
            category = code_info.get("category", "general")

            if platform == "bookstack":
                self.logger.info(f"Creating {para_code} on Bookstack...")
                result = self.linker.create_bookstack_item(title, "", para_code=para_code)

            elif platform == "craft":
                self.logger.info(f"Creating {para_code} on Craft...")
                result = self.linker.create_craft_item(title, "", para_code=para_code)

            elif platform == "ticktick":
                self.logger.info(f"Creating {para_code} on TickTick...")
                result = self.linker.create_ticktick_task(title, "", para_code=para_code)

            elif platform == "raindrop":
                self.logger.info(f"Creating {para_code} on Raindrop...")
                # Need a source URL for raindrop
                source_url = self._get_source_url(para_code, code_info)
                result = self.linker.create_raindrop_item(title, source_url, "", para_code=para_code)

            elif platform == "paperless":
                self.logger.info(f"Creating {para_code} on Paperless...")
                # Paperless requires actual document - would be handled separately
                return

            if result.get("success"):
                self.logger.info(f"✓ Created {para_code} on {platform}")
            else:
                self.logger.error(f"✗ Failed to create on {platform}: {result.get('error')}")

        except Exception as e:
            self.logger.error(f"Error creating on {platform}: {e}")

    async def _update_all_platform_links(self, para_code: str):
        """
        Update cross-platform links on all platforms for a code
        """
        try:
            self.logger.info(f"Updating links for {para_code} across all platforms...")
            result = self.linker.create_bidirectional_links(para_code)

            if result.get("success"):
                self.logger.info(f"✓ Updated links for {para_code}")
            else:
                self.logger.error(f"✗ Failed to update links: {result.get('error')}")

        except Exception as e:
            self.logger.error(f"Error updating links: {e}")

    def _get_source_url(self, para_code: str, code_info: Dict) -> str:
        """Get source URL from existing platform"""
        platforms = code_info.get("platforms", {})

        # Try to get URL from any existing platform
        for platform, details in platforms.items():
            url = details.get("url")
            if url:
                return url

        # Fallback
        return f"para://{para_code}"

    async def watch_platforms(self):
        """
        Continuous monitoring mode - watch for changes and sync
        Runs as long-running daemon
        """
        self.logger.info("Starting platform watch daemon...")

        while True:
            try:
                await self.sync_all_platforms()

                # Wait 5 minutes before next sync
                await asyncio.sleep(300)

            except Exception as e:
                self.logger.error(f"Watch error: {e}")
                await asyncio.sleep(60)

    def generate_sync_report(self) -> str:
        """Generate sync status report"""
        report = "# Platform Sync Report\n\n"
        report += f"Generated: {datetime.now().isoformat()}\n"
        report += f"Last Sync: {self.sync_state.get('last_sync', 'Never')}\n\n"

        report += "## Sync Status by Code\n"
        report += "| Code | Status | Platforms | Last Sync |\n"
        report += "|------|--------|-----------|----------|\n"

        for code, sync_info in self.sync_state.get("synced_codes", {}).items():
            platforms = len(sync_info.get("platforms", []))
            status = sync_info.get("status", "unknown")
            last_sync = sync_info.get("synced_at", "N/A")

            report += f"| {code} | {status} | {platforms}/5 | {last_sync[:10]} |\n"

        report += "\n## Codes Needing Sync\n"
        codes_needing = self._get_codes_needing_sync()
        if codes_needing:
            for code in codes_needing:
                info = self.para_gen.get_code_info(code)
                platforms = len(info.get("platforms", {}))
                report += f"- {code}: {platforms}/5 platforms\n"
        else:
            report += "All codes are synchronized!\n"

        report += "\n## Statistics\n"
        report += f"- Total codes: {len(self.para_gen.codes)}\n"
        report += f"- Fully synced: {sum(1 for s in self.sync_state.get('synced_codes', {}).values() if s.get('status') == 'complete')}\n"
        report += f"- Needs syncing: {len(codes_needing)}\n"

        return report


# ============================================================================
# Systemd Service Setup
# ============================================================================

SYSTEMD_SERVICE = """
[Unit]
Description=Platform Sync Service
After=network.target
Requires=realtime-events.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /home/user/.github/infrastructure/event-logging/platform-sync-service.py --watch
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
"""


# ============================================================================
# Main
# ============================================================================

async def main():
    import sys

    sync = PlatformSyncService()

    if len(sys.argv) > 1 and sys.argv[1] == "--watch":
        # Run as daemon
        await sync.watch_platforms()
    elif len(sys.argv) > 1 and sys.argv[1] == "--report":
        # Generate and print report
        report = sync.generate_sync_report()
        print(report)
    else:
        # Run one-time sync
        await sync.sync_all_platforms()


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "--install":
        # Install systemd service
        service_file = Path("/etc/systemd/system/platform-sync.service")
        with open(service_file, 'w') as f:
            f.write(SYSTEMD_SERVICE)
        print(f"Installed {service_file}")
        os.system("systemctl daemon-reload")
        os.system("systemctl enable platform-sync.service")
        print("Service enabled. Start with: systemctl start platform-sync.service")
    else:
        asyncio.run(main())
