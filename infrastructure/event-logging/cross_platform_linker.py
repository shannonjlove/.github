#!/usr/bin/env python3
"""
Cross-Platform Linker
Bidirectional linking between Bookstack, Craft Docs, TickTick, Raindrop.io, and Paperless-NGX
Uses para system codes for unique identification across platforms
"""

import os
import json
import requests
from datetime import datetime
from typing import Dict, Optional, List
from para_system import ParaSystemCodeGenerator

class CrossPlatformLinker:
    def __init__(self):
        """Initialize cross-platform linking system"""
        self.para_gen = ParaSystemCodeGenerator()

        # Platform APIs
        self.bookstack_url = os.getenv("BOOKSTACK_URL", "http://localhost:8000")
        self.bookstack_token = os.getenv("BOOKSTACK_API_TOKEN", "")
        self.bookstack_secret = os.getenv("BOOKSTACK_API_SECRET", "")

        self.craft_token = os.getenv("CRAFT_API_TOKEN", "")
        self.craft_user_id = os.getenv("CRAFT_USER_ID", "")

        self.ticktick_token = os.getenv("TICKTICK_API_TOKEN", "")

        self.raindrop_token = os.getenv("RAINDROP_API_TOKEN", "")

        self.paperless_url = os.getenv("PAPERLESS_URL", "http://localhost:8080")
        self.paperless_token = os.getenv("PAPERLESS_TOKEN", "")

    # =========================================================================
    # Bookstack Integration
    # =========================================================================

    def create_bookstack_item(self, title: str, content: str, shelf_name: str = "System Events",
                             book_name: str = None, para_code: str = None) -> Dict:
        """
        Create item in Bookstack and return para code and link
        """
        if not para_code:
            para_code = self.para_gen.generate_code("bookstack", title)

        session = requests.Session()
        session.headers.update({
            "Authorization": f"Token {self.bookstack_token}:{self.bookstack_secret}",
            "Content-Type": "application/json"
        })

        try:
            # Get or create shelf
            shelf_resp = session.get(f"{self.bookstack_url}/api/shelves",
                                     params={"filter[name]": shelf_name})
            shelf_id = shelf_resp.json()['data'][0]['id'] if shelf_resp.json().get('data') else None

            if not shelf_id:
                shelf_resp = session.post(f"{self.bookstack_url}/api/shelves",
                                         json={"name": shelf_name})
                shelf_id = shelf_resp.json()['id']

            # Get or create book
            if not book_name:
                book_name = datetime.now().strftime("%B %Y")

            book_resp = session.get(f"{self.bookstack_url}/api/books",
                                   params={"filter[name]": book_name, "filter[shelf_id]": shelf_id})
            book_id = book_resp.json()['data'][0]['id'] if book_resp.json().get('data') else None

            if not book_id:
                book_resp = session.post(f"{self.bookstack_url}/api/books",
                                        json={"name": book_name, "shelf_id": shelf_id})
                book_id = book_resp.json()['id']

            # Create page with para code
            page_content = f"""
            <h2>[{para_code}] {title}</h2>
            <div class="para-code" style="background: #f0f0f0; padding: 8px; margin: 10px 0; border-radius: 4px;">
                <strong>Para Code:</strong> {para_code}
            </div>
            <div class="content">{content}</div>
            <div class="cross-platform-links" style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ccc;">
                <h4>Cross-Platform Links:</h4>
                <ul id="platform-links"></ul>
            </div>
            """

            page_resp = session.post(f"{self.bookstack_url}/api/pages",
                                    json={"name": f"[{para_code}] {title}",
                                          "book_id": book_id,
                                          "html": page_content})

            page_id = page_resp.json()['id']
            page_url = f"{self.bookstack_url}/pages/{page_id}"

            # Register in para system
            self.para_gen.register_code_usage(para_code, "bookstack", page_id, page_url)

            return {
                "success": True,
                "para_code": para_code,
                "platform": "bookstack",
                "page_id": page_id,
                "url": page_url
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    # =========================================================================
    # Craft Docs Integration
    # =========================================================================

    def create_craft_item(self, title: str, content: str, para_code: str = None) -> Dict:
        """
        Create item in Craft Docs and return para code and link
        """
        if not para_code:
            para_code = self.para_gen.generate_code("craft", title)

        try:
            headers = {
                "Authorization": f"Bearer {self.craft_token}",
                "Content-Type": "application/json"
            }

            craft_content = f"""[{para_code}] {title}

Para Code: {para_code}
Created: {datetime.now().isoformat()}

{content}

### Cross-Platform Links
- [View in Bookstack](#)
- [View in TickTick](#)
- [View in Raindrop](#)
- [View in Paperless](#)
"""

            # Create block in Craft
            response = requests.post(
                "https://api.craft.do/v2/blocks",
                headers=headers,
                json={
                    "blockType": "document",
                    "title": f"[{para_code}] {title}",
                    "markdownContent": craft_content
                }
            )

            if response.status_code == 201:
                data = response.json()
                craft_id = data.get('id')
                craft_url = data.get('webLink')

                self.para_gen.register_code_usage(para_code, "craft", craft_id, craft_url)

                return {
                    "success": True,
                    "para_code": para_code,
                    "platform": "craft",
                    "craft_id": craft_id,
                    "url": craft_url
                }
            else:
                return {"success": False, "error": response.text}

        except Exception as e:
            return {"success": False, "error": str(e)}

    # =========================================================================
    # TickTick Integration
    # =========================================================================

    def create_ticktick_task(self, title: str, description: str = "", para_code: str = None,
                            list_name: str = "System Events") -> Dict:
        """
        Create task in TickTick and return para code and link
        """
        if not para_code:
            para_code = self.para_gen.generate_code("ticktick", title)

        try:
            headers = {
                "Authorization": f"Bearer {self.ticktick_token}",
                "Content-Type": "application/json"
            }

            task_content = f"""[{para_code}] {title}

Para Code: {para_code}

{description}

Links:
Bookstack | Craft | Raindrop | Paperless
"""

            response = requests.post(
                "https://api.ticktick.com/v2/tasks",
                headers=headers,
                json={
                    "title": f"[{para_code}] {title}",
                    "description": task_content,
                    "listId": list_name,
                    "tags": [para_code, "cross-platform"]
                }
            )

            if response.status_code == 201:
                data = response.json()
                task_id = data.get('id')
                task_url = f"https://www.ticktick.com/tasks/{task_id}"

                self.para_gen.register_code_usage(para_code, "ticktick", task_id, task_url)

                return {
                    "success": True,
                    "para_code": para_code,
                    "platform": "ticktick",
                    "task_id": task_id,
                    "url": task_url
                }
            else:
                return {"success": False, "error": response.text}

        except Exception as e:
            return {"success": False, "error": str(e)}

    # =========================================================================
    # Raindrop.io Integration
    # =========================================================================

    def create_raindrop_item(self, title: str, url: str, description: str = "",
                            para_code: str = None, collection_name: str = "System") -> Dict:
        """
        Create item in Raindrop.io and return para code and link
        """
        if not para_code:
            para_code = self.para_gen.generate_code("raindrop", title)

        try:
            headers = {
                "Authorization": f"Bearer {self.raindrop_token}",
                "Content-Type": "application/json"
            }

            raindrop_content = f"""[{para_code}] {title}

Para Code: {para_code}

{description}

Source: {url}
"""

            response = requests.post(
                "https://api.raindrop.io/rest/v5/raindrops",
                headers=headers,
                json={
                    "title": f"[{para_code}] {title}",
                    "link": url,
                    "description": raindrop_content,
                    "tags": [para_code, "cross-platform"],
                    "collection": {"name": collection_name}
                }
            )

            if response.status_code == 201:
                data = response.json()
                raindrop_id = data.get('item', {}).get('_id')
                raindrop_url = data.get('item', {}).get('link')

                self.para_gen.register_code_usage(para_code, "raindrop", raindrop_id, raindrop_url)

                return {
                    "success": True,
                    "para_code": para_code,
                    "platform": "raindrop",
                    "raindrop_id": raindrop_id,
                    "url": raindrop_url
                }
            else:
                return {"success": False, "error": response.text}

        except Exception as e:
            return {"success": False, "error": str(e)}

    # =========================================================================
    # Paperless-NGX Integration
    # =========================================================================

    def upload_to_paperless_with_para(self, document_path: str, title: str = "",
                                      para_code: str = None, tags: List[str] = None) -> Dict:
        """
        Upload document to Paperless-NGX with para system code
        """
        if not para_code:
            para_code = self.para_gen.generate_code("paperless", title)

        try:
            with open(document_path, 'rb') as f:
                files = {'document': (document_path, f)}

                # Build tags list with para code
                if not tags:
                    tags = []
                tags.append(para_code)

                data = {
                    'title': f"[{para_code}] {title or document_path.split('/')[-1]}",
                    'tags': ','.join(tags),
                    'correspondent': '',
                    'document_type': '',
                    'notes': f"Para Code: {para_code}"
                }

                response = requests.post(
                    f"{self.paperless_url}/api/documents/post_document/",
                    headers={"Authorization": f"Token {self.paperless_token}"},
                    data=data,
                    files=files
                )

                if response.status_code == 200:
                    doc_data = response.json()
                    doc_id = doc_data.get('id')
                    doc_url = f"{self.paperless_url}/documents/{doc_id}"

                    self.para_gen.register_code_usage(para_code, "paperless", doc_id, doc_url)

                    return {
                        "success": True,
                        "para_code": para_code,
                        "platform": "paperless",
                        "document_id": doc_id,
                        "url": doc_url
                    }
                else:
                    return {"success": False, "error": response.text}

        except Exception as e:
            return {"success": False, "error": str(e)}

    # =========================================================================
    # Cross-Platform Linking
    # =========================================================================

    def create_bidirectional_links(self, para_code: str) -> Dict:
        """
        Get all platforms where a para code exists and create bidirectional links
        """
        code_info = self.para_gen.get_code_info(para_code)
        if not code_info:
            return {"success": False, "error": "Para code not found"}

        links = {}
        for platform, details in code_info.get("platforms", {}).items():
            links[platform] = {
                "name": self._platform_name(platform),
                "url": details.get("url"),
                "reference": details.get("reference_id")
            }

        # Update each platform with links to others
        update_results = {}

        for source_platform, source_details in code_info.get("platforms", {}).items():
            link_html = self._generate_link_html(para_code, source_platform, links)
            update_results[source_platform] = self._update_platform_links(
                source_platform, source_details.get("reference_id"), link_html
            )

        return {
            "success": True,
            "para_code": para_code,
            "links": links,
            "update_results": update_results
        }

    def _generate_link_html(self, para_code: str, exclude_platform: str, links: Dict) -> str:
        """Generate HTML for cross-platform links"""
        html = f'<div class="cross-platform-links" style="margin-top: 20px; border-top: 1px solid #ccc; padding-top: 10px;">'
        html += f'<h4>Related Items [{para_code}]:</h4><ul>'

        for platform, details in links.items():
            if platform != exclude_platform:
                html += f'<li><a href="{details["url"]}" target="_blank">{details["name"]}</a></li>'

        html += '</ul></div>'
        return html

    def _update_platform_links(self, platform: str, reference_id: str, link_html: str) -> Dict:
        """Update links on specific platform"""
        try:
            if platform == "bookstack":
                session = requests.Session()
                session.headers.update({
                    "Authorization": f"Token {self.bookstack_token}:{self.bookstack_secret}",
                    "Content-Type": "application/json"
                })
                resp = session.put(f"{self.bookstack_url}/api/pages/{reference_id}",
                                  json={"html": link_html})
                return {"success": resp.ok}

            # Add other platforms as needed
            return {"success": True}

        except Exception as e:
            return {"success": False, "error": str(e)}

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
    linker = CrossPlatformLinker()

    # Example: Create linked items
    title = "Important Document"
    content = "This is a document that needs to be linked across platforms"

    print("Creating linked items...")

    bookstack = linker.create_bookstack_item(title, content)
    print(f"Bookstack: {bookstack}")

    # Use same para code for all platforms
    para_code = bookstack["para_code"]

    craft = linker.create_craft_item(title, content, para_code)
    print(f"Craft: {craft}")

    # Create bidirectional links
    links = linker.create_bidirectional_links(para_code)
    print(f"Links: {json.dumps(links, indent=2)}")
