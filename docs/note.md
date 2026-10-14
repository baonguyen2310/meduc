# Ghi chú yêu cầu MedUC

Cập nhật: 14/10/2026. Tài liệu này ghi nhận yêu cầu và hiện trạng để thảo luận tiếp; **chưa triển khai thay đổi chức năng**.

## Vấn đề 1 — Cấu trúc khóa học, nội dung bài và giải thích đáp án

### Yêu cầu đã trao đổi

- Nội dung có ba cấp: **khóa học → chương → bài**. Tùy nội dung, tên có thể là môn/module/khóa học ở cấp 1 và chương/chủ đề/module/giai đoạn ở cấp 2. Chưa chốt việc cho phép cấu hình *nhãn của từng cấp* riêng theo khóa học.
- Mỗi bài có thể có **nhiều video, nhiều bài tập và nhiều tài liệu**; mỗi bài tập gồm nhiều câu hỏi. Bài không bắt buộc phải có đủ cả ba loại nội dung.
- Mỗi câu hỏi vẫn có thể có giải thích chung. Mỗi phương án trả lời có thể có **giải thích riêng**, để phản hồi khác nhau theo phương án người học chọn.
- Đây là nhu cầu dự phòng cho sau này; chưa yêu cầu sửa code ngay.

### Hiện trạng MedUC PHP production

- Khóa học là một sản phẩm. Danh sách chương và bài được lưu theo thứ tự trong `products_attribute` (attribute 11); mục có `chapter_vi = y` là chương, các mục còn lại là bài.
- Mỗi bài hiện đọc **một video** từ `youtube_id_vi`, **một bài tập** từ `quiz_id_vi` và **nhiều tài liệu** từ `filestwo`.
- Giải thích hiện gắn với **câu hỏi** qua `answer_detail_vi`; chưa có trường giải thích riêng cho từng phương án.
- Trong nguồn của 2.033 đề, `detailAnswer` cũng đi theo câu hỏi. Các phương án chứa nội dung và dấu đúng/sai (`isCorrect`), không có giải thích riêng. Vì vậy không thể tự suy ra giải thích cho từng phương án cũ.

### Dự định

- **Chưa cần làm.** Các ý trên được ghi lại để dùng khi quyết định triển khai sau.
- Khi triển khai, cần giữ cho bài và đề hiện có tiếp tục hiển thị/làm bài được, đồng thời cập nhật form quản trị và trang học cho các trường mới.

### Mốc kiểm tra trong code

- `coredaca/plugins/Admin/src/Service/CourseExamLibrary.php`: đọc danh sách bài và giải thích câu hỏi.
- `templates/app01/block/product_detail/view_content.tpl`: hiển thị video, bài tập và tài liệu của bài.
