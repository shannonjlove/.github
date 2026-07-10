#!/usr/bin/env python3
"""
ChatGPT Custom Action Manager
Automates creation and management of ChatGPT Custom Actions for sjl-mcp-filesystem
"""

import json
import os
import sys
from dataclasses import dataclass
from typing import Optional

@dataclass
class CustomAction:
    name: str = "SJL MCP Filesystem"
    description: str = "Read and write files with automatic backups"
    server_url: str = "https://72.61.74.250:8813"
    bearer_token: str = ""

    @classmethod
    def from_env(cls):
        """Create CustomAction from environment variables"""
        return cls(
            bearer_token=os.getenv('SJL_WRITE_TOKEN', '')
        )

    def to_config(self) -> dict:
        """Convert to ChatGPT configuration format"""
        return {
            "name": self.name,
            "description": self.description,
            "server_url": self.server_url,
            "authentication": {
                "type": "bearer",
                "token": self.bearer_token
            },
            "tools": [
                "read_file",
                "write_file",
                "list_directory",
                "search_files",
                "get_file_info",
                "create_directory"
            ]
        }

    def validate(self) -> bool:
        """Validate configuration"""
        if not self.bearer_token:
            print("❌ Error: Bearer token not set")
            return False
        if not self.server_url.startswith('https://'):
            print("❌ Error: Server URL must use HTTPS")
            return False
        return True

    def test_connection(self) -> bool:
        """Test connection to MCP server"""
        try:
            import urllib.request
            req = urllib.request.Request(
                f"{self.server_url}/health",
                headers={"Authorization": f"Bearer {self.bearer_token}"}
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                return response.status == 200
        except Exception as e:
            print(f"❌ Connection failed: {e}")
            return False

    def save_config(self, filepath: str):
        """Save configuration to file"""
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            json.dump(self.to_config(), f, indent=2)
        print(f"✅ Configuration saved to {filepath}")

def main():
    print("ChatGPT Custom Action Manager")
    print("=" * 50)
    print()

    # Load configuration
    action = CustomAction.from_env()

    # Validate
    if not action.validate():
        sys.exit(1)

    # Test connection
    print("Testing connection to MCP server...")
    if action.test_connection():
        print("✅ Connection successful")
    else:
        print("⚠️  Connection test failed")

    # Save configuration
    config_path = os.path.expanduser("~/.chatgpt/actions/sjl-mcp-filesystem.json")
    action.save_config(config_path)

    # Display summary
    print()
    print("Configuration Summary:")
    print(f"  Action: {action.name}")
    print(f"  Server: {action.server_url}")
    print(f"  Tools: 6 available")
    print()
    print("Next steps:")
    print("  1. Go to ChatGPT Settings → Integrations → Actions")
    print("  2. Click 'Create new action'")
    print("  3. Paste the configuration")
    print("  4. Set Bearer token authentication")
    print("  5. Save and test")

if __name__ == "__main__":
    main()
