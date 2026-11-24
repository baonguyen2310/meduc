-- Equipment detail page (category 80), desktop and mobile.
-- Back up these template rows before applying; these CMS tables use MyISAM.
SET NAMES utf8mb4;

INSERT INTO templates_block
  (template_code,code,name,type,action,view,element_view,config,data_extend,normal_data_extend,created,created_by,updated,status,search_unicode,deleted)
SELECT source.template_code,'equipmentqna','Hỏi đáp thiết bị - MedUC',source.type,source.action,
  'view_equipment_comments.tpl',source.element_view,JSON_SET(source.config,'$.class',''),
  source.data_extend,source.normal_data_extend,UNIX_TIMESTAMP(),NULL,UNIX_TIMESTAMP(),source.status,
  'hoi dap thiet bi meduc | equipmentqna',0
FROM templates_block source
WHERE source.template_code='app01' AND source.code='nfaxb23' AND source.deleted=0
  AND NOT EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='equipmentqna');

UPDATE templates_block
SET view='view_equipment_detail.tpl', config=JSON_SET(config,'$.class',''), updated=UNIX_TIMESTAMP()
WHERE template_code='app01' AND code='pom1l5g' AND type='product_detail' AND view='view_book_v3.tpl';

UPDATE templates_column SET block_code='pom1l5g,equipmentqna'
WHERE template_code='app01' AND page_code='iefplhk' AND row_code IN ('mr3bgd5','i2xqcgs')
  AND block_code='pom1l5g,nfaxb23'
  AND EXISTS (SELECT 1 FROM templates_block WHERE template_code='app01' AND code='equipmentqna' AND deleted=0);

UPDATE templates_column SET block_code=''
WHERE template_code='app01' AND page_code='iefplhk' AND row_code IN ('9m0adwh','ouf7k6q') AND block_code='mz4eo5d';

UPDATE templates_row SET config=JSON_SET(COALESCE(config,'{}'),'$.style_class','','$.full_screen',1)
WHERE template_code='app01' AND page_code='iefplhk'
  AND code IN ('9m0adwh','ouf7k6q','mr3bgd5','i2xqcgs');
