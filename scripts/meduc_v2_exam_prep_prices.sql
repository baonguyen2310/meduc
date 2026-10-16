-- Prices of the exam-prep courses (exam_prep_courses, Khóa học > Khóa luyện thi): 1.200.000đ, on sale for 499.000đ.
--   Only courses still without a price (0đ, as scripts/import_private_exams.php made them) get it, so a price the admin
--   has set stays. The sale has no end date (time_start_special and time_end_special empty), as for the other courses;
--   discount_percent is worked out the way the admin form does it: round((price - sale) / price * 100) = 58.
-- Run after scripts/publish_exam_prep_courses.php, then clear the website cache. Safe to re-run.
-- To go back (only rows still at these prices):
--   UPDATE products_item pi JOIN exam_prep_courses e ON e.product_id = pi.product_id
--   SET pi.price = 0, pi.price_special = NULL, pi.discount_percent = 0
--   WHERE pi.price = 1200000 AND pi.price_special = 499000;

SET NAMES utf8mb4;

UPDATE products_item pi
JOIN exam_prep_courses e ON e.product_id = pi.product_id
SET pi.price = 1200000, pi.price_special = 499000, pi.discount_percent = 58,
    pi.time_start_special = NULL, pi.time_end_special = NULL
WHERE pi.deleted = 0 AND (pi.price IS NULL OR pi.price = 0);
