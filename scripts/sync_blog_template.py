#!/usr/bin/env python3
"""Mirror the light blog listing into CakePHP's /blog-v2 template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "blog.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "blog_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="about.html"', 'href="/gioi-thieu-v2"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
        ('href="books.html"', 'href="/sach-y-khoa-v2"'),
        ('href="documents.html"', 'href="/tai-lieu-hoc-tap-v2"'),
        ('© 2026 Meduc · Bản xem trước giao diện blog', '© 2026 Meduc'),
    ):
        html = html.replace(source, target)
    TARGET.write_text(
        '<!-- Generated from hero-light/blog.html by scripts/sync_blog_template.py. -->\n' + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
