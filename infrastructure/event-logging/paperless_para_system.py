#!/usr/bin/env python3
"""
Paperless-NGX Para System Integration
Organizes documents with six-digit para codes for systematic document management
Maps para codes to:
- Tags (para code as main tag + category tags)
- Correspondent (extracted from para code metadata)
- Document Type (inferred from para code category)
- Custom fields (stores full para code metadata)
"""

import os
import json
import requests
from typing import Dict, Optional, List
from para_system import ParaSystemCodeGenerator

class PaperlessPara:
    def __init__(self):
        """Initialize Paperless-NGX para system"""
        self.paperless_url = os.getenv("PAPERLESS_URL", "http://localhost:8080")
        self.api_token = os.getenv("PAPERLESS_TOKEN", "")
        self.para_gen = ParaSystemCodeGenerator()

        self.headers = {
            "Authorization": f"Token {self.api_token}",
            "Content-Type": "application/json"
        }

        # Para system category mappings
        self.category_to_doctype = {
            "invoice": "Invoice",
            "receipt": "Receipt",
            "contract": "Contract",
            "document": "Document",
            "backup": "Archive",
            "file": "File",
            "pdf": "Document",
            "general": "Miscellaneous"
        }

        self.category_to_correspondent = {
            "invoice": "Finance",
            "receipt": "Expenses",
            "contract": "Legal",
            "document": "Administrative",
            "backup": "System",
            "file": "Archive",
            "pdf": "Library"
        }

    def create_para_tags(self, para_code: str, category: str, additional_tags: List[str] = None) -> List[int]:
        """
        Create or get para system tags for a document
        Creates tags: [PARA_CODE], [CATEGORY], [YYMMDD], [YYYY], [MM]
        """
        tags = []

        if not additional_tags:
            additional_tags = []

        all_tag_names = [
            para_code,  # Full para code (e.g., "260705-0001")
            category,   # Category (invoice, receipt, etc.)
            para_code[:6],  # Date portion (YYMMDD)
            f"20{para_code[:2]}",  # Year (2026 from 26)
            f"Month-{para_code[2:4]}",  # Month (Month-07)
        ] + additional_tags

        # Create tags in Paperless
        for tag_name in all_tag_names:
            tag_id = self._get_or_create_tag(tag_name)
            if tag_id:
                tags.append(tag_id)

        return tags

    def _get_or_create_tag(self, tag_name: str) -> Optional[int]:
        """Get existing tag or create new one"""
        try:
            # Try to get existing tag
            resp = requests.get(
                f"{self.paperless_url}/api/tags/",
                headers=self.headers,
                params={"name": tag_name}
            )

            if resp.ok and resp.json().get('results'):
                return resp.json()['results'][0]['id']

            # Create new tag
            resp = requests.post(
                f"{self.paperless_url}/api/tags/",
                headers=self.headers,
                json={"name": tag_name, "color": self._get_color_for_tag(tag_name)}
            )

            if resp.ok:
                return resp.json()['id']

            return None

        except Exception as e:
            print(f"Error creating tag {tag_name}: {e}")
            return None

    def _get_color_for_tag(self, tag_name: str) -> str:
        """Get color code for tag based on type"""
        colors = {
            "invoice": "#FF6B6B",     # Red
            "receipt": "#4ECDC4",     # Teal
            "contract": "#45B7D1",    # Blue
            "document": "#96CEB4",    # Green
            "backup": "#FFEAA7",      # Yellow
            "file": "#DFE6E9",        # Gray
            "pdf": "#A29BFE"          # Purple
        }

        for cat, color in colors.items():
            if cat in tag_name.lower():
                return color

        return "#95A5A6"  # Default gray

    def create_correspondent(self, para_code: str, category: str, custom_name: str = None) -> Optional[int]:
        """
        Create or get correspondent for para system
        Correspondent represents the source/owner of the document
        """
        correspondent_name = custom_name or self.category_to_correspondent.get(category, "Unknown")
        correspondent_name = f"[PARA] {correspondent_name}"

        try:
            # Try to get existing correspondent
            resp = requests.get(
                f"{self.paperless_url}/api/correspondents/",
                headers=self.headers,
                params={"name": correspondent_name}
            )

            if resp.ok and resp.json().get('results'):
                return resp.json()['results'][0]['id']

            # Create new correspondent
            resp = requests.post(
                f"{self.paperless_url}/api/correspondents/",
                headers=self.headers,
                json={"name": correspondent_name}
            )

            if resp.ok:
                return resp.json()['id']

            return None

        except Exception as e:
            print(f"Error creating correspondent: {e}")
            return None

    def create_document_type(self, category: str) -> Optional[int]:
        """
        Create or get document type for para category
        """
        doc_type_name = self.category_to_doctype.get(category, "Miscellaneous")

        try:
            # Try to get existing type
            resp = requests.get(
                f"{self.paperless_url}/api/document_types/",
                headers=self.headers,
                params={"name": doc_type_name}
            )

            if resp.ok and resp.json().get('results'):
                return resp.json()['results'][0]['id']

            # Create new type
            resp = requests.post(
                f"{self.paperless_url}/api/document_types/",
                headers=self.headers,
                json={"name": doc_type_name}
            )

            if resp.ok:
                return resp.json()['id']

            return None

        except Exception as e:
            print(f"Error creating document type: {e}")
            return None

    def upload_document_with_para(self, file_path: str, title: str = None,
                                  category: str = "document", para_code: str = None,
                                  additional_tags: List[str] = None) -> Dict:
        """
        Upload document to Paperless-NGX with full para system integration
        """
        if not para_code:
            para_code = self.para_gen.generate_code(category, title or file_path)

        if not title:
            title = file_path.split('/')[-1]

        try:
            # Create para system elements
            tags = self.create_para_tags(para_code, category, additional_tags)
            correspondent_id = self.create_correspondent(para_code, category)
            doc_type_id = self.create_document_type(category)

            # Upload document
            with open(file_path, 'rb') as f:
                files = {'document': (file_path, f)}

                data = {
                    'title': f"[{para_code}] {title}",
                    'tags': ','.join(str(t) for t in tags),
                    'correspondent': correspondent_id or '',
                    'document_type': doc_type_id or '',
                    'notes': self._generate_notes(para_code, category),
                    'created': self.para_gen.codes[para_code].get('generated_at', '')
                }

                response = requests.post(
                    f"{self.paperless_url}/api/documents/post_document/",
                    headers={"Authorization": f"Token {self.api_token}"},
                    data=data,
                    files=files
                )

                if response.ok:
                    doc_data = response.json()
                    doc_id = doc_data.get('id')
                    doc_url = f"{self.paperless_url}/documents/{doc_id}"

                    # Register in para system
                    self.para_gen.register_code_usage(para_code, "paperless", doc_id, doc_url)

                    return {
                        "success": True,
                        "para_code": para_code,
                        "document_id": doc_id,
                        "url": doc_url,
                        "tags": tags,
                        "correspondent": correspondent_id,
                        "document_type": doc_type_id
                    }
                else:
                    return {"success": False, "error": response.text}

        except Exception as e:
            return {"success": False, "error": str(e)}

    def _generate_notes(self, para_code: str, category: str) -> str:
        """Generate notes field with para system metadata"""
        code_info = self.para_gen.get_code_info(para_code)

        notes = f"""Para Code: {para_code}
Category: {category}
Generated: {code_info.get('generated_at', 'N/A')}
Description: {code_info.get('description', 'N/A')}

Cross-Platform Links:
"""

        for platform, details in code_info.get('platforms', {}).items():
            if platform != 'paperless':
                notes += f"- {self._platform_name(platform)}: {details.get('url', 'N/A')}\n"

        return notes

    def create_para_search_view(self) -> Dict:
        """
        Create saved searches for common para system queries
        """
        searches = [
            {
                "name": "By Para Code (Today)",
                "query": f"date_from:{self.para_gen.get_daily_codes().keys().__iter__().__next__()}"
            },
            {
                "name": "By Category: Invoices",
                "query": "tag:invoice"
            },
            {
                "name": "By Category: Receipts",
                "query": "tag:receipt"
            },
            {
                "name": "By Category: Contracts",
                "query": "tag:contract"
            },
            {
                "name": "Recent Documents",
                "query": "ordering:-created"
            }
        ]

        return {"searches": searches, "note": "Configure these in Paperless-NGX Settings → Saved Searches"}

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

    def generate_para_reference_document(self) -> str:
        """
        Generate a reference document showing all active para codes and their usage
        """
        doc = "# Para System Reference Document\n\n"
        doc += f"Generated: {self.para_gen._load_data()}\n\n"

        doc += "## Today's Codes\n"
        daily_codes = self.para_gen.get_daily_codes()
        for code, info in daily_codes.items():
            doc += f"\n### {code}\n"
            doc += f"- Category: {info.get('category')}\n"
            doc += f"- Description: {info.get('description')}\n"
            doc += f"- Platforms: {', '.join(info.get('platforms', {}).keys())}\n"

        doc += "\n## Platform References\n"
        doc += "| Code | Bookstack | Craft | TickTick | Raindrop | Paperless |\n"
        doc += "|------|-----------|-------|----------|----------|----------|\n"

        for code, info in self.para_gen.codes.items():
            platforms = info.get('platforms', {})
            row = f"| {code} | "
            row += f"✓" if 'bookstack' in platforms else "✗"
            row += f" | ✓" if 'craft' in platforms else " | ✗"
            row += f" | ✓" if 'ticktick' in platforms else " | ✗"
            row += f" | ✓" if 'raindrop' in platforms else " | ✗"
            row += f" | ✓" if 'paperless' in platforms else " | ✗"
            row += " |\n"
            doc += row

        return doc


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    paperless_para = PaperlessPara()

    # Example: Upload document with para system
    result = paperless_para.upload_document_with_para(
        file_path="/tmp/example.pdf",
        title="Example Invoice",
        category="invoice",
        additional_tags=["important", "2026"]
    )

    print(json.dumps(result, indent=2))

    # Generate reference document
    ref = paperless_para.generate_para_reference_document()
    print("\nReference Document:\n")
    print(ref)
