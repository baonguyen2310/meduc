SET NAMES utf8mb4;
ALTER TABLE course_price_lists ADD COLUMN IF NOT EXISTS course_type VARCHAR(16) NOT NULL DEFAULT 'course';
UPDATE course_price_lists l SET l.course_type='exam_prep' WHERE l.id IN (
 SELECT p.course_price_list_id FROM products p WHERE p.deleted=0 AND p.course_price_list_id IS NOT NULL
 AND (p.main_category_id=125 OR EXISTS (SELECT 1 FROM categories_product cp JOIN categories c ON c.id=cp.category_id WHERE cp.product_id=p.id AND (c.id=125 OR c.path_id LIKE '%|125|%')))
);
INSERT INTO course_price_lists(name,slug,course_type,description,position,status,created,updated)
SELECT 'Khóa học Y khoa','khoa-hoc-y-khoa','course','Chọn khóa học phù hợp với năm học và mục tiêu của bạn.',-1,1,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM course_price_lists WHERE slug='khoa-hoc-y-khoa');
SET @meduc_course_prices=(SELECT id FROM course_price_lists WHERE slug='khoa-hoc-y-khoa');
UPDATE products p SET p.course_price_list_id=@meduc_course_prices
WHERE p.course_price_list_id IS NULL AND p.deleted=0 AND p.status=1
AND (p.main_category_id=50 OR EXISTS (SELECT 1 FROM categories c WHERE c.id=p.main_category_id AND c.path_id LIKE '%|50|%') OR EXISTS (SELECT 1 FROM categories_product cp JOIN categories c ON c.id=cp.category_id WHERE cp.product_id=p.id AND (c.id=50 OR c.path_id LIKE '%|50|%')))
AND COALESCE(p.main_category_id,0)<>125 AND NOT EXISTS (SELECT 1 FROM categories c WHERE c.id=p.main_category_id AND c.path_id LIKE '%|125|%') AND NOT EXISTS (SELECT 1 FROM categories_product cp JOIN categories c ON c.id=cp.category_id WHERE cp.product_id=p.id AND (c.id=125 OR c.path_id LIKE '%|125|%'));
INSERT INTO course_price_packages(price_list_id,name,course_count,price,sale_price,benefits,recommended,position,status,created,updated)
SELECT @meduc_course_prices,CONCAT('Gói ',n,' môn'),n,n*3000000,NULL,
CONCAT('Tự chọn ',n,' môn trong bảng giá\nHọc theo lộ trình từng khóa\nXem lại nội dung khóa học\nQuản lý các khóa đã đăng ký'),IF(n=2,1,0),n,1,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3) a
WHERE NOT EXISTS (SELECT 1 FROM course_price_packages p WHERE p.price_list_id=@meduc_course_prices AND p.course_count=a.n);
