#!/usr/bin/env python3
"""Export enabled Meduc blog articles for the light editorial catalog."""

from __future__ import annotations

import html
import json
import re
import subprocess
from datetime import date
from html.parser import HTMLParser
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "hero-light" / "assets" / "blog-catalog.json"
BLOG_CATEGORIES = (45, 91, 92, 93, 94, 95, 96, 100, 113, 114, 115, 116, 117, 118, 119)

SQL = f"""
SELECT JSON_OBJECT(
  'id', a.id, 'name', ac.name, 'description', COALESCE(ac.description, ''),
  'image', COALESCE(a.image_avatar, ''), 'date', DATE_FORMAT(FROM_UNIXTIME(a.created), '%Y-%m-%d'),
  'slug', COALESCE(l.url, ''),
  'categories', (SELECT GROUP_CONCAT(DISTINCT ca2.category_id ORDER BY ca2.category_id)
                 FROM categories_article ca2 WHERE ca2.article_id = a.id)
)
FROM articles a
JOIN articles_content ac ON ac.article_id = a.id AND ac.lang = 'vi'
LEFT JOIN links l ON l.id = (
  SELECT MIN(l2.id) FROM links l2 WHERE l2.foreign_id = a.id
    AND l2.type = 'article_detail' AND l2.lang = 'vi' AND l2.deleted = 0
)
WHERE a.status = 1 AND a.deleted = 0
  AND EXISTS (SELECT 1 FROM categories_article ca
              WHERE ca.article_id = a.id AND ca.category_id IN {BLOG_CATEGORIES})
ORDER BY a.created DESC, a.id DESC;
"""


class TextOnly(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []

    def handle_data(self, data: str) -> None:
        self.parts.append(data)


def plain_text(markup: str, limit: int = 230) -> str:
    parser = TextOnly()
    parser.feed(markup)
    text = re.sub(r"\s+", " ", html.unescape(" ".join(parser.parts))).strip()
    if len(text) <= limit:
        return text
    return text[:limit].rsplit(" ", 1)[0].rstrip(".,;:") + "…"


def main() -> None:
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
         'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --batch --raw -N'],
        input=SQL, text=True, capture_output=True, cwd=ROOT, check=True,
    )
    articles = []
    for line in result.stdout.splitlines():
        row = json.loads(line)
        if not row["slug"]:
            raise ValueError(f"Missing URL for enabled blog article {row['id']}")
        image = row["image"]
        articles.append({
            "id": row["id"],
            "name": row["name"].strip(),
            "summary": plain_text(row["description"]),
            "image": "https://cdn.meduc.vn" + image if image.startswith("/media/") else "",
            "date": row["date"],
            "url": "/" + row["slug"].lstrip("/"),
            "categories": [int(value) for value in (row["categories"] or "").split(",") if value],
        })
    if len(articles) != len({article["id"] for article in articles}):
        raise ValueError("Duplicate blog IDs in export")
    TARGET.write_text(
        json.dumps({"exported": date.today().isoformat(), "count": len(articles), "articles": articles},
                   ensure_ascii=False, indent=2) + "\n", encoding="utf-8",
    )
    print(f"Wrote {len(articles)} enabled blog articles to {TARGET}")


if __name__ == "__main__":
    main()
