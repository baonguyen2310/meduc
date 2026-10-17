# Đóng góp đề, đáp án và lộ trình

- Dữ liệu nằm riêng trong `course_contributions`; góp ý không tự sửa câu hỏi hay đáp án gốc.
- Tạo bảng bằng migration `45_Migration45.php`, hoặc chạy `scripts/course_contributions.sql` một lần. MariaDB local đã có bảng.
- Tạo thư mục `coredaca/tmp/course-contributions` và cấp quyền ghi cho tiến trình PHP. Ảnh nằm ngoài webroot và chỉ admin xem qua `/admin/course-contributions/photo/{id}/{number}`.
- Email thông báo dùng địa chỉ quản trị trong cài đặt Email của MedUC. Khi truy cập qua `localhost` hoặc `127.0.0.1`, bản local chỉ lưu góp ý và không gửi email thật.
- Admin xem và xử lý tại `/admin/course-contributions`. Chỉ quản trị viên được truy cập; giáo viên và học viên không đọc được danh sách.
