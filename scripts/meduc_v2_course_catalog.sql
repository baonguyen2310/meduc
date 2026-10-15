-- Horizontal public course catalogue on /khoa-hoc and its existing course-category URLs.
-- Uses the live product block pipeline, real prices and memberships in year categories 102, 72, 103.
-- No snapshot product data is seeded. Inactive/draft/staff-only exam content stays outside the catalogue.
-- Run once, then clear website cache. Existing coursecat text is preserved on re-runs.
-- Rollback: blank coursecatalog/coursecatalogm columns and restore the old odxyim4 columns:
-- pfncuat=4x7glj2, bxgfhs1=8t9pn3k, gyowbdi=u52h81f,wo8nl63;
-- rd0zqgv=8t9pn3k, aelizfh=4x7glj2,u52h81f,wo8nl63.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','coursecat','Danh sách khóa học - Card ngang theo năm học','product','','view_course_catalog.tpl','',
  '{"class":"","cache":"0","number_record":"500","has_pagination":"0","sort_field":"position","sort_type":"desc","data_type":"by_url","filter_data":""}',
  NULL,'{"locale":{"vi":{"tieu_de_1":"CHỌN KHÓA HỌC.","tieu_de_2":"ĐÚNG CHẶNG ĐƯỜNG.","mo_ta":"Tìm môn học phù hợp với năm học và mục tiêu của bạn. Xem lộ trình, chọn khóa học và bắt đầu cùng MedUC."}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'danh sach khoa hoc - card ngang theo nam hoc | coursecat',0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='coursecat');

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','odxyim4',IF(devices.device=1,'coursecatalogm','coursecatalog'),'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='odxyim4')
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='odxyim4' AND code=IF(devices.device=1,'coursecatalogm','coursecatalog') AND device=devices.device);

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','odxyim4',IF(devices.device=1,'coursecatalogm','coursecatalog'),12,'coursecat',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='odxyim4' AND code=IF(devices.device=1,'coursecatalogm','coursecatalog') AND device=devices.device)
AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='odxyim4' AND row_code=IF(devices.device=1,'coursecatalogm','coursecatalog') AND device=devices.device);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='odxyim4'
AND block_code IN ('4x7glj2','8t9pn3k','u52h81f,wo8nl63','4x7glj2,u52h81f,wo8nl63');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code='app01' AND page_code='odxyim4' AND code IN ('pfncuat','bxgfhs1','gyowbdi','rd0zqgv','aelizfh');
COMMIT;
