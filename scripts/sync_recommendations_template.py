#!/usr/bin/env python3
"""Mirror the light course recommendation flow into CakePHP."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "recommendations.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "recommendations_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
        ('© 2026 Meduc · Gợi ý khóa học', '© 2026 Meduc'),
    ):
        html = html.replace(source, target)
    TARGET.write_text(
        "<!-- Generated from hero-light/recommendations.html by scripts/sync_recommendations_template.py. -->\n" + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
