-- Run once against the MedUC application database. Uploaded photos live in
-- coredaca/tmp/course-contributions and are served only by the admin controller.
CREATE TABLE IF NOT EXISTS course_contributions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  lesson_number INT UNSIGNED DEFAULT NULL,
  quiz_id BIGINT UNSIGNED DEFAULT NULL,
  question_number INT UNSIGNED DEFAULT NULL,
  type VARCHAR(24) NOT NULL,
  suggested_answer VARCHAR(255) DEFAULT NULL,
  content TEXT NOT NULL,
  photo_files TEXT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'new',
  admin_note TEXT NULL,
  reviewed_by BIGINT UNSIGNED DEFAULT NULL,
  reviewed_at INT UNSIGNED DEFAULT NULL,
  created INT UNSIGNED NOT NULL,
  updated INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  KEY idx_contribution_status_created (status, created),
  KEY idx_contribution_course_quiz (product_id, quiz_id),
  KEY idx_contribution_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
