-- One optional image per course, using the existing product attribute image picker and save flow.
START TRANSACTION;
INSERT INTO attributes (attribute_type, code, input_type, has_image, required, position, status, created_by, created, deleted)
SELECT 'product', 'anhtongquan', 'image', 0, 0, 6, 1, 1, UNIX_TIMESTAMP(), 0
WHERE NOT EXISTS (SELECT 1 FROM attributes WHERE code = 'anhtongquan');

INSERT INTO attributes_content (attribute_id, name, lang, search_unicode)
SELECT a.id, 'Ảnh tổng quan khoá học', 'vi', 'anh tong quan khoa hoc'
FROM attributes a
WHERE a.code = 'anhtongquan' AND a.attribute_type = 'product' AND a.input_type = 'image'
AND NOT EXISTS (SELECT 1 FROM attributes_content c WHERE c.attribute_id = a.id AND c.lang = 'vi');
COMMIT;
