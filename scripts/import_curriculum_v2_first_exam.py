#!/usr/bin/env python3
"""Import source exam 2431 into the subject-1 review lesson on local MedUC.

Reads the original question/answer data and separate AI explanations from the
local source DB. A web quiz is created only when --apply is passed. Original
answers are copied unchanged; the importer does not calculate a new key.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
import sys
import time

from curriculum_v2_local import connect_source, connect_target, encoded, one, require

EXAM_ID = 2431
SOURCE_DIGEST = '5cd886f5935f42607272acfbebbbc059330802f26a87e27535f36069892ea3c1'
SOURCE_SYSTEM = 'meduc-source-v2'


def source_exam(db):
    with db.cursor() as cur:
        exam = one(cur, 'SELECT id,remote_id,category_id,name,quiz_type,is_pro,total_questions,duration_minutes,is_curated FROM sub_categories WHERE id=%s', (EXAM_ID,))
        require(exam['is_curated'] == 1 and exam['total_questions'] == 40, 'Source exam is no longer the reviewed 40-question exam')
        cat = one(cur, 'SELECT name,category_type FROM categories WHERE remote_id=%s', (exam['category_id'],))
        mapping = one(cur, '''SELECT s.id,s.code,s.name FROM curriculum_mapping_runs r
            JOIN curriculum_versions v ON v.id=r.version_id
            JOIN curriculum_exam_subjects m ON m.run_id=r.id AND m.mapping_role='primary'
            JOIN curriculum_subjects s ON s.id=m.subject_id
            WHERE r.status='active' AND v.code='mon_v2' AND m.source_exam_id=%s''', (EXAM_ID,))
        require(mapping['code'] == 'MV2-S001', 'Source primary subject mapping changed')
        review = one(cur, '''SELECT l.id,l.code,l.name FROM curriculum_lessons l
            WHERE l.subject_id=%s AND l.lesson_kind='review' ''', (mapping['id'],))
        cur.execute('''SELECT q.id,q.order_index,q.question_type,q.content,
                o.id AS option_id,o.option_key,o.content AS option_content,o.is_correct
            FROM questions q JOIN question_options o ON o.question_id=q.id
            WHERE q.sub_category_id=%s ORDER BY q.order_index,q.id,o.order_index,o.id''', (EXAM_ID,))
        digest_rows = cur.fetchall()
        digest = hashlib.sha256(json.dumps(digest_rows,sort_keys=True,ensure_ascii=False,
                                separators=(',',':')).encode()).hexdigest()
        require(digest == SOURCE_DIGEST, 'Source questions/options changed since the reviewed pilot')
        cur.execute('''SELECT q.id,q.order_index,q.question_type,q.content,q.explanation,
                q.has_image,o.id AS option_id,o.option_key,o.content AS option_content,
                o.is_correct,o.explanation AS option_explanation,
                qa.subject_id,qa.lesson_id,qa.lesson_match,qa.difficulty_level,
                qa.general_explanation,oa.explanation AS ai_option_explanation
            FROM questions q JOIN question_options o ON o.question_id=q.id
            JOIN curriculum_question_ai qa ON qa.source_question_id=q.id
            JOIN curriculum_option_ai oa ON oa.source_option_id=o.id
            WHERE q.sub_category_id=%s ORDER BY q.order_index,q.id,o.order_index,o.id''', (EXAM_ID,))
        rows = cur.fetchall()
        require(len(rows) == 160, 'Some source options or AI explanations are missing')
        grouped = {}
        for r in rows:
            grouped.setdefault(r['order_index'], []).append(r)
        require(list(grouped) == list(range(1,41)), 'Source question order changed')
        cur.execute('SELECT id,code FROM curriculum_lessons WHERE subject_id=%s', (mapping['id'],))
        lesson_codes = {r['id']:r['code'] for r in cur.fetchall()}
        questions = []
        for number, options in grouped.items():
            require(len(options) == 4 and [o['option_key'] for o in options] == list('ABCD')
                    and sum(int(o['is_correct']) for o in options) == 1,
                    f'Question {number} has changed option structure')
            first = options[0]
            require(first['question_type'] == 'MULTIPLE_CHOICE' and not first['has_image'],
                    f'Question {number} requires a different importer')
            require(all(o['subject_id'] == mapping['id'] and o['general_explanation']
                        and o['ai_option_explanation'] for o in options),
                    f'Question {number} has incomplete subject/AI data')
            lesson_id = first['lesson_id']
            require((lesson_id is None and first['lesson_match'] == 'none') or
                    (lesson_id in lesson_codes and first['lesson_match'] in ('direct','related_low')),
                    f'Question {number} is mapped outside subject 1')
            correct = next(i + 1 for i,o in enumerate(options) if o['is_correct'])
            explanation = '<h3>Khái niệm</h3><p>' + html.escape(first['general_explanation']) + '</p>'
            if first['explanation']:
                explanation += '<h3>Giải thích gốc</h3><p>' + html.escape(first['explanation']) + '</p>'
            explanation += '<h3>Giải thích từng lựa chọn</h3><ul>'
            for o in options:
                explanation += '<li><strong>' + o['option_key'] + '.</strong> ' + html.escape(o['ai_option_explanation']) + '</li>'
            explanation += '</ul>'
            item = {'code': f'q_{number}', 'name_vi': first['content'], 'description_vi': '',
                    'answer_vi': str(correct), 'answer_detail_vi': explanation,
                    'source_question_id': first['id'], 'question_type': first['question_type'],
                    'source_explanation': first['explanation'] or '',
                    'ai_subject_code': mapping['code'],
                    'ai_lesson_code': lesson_codes.get(lesson_id),
                    'ai_lesson_match': first['lesson_match'],
                    'difficulty_level': first['difficulty_level'],
                    'ai_general_explanation': first['general_explanation'],
                    'files': '', 'images': [], 'rubrics': []}
            item['options'] = []
            for i, o in enumerate(options):
                item['option_' + ['one','two','three','four'][i] + '_vi'] = o['option_content']
                item['options'].append({'id':o['option_id'], 'key':o['option_key'],
                    'content':o['option_content'], 'is_correct':bool(o['is_correct']),
                    'source_explanation':o['option_explanation'] or '',
                    'ai_explanation':o['ai_option_explanation']})
            item['option_five_vi'] = ''
            questions.append(item)
        return exam, cat, mapping, review, questions, digest


def target_course(cur, subject_code, review_code):
    course = one(cur, '''SELECT cv.product_id,p.status,p.draft,p.deleted,e.staff_only,pa.id attr_id,pa.value
        FROM curriculum_v2_courses cv JOIN products p ON p.id=cv.product_id
        JOIN exam_prep_courses e ON e.product_id=cv.product_id
        JOIN products_attribute pa ON pa.product_id=cv.product_id AND pa.attribute_id=11
        WHERE cv.subject_code=%s''', (subject_code,))
    require(course['status'] == 0 and course['draft'] == 1 and course['deleted'] == 0
            and course['staff_only'] == 1, 'Target course is not private')
    lessons = json.loads(course['value'])
    matches = [i for i,l in enumerate(lessons) if l['code'] == review_code]
    require(len(matches) == 1 and lessons[matches[0]]['review_vi'] == 'y',
            'Target review lesson is missing')
    return course, lessons, matches[0]


def apply(cur, exam, category, mapping, review, questions, digest):
    course, lessons, review_index = target_course(cur, mapping['code'], review['code'])
    existing = cur.execute('''SELECT quiz_id,source_hash FROM quiz_exam_metadata
        WHERE source_system=%s AND source_exam_id=%s''', (SOURCE_SYSTEM, EXAM_ID))
    if existing:
        row = cur.fetchone()
        require(row['source_hash'] == digest, 'Imported source hash differs')
        quiz_id = row['quiz_id']
        stored = one(cur, 'SELECT value FROM quizs_attribute WHERE quiz_id=%s AND attribute_id=18', (quiz_id,))
        require(json.loads(stored['value']) == questions, 'Imported question data differs')
        require(str(lessons[review_index].get('quiz_id_vi')) == str(quiz_id), 'Review lesson is not linked to imported quiz')
        return quiz_id, 'existing-identical', course['product_id']
    require(not lessons[review_index].get('quiz_id_vi') and not lessons[review_index].get('quizzes_vi'),
            'Review lesson already has a quiz; this script only handles its first exam')
    now = int(time.time())
    cur.execute('''INSERT INTO quizs (status,draft,deleted,created,updated,created_by,position)
        VALUES (0,1,0,%s,%s,1,1)''', (now,now))
    quiz_id = cur.lastrowid
    cur.execute('''INSERT INTO quizs_content (quiz_id,name,search_unicode,lang)
        VALUES (%s,%s,%s,'vi')''', (quiz_id,exam['name'],exam['name']))
    cur.execute('INSERT INTO quizs_attribute (quiz_id,attribute_id,value) VALUES (%s,18,%s)',
                (quiz_id,encoded(questions)))
    duration = exam['duration_minutes'] or 60
    cur.execute('INSERT INTO quizs_attribute (quiz_id,attribute_id,value) VALUES (%s,19,%s)',
                (quiz_id,str(duration)))
    year = re.search(r'(?<!\d)(19\d\d|20\d\d)(?!\d)', exam['name'])
    cur.execute('''INSERT INTO quiz_exam_metadata
        (quiz_id,source_system,source_exam_id,source_remote_id,source_category_id,
         source_category_name,import_topic,school_name,year_in_title,source_quiz_type,
         curriculum_type,source_is_pro,question_count,source_question_count,
         source_hash,imported_at,staff_only)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'subject',%s,40,40,%s,NOW(),1)''',
        (quiz_id,SOURCE_SYSTEM,EXAM_ID,exam['remote_id'],exam['category_id'],
         category['name'],mapping['name'],category['category_type'],
         int(year.group()) if year else None,exam['quiz_type'],exam['is_pro'],digest))
    cur.execute('''INSERT INTO links (foreign_id,type,url,lang,created,updated,deleted)
        VALUES (%s,'quiz_detail',%s,'vi',%s,%s,0)''',
        (quiz_id,f'de-tong-on-mv2-{EXAM_ID}',now,now))
    lessons[review_index]['quiz_id_vi'] = str(quiz_id)
    lessons[review_index]['quizzes_vi'] = encoded([{'id':quiz_id,'free':'n'}])
    cur.execute('UPDATE products_attribute SET value=%s WHERE id=%s',
                (encoded(lessons),course['attr_id']))
    return quiz_id, 'inserted', course['product_id']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    source = connect_source()
    try:
        exam,cat,mapping,review,questions,digest = source_exam(source)
    finally:
        source.close()
    summary = {'source_exam_id':EXAM_ID,'subject_code':mapping['code'],
               'review_lesson_code':review['code'],'questions':len(questions),
               'options':sum(len(q['options']) for q in questions),
               'original_correct_options':sum(sum(o['is_correct'] for o in q['options']) for q in questions)}
    if not args.apply:
        print(encoded({'mode':'plan',**summary}))
        return
    target = connect_target()
    try:
        with target.cursor() as cur:
            quiz_id, state, product_id = apply(cur,exam,cat,mapping,review,questions,digest)
            row = one(cur, '''SELECT m.staff_only,q.status,q.draft,q.deleted,qa.value
                FROM quiz_exam_metadata m JOIN quizs q ON q.id=m.quiz_id
                JOIN quizs_attribute qa ON qa.quiz_id=q.id AND qa.attribute_id=18
                WHERE m.quiz_id=%s''', (quiz_id,))
            require(row['staff_only'] == 1 and row['status'] == 0 and row['draft'] == 1
                    and row['deleted'] == 0 and len(json.loads(row['value'])) == 40,
                    'Imported quiz failed verification')
            print(encoded({'mode':'applied','state':state,'product_id':product_id,
                           'quiz_id':quiz_id,**summary}))
    finally:
        target.close()


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'ERROR: {error}', file=sys.stderr)
        raise
