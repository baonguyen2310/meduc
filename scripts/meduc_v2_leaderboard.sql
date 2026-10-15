-- Leaderboard page (page crm5st1, address /class-rank): "Bảng xếp hạng" and "Chỉ số tiến bộ của bạn".
--   bxhrank "Bảng xếp hạng" (slider type used only for its view: block/slider/view_leaderboard.tpl,
--   assets/meduc-v2/leaderboard.css and leaderboard.js) replaces the class ranking table (html block f70p4vk).
--   The board is per course (or all courses) and per period, from the quiz history (quizs_answer); old links
--   /class-rank?class-room-id=… open the class's course. The page now has its own heading, so the row spans the full width.
-- Code also needed on the server: coredaca/src/View/Helper/LeaderboardHelper.php (and MemberHelper::getCourseAccessList
--   from scripts/meduc_v2_course_enrollment.sql).
--
-- Run once on the MedUC PHP database, then clear the website cache from the admin bar.
-- Safe to re-run: the block is inserted only when missing, and only the original values are changed.
-- To go back:
--   UPDATE templates_column SET block_code = 'f70p4vk' WHERE template_code = 'app01' AND page_code = 'crm5st1' AND row_code = 'mrgb0pk' AND block_code = 'bxhrank';
--   UPDATE templates_row SET config = '{"id_row":"","style_class":"my-60","full_screen":""}' WHERE template_code = 'app01' AND page_code = 'crm5st1' AND code = 'mrgb0pk';
--   UPDATE templates_page SET name = 'Xếp hạng trong lớp học' WHERE template_code = 'app01' AND code = 'crm5st1';
--   UPDATE templates_page_content SET seo_title = 'Xếp hạng trong lớp học' WHERE template_code = 'app01' AND page_code = 'crm5st1';

SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'bxhrank', 'Bảng xếp hạng', 'slider', '', 'view_leaderboard.tpl', '',
  '{"class":"","cache":"0","item":[]}',
  NULL, NULL,
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'bang xep hang | bxhrank', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'bxhrank');

UPDATE templates_column SET block_code = 'bxhrank'
WHERE template_code = 'app01' AND page_code = 'crm5st1' AND row_code = 'mrgb0pk' AND block_code = 'f70p4vk';
UPDATE templates_row SET config = '{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code = 'app01' AND page_code = 'crm5st1' AND code = 'mrgb0pk';

UPDATE templates_page SET name = 'Bảng xếp hạng'
WHERE template_code = 'app01' AND code = 'crm5st1' AND name = 'Xếp hạng trong lớp học';
UPDATE templates_page_content SET seo_title = 'Bảng xếp hạng'
WHERE template_code = 'app01' AND page_code = 'crm5st1' AND seo_title = 'Xếp hạng trong lớp học';
