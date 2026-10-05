#!/usr/bin/env python3
"""Build the page-16 browse index from Meduc Cao's audited Facourse CSVs."""

from __future__ import annotations

import csv
import json
import re
from collections import Counter
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parent / "meduc-cao" / "data"
EXAMS = SOURCE / "danh_sach_2033_de_thi_toan_dien_hk_va_ky.csv"
MAPPING = SOURCE / "chi_tiet_445_danh_muc_mon_va_module.csv"
TARGET = ROOT / "hero-light" / "assets" / "exam-hierarchy-data.json"
YEAR = re.compile(r"(?<!\d)(20[0-3]\d)(?!\d)")


def rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as source:
        return list(csv.DictReader(source))


def main() -> None:
    raw_exams = rows(EXAMS)
    mapping = rows(MAPPING)
    by_category = {row["Category ID"]: row for row in mapping}
    if len(by_category) != len(mapping):
        raise ValueError("Duplicate category IDs in the subject/module mapping")

    exams = []
    for row in raw_exams:
        category = by_category.get(row["category_id"])
        if category is None:
            raise ValueError(f"Unmapped category {row['category_id']}")
        years = [int(match.group()) for match in YEAR.finditer(row["name"])]
        group = category["Nhóm phân loại"].strip()
        exams.append({
            "id": int(row["id"]),
            "title": row["name"].strip(),
            "school": category["Trường đào tạo"].strip(),
            "year": max(years) if years else None,
            "type": "module" if group.startswith("Module tích hợp") else "subject",
            "group": group,
            "topic": category["Môn học / Module chuẩn hóa"].strip(),
            "category": category["Tên danh mục gốc"].strip(),
            "categoryId": int(row["category_id"]),
            "questions": int(row["total_questions"]),
            "pro": row["is_pro"] == "1",
        })

    ids = {exam["id"] for exam in exams}
    questions = sum(exam["questions"] for exam in exams)
    schools = {exam["school"] for exam in exams}
    topics = {exam["topic"] for exam in exams}
    if len(exams) != 2033 or len(ids) != len(exams) or questions != 131980:
        raise ValueError("Facourse source totals do not match the audited 2,033 exams")
    if len(schools) != 32 or len(topics) != 88:
        raise ValueError("Normalized school/topic counts changed unexpectedly")
    years = Counter(str(exam["year"]) if exam["year"] else "undated" for exam in exams)
    if years["undated"] != 1011:
        raise ValueError("Undated count no longer matches the prior matrix")

    payload = {
        "exported": date.today().isoformat(),
        "source": "meduc-cao/data/danh_sach_2033_de_thi_toan_dien_hk_va_ky.csv",
        "yearRule": "Largest four-digit 20xx in title; includes cohort codes such as Y2022; not verified exam date.",
        "count": len(exams),
        "questions": questions,
        "schools": len(schools),
        "topics": len(topics),
        "categories": len({exam["categoryId"] for exam in exams}),
        "undated": years["undated"],
        "exams": exams,
    }
    TARGET.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Wrote {len(exams)} exams, {len(schools)} schools, {len(topics)} topics to {TARGET}")


if __name__ == "__main__":
    main()
