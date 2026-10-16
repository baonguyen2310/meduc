-- "Luyện thi" pages: the exam-prep courses (Khóa học > Khóa luyện thi, category 125, address /khoa-luyen-thi).
--   "Luyện thi" no longer means the list of exams at /danh-sach-de-thi, which stays as it is. The header, footer and
--   phone action bar link to /khoa-luyen-thi in their templates; this script does the parts kept in the database:
--   - the second button of the homepage hero (block herowal, "Vào khoá luyện thi") links to /khoa-luyen-thi;
--   - the related-courses rail of the course page (block sw780fy) reads up to 200 products, because the exam-prep
--     courses are the newest products in the course category; view_course_related.tpl keeps courses for a course and
--     exam-prep courses for an exam-prep course, at most 12.
-- Run after scripts/publish_exam_prep_courses.php, then clear the website cache. Safe to re-run.
-- To go back:
--   UPDATE templates_block SET normal_data_extend = JSON_SET(normal_data_extend, '$.locale.vi.link_nut_chinh_2', '/danh-sach-de-thi') WHERE template_code = 'app01' AND code = 'herowal';
--   UPDATE templates_block SET config = JSON_SET(config, '$.number_record', '12') WHERE template_code = 'app01' AND code = 'sw780fy';

SET NAMES utf8mb4;

UPDATE templates_block
SET normal_data_extend = JSON_SET(normal_data_extend, '$.locale.vi.link_nut_chinh_2', '/khoa-luyen-thi')
WHERE template_code = 'app01' AND code = 'herowal'
  AND JSON_UNQUOTE(JSON_EXTRACT(normal_data_extend, '$.locale.vi.link_nut_chinh_2')) = '/danh-sach-de-thi';

UPDATE templates_block
SET config = JSON_SET(config, '$.number_record', '200')
WHERE template_code = 'app01' AND code = 'sw780fy'
  AND JSON_UNQUOTE(JSON_EXTRACT(config, '$.number_record')) = '12';
