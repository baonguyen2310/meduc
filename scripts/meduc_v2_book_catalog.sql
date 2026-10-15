-- Live public book catalogue on /sach-y-khoa and the existing subject/year category URLs.
-- No products, prices, images, categories or order data are seeded or modified.
-- Apply once and clear website cache. Existing editorial text is preserved on subsequent runs.
-- Original yzr8ow7 block assignments for rollback:
-- sfli3m8/on1qt7x = 8t9pn3k; ysiat2v/9a48tqb = 4x7glj2,jsny8qu,usdng3k.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','bookcat','Danh sách sách Y khoa - Kệ sách MedUC','product','','view_book_catalog.tpl','',
  '{"class":"","cache":"0","number_record":"500","has_pagination":"0","sort_field":"position","sort_type":"desc","data_type":"by_url","filter_data":""}',
  NULL,'{"locale":{"vi":{"tieu_de_1":"MỞ SÁCH.","tieu_de_2":"MỞ THÊM GÓC NHÌN.","mo_ta":"Từ kiến thức nền tảng đến những ca lâm sàng. Tìm cuốn sách phù hợp với môn học và chặng đường của bạn."}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'danh sach sach y khoa - ke sach meduc | bookcat',0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='bookcat');

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','yzr8ow7',IF(devices.device=1,'bookcatalogm','bookcatalog'),'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='yzr8ow7')
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='yzr8ow7' AND code=IF(devices.device=1,'bookcatalogm','bookcatalog') AND device=devices.device);

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','yzr8ow7',IF(devices.device=1,'bookcatalogm','bookcatalog'),12,'bookcat',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='yzr8ow7' AND code=IF(devices.device=1,'bookcatalogm','bookcatalog') AND device=devices.device)
AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='yzr8ow7' AND row_code=IF(devices.device=1,'bookcatalogm','bookcatalog') AND device=devices.device);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='yzr8ow7'
AND block_code IN('8t9pn3k','4x7glj2,jsny8qu,usdng3k');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code='app01' AND page_code='yzr8ow7' AND code IN('sfli3m8','ysiat2v','on1qt7x','9a48tqb');
COMMIT;
