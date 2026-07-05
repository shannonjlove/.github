#!/usr/bin/env python3
"""
Google Gemini MCP Server Connector
Bridges Gemini to VPS infrastructure via remote executor
"""

import os
import json
import requests
from typing import Any

# Configuration
REMOTE_EXECUTOR_URL = os.getenv("REMOTE_EXECUTOR_URL", "http://72.61.74.250:8813")
REMOTE_EXECUTOR_KEY = os.getenv("REMOTE_EXECUTOR_KEY", "")

class GeminiMCPServer:
    """MCP server for Google Gemini integration"""

    def __init__(self):
        if not REMOTE_EXECUTOR_KEY:
            raise ValueError("REMOTE_EXECUTOR_KEY not set")
        self.executor_url = REMOTE_EXECUTOR_URL
        self.api_key = REMOTE_EXECUTOR_KEY

    def execute_command(self, command: str) -> dict:
        """Execute command on remote VPS"""
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "command": command,
            "shell": True
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
                "exit_code": -1,
                "stdout": "",
                "stderr": str(e)
            }

    # Gemini Tool Definitions

    def get_tools(self) -> list:
        """Get tool definitions for Gemini"""
        return [
            {
                "name": "vps_execute_command",
                "description": "Execute a shell command on your VPS infrastructure",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "command": {
                            "type": "string",
                            "description": "The shell command to execute on the VPS"
                        }
                    },
                    "required": ["command"]
                }
            },
            {
                "name": "vps_read_file",
                "description": "Read contents of a file on the VPS",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "filepath": {
                            "type": "string",
                            "description": "Full path to file to read"
                        }
                    },
                    "required": ["filepath"]
                }
            },
            {
                "name": "vps_list_services",
                "description": "List all running services and containers on VPS",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "vps_get_service_logs",
                "description": "Get recent logs for a specific service",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "service_name": {
                            "type": "string",
                            "description": "Name of the service to get logs for"
                        },
                        "lines": {
                            "type": "integer",
                            "description": "Number of log lines to retrieve (default: 50)"
                        }
                    },
                    "required": ["service_name"]
                }
            },
            {
                "name": "vps_system_status",
                "description": "Get VPS system status (CPU, memory, disk, uptime)",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "vps_docker_status",
                "description": "Get Podman/Docker container status",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "vps_disk_usage",
                "description": "Get disk usage information for VPS",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            },
            {
                "name": "vps_network_status",
                "description": "Get network configuration and listening ports",
                "parameters": {
                    "type": "object",
                    "properties": {}
                }
            }
        ]

    def process_tool_call(self, tool_name: str, tool_input: dict) -> str:
        """Process a tool call from Gemini"""

        if tool_name == "vps_execute_command":
            command = tool_input.get("command", "")
            result = self.execute_command(command)
            return json.dumps(result, indent=2)

        elif tool_name == "vps_read_file":
            filepath = tool_input.get("filepath", "")
            result = self.execute_command(f"cat {filepath}")
            return result.get("stdout", "") if result.get("success") else f"Error: {result.get('stderr')}"

        elif tool_name == "vps_list_services":
            result = self.execute_command(
                "echo '=== Systemd Services ===' && systemctl list-units --type=service --state=running | head -20 && echo '' && echo '=== Podman Containers ===' && podman ps -a --format 'table {{.Names}}\t{{.Status}}'"
            )
            return result.get("stdout", "")

        elif tool_name == "vps_get_service_logs":
            service = tool_input.get("service_name", "")
            lines = tool_input.get("lines", 50)
            result = self.execute_command(f"journalctl -u {service}.service -n {lines} --no-pager")
            return result.get("stdout", "")

        elif tool_name == "vps_system_status":
            result = self.execute_command(
                "echo '=== Uptime ===' && uptime && echo '' && echo '=== CPU Load ===' && cat /proc/loadavg && echo '' && echo '=== Memory ===' && free -h && echo '' && echo '=== Disk ===' && df -h /"
            )
            return result.get("stdout", "")

        elif tool_name == "vps_docker_status":
            result = self.execute_command(
                "echo '=== Podman Images ===' && podman images --format 'table {{.Repository}}:{{.Tag}}\t{{.Size}}' && echo '' && echo '=== Running Containers ===' && podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
            )
            return result.get("stdout", "")

        elif tool_name == "vps_disk_usage":
            result = self.execute_command(
                "echo '=== Filesystem Usage ===' && df -h && echo '' && echo '=== Top 10 Largest Directories ===' && du -sh /* 2>/dev/null | sort -rh | head -10"
            )
            return result.get("stdout", "")

        elif tool_name == "vps_network_status":
            result = self.execute_command(
                "echo '=== Network Interfaces ===' && ip addr show && echo '' && echo '=== Listening Ports ===' && ss -tlnp | grep LISTEN | head -20"
            )
            return result.get("stdout", "")

        else:
            return json.dumps({"error": f"Unknown tool: {tool_name}"})


def get_tools() -> list:
    """Entry point for Gemini to get available tools"""
    server = GeminiMCPServer()
    return server.get_tools()


def process_tool_call(tool_name: str, tool_input: dict) -> str:
    """Entry point for Gemini to call tools"""
    server = GeminiMCPServer()
    return server.process_tool_call(tool_name, tool_input)


if __name__ == "__main__":
    # Test mode
    server = GeminiMCPServer()
    print("Available tools:")
    for tool in server.get_tools():
        print(f"  - {tool['name']}: {tool['description']}")
