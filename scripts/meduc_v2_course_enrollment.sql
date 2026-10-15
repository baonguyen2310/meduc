-- Course enrollment: who may study a course (its paid lessons and quizzes) on the website.
--   New students get a row in course_enrollments, made two ways:
--   - automatically when an order with the course is fully paid (OrdersTable::updateAfterPayment, source = order);
--     if that order later stops being fully paid (a payment is cancelled), the row is paused again;
--   - by hand in the admin, menu "Ghi danh khoá học" (/admin/course-enrollment, source = admin).
--   Old students keep their access through class rooms (class_rooms.users); nothing here changes them.
--   A student has a course while the row is active (status = 1, deleted = 0) and not past expires_at (NULL = no end).
-- Code also needed on the server: coredaca/src/Model/Table/CourseEnrollmentsTable.php, OrdersTable.php,
--   src/View/Helper/MemberHelper.php (getCourseAccess), the admin CourseEnrollmentController with its templates and
--   webroot/assets/js/pages/course_enrollment.js, config/routes.php and constants_permission.php.
--
-- Run once on the MedUC PHP database, then clear the website cache from the admin bar (it also holds role permissions).
-- Safe to re-run: the table is created only when missing, and roles get the permission only when they lack it.
-- Role 1 (Quản trị viên) gets every right; role 7 (Thêm Học Viên Vào Lớp) gets everything but delete, as for its other
-- menus. Other roles can be given the right in "Nhóm quyền".
-- To go back (only once no student depends on an enrollment):
--   DROP TABLE course_enrollments;
--   UPDATE roles SET permission = JSON_REMOVE(permission, '$.CourseEnrollment') WHERE JSON_EXTRACT(permission, '$.CourseEnrollment') IS NOT NULL;

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS course_enrollments (
  id int(11) NOT NULL AUTO_INCREMENT,
  product_id int(11) NOT NULL COMMENT 'course (products.id)',
  customer_id int(11) NOT NULL COMMENT 'student (customers.id)',
  source varchar(20) NOT NULL DEFAULT 'admin' COMMENT 'admin = enrolled by hand, order = enrolled when the order was paid',
  order_id int(11) DEFAULT NULL COMMENT 'the paid order (orders.id) for source = order',
  expires_at int(11) DEFAULT NULL COMMENT 'unix time the access ends, NULL = no end',
  note varchar(500) DEFAULT NULL,
  status tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = studying, 0 = paused',
  created_by int(11) DEFAULT NULL COMMENT 'admin user (users.id), NULL when made from an order',
  created int(11) DEFAULT NULL,
  updated int(11) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY customer_product (customer_id, product_id),
  KEY product_id (product_id),
  KEY order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE roles
SET permission = JSON_SET(permission, '$.CourseEnrollment', JSON_OBJECT('view', '1', 'add', '1', 'status', '1', 'update', '1', 'delete', '1'))
WHERE id = 1 AND JSON_VALID(permission) AND JSON_EXTRACT(permission, '$.CourseEnrollment') IS NULL;

UPDATE roles
SET permission = JSON_SET(permission, '$.CourseEnrollment', JSON_OBJECT('view', '1', 'add', '1', 'status', '1', 'update', '1'))
WHERE id = 7 AND JSON_VALID(permission) AND JSON_EXTRACT(permission, '$.CourseEnrollment') IS NULL;
