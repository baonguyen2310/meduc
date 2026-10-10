#!/usr/bin/env bash
set -euo pipefail

# Run as root on civo-01 after MEDUC_2033_API_KEY is set in meduc.env.
if [[ $(id -u) -ne 0 ]]; then
  echo 'Run this deployment as root on civo-01.' >&2
  exit 1
fi

source_dir=/opt/meduc-php/src
app_dir=/opt/meduc-php/app
secret_file=/opt/meduc-php/secrets/meduc.env

if [[ ! -f "$secret_file" ]] || ! grep -q '^MEDUC_2033_API_KEY=.' "$secret_file"; then
  echo 'Set MEDUC_2033_API_KEY in /opt/meduc-php/secrets/meduc.env first.' >&2
  exit 1
fi

git -C "$source_dir" pull --ff-only origin main

cd "$source_dir"
rsync -a --relative \
  compose.production.yml \
  coredaca/config/routes.php \
  coredaca/plugins/Admin/src/Controller/AppController.php \
  coredaca/plugins/Admin/src/Controller/UserController.php \
  coredaca/plugins/Admin/src/Controller/TeacherExamController.php \
  coredaca/plugins/Admin/templates/TeacherExam/index.tpl \
  coredaca/plugins/Admin/templates/element/layout/menu_left.tpl \
  coredaca/src/Service/TeacherExamLibrary.php \
  coredaca/src/Service/ExamWordExporter.php \
  hero-light/assets/exam-hierarchy-data.json \
  hero-light/assets/teacher-exams.css \
  hero-light/assets/teacher-exams.js \
  "$app_dir/"

docker exec -i meduc_php_db sh -lc \
  'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot "$MARIADB_DATABASE"' \
  < "$source_dir/scripts/teacher_exam_access.sql"

cd "$app_dir"
docker compose --env-file "$secret_file" -f compose.production.yml up -d --no-deps --force-recreate web

status=$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:8081/admin/teacher-exams)
if [[ "$status" != '302' ]]; then
  echo "Unexpected teacher-exam page status: $status" >&2
  exit 1
fi
echo 'Deployed teacher exam workspace. Open https://meducv2.duckdns.org/admin/teacher-exams'
