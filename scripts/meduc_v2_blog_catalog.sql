-- MedUC journal: existing public articles from Blog (45) and Blog Môn Học (113).
-- This migration changes page composition only; articles and their URLs remain untouched.
-- Original mlvk2js blocks for rollback:
-- jqzon6e/k54a3sq=8t9pn3k; ejdgsx4=3ra1uk2 and v6xbh3u;
-- k03vlon=v6xbh3u,3ra1uk2; 2bk40wr/uqygoim=4x7glj2,hso1iwm,0y52arf.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','blogcat','Blog - Góc học tập MedUC','html','','blogcat.tpl','',
  '{"class":"","cache":"0"}',NULL,
  '{"locale":{"vi":{"tieu_de_1":"ĐỌC MỘT BÀI.","tieu_de_2":"HIỂU THÊM MỘT ĐIỀU.","mo_ta":"Những bài viết Y khoa và kinh nghiệm học tập từ MedUC. Tìm góc nhìn phù hợp với môn học bạn đang theo đuổi."}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'blog - goc hoc tap meduc | blogcat',0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='blogcat');

-- Give the second original blog tree the same presentation without changing the generic articles/docs page.
INSERT INTO templates_page (template_code,layout_code,code,name,page_type,type,category_id,created,updated)
SELECT template_code,layout_code,'blogsub','Blog theo môn học','page','article',113,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM templates_page WHERE template_code='app01' AND code='mlvk2js'
AND NOT EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code='blogsub');
INSERT INTO templates_page_content (template_code,page_code,url,lang,seo_title,seo_description)
SELECT 'app01','blogsub','danh-sach-blog-mon-hoc','vi','Blog Y khoa và kinh nghiệm học tập - MedUC','Bài viết Y khoa và kinh nghiệm học tập từ MedUC, theo từng môn học.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM templates_page_content WHERE template_code='app01' AND page_code='blogsub' AND lang='vi');

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01',pages.code,
  CONCAT(IF(pages.code='mlvk2js','blogcatalog','blogsubjects'),IF(devices.device=1,'m','')),
  'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 'mlvk2js' AS code UNION ALL SELECT 'blogsub') pages
CROSS JOIN (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS (SELECT 1 FROM templates_page WHERE template_code='app01' AND code=pages.code)
AND NOT EXISTS (SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code=pages.code AND code=CONCAT(IF(pages.code='mlvk2js','blogcatalog','blogsubjects'),IF(devices.device=1,'m','')) AND device=devices.device);

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01',page_code,code,12,'blogcat',device FROM templates_row r
WHERE template_code='app01' AND page_code IN('mlvk2js','blogsub') AND code IN('blogcatalog','blogcatalogm','blogsubjects','blogsubjectsm')
AND NOT EXISTS (SELECT 1 FROM templates_column c WHERE c.template_code=r.template_code AND c.page_code=r.page_code AND c.row_code=r.code AND c.device=r.device);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='mlvk2js'
AND block_code IN('8t9pn3k','3ra1uk2','v6xbh3u','v6xbh3u,3ra1uk2','4x7glj2,hso1iwm,0y52arf');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code='app01' AND page_code='mlvk2js' AND code IN('ejdgsx4','jqzon6e','k54a3sq','k03vlon','2bk40wr','uqygoim');
COMMIT;
