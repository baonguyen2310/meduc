-- Production: a course product may have several teachers; a teacher may teach several courses.
-- This is intentionally separate from the obsolete classroom tables.
CREATE TABLE IF NOT EXISTS teacher_course_access (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (user_id, product_id),
    KEY product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
