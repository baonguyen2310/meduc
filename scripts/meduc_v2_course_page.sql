-- Course page as a classroom (page z6teqsj "Chi tiết sản phẩm", used by every course).
--   crclass "Khoá học - Không gian học tập" (product_detail, block/product_detail/view_classroom.tpl,
--   assets/meduc-v2/classroom.css and classroom.js) replaces the old title, price/sign-up and content blocks:
--   the course outline on the left, and on the right the course introduction or the selected lesson.
-- Its "Dữ liệu mở rộng" start from the old blocks: link_zalo and loi_moi from jcqsxy5, ghi_chu_bai_tap from vajmr7c.
-- The FAQ, questions, ratings and related-course blocks stay on the page; classroom.js moves them into the introduction.
-- The FAQ (6a5tyhf) and related courses (sw780fy) get new views: block/slider/view_faq_accordion.tpl and
-- block/product/view_course_related.tpl. The old "Cảm Nhận Của Học Viên" row leaves this page:
-- the classroom's "Phản hồi học viên" tab shows the videos of block fbvideos (scripts/meduc_v2_feedback_page.sql)
-- whose course link is the course being viewed, and the reviews of block hvreview.
-- Code also needed on the server: coredaca/src/View/Helper/BlockHelper.php (getSliderItems).
--
-- Run once on the MedUC PHP database after meduc_v2_feedback_page.sql, then clear the website cache from the admin bar.
-- Safe to re-run: the block is inserted only when missing, and only the original row and column values are changed.
-- To go back:
--   UPDATE templates_column SET block_code = 'mz4eo5d' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code IN ('qmh1xt0', 'qb1kuld') AND block_code = 'crclass';
--   UPDATE templates_row SET config = '{"id_row":"","style_class":"bg-breadcrums py-10","full_screen":""}' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND code IN ('qmh1xt0', 'qb1kuld');
--   UPDATE templates_column SET block_code = '5vw4hay,vajmr7c,6a5tyhf', column_value = 8 WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'k38bhfj' AND block_code = '6a5tyhf';
--   UPDATE templates_column SET block_code = 'jcqsxy5' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'k38bhfj' AND column_value = 4 AND block_code = '';
--   UPDATE templates_column SET block_code = '5vw4hay' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'l09iro5' AND block_code = '';
--   UPDATE templates_column SET block_code = 'jcqsxy5' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'nxhqsd4' AND block_code = '';
--   UPDATE templates_column SET block_code = 'vajmr7c' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'fr5je2t' AND block_code = '';
--   UPDATE templates_column SET block_code = 'bptjnf0' WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code IN ('bd37gl9', 'jvtlipf') AND block_code = '';
--   UPDATE templates_block SET view = 'view_faqs.tpl' WHERE template_code = 'app01' AND code = '6a5tyhf' AND view = 'view_faq_accordion.tpl';
--   UPDATE templates_block SET view = 'view.tpl' WHERE template_code = 'app01' AND code = 'sw780fy' AND view = 'view_course_related.tpl';

SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'crclass', 'Khoá học - Không gian học tập', 'product_detail', '', 'view_classroom.tpl', '',
  '{"class":"","cache":"0","data_type":"by_url"}',
  NULL,
  JSON_OBJECT('locale', JSON_OBJECT('vi', JSON_OBJECT(
    'link_zalo', COALESCE(JSON_UNQUOTE(JSON_EXTRACT(head.normal_data_extend, '$.locale.vi.link_zalo')), ''),
    'loi_moi', TRIM(BOTH '"' FROM COALESCE(JSON_UNQUOTE(JSON_EXTRACT(head.normal_data_extend, '$.locale.vi.text_2')), '')),
    'ghi_chu_bai_tap', TRIM(BOTH '"' FROM COALESCE(JSON_UNQUOTE(JSON_EXTRACT(content.normal_data_extend, '$.locale.vi.text_1')), ''))
  )), 'normal', JSON_OBJECT()),
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'khoa hoc - khong gian hoc tap | crclass', 0
FROM templates_block head
JOIN templates_block content ON content.template_code = 'app01' AND content.code = 'vajmr7c'
WHERE head.template_code = 'app01' AND head.code = 'jcqsxy5'
  AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'crclass');

-- The classroom takes the breadcrumb row (the first row) and spans the full width.
UPDATE templates_column SET block_code = 'crclass'
WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code IN ('qmh1xt0', 'qb1kuld') AND block_code = 'mz4eo5d';
UPDATE templates_row SET config = '{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND code IN ('qmh1xt0', 'qb1kuld');

-- Desktop: the old two columns keep only the FAQ, now full width.
UPDATE templates_column SET block_code = '6a5tyhf', column_value = 12
WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'k38bhfj' AND block_code = '5vw4hay,vajmr7c,6a5tyhf';
UPDATE templates_column SET block_code = ''
WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code = 'k38bhfj' AND block_code = 'jcqsxy5';

-- Phones: the old title, price and content rows.
UPDATE templates_column SET block_code = ''
WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code IN ('l09iro5', 'nxhqsd4', 'fr5je2t')
  AND block_code IN ('5vw4hay', 'jcqsxy5', 'vajmr7c');

-- The old student feedback row, now inside the classroom's feedback tab.
UPDATE templates_column SET block_code = ''
WHERE template_code = 'app01' AND page_code = 'z6teqsj' AND row_code IN ('bd37gl9', 'jvtlipf') AND block_code = 'bptjnf0';

-- New looks for the FAQ and related courses (both blocks are only on this page).
UPDATE templates_block SET view = 'view_faq_accordion.tpl'
WHERE template_code = 'app01' AND code = '6a5tyhf' AND view = 'view_faqs.tpl';
UPDATE templates_block SET view = 'view_course_related.tpl'
WHERE template_code = 'app01' AND code = 'sw780fy' AND view = 'view.tpl';
