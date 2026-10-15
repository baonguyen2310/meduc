-- Redesigned /gioi-thieu: a dedicated story page, separate from /doi-ngu-giang-vien.
-- Run once, then clear the website cache. Safe to re-run; existing aboutv2 content is not overwritten.
-- Original content: qkb4xzd (full founder story + real portrait), 2nlzqpi (vision/mission),
-- and the six values transcribed from its original anh_gia_tri_cot_loi image.
-- Editing: Admin > Giao diện > Block > "Trang giới thiệu - Câu chuyện MedUC".
-- Story: slider description. Portrait, other copy: Dữ liệu mở rộng.
-- Old blocks are retained, and only their known About-page columns are detached.
-- To roll back, blank aboutbody/aboutbodym columns and restore the original blocks on
-- njv1rpw=8rj4zou, ad1ie29=qkb4xzd, 2bahulj=2nlzqpi, 7io3rx1=w4mxd67,
-- 8lvo0p7=3p9qz6e, g1os03y=bptjnf0. Faculty now has its own page.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO templates_block
    (template_code, code, name, type, action, view, element_view, config, data_extend, normal_data_extend,
     created, created_by, updated, status, search_unicode, deleted)
SELECT 'app01', 'aboutv2', 'Trang giới thiệu - Câu chuyện MedUC', 'slider', '', 'view_about_story.tpl', '',
    origin.config, NULL,
    JSON_OBJECT('locale', JSON_OBJECT('vi', JSON_OBJECT(
        'hero_tieu_de_1', 'HỌC Y CÓ',
        'hero_tieu_de_2', 'NGƯỜI ĐỒNG HÀNH.',
        'hero_mo_ta', 'MedUC ra đời từ sự thấu hiểu những khó khăn của người học Y. Bởi chính người sáng lập cũng từng chật vật, mất gốc và có lúc muốn dừng lại.',
        'nguoi_sang_lap', 'BS Ngô Nghĩa Đức',
        'anh_nguoi_sang_lap', JSON_UNQUOTE(JSON_EXTRACT(origin.normal_data_extend, '$.locale.vi.hinh_anh')),
        'cau_hoi_khoi_nguon', 'Nếu không có sự hỗ trợ từ chị ấy, mình sẽ ra sao? Và những sinh viên khác trong hoàn cảnh tương tự sẽ tìm kiếm sự hỗ trợ ở đâu?',
        'ten_goi_med', 'Chuyên sâu lĩnh vực Y khoa.',
        'ten_goi_u', 'Cung cấp chất lượng cao cấp nhất.',
        'ten_goi_c', 'Trung tâm đào tạo toàn diện.',
        'tam_nhin_tieu_de', 'Một nơi học Y đáng tin cậy.',
        'tam_nhin', JSON_UNQUOTE(JSON_EXTRACT(vision.normal_data_extend, '$.locale.vi.text_2')),
        'su_menh_tieu_de', 'Trao kiến thức. Chia sẻ kinh nghiệm.',
        'su_menh', JSON_UNQUOTE(JSON_EXTRACT(vision.normal_data_extend, '$.locale.vi.text_4')),
        'gia_tri_1', 'Lấy học viên làm trung tâm',
        'gia_tri_2', 'Chất lượng và dịch vụ tạo nên khác biệt',
        'gia_tri_3', 'Cam kết và trách nhiệm',
        'gia_tri_4', 'Đầu tư vào giảng viên và phương pháp dạy học',
        'gia_tri_5', 'Không ngừng học hỏi và phát triển',
        'gia_tri_6', 'Kỷ luật tạo nên động lực',
        'tuong_lai_mo_ta', 'Lấy người học làm trung tâm, tiếp tục đầu tư vào đội ngũ giảng viên và phương pháp dạy học là định hướng phát triển của MedUC.',
        'tuong_lai_1_tieu_de', 'Đầu tư vào người dạy',
        'tuong_lai_1', 'Tiếp tục đầu tư vào giảng viên, chuyên môn và kinh nghiệm giảng dạy.',
        'tuong_lai_2_tieu_de', 'Hoàn thiện cách học',
        'tuong_lai_2', 'Phát triển phương pháp dạy học, hệ thống kiến thức từ nền tảng đến chuyên sâu.',
        'tuong_lai_3_tieu_de', 'Đồng hành cùng người học',
        'tuong_lai_3', 'Lắng nghe khó khăn của học viên, nâng cao chất lượng và dịch vụ hỗ trợ học tập.'
    )), 'normal', JSON_OBJECT()),
    UNIX_TIMESTAMP(), NULL, UNIX_TIMESTAMP(), 1, 'trang gioi thieu - cau chuyen meduc | aboutv2', 0
FROM templates_block origin
JOIN templates_block vision ON vision.template_code=origin.template_code AND vision.code='2nlzqpi' AND vision.deleted=0
WHERE origin.template_code='app01' AND origin.code='qkb4xzd' AND origin.deleted=0
    AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='aboutv2');

INSERT INTO templates_row (template_code, page_code, code, type, config, device)
SELECT 'app01', 'cidahpl', IF(devices.device=1, 'aboutbodym', 'aboutbody'), 'content', '{"id_row":"","style_class":"","full_screen":1}', devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='cidahpl')
    AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='aboutv2')
    AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='cidahpl' AND code=IF(devices.device=1, 'aboutbodym', 'aboutbody') AND device=devices.device);

INSERT INTO templates_column (template_code, page_code, row_code, column_value, block_code, device)
SELECT 'app01', 'cidahpl', IF(devices.device=1, 'aboutbodym', 'aboutbody'), 12, 'aboutv2', devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='cidahpl' AND code=IF(devices.device=1, 'aboutbodym', 'aboutbody') AND device=devices.device)
    AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='cidahpl' AND row_code=IF(devices.device=1, 'aboutbodym', 'aboutbody') AND device=devices.device);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='cidahpl'
    AND block_code IN ('8rj4zou','l06kedm','qkb4xzd','2nlzqpi','w4mxd67','3p9qz6e','bptjnf0')
    AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='aboutv2');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code='app01' AND page_code='cidahpl'
    AND code IN ('njv1rpw','be6zyog','ad1ie29','2bahulj','7io3rx1','8lvo0p7','g1os03y')
    AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='aboutv2');

UPDATE templates_page_content
SET seo_title='Câu chuyện MedUC · Tầm nhìn & sứ mệnh | MedUC',
    seo_description='Câu chuyện hình thành MedUC từ trải nghiệm học Y của người sáng lập. Tìm hiểu ý nghĩa tên gọi, tầm nhìn, sứ mệnh và sáu giá trị cốt lõi của MedUC.'
WHERE template_code='app01' AND page_code='cidahpl' AND lang='vi'
    AND (seo_title='Giới thiệu' OR seo_title='' OR seo_title IS NULL)
    AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='aboutv2');
COMMIT;
