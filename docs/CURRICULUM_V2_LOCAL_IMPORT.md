# Thay dữ liệu luyện thi local bằng lộ trình 108 môn

Ngày thực hiện: 17/10/2026. Phạm vi: web MedUC trên `localhost:8080`, checkout
`meduc-production-baseline` (nhánh `production`), database MariaDB local trên
cổng 3307. Database nguồn `fhd_quiz_source` là MySQL local trên cổng 3308.

## Dữ liệu đã thay

- Dọn 88 khóa luyện thi và 2.033 đề `local-draft` cũ cùng các dòng liên kết.
  Trong dữ liệu local có một lượt ghi danh và một bài nộp thử thuộc khóa cũ;
  hai dòng này được giữ trong bản sao lưu SQL trước khi dọn.
- Nạp 108 khóa luyện thi từ `mon_v2` đã duyệt, gồm 804 chương và 2.971 bài.
  Mỗi khóa có một chương Tổng ôn và một bài Tổng ôn. Trong đó có 2.863 bài
  kiến thức và 108 bài Tổng ôn.
- Dữ liệu khóa học được lưu theo định dạng `products_attribute.attribute_id=11`
  mà trang web hiện dùng. Mã chương/bài của lộ trình được giữ trong `code`.
  Bảng mới `curriculum_v2_courses` ánh xạ mã môn nguồn với `products.id`.
- 108 khóa còn ở trạng thái nội bộ (`status=0`, `draft=1`,
  `exam_prep_courses.staff_only=1`), chưa xuất hiện với học viên.

## Đề thử đầu tiên

Script `scripts/import_curriculum_v2_first_exam.py` nạp đề nguồn `2431`
“2020 - Dược - Đề thi cuối kỳ” vào bài Tổng ôn của môn `MV2-S001`
“Sinh học - Di truyền”. Trên web local: khóa `products.id=316`,
đề `quizs.id=2715`. Đề có 40 câu và 160 lựa chọn.

Đáp án được sao chép từ `question_options.is_correct`; giải thích AI nằm trong
phần giải thích câu và trong dữ liệu từng lựa chọn. Câu hỏi, đáp án và giải thích
gốc không bị sửa trên DB nguồn. Đề cũng ở trạng thái nội bộ
(`quiz_exam_metadata.staff_only=1`, `status=0`, `draft=1`).

## Script và sao lưu

Chạy ở thư mục checkout `production`:

```sh
python3 scripts/curriculum_v2_local.py
python3 scripts/curriculum_v2_local.py --apply --backup /Users/Shared/architecture/artifacts/meduc-local-backups/before-curriculum-v2-20261017-full.sql.gz
python3 scripts/import_curriculum_v2_first_exam.py
python3 scripts/import_curriculum_v2_first_exam.py --apply
```

Hai script kiểm tra dữ liệu nguồn và có thể chạy lại: lần sau chỉ xác nhận
108 khóa và đề đã nạp trùng khớp. Lệnh `--apply` của script chuyển lộ trình
yêu cầu bản sao lưu đầy đủ nằm ngoài web root.

Bản sao lưu toàn bộ DB local trước khi thay:
`/Users/Shared/architecture/artifacts/meduc-local-backups/before-curriculum-v2-20261017-full.sql.gz`
(SHA-256 `7ce51344084cd0d418e91c895ea092ac1d8c3037c6c7628298edbb15bc3c83bc`).
