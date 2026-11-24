-- Assemble the member's course dashboard on /khoa-hoc-da-dang-ky (h0ra52x).
-- Keep this block uncached because it shows the current member's entitlements and balance.
SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','membercourses','Khoá học đang tham gia - MedUC','html','','membercourses.tpl','',
  '{"class":"","cache":"0","html_content":""}',NULL,'{"locale":{"vi":{}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'khoa hoc dang tham gia | membercourses',0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='membercourses');

UPDATE templates_column SET block_code='membercourses'
WHERE template_code='app01' AND page_code='h0ra52x' AND row_code='6d5zmv3' AND block_code='vwg9tcd'
  AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='membercourses' AND status=1 AND deleted=0);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='h0ra52x' AND row_code='tpkfq9n' AND block_code='8t9pn3k';

UPDATE templates_row SET config=JSON_SET(COALESCE(config,'{}'),'$.style_class','','$.full_screen',1)
WHERE template_code='app01' AND page_code='h0ra52x' AND code IN ('6d5zmv3','tpkfq9n');
