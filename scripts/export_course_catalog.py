#!/usr/bin/env python3
"""Export the public, enabled Meduc course catalog for the light UI preview.

The course list and URLs come from the local Meduc database. Chapter and lesson
counts are the audited counts in danh-sach-63-khoa-hoc-chuong-bai.md.
"""

from __future__ import annotations

import json
import re
import subprocess
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "hero-light" / "assets" / "catalog-data.json"
REPORT = ROOT / "danh-sach-63-khoa-hoc-chuong-bai.md"

SQL = """
SELECT JSON_OBJECT(
  'id', p.id,
  'name', pc.name,
  'slug', COALESCE(l.url, ''),
  'image', COALESCE(JSON_UNQUOTE(JSON_EXTRACT(pi.images, '$[0]')), ''),
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
    WHERE cp.product_id = p.id
      AND cp.category_id IN (50, 102, 72, 103, 105, 67, 68, 69, 70, 71, 106)
  )
ORDER BY p.id;
"""


def read_counts() -> dict[int, tuple[int, int]]:
    result = {}
    pattern = re.compile(r"^\|\s*\d+\s*\|\s*(\d+)\s*\|.*?\|\s*Đang bật\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|$")
    for line in REPORT.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match:
            course_id, chapters, lessons = map(int, match.groups())
            result[course_id] = (chapters, lessons)
    return result


def main() -> None:
    result = subprocess.run(
        ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
         'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -N'],
        input=SQL,
        text=True,
        capture_output=True,
        cwd=ROOT,
        check=True,
    )
    counts = read_counts()
    courses = []
    for line in result.stdout.splitlines():
        row = json.loads(line)
        course_id = row["id"]
        if course_id not in counts:
            raise ValueError(f"Missing audited lesson count for active course {course_id}")
        if not row["slug"]:
            raise ValueError(f"Missing course URL for active course {course_id}")
        chapters, lessons = counts[course_id]
        courses.append({
            "id": course_id,
            "name": row["name"],
            "url": "/" + row["slug"].lstrip("/"),
            "image": "https://cdn.meduc.vn" + row["image"] if row["image"].startswith("/media/") else "",
            "categories": [int(value) for value in (row["categories"] or "").split(",") if value],
            "chapters": chapters,
            "lessons": lessons,
        })
    if set(counts) != {course["id"] for course in courses}:
        raise ValueError("Audited enabled courses differ from the local database")
    payload = {"exported": date.today().isoformat(), "count": len(courses), "courses": courses}
    TARGET.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(courses)} enabled courses to {TARGET}")


if __name__ == "__main__":
    main()
