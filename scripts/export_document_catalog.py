#!/usr/bin/env python3
"""Export enabled Meduc study documents for the light catalog preview."""

from __future__ import annotations

import html
import json
import re
import subprocess
from datetime import date, datetime
from html.parser import HTMLParser
from pathlib import Path
from zoneinfo import ZoneInfo


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "hero-light" / "assets" / "document-catalog.json"
CATEGORIES = (48, 73, 74, 75, 76, 77, 78, 121, 122, 123, 124)

SQL = f"""
SELECT JSON_OBJECT(
  'id', a.id, 'name', ac.name, 'description', COALESCE(ac.description, ''),
  'slug', COALESCE(l.url, ''), 'image', COALESCE(a.image_avatar, ''),
  'files', COALESCE(a.files, '[]'), 'created', a.created,
  'categories', (SELECT GROUP_CONCAT(DISTINCT ca2.category_id ORDER BY ca2.category_id)
                 FROM categories_article ca2 WHERE ca2.article_id = a.id)
)
FROM articles a
JOIN articles_content ac ON ac.article_id = a.id AND ac.lang = 'vi'
LEFT JOIN links l ON l.id = (
  SELECT MIN(l2.id) FROM links l2
  WHERE l2.foreign_id = a.id AND l2.type = 'article_detail'
    AND l2.lang = 'vi' AND l2.deleted = 0
)
WHERE a.status = 1 AND a.deleted = 0
  AND EXISTS (
    SELECT 1 FROM categories_article ca
    WHERE ca.article_id = a.id AND ca.category_id IN {CATEGORIES}
  )
ORDER BY a.created DESC, a.id DESC;
"""


class PlainText(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.parts: list[str] = []

    def handle_data(self, data: str) -> None:
        self.parts.append(data)


def summary(markup: str) -> str:
    parser = PlainText()
    parser.feed(markup)
    content = re.sub(r"\s+", " ", html.unescape(" ".join(parser.parts))).strip()
    return content[:177].rstrip() + "…" if len(content) > 180 else content


def main() -> None:
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
         'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --batch --raw -N'],
        input=SQL, text=True, capture_output=True, cwd=ROOT, check=True,
    )
    documents = []
    for line in result.stdout.splitlines():
        row = json.loads(line)
        if not row["slug"]:
            raise ValueError(f"Missing URL for active document {row['id']}")
        files = json.loads(row["files"]) if isinstance(row["files"], str) else row["files"]
        if not isinstance(files, list):
            raise ValueError(f"Unexpected file data for document {row['id']}")
        cover = row["image"]
        documents.append({
            "id": row["id"], "name": row["name"], "summary": summary(row["description"]),
            "url": "/" + row["slug"].lstrip("/"),
            "image": "https://cdn.meduc.vn" + cover if cover.startswith("/media/") else "",
            "fileCount": sum(isinstance(item, str) and bool(item) for item in files),
            "date": datetime.fromtimestamp(int(row["created"]), ZoneInfo("Asia/Ho_Chi_Minh")).date().isoformat(),
            "categories": [int(item) for item in (row["categories"] or "").split(",") if item],
        })
    if len(documents) != len({item["id"] for item in documents}):
        raise ValueError("Duplicate document IDs in export")
    TARGET.write_text(json.dumps({"exported": date.today().isoformat(), "count": len(documents), "documents": documents}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(documents)} enabled documents to {TARGET}")


if __name__ == "__main__":
    main()
