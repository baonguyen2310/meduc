-- Idempotent setup for the MedUC teacher exam workspace.
CREATE TABLE IF NOT EXISTS teacher_course_access (
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  PRIMARY KEY (user_id, product_id),
  KEY product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS facourse_topic_courses (
  topic VARCHAR(180) NOT NULL,
  product_id INT NOT NULL,
  PRIMARY KEY (topic, product_id),
  KEY product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS facourse_exam_courses (
  exam_id INT NOT NULL,
  product_id INT NOT NULL,
  PRIMARY KEY (exam_id, product_id),
  KEY product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS facourse_word_downloads (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  exam_id INT NOT NULL,
  product_id INT DEFAULT NULL,
  downloaded_at DATETIME NOT NULL,
  KEY user_downloaded (user_id, downloaded_at),
  KEY exam_id (exam_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (name, short_description, permission, created, deleted)
SELECT 'Giáo viên', 'Chỉ xem và tải đề thuộc khóa học được giao', '{}', UNIX_TIMESTAMP(), 0
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'Giáo viên' AND deleted = 0);

-- Clear subject matches. Integrated modules and ambiguous subjects are left for admin review.
CREATE TABLE IF NOT EXISTS meduc_feature_migrations (
  version VARCHAR(80) NOT NULL PRIMARY KEY,
  applied_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TEMPORARY TABLE teacher_exam_initial_topics (
  topic VARCHAR(180) NOT NULL,
  product_id INT NOT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO teacher_exam_initial_topics (topic, product_id) VALUES
('Dược học & Dược lý', 191),
('Dược học & Dược lý', 200),
('Giải phẫu học', 99),
('Giải phẫu học', 201),
('BSNT - Nội khoa', 157),
('BSNT - Nội khoa', 198),
('BSNT - Ngoại khoa', 174),
('Hóa sinh y học', 195),
('Hóa sinh y học', 180),
('Sinh lý học', 48),
('Sinh lý học', 176),
('Ngoại khoa (Cơ sở, Bệnh lý, CK)', 52),
('Ngoại khoa (Cơ sở, Bệnh lý, CK)', 220),
('Sinh lý bệnh - Miễn dịch', 193),
('Nội khoa (Cơ sở, Bệnh lý, Triệu chứng)', 51),
('Nội khoa (Cơ sở, Bệnh lý, Triệu chứng)', 206),
('Mô phôi thai học', 177),
('Lý sinh y học', 199),
('Sinh học & Di truyền y học', 161),
('Sản phụ khoa', 53),
('Ký sinh trùng', 194),
('Giải phẫu bệnh', 203),
('Nhi khoa', 107),
('Vi sinh y học', 204),
('Tiếng Anh chuyên ngành', 101),
('Xác suất thống kê y học', 196),
('Da liễu', 181),
('Hóa học (Đại cương, Hữu cơ, Vô cơ, Phân tích)', 215),
('Kỹ năng lâm sàng & Tiền lâm sàng (Skillslab)', 219),
('Module 6.2: Sinh lý bệnh - Miễn dịch (Y Dược Huế)', 193),
('Module 6.1: Tế bào - Mô phôi (Y Dược Huế)', 177);

INSERT IGNORE INTO facourse_topic_courses (topic, product_id)
SELECT topic, product_id FROM teacher_exam_initial_topics
WHERE NOT EXISTS (SELECT 1 FROM meduc_feature_migrations WHERE version = 'teacher-exams-initial-topics-20261010');

INSERT IGNORE INTO meduc_feature_migrations (version, applied_at)
VALUES ('teacher-exams-initial-topics-20261010', NOW());

DROP TEMPORARY TABLE teacher_exam_initial_topics;
