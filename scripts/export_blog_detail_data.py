#!/usr/bin/env python3
"""Export safe, lightweight reading content for enabled Meduc blog posts."""

from __future__ import annotations

import html
import json
import re
import subprocess
from datetime import date
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urljoin, urlparse


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "hero-light" / "assets" / "blog-detail-data.json"
BLOG_CATEGORIES = (45, 91, 92, 93, 94, 95, 96, 100, 113, 114, 115, 116, 117, 118, 119)

SQL = f"""
SELECT JSON_OBJECT(
  'id', a.id, 'name', ac.name, 'description', COALESCE(ac.description, ''),
  'content', REGEXP_REPLACE(COALESCE(ac.content, ''), 'data:image[^" ]*', ''),
  'image', COALESCE(a.image_avatar, ''),
  'slug', COALESCE(l.url, ''),
  'date', DATE_FORMAT(FROM_UNIXTIME(a.created), '%Y-%m-%d'),
  'categories', (SELECT GROUP_CONCAT(DISTINCT ca2.category_id ORDER BY ca2.category_id)
                 FROM categories_article ca2 WHERE ca2.article_id = a.id)
)
FROM articles a
JOIN articles_content ac ON ac.article_id = a.id AND ac.lang = 'vi'
LEFT JOIN links l ON l.id = (
  SELECT MIN(l2.id) FROM links l2 WHERE l2.foreign_id = a.id
    AND l2.type = 'article_detail' AND l2.lang = 'vi' AND l2.deleted = 0
)
WHERE a.status = 1 AND a.deleted = 0
  AND EXISTS (SELECT 1 FROM categories_article ca
              WHERE ca.article_id = a.id AND ca.category_id IN {BLOG_CATEGORIES})
ORDER BY a.created DESC, a.id DESC;
"""


class TextOnly(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []

    def handle_data(self, data: str) -> None:
        self.parts.append(data)


def plain_text(markup: str) -> str:
    parser = TextOnly()
    parser.feed(markup)
    return re.sub(r"\s+", " ", html.unescape(" ".join(parser.parts))).strip()


def safe_url(value: str, *, image: bool = False) -> str:
    value = html.unescape(value.strip())
    if not value or value.startswith(("data:", "javascript:", "vbscript:")):
        return ""
    if value.startswith("//"):
        value = "https:" + value
    elif not urlparse(value).scheme:
        value = urljoin("https://meduc.vn/", value)
    parsed = urlparse(value)
    if parsed.scheme not in ("https", "http"):
        return ""
    if image and parsed.hostname not in ("meduc.vn", "www.meduc.vn", "cdn.meduc.vn"):
        return ""
    if image and parsed.hostname in ("meduc.vn", "www.meduc.vn") and parsed.path.startswith("/media/"):
        value = "https://cdn.meduc.vn" + parsed.path + ("?" + parsed.query if parsed.query else "")
    return value


class ArticleHTML(HTMLParser):
    BLOCKED = {"script", "style", "iframe", "object", "embed", "form", "button", "input", "svg", "canvas", "video", "audio", "noscript"}
    ALLOWED = {"p", "h1", "h2", "h3", "h4", "ul", "ol", "li", "strong", "b", "em", "i", "u", "blockquote", "a", "img", "br", "hr", "figure", "figcaption", "table", "thead", "tbody", "tr", "th", "td", "sup", "sub", "pre", "code"}
    VOID = {"img", "br", "hr"}

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self.text_parts: list[str] = []
        self.blocked: list[str] = []
        self.image_count = 0

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if self.blocked:
            if tag in self.BLOCKED:
                self.blocked.append(tag)
            return
        if tag in self.BLOCKED:
            self.blocked.append(tag)
            return
        if tag not in self.ALLOWED:
            return
        attributes = dict(attrs)
        if tag == "img":
            src = safe_url(attributes.get("src") or "", image=True)
            if not src:
                return
            alt = html.escape(attributes.get("alt") or "Ảnh minh họa bài viết", quote=True)
            self.parts.append(f'<img src="{html.escape(src, quote=True)}" alt="{alt}" loading="lazy" />')
            self.image_count += 1
            return
        if tag == "a":
            href = safe_url(attributes.get("href") or "")
            if href:
                self.parts.append(f'<a href="{html.escape(href, quote=True)}" target="_blank" rel="noopener noreferrer">')
            else:
                self.parts.append('<a href="#">')
            return
        rendered_tag = "h2" if tag == "h1" else tag
        self.parts.append(f"<{rendered_tag}>")

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)

    def handle_endtag(self, tag: str) -> None:
        if self.blocked:
            if tag == self.blocked[-1]:
                self.blocked.pop()
            return
        if tag in self.ALLOWED and tag not in self.VOID:
            rendered_tag = "h2" if tag == "h1" else tag
            self.parts.append(f"</{rendered_tag}>")

    def handle_data(self, data: str) -> None:
        if self.blocked:
            return
        if data.strip():
            self.text_parts.append(data)
        self.parts.append(html.escape(data))


