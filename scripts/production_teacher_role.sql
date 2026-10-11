-- Register the teacher account group on the original meduc.vn production database.
-- This migration only creates the role; course access and exam permissions are separate work.
INSERT INTO roles (name, short_description, permission, created, deleted)
SELECT 'Giáo viên', 'Tài khoản giáo viên MedUC', '{}', UNIX_TIMESTAMP(), 0
WHERE NOT EXISTS (
    SELECT 1 FROM roles WHERE name = 'Giáo viên' AND deleted = 0
);
