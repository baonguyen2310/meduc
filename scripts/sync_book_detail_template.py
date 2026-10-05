#!/usr/bin/env python3
"""Mirror the static book detail preview into CakePHP's preview template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "book-detail.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "book_detail_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="books.html"', 'href="/sach-y-khoa-v2"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
        ('href="checkout.html"', 'href="/thanh-toan-v2"'),
        ('© 2026 Meduc · Bản xem trước giao diện chi tiết sách', '© 2026 Meduc'),
    ):
        html = html.replace(source, target)
    TARGET.write_text(
        '<!-- Generated from hero-light/book-detail.html by scripts/sync_book_detail_template.py. -->\n' + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
