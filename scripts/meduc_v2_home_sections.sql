-- Homepage sections under the hero, in this order:
--   gvrail   "Trang chủ - Đội ngũ giảng viên và cố vấn"  view block/slider/view_faculty_rail.tpl
--   hvvideo  "Trang chủ - Video cảm nhận học viên"        view block/slider/view_video_feedback.tpl
--   hvreview "Trang chủ - Phản hồi học viên (chữ và ảnh)" view block/slider/view_student_reviews.tpl
-- Styles and scripts: templates/app01/assets/meduc-v2/{faculty,video-feedback,reviews}.css and {rail,video-feedback,reviews}.js.
-- Content stays editable in admin: Giao diện > Block. Items are the slider list; texts are "Dữ liệu mở rộng" (an empty value hides that line).
--   gvrail starts as a copy of the team on the About page (block l06kedm); after that the two lists are edited separately.
--   hvreview quotes four real Facebook reviews; the screenshots and names come from the "CÁC HỌC VIÊN TIÊU BIỂU" block (jablkdt).
--
-- Run once on the MedUC PHP database after meduc_v2_home_hero.sql, then clear the website cache from the admin bar.
-- Safe to re-run: blocks are inserted only when missing, and only the original column values are changed.
-- The three blocks join the hero's column, because the CMS orders rows by id and cannot insert a row between two others.
-- The old "Cảm Nhận Của Học Viên" row (block bptjnf0) leaves the homepage so the videos are not shown twice; it stays on other pages.
-- To go back:
--   UPDATE templates_column SET block_code = 'herowal'
--   WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('xvy1d68', 'vd4sx71') AND block_code = 'herowal,gvrail,hvvideo,hvreview';
--   UPDATE templates_column SET block_code = 'bptjnf0'
--   WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('r9p1b2m', 'tifa3zg') AND block_code = '';

SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'gvrail', 'Trang chủ - Đội ngũ giảng viên và cố vấn', 'slider', '', 'view_faculty_rail.tpl', '',
  src.config,
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"CON NGƯỜI MEDUC",
    "tieu_de":"Đội Ngũ Giảng Viên Và Cố Vấn",
    "mo_ta":"Gặp gỡ những người đồng hành cùng bạn trên hành trình học Y.",
    "chu_cuoi":"Học từ kinh nghiệm của đội ngũ MedUC.",
    "nut_xem_tat_ca":"Xem toàn bộ đội ngũ",
    "link_xem_tat_ca":"/gioi-thieu"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - doi ngu giang vien va co van | gvrail', 0
FROM templates_block src
WHERE src.template_code = 'app01' AND src.code = 'l06kedm'
  AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'gvrail');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'hvvideo', 'Trang chủ - Video cảm nhận học viên', 'slider', '', 'view_video_feedback.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Phản hồi khóa học Giải phẫu, Tiếng Anh Y khoa","url_vi":"https://www.youtube.com/watch?v=g9wXdFv1mTw","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu · Tiếng Anh Y khoa","description_short_vi":""},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=mvoFlFPB-rE","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":""},
    {"name_vi":"Phản hồi khóa học Giải phẫu","url_vi":"https://www.youtube.com/watch?v=YfhMZ9LwkZo","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu","description_short_vi":""},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=sJDkfvW7oxk","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":""},
    {"name_vi":"Phản hồi khóa học Tiếng Anh Y khoa","url_vi":"https://www.youtube.com/watch?v=OlefssQgsXY","class_item":"","image":"","image_source":"","description_vi":"Tiếng Anh Y khoa","description_short_vi":""},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=bn_BJlYt9jI","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":""}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"CẢM NHẬN CỦA HỌC VIÊN",
    "tieu_de_dong_1":"HỌC THẬT.",
    "tieu_de_dong_2":"CẢM NHẬN THẬT.",
    "mo_ta":"Nghe chính người học chia sẻ về hành trình học Y cùng MedUC.",
    "nut_xem_tat_ca":"Xem tất cả cảm nhận",
    "link_xem_tat_ca":"/phan-hoi-hoc-vien"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - video cam nhan hoc vien | hvvideo', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'hvvideo');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'hvreview', 'Trang chủ - Phản hồi học viên (chữ và ảnh)', 'slider', '', 'view_student_reviews.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Nguyễn Văn An","url_vi":"","class_item":"","image":"/media/img_3426.jpg","image_source":"cdn","description_vi":"Bác sĩ tại huyện Phú Vang","description_short_vi":"Rất may mắn biết đến trung tâm này, tôi theo học trong quá trình 6 tháng ở Trung tâm thì tôi cảm nhận được các thạc sĩ, bác sĩ ở đó dạy rất nhiệt tình, tôi không hiểu ở chỗ nào thì được giải đáp rất tận tình."},
    {"name_vi":"Hữu Tân","url_vi":"","class_item":"","image":"/media/img_3422.jpg","image_source":"cdn","description_vi":"Sinh viên Y khoa năm 2","description_short_vi":"Các thầy cô không chạy theo tiến độ mà tập trung đi vào yếu tố: “chất lượng hơn số lượng”, “chất đề cao hơn lượng”, chính vì thế trong mỗi tiết học bản thân mình và các bạn học viên khác luôn cảm giác được thầy, cô luôn quan tâm, trau dồi kiến thức mọi lúc."},
    {"name_vi":"Nguyễn Hân","url_vi":"","class_item":"","image":"/media/img_3423.jpg","image_source":"cdn","description_vi":"Sinh viên Y khoa năm 1","description_short_vi":"Mình cũng biết rằng học Y đa số thời gian là tự học, nhưng nếu trong quá trình tự học đó mình có những người bạn đồng hành, thầy cô có thể trao đổi trực tiếp chẳng phải tốt hơn sao?"},
    {"name_vi":"Nguyễn Khánh Quỳnh","url_vi":"","class_item":"","image":"/media/img_3425.jpg","image_source":"cdn","description_vi":"Sinh viên Y khoa năm 2","description_short_vi":"Các Thầy Cô đều rất dễ thương và nhiệt tình chỉ dạy em, bài giảng thì được đầu tư kỹ lưỡng, giảng dạy lôi cuốn, tương tác liên tục với học viên nên không bị nhàm chán chút nào ạ."}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"CÂU CHUYỆN NGƯỜI HỌC",
    "tieu_de":"Góc chia sẻ của người học.",
    "ghi_chu":"Trích từ đánh giá học viên gửi trên trang Facebook của MedUC."
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - phan hoi hoc vien chu va anh | hvreview', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'hvreview');

UPDATE templates_column
SET block_code = 'herowal,gvrail,hvvideo,hvreview'
WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('xvy1d68', 'vd4sx71') AND block_code = 'herowal';

UPDATE templates_column
SET block_code = ''
WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('r9p1b2m', 'tifa3zg') AND block_code = 'bptjnf0';
