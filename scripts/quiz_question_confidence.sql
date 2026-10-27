CREATE TABLE IF NOT EXISTS quiz_question_confidence (
 quiz_answer_id INT NOT NULL,
 question_index INT UNSIGNED NOT NULL,
 question_key CHAR(64) NOT NULL,
 confidence VARCHAR(16) NOT NULL,
 created INT NOT NULL,
 updated INT NOT NULL,
 PRIMARY KEY (quiz_answer_id, question_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
