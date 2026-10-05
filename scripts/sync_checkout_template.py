#!/usr/bin/env python3
"""Mirror the light checkout HTML into CakePHP's Masterclass template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "checkout.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "checkout_v2.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
        ('href="books.html"', 'href="/sach-y-khoa-v2"'),
        ('© 2026 Meduc · Giao diện thanh toán xem trước', '© 2026 Meduc'),
    ):
        html = html.replace(source, target)
    TARGET.write_text(
        '<!-- Generated from hero-light/checkout.html by scripts/sync_checkout_template.py. -->\n' + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
