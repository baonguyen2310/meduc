-- Standalone /lo-trinh-hoc page. Reuses the existing homepage's stage data.
-- Safe to rerun: existing content and administrator edits are preserved.
-- Rollback: remove only pathpage's column, row, content, page and block records.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO templates_block
(template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','pathpage','Trang lộ trình học','slider','','view_learning_roadmap.tpl','',
 JSON_SET(src.config,'$.cache','0'),NULL,
 JSON_OBJECT('locale',JSON_OBJECT('vi',JSON_OBJECT(
  'tieu_de_1','TỪ CƠ BẢN.',
  'tieu_de_2','ĐẾN CHUYÊN SÂU.',
  'mo_ta','Mỗi giai đoạn học Y có một trọng tâm. Chọn điểm bắt đầu phù hợp, xây chắc kiến thức nền rồi kết nối với lâm sàng và luyện tập.'
 )), 'normal',JSON_OBJECT()),
 UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'trang lo trinh hoc | pathpage',0
FROM templates_block src
WHERE src.template_code='app01' AND src.code='hvpath' AND src.deleted=0
AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='pathpage');

INSERT INTO templates_page (template_code,layout_code,code,name,page_type,type,category_id,created,updated)
SELECT 'app01',src.layout_code,'pathpage','Lộ trình học','page','normal',NULL,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM templates_page src
WHERE src.template_code='app01' AND src.code='methodpage'
AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='pathpage')
AND NOT EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='pathpage');

INSERT INTO templates_page_content (template_code,page_code,url,lang,seo_title,seo_description,seo_keyword)
SELECT 'app01','pathpage','lo-trinh-hoc','vi','Lộ trình học từ cơ bản đến chuyên sâu | MedUC',
 'Chọn chặng học phù hợp tại MedUC: Y học cơ sở, lâm sàng, nội trú và sau đại học, kết hợp luyện đề để củng cố kiến thức.',
 'lộ trình học Y, MedUC, Y học cơ sở, lâm sàng, luyện thi'
FROM DUAL
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='pathpage')
AND NOT EXISTS (SELECT 1 FROM templates_page_content WHERE template_code='app01' AND ((page_code='pathpage' AND lang='vi') OR url='lo-trinh-hoc'));

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','pathpage',IF(d.device=1,'pathbodym','pathbody'),'content','{"id_row":"","style_class":"","full_screen":1}',d.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) d
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='pathpage')
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='pathpage' AND device=d.device AND code=IF(d.device=1,'pathbodym','pathbody'));

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','pathpage',IF(d.device=1,'pathbodym','pathbody'),12,'pathpage',d.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) d
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='pathpage' AND device=d.device)
AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='pathpage' AND device=d.device AND row_code=IF(d.device=1,'pathbodym','pathbody'));
COMMIT;
