#!/usr/bin/env python3
"""Publish subject-exam JSONs through SSH. Plan by default; --apply writes, --verify reads back.

Reference exams are materialized from the approved lesson banks, retaining assembly provenance.
No source questions, existing attempts, Fa exams or unrelated courses are rewritten.
"""
import argparse
import copy
import datetime
import hashlib
import html
import json
from pathlib import Path
import shlex
import subprocess
import uuid

from publish_lesson_exercises import DEFAULT_DATA, SUBJECTS, prepare, require


def build(data_dir, subject, public_base, remote_dir):
    subject_code = SUBJECTS[subject]
    bank = {}
    assets = {}
    paths = sorted((data_dir / 'de-theo-bai' / subject).glob('bai-*/*-2-bai-tap-40-cau.json'))
    require(bool(paths), 'Lesson bank missing.')
    for path in paths:
        number = json.loads(path.read_text())['curriculum']['lesson_number']
        lesson, images = prepare(path, subject_code, number, public_base, remote_dir)
        assets.update(images)
        for exam in lesson['exams']:
            for question in exam['questions']:
                require(question['code'] not in bank, 'Duplicate source code.')
                bank[question['code']] = (lesson, exam, question)
    groups = []
    for folder, kind, label, suffix in [('giua-ky', 'midterm', 'Bài giữa kỳ', 'MIDTERM'),
                                        ('thuc-hanh', 'practical', 'Bài thực hành', 'PRACTICAL'),
                                        ('cuoi-ky', 'final', 'Bài cuối kỳ', 'FINAL')]:
        exams = []
        for path in sorted((data_dir / 'de-theo-mon' / subject / folder).glob(f'{subject}-{folder}-[0-9]*.json')):
            doc = json.loads(path.read_text())
            meta = copy.deepcopy(doc['metadata'])
            require(meta['subject_code'] == subject_code and meta['lesson_type'] == kind, 'Subject/type mismatch.')
            questions = []
            if doc['schema_version'].startswith('meduc.exam-question-references/'):
                for position, ref in enumerate(doc['questions'], 1):
                    lesson, source_exam, source = bank[ref['source_question_code']]
                    require(lesson['lesson_code'] == ref['source_lesson_code'] and
                            source_exam['metadata']['code'] == ref['source_exercise_code'] and
                            source['order_index'] == ref['source_exercise_question_order'], 'Broken source reference.')
                    q = copy.deepcopy(source)
                    q['order_index'] = position
                    q['assembly_source'] = copy.deepcopy(ref)
                    q['assembly_exam_code'] = meta['code']
                    questions.append(q)
            else:
                require(kind == 'practical', 'Only practical exams may contain source short-answer questions.')
                questions = copy.deepcopy(doc['questions'])
                for position, q in enumerate(questions, 1):
                    require(q['question_type'] == 'TULUAN' and q.get('answer_vi') and q.get('ai_general_explanation'), 'Incomplete practical answer.')
                    q['question_category'] = q['question_kind']
                    q['difficulty_level'] = {'comprehension': 'understanding'}.get(q['difficulty_level'], q['difficulty_level'])
                    require(q['order_index'] == position, 'Practical order differs.')
                    tags = []
                    require(len(q.get('images', [])) == len(q.get('image_assets', [])), 'Practical image missing.')
                    for asset in q.get('image_assets', []):
                        local = (path.parent / asset['file']).resolve()
                        require(local.is_relative_to(path.parent.resolve()), 'Image escapes source directory.')
                        digest = hashlib.sha256(local.read_bytes()).hexdigest()
                        require(digest == asset['sha256'], 'Practical image checksum differs.')
                        filename = digest + local.suffix.lower()
                        require(local.suffix.lower() in ('.png', '.jpg', '.jpeg', '.webp'), 'Unsupported image format.')
                        url = public_base.rstrip('/') + '/cdn/media/lesson-exercises/' + filename
                        assets[filename] = (local, {'filename': filename, 'sha256': digest, 'staged_path': remote_dir + '/' + filename,
                                                   'relative_path': 'cdn/media/lesson-exercises/' + filename})
                        asset['published_url'] = url
                        tags.append('<p><img src="' + html.escape(url, quote=True) + '" alt="Hình thực hành giải phẫu" loading="lazy"></p>')
                    q['description_vi'] = q.get('description_vi', '') + ''.join(tags)
                meta.update(answer_mode='show_answer_only', feedback_mode='reference', require_student_response=False)
            require(len(questions) == meta['total_questions'], 'Question count differs.')
            require(len({q['code'] for q in questions}) == len(questions), 'Duplicate question within exam.')
            meta['duration_minutes'] = 0 if kind == 'practical' else int(meta.get('duration_minutes') or 30)
            exams.append({'metadata': meta, 'questions': questions, 'source_file': str(path),
                          'input_sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
        require(bool(exams), f'No exams for {kind}.')
        if subject == 'giai-phau': require(len(exams) == {'midterm': 3, 'practical': 2, 'final': 90}[kind], 'Incomplete Anatomy batch.')
        groups.append({'lesson_type': kind, 'lesson_name': label, 'lesson_code': f'CEO5-20261110-{subject_code}-{suffix}', 'exams': exams})
    return {'subject_code': subject_code, 'product_code': 'MEDUC-32V1-Q-' + subject_code, 'groups': groups,
            'assets': [entry[1] for entry in assets.values()]}, assets


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--subject', choices=SUBJECTS, required=True)
    parser.add_argument('--data-dir', type=Path, default=DEFAULT_DATA.parent)
    parser.add_argument('--host', default='pbf43-22360.azdigihost.com')
    parser.add_argument('--user', default='kbbcutgf')
    parser.add_argument('--port', type=int, default=2210)
    parser.add_argument('--key', type=Path, default=Path.home() / 'Downloads/id_rsa_meduc')
    parser.add_argument('--app-root', default='/home/kbbcutgf/public_html')
    parser.add_argument('--backup-root', default='/home/kbbcutgf/backups/subject-exams')
    parser.add_argument('--public-base', default='https://meduc.vn')
    parser.add_argument('--report', type=Path)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--apply', action='store_true')
    modes.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    run = datetime.datetime.now().strftime('%Y%m%d-%H%M%S') + '-' + uuid.uuid4().hex[:8]
    remote_dir = args.backup_root.rstrip('/') + '/' + run
    payload, assets = build(args.data_dir, args.subject, args.public_base, remote_dir)
    payload['app_root'] = args.app_root
    ssh = ['ssh', '-p', str(args.port), '-i', str(args.key), '-o', 'BatchMode=yes', '-o', 'IdentitiesOnly=yes',
           '-o', 'StrictHostKeyChecking=yes', '-o', 'ConnectTimeout=15', args.user + '@' + args.host]
    def remote(command, data=None):
        result = subprocess.run(ssh + [command], input=data, capture_output=True)
        if result.returncode: raise RuntimeError((result.stdout + result.stderr).decode('utf-8', 'replace'))
        return result.stdout.decode('utf-8')
    remote('umask 077; mkdir -p ' + shlex.quote(remote_dir))
    # One tar upload also handles all practical images without forty separate SSH sessions.
    import io
    import tarfile
    uploads = {'payload.json': json.dumps(payload, ensure_ascii=False).encode(),
               'import.php': Path(__file__).with_name('import_subject_exams.php').read_bytes()}
    uploads.update({name: entry[0].read_bytes() for name, entry in assets.items()})
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode='w:gz') as archive:
        for name, content in uploads.items():
            info = tarfile.TarInfo(name); info.size = len(content); info.mode = 0o600
            archive.addfile(info, io.BytesIO(content))
    remote('umask 077; tar -xzf - -C ' + shlex.quote(remote_dir), stream.getvalue())
    mode = 'apply' if args.apply else 'verify' if args.verify else 'plan'
    output = remote('php -d memory_limit=512M ' + shlex.quote(remote_dir + '/import.php') + ' ' + mode + ' ' + shlex.quote(remote_dir + '/payload.json') + ' ' + shlex.quote(remote_dir + '/before.json'))
    report = json.loads(output)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__': main()
