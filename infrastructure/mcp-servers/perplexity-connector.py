#!/usr/bin/env python3
"""
Perplexity MCP Server Connector
Bridges Perplexity to VPS infrastructure via remote executor
"""

import os
import sys
import json
import subprocess
import requests
from typing import Any

# Configuration
REMOTE_EXECUTOR_URL = os.getenv("REMOTE_EXECUTOR_URL", "http://72.61.74.250:8813")
REMOTE_EXECUTOR_KEY = os.getenv("REMOTE_EXECUTOR_KEY", "")

class PerplexityMCPServer:
    """MCP server that bridges to remote VPS executor"""

    def __init__(self):
        if not REMOTE_EXECUTOR_KEY:
            raise ValueError("REMOTE_EXECUTOR_KEY not set")
        self.executor_url = REMOTE_EXECUTOR_URL
        self.api_key = REMOTE_EXECUTOR_KEY

    def execute_command(self, command: str, shell: bool = True) -> dict:
        """Execute command on remote VPS"""
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "command": command,
            "shell": shell
        }

        try:
            response = requests.post(
                f"{self.executor_url}/execute",
                headers=headers,
                json=payload,
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "exit_code": -1
            }

    # MCP Tool Definitions

    def handle_list_tools(self) -> list:
        """List available tools for Perplexity"""
        return [
            {
                "name": "execute_command",
                "description": "Execute shell command on VPS",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "command": {
                            "type": "string",
                            "description": "Shell command to execute"
                        }
                    },
                    "required": ["command"]
                }
            },
            {
                "name": "read_file",
                "description": "Read file contents from VPS",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "path": {
                            "type": "string",
                            "description": "File path to read"
                        }
                    },
                    "required": ["path"]
                }
            },
            {
                "name": "list_services",
                "description": "List all Podman services",
                "inputSchema": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "service_status",
                "description": "Get status of specific service",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "service": {
                            "type": "string",
                            "description": "Service name"
                        }
                    },
                    "required": ["service"]
                }
            },
            {
                "name": "get_system_info",
                "description": "Get VPS system information",
                "inputSchema": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "list_containers",
                "description": "List all running containers",
                "inputSchema": {
                    "type": "object",
                    "properties": {}
                }
            }
        ]

    def handle_call_tool(self, name: str, arguments: dict) -> dict:
        """Handle tool calls from Perplexity"""

        if name == "execute_command":
            return self.execute_command(arguments.get("command", ""))

        elif name == "read_file":
            path = arguments.get("path", "")
            result = self.execute_command(f"cat {path}")
            return result

        elif name == "list_services":
            result = self.execute_command("systemctl list-units --type=service --state=running | grep -E 'quadlet|service' | awk '{print $1}'")
            return result

        elif name == "service_status":
            service = arguments.get("service", "")
            result = self.execute_command(f"sudo systemctl status {service}.service")
            return result

        elif name == "get_system_info":
            result = self.execute_command("echo '=== System Info ===' && uname -a && echo '=== Disk ===' && df -h / && echo '=== Memory ===' && free -h && echo '=== Load ===' && uptime")
            return result

        elif name == "list_containers":
            result = self.execute_command("podman ps -a --format json | jq -r '.[] | \"\\(.Names): \\(.Status)\"'")
            return result

        return {"error": f"Unknown tool: {name}"}

    def run(self):
        """Run MCP server in stdio mode for Perplexity"""
        print("Perplexity MCP Server started", file=sys.stderr)

        while True:
            try:
                line = sys.stdin.readline()
                if not line:
                    break

                message = json.loads(line)
                response = self.process_message(message)
                print(json.dumps(response))
                sys.stdout.flush()

            except json.JSONDecodeError:
                continue
            except Exception as e:
                error_response = {
                    "error": str(e)
                }
                print(json.dumps(error_response))
                sys.stdout.flush()

    def process_message(self, message: dict) -> dict:
        """Process incoming MCP message"""
        method = message.get("method")
        params = message.get("params", {})

        if method == "list_tools":
            return {
                "tools": self.handle_list_tools()
            }
        elif method == "call_tool":
            tool_name = params.get("name")
            tool_args = params.get("arguments", {})
            return self.handle_call_tool(tool_name, tool_args)
        else:
            return {"error": f"Unknown method: {method}"}


if __name__ == "__main__":
    server = PerplexityMCPServer()
    server.run()
