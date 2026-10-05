#!/usr/bin/env python3
"""Export enabled Meduc study resources for the light detail page.

This includes category 48 (Tài liệu học tập) and its direct children. Rich
article HTML is reduced to text blocks so the preview never injects stored HTML.
"""

from __future__ import annotations

import json
import re
import subprocess
from datetime import date
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "hero-light" / "assets" / "resource-detail-data.json"
CDN = "https://cdn.meduc.vn"
SQL = """
SELECT JSON_OBJECT(
  'id', a.id, 'name', ac.name, 'slug', COALESCE(l.url, ''),
  'description', COALESCE(ac.description, ''),
  'content', COALESCE(ac.content, ''),
  'image', COALESCE(a.image_avatar, ''),
  'files', COALESCE(a.files, '[]'),
  'categories', (SELECT GROUP_CONCAT(DISTINCT ca2.category_id ORDER BY ca2.category_id)
                 FROM categories_article ca2 WHERE ca2.article_id = a.id)
)
FROM articles a
JOIN articles_content ac ON ac.article_id = a.id AND ac.lang = 'vi'
LEFT JOIN links l ON l.id = (
  SELECT MIN(l2.id) FROM links l2 WHERE l2.foreign_id = a.id
    AND l2.type = 'article_detail' AND l2.lang = 'vi' AND l2.deleted = 0
)
WHERE a.deleted = 0 AND a.status = 1
  AND EXISTS (
    SELECT 1 FROM categories_article ca JOIN categories c ON c.id = ca.category_id
    WHERE ca.article_id = a.id AND (c.id = 48 OR c.parent_id = 48)
  )
ORDER BY a.id;
"""


def clean(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


class TextBlocks(HTMLParser):
    BLOCKS = {"p": "paragraph", "h1": "heading", "h2": "heading", "h3": "heading",
              "li": "bullet", "blockquote": "quote"}
    SKIP = {"script", "style", "iframe", "noscript"}

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.blocks: list[dict[str, str]] = []
        self.kind: str | None = None
        self.parts: list[str] = []
        self.depth = 0
        self.skipping = 0

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in self.SKIP:
            self.skipping += 1
        if self.skipping:
            return
        if tag in self.BLOCKS:
            if self.kind is None:
                self.kind = self.BLOCKS[tag]
                self.parts = []
                self.depth = 1
            else:
                self.depth += 1
        elif tag == "br" and self.kind:
            self.parts.append(" ")

    def handle_endtag(self, tag: str) -> None:
        if tag in self.SKIP and self.skipping:
            self.skipping -= 1
            return
        if self.skipping or tag not in self.BLOCKS or self.kind is None:
            return
        self.depth -= 1
        if self.depth == 0:
            value = clean("".join(self.parts))
            if value and (not self.blocks or self.blocks[-1]["text"] != value):
                self.blocks.append({"type": self.kind, "text": value})
            self.kind = None
            self.parts = []

    def handle_data(self, data: str) -> None:
        if self.kind and not self.skipping:
            self.parts.append(data)


def blocks(html: str) -> list[dict[str, str]]:
    parser = TextBlocks()
    parser.feed(html)
    parser.close()
    return parser.blocks


def media_url(value: str) -> str:
    return CDN + value if value.startswith("/media/") else ""


def main() -> None:
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
         'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --batch --raw -N'],
        input=SQL, text=True, capture_output=True, cwd=ROOT, check=True,
    )
    resources = []
    for line in result.stdout.splitlines():
        row = json.loads(line)
        if not row["slug"]:
            raise ValueError(f"Missing URL for enabled resource {row['id']}")
        source_files = json.loads(row["files"] or "[]")
        if not isinstance(source_files, list):
            raise ValueError(f"Invalid file array for resource {row['id']}")
        files = []
        seen_files = set()
        for file in source_files:
            if not isinstance(file, str) or not file.startswith("/media/") or file in seen_files:
                continue
            seen_files.add(file)
            filename = unquote(file.rsplit("/", 1)[-1])
            files.append({"name": filename, "url": media_url(file),
                          "type": filename.rsplit(".", 1)[-1].lower() if "." in filename else "file"})
        content_blocks = blocks(row["content"])
        description_blocks = blocks(row["description"])
        description = clean(" ".join(block["text"] for block in description_blocks))
        if not description:
            description = next((block["text"] for block in content_blocks if block["type"] == "paragraph"), "")
        resources.append({
            "id": row["id"], "name": row["name"], "url": "/" + row["slug"].lstrip("/"),
            "image": media_url(row["image"]), "description": description,
            "blocks": content_blocks, "files": files,
            "categories": [int(item) for item in (row["categories"] or "").split(",") if item],
        })
    if len(resources) != len({item["id"] for item in resources}):
        raise ValueError("Duplicate resource IDs in export")
    TARGET.write_text(json.dumps({"exported": date.today().isoformat(), "count": len(resources), "resources": resources}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(resources)} enabled study resources to {TARGET}")


if __name__ == "__main__":
    main()
