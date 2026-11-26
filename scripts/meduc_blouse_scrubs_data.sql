-- MedUC Blouse: bộ scrubs bán theo hợp đồng white-label (26/11/2026).
-- Chạy sau scripts/blouse_variants.sql. Chuyển sản phẩm 499 (áo minh hoạ AI) thành "Bộ scrubs MedUC Blouse":
-- 24 mã hàng = Kiểu dáng (Nữ, Nam) × Màu (Xanh rêu, Xám chì) × Size (S, M, L, XL, XXL, 3XL),
-- giá 700.000đ, tồn kho mặc định 20 mỗi mã, thêu tên 35.000đ/áo. Ẩn sản phẩm 500 (áo tay dài minh hoạ AI).
-- Ảnh nằm ở cdn/media/meduc-blouse-20261126 (đã tạo cùng ảnh thu nhỏ trong cdn/thumbs).
-- Sau khi chạy: xoá cache dữ liệu (Attributes/AttributesOptions::getAll).

START TRANSACTION;
SET @now = UNIX_TIMESTAMP();
SET @product = 499;
SET @fit = (SELECT id FROM attributes WHERE code = 'blouse_fit' AND deleted = 0 ORDER BY id LIMIT 1);
SET @color = (SELECT id FROM attributes WHERE code = 'blouse_color' AND deleted = 0 ORDER BY id LIMIT 1);
SET @size = (SELECT id FROM attributes WHERE code = 'blouse_size' AND deleted = 0 ORDER BY id LIMIT 1);
SET @fee = (SELECT id FROM attributes WHERE code = 'phi_theu_ten' AND deleted = 0 ORDER BY id LIMIT 1);
SET @intro = (SELECT id FROM attributes WHERE code = 'motangan' AND deleted = 0 ORDER BY id LIMIT 1);
SET @info = (SELECT id FROM attributes WHERE code = 'thongtinchitiet' AND deleted = 0 ORDER BY id LIMIT 1);
SET @care = (SELECT id FROM attributes WHERE code = 'huongdansudung' AND deleted = 0 ORDER BY id LIMIT 1);
SET @spec = (SELECT id FROM attributes WHERE code = 'thongsokythuat' AND deleted = 0 ORDER BY id LIMIT 1);

-- Tên, mô tả, SEO, đường dẫn
UPDATE products_content SET
  name = 'Bộ scrubs MedUC Blouse',
  search_unicode = 'bo scrubs meduc blouse',
  description = 'Áo cổ V và quần ống suông · Xanh rêu, Xám chì',
  content = NULL,
  seo_title = 'Bộ scrubs MedUC Blouse cho sinh viên Y | MedUC',
  seo_description = 'Bộ scrubs MedUC Blouse: áo cổ V, quần ống suông, vải thoáng nhanh khô. Mẫu nữ và nam, màu Xanh rêu và Xám chì, size S đến 3XL, nhận thêu tên.'
WHERE product_id = @product AND lang = 'vi';
UPDATE links SET url = 'meduc-blouse-scrubs', updated = @now
WHERE foreign_id = @product AND type = 'product_detail' AND lang = 'vi' AND deleted = 0;
INSERT INTO seo_redirects (url, redirect, search_unicode, created, updated, status)
SELECT 'ao-blouse-sinh-vien-tay-ngan', 'meduc-blouse-scrubs', 'ao-blouse-sinh-vien-tay-ngan', @now, @now, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM seo_redirects WHERE url = 'ao-blouse-sinh-vien-tay-ngan');

-- Nội dung các mục trên trang
DELETE FROM products_attribute WHERE product_id = @product AND attribute_id IN (@intro, @info, @care, @spec, @fee);
INSERT INTO products_attribute (product_id, attribute_id, value) VALUES
(@product, @intro, JSON_OBJECT('vi', '<p>Bộ scrubs MedUC Blouse gồm áo cổ V và quần ống suông, may từ vải thoáng khí, nhanh khô và giữ phom, để bạn gọn gàng suốt buổi thực hành, đi lâm sàng hay ca trực dài.</p><ul><li><strong>Mẫu nữ:</strong> dáng gọn, chiết nhẹ eo, túi ngực nhỏ.</li><li><strong>Mẫu nam:</strong> phom rộng thoải mái qua vai, túi ngực lớn có ngăn cài bút.</li><li><strong>Hai màu:</strong> Xanh rêu trầm dịu mắt và Xám chì trung tính.</li><li><strong>Thêu tên</strong> trên ngực trái theo yêu cầu.</li></ul>')),
(@product, @info, JSON_OBJECT('vi', '<p><strong>Thiết kế</strong></p><ul><li>Áo cổ V, túi ngực (mẫu nam có thêm ngăn đựng bút).</li><li>Túi bụng âm, túi hông âm.</li><li>Quần giả khoá kéo, bản lưng rời rộng 5 cm kéo đến túi hông.</li><li>2 đường cúp ngang, ống suông thẳng.</li></ul><p><strong>Chất liệu</strong></p><ul><li>70% polyester, 25% rayon, 5% spandex.</li><li>Định lượng vải 195 GSM.</li><li>Chống nhăn, thoáng khí, mềm mại, kháng mùi, co giãn, đứng phom.</li></ul>')),
(@product, @care, JSON_OBJECT('vi', '<ul><li>Giặt máy ở chế độ nhẹ hoặc giặt tay.</li><li>Nước tối đa 40°C.</li><li>Giặt chung với đồ cùng màu, không dùng thuốc tẩy.</li><li>Sấy và ủi ở nhiệt độ thường.</li></ul><p>Áo có thêu tên cần thêm thời gian may thêu, thường khoảng 7 ngày.</p>')),
(@product, @spec, JSON_OBJECT('vi', '<p>Người mẫu nữ trong ảnh cao 165 cm, nặng 48 kg, mặc size M. Nếu cần size 3XL hoặc chưa chắc size, hãy liên hệ MedUC để được tư vấn số đo.</p><p><img src="https://cdn.meduc.vn/media/meduc-blouse-20261126/meduc-blouse-bang-size-nu.jpg" alt="Bảng size bộ scrubs nữ"></p><p><img src="https://cdn.meduc.vn/media/meduc-blouse-20261126/meduc-blouse-bang-size-nam.jpg" alt="Bảng size bộ scrubs nam"></p>')),
(@product, @fee, '35000');

