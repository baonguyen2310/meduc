"""Build the private 2033-exam import from a fresh Civo source export."""
import argparse
import csv
import gzip
import hashlib
import json
import re
import unicodedata


def clean_explanation(text):
    text = text or ''
    patterns = [r'[✨\s]*Tải\s+FA\s+Hack[^\n]*\n*https?://[^\s]+',
                r'Sorry,\s*bạn đã hết lượt hỏi miễn phí[^\n]*https?://[^\s]*',
                r'Bạn đã hết lượt hỏi đáp miễn phí[^\n]*https?://[^\s]*',
                r'Câu này khó,\s*tải FA Hack[^\n]*https?://[^\s]*',
                r'https?://fanotes\.com[^\s]*', r'[✨\s]*Tải\s+FA\s+Hack[^\n]*']
    for pattern in patterns:
        text = re.sub(pattern, '', text, flags=re.I)
    return text.strip()


def search(text):
    return ''.join(c for c in unicodedata.normalize('NFD', text.lower().replace('đ', 'd')) if not unicodedata.combining(c))


def main():
    p = argparse.ArgumentParser()
    p.add_argument('source'); p.add_argument('hierarchy'); p.add_argument('csv'); p.add_argument('output')
    a = p.parse_args()
    hierarchy = {int(e['id']): e for e in json.load(open(a.hierarchy))['exams']}
    catalog = {int(e['id']): e for e in csv.DictReader(open(a.csv, encoding='utf-8-sig'))}
    source = [json.loads(line) for line in gzip.open(a.source, 'rt')]
    assert len(source) == len(hierarchy) == len(catalog) == 2033
    assert {int(x['exam']['id']) for x in source} == set(hierarchy)
    records = []
    for item in source:
        e = item['exam']; h = hierarchy[int(e['id'])]; c = catalog[int(e['id'])]
        assert e['name'].strip() == h['title'].strip() == c['name'].strip()
        assert e['standardized_subject'] == h['topic']
        questions = []
        for i, q in enumerate(item['questions']):
            options = q['options']
            legacy = {'code': 'q_' + str(i + 1), 'name_vi': q['content'], 'description_vi': '',
                      'answer_vi': '', 'answer_detail_vi': clean_explanation(q['explanation']), 'files': '',
                      'source_question_id': q['id'], 'question_type': q['question_type'],
                      'options': options, 'images': q['images'], 'rubrics': q['rubrics']}
            correct = [str(j + 1) for j, o in enumerate(options) if o['is_correct']]
            if len(correct) == 1:
                legacy['answer_vi'] = correct[0]
            for j, word in enumerate(['one', 'two', 'three', 'four', 'five']):
                legacy['option_' + word + '_vi'] = options[j]['content'] if j < len(options) else ''
            questions.append(legacy)
        metadata = {'source_system': 'facourse', 'source_exam_id': int(e['id']),
                    'source_remote_id': str(e['remote_id']), 'source_category_id': int(h['categoryId']),
                    'source_category_name': h['category'], 'import_topic': h['topic'], 'school_name': h['school'],
                    'year_in_title': h['year'], 'source_quiz_type': e['quiz_type'], 'curriculum_type': h['type'],
                    'source_is_pro': int(e['is_pro']), 'question_count': len(questions),
                    'source_question_count': int(e['total_questions']),
                    'source_hash': hashlib.sha256(json.dumps(item, ensure_ascii=False, sort_keys=True).encode()).hexdigest(),
                    'staff_only': 1}
        records.append({'type': 'exam', 'name': e['name'].strip(), 'search_unicode': search(e['name'].strip()),
                        'duration': int(e['duration_minutes']) or max(15, int(len(questions)*1.5)),
                        'metadata': metadata, 'questions': questions})
    topics = sorted({r['metadata']['import_topic'] for r in records})
    assert len(topics) == 88
    with gzip.open(a.output, 'wt', encoding='utf-8') as output:
        output.write(json.dumps({'type':'manifest','exams':2033,'topics':topics,'questions':sum(len(r['questions']) for r in records)},ensure_ascii=False)+'\n')
        for record in records:
            output.write(json.dumps(record,ensure_ascii=False,separators=(',', ':'))+'\n')
    print('Prepared',len(records),'exams;',len(topics),'courses;',sum(len(r['questions']) for r in records),'questions')


if __name__ == '__main__':
    main()
