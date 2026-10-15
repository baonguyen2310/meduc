-- Dedicated faculty page: /doi-ngu-giang-vien (desktop + mobile), using the current site's layout.
-- Run after meduc_v2_home_sections.sql, then clear the website cache.
-- The new slider block gvteam starts from the homepage's gvrail items; edit its profiles independently in admin.
--   Description: qualifications / experience, one line per item.
--   Faculty documents: "Document title | /media/image.jpg" or a full HTTPS image/PDF URL, one per line.
--   No degree images are seeded: publish the real files when available.
-- Safe to re-run: no existing profiles or edited page text are overwritten.
-- Undo: restore l06kedm in the About page's be6zyog column and its original row config
-- ({"id_row":"","style_class":"pt-45 mt-45 mb-45","full_screen":""}); point gvrail's link_xem_tat_ca back to /gioi-thieu.
-- The old block is kept. The new page can be removed from CMS without deleting its profile data.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO templates_block
    (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
     created, created_by, updated, status, search_unicode, deleted)
SELECT 'app01', 'gvteam', 'Trang đội ngũ - Hồ sơ giảng viên và cố vấn', 'slider', '', 'view_faculty_directory.tpl', '',
    src.config, NULL,
    '{"locale":{"vi":{
        "mo_dau_nhan":"ĐỘI NGŨ GIẢNG VIÊN MEDUC",
        "mo_dau_tieu_de_1":"NGƯỜI DẠY VỮNG VÀNG.",
        "mo_dau_tieu_de_2":"NGƯỜI HỌC VỮNG TIN.",
        "mo_dau_mo_ta":"Một người thầy giỏi giúp bạn hiểu bản chất, kết nối kiến thức và tự tin hơn trên hành trình học Y.",
        "tuyen_chon_nhan":"TIÊU CHUẨN TUYỂN CHỌN",
        "tuyen_chon_tieu_de":"Chọn người dạy. Chọn chất lượng.",
        "tuyen_chon_mo_ta":"MedUC không tuyển sinh viên hoặc bác sĩ vừa tốt nghiệp làm giảng viên. Chúng tôi lựa chọn những người có nền tảng chuyên môn, kinh nghiệm và khả năng truyền đạt phù hợp với người học.",
        "tieu_de_phu":"CON NGƯỜI MEDUC",
        "tieu_de":"Đội Ngũ Giảng Viên Và Cố Vấn"
    }},"normal":{}}',
    UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang doi ngu - ho so giang vien va co van | gvteam', 0
FROM templates_block src
WHERE src.template_code='app01' AND src.code='gvrail' AND src.deleted=0
    AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='gvteam');

INSERT INTO templates_page (template_code, layout_code, code, name, page_type, type, category_id, created, updated)
SELECT 'app01', src.layout_code, 'faculty', 'Đội ngũ giảng viên', 'page', 'normal', NULL, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()
FROM templates_page src
WHERE src.template_code='app01' AND src.code='cidahpl'
    AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='gvteam')
    AND NOT EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='faculty');

INSERT INTO templates_page_content (template_code, page_code, url, lang, seo_title, seo_description, seo_keyword)
SELECT 'app01', 'faculty', 'doi-ngu-giang-vien', 'vi', 'Đội ngũ giảng viên và cố vấn | MedUC',
    'Gặp gỡ đội ngũ giảng viên và cố vấn MedUC. Tìm hiểu tiêu chuẩn tuyển chọn, chuyên môn, kinh nghiệm và hồ sơ bằng cấp của từng giảng viên.', 'giảng viên MedUC, đội ngũ, bằng cấp'
FROM DUAL
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='faculty')
    AND NOT EXISTS (SELECT 1 FROM templates_page_content WHERE template_code='app01' AND (page_code='faculty' AND lang='vi' OR url='doi-ngu-giang-vien'));

INSERT INTO templates_row (template_code, page_code, code, type, config, device)
SELECT 'app01', 'faculty', IF(devices.device=1, 'facultyrowm', 'facultyrow'), 'content', '{"id_row":"","style_class":"","full_screen":1}', devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='faculty')
    AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='faculty' AND code=IF(devices.device=1, 'facultyrowm', 'facultyrow') AND device=devices.device);

INSERT INTO templates_column (template_code, page_code, row_code, column_value, block_code, device)
SELECT 'app01', 'faculty', IF(devices.device=1, 'facultyrowm', 'facultyrow'), 12, 'gvteam', devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='faculty')
    AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='faculty' AND row_code=IF(devices.device=1, 'facultyrowm', 'facultyrow') AND device=devices.device);

UPDATE templates_block
SET normal_data_extend=JSON_SET(normal_data_extend, '$.locale.vi.link_xem_tat_ca', '/doi-ngu-giang-vien')
WHERE template_code='app01' AND code='gvrail' AND JSON_UNQUOTE(JSON_EXTRACT(normal_data_extend, '$.locale.vi.link_xem_tat_ca'))='/gioi-thieu';

-- The About page now tells the MedUC story; its former team list lives on the new page.
UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='cidahpl' AND block_code='l06kedm';
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":""}'
WHERE template_code='app01' AND page_code='cidahpl' AND code='be6zyog'
    AND JSON_UNQUOTE(JSON_EXTRACT(config, '$.style_class'))='pt-45 mt-45 mb-45';

COMMIT;
