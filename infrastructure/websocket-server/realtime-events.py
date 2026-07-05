#!/usr/bin/env python3
"""
WebSocket Server for Real-Time System Events
Provides live updates to dashboard and triggers Bookstack logging
"""

import asyncio
import json
import logging
from datetime import datetime
from pathlib import Path
import websockets
from websockets.server import serve

# WebSocket Configuration
WS_HOST = "0.0.0.0"
WS_PORT = 9000

# Setup logging
log_dir = Path("/var/log/realtime-events")
log_dir.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_dir / f"server-{datetime.now().strftime('%Y-%m-%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Connected clients
connected_clients = set()

# ============================================================================
# WebSocket Handlers
# ============================================================================

async def broadcast_event(event: dict):
    """Send event to all connected clients"""
    if not connected_clients:
        return

    message = json.dumps({
        "timestamp": datetime.now().isoformat(),
        "event": event
    })

    # Send to all connected clients
    dead_clients = set()

    for client in connected_clients:
        try:
            await client.send(message)
        except Exception as e:
            logger.error(f"Error sending to client: {e}")
            dead_clients.add(client)

    # Remove dead connections
    connected_clients.difference_update(dead_clients)


async def handle_client(websocket, path):
    """Handle WebSocket client connection"""
    client_ip = websocket.remote_address[0]
    logger.info(f"Client connected: {client_ip}")
    connected_clients.add(websocket)

    try:
        # Send welcome message
        await websocket.send(json.dumps({
            "type": "connection",
            "message": "Connected to real-time events server",
            "timestamp": datetime.now().isoformat()
        }))

        # Listen for client messages
        async for message in websocket:
            try:
                data = json.loads(message)

                # Handle different message types
                if data.get("type") == "event":
                    await process_event(data)
                elif data.get("type") == "ping":
                    await websocket.send(json.dumps({"type": "pong"}))

            except json.JSONDecodeError:
                logger.warning(f"Invalid JSON from {client_ip}")

    except websockets.exceptions.ConnectionClosed:
        logger.info(f"Client disconnected: {client_ip}")
    finally:
        connected_clients.discard(websocket)


async def process_event(data: dict):
    """Process incoming event and broadcast to all clients"""
    event_type = data.get("type", "unknown")
    operation = data.get("operation", "")
    details = data.get("details", {})
    status = data.get("status", "success")

    # Log event
    logger.info(f"Event: {event_type}/{operation} - {status}")

    # Format event for dashboard
    formatted_event = {
        "type": event_type,
        "operation": operation,
        "status": status,
        "details": details,
        "timestamp": datetime.now().isoformat()
    }

    # Broadcast to all connected clients
    await broadcast_event(formatted_event)

    # Log to Bookstack (async)
    asyncio.create_task(log_to_bookstack(formatted_event))


async def log_to_bookstack(event: dict):
    """Log event to Bookstack"""
    import subprocess

    try:
        # Call bookstack event logger
        command = [
            "python3",
            "/home/user/.github/infrastructure/event-logging/bookstack-event-logger.py",
            event.get("type", "event"),
            json.dumps(event)
        ]

        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        await process.communicate()

    except Exception as e:
        logger.error(f"Error logging to Bookstack: {e}")


# ============================================================================
# Event Publishing API (for other services to publish events)
# ============================================================================

async def handle_http_event(path, request_body):
    """Handle HTTP POST for publishing events"""
    try:
        event = json.loads(request_body)
        await process_event(event)
        return True
    except Exception as e:
        logger.error(f"Error processing HTTP event: {e}")
        return False


# ============================================================================
# Event Publishing Helpers
# ============================================================================

def publish_backup_event(backup_type: str, size: str, duration: str, status: str = "success"):
    """Helper to publish backup events"""
    return {
        "type": "backup",
        "operation": f"backup-{backup_type}",
        "status": status,
        "details": {
            "type": backup_type,
            "size": size,
            "duration": duration
        }
    }


def publish_file_event(operation: str, filename: str, size: str = "", tags: str = "", status: str = "success"):
    """Helper to publish file operation events"""
    return {
        "type": "file-operation",
        "operation": f"file-{operation}",
        "status": status,
        "details": {
            "operation": operation,
            "filename": filename,
            "size": size,
            "tags": tags
        }
    }


def publish_system_event(event_name: str, details: dict, status: str = "success"):
    """Helper to publish system events"""
    return {
        "type": "system",
        "operation": event_name,
        "status": status,
        "details": details
    }


# ============================================================================
# Startup & Management
# ============================================================================

async def main():
    """Start WebSocket server"""
    logger.info(f"Starting WebSocket server on ws://{WS_HOST}:{WS_PORT}")

    async with serve(handle_client, WS_HOST, WS_PORT):
        logger.info("WebSocket server is running")
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Server error: {e}")
