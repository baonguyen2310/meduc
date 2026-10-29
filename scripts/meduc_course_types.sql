-- Run once before deploying CourseTypes; MariaDB additive, repeatable schema migration.
ALTER TABLE products ADD COLUMN IF NOT EXISTS course_kind VARCHAR(24) NULL;
ALTER TABLE products ADD INDEX IF NOT EXISTS idx_course_kind (course_kind,deleted,status);
ALTER TABLE quizs ADD COLUMN IF NOT EXISTS fa_only TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE quizs ADD COLUMN IF NOT EXISTS course_only TINYINT(1) NOT NULL DEFAULT 0;
CREATE TABLE IF NOT EXISTS course_quiz_slots (
  product_id INT NOT NULL,
  lesson_code VARCHAR(255) NOT NULL,
  slot TINYINT UNSIGNED NOT NULL,
  quiz_id INT NOT NULL,
  PRIMARY KEY (product_id,lesson_code,slot),
  UNIQUE KEY quiz_owner (quiz_id),
  CONSTRAINT slot_two_only CHECK (slot IN (1,2))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
UPDATE products p JOIN curriculum_v2_courses c ON c.product_id=p.id SET p.course_kind='fa';
UPDATE products p SET p.course_kind='knowledge'
WHERE p.course_kind IS NULL AND p.deleted=0 AND (
 p.main_category_id=50 OR EXISTS(SELECT 1 FROM categories c WHERE c.id=p.main_category_id AND c.path_id LIKE '%|50|%')
 OR EXISTS(SELECT 1 FROM categories_product cp JOIN categories c ON c.id=cp.category_id WHERE cp.product_id=p.id AND (c.id=50 OR c.path_id LIKE '%|50|%')));
UPDATE quizs q JOIN quiz_exam_metadata m ON m.quiz_id=q.id SET q.fa_only=1 WHERE m.source_system IN ('facourse','meduc-source-v2','curriculum-v2-lesson');
UPDATE quizs q JOIN course_quiz_slots s ON s.quiz_id=q.id SET q.course_only=1;
-- All quizzes attached to a Fa course are also tagged by the companion PHP runner.
