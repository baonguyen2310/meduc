-- Replace only the book detail layout (au0js3n), preserving live products and their existing URLs.
-- The comment block retains the original approval/login settings; comments are not copied or deleted.
-- Rollback original columns: xbqaj5m/974a1sg=mz4eo5d; xl8gw31/3c6vkgr=yanoi4s,nfaxb23.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','bookdetail','Chi tiết sách - MedUC','product_detail','','view_book_detail.tpl','',
  '{"class":"","cache":"0","data_type":"by_url"}',NULL,'{"locale":{"vi":{}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'chi tiet sach meduc | bookdetail',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM templates_block WHERE template_code='app01' AND code='bookdetail');

INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','bookqna','Hỏi đáp sách - MedUC','comment','','view_book_comments.tpl','',
  '{"class":"","cache":"0","number_record":"5","sort_field":"created","login_required":"0","awaiting_approval":"1"}',NULL,'{"locale":{"vi":{}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'hoi dap sach meduc | bookqna',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM templates_block WHERE template_code='app01' AND code='bookqna');

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','au0js3n',IF(devices.device=1,'bookdetailpagem','bookdetailpage'),'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS(SELECT 1 FROM templates_page WHERE template_code='app01' AND code='au0js3n')
AND NOT EXISTS(SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='au0js3n' AND code=IF(devices.device=1,'bookdetailpagem','bookdetailpage') AND device=devices.device);

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','au0js3n',IF(devices.device=1,'bookdetailpagem','bookdetailpage'),12,'bookdetail,bookqna',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS(SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='au0js3n' AND code=IF(devices.device=1,'bookdetailpagem','bookdetailpage') AND device=devices.device)
AND NOT EXISTS(SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='au0js3n' AND row_code=IF(devices.device=1,'bookdetailpagem','bookdetailpage') AND device=devices.device);

UPDATE templates_column SET block_code='' WHERE template_code='app01' AND page_code='au0js3n' AND block_code IN('mz4eo5d','yanoi4s,nfaxb23');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}' WHERE template_code='app01' AND page_code='au0js3n' AND code IN('xbqaj5m','xl8gw31','974a1sg','3c6vkgr');
COMMIT;
