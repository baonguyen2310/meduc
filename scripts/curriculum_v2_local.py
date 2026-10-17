#!/usr/bin/env python3
"""Replace the local 88-topic draft with the approved 108-subject curriculum.

Target: the MariaDB backing localhost:8080. Source: the separate local
fhd_quiz_source MySQL database. Run without --apply to inspect the plan.
--apply requires a verified full SQL backup outside the web root.
"""
from __future__ import annotations

import argparse
import configparser
import gzip
import hashlib
import json
import re
import sys
import time
import unicodedata
from collections import defaultdict
from pathlib import Path

import pymysql

ROOT = Path(__file__).resolve().parents[1]
MAIN = Path('/Users/Shared/architecture/meduc')
SOURCE = Path('/Users/Shared/architecture/meduc-cao')
VERSION = 'mon_v2'
COUNTS = {'subjects': 108, 'chapters': 804, 'lessons': 2971, 'review_chapters': 108, 'review_lessons': 108}


def require(ok, message):
    if not ok:
        raise RuntimeError(message)


def connect_source():
    cfg = configparser.ConfigParser()
    require(cfg.read(SOURCE / '.local/source-db/client.cnf'), 'Missing source DB config')
    c = cfg['client']
    return pymysql.connect(host=c.get('host', '127.0.0.1'), port=c.getint('port', 3308),
                           user=c['user'], password=c['password'], database='fhd_quiz_source',
                           charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor)


def connect_target():
    env = {}
    for line in (MAIN / '.env').read_text().splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            k, v = line.split('=', 1)
            env[k] = v.strip('"\'')
    return pymysql.connect(host='127.0.0.1', port=3307, user=env['MEDUC_DB_USER'],
                           password=env['MEDUC_DB_PASSWORD'], database=env['MEDUC_DB_NAME'],
                           charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor, autocommit=True)


def one(cur, sql, args=()):
    cur.execute(sql, args)
    row = cur.fetchone()
    require(row is not None, 'Missing expected row')
    return row


