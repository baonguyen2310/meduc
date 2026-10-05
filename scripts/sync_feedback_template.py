#!/usr/bin/env python3
"""Mirror the light feedback page into CakePHP's /phan-hoi-hoc-vien-v2 template."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "feedback.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "feedback.tpl"


def replace_live_href(match: re.Match[str]) -> str:
    anchor = match.group(0)
    live = re.search(r'data-live-href="([^"]+)"', anchor)
    if live:
        anchor = re.sub(r'href="[^"]+"', f'href="{live.group(1)}"', anchor, count=1)
        anchor = re.sub(r' data-live-href="[^"]+"', '', anchor)
    return anchor


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    html = html.replace('href="assets/', 'href="/hero-light/assets/')
    html = html.replace('src="assets/', 'src="/hero-light/assets/')
    html = html.replace('href="index.html"', 'href="/masterclass"')
    html = html.replace('href="about.html"', 'href="/gioi-thieu-v2"')
    html = re.sub(r"<a\b[^>]*>", replace_live_href, html, flags=re.S)
    html = html.replace('© 2026 Meduc · Bản xem trước giao diện phản hồi', '© 2026 Meduc')
    html = '<!-- Generated from hero-light/feedback.html by scripts/sync_feedback_template.py. -->\n' + html
    TARGET.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main()
