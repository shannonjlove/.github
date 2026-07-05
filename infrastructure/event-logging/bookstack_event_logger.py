#!/usr/bin/env python3
"""
Real-time Event Logger to Bookstack
Logs all system operations with proper hierarchy and naming conventions

Bookstack Structure:
├── System Events [Shelf]
│   ├── [Year] [Book]
│   │   ├── [Month] [Book]
│   │   │   ├── Daily Events [Page]
"""

import os
import json
import requests
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Any
import hashlib

class BookstackEventLogger:
    def __init__(self):
        # Load configuration
        self.base_url = os.getenv("BOOKSTACK_URL", "http://localhost:8000")
        self.api_token = os.getenv("BOOKSTACK_API_TOKEN", "")
        self.api_secret = os.getenv("BOOKSTACK_API_SECRET", "")

        if not self.api_token or not self.api_secret:
            raise ValueError("BOOKSTACK_API_TOKEN and BOOKSTACK_API_SECRET not set")

        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Token {self.api_token}:{self.api_secret}",
            "Content-Type": "application/json"
        })

        # Setup logging
        log_dir = Path("/var/log/bookstack-events")
        log_dir.mkdir(parents=True, exist_ok=True)

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / f"events-{datetime.now().strftime('%Y-%m-%d')}.log"),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)

    # =========================================================================
    # Bookstack Hierarchy Management
    # =========================================================================

    def get_or_create_shelf(self, shelf_name: str) -> str:
        """Get or create a shelf (year-level container)"""
        # Search for shelf
        response = self.session.get(
            f"{self.base_url}/api/shelves",
            params={"filter[name]": shelf_name}
        )

        if response.ok and response.json().get('data'):
            return response.json()['data'][0]['id']

        # Create shelf if not found
        create_response = self.session.post(
            f"{self.base_url}/api/shelves",
            json={"name": shelf_name, "description": f"System events for {shelf_name}"}
        )

        if create_response.ok:
            return create_response.json()['id']

        raise Exception(f"Failed to create shelf: {create_response.text}")

    def get_or_create_book(self, shelf_id: str, book_name: str) -> str:
        """Get or create a book (month-level container)"""
        # Search for book
        response = self.session.get(
            f"{self.base_url}/api/books",
            params={"filter[name]": book_name, "filter[shelf_id]": shelf_id}
        )

        if response.ok and response.json().get('data'):
            return response.json()['data'][0]['id']

        # Create book if not found
        create_response = self.session.post(
            f"{self.base_url}/api/books",
            json={
                "name": book_name,
                "description": f"Events for {book_name}",
                "shelf_id": shelf_id
            }
        )

        if create_response.ok:
            return create_response.json()['id']

        raise Exception(f"Failed to create book: {create_response.text}")

    def get_or_create_page(self, book_id: str, page_name: str) -> str:
        """Get or create a page (daily log page)"""
        # Search for page
        response = self.session.get(
            f"{self.base_url}/api/pages",
            params={"filter[name]": page_name, "filter[book_id]": book_id}
        )

        if response.ok and response.json().get('data'):
            return response.json()['data'][0]['id']

        # Create page if not found
        create_response = self.session.post(
            f"{self.base_url}/api/pages",
            json={
                "name": page_name,
                "book_id": book_id,
                "html": self._get_page_template(page_name)
            }
        )

        if create_response.ok:
            return create_response.json()['id']

        raise Exception(f"Failed to create page: {create_response.text}")

    # =========================================================================
    # Event Logging
    # =========================================================================

    def log_event(self, event_type: str, operation: str, details: Dict[str, Any],
                  status: str = "success", severity: str = "info"):
        """
        Log an event to Bookstack with proper hierarchy

        Args:
            event_type: Category (backup, file-operation, system, etc.)
            operation: Specific operation (backup-start, file-upload, etc.)
            details: Dictionary with operation details
            status: success/failure/warning
            severity: info/warning/error/critical
        """
        now = datetime.now()
        year = now.strftime("%Y")
        month = now.strftime("%B %Y")  # e.g., "January 2026"
        day = now.strftime("%Y-%m-%d")

        try:
            # Create hierarchy
            shelf_id = self.get_or_create_shelf(f"System Events {year}")
            book_id = self.get_or_create_book(shelf_id, f"{month}")
            page_id = self.get_or_create_page(book_id, f"Daily Log {day}")

            # Format event content
            event_html = self._format_event_html(
                event_type, operation, details, status, severity, now
            )

            # Append to page (fetch current content, append, update)
            page_response = self.session.get(f"{self.base_url}/api/pages/{page_id}")
            current_html = page_response.json().get('html', '')

            # Append new event
            updated_html = f"{current_html}\n{event_html}"

            # Update page
            update_response = self.session.put(
                f"{self.base_url}/api/pages/{page_id}",
                json={"html": updated_html}
            )

            if update_response.ok:
                self.logger.info(f"✅ Event logged: {event_type}/{operation}")
            else:
                self.logger.error(f"Failed to log event: {update_response.text}")

        except Exception as e:
            self.logger.error(f"Error logging event: {e}")

    # =========================================================================
    # Formatting
    # =========================================================================

    def _get_page_template(self, page_name: str) -> str:
        """Generate page template with styling"""
        return f"""
        <h1>{page_name}</h1>
        <p><strong>Created:</strong> {datetime.now().isoformat()}</p>
        <hr>
        <div id="events-container">
            <!-- Events will be appended here -->
        </div>
        """

    def _format_event_html(self, event_type: str, operation: str,
                          details: Dict[str, Any], status: str,
                          severity: str, timestamp: datetime) -> str:
        """Format event as HTML for Bookstack"""

        # Status badge color
        status_colors = {
            "success": "#28a745",
            "warning": "#ffc107",
            "failure": "#dc3545",
            "pending": "#17a2b8"
        }

        color = status_colors.get(status, "#6c757d")

        # Build details HTML
        details_html = ""
        for key, value in details.items():
            details_html += f"<li><strong>{key}:</strong> {value}</li>"

        return f"""
        <div style="border-left: 4px solid {color}; padding: 12px; margin: 10px 0; background: #f8f9fa;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <strong style="color: {color};">[{event_type}]</strong>
                    <strong>{operation}</strong>
                    <span style="background: {color}; color: white; padding: 2px 8px; border-radius: 3px; margin-left: 8px;">
                        {status.upper()}
                    </span>
                </div>
                <small style="color: #666;">{timestamp.strftime('%H:%M:%S')}</small>
            </div>
            <ul style="margin: 8px 0; padding-left: 20px;">
                {details_html}
            </ul>
        </div>
        """

    # =========================================================================
    # Event Shortcuts
    # =========================================================================

    def log_backup(self, backup_type: str, size: str, duration: str,
                   status: str = "success"):
        """Log backup event"""
        self.log_event(
            event_type="Backup",
            operation=f"backup-{backup_type}",
            details={
                "type": backup_type,
                "size": size,
                "duration": duration,
                "timestamp": datetime.now().isoformat()
            },
            status=status
        )

    def log_file_operation(self, operation_type: str, filename: str,
                          size: str = "", tags: str = "", status: str = "success"):
        """Log file operation (upload, rename, tag, etc.)"""
        self.log_event(
            event_type="FileOperation",
            operation=f"file-{operation_type}",
            details={
                "operation": operation_type,
                "filename": filename,
                "size": size,
                "tags": tags,
                "timestamp": datetime.now().isoformat()
            },
            status=status
        )

    def log_system_event(self, event_name: str, details_dict: Dict[str, str],
                        status: str = "success", severity: str = "info"):
        """Log general system event"""
        self.log_event(
            event_type="SystemEvent",
            operation=event_name,
            details=details_dict,
            status=status,
            severity=severity
        )


# ============================================================================
# CLI Usage
# ============================================================================

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 bookstack-event-logger.py <event-type> <json-details>")
        print("Example: python3 bookstack-event-logger.py backup '{\"size\": \"2.4GB\", \"duration\": \"45min\"}'")
        sys.exit(1)

    event_type = sys.argv[1]
    details = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}

    logger = BookstackEventLogger()
    logger.log_system_event(event_type, details)