def slug(text):
    text = unicodedata.normalize('NFD', text.lower().replace('đ', 'd'))
    text = ''.join(c for c in text if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', text).strip('-')[:100]


def encoded(value):
    return json.dumps(value, ensure_ascii=False, separators=(',', ':'))


def read_curriculum(db):
    with db.cursor() as cur:
        version = one(cur, 'SELECT id,status,source_digest FROM curriculum_versions WHERE code=%s', (VERSION,))
        require(version['status'] == 'approved', 'Source curriculum is not approved')
        cur.execute('SELECT id,code,name,subject_number FROM curriculum_subjects WHERE version_id=%s ORDER BY subject_number', (version['id'],))
        subjects = cur.fetchall()
        cur.execute('''SELECT c.id,c.subject_id,c.code,c.name,c.sort_order,c.chapter_kind
            FROM curriculum_chapters c JOIN curriculum_subjects s ON s.id=c.subject_id
            WHERE s.version_id=%s ORDER BY c.subject_id,c.sort_order''', (version['id'],))
        chapters = cur.fetchall()
        cur.execute('''SELECT l.id,l.subject_id,l.chapter_id,l.code,l.name,l.sort_order,l.lesson_kind
            FROM curriculum_lessons l JOIN curriculum_subjects s ON s.id=l.subject_id
            WHERE s.version_id=%s ORDER BY l.subject_id,l.chapter_id,l.sort_order''', (version['id'],))
        lessons = cur.fetchall()
    require(len(subjects) == COUNTS['subjects'] and len(chapters) == COUNTS['chapters']
            and len(lessons) == COUNTS['lessons'], 'Source curriculum counts differ from approved plan')
    require(sum(c['chapter_kind'] == 'review' for c in chapters) == COUNTS['review_chapters']
            and sum(l['lesson_kind'] == 'review' for l in lessons) == COUNTS['review_lessons'],
            'Source review chapters/lessons differ from approved plan')
    by_chapter = defaultdict(list)
    for l in lessons:
        by_chapter[l['chapter_id']].append(l)
    by_subject = defaultdict(list)
    for c in chapters:
        require(by_chapter[c['id']], f'Chapter {c["code"]} has no lessons')
        by_subject[c['subject_id']].append(c)
    require(all(len([c for c in by_subject[s['id']] if c['chapter_kind'] == 'review']) == 1
                for s in subjects), 'Each subject must have exactly one review chapter')
    return version, subjects, by_subject, by_chapter


def lesson_json(chapter, lesson):
    return {'code': lesson['code'], 'name_vi': lesson['name'], 'chapter_vi': 'n',
            'review_vi': 'y' if lesson['lesson_kind'] == 'review' else 'n',
            'trial_vi': 'n', 'quiz_id_vi': '', 'youtube_id_vi': '',
            'description_vi': '', 'files': '', 'filestwo': ''}


def course_json(chapters, by_chapter):
    result = []
    for c in chapters:
        result.append({'code': c['code'], 'name_vi': c['name'], 'chapter_vi': 'y',
                       'review_vi': 'n', 'trial_vi': 'n', 'quiz_id_vi': '',
                       'youtube_id_vi': '', 'description_vi': '', 'files': '', 'filestwo': ''})
        result.extend(lesson_json(c, l) for l in by_chapter[c['id']])
    return result


def verify_backup(path):
    p = Path(path).resolve()
    require(p.is_file() and p.stat().st_size > 100_000_000,
            'A full, pre-migration compressed SQL backup is required')
    require(ROOT not in p.parents and MAIN not in p.parents,
            'Backup must be outside the public web root')
    with gzip.open(p, 'rb') as stream:
        require(stream.read(64).startswith(b'/*M!') or b'MariaDB' in stream.read(1024),
                'Backup does not look like MariaDB SQL')
        for _ in iter(lambda: stream.read(1024 * 1024), b''):
            pass
    return str(p)


def preflight_target(cur):
    current = one(cur, "SELECT COUNT(*) n FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='curriculum_v2_courses'")['n']
    if current:
        new = one(cur, 'SELECT COUNT(*) n FROM curriculum_v2_courses')['n']
        cur.execute('''SELECT e.product_id FROM exam_prep_courses e
            LEFT JOIN curriculum_v2_courses cv ON cv.product_id=e.product_id
            WHERE cv.product_id IS NULL ORDER BY e.product_id''')
    else:
        new = 0
        cur.execute('SELECT product_id FROM exam_prep_courses ORDER BY product_id')
    old_ids = [r['product_id'] for r in cur.fetchall()]
    old = len(old_ids)
    cur.execute("SELECT quiz_id FROM quiz_exam_metadata WHERE source_system='local-draft' ORDER BY quiz_id")
    old_quiz_ids = [r['quiz_id'] for r in cur.fetchall()]
    if old:
        require(old == 88 and len(old_quiz_ids) == 2033 and new == 0,
                'Unexpected legacy/new data state; inspect before applying')
        for table, col in [('orders_item','product_id'), ('class_rooms','product_id'),
                           ('teacher_course_access','product_id'), ('facourse_word_downloads','product_id'),
                           ('products_item_attribute','product_id')]:
            n = one(cur, f'SELECT COUNT(*) n FROM `{table}` WHERE `{col}` IN (SELECT product_id FROM exam_prep_courses)')['n']
            require(n == 0, f'{table} contains old-course references; migration halted')
    elif new:
        require(new == 108 and not old_quiz_ids, 'Partial migration state; inspect before applying')
    else:
        raise RuntimeError('Neither known 88-course baseline nor complete 108-course import found')
    return old_ids, old_quiz_ids, new


def delete_legacy(cur, old_ids, old_quiz_ids):
    require(len(old_ids) == 88 and len(old_quiz_ids) == 2033, 'Legacy IDs changed')
    course_ids = ','.join(map(str, old_ids))
    quiz_ids = ','.join(map(str, old_quiz_ids))
    # Every affected row is preserved in the full SQL backup. One local test
    # enrollment and one test submission are deleted with their old course.
    statements = [
        f'DELETE FROM course_enrollments WHERE product_id IN ({course_ids})',
        f'DELETE FROM quizs_answer WHERE product_id IN ({course_ids}) OR quiz_id IN ({quiz_ids})',
        f'DELETE FROM categories_product WHERE product_id IN ({course_ids})',
        f'DELETE FROM categories_quiz WHERE quiz_id IN ({quiz_ids})',
        f'DELETE FROM links WHERE type="product_detail" AND foreign_id IN ({course_ids})',
        f'DELETE FROM links WHERE type="quiz_detail" AND foreign_id IN ({quiz_ids})',
        f'DELETE FROM products_attribute WHERE product_id IN ({course_ids})',
        f'DELETE FROM products_content WHERE product_id IN ({course_ids})',
        f'DELETE FROM products_item WHERE product_id IN ({course_ids})',
        f'DELETE FROM exam_prep_courses WHERE product_id IN ({course_ids})',
        f'DELETE FROM products WHERE id IN ({course_ids})',
        f'DELETE FROM quizs_attribute WHERE quiz_id IN ({quiz_ids})',
        f'DELETE FROM quizs_content WHERE quiz_id IN ({quiz_ids})',
        f'DELETE FROM quiz_exam_metadata WHERE quiz_id IN ({quiz_ids})',
        f'DELETE FROM quizs WHERE id IN ({quiz_ids})',
    ]
    for statement in statements:
        cur.execute(statement)


def create_mapping(cur):
    cur.execute('''CREATE TABLE IF NOT EXISTS curriculum_v2_courses (
        product_id INT NOT NULL PRIMARY KEY,
        source_subject_id INT UNSIGNED NOT NULL,
        subject_code VARCHAR(24) NOT NULL UNIQUE,
        source_digest CHAR(64) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_curriculum_v2_product FOREIGN KEY (product_id)
            REFERENCES products(id) ON DELETE RESTRICT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci''')


def insert_course(cur, subject, curriculum, digest):
    now = int(time.time())
    code = subject['code']
    number = subject['subject_number']
    name = subject['name']
    url = f'luyen-thi-{slug(name)}-{number:03d}'
    require(len(url) <= 255, 'URL too long')
    require(not one(cur, 'SELECT COUNT(*) n FROM links WHERE url=%s AND type=%s AND deleted=0',
                    (url, 'product_detail'))['n'], f'URL already exists: {url}')
    cur.execute('''INSERT INTO products
        (main_category_id,status,draft,deleted,created,updated,created_by,position)
        VALUES (125,0,1,0,%s,%s,1,%s)''', (now, now, number))
    pid = cur.lastrowid
    cur.execute('''INSERT INTO products_content (product_id,name,search_unicode,lang)
        VALUES (%s,%s,%s,'vi')''', (pid, name, slug(name).replace('-', ' ')))
    cur.execute('''INSERT INTO products_item (product_id,code,price,status,deleted,position)
        VALUES (%s,%s,0,0,0,1)''', (pid, f'MEDUC-LT-{code}'))
    cur.execute('''INSERT INTO products_attribute (product_id,attribute_id,value)
        VALUES (%s,11,%s)''', (pid, encoded(curriculum)))
    cur.execute('INSERT INTO categories_product (product_id,category_id) VALUES (%s,125)', (pid,))
    cur.execute('''INSERT INTO links (foreign_id,type,url,lang,created,updated,deleted)
        VALUES (%s,'product_detail',%s,'vi',%s,%s,0)''', (pid, url, now, now))
    cur.execute('''INSERT INTO exam_prep_courses (product_id,import_topic,staff_only)
        VALUES (%s,%s,1)''', (pid, name))
    cur.execute('''INSERT INTO curriculum_v2_courses
        (product_id,source_subject_id,subject_code,source_digest) VALUES (%s,%s,%s,%s)''',
        (pid, subject['id'], code, digest))
    return pid


def verify_target(cur, subjects, by_subject, by_chapter, digest):
    cur.execute('''SELECT cv.product_id,cv.source_subject_id,cv.subject_code,cv.source_digest,
        e.staff_only,p.status,p.draft,p.deleted,pi.status AS item_status,pa.value
        FROM curriculum_v2_courses cv JOIN exam_prep_courses e ON e.product_id=cv.product_id
        JOIN products p ON p.id=cv.product_id
        JOIN products_item pi ON pi.product_id=cv.product_id AND pi.deleted=0
        JOIN products_attribute pa ON pa.product_id=cv.product_id AND pa.attribute_id=11
        ORDER BY cv.source_subject_id''')
    rows = cur.fetchall()
    require(len(rows) == 108, f'Expected 108 new courses, got {len(rows)}')
    chapters = lessons = 0
    for row, subject in zip(rows, subjects):
        visibility = (row['status'], row['draft'], row['item_status'], row['staff_only'])
        require(row['source_subject_id'] == subject['id'] and row['subject_code'] == subject['code']
                and row['source_digest'] == digest and row['deleted'] == 0
                and visibility in ((0, 1, 0, 1), (1, 0, 1, 0)),
                f'Course mismatch for {subject["code"]}')
        actual = json.loads(row['value'])
        expected = course_json(by_subject[subject['id']], by_chapter)
        # A later exam import is allowed to attach quizzes to the review lesson.
        for entry in actual:
            if entry['code'].endswith('-L-REVIEW'):
                entry['quiz_id_vi'] = ''
                entry.pop('quizzes_vi', None)
        require(actual == expected, f'Curriculum mismatch for {subject["code"]}')
        chapters += sum(x['chapter_vi'] == 'y' for x in expected)
        lessons += sum(x['chapter_vi'] == 'n' for x in expected)
    require(chapters == 804 and lessons == 2971, 'Imported curriculum totals differ')
    return {'courses': len(rows), 'chapters': chapters, 'lessons': lessons}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--backup', help='Verified full SQL backup outside the web root')
    args = parser.parse_args()
    source = connect_source()
    target = connect_target()
    try:
        version, subjects, by_subject, by_chapter = read_curriculum(source)
        with target.cursor() as cur:
            old_ids, old_quiz_ids, new = preflight_target(cur)
            plan = {'old_courses': len(old_ids), 'old_local_draft_exams': len(old_quiz_ids),
                    'new_courses': 108, 'new_chapters': 804, 'new_lessons': 2971,
                    'source_digest': version['source_digest']}
            if not args.apply:
                print(encoded({'mode': 'plan', **plan}))
                return
            require(args.backup, '--apply requires --backup')
            backup = verify_backup(args.backup)
            if old_ids:
                delete_legacy(cur, old_ids, old_quiz_ids)
                create_mapping(cur)
                for subject in subjects:
                    insert_course(cur, subject, course_json(by_subject[subject['id']], by_chapter),
                                  version['source_digest'])
            result = verify_target(cur, subjects, by_subject, by_chapter, version['source_digest'])
            require(one(cur, "SELECT COUNT(*) n FROM quiz_exam_metadata WHERE source_system='local-draft'")['n'] == 0,
                    'Legacy exam metadata remains')
            print(encoded({'mode': 'applied', 'backup': backup, **plan, **result}))
    finally:
        source.close()
        target.close()


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'ERROR: {error}', file=sys.stderr)
        raise
