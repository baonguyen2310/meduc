-- Blog article reader for both original blog trees; generic article/document pages stay separate.
-- All article text, URLs, tags, FAQ and course selections continue to come from the CMS.
-- Rollback: remove blogread page assignments; restore the original 6wlfvac column values:
-- on1wu9s/augzhp2=mz4eo5d; y1rv6gn(3)=9hfl58c;
-- y1rv6gn(9)=ir7oumh,srmjg69,fg0ehkr,rew8ysj,0jy2as5,71fa4ku;
-- 2wiab4q=ir7oumh; u90yotz=fg0ehkr; 4zg5y3a=srmjg69;
-- h0facb6=rew8ysj,0jy2as5,71fa4ku; 4r3ek9x=9hfl58c; rqwcbhl=o5e0w9n,h4pbrs3,q4dnmj7.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT 'app01','blogdetail','Chi tiết blog - MedUC Journal','article_detail','','view_blog_detail.tpl','',
  '{"class":"","cache":"0","data_type":"by_url"}',NULL,'{"locale":{"vi":{}},"normal":{}}',
  UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),1,'chi tiet blog meduc journal | blogdetail',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM templates_block WHERE template_code='app01' AND code='blogdetail');

INSERT INTO templates_page (template_code,layout_code,code,name,page_type,type,category_id,created,updated)
SELECT template_code,layout_code,'blogread','Chi tiết blog - MedUC Journal','page','article_detail',45,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM templates_page WHERE template_code='app01' AND code='c38hltr'
AND NOT EXISTS(SELECT 1 FROM templates_page WHERE template_code='app01' AND code='blogread');
INSERT INTO templates_page_content (template_code,page_code,url,lang,seo_title,seo_description)
SELECT 'app01','blogread','','vi','Blog Y khoa - MedUC','Bài viết Y khoa và kinh nghiệm học tập từ MedUC.'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM templates_page_content WHERE template_code='app01' AND page_code='blogread' AND lang='vi');

INSERT INTO templates_row (template_code,page_code,code,type,config,device)
SELECT 'app01',pages.code,CONCAT(IF(pages.code='blogread','blogreadpage','blogsubjectread'),IF(devices.device=1,'m','')),
  'content','{"id_row":"","style_class":"","full_screen":1}',devices.device
FROM (SELECT 'blogread' AS code UNION ALL SELECT '6wlfvac') pages
CROSS JOIN (SELECT 0 AS device UNION ALL SELECT 1) devices
WHERE EXISTS(SELECT 1 FROM templates_page WHERE template_code='app01' AND code=pages.code)
AND NOT EXISTS(SELECT 1 FROM templates_row WHERE template_code='app01' AND page_code=pages.code AND code=CONCAT(IF(pages.code='blogread','blogreadpage','blogsubjectread'),IF(devices.device=1,'m','')) AND device=devices.device);

INSERT INTO templates_column (template_code,page_code,row_code,column_value,block_code,device)
SELECT 'app01',page_code,code,12,'blogdetail',device FROM templates_row r
WHERE template_code='app01' AND page_code IN('blogread','6wlfvac') AND code IN('blogreadpage','blogreadpagem','blogsubjectread','blogsubjectreadm')
AND NOT EXISTS(SELECT 1 FROM templates_column c WHERE c.template_code=r.template_code AND c.page_code=r.page_code AND c.row_code=r.code AND c.device=r.device);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='6wlfvac'
AND row_code IN('on1wu9s','augzhp2','y1rv6gn','2wiab4q','u90yotz','4zg5y3a','h0facb6','4r3ek9x','rqwcbhl')
AND block_code IN('mz4eo5d','9hfl58c','ir7oumh,srmjg69,fg0ehkr,rew8ysj,0jy2as5,71fa4ku','ir7oumh','fg0ehkr','srmjg69','rew8ysj,0jy2as5,71fa4ku','o5e0w9n,h4pbrs3,q4dnmj7');
UPDATE templates_row SET config='{"id_row":"","style_class":"","full_screen":1}'
WHERE template_code='app01' AND page_code='6wlfvac' AND code IN('on1wu9s','augzhp2','y1rv6gn','2wiab4q','u90yotz','4zg5y3a','h0facb6','4r3ek9x','rqwcbhl');
COMMIT;
