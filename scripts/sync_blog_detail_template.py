#!/usr/bin/env python3
"""Mirror the light article detail page into CakePHP's preview template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "blog-detail.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "blog_detail_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
        ('href="documents.html"', 'href="/tai-lieu-hoc-tap-v2"'),
        ('href="blog.html"', 'href="/blog-v2"'),
        ('© 2026 Meduc · Bản xem trước giao diện chi tiết blog', '© 2026 Meduc'),
    ):
        html = html.replace(source, target)
    TARGET.write_text(
        '<!-- Generated from hero-light/blog-detail.html by scripts/sync_blog_detail_template.py. -->\n' + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
