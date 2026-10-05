#!/usr/bin/env python3
"""Mirror the reviewed light homepage into CakePHP's /masterclass template."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "index.html"
TARGET = ROOT / "templates" / "app01" / "Masterclass" / "index.tpl"


def live_url(demo_path: str) -> str:
    if demo_path.startswith("course_detail.html"):
        mapping = {
            "anatomy": "giai-phau-1-2-co-ban-chuyen-sau",
            "clinical-thinking": "lam-sang-noi-khoa-co-ban-chuyen-sau",
            "surgery": "lam-sang-ngoai-khoa-co-ban-chuyen-sau",
            "ecg": "ly-thuyet-lam-sang-ecg-co-ban-chuyen-sau",
            "physiology": "sinh-ly-1-2-co-ban-chuyen-sau",
            "examination": "ngoai-co-so-ngoai-trieu-chung-co-ban-chuyen-sau",
        }
        match = re.search(r"[?&]id=([^&]+)", demo_path)
        slug = mapping.get(match.group(1)) if match else None
        return f"/khoa-hoc-chi-tiet-v2?course={slug}" if slug else "/khoa-hoc-v2"
    if demo_path.startswith("courses.html"):
        group = re.search(r"[?&]nhom=([^&]+)", demo_path)
        return "/khoa-hoc-v2" + (f"?nhom={group.group(1)}" if group else "")
    if demo_path.startswith(("exams.html", "practice.html", "leaderboard.html")):
        return "/danh-sach-de-thi"
    if demo_path.startswith("instructors.html"):
        return "/gioi-thieu-v2#doi-ngu"
    if demo_path.startswith(("blog.html", "article_detail.html")):
        return "/blog-v2"
    return "/khoa-hoc-v2"


def update_anchor(match: re.Match[str]) -> str:
    anchor = match.group(0)
    demo = re.search(r'data-demo="([^"]+)"', anchor)
    if demo:
        anchor = re.sub(r'href="[^"]+"', f'href="{live_url(demo.group(1))}"', anchor, count=1)
    # Product and section links within this same PHP site should stay in the tab.
    anchor = anchor.replace('href="https://meduc.vn/', 'href="/')
    if 'href="/' in anchor:
        anchor = anchor.replace(' target="_blank" rel="noopener noreferrer"', "")
    return anchor


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    html = html.replace('href="assets/', 'href="/hero-light/assets/')
    html = html.replace('src="assets/', 'src="/hero-light/assets/')
    html = html.replace('href="index.html"', 'href="/masterclass"')
    html = html.replace('href="about.html"', 'href="/gioi-thieu-v2"')
    html = html.replace('href="feedback.html"', 'href="/phan-hoi-hoc-vien-v2"')
    html = html.replace('href="courses.html"', 'href="/khoa-hoc-v2"')
    html = html.replace('href="books.html"', 'href="/sach-y-khoa-v2"')
    html = html.replace('href="documents.html"', 'href="/tai-lieu-hoc-tap-v2"')
    html = html.replace('href="blog.html"', 'href="/blog-v2"')
    html = html.replace('href="course-detail.html?', 'href="/khoa-hoc-chi-tiet-v2?')
    html = re.sub(r"<a\b[^>]*>", update_anchor, html, flags=re.S)
    html = html.replace('© 2026 Meduc · Bản xem trước giao diện trang chủ', '© 2026 Meduc')
    html = '<!-- Generated from hero-light/index.html by scripts/sync_homepage_template.py. -->\n' + html
    TARGET.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main()
