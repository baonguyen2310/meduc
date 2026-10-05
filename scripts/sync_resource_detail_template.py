#!/usr/bin/env python3
"""Mirror the resource detail page into CakePHP's preview template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "resource-detail.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "resource_detail_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    html = html.replace('href="assets/', 'href="/hero-light/assets/')
    html = html.replace('src="assets/', 'src="/hero-light/assets/')
    html = html.replace('href="index.html"', 'href="/masterclass"')
    html = html.replace('href="courses.html"', 'href="/khoa-hoc-v2"')
    html = html.replace('href="documents.html"', 'href="/tai-lieu-hoc-tap-v2"')
    html = html.replace('© 2026 Meduc · Bản xem trước giao diện chi tiết tài liệu', '© 2026 Meduc')
    html = '<!-- Generated from hero-light/resource-detail.html by scripts/sync_resource_detail_template.py. -->\n' + html
    TARGET.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main()
