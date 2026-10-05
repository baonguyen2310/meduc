#!/usr/bin/env python3
"""Export enabled course and book prices for the checkout design preview."""

from __future__ import annotations

import json
import subprocess
from datetime import date
from decimal import Decimal
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "hero-light" / "assets"
TARGET = ASSETS / "checkout-catalog.json"


def read_source(filename: str, key: str) -> list[dict]:
    payload = json.loads((ASSETS / filename).read_text(encoding="utf-8"))
    if len(payload[key]) != payload["count"]:
        raise ValueError(f"Invalid count in {filename}")
    return payload[key]


def main() -> None:
    courses = read_source("catalog-data.json", "courses")
    books = read_source("book-catalog.json", "books")
    source = [("course", item) for item in courses] + [("book", item) for item in books]
    ids = [int(item["id"]) for _, item in source]
    if len(ids) != len(set(ids)):
        raise ValueError("Product IDs overlap across course and book catalogs")

    sql = f"""
SELECT JSON_OBJECT('id', p.id, 'item_id', pi.id,
                   'price', pi.price, 'special', pi.price_special)
FROM products p
JOIN products_item pi ON pi.id = (
    SELECT MIN(pi2.id) FROM products_item pi2
    WHERE pi2.product_id = p.id AND pi2.deleted = 0 AND pi2.status = 1
)
WHERE p.deleted = 0 AND p.status = 1 AND p.id IN ({','.join(map(str, ids))})
ORDER BY p.id;
"""
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
         'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --batch --raw -N'],
        input=sql, text=True, capture_output=True, cwd=ROOT, check=True,
    )
    prices = {row["id"]: row for row in map(json.loads, result.stdout.splitlines())}
    if set(prices) != set(ids):
        raise ValueError(f"Missing active product items: {set(ids) - set(prices)}")

    items = []
    for kind, item in source:
        row = prices[item["id"]]
        regular = int(Decimal(str(row["price"])))
        special = int(Decimal(str(row["special"] or 0)))
        if regular <= 0:
            raise ValueError(f"Product {item['id']} has no published price")
        items.append({
            "id": item["id"], "item_id": row["item_id"], "type": kind,
            "name": item["name"], "url": item["url"], "image": item["image"],
            "price": regular, "special": special if 0 < special < regular else 0,
            "chapters": item.get("chapters", 0), "lessons": item.get("lessons", 0),
        })

    payload = {"exported": date.today().isoformat(), "count": len(items), "items": items}
    TARGET.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(courses)} courses and {len(books)} books to {TARGET}")


if __name__ == "__main__":
    main()
