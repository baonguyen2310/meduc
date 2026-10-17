#!/usr/bin/env python3
"""Show the 108 local curriculum courses in the public catalogue, not their exams.

Run without --apply to inspect the current state. This script only changes
visibility of products mapped in curriculum_v2_courses and their sellable item.
It never changes quizs or quiz_exam_metadata.
"""
from __future__ import annotations

import argparse
import sys

from curriculum_v2_local import connect_target, encoded, one, require


def inspect(cur):
    cur.execute('''SELECT cv.product_id,p.main_category_id,p.status,p.draft,p.deleted,
        pi.id AS item_id,pi.status AS item_status,pi.deleted AS item_deleted,
        e.staff_only
        FROM curriculum_v2_courses cv
        JOIN products p ON p.id=cv.product_id
        JOIN products_item pi ON pi.product_id=p.id
        JOIN exam_prep_courses e ON e.product_id=p.id
        ORDER BY cv.product_id''')
    rows = cur.fetchall()
    require(len(rows) == 108 and len({r['product_id'] for r in rows}) == 108,
            'Expected exactly one item for each of 108 curriculum courses')
    draft = (0, 1, 0, 1)
    published = (1, 0, 1, 0)
    for r in rows:
        state = (r['status'], r['draft'], r['item_status'], r['staff_only'])
        require(r['main_category_id'] == 125 and r['deleted'] == 0 and
                r['item_deleted'] == 0 and state in (draft, published),
                f'Unexpected category or visibility for course {r["product_id"]}')
    require(one(cur, '''SELECT COUNT(*) n FROM quiz_exam_metadata m
        JOIN quizs q ON q.id=m.quiz_id
        WHERE m.source_system='meduc-source-v2'
        AND (m.staff_only<>1 OR q.status<>0 OR q.draft<>1 OR q.deleted<>0)''')['n'] == 0,
        'A source exam is not private; catalogue publishing halted')
    return {'total': len(rows), 'draft': sum(
        (r['status'], r['draft'], r['item_status'], r['staff_only']) == draft for r in rows)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    db = connect_target()
    try:
        with db.cursor() as cur:
            before = inspect(cur)
            if not args.apply:
                print(encoded({'mode': 'plan', **before}))
                return
            db.begin()
            try:
                cur.execute('''UPDATE products p JOIN curriculum_v2_courses cv ON cv.product_id=p.id
                    SET p.status=1,p.draft=0''')
                cur.execute('''UPDATE products_item pi
                    JOIN curriculum_v2_courses cv ON cv.product_id=pi.product_id
                    SET pi.status=1''')
                cur.execute('''UPDATE exam_prep_courses e
                    JOIN curriculum_v2_courses cv ON cv.product_id=e.product_id
                    SET e.staff_only=0''')
                after = inspect(cur)
                require(after['draft'] == 0, 'Some curriculum courses remain private')
                db.commit()
            except Exception:
                db.rollback()
                raise
            print(encoded({'mode': 'applied', 'before': before, 'after': after,
                           'source_exams': 'unchanged and private'}))
    finally:
        db.close()


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'ERROR: {error}', file=sys.stderr)
        raise
