#!/usr/bin/env python3
"""
Standalone Remote Command Executor for Claude Code
Single file, no dependencies, ready to run immediately
"""
import os
import sys
import json
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

# Configuration
PORT = 8812
API_KEY = os.getenv("REMOTE_EXECUTOR_KEY", "")
LOG_FILE = "/var/log/remote-executor.log"

if not API_KEY:
    print("ERROR: REMOTE_EXECUTOR_KEY environment variable not set!")
    print("Usage: REMOTE_EXECUTOR_KEY='your-key' python3 remote-executor-simple.py")
    sys.exit(1)

# Setup logging
def log_message(msg):
    try:
        with open(LOG_FILE, 'a') as f:
            f.write(f"{msg}\n")
    except:
        pass
    print(msg)

log_message(f"[STARTUP] Remote Executor starting on port {PORT}")
log_message(f"[STARTUP] API Key: {API_KEY[:16]}...")

class CommandHandler(BaseHTTPRequestHandler):
    """HTTP handler for executing commands"""

    def do_POST(self):
        """Execute command via POST request"""
        try:
            # Check authorization
            auth_header = self.headers.get('Authorization', '')
            if not auth_header.startswith('Bearer '):
                self.send_response(401)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing authorization header"}).encode())
                log_message(f"[AUTH] Unauthorized request from {self.client_address[0]}")
                return

            token = auth_header[7:]
            if token != API_KEY:
                self.send_response(403)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Invalid token"}).encode())
                log_message(f"[AUTH] Invalid token from {self.client_address[0]}")
                return

            # Parse request body
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length == 0:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": "No command provided"}).encode())
                return

            body = self.rfile.read(content_length).decode('utf-8')
            data = json.loads(body)
            command = data.get('command', '')

            if not command:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Empty command"}).encode())
                return

            log_message(f"[EXEC] Executing: {command}")

            # Execute the command
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )

            # Send response
            response = {
                "success": True,
                "exit_code": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }

            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())

            log_message(f"[EXEC] Exit code: {result.returncode}")

        except subprocess.TimeoutExpired:
            self.send_response(504)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"error": "Command timeout"}).encode())
            log_message("[EXEC] Command timeout")

        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())
            log_message(f"[ERROR] {str(e)}")

    def do_GET(self):
        """Health check endpoint"""
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "port": PORT}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        """Suppress default logging"""
        pass


def run_server():
    """Start the HTTP server"""
    server = HTTPServer(('0.0.0.0', PORT), CommandHandler)
    log_message(f"[SERVER] Listening on 0.0.0.0:{PORT}")
    log_message(f"[SERVER] Ready to accept commands")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        log_message("[SHUTDOWN] Received interrupt, shutting down")
        server.shutdown()


if __name__ == '__main__':
    # Create log directory if needed
    Path(LOG_FILE).parent.mkdir(parents=True, exist_ok=True)
    run_server()
