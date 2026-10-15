-- Homepage, second part. After this script the homepage is, top to bottom:
--   hero (herowal), faculty (gvrail), teaching method (hvmethod), student videos (hvvideo), student reviews (hvreview),
--   learning path (hvpath), community figures (hvstats), free consultation form (hvconsult), then the site footer.
-- New blocks and their views (templates/app01/block/slider/):
--   hvmethod  "Trang chủ - Phương pháp Core Learning"  view_method_feature.tpl
--   hvpath    "Trang chủ - Lộ trình học"              view_learning_path.tpl
--   hvstats   "Trang chủ - Cùng nhau học Y tốt hơn"   view_impact_stats.tpl  (starts as a copy of "[Trang chủ] 4 chỉ số", mxvdb03)
--   hvconsult "Trang chủ - Đăng ký tư vấn miễn phí"   view_consult_form.tpl  (the same contact form 3HZO5VFWIK as block gkefh9w)
-- Content stays editable in admin: Giao diện > Block. Items are the slider list; texts are "Dữ liệu mở rộng" (an empty value hides that line).
-- The Core Learning picture (templates/app01/assets/meduc-v2/method/study-editorial.jpg) is an AI illustration; replace it
-- with a MedUC photo or add a YouTube link under the "video" key.
--
-- Run once on the MedUC PHP database after meduc_v2_home_sections.sql, then clear the website cache from the admin bar.
-- Safe to re-run: blocks are inserted only when missing, and only the original column values are changed.
-- The new blocks join the hero's column, because the CMS orders rows by id and cannot insert a row between two others.
-- These old homepage sections are taken off (their blocks are kept): Block giới thiệu (27vczr0), Các khóa học tiêu biểu (itgqfxh),
-- 6 cuốn sách tiêu biểu (b6q45ok), Thông Tin Liên Hệ (3p9qz6e), Learning system (dqays82), 4 chỉ số (mxvdb03),
-- Danh sách bài viết (wlmp69b) and the old consultation form (gkefh9w). Their emptied rows are hidden by hero.css.
-- To go back:
--   UPDATE templates_column SET block_code = 'herowal,gvrail,hvvideo,hvreview'
--   WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('xvy1d68', 'vd4sx71')
--     AND block_code = 'herowal,gvrail,hvmethod,hvvideo,hvreview,hvpath,hvstats,hvconsult';
--   Then, for each pair below: UPDATE templates_column SET block_code = '<block>'
--   WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('<desktop row>', '<phone row>') AND block_code = '';
--     27vczr0: u9as36w, r5dwkqz    itgqfxh: 40oblf9, o30vhnd    b6q45ok: yt8uwo2, tqvgpo7    3p9qz6e: 8mkec9z, 0zcf139
--     dqays82: gdj39ru, gdbj70r    mxvdb03: p4tomue, vi2osju    wlmp69b: 96fze8n, o1la8c5    gkefh9w: 7qg1x8j, 9ir45ag

SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'hvmethod', 'Trang chủ - Phương pháp Core Learning', 'slider', '', 'view_method_feature.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Mind Map","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Hệ thống kiến thức bằng từ khóa trọng tâm và hình ảnh trực quan, giúp hiểu sâu – nhớ lâu thay cho lối học thuộc lòng.","description_short_vi":""},
    {"name_vi":"Bài tập tự chấm và chữa chi tiết","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Theo dõi tiến độ, củng cố kiến thức và tối ưu thời gian ôn tập sau mỗi phần học.","description_short_vi":""},
    {"name_vi":"Thạc sĩ, Bác sĩ nội trú đồng hành","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Giảng viên từ những trường Y hàng đầu, giàu kinh nghiệm giảng dạy và tận tâm giải đáp từng thắc mắc.","description_short_vi":""}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "nhan":"Phương pháp MedUC",
    "tieu_de":"Core Learning",
    "tieu_de_phu":"Hiểu sâu · Nhớ lâu",
    "mo_ta":"Học từ cốt lõi: từ khóa trọng tâm, sơ đồ tư duy và case lâm sàng, thay cho lối học thuộc lòng.",
    "anh":"/templates/app01/assets/meduc-v2/method/study-editorial.jpg",
    "video":"",
    "nut_video":"Xem video",
    "nut":"Tìm hiểu khoá học",
    "link_nut":"/khoa-hoc"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - phuong phap core learning | hvmethod', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'hvmethod');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'hvpath', 'Trang chủ - Lộ trình học', 'slider', '', 'view_learning_path.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Y học cơ sở","url_vi":"/khoa-hoc-sinh-vien-nam-1-nam-2","class_item":"","image":"/media/z6416951893460_a37178b7143a5daada4c529c48d1f6db.jpg","image_source":"cdn","description_vi":"Giải phẫu, Sinh lý, Hoá sinh, Mô phôi… học chắc từ khái niệm cốt lõi, làm nền vững cho các năm lâm sàng.","description_short_vi":"Năm 1 – Năm 2"},
    {"name_vi":"Lâm sàng","url_vi":"/khoa-hoc-sinh-vien-nam-3-nam-4","class_item":"","image":"/media/Cover%20web%20(14).png","image_source":"cdn","description_vi":"Nội, Ngoại, Sản, Nhi qua từng case lâm sàng, để tự tin khi đi bệnh viện và khi thi hết môn.","description_short_vi":"Năm 3 – Năm 4"},
    {"name_vi":"Nội trú – Sau đại học","url_vi":"/khoa-hoc-noi-tru-sau-dai-hoc","class_item":"","image":"/media/Cover%20web%20(16).png","image_source":"cdn","description_vi":"Ôn thi chuyên sâu cùng Thạc sĩ, Bác sĩ nội trú, bám sát cấu trúc đề thi Nội trú và Sau đại học.","description_short_vi":"Sau tốt nghiệp"},
    {"name_vi":"Luyện đề","url_vi":"/danh-sach-de-thi","class_item":"","image":"","image_source":"","description_vi":"Đề trắc nghiệm có đáp án, chấm và chữa chi tiết, để biết mình cần ôn lại phần nào.","description_short_vi":"Mọi giai đoạn"}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"LỘ TRÌNH HỌC",
    "tieu_de_dong_1":"TỪ CƠ BẢN",
    "tieu_de_dong_2":"ĐẾN CHUYÊN SÂU.",
    "mo_ta":"Mỗi môn đi từ nền tảng đến chuyên sâu, theo đúng giai đoạn bạn đang học.",
    "nut_xem_tat_ca":"Xem tất cả khoá học",
    "link_xem_tat_ca":"/khoa-hoc",
    "nut_chang":"Xem khoá học"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - lo trinh hoc | hvpath', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'hvpath');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'hvstats', 'Trang chủ - Cùng nhau học Y tốt hơn', 'slider', '', 'view_impact_stats.tpl', '',
  src.config,
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"MEDUC / CỘNG ĐỒNG HỌC Y",
    "tieu_de_dong_1":"Cùng nhau học Y",
    "tieu_de_dong_2":"tốt hơn.",
    "mo_ta":"Những dấu mốc trên hành trình học tập cùng MedUC."
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - cung nhau hoc y tot hon | hvstats', 0
FROM templates_block src
WHERE src.template_code = 'app01' AND src.code = 'mxvdb03'
  AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'hvstats');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'hvconsult', 'Trang chủ - Đăng ký tư vấn miễn phí', 'slider', '', 'view_consult_form.tpl', '',
  '{"class":"","cache":"1","item":[]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"MEDUC / TƯ VẤN HỌC TẬP",
    "tieu_de":"Đăng ký nhận tư vấn miễn phí",
    "mo_ta":"Hơn 1000 học viên đã trải nghiệm và học tốt y khoa cùng MedUC. Và giờ, đến lượt bạn.",
    "gioi_thieu_form":"Để lại thông tin, MedUC sẽ liên hệ tư vấn lộ trình học phù hợp với bạn.",
    "nut_gui":"Nhận tư vấn miễn phí"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang chu - dang ky tu van mien phi | hvconsult', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'hvconsult');

UPDATE templates_column
SET block_code = 'herowal,gvrail,hvmethod,hvvideo,hvreview,hvpath,hvstats,hvconsult'
WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('xvy1d68', 'vd4sx71')
  AND block_code = 'herowal,gvrail,hvvideo,hvreview';

UPDATE templates_column
SET block_code = ''
WHERE template_code = 'app01' AND page_code = 'lhw3opn'
  AND row_code IN ('u9as36w', 'r5dwkqz', '40oblf9', 'o30vhnd', 'yt8uwo2', 'tqvgpo7', '8mkec9z', '0zcf139',
                   'gdj39ru', 'gdbj70r', 'p4tomue', 'vi2osju', '96fze8n', 'o1la8c5', '7qg1x8j', '9ir45ag')
  AND block_code IN ('27vczr0', 'itgqfxh', 'b6q45ok', '3p9qz6e', 'dqays82', 'mxvdb03', 'wlmp69b', 'gkefh9w');
