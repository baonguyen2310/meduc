#!/usr/bin/env python3
"""Export enabled Meduc books for the light book catalog preview."""

from __future__ import annotations

import json
import subprocess
from datetime import date
from decimal import Decimal
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "hero-light" / "assets" / "book-catalog.json"
BOOK_CATEGORIES = (79, 81, 82, 83, 84, 85, 86, 109, 110, 111)

SQL = f"""
SELECT JSON_OBJECT(
  'id', p.id, 'name', pc.name, 'slug', COALESCE(l.url, ''),
  'image', COALESCE(JSON_UNQUOTE(JSON_EXTRACT(pi.images, '$[0]')), ''),
  'price', pi.price, 'special', pi.price_special,
  'categories', (SELECT GROUP_CONCAT(DISTINCT cp2.category_id ORDER BY cp2.category_id)
                 FROM categories_product cp2 WHERE cp2.product_id = p.id)
)
FROM products p
JOIN products_content pc ON pc.product_id = p.id AND pc.lang = 'vi'
LEFT JOIN products_item pi ON pi.id = (
  SELECT MIN(pi2.id) FROM products_item pi2
  WHERE pi2.product_id = p.id AND pi2.deleted = 0
)
LEFT JOIN links l ON l.id = (
  SELECT MIN(l2.id) FROM links l2
  WHERE l2.foreign_id = p.id AND l2.type = 'product_detail'
    AND l2.lang = 'vi' AND l2.deleted = 0
)
WHERE p.deleted = 0 AND p.status = 1
  AND EXISTS (
    SELECT 1 FROM categories_product cp
    WHERE cp.product_id = p.id AND cp.category_id IN {BOOK_CATEGORIES}
  )
ORDER BY p.id;
"""


def price(value: object) -> int | None:
    return int(Decimal(str(value))) if value is not None else None


def main() -> None:
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
         'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --batch --raw -N'],
        input=SQL, text=True, capture_output=True, cwd=ROOT, check=True,
    )
    books = []
    for line in result.stdout.splitlines():
        row = json.loads(line)
        if not row["slug"]:
            raise ValueError(f"Missing URL for active book {row['id']}")
        cover = row["image"]
        books.append({
            "id": row["id"], "name": row["name"],
            "url": "/" + row["slug"].lstrip("/"),
            "image": "https://cdn.meduc.vn" + cover if cover.startswith("/media/") else "",
            "price": price(row["price"]), "special": price(row["special"]),
            "categories": [int(item) for item in (row["categories"] or "").split(",") if item],
        })
    if len(books) != len({book["id"] for book in books}):
        raise ValueError("Duplicate book IDs in export")
    TARGET.write_text(json.dumps({"exported": date.today().isoformat(), "count": len(books), "books": books}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(books)} enabled books to {TARGET}")


if __name__ == "__main__":
    main()
