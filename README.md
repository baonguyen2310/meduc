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
