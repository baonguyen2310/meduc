-- Separate document details from the generic blog/article layout.
-- Uses the original category tree (48), article URLs, content and public attachments.
-- Rollback: remove documentdetail/documentdetailm column assignments and the docdetail page;
-- the original generic article detail page c38hltr has not been changed.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_page (template_code,layout_code,code,name,page_type,type,category_id,created,updated)
SELECT template_code,layout_code,'docdetail','Chi tiết tài liệu học tập','page','article_detail',48,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM templates_page WHERE template_code='app01' AND code='c38hltr'
AND NOT EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='docdetail');
INSERT INTO templates_page_content (template_code,page_code,url,lang,seo_title,seo_description)
SELECT 'app01','docdetail','chi-tiet-tai-lieu-hoc-tap','vi','Tài liệu học tập Y khoa - MedUC','Đọc tài liệu, giáo trình và bài giảng Y khoa trong thư viện MedUC.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_page_content WHERE template_code='app01' AND page_code='docdetail' AND lang='vi');
INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','docdetail','Chi tiết tài liệu - MedUC','article_detail','','view_document_detail.tpl','',
  '{"class":"","cache":"0","data_type":"by_url"}',NULL,'{"locale":{"vi":{}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'chi tiet tai lieu meduc | docdetail',0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='docdetail');
INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','docdetail',IF(devices.device=1,'documentdetailm','documentdetail'),'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='docdetail')
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='docdetail' AND code=IF(devices.device=1,'documentdetailm','documentdetail') AND device=devices.device);
INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','docdetail',IF(devices.device=1,'documentdetailm','documentdetail'),12,'docdetail',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='docdetail' AND code=IF(devices.device=1,'documentdetailm','documentdetail') AND device=devices.device)
AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='docdetail' AND row_code=IF(devices.device=1,'documentdetailm','documentdetail') AND device=devices.device);
COMMIT;
