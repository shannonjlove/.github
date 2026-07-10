#!/usr/bin/env python3
"""
Example Python client for SJL MCP Filesystem via ChatGPT Custom Actions

This demonstrates how to programmatically interact with the filesystem service
using the same API that ChatGPT Custom Actions would use.

Usage:
    python3 python-client-example.py --read /path/to/file
    python3 python-client-example.py --write /path/to/file "file content"
    python3 python-client-example.py --list /path/to/directory
    python3 python-client-example.py --search /path "pattern"
"""

import os
import json
import requests
import argparse
import sys
from typing import Any, Dict, Optional
from datetime import datetime


class MCPFilesystemClient:
    """Client for SJL MCP Filesystem service via HTTP API"""

    def __init__(
        self,
        host: str = "72.61.74.250",
        port: int = 8813,
        token: Optional[str] = None,
        verify_ssl: bool = True,
    ):
        """
        Initialize MCP Filesystem client.

        Args:
            host: Service hostname
            port: Service port
            token: Bearer token (or read from SJL_MCP_TOKEN env var)
            verify_ssl: Verify SSL certificate
        """
        self.host = host
        self.port = port
        self.base_url = f"https://{host}:{port}"
        self.endpoint = f"{self.base_url}/api/tools/call"

        # Get token from parameter or environment variable
        if token:
            self.token = token
        else:
            self.token = os.environ.get("SJL_MCP_TOKEN", "")

        if not self.token:
            raise ValueError(
                "Bearer token required. Set SJL_MCP_TOKEN env var or pass token parameter"
            )

        # Ensure token starts with "Bearer "
        if not self.token.startswith("Bearer "):
            self.token = f"Bearer {self.token}"

        self.verify_ssl = verify_ssl
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": self.token,
            "Content-Type": "application/json",
        })
        self.request_id = 0

    def _call_tool(self, tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """
        Call an MCP tool.

        Args:
            tool_name: Name of tool to call (read_file, write_file, etc.)
            arguments: Tool-specific arguments

        Returns:
            API response result

        Raises:
            Exception: On API error
        """
        self.request_id += 1

        payload = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": arguments,
            },
            "id": str(self.request_id),
        }

        try:
            response = self.session.post(
                self.endpoint,
                json=payload,
                verify=self.verify_ssl,
                timeout=30,
            )
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            raise Exception(f"API request failed: {e}")

        result = response.json()

        # Check for JSON-RPC error
        if "error" in result:
            error = result["error"]
            raise Exception(
                f"MCP Error {error.get('code')}: {error.get('message')} - "
                f"{error.get('data', {}).get('details', '')}"
            )

        return result.get("result", {})

    def read_file(
        self,
        path: str,
        encoding: str = "utf-8",
    ) -> str:
        """Read file content"""
        result = self._call_tool("read_file", {
            "path": path,
            "encoding": encoding,
        })
        return result.get("content", "")

    def write_file(
        self,
        path: str,
        content: str,
        mode: str = "644",
        create_dirs: bool = True,
        backup_existing: bool = True,
    ) -> Dict[str, Any]:
        """Write file content"""
        return self._call_tool("write_file", {
            "path": path,
            "content": content,
            "mode": mode,
            "create_dirs": create_dirs,
            "backup_existing": backup_existing,
        })

    def list_directory(
        self,
        path: str,
        recursive: bool = False,
        filter_pattern: Optional[str] = None,
    ) -> Dict[str, Any]:
        """List directory contents"""
        args = {
            "path": path,
            "recursive": recursive,
        }
        if filter_pattern:
            args["filter"] = filter_pattern
        return self._call_tool("list_directory", args)

    def search_files(
        self,
        path: str,
        pattern: str,
        search_type: str = "name",
        recursive: bool = True,
    ) -> Dict[str, Any]:
        """Search for files"""
        return self._call_tool("search_files", {
            "path": path,
            "pattern": pattern,
            "search_type": search_type,
            "recursive": recursive,
        })

    def get_file_info(self, path: str) -> Dict[str, Any]:
        """Get file metadata"""
        result = self._call_tool("get_file_info", {"path": path})
        return result.get("metadata", {})

    def delete_file(self, path: str, recursive: bool = False) -> Dict[str, Any]:
        """Delete file or directory"""
        return self._call_tool("delete_file", {
            "path": path,
            "recursive": recursive,
        })

    def create_directory(
        self,
        path: str,
        mode: str = "755",
    ) -> Dict[str, Any]:
        """Create directory"""
        return self._call_tool("create_directory", {
            "path": path,
            "mode": mode,
        })


def print_response(title: str, data: Any) -> None:
    """Pretty print response data"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")
    print(json.dumps(data, indent=2, default=str))


def main():
    parser = argparse.ArgumentParser(
        description="SJL MCP Filesystem Client",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Read a file
  python3 python-client-example.py --read /home/user/.github/infrastructure/script.sh

  # Write a file
  python3 python-client-example.py --write /home/user/.github/infrastructure/test.txt "Hello World"

  # List directory
  python3 python-client-example.py --list /home/user/.github/infrastructure/

  # Search for files
  python3 python-client-example.py --search /home/user/.github/infrastructure/ "*.sh"

  # Get file info
  python3 python-client-example.py --info /home/user/.github/infrastructure/script.sh

  # Create directory
  python3 python-client-example.py --mkdir /home/user/.github/infrastructure/new-dir
""",
    )

    parser.add_argument("--token", help="Bearer token (or set SJL_MCP_TOKEN env var)")
    parser.add_argument("--host", default="72.61.74.250", help="Service host")
    parser.add_argument("--port", type=int, default=8813, help="Service port")
    parser.add_argument(
        "--no-verify-ssl",
        action="store_true",
        help="Disable SSL verification (not recommended)",
    )

    # Commands
    parser.add_argument("--read", metavar="PATH", help="Read file content")
    parser.add_argument(
        "--write",
        nargs=2,
        metavar=("PATH", "CONTENT"),
        help="Write file content",
    )
    parser.add_argument("--list", metavar="PATH", help="List directory")
    parser.add_argument(
        "--search",
        nargs=2,
        metavar=("PATH", "PATTERN"),
        help="Search for files",
    )
    parser.add_argument("--info", metavar="PATH", help="Get file info")
    parser.add_argument("--mkdir", metavar="PATH", help="Create directory")

    args = parser.parse_args()

    # Validate that at least one command is specified
    if not any([args.read, args.write, args.list, args.search, args.info, args.mkdir]):
        parser.print_help()
        sys.exit(1)

    # Initialize client
    try:
        client = MCPFilesystemClient(
            host=args.host,
            port=args.port,
            token=args.token,
            verify_ssl=not args.no_verify_ssl,
        )
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    # Execute command
    try:
        if args.read:
            content = client.read_file(args.read)
            print_response(f"Read: {args.read}", content)

        elif args.write:
            path, content = args.write
            result = client.write_file(path, content)
            print_response(f"Write: {path}", result)

        elif args.list:
            result = client.list_directory(args.list)
            print_response(f"List: {args.list}", result)

        elif args.search:
            path, pattern = args.search
            result = client.search_files(path, pattern)
            print_response(f"Search: {pattern} in {path}", result)

        elif args.info:
            result = client.get_file_info(args.info)
            print_response(f"Info: {args.info}", result)

        elif args.mkdir:
            result = client.create_directory(args.mkdir)
            print_response(f"Create: {args.mkdir}", result)

        print()  # Final newline

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
