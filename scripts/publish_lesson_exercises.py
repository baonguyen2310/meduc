#!/usr/bin/env python3
"""Publish selected lesson JSONs to MedUC. Defaults to a read-only plan.

Example: python3 publish_lesson_exercises.py --subject giai-phau --lessons 1,2 --apply
Use --verify for readback only. --replace permits changed content only without attempts.
Uses the current SSH agent/key; no hosting/database credentials are stored here.
"""
import argparse
import copy
import datetime
import hashlib
import html
import json
from pathlib import Path
import re
import shlex
import subprocess
import sys
import uuid

WORKSPACE=Path('/Users/Shared/architecture')
DEFAULT_DATA=WORKSPACE/'meduc-cao/data/research/ceo-approved-5/2026-11-10/de-theo-bai'
SUBJECTS={'giai-phau':'MV2-S004','hoa-sinh':'MV2-S007','ly-sinh':'MV2-S003','sinh-hoc':'MV2-S001','hoa-hoc':'MV2-S002'}
LEVELS={'recognition','understanding','application'}
CATEGORIES={'theory','calculation','image','clinical'}

def require(ok,message):
    if not ok:raise ValueError(message)

def lesson_numbers(text):
    values=[]
    for part in text.split(','):
        require(bool(re.fullmatch(r'\s*[1-9]\d*\s*',part)), 'Use lesson numbers such as 1,2,5.')
        values.append(int(part))
    require(len(set(values))==len(values),'Duplicate lesson numbers.')
    return sorted(values)

def prepare(path,subject,number,public_base,remote_dir):
    original=json.loads(path.read_text())
    require(original.get('schema_version')=='meduc.lesson-exercises/2026-11-10',f'{path}: unsupported JSON schema.')
    require(original.get('subject_code')==subject,f'{path}: subject differs.')
    curriculum=original['curriculum']
    require(curriculum['lesson_number']==number,f'{path}: lesson number differs.')
    exams=copy.deepcopy(original['exams'])
    require(len(exams)==2,f'{path}: a lesson needs two exercises.')
    exams.sort(key=lambda e:e['metadata']['exercise_number'])
    require([e['metadata']['exercise_number'] for e in exams]==[1,2],'Expected exercises 1 and 2.')
    files={};codes=set()
    for exam in exams:
        questions=exam['questions']
        require(len(questions)==20 and exam['metadata']['total_questions']==20,'An exercise needs exactly 20 questions.')
        clinical=0
        for index,q in enumerate(questions,1):
            require(q.get('code') and q['code'] not in codes,'Missing or duplicate question code.')
            codes.add(q['code'])
            require(q['ai_subject_code']==subject and q['ai_lesson_code']==curriculum['lesson_code'],'Question belongs to another lesson.')
            require(q['question_type']=='MULTIPLE_CHOICE','This importer currently supports MCQs.')
            require(q.get('order_index')==index,'Question order differs.')
            options=q['options']
            require(4<=len(options)<=5,'Expected four or five choices.')
            correct=[i for i,o in enumerate(options,1) if o.get('is_correct') is True]
            require(len(correct)==1 and str(correct[0])==q['answer_vi'],'Answer key differs from choices.')
            require([o['key'] for o in options]==list('ABCDE'[:len(options)]),'Choice labels differ.')
            require(q.get('ai_general_explanation','').strip(),'Missing concept explanation.')
            for option in options:
                prefix='Đúng vì' if option['is_correct'] else 'Sai vì'
                require(option.get('ai_explanation','').startswith(prefix),'Missing correct/incorrect choice explanation.')
                # The course player already prints the coloured verdict before this reason.
                option['ai_explanation']=option['ai_explanation'][len(prefix):].lstrip()
            level=q['difficulty_level']
            q['difficulty_level']='understanding' if level=='comprehension' else level
            q['question_category']=q['question_kind']
            require(q['difficulty_level'] in LEVELS and q['question_category'] in CATEGORIES,'Invalid question classification.')
            if q['question_category']=='clinical':
                clinical+=1
                require(q['difficulty_level']=='application','Clinical questions must use application level.')
            assets=q.get('image_assets',[])
            require(not q.get('images') or len(assets)==len(q['images']),'Every image needs a local image_assets entry.')
            tags=[]
            for asset in assets:
                asset_path=(path.parent/asset['local_file']).resolve()
                require(asset_path.is_relative_to(path.parent.resolve()),'Image must be inside the lesson directory.')
                content=asset_path.read_bytes();digest=hashlib.sha256(content).hexdigest()
                require(digest==asset['sha256'],'Image checksum differs.')
                ext=asset_path.suffix.lower()
                require(ext in ('.jpg','.jpeg','.png','.webp','.gif'),'Unsupported image format.')
                filename=digest+ext
                url=public_base.rstrip('/')+'/cdn/media/lesson-exercises/'+filename
                files[filename]=(asset_path,{'filename':filename,'sha256':digest,'staged_path':remote_dir+'/'+filename,'relative_path':'cdn/media/lesson-exercises/'+filename})
                tags.append('<p><img src="'+html.escape(url,quote=True)+'" alt="Hình minh hoạ câu hỏi" loading="lazy"></p>')
                asset['published_url']=url
            if tags:
                q['description_vi']=q.get('description_vi','')+''.join(tags)
    return {'lesson_number':number,'lesson_code':curriculum['lesson_code'],'lesson_name':curriculum['lesson_name'],'exams':exams,'input_sha256':hashlib.sha256(path.read_bytes()).hexdigest()},files

