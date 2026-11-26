-- Áo blouse: thuộc tính mã hàng Kiểu dáng và Màu (Size đã có, id 44 · blouse_size; thêm 3XL),
-- cùng thuộc tính sản phẩm "phí thêu tên" để admin bật thêu tên cho từng mẫu áo.
-- Chạy lại nhiều lần không tạo trùng. Sau khi chạy trên hosting: xoá cache dữ liệu
-- (tmp/cache/data) để Attributes/AttributesOptions::getAll đọc lại.
-- Màu: mã tuỳ chọn có đuôi 6 ký tự hex (vd mau_5f6b58) là màu của ô chọn màu trên trang áo.

SET @now = UNIX_TIMESTAMP();

-- Kiểu dáng (Nữ / Nam)
INSERT INTO attributes (attribute_type, code, input_type, has_image, required, position, status, created, updated, deleted)
SELECT 'product_item', 'blouse_fit', 'special_select_item', 0, 1, 98, 1, @now, @now, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM attributes WHERE code = 'blouse_fit' AND deleted = 0);
SET @fit = (SELECT id FROM attributes WHERE code = 'blouse_fit' AND deleted = 0 ORDER BY id LIMIT 1);
INSERT INTO attributes_content (attribute_id, name, lang, search_unicode)
SELECT @fit, 'Kiểu dáng áo blouse', 'vi', 'kieu dang ao blouse'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM attributes_content WHERE attribute_id = @fit AND lang = 'vi');

-- Màu
INSERT INTO attributes (attribute_type, code, input_type, has_image, required, position, status, created, updated, deleted)
SELECT 'product_item', 'blouse_color', 'special_select_item', 0, 1, 99, 1, @now, @now, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM attributes WHERE code = 'blouse_color' AND deleted = 0);
SET @color = (SELECT id FROM attributes WHERE code = 'blouse_color' AND deleted = 0 ORDER BY id LIMIT 1);
INSERT INTO attributes_content (attribute_id, name, lang, search_unicode)
SELECT @color, 'Màu áo blouse', 'vi', 'mau ao blouse'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM attributes_content WHERE attribute_id = @color AND lang = 'vi');

SET @size = (SELECT id FROM attributes WHERE code = 'blouse_size' AND deleted = 0 ORDER BY id LIMIT 1);

-- Tuỳ chọn: (thuộc tính, mã, thứ tự, tên)
DROP TEMPORARY TABLE IF EXISTS blouse_option_seed;
CREATE TEMPORARY TABLE blouse_option_seed (attribute_id INT, code VARCHAR(50), position INT, name VARCHAR(255), search VARCHAR(255)) DEFAULT CHARSET = utf8mb4;
INSERT INTO blouse_option_seed VALUES
  (@fit, 'blouse_nu', 1, 'Nữ', 'nu'),
  (@fit, 'blouse_nam', 2, 'Nam', 'nam'),
  (@color, 'mau_5e6a50', 1, 'Xanh rêu', 'xanh reu'),
  (@color, 'mau_5c6068', 2, 'Xám chì', 'xam chi'),
  (@size, 'blouse_3xl', 7, '3XL', '3xl');
INSERT INTO attributes_options (attribute_id, code, position, deleted)
SELECT s.attribute_id, s.code, s.position, 0 FROM blouse_option_seed s
WHERE NOT EXISTS (SELECT 1 FROM attributes_options o WHERE o.attribute_id = s.attribute_id AND o.code = s.code AND o.deleted = 0);
INSERT INTO attributes_options_content (attribute_option_id, name, lang, search_unicode)
SELECT o.id, s.name, 'vi', s.search FROM blouse_option_seed s
JOIN attributes_options o ON o.attribute_id = s.attribute_id AND o.code = s.code AND o.deleted = 0
WHERE NOT EXISTS (SELECT 1 FROM attributes_options_content c WHERE c.attribute_option_id = o.id AND c.lang = 'vi');
DROP TEMPORARY TABLE blouse_option_seed;

-- Phí thêu tên (đ) cho mỗi áo. Để trống: mẫu áo đó không nhận thêu tên.
INSERT INTO attributes (attribute_type, code, input_type, has_image, required, position, status, created, updated, deleted)
SELECT 'product', 'phi_theu_ten', 'numeric', 0, 0, 45, 1, @now, @now, 0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM attributes WHERE code = 'phi_theu_ten' AND deleted = 0);
SET @fee = (SELECT id FROM attributes WHERE code = 'phi_theu_ten' AND deleted = 0 ORDER BY id LIMIT 1);
INSERT INTO attributes_content (attribute_id, name, lang, search_unicode)
SELECT @fee, 'Áo blouse: phí thêu tên mỗi áo (đ)', 'vi', 'ao blouse phi theu ten moi ao'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM attributes_content WHERE attribute_id = @fee AND lang = 'vi');