def clean_article(markup: str) -> tuple[str, str, int]:
    parser = ArticleHTML()
    parser.feed(markup)
    content = "".join(parser.parts)
    content = re.sub(r"<(p|h2|h3|h4|figure)>\s*</\1>", "", content, flags=re.I)
    content = re.sub(r"(?:<br>\s*){3,}", "<br><br>", content, flags=re.I)
    text = re.sub(r"\s+", " ", " ".join(parser.text_parts)).strip()
    return content, text, parser.image_count


def article_summary(description: str, readable: str) -> str:
    text = plain_text(description) or readable
    if len(text) <= 290:
        return text
    sentences = re.split(r"(?<=[.!?])\s+", text)
    selected = ""
    for sentence in sentences:
        candidate = f"{selected} {sentence}".strip()
        if len(candidate) > 290:
            break
        selected = candidate
    if len(selected) >= 90:
        return selected
    return text[:290].rsplit(" ", 1)[0].rstrip(".,;:") + "…"


def main() -> None:
    command = ["docker", "compose", "exec", "-T", "db", "sh", "-lc",
               'mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --batch --raw -N']
    process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, text=True, cwd=ROOT)
    assert process.stdin is not None and process.stdout is not None and process.stderr is not None
    process.stdin.write(SQL)
    process.stdin.close()
    articles = []
    for line in process.stdout:
        row = json.loads(line)
        if not row["slug"]:
            process.kill()
            raise ValueError(f"Missing URL for enabled blog article {row['id']}")
        content, readable, image_count = clean_article(row["content"])
        summary = article_summary(row["description"], readable)
        cover = row["image"]
        words = len(readable.split())
        articles.append({
            "id": row["id"], "name": row["name"].strip(),
            "summary": summary,
            "url": "/" + row["slug"].lstrip("/"),
            "image": "https://cdn.meduc.vn" + cover if cover.startswith("/media/") else "",
            "date": row["date"],
            "categories": [int(value) for value in (row["categories"] or "").split(",") if value],
            "minutes": max(1, round(words / 220)),
            "content": content,
            "bodyImages": image_count,
            "wordCount": words,
        })
    error = process.stderr.read()
    return_code = process.wait()
    if return_code:
        raise RuntimeError(f"MariaDB export failed ({return_code}): {error[-1000:]}")
    if len(articles) != len({article["id"] for article in articles}):
        raise ValueError("Duplicate blog article IDs in export")
    payload = {"exported": date.today().isoformat(), "count": len(articles), "articles": articles}
    TARGET.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Wrote {len(articles)} enabled blog posts to {TARGET} ({TARGET.stat().st_size / 1024 / 1024:.2f} MiB)")
    print(f"Text words: {sum(article['wordCount'] for article in articles)}; preserved body images: {sum(article['bodyImages'] for article in articles)}")


if __name__ == "__main__":
    main()