def main():
    ap=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--subject',choices=SUBJECTS,required=True)
    ap.add_argument('--lessons',required=True,help='1 or 1,2,5')
    ap.add_argument('--data-dir',type=Path,default=DEFAULT_DATA)
    ap.add_argument('--host',default='pbf43-22360.azdigihost.com')
    ap.add_argument('--user',default='kbbcutgf');ap.add_argument('--port',type=int,default=2210)
    ap.add_argument('--key',type=Path,default=Path.home()/'Downloads/id_rsa_meduc')
    ap.add_argument('--app-root',default='/home/kbbcutgf/public_html')
    ap.add_argument('--backup-root',default='/home/kbbcutgf/backups/lesson-exercises')
    ap.add_argument('--public-base',default='https://meduc.vn')
    ap.add_argument('--report',type=Path)
    ap.add_argument('--replace',action='store_true',help='Allow changed questions only if the exercise has no attempts.')
    modes=ap.add_mutually_exclusive_group();modes.add_argument('--apply',action='store_true');modes.add_argument('--verify',action='store_true')
    args=ap.parse_args();numbers=lesson_numbers(args.lessons)
    run=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')+'-'+uuid.uuid4().hex[:8]
    remote_dir=args.backup_root.rstrip('/')+'/'+run
    payload={'subject_code':SUBJECTS[args.subject],'product_code':'MEDUC-32V1-Q-'+SUBJECTS[args.subject],'app_root':args.app_root,'replace':args.replace,'lessons':[],'assets':[]}
    assets={}
    for number in numbers:
        folder=args.data_dir/args.subject/f'bai-{number:02}'
        matches=sorted(folder.glob(f'*-bai-{number:02}-2-bai-tap-40-cau.json'))
        require(len(matches)==1,f'Expected exactly one lesson JSON in {folder}; found {len(matches)}.')
        lesson,images=prepare(matches[0],payload['subject_code'],number,args.public_base,remote_dir)
        payload['lessons'].append(lesson);assets.update(images)
    payload['assets']=[value[1] for value in assets.values()]
    ssh=['ssh','-p',str(args.port),'-i',str(args.key),'-o','BatchMode=yes','-o','IdentitiesOnly=yes','-o','StrictHostKeyChecking=yes','-o','ConnectTimeout=15',args.user+'@'+args.host]
    def remote(command,data=None):
        result=subprocess.run(ssh+[command],input=data,capture_output=True)
        if result.returncode:raise RuntimeError((result.stdout+result.stderr).decode('utf-8','replace'))
        return result.stdout.decode('utf-8')
    remote('umask 077; mkdir -p '+shlex.quote(remote_dir)+'; chmod 700 '+shlex.quote(remote_dir))
    uploads={'payload.json':json.dumps(payload,ensure_ascii=False).encode(),'import.php':Path(__file__).with_name('import_lesson_exercises.php').read_bytes()}
    uploads.update({name:entry[0].read_bytes() for name,entry in assets.items()})
    for filename,content in uploads.items():remote('umask 077; cat > '+shlex.quote(remote_dir+'/'+filename),content)
    mode='apply' if args.apply else 'verify' if args.verify else 'plan'
    command='php '+shlex.quote(remote_dir+'/import.php')+' '+mode+' '+shlex.quote(remote_dir+'/payload.json')+' '+shlex.quote(remote_dir+'/before.json')
    output=remote(command);report=json.loads(output)
    if args.report:
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(report,ensure_ascii=False,indent=2))

if __name__=='__main__':
    try:main()
    except (ValueError,RuntimeError,KeyError,OSError) as error:
        print('ERROR: '+str(error),file=sys.stderr);sys.exit(1)
