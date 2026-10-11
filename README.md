MedUC PHP production baseline
=============================

This branch records the PHP application source found in the original
`meduc.vn` shared hosting account on 2026-10-12, before importing the
2,033 exam set. It branches from the repository's first commit so changes
can be compared or selectively brought over from `main`.

Runtime data and private configuration are intentionally outside Git:
`cdn/`, backups, database dumps, `coredaca/vendor/`, Google service account,
and live database/application credentials. The config files tracked here are
the sanitized placeholders from the first public repository commit. A Git
checkout of this branch is therefore not a deployable copy of the hosting
account without its separate runtime configuration and data.

The original feedback controller contained live notification credentials.
This branch reads the Slack webhook from `MEDUC_FEEDBACK_SLACK_WEBHOOK_URL`
and the SMTP password from `MEDUC_FEEDBACK_SMTP_PASSWORD` instead. Set these
only in the deployment environment if those notification paths are needed.
The old order and customer mailers also read their SMTP passwords from
`MEDUC_DACA_SMTP_PASSWORD` and
`MEDUC_VIRTUAL_ASSISTANT_SMTP_PASSWORD` in this branch.

## Internal exam library (2026-10-12)

Production hosting contains 88 exam preparation courses (category 125),
2,033 review lessons/quizzes and 131,940 questions. Each review lesson links
to exactly one quiz; these imported courses do not need chapters.

- Open `/admin/product?cate=125`, then a course, then an exam title.
- Admins can preview, practice and download a real `.docx` with questions,
  illustrations, answers and explanations. Export uses PHP's existing ZIP,
  DOM, cURL and GD extensions; no new runtime package is required.
- Teachers can preview and practice only within assigned courses. They cannot
  download Word. Assignments remain in `teacher_course_access` and are edited
  using the existing course form. New courses have no teachers by default.
- Practice results stay in browser memory and do not create student attempts.
- `exam_prep_courses.staff_only` and `quiz_exam_metadata.staff_only` block
  imported content from public/student model queries, separately from status
  and draft flags. Changing a publication status alone does not publish them.
- Complete options, multiple answers, essay rubrics and image hashes are kept
  alongside legacy question fields. The old five-option editor cannot overwrite
  imported question data. Image bytes are currently served by the existing
  Civo media endpoint, and Word embeds them into the downloaded document.

Import tooling lives in `scripts/prepare_exam_import.py` and
`scripts/import_private_exams.php`. The PHP CLI script targets the production
hosting paths. Run `schema` before deploying code to a new environment: it
backs up affected tables outside the document root, adds privacy metadata and
widens attribute JSON columns. `import <file.jsonl.gz>` is resumable by the
unique source catalog ID; `verify <file.jsonl.gz>` checks every question and
course curriculum. Original remote IDs are preserved separately because they
are not unique across the 2,033 catalog entries. Keep exports and backups
outside the document root and out of Git. Existing legacy MyISAM tables do not
support transactional rollback; retain the pre-import backup.
