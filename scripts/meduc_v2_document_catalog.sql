-- Live document library on /tai-lieu-hoc-tap and its existing subject/year category URLs.
-- The helper reads public, non-draft articles and attachments from category 48 and its children.
-- No articles, files, memberships or download permissions are changed.
-- Original 8je9vnk assignments for rollback:
-- lo4zm56/08ncqi5 = 8t9pn3k; bfvp4jz/fokdvqx = u3c9i2h,au2wpd4.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','documentcat','Thư viện tài liệu học tập MedUC','html','','document_catalog.tpl','',
  '{"class":"","cache":"0"}',NULL,
  '{"locale":{"vi":{"tieu_de_1":"ĐÚNG TÀI LIỆU.","tieu_de_2":"VỮNG KIẾN THỨC.","mo_ta":"Giáo trình, bài giảng và tài liệu ôn tập cho hành trình học Y. Bắt đầu từ môn bạn đang học, tìm thêm một góc nhìn để hiểu sâu hơn."}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'thu vien tai lieu hoc tap meduc | documentcat',0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='documentcat');
INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01','8je9vnk',IF(devices.device=1,'documentcatalogm','documentcatalog'),'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='8je9vnk')
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='8je9vnk' AND code=IF(devices.device=1,'documentcatalogm','documentcatalog') AND device=devices.device);
INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01','8je9vnk',IF(devices.device=1,'documentcatalogm','documentcatalog'),12,'documentcat',devices.device
FROM (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code='8je9vnk' AND code=IF(devices.device=1,'documentcatalogm','documentcatalog') AND device=devices.device)
AND NOT EXISTS (SELECT 1 FROM templates_column WHERE template_code='app01' AND page_code='8je9vnk' AND row_code=IF(devices.device=1,'documentcatalogm','documentcatalog') AND device=devices.device);
UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='8je9vnk' AND block_code IN ('8t9pn3k','u3c9i2h,au2wpd4');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code='app01' AND page_code='8je9vnk' AND code IN ('lo4zm56','08ncqi5','bfvp4jz','fokdvqx');
COMMIT;
