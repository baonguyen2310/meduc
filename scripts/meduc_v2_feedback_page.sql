-- Student feedback page (/phan-hoi-hoc-vien, page veb1pro), top to bottom:
--   fbhero   "Phản hồi học viên - Mở đầu"          view_feedback_hero.tpl       students are the core of MedUC
--   fbcare   "Phản hồi học viên - Chăm sóc"        view_student_care.tpl        how students are looked after
--   fbperks  "Phản hồi học viên - Quyền ưu đãi"    view_student_perks.tpl       student benefits (fee reduction, refunds, free materials)
--   fblove   "Phản hồi học viên - Lời kết"         view_feedback_statement.tpl  MedUC always cares for its students
--   fbvideos "Phản hồi học viên - Video"           view_video_grid.tpl          all 18 student videos, with subject filters
--   hvreview (the homepage's student reviews block, shared: editing it changes both pages)
-- Views are in templates/app01/block/slider/; styles and scripts in templates/app01/assets/meduc-v2/
-- (feedback-page.css, video-feedback.css/.js, video-grid.css/.js, reviews.css/.js).
-- Content stays editable in admin: Giao diện > Block. Items are the slider list; texts are "Dữ liệu mở rộng" (an empty value hides that line).
-- Sources: the care points and the closing sentence come from the About page block "Tại sao lựa chọn MedUC.vn?" (w4mxd67) and from
-- students' Facebook reviews (replayed lessons); the benefits summarise the fee reduction and refund policy pages;
-- the videos are the 18 of the old feedback block (291aktb), with subject labels and course links from the main branch
-- (two of the old block's course links pointed to course addresses that no longer exist).
--
-- Run once on the MedUC PHP database, then clear the website cache from the admin bar.
-- Safe to re-run: blocks are inserted only when missing, and only the original row and column values are changed.
-- To go back:
--   UPDATE templates_column SET block_code = '291aktb'
--   WHERE template_code = 'app01' AND page_code = 'veb1pro' AND row_code = 'm0cxgnz' AND block_code = 'fbhero,fbcare,fbperks,fblove,fbvideos,hvreview';
--   UPDATE templates_row SET config = NULL WHERE template_code = 'app01' AND page_code = 'veb1pro' AND code = 'm0cxgnz';

SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'fbhero', 'Phản hồi học viên - Mở đầu', 'slider', '', 'view_feedback_hero.tpl', '',
  '{"class":"","cache":"1","item":[]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"PHẢN HỒI HỌC VIÊN · MEDUC",
    "tieu_de_dong_1":"HỌC VIÊN LÀ",
    "tieu_de_dong_2":"CỐT LÕI CỦA MEDUC.",
    "mo_ta":"MedUC ra đời để không sinh viên Y nào phải một mình vượt qua khối kiến thức khổng lồ. Vì vậy mọi điều chúng tôi làm, từ chọn giảng viên, xây lộ trình đến chăm sóc từng buổi học, đều bắt đầu từ người học.",
    "nut_chinh":"Xem học viên nói gì",
    "link_nut_chinh":"#phan-hoi",
    "nut_phu":"Học thử miễn phí",
    "link_nut_phu":"/khoa-hoc",
    "anh":"/templates/app01/assets/meduc-v2/feedback/hoc-vien-meduc.jpg",
    "mo_ta_anh":"Học viên MedUC cùng xem tài liệu học tập",
    "so_noi_bat":"6.000+",
    "chu_noi_bat":"học viên đã học cùng MedUC"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'phan hoi hoc vien - mo dau | fbhero', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'fbhero');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'fbcare', 'Phản hồi học viên - Chăm sóc', 'slider', '', 'view_student_care.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Giải đáp nhanh – đúng – đủ","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Thắc mắc trong và sau buổi học đều được giảng viên, trợ giảng trả lời tận tình.","description_short_vi":""},
    {"name_vi":"Nhắc học và theo dõi tiến độ","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Trung tâm nhắc lịch học và theo dõi tiến độ, để không học viên nào bị bỏ lại phía sau.","description_short_vi":""},
    {"name_vi":"Rà soát và chữa bài 2 lần mỗi tháng","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Bài tập trắc nghiệm sau mỗi phần học được rà soát và chữa định kỳ, giúp củng cố kiến thức.","description_short_vi":""},
    {"name_vi":"Phát lại bài giảng, học bù","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Bận hay vắng buổi nào, học viên vẫn có thể xem lại bài giảng và học bù.","description_short_vi":""},
    {"name_vi":"Tài liệu bổ trợ mỗi mùa thi","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Tài liệu ôn tập đặc biệt đến với học viên trước mỗi kỳ thi.","description_short_vi":""},
    {"name_vi":"Quà tặng khích lệ","url_vi":"","class_item":"","image":"","image_source":"","description_vi":"Những phần quà nhỏ ghi nhận sự cố gắng của học viên trên hành trình học Y.","description_short_vi":""}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"Học viên được chăm sóc ra sao",
    "tieu_de_dong_1":"ĐỒNG HÀNH",
    "tieu_de_dong_2":"ĐẾN KHI BẠN TỐT.",
    "mo_ta":"MedUC không “dạy xong là xong”. Mỗi học viên đều có người theo sát từ buổi học đầu tiên đến mùa thi."
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'phan hoi hoc vien - cham soc | fbcare', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'fbcare');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'fbperks', 'Phản hồi học viên - Quyền ưu đãi', 'slider', '', 'view_student_perks.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Miễn giảm học phí","url_vi":"/chinh-sach-mien-giam-hoc-phi","class_item":"","image":"","image_source":"","description_vi":"Giảm 75% học phí cho học viên thuộc hộ nghèo và 50% cho hộ cận nghèo có giấy xác nhận. Thông tin hoàn cảnh được giữ kín.","description_short_vi":"75%"},
    {"name_vi":"Hoàn học phí","url_vi":"/chinh-sach-hoan-tra-hoc-phi","class_item":"","image":"","image_source":"","description_vi":"Hoàn 100% học phí nếu lớp chưa khai giảng; hoàn 80% nếu thấy chưa phù hợp trong 7 ngày đầu với khoá trực tuyến, 3 ngày đầu với khoá video.","description_short_vi":"100%"},
    {"name_vi":"Sách và tài liệu miễn phí","url_vi":"/tai-lieu-hoc-tap","class_item":"","image":"","image_source":"","description_vi":"Kho sách và tài liệu Y khoa miễn phí để học viên ôn tập thêm ngoài giờ học.","description_short_vi":"0đ"}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"Quyền ưu đãi của học viên",
    "tieu_de_dong_1":"QUYỀN LỢI",
    "tieu_de_dong_2":"RÕ RÀNG, MINH BẠCH.",
    "mo_ta":"Những chính sách giúp học viên yên tâm bắt đầu và theo học đến cùng.",
    "nut_chinh_sach":"Xem chi tiết",
    "ghi_chu":"Điều kiện áp dụng cụ thể xem trong từng chính sách của MedUC."
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'phan hoi hoc vien - quyen uu dai | fbperks', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'fbperks');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'fblove', 'Phản hồi học viên - Lời kết', 'slider', '', 'view_feedback_statement.tpl', '',
  '{"class":"","cache":"1","item":[]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"Trung tâm luôn ở bên học viên",
    "cau_chinh":"Học viên tiến bộ là mục tiêu cuối cùng của MedUC.",
    "mo_ta":"MedUC bắt đầu từ một người chị khóa trên đã kiên nhẫn kèm người sáng lập qua những năm học Y khó khăn. Chúng tôi giữ tinh thần ấy với từng học viên: yêu quý, lắng nghe và chăm sóc như người nhà.",
    "ky_ten":"— ĐỘI NGŨ MEDUC",
    "nut":"Xem học viên nói gì",
    "link_nut":"#phan-hoi",
    "anh_nen":"/templates/app01/assets/meduc-v2/feedback/lop-lam-sang.jpg"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'phan hoi hoc vien - loi ket | fblove', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'fblove');

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'fbvideos', 'Phản hồi học viên - Video', 'slider', '', 'view_video_grid.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Phản hồi khóa học Giải phẫu, Tiếng Anh Y khoa","url_vi":"https://www.youtube.com/watch?v=g9wXdFv1mTw","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu · Tiếng Anh Y khoa","description_short_vi":"/giai-phau-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=mvoFlFPB-rE","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":"/sinh-ly-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Giải phẫu","url_vi":"https://www.youtube.com/watch?v=YfhMZ9LwkZo","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu","description_short_vi":"/giai-phau-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=sJDkfvW7oxk","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":"/sinh-ly-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Tiếng Anh Y khoa","url_vi":"https://www.youtube.com/watch?v=OlefssQgsXY","class_item":"","image":"","image_source":"","description_vi":"Tiếng Anh Y khoa","description_short_vi":"/tieng-anh-y-khoa-12-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=bn_BJlYt9jI","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":"/sinh-ly-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Tiếng Anh Y khoa","url_vi":"https://www.youtube.com/watch?v=0tuRJk4A0XI","class_item":"","image":"","image_source":"","description_vi":"Tiếng Anh Y khoa","description_short_vi":"/tieng-anh-y-khoa-12-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Giải phẫu","url_vi":"https://www.youtube.com/watch?v=pgTpfhb8lbI","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu","description_short_vi":"/giai-phau-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa Tiếng Anh Y khoa Sau đại học","url_vi":"https://www.youtube.com/watch?v=m2ZYIqQbJz8","class_item":"","image":"","image_source":"","description_vi":"Tiếng Anh Y khoa · Sau đại học","description_short_vi":"/tieng-anh-y-khoa-12-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Giải phẫu Sau đại học","url_vi":"https://www.youtube.com/watch?v=Oo3DJw_guIU","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu · Sau đại học","description_short_vi":"/giai-phau-noi-tru-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Sinh lý Sau đại học","url_vi":"https://www.youtube.com/watch?v=jgPymEG6A00","class_item":"","image":"","image_source":"","description_vi":"Sinh lý · Sau đại học","description_short_vi":"/sinh-ly-noi-tru-co-ban-chuyen"},
    {"name_vi":"Phản hồi khóa học Tiếng Anh Y khoa","url_vi":"https://www.youtube.com/watch?v=J2yiarvLxj4","class_item":"","image":"","image_source":"","description_vi":"Tiếng Anh Y khoa","description_short_vi":"/tieng-anh-y-khoa-12-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=ysWvZ6Zz6p8","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":"/sinh-ly-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Sinh lý","url_vi":"https://www.youtube.com/watch?v=zcd3Mj-VsNU","class_item":"","image":"","image_source":"","description_vi":"Sinh lý","description_short_vi":"/sinh-ly-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Giải phẫu","url_vi":"https://www.youtube.com/watch?v=9vy0PhvunS4","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu","description_short_vi":"/giai-phau-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Giải phẫu","url_vi":"https://www.youtube.com/watch?v=-XMriPiTsw8","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu","description_short_vi":"/giai-phau-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa học Giải phẫu","url_vi":"https://www.youtube.com/watch?v=QwZk07ZP8sw","class_item":"","image":"","image_source":"","description_vi":"Giải phẫu","description_short_vi":"/giai-phau-1-2-co-ban-chuyen-sau"},
    {"name_vi":"Phản hồi khóa ôn thi Nội trú Sau đại học","url_vi":"https://www.youtube.com/watch?v=UNl0xfqVFPo","class_item":"","image":"","image_source":"","description_vi":"Ôn thi Nội trú","description_short_vi":"/khoa-hoc-noi-tru-sau-dai-hoc"}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_phu":"VIDEO TỪ HỌC VIÊN MEDUC",
    "tieu_de_dong_1":"LẮNG NGHE TỪNG",
    "tieu_de_dong_2":"TRẢI NGHIỆM THẬT.",
    "mo_ta":"Video phản hồi do MedUC đăng tải. Chọn môn học để xem những chia sẻ liên quan.",
    "nut_xem_them":"Xem thêm video",
    "so_video_moi_lan":"6"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'phan hoi hoc vien - video | fbvideos', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'fbvideos');

-- The row had no settings, so its blocks sat inside a narrow container; the new sections span the full width.
UPDATE templates_row
SET config = '{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code = 'app01' AND page_code = 'veb1pro' AND code = 'm0cxgnz' AND config IS NULL;

UPDATE templates_column
SET block_code = 'fbhero,fbcare,fbperks,fblove,fbvideos,hvreview'
WHERE template_code = 'app01' AND page_code = 'veb1pro' AND row_code = 'm0cxgnz' AND block_code = '291aktb';
