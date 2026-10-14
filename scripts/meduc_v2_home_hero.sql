-- Homepage hero: a wall of scrolling portraits behind the headline (block "herowal").
-- Code: templates/app01/block/slider/view_hero_wall.tpl and templates/app01/assets/meduc-v2/hero.css.
-- Content stays editable in admin: Giao diện > Block > "Hero trang chủ - bức tường giảng viên".
--   Images: the slider image list. Text: "Dữ liệu mở rộng" (an empty value hides that line).
-- The images below are demo images (templates/app01/assets/meduc-v2/hero/SOURCES.md); replace them with MedUC faculty photos.
--
-- Run once on the MedUC PHP database, then clear the website cache from the admin bar.
-- Safe to re-run: the block is inserted only when missing, and only the old slider column is swapped.
-- The old slider block ka5nc6p is kept. To go back to it:
--   UPDATE templates_column SET block_code = 'ka5nc6p'
--   WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('xvy1d68', 'vd4sx71') AND block_code = 'herowal';

SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
   created, created_by, updated, status, search_unicode, deleted)
SELECT
  'app01', 'herowal', 'Hero trang chủ - bức tường giảng viên', 'slider', '', 'view_hero_wall.tpl', '',
  '{"class":"","cache":"1","item":[
    {"name_vi":"Ảnh demo 1","url_vi":"","class_item":"","image":"/templates/app01/assets/meduc-v2/hero/doctor-linh.jpg","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 2","url_vi":"","class_item":"","image":"https://images.unsplash.com/photo-1712215544003-af10130f8eb3?w=400&h=580&fit=crop&crop=faces&q=75&auto=format","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 3","url_vi":"","class_item":"","image":"/templates/app01/assets/meduc-v2/hero/meduc-doctor-04.jpg","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 4","url_vi":"","class_item":"","image":"https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&h=580&fit=crop&crop=faces&q=75&auto=format","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 5","url_vi":"","class_item":"","image":"/templates/app01/assets/meduc-v2/hero/professor.jpg","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 6","url_vi":"","class_item":"","image":"https://images.unsplash.com/photo-1706565029539-d09af5896340?w=400&h=580&fit=crop&crop=faces&q=75&auto=format","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 7","url_vi":"","class_item":"","image":"/templates/app01/assets/meduc-v2/hero/doctor-minh.jpg","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 8","url_vi":"","class_item":"","image":"https://images.unsplash.com/photo-1678695972687-033fa0bdbac9?w=400&h=580&fit=crop&crop=faces&q=75&auto=format","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 9","url_vi":"","class_item":"","image":"/templates/app01/assets/meduc-v2/hero/meduc-doctor-02.jpg","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 10","url_vi":"","class_item":"","image":"https://images.unsplash.com/photo-1757125736482-328a3cdd9743?w=400&h=580&fit=crop&crop=faces&q=75&auto=format","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 11","url_vi":"","class_item":"","image":"/templates/app01/assets/meduc-v2/hero/meduc-doctor-01.jpg","image_source":"template","description_vi":"","description_short_vi":""},
    {"name_vi":"Ảnh demo 12","url_vi":"","class_item":"","image":"https://images.unsplash.com/photo-1736289173074-df6009da27c9?w=400&h=580&fit=crop&crop=faces&q=75&auto=format","image_source":"template","description_vi":"","description_short_vi":""}
  ]}',
  NULL,
  '{"locale":{"vi":{
    "tieu_de_dong_1":"HỌC TỪ NGƯỜI GIỎI",
    "tieu_de_dong_2":"VỮNG BƯỚC NGHỀ Y",
    "mo_ta":"Học Y bứt phá cùng đội ngũ Thạc sĩ, Bác sĩ nội trú.",
    "dong_phu":"Hơn 5.000 câu hỏi luyện tập có đáp án.",
    "nut_chinh":"Khám phá khóa học",
    "link_nut_chinh":"/khoa-hoc",
    "nut_phu":"Tìm hiểu về MedUC",
    "link_nut_phu":"/gioi-thieu",
    "cam_ket":"Cam kết hoàn lại 100% học phí"
  }},"normal":{}}',
  UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'hero trang chu - buc tuong giang vien | herowal', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code = 'app01' AND code = 'herowal');

UPDATE templates_column
SET block_code = 'herowal'
WHERE template_code = 'app01' AND page_code = 'lhw3opn' AND row_code IN ('xvy1d68', 'vd4sx71') AND block_code = 'ka5nc6p';
