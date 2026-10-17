<?php
declare(strict_types=1);

use Migrations\AbstractMigration;

class Migration45 extends AbstractMigration
{
    public function up()
    {
        if ($this->hasTable('course_contributions')) return;
        $this->execute("CREATE TABLE course_contributions (
            id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            customer_id BIGINT UNSIGNED NOT NULL,
            product_id BIGINT UNSIGNED NOT NULL,
            lesson_number INT UNSIGNED NULL,
            quiz_id BIGINT UNSIGNED NULL,
            question_number INT UNSIGNED NULL,
            type VARCHAR(24) NOT NULL,
            suggested_answer VARCHAR(255) NULL,
            content TEXT NOT NULL,
            photo_files TEXT NULL,
            status VARCHAR(16) NOT NULL DEFAULT 'new',
            admin_note TEXT NULL,
            reviewed_by BIGINT UNSIGNED NULL,
            reviewed_at INT UNSIGNED NULL,
            created INT UNSIGNED NOT NULL,
            updated INT UNSIGNED NOT NULL,
            PRIMARY KEY (id),
            KEY idx_contribution_status_created (status, created),
            KEY idx_contribution_course_quiz (product_id, quiz_id),
            KEY idx_contribution_customer (customer_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    }

    public function down()
    {
        // Preserve submitted feedback; reverting application code must not erase it.
    }
}
