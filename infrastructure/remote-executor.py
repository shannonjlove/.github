#!/usr/bin/env python3
"""
Remote Command Executor for Claude Code
Allows Claude to execute commands on the VPS via secure HTTP API
"""

import os
import sys
import json
import subprocess
import hashlib
import hmac
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import logging

# Configuration
PORT = 8812
API_KEY = os.getenv("REMOTE_EXECUTOR_KEY", "change-me-immediately")
LOG_FILE = "/var/log/remote-executor.log"

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class RemoteExecutorHandler(BaseHTTPRequestHandler):
    """HTTP request handler for command execution"""

    def do_POST(self):
        """Handle POST requests for command execution"""
        # Check authorization
        auth_header = self.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            self.send_error(401, "Unauthorized")
            logger.warning(f"Unauthorized request from {self.client_address[0]}")
            return

        token = auth_header[7:]
        if token != API_KEY:
            self.send_error(403, "Forbidden")
            logger.warning(f"Invalid token from {self.client_address[0]}")
            return

        # Parse request
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')

        try:
            data = json.loads(body)
            command = data.get('command', '')
            shell = data.get('shell', False)
        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON")
            return

        if not command:
            self.send_error(400, "Missing command")
            return

        logger.info(f"Executing command: {command}")

        try:
            # Execute command
            result = subprocess.run(
                command,
                shell=shell,
                capture_output=True,
                text=True,
                timeout=30
            )

            response = {
                "success": True,
                "exit_code": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }

            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))

            logger.info(f"Command completed with exit code {result.returncode}")

        except subprocess.TimeoutExpired:
            response = {
                "success": False,
                "error": "Command timeout (30s limit)"
            }
            self.send_response(504)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
            logger.error("Command timeout")

        except Exception as e:
            response = {
                "success": False,
                "error": str(e)
            }
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
            logger.error(f"Command execution error: {e}")

    def do_GET(self):
        """Handle GET requests for health check"""
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode('utf-8'))
        else:
            self.send_error(404)

    def log_message(self, format, *args):
        """Suppress default logging"""
        pass


def main():
    if API_KEY == "change-me-immediately":
        print("ERROR: REMOTE_EXECUTOR_KEY environment variable not set!")
        print("Set it before running: export REMOTE_EXECUTOR_KEY='your-secure-key'")
        sys.exit(1)

    server = HTTPServer(('0.0.0.0', PORT), RemoteExecutorHandler)
    logger.info(f"Remote Executor listening on port {PORT}")
    logger.info("Waiting for connections...")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down...")
        server.shutdown()


if __name__ == '__main__':
    main()
