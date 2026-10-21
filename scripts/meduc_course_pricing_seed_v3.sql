SET NAMES utf8mb4;
INSERT INTO course_price_lists(name,slug,description,position,status,created,updated)
SELECT 'Luyện thi Y khoa','luyen-thi-y-khoa','Chọn những môn bạn cần. Chủ động ôn luyện theo lộ trình của riêng mình.',0,1,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM course_price_lists WHERE slug='luyen-thi-y-khoa');
SET @meduc_price_list=(SELECT id FROM course_price_lists WHERE slug='luyen-thi-y-khoa');
UPDATE products p INNER JOIN curriculum_v2_courses c ON c.product_id=p.id
SET p.course_price_list_id=@meduc_price_list WHERE p.course_price_list_id IS NULL AND p.deleted=0;
INSERT INTO course_price_packages(price_list_id,name,course_count,price,sale_price,benefits,recommended,position,status,created,updated)
SELECT @meduc_price_list,CONCAT('Gói ',n,' môn'),n,n*1500000,n*499000,
 CONCAT('Tự chọn ',n,' môn trong bảng giá\nLuyện tập theo chương và bài\nLưu lịch sử và theo dõi kết quả\nXem lời giải chi tiết'),IF(n=2,1,0),n,1,UNIX_TIMESTAMP(),UNIX_TIMESTAMP()
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3) a
WHERE NOT EXISTS (SELECT 1 FROM course_price_packages p WHERE p.price_list_id=@meduc_price_list AND p.course_count=a.n);
