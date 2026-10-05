#!/usr/bin/env python3
"""Mirror the quiz history preview into the CakePHP Smarty template."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "hero-light" / "quiz-history.html"
TARGET = ROOT / "templates" / "app01" / "QuizHistory" / "index.tpl"


def main() -> None:
    html = SOURCE.read_text(encoding="utf-8")
    for source, target in (
        ('href="assets/', 'href="/hero-light/assets/'),
        ('src="assets/', 'src="/hero-light/assets/'),
        ('href="index.html"', 'href="/masterclass"'),
        ('href="my-courses.html"', 'href="/khoa-hoc-dang-tham-gia-v2"'),
        ('href="courses.html"', 'href="/khoa-hoc-v2"'),
    ):
        html = html.replace(source, target)
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(
        '<!-- Generated from hero-light/quiz-history.html by scripts/sync_quiz_history_template.py. -->\n' + html,
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