-- Mã hàng: bỏ các mã minh hoạ cũ, tạo 24 mã mới
DELETE FROM products_item_attribute WHERE product_id = @product
  AND product_item_id IN (SELECT id FROM products_item WHERE product_id = @product AND deleted = 0);
UPDATE products_item SET deleted = 1, status = 0 WHERE product_id = @product AND deleted = 0;

DROP TEMPORARY TABLE IF EXISTS blouse_combo;
CREATE TEMPORARY TABLE blouse_combo (
  code VARCHAR(64), fit_code VARCHAR(50), color_code VARCHAR(50), size_code VARCHAR(50), images TEXT, position INT
) DEFAULT CHARSET = utf8mb4;
INSERT INTO blouse_combo (code, fit_code, color_code, size_code, images, position)
SELECT CONCAT('MEDUC-BLOUSE-', f.tag, '-', c.tag, '-', z.tag), f.code, c.code, z.code,
  CONCAT('["\\/media\\/meduc-blouse-20261126\\/meduc-blouse-scrubs-', f.slug, '-', c.slug, '-1.jpg",',
         '"\\/media\\/meduc-blouse-20261126\\/meduc-blouse-scrubs-', f.slug, '-', c.slug, '-2.jpg",',
         '"\\/media\\/meduc-blouse-20261126\\/meduc-blouse-scrubs-', f.slug, '-', c.slug, '-3.jpg",',
         '"\\/media\\/meduc-blouse-20261126\\/meduc-blouse-scrubs-', f.slug, '-', c.slug, '-4.jpg",',
         '"\\/media\\/meduc-blouse-20261126\\/meduc-blouse-scrubs-', f.slug, '-', c.slug, '-5.jpg"]'),
  f.ord * 100 + c.ord * 10 + z.ord
FROM (SELECT 'blouse_nu' code, 'NU' tag, 'nu' slug, 1 ord UNION ALL SELECT 'blouse_nam', 'NAM', 'nam', 2) f
JOIN (SELECT 'mau_5e6a50' code, 'XR' tag, 'xanh-reu' slug, 1 ord UNION ALL SELECT 'mau_5c6068', 'XC', 'xam-chi', 2) c
JOIN (SELECT 'blouse_s' code, 'S' tag, 1 ord UNION ALL SELECT 'blouse_m', 'M', 2 UNION ALL SELECT 'blouse_l', 'L', 3
      UNION ALL SELECT 'blouse_xl', 'XL', 4 UNION ALL SELECT 'blouse_xxl', 'XXL', 5 UNION ALL SELECT 'blouse_3xl', '3XL', 6) z;

INSERT INTO products_item (product_id, code, price, discount_percent, price_special, time_start_special, time_end_special, images, quantity_available, position, status, deleted)
SELECT @product, code, 700000, 0, NULL, NULL, NULL, images, 20, position, 1, 0 FROM blouse_combo ORDER BY position;

INSERT INTO products_item_attribute (product_id, product_item_id, attribute_id, value)
SELECT @product, i.id, @fit, o.id FROM blouse_combo b
JOIN products_item i ON i.product_id = @product AND i.deleted = 0 AND i.code = b.code
JOIN attributes_options o ON o.attribute_id = @fit AND o.code = b.fit_code AND o.deleted = 0
UNION ALL
SELECT @product, i.id, @color, o.id FROM blouse_combo b
JOIN products_item i ON i.product_id = @product AND i.deleted = 0 AND i.code = b.code
JOIN attributes_options o ON o.attribute_id = @color AND o.code = b.color_code AND o.deleted = 0
UNION ALL
SELECT @product, i.id, @size, o.id FROM blouse_combo b
JOIN products_item i ON i.product_id = @product AND i.deleted = 0 AND i.code = b.code
JOIN attributes_options o ON o.attribute_id = @size AND o.code = b.size_code AND o.deleted = 0;
DROP TEMPORARY TABLE blouse_combo;

-- Ẩn áo tay dài minh hoạ AI (sản phẩm 500); bật lại bằng status = 1.
UPDATE products SET status = 0, updated = @now WHERE id = 500;
UPDATE products SET updated = @now WHERE id = @product;

-- Kiểm tra: phải ra 24 mã, mỗi mã đủ 3 thuộc tính
SELECT COUNT(*) AS skus,
       SUM((SELECT COUNT(*) FROM products_item_attribute a WHERE a.product_item_id = i.id) = 3) AS complete
FROM products_item i WHERE i.product_id = @product AND i.deleted = 0;
COMMIT;
