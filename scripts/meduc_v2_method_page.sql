-- Dedicated /phuong-phap-hoc page, sharing the About page's layout and the site's header/footer.
-- Based on the existing homepage Core Learning content. Safe to re-run: existing page copy is preserved.
-- Hero copy/image: Admin > Giao diện > Block > Trang phương pháp học - Core Learning.
-- Rollback: remove methodpage's page/row/column/block records and restore hvmethod from the deployment backup.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO templates_block
 (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','methodpage','Trang phương pháp học - Core Learning','html','','methodpage.tpl','',
 '{"class":"","cache":"0"}',NULL,
 JSON_OBJECT('locale',JSON_OBJECT('vi',JSON_OBJECT(
   'tieu_de_1','HỌC TỪ CỐT LÕI.',
   'tieu_de_2','HIỂU ĐỂ ĐI XA.',
   'mo_ta','Học Y có rất nhiều điều cần nhớ. MedUC chọn bắt đầu từ điều cần hiểu: bản chất của vấn đề, mối liên hệ giữa các kiến thức và cách vận dụng vào từng câu hỏi, từng tình huống.',
   'anh',COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(src.normal_data_extend,'$.locale.vi.anh')),''),'/templates/app01/assets/meduc-v2/method/study-editorial.jpg')
 )), 'normal',JSON_OBJECT()),
 UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'trang phuong phap hoc - core learning | methodpage',0
FROM templates_block src
WHERE src.template_code='app01' AND src.code='hvmethod' AND src.deleted=0
AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='methodpage');

INSERT INTO templates_page (template_code,layout_code,code,name,page_type,type,category_id,created,updated)
SELECT 'app01',src.layout_code,'methodpage','Phương pháp học','page','normal',NULL,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM templates_page src
WHERE src.template_code='app01' AND src.code='cidahpl'
AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='methodpage')
AND NOT EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='methodpage');

INSERT INTO templates_page_content (template_code,page_code,url,lang,seo_title,seo_description,seo_keyword)
SELECT 'app01','methodpage','phuong-phap-hoc','vi','Phương pháp học Core Learning | MedUC',
 'Tìm hiểu cách học tại MedUC: hiểu kiến thức cốt lõi, hệ thống hóa bằng Mind Map, vận dụng qua tình huống lâm sàng và củng cố với bài tập có lời giải.',
 'phương pháp học MedUC, Core Learning, Mind Map, học Y'
FROM DUAL
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='methodpage')
AND NOT EXISTS (SELECT 1 FROM templates_page_content WHERE template_code='app01' AND (page_code='methodpage' AND lang='vi' OR url='phuong-phap-hoc'));

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','methodpage',IF(d.device=1,'methodbodym','methodbody'),'content','{"id_row":"","style_class":"","full_screen":1}',d.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) d
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='methodpage')
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='methodpage' AND device=d.device AND code=IF(d.device=1,'methodbodym','methodbody'));

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','methodpage',IF(d.device=1,'methodbodym','methodbody'),12,'methodpage',d.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) d
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='methodpage' AND device=d.device)
AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='methodpage' AND device=d.device AND row_code=IF(d.device=1,'methodbodym','methodbody'));

UPDATE templates_block
SET normal_data_extend=JSON_SET(normal_data_extend,'$.locale.vi.link_nut','/phuong-phap-hoc','$.locale.vi.nut','Tìm hiểu phương pháp học'),updated=UNIX_TIMESTAMP()
WHERE template_code='app01' AND code='hvmethod'
AND JSON_UNQUOTE(JSON_EXTRACT(normal_data_extend,'$.locale.vi.link_nut'))='/khoa-hoc';
COMMIT;
