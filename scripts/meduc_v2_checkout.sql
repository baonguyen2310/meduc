-- /dat-hang and its confirmation page; course /order/info and /order/checkout use normal templates.
-- Keeps original order/contact form 61CQ0U3H9I, payment methods and live product data.
-- Original columns for rollback: 4p8ktu1/hfrp6n7=8t9pn3k, t4ivqsx=y35rthu;
-- 8ynx5t3/yi51ao3=z4ircu6. New rows have separate mobile codes to avoid duplicate blocks.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_block
(template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','bookcheckout','Thanh toán sách và thiết bị - MedUC','slider','','view_book_checkout.tpl','','{"cache":"0","class":"","data":[]}',NULL,'{"locale":{"vi":{}},"normal":{}}',UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'thanh toan sach thiet bi meduc',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM templates_block WHERE template_code='app01' AND code='bookcheckout');
INSERT INTO templates_block
(template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','bookorderdone','Xác nhận đơn hàng - MedUC','slider','','view_book_order_success.tpl','','{"cache":"0","class":"","data":[]}',NULL,'{"locale":{"vi":{}},"normal":{}}',UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'xac nhan don hang meduc',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM templates_block WHERE template_code='app01' AND code='bookorderdone');
INSERT INTO templates_row(template_code,page_code,code,type,config,device)
SELECT 'app01',pages.page_code,CONCAT(pages.row_code,IF(devices.device=1,'m','')),'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT '4p8ktu1' page_code,'bookcheckoutpage' row_code UNION ALL SELECT '8ynx5t3','bookorderdonepage') pages
CROSS JOIN (SELECT 0 device UNION ALL SELECT 1) devices
WHERE EXISTS(SELECT 1 FROM templates_page WHERE template_code='app01' AND code=pages.page_code)
AND NOT EXISTS(SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code=pages.page_code AND code=CONCAT(pages.row_code,IF(devices.device=1,'m','')) AND device=devices.device);
INSERT INTO templates_column(template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01',pages.page_code,CONCAT(pages.row_code,IF(devices.device=1,'m','')),12,pages.block_code,devices.device
FROM (SELECT '4p8ktu1' page_code,'bookcheckoutpage' row_code,'bookcheckout' block_code UNION ALL SELECT '8ynx5t3','bookorderdonepage','bookorderdone') pages
CROSS JOIN (SELECT 0 device UNION ALL SELECT 1) devices
WHERE EXISTS(SELECT 1 FROM templates_row WHERE template_code='app01' AND code=CONCAT(pages.row_code,IF(devices.device=1,'m','')) AND device=devices.device)
AND NOT EXISTS(SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code=pages.page_code AND row_code=CONCAT(pages.row_code,IF(devices.device=1,'m','')) AND device=devices.device);
UPDATE templates_column SET block_code='' WHERE template_code='app01' AND page_code='4p8ktu1' AND block_code IN('8t9pn3k','y35rthu');
UPDATE templates_column SET block_code='' WHERE template_code='app01' AND page_code='8ynx5t3' AND block_code='z4ircu6';
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}' WHERE template_code='app01' AND page_code IN('4p8ktu1','8ynx5t3') AND code IN('hfrp6n7','t4ivqsx','yi51ao3');
COMMIT;
