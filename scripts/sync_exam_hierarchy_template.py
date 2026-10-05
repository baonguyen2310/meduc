#!/usr/bin/env python3
"""Mirror the light Facourse hierarchy preview into CakePHP's template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "exam-hierarchy.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "exam_hierarchy_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
        ('href="quiz-history.html"', 'href="/lich-su-lam-bai-v2"'),
        ('© 2026 Meduc · Thư viện bộ đề xem trước', '© 2026 Meduc'),
    ):
        html = html.replace(source, target)
    TARGET.write_text(
        '<!-- Generated from hero-light/exam-hierarchy.html by scripts/sync_exam_hierarchy_template.py. -->\n' + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
