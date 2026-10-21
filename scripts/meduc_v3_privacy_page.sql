-- Informational privacy page; no account or commerce behavior is changed.
SET NAMES utf8mb4;
INSERT INTO templates_page (template_code,layout_code,code,name,page_type,type,category_id,created,updated)
SELECT template_code,layout_code,'privacyv3','Chính sách bảo mật','page','normal',NULL,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM templates_page WHERE template_code='app01' AND code='cidahpl'
AND NOT EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='privacyv3');

INSERT INTO templates_page_content (template_code,page_code,url,lang,seo_title,seo_description)
SELECT 'app01','privacyv3','chinh-sach-bao-mat-thong-tin','vi','Chính sách bảo mật | MedUC',
'Thông tin MedUC thu thập, mục đích sử dụng, email xác thực và cách liên hệ về dữ liệu tài khoản.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_page_content WHERE template_code='app01' AND (page_code='privacyv3' OR url='chinh-sach-bao-mat-thong-tin'));

INSERT INTO templates_block (template_code,code,name,type,action,view,element_view,config,created,updated,status,deleted)
SELECT 'app01','privacyv3','Chính sách bảo mật','html','','privacy.tpl','','{"class":"","cache":"1"}',UNIX_TIMESTAMP(),UNIX_TIMESTAMP(),1,0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='privacyv3');

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','privacyv3',IF(d.device=1,'privacyrowm','privacyrow'),'content','{"full_screen":1}',d.device
FROM (SELECT 0 device UNION ALL SELECT 1) d WHERE NOT EXISTS
(SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='privacyv3' AND device=d.device);
INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','privacyv3',IF(d.device=1,'privacyrowm','privacyrow'),12,'privacyv3',d.device
FROM (SELECT 0 device UNION ALL SELECT 1) d WHERE NOT EXISTS
(SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='privacyv3' AND device=d.device);
