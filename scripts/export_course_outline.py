#!/usr/bin/env python3
"""Export audited Meduc chapter and lesson names for enabled course previews."""

from __future__ import annotations

import html
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "danh-sach-63-khoa-hoc-chuong-bai.md"
CATALOG = ROOT / "hero-light" / "assets" / "catalog-data.json"
TARGET = ROOT / "hero-light" / "assets" / "course-outline.json"


def clean(value: str) -> str:
    return html.unescape(value).replace("\\[", "[").replace("\\]", "]").strip()


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    active_ids = {course["id"] for course in catalog["courses"]}
    source = REPORT.read_text(encoding="utf-8")
    blocks = re.split(r'(?=<a id="khoa-\d+"></a>)', source)
    outlines = {}
    for block in blocks:
        match = re.search(r'<a id="khoa-(\d+)"></a>', block)
        if not match:
            continue
        course_id = int(match.group(1))
        if course_id not in active_ids:
            continue
        expected = re.search(r'\*\*Chương:\*\* (\d+) · \*\*Bài học:\*\* (\d+)', block)
        if not expected or '**Trạng thái:** Đang bật' not in block:
            raise ValueError(f"Course {course_id} is not an audited enabled course")

        chapters = []
        current = None
        for line in block.splitlines():
            if line.startswith("#### "):
                current = {"title": clean(line[5:]), "lessons": []}
                chapters.append(current)
            elif line.startswith("- "):
                if current is None:
                    current = {"title": "Nội dung khóa học", "lessons": []}
                    chapters.append(current)
                current["lessons"].append(clean(line[2:]))
        actual_chapters = sum(chapter["title"] != "Nội dung khóa học" for chapter in chapters)
        actual_lessons = sum(len(chapter["lessons"]) for chapter in chapters)
        if (actual_chapters, actual_lessons) != tuple(map(int, expected.groups())):
            raise ValueError(f"Unexpected outline count for course {course_id}: {actual_chapters}, {actual_lessons}")
        catalog_course = next(course for course in catalog["courses"] if course["id"] == course_id)
        if (actual_chapters, actual_lessons) != (catalog_course["chapters"], catalog_course["lessons"]):
            raise ValueError(f"Catalog count mismatch for course {course_id}")
        outlines[str(course_id)] = chapters

    if set(map(int, outlines)) != active_ids:
        raise ValueError("Outline does not cover every enabled course")
    TARGET.write_text(json.dumps({"source": REPORT.name, "outlines": outlines}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(outlines)} course outlines to {TARGET}")


if __name__ == "__main__":
    main()
