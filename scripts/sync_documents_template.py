#!/usr/bin/env python3
"""Mirror the light document list into CakePHP's preview template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "documents.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "documents_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    html = html.replace('href="assets/', 'href="/hero-light/assets/')
    html = html.replace('src="assets/', 'src="/hero-light/assets/')
    html = html.replace('href="index.html"', 'href="/masterclass"')
    html = html.replace('href="about.html"', 'href="/gioi-thieu-v2"')
    html = html.replace('href="courses.html"', 'href="/khoa-hoc-v2"')
    html = html.replace('href="books.html"', 'href="/sach-y-khoa-v2"')
    html = html.replace('© 2026 Meduc · Bản xem trước giao diện danh sách tài liệu', '© 2026 Meduc')
    html = '<!-- Generated from hero-light/documents.html by scripts/sync_documents_template.py. -->\n' + html
    TARGET.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main()
