#!/usr/bin/env python3
"""Create one exercise slot for every mon_v2 lesson on local MedUC.

The first reviewed source exam remains in the subject-1 review lesson. Its 29
questions with a lesson match are also copied into seven lesson exercises.
Empty exercises stay staff-only and cannot be started by students. Exercises
with questions are available only through an enrolled course's quiz player.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
import time
from collections import defaultdict

from curriculum_v2_local import (
    connect_source, connect_target, encoded, one, read_curriculum, require,
    slug, verify_backup,
)
from import_curriculum_v2_first_exam import EXAM_ID, source_exam

SOURCE_SYSTEM = 'curriculum-v2-lesson'
PILOT_QUIZ_ID = 2715


def plan_source():
    source = connect_source()
    try:
        version, subjects, by_subject, by_chapter = read_curriculum(source)
        exam, _, mapping, review, questions, _ = source_exam(source)
        require(exam['id'] == EXAM_ID and mapping['code'] == 'MV2-S001',
                'Pilot source exam or subject changed')
        by_lesson = defaultdict(list)
        unmatched = []
        for question in questions:
            code = question['ai_lesson_code']
            if code:
                require(question['ai_lesson_match'] in ('direct', 'related_low'),
                        'Question with lesson has unexpected match state')
                by_lesson[code].append(dict(question, source_exam_id=EXAM_ID))
            else:
                require(question['ai_lesson_match'] == 'none',
                        'Question without lesson has unexpected match state')
                unmatched.append(question['source_question_id'])
        require(sum(map(len, by_lesson.values())) == 29 and len(by_lesson) == 7
                and len(unmatched) == 11, 'Pilot lesson distribution changed')
        return version, subjects, by_subject, by_chapter, by_lesson, unmatched
    finally:
        source.close()


def target_state(cur, subjects, version):
    cur.execute('''SELECT cv.product_id,cv.source_subject_id,cv.subject_code,
        cv.source_digest,p.status,p.draft,p.deleted
        FROM curriculum_v2_courses cv JOIN products p ON p.id=cv.product_id
        ORDER BY cv.source_subject_id''')
    rows = cur.fetchall()
    require(len(rows) == 108, 'Target must have all 108 curriculum courses')
    by_subject = {}
    for row, subject in zip(rows, subjects):
        require(row['source_subject_id'] == subject['id']
                and row['subject_code'] == subject['code']
                and row['source_digest'] == version['source_digest']
                and (row['status'], row['draft'], row['deleted']) == (1, 0, 0),
                f'Target course changed: {subject["code"]}')
        by_subject[subject['id']] = row['product_id']
    cur.execute('''SELECT m.source_exam_id,m.quiz_id,m.question_count,m.staff_only,
        q.status,q.draft,q.deleted
        FROM quiz_exam_metadata m JOIN quizs q ON q.id=m.quiz_id
        WHERE m.source_system=%s''', (SOURCE_SYSTEM,))
    existing = {r['source_exam_id']: r for r in cur.fetchall()}
    require(len(existing) <= 2970, 'Too many lesson exercise mappings')
    pilot = one(cur, '''SELECT m.quiz_id,m.staff_only,m.question_count,q.status,q.draft,q.deleted,
        qa.value FROM quiz_exam_metadata m JOIN quizs q ON q.id=m.quiz_id
        JOIN quizs_attribute qa ON qa.quiz_id=q.id AND qa.attribute_id=18
        WHERE m.source_system='meduc-source-v2' AND m.source_exam_id=%s''', (EXAM_ID,))
    require(pilot['quiz_id'] == PILOT_QUIZ_ID and pilot['question_count'] == 40
            and (pilot['status'], pilot['draft'], pilot['deleted']) == (0, 1, 0)
            and pilot['staff_only'] in (0, 1)
            and len(json.loads(pilot['value'])) == 40,
            'Pilot review quiz differs from the verified import')
    return by_subject, existing, pilot


def ensure_quiz(cur, lesson, subject, questions, existing, now):
    source_id = lesson['id']
    expected = encoded(questions)
    title = ('Đề Tổng ôn' if lesson['lesson_kind'] == 'review' else 'Bài tập 1')
    title += ' · ' + lesson['name']
    if source_id in existing:
        row = existing[source_id]
        quiz_id = row['quiz_id']
        require((row['status'], row['draft'], row['deleted']) == (0, 1, 0)
                and row['question_count'] == len(questions)
                and row['staff_only'] == (0 if questions else 1),
                f'Exercise status changed for {lesson["code"]}')
        stored = one(cur, '''SELECT qa.value,qc.name FROM quizs_attribute qa
            JOIN quizs_content qc ON qc.quiz_id=qa.quiz_id AND qc.lang='vi'
            WHERE qa.quiz_id=%s AND qa.attribute_id=18''', (quiz_id,))
        require(json.loads(stored['value']) == questions and stored['name'] == title,
                f'Exercise content changed for {lesson["code"]}')
        return quiz_id, False

    cur.execute('''INSERT INTO quizs (status,draft,deleted,created,updated,created_by,position)
        VALUES (0,1,0,%s,%s,1,1)''', (now, now))
    quiz_id = cur.lastrowid
    cur.execute('''INSERT INTO quizs_content (quiz_id,name,search_unicode,lang)
        VALUES (%s,%s,%s,'vi')''', (quiz_id, title, slug(title).replace('-', ' ')))
    cur.execute('''INSERT INTO quizs_attribute (quiz_id,attribute_id,value)
        VALUES (%s,18,%s)''', (quiz_id, expected))
    cur.execute('''INSERT INTO quizs_attribute (quiz_id,attribute_id,value)
        VALUES (%s,19,%s)''', (quiz_id, str(max(15, len(questions) * 2))))
    digest = hashlib.sha256(encoded([q['source_question_id'] for q in questions]).encode()).hexdigest()
    cur.execute('''INSERT INTO quiz_exam_metadata
        (quiz_id,source_system,source_exam_id,import_topic,curriculum_type,
         question_count,source_question_count,source_hash,imported_at,staff_only)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,NOW(),%s)''',
        (quiz_id, SOURCE_SYSTEM, source_id, subject['name'],
         lesson['lesson_kind'], len(questions), len(questions), digest,
         0 if questions else 1))
    existing[source_id] = {'quiz_id': quiz_id, 'question_count': len(questions),
                           'staff_only': 0 if questions else 1,
                           'status': 0, 'draft': 1, 'deleted': 0}
    return quiz_id, True


def apply(version, subjects, by_subject, by_chapter, by_lesson):
    target = connect_target()
    created = 0
    try:
        with target.cursor() as cur:
            course_ids, existing, pilot = target_state(cur, subjects, version)
            for subject in subjects:
                product_id = course_ids[subject['id']]
                attr = one(cur, '''SELECT id,value FROM products_attribute
                    WHERE product_id=%s AND attribute_id=11''', (product_id,))
                course_items = json.loads(attr['value'])
                expected = [item for chapter in by_subject[subject['id']]
                            for item in ([chapter] + by_chapter[chapter['id']])]
                require([x['code'] for x in course_items] == [x['code'] for x in expected],
                        f'Course outline changed: {subject["code"]}')
                by_code = {item['code']: item for item in course_items}
                for lesson in (item for item in expected if 'lesson_kind' in item):
                    entry = by_code[lesson['code']]
                    if lesson['code'] == 'MV2-S001-L-REVIEW':
                        require(str(entry.get('quiz_id_vi')) == str(PILOT_QUIZ_ID),
                                'Pilot review quiz link changed')
                        continue
                    questions = by_lesson.get(lesson['code'], [])
                    require(not questions or subject['code'] == 'MV2-S001',
                            'Pilot question mapped outside first subject')
                    quiz_id, is_new = ensure_quiz(cur, lesson, subject, questions, existing,
                                                  int(time.time()))
                    created += is_new
                    prior = entry.get('quiz_id_vi')
                    require(not prior or str(prior) == str(quiz_id),
                            f'Lesson already uses another exercise: {lesson["code"]}')
                    entry['quiz_id_vi'] = str(quiz_id)
                    entry['quizzes_vi'] = encoded([{'id': quiz_id, 'free': 'n'}])
                cur.execute('UPDATE products_attribute SET value=%s WHERE id=%s',
                            (encoded(course_items), attr['id']))
            require(len(existing) == 2970, f'Expected 2970 new lesson exercises, got {len(existing)}')
            cur.execute('''UPDATE quiz_exam_metadata SET staff_only=0
                WHERE quiz_id=%s AND source_system='meduc-source-v2' AND source_exam_id=%s''',
                (PILOT_QUIZ_ID, EXAM_ID))
            require(one(cur, 'SELECT staff_only FROM quiz_exam_metadata WHERE quiz_id=%s',
                        (PILOT_QUIZ_ID,))['staff_only'] == 0, 'Pilot review quiz not available')
            target.commit()
            return {'courses': len(subjects), 'lesson_exercises': len(existing),
                    'created': created, 'filled_lesson_exercises': len(by_lesson),
                    'lesson_questions': sum(map(len, by_lesson.values())),
                    'review_questions': 40, 'empty_exercises': 2970 - len(by_lesson)}
    finally:
        target.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--backup', help='Verified full SQL backup outside web root')
    args = parser.parse_args()
    version, subjects, by_subject, by_chapter, by_lesson, unmatched = plan_source()
    target = connect_target()
    try:
        with target.cursor() as cur:
            _, existing, pilot = target_state(cur, subjects, version)
    finally:
        target.close()
    summary = {'courses': len(subjects), 'lessons': 2971, 'new_slots': 2970,
               'already_created_slots': len(existing), 'mapped_lesson_questions': 29,
               'unmatched_review_only_questions': len(unmatched),
               'pilot_review_staff_only': pilot['staff_only']}
    if not args.apply:
        print(encoded({'mode': 'plan', **summary}))
        return
    require(args.backup, '--apply requires --backup')
    backup = verify_backup(args.backup)
    result = apply(version, subjects, by_subject, by_chapter, by_lesson)
    print(encoded({'mode': 'applied', 'backup': backup, **summary, **result}))


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'ERROR: {error}', file=sys.stderr)
        raise
