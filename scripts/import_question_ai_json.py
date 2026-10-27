#!/usr/bin/env python3
"""Validate an enrichment payload against source MySQL; insert only missing AI rows.

Uses the existing MySQL CLI inside Docker, with no extra Python dependencies.
The source questions/options, correct answers and curriculum are read only.
Default: validate and write a guarded SQL import. Use --apply to execute it.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


QUESTION_COLUMNS = ('source_question_id', 'subject_id', 'lesson_id',
                    'lesson_match', 'difficulty_level', 'general_explanation')
OPTION_COLUMNS = ('source_option_id', 'explanation')
MATCHES = {'direct', 'related_low', 'none'}
DIFFICULTIES = {'easy', 'medium', 'upper_medium', 'hard'}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def canonical(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(',', ':'))


def digest(value):
    return hashlib.sha256(canonical(value).encode()).hexdigest()


def literal(value):
    if value is None:
        return 'NULL'
    if isinstance(value, bool):
        return str(int(value))
    if isinstance(value, int):
        return str(value)
    require(isinstance(value, str), 'Only text, integer and NULL SQL values are allowed')
    return "CONVERT(X'%s' USING utf8mb4)" % value.encode().hex()


def ids(values):
    result = sorted(set(values))
    require(result and all(type(v) is int and v > 0 for v in result), 'Invalid source IDs')
    return ','.join(map(str, result))


class Database:
    def __init__(self, container, database):
        require(re.fullmatch(r'[a-zA-Z0-9_-]+', container), 'Invalid container name')
        require(re.fullmatch(r'[a-zA-Z0-9_]+', database), 'Invalid database name')
        self.name = database
        self.command = [
            'docker', 'exec', '-i', container, 'sh', '-c',
            'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot '
            '--default-character-set=utf8mb4 --batch --raw --skip-column-names '
            '--database="$1"', 'mysql-client', database]

    def execute(self, sql):
        result = subprocess.run(self.command, input=sql, text=True, capture_output=True)
        if result.returncode:
            # MySQL errors can echo the SQL text, which can contain exam content.
            error = result.stderr.strip().splitlines()
            summary = next((line for line in reversed(error) if line.startswith('ERROR')), '')
            raise RuntimeError('MySQL rejected the operation: ' + (summary or 'client failed'))
        return result.stdout

    def rows(self, table, alias, where, columns=None, join=''):
        if columns is None:
            query = ("SELECT JSON_ARRAYAGG(COLUMN_NAME) FROM information_schema.COLUMNS "
                     f"WHERE TABLE_SCHEMA={literal(self.name)} AND TABLE_NAME={literal(table)};")
            columns = json.loads(self.execute(query))
        require(columns and all(re.fullmatch(r'[a-zA-Z0-9_]+', c) for c in columns),
                'Missing or unsupported table columns: ' + table)
        obj = 'JSON_OBJECT(' + ','.join(
            f"'{c}',{alias}.`{c}`" for c in columns) + ')'
        key = next(c for c in ('id', 'source_question_id', 'source_option_id') if c in columns)
        sql = f'SELECT {obj} FROM `{table}` {alias} {join} WHERE {where} ORDER BY {alias}.`{key}`;'
        return [json.loads(line) for line in self.execute(sql).splitlines() if line], obj


def compare_existing(rows, expected, key, columns):
    for row in rows:
        wanted = expected.get(row[key])
        require(wanted is not None and all(row[c] == wanted[c] for c in columns),
                f'Existing AI data differs at {key}={row[key]}; refusing to overwrite')


def inserts(table, columns, rows):
    if not rows:
        return ''
    values = ',\n'.join('(' + ','.join(literal(row[c]) for c in columns) + ')' for row in rows)
    return f'INSERT INTO `{table}` (`' + '`,`'.join(columns) + '`) VALUES\n' + values + ';\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('payload', type=Path)
    parser.add_argument('--container', default='fhd_quiz_mysql')
    parser.add_argument('--database', default='fhd_quiz')
    parser.add_argument('--expected-exams', help='Comma-separated source exam IDs')
    parser.add_argument('--output-sql', type=Path)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    raw = args.payload.read_bytes()
    data = json.loads(raw)
    exams = data['exams']
    exam_ids = [e['metadata']['id'] for e in exams]
    exam_in = ids(exam_ids)
    require(len(set(exam_ids)) == len(exam_ids), 'Duplicate source exams')
    if args.expected_exams:
        require(set(exam_ids) == set(map(int, args.expected_exams.split(','))), 'Unexpected exam batch')
    subject_code = data['subject_code']
    input_questions = [q for e in exams for q in e['questions']]
    question_ids = [q['source_question_id'] for q in input_questions]
    question_in = ids(question_ids)
    require(len(set(question_ids)) == len(question_ids), 'Duplicate source question IDs')
    input_options = [o for q in input_questions for o in q['options']]
    option_ids = [o['id'] for o in input_options]
    option_in = ids(option_ids)
    require(len(set(option_ids)) == len(option_ids), 'Duplicate source option IDs')
    for key, count in [('question_count', len(input_questions)), ('option_count', len(input_options))]:
        if key in data.get('processing', {}):
            require(data['processing'][key] == count, 'Payload processing count differs: ' + key)

    db = Database(args.container, args.database)
    source_exams, exam_obj = db.rows('sub_categories', 'e', f'e.id IN ({exam_in})')
    source_questions, question_obj = db.rows('questions', 'q', f'q.sub_category_id IN ({exam_in})')
    source_options, option_obj = db.rows('question_options', 'o', f'q.sub_category_id IN ({exam_in})',
        join='JOIN questions q ON q.id=o.question_id')
    original = {'exams': source_exams, 'questions': source_questions, 'options': source_options}
    require({e['id'] for e in source_exams} == set(exam_ids), 'Source exam IDs differ')
    require({q['id'] for q in source_questions} == set(question_ids), 'Missing or extra source questions')
    require({o['id'] for o in source_options} == set(option_ids), 'Missing or extra source options')
    sq = {q['id']: q for q in source_questions}
    so = {o['id']: o for o in source_options}
    se = {e['id']: e for e in source_exams}
    context_sql = f"""SELECT JSON_OBJECT('exam_id',m.source_exam_id,'subject_id',s.id,
        'subject_code',s.code,'run_id',r.id) FROM curriculum_exam_subjects m
        JOIN curriculum_mapping_runs r ON r.id=m.run_id AND r.status='active'
        JOIN curriculum_subjects s ON s.id=m.subject_id
        JOIN curriculum_versions v ON v.id=r.version_id AND v.code='mon_v2'
        WHERE m.mapping_role='primary' AND m.source_exam_id IN ({exam_in}) ORDER BY m.source_exam_id;"""
    mappings = [json.loads(line) for line in db.execute(context_sql).splitlines() if line]
    require(len(mappings) == len(exams) and {m['exam_id'] for m in mappings} == set(exam_ids),
            'Each exam must have exactly one active primary subject mapping')
    require(all(m['subject_code'] == subject_code for m in mappings), 'Subject differs from fixed source mapping')
    subject_ids = {m['subject_id'] for m in mappings}
    require(len(subject_ids) == 1, 'Mixed subject mappings')
    subject_id = next(iter(subject_ids))
    lesson_rows, _ = db.rows('curriculum_lessons', 'l', f'l.subject_id={subject_id}')
    lessons = {l['code']: l for l in lesson_rows}

    expected_questions, expected_options = {}, {}
    for exam in exams:
        eid = exam['metadata']['id']
        require(se[eid]['is_curated'] == 1, f'Exam {eid} is outside the curated source set')
        require(len(exam['questions']) == se[eid]['total_questions'] == exam['metadata']['total_questions'],
                f'Question count differs for exam {eid}')
        for order, question in enumerate(exam['questions'], 1):
            qid = question['source_question_id']
            source = sq[qid]
            require(source['sub_category_id'] == eid == question['source_exam_id'], f'Question {qid}: exam differs')
            require(source['order_index'] == question['source_question_order'] == order,
                    f'Question {qid}: original question order differs')
            require(source['content'] == question['name_vi'], f'Question {qid}: original text differs')
            require((source['explanation'] or '') == (question['source_explanation'] or ''),
                    f'Question {qid}: original explanation differs')
            require(source['question_type'] == question['question_type'] == 'MULTIPLE_CHOICE',
                    f'Question {qid}: this batch expects original multiple-choice questions')
            require(question['ai_subject_code'] == subject_code, f'Question {qid}: AI changed the subject')
            match = question['ai_lesson_match']
            require(match in MATCHES, f'Question {qid}: invalid match')
            lesson_code = question['ai_lesson_code']
            require((lesson_code is None) == (match == 'none'), f'Question {qid}: lesson/match mismatch')
            lesson = lessons.get(lesson_code) if lesson_code else None
            require(lesson_code is None or lesson and lesson['lesson_kind'] == 'knowledge',
                    f'Question {qid}: lesson is outside the subject knowledge curriculum')
            require(question['difficulty_level'] in DIFFICULTIES, f'Question {qid}: invalid difficulty')
            require(isinstance(question['ai_general_explanation'], str)
                    and question['ai_general_explanation'].strip(), f'Question {qid}: empty concept explanation')
            expected_questions[qid] = dict(zip(QUESTION_COLUMNS, (
                qid, subject_id, lesson['id'] if lesson else None, match,
                question['difficulty_level'], question['ai_general_explanation'])))
            require({o['id'] for o in question['options']} ==
                    {o['id'] for o in source_options if o['question_id'] == qid},
                    f'Question {qid}: original option IDs differ')
            for option in question['options']:
                oid = option['id']
                old = so[oid]
                require(old['question_id'] == qid and old['option_key'] == option['key']
                        and old['content'] == option['content']
                        and type(option['is_correct']) in (int, bool)
                        and option['is_correct'] in (0, 1)
                        and old['is_correct'] == int(option['is_correct']),
                        f'Option {oid}: source ID, text or correct answer differs')
                require((old['explanation'] or '') == (option['source_explanation'] or ''),
                        f'Option {oid}: original option explanation differs')
                require(isinstance(option['ai_explanation'], str) and option['ai_explanation'].strip(),
                        f'Option {oid}: missing AI explanation')
                expected_options[oid] = {'source_option_id': oid, 'explanation': option['ai_explanation']}

    before_q, _ = db.rows('curriculum_question_ai', 'a', f'a.source_question_id IN ({question_in})', QUESTION_COLUMNS)
    before_o, _ = db.rows('curriculum_option_ai', 'a', f'a.source_option_id IN ({option_in})', OPTION_COLUMNS)
    compare_existing(before_q, expected_questions, 'source_question_id', QUESTION_COLUMNS)
    compare_existing(before_o, expected_options, 'source_option_id', OPTION_COLUMNS)
    preserved_q, _ = db.rows('curriculum_question_ai', 'a', f'a.source_question_id NOT IN ({question_in})')
    preserved_o, _ = db.rows('curriculum_option_ai', 'a', f'a.source_option_id NOT IN ({option_in})')
    preserved_hash = digest([preserved_q, preserved_o])

    parts = [f'-- Enrichment only; original source rows are never updated.\n'
             f'-- Payload SHA256: {hashlib.sha256(raw).hexdigest()}\n'
             f'-- Original exams: {exam_in}; subject: {subject_code}\n'
             'SET NAMES utf8mb4;\n'
             'CREATE TEMPORARY TABLE _ai_import_guard (ok TINYINT NOT NULL CHECK (ok=1));\n'
             "INSERT INTO _ai_import_guard VALUES (GET_LOCK('curriculum_question_ai_import',15));\n"
             'SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;\n'
             'START TRANSACTION;\n'
             'CREATE TEMPORARY TABLE _incoming_question_ai LIKE curriculum_question_ai;\n'
             'CREATE TEMPORARY TABLE _incoming_option_ai LIKE curriculum_option_ai;\n',
             inserts('_incoming_question_ai', QUESTION_COLUMNS, list(expected_questions.values())),
             inserts('_incoming_option_ai', OPTION_COLUMNS, list(expected_options.values()))]
    # Lock source rows and compare every original column against the validated snapshot.
    for table, alias, source_rows, obj, where in [
        ('sub_categories', 'e', source_exams, exam_obj, f'e.id IN ({exam_in})'),
        ('questions', 'q', source_questions, question_obj, f'q.sub_category_id IN ({exam_in})'),
        ('question_options', 'o', source_options, option_obj, f'o.question_id IN ({question_in})')]:
        parts.append(f'SELECT {alias}.id FROM `{table}` {alias} WHERE {where} ORDER BY {alias}.id FOR SHARE;\n')
        parts.append('CREATE TEMPORARY TABLE _expected_source (id BIGINT PRIMARY KEY, original JSON NOT NULL);\n')
        parts.append(inserts('_expected_source', ('id', 'original'),
                             [{'id': r['id'], 'original': canonical(r)} for r in source_rows]))
        parts.append(f'INSERT INTO _ai_import_guard SELECT COUNT(*)={len(source_rows)} '
                     f'FROM `{table}` {alias} WHERE {where};\n')
        # JSON_OBJECT encodes DATETIME as a MySQL JSON opaque value; normalize
        # through text so it compares exactly to the JSON read by Python.
        normalized = f'CAST(CAST({obj} AS CHAR CHARACTER SET utf8mb4) AS JSON)'
        parts.append(f'INSERT INTO _ai_import_guard SELECT NOT EXISTS '
                     f'(SELECT 1 FROM _expected_source x LEFT JOIN `{table}` {alias} ON {alias}.id=x.id '
                     f'WHERE {alias}.id IS NULL OR NOT ({normalized} <=> x.original));\n'
                     'DROP TEMPORARY TABLE _expected_source;\n')
    # Bind the import to the same active subject mapping and lesson IDs used above.
    parts.append(f'SELECT m.source_exam_id FROM curriculum_exam_subjects m '
                 f'JOIN curriculum_mapping_runs r ON r.id=m.run_id '
                 f"WHERE r.status='active' AND m.mapping_role='primary' "
                 f'AND m.source_exam_id IN ({exam_in}) ORDER BY m.source_exam_id FOR SHARE;\n')
    parts.append(f'SELECT l.id FROM curriculum_lessons l WHERE l.subject_id={subject_id} '
                 'ORDER BY l.id FOR SHARE;\n')
    for mapping in mappings:
        parts.append(f"INSERT INTO _ai_import_guard SELECT COUNT(*)=1 FROM curriculum_exam_subjects m "
                     f"JOIN curriculum_mapping_runs r ON r.id=m.run_id AND r.status='active' "
                     f"JOIN curriculum_subjects s ON s.id=m.subject_id "
                     f"WHERE m.source_exam_id={mapping['exam_id']} AND m.mapping_role='primary' "
                     f"AND m.run_id={mapping['run_id']} AND m.subject_id={subject_id} "
                     f"AND s.code={literal(subject_code)};\n")
    for code in sorted({q['ai_lesson_code'] for q in input_questions if q['ai_lesson_code']}):
        parts.append(f"INSERT INTO _ai_import_guard SELECT COUNT(*)=1 FROM curriculum_lessons "
                     f"WHERE id={lessons[code]['id']} AND subject_id={subject_id} "
                     f"AND code={literal(code)} AND lesson_kind='knowledge';\n")
    for table, stage, columns in [
        ('curriculum_question_ai', '_incoming_question_ai', QUESTION_COLUMNS),
        ('curriculum_option_ai', '_incoming_option_ai', OPTION_COLUMNS)]:
        key = columns[0]
        equal = ' AND '.join(f'(BINARY a.`{c}` <=> BINARY b.`{c}`)' for c in columns)
        parts.append(f'SELECT a.`{key}` FROM `{table}` a JOIN `{stage}` b USING (`{key}`) FOR UPDATE;\n')
        parts.append(f'INSERT INTO _ai_import_guard SELECT NOT EXISTS '
                     f'(SELECT 1 FROM `{table}` a JOIN `{stage}` b USING (`{key}`) WHERE NOT ({equal}));\n')
        col_names = ','.join(f'`{c}`' for c in columns)
        selected = ','.join(f'b.`{c}`' for c in columns)
        parts.append(f'INSERT INTO `{table}` ({col_names}) SELECT {selected} FROM `{stage}` b '
                     f'LEFT JOIN `{table}` a USING (`{key}`) WHERE a.`{key}` IS NULL;\n')
        count = len(expected_questions) if table == 'curriculum_question_ai' else len(expected_options)
        parts.append(f'INSERT INTO _ai_import_guard SELECT COUNT(*)={count} '
                     f'FROM `{table}` a JOIN `{stage}` b USING (`{key}`) WHERE {equal};\n')
    parts.append("COMMIT;\nSELECT RELEASE_LOCK('curriculum_question_ai_import');\n")
    sql = ''.join(parts)
    output = args.output_sql or args.payload.with_name(args.payload.stem + '-ai-data.sql')
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(sql, encoding='utf-8')
    report = {
        'mode': 'validate', 'subject_code': subject_code, 'exam_ids': sorted(exam_ids),
        'questions': len(expected_questions), 'options': len(expected_options),
        'existing_identical_questions': len(before_q), 'existing_identical_options': len(before_o),
        'new_questions': len(expected_questions) - len(before_q),
        'new_options': len(expected_options) - len(before_o),
        'lesson_match': dict(Counter(q['lesson_match'] for q in expected_questions.values())),
        'difficulty': dict(Counter(q['difficulty_level'] for q in expected_questions.values())),
        'original_sha256': digest(original), 'payload_sha256': hashlib.sha256(raw).hexdigest(),
        'sql_file': str(output), 'sql_sha256': hashlib.sha256(sql.encode()).hexdigest()}
    if args.apply:
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        backup = output.with_name(output.stem + '-before-' + stamp + '.json')
        backup.write_text(canonical({'payload_sha256': report['payload_sha256'],
            'questions': before_q, 'options': before_o, 'original_sha256': digest(original)}), encoding='utf-8')
        db.execute(sql)
        after_q, _ = db.rows('curriculum_question_ai', 'a', f'a.source_question_id IN ({question_in})', QUESTION_COLUMNS)
        after_o, _ = db.rows('curriculum_option_ai', 'a', f'a.source_option_id IN ({option_in})', OPTION_COLUMNS)
        require(len(after_q) == len(expected_questions) and len(after_o) == len(expected_options),
                'Post-import counts differ')
        compare_existing(after_q, expected_questions, 'source_question_id', QUESTION_COLUMNS)
        compare_existing(after_o, expected_options, 'source_option_id', OPTION_COLUMNS)
        aq, _ = db.rows('curriculum_question_ai', 'a', f'a.source_question_id NOT IN ({question_in})')
        ao, _ = db.rows('curriculum_option_ai', 'a', f'a.source_option_id NOT IN ({option_in})')
        require(digest([aq, ao]) == preserved_hash, 'Unrelated existing AI rows changed')
        report.update(mode='applied', backup_file=str(backup), source_unchanged=True,
                      unrelated_ai_rows_unchanged=True)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, RuntimeError, json.JSONDecodeError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
