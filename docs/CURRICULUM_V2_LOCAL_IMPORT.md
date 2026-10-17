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
- 108 khóa được nạp ban đầu ở trạng thái nội bộ. Sau đó chạy
  `scripts/publish_curriculum_v2_catalog.py --apply` để hiện danh sách và
  lộ trình môn trên `/khoa-luyen-thi` (`status=1`, `draft=0`,
  `products_item.status=1`, `exam_prep_courses.staff_only=0`).
  Ban đầu chưa mở đề hoặc câu hỏi cho học viên.

## Đề thử đầu tiên

Script `scripts/import_curriculum_v2_first_exam.py` nạp đề nguồn `2431`
“2020 - Dược - Đề thi cuối kỳ” vào bài Tổng ôn của môn `MV2-S001`
“Sinh học - Di truyền”. Trên web local: khóa `products.id=316`,
đề `quizs.id=2715`. Đề có 40 câu và 160 lựa chọn.

Đáp án được sao chép từ `question_options.is_correct`; giải thích AI nằm trong
phần giải thích câu và trong dữ liệu từng lựa chọn. Câu hỏi, đáp án và giải thích
gốc không bị sửa trên DB nguồn. Đề được nạp ban đầu ở trạng thái nội bộ.

## Bài tập từng bài và đề Tổng ôn

Script `scripts/create_curriculum_v2_lesson_quizzes.py` tạo một bản ghi bài tập
cho mỗi bài trong 108 môn: 2.970 bản ghi mới cộng với đề Tổng ôn đã có, đủ
2.971 bài. Bài tập chưa có câu hỏi vẫn ở trạng thái nội bộ và hiện là
“đang được cập nhật” trên trang khóa học, không có nút bắt đầu làm.

Trong môn Sinh học - Di truyền, 29 câu của đề đầu tiên được gắn vào bảy bài
đúng theo ánh xạ từ DB nguồn. Gồm 16 câu khớp trực tiếp và 13 câu liên quan
ít; 11 câu chưa có bài phù hợp chỉ giữ trong đề Tổng ôn. Cả bảy bài tập đã
có câu hỏi và đề Tổng ôn 40 câu chỉ mở qua trình làm bài của khóa cho học
viên đã ghi danh; khách chưa ghi danh nhận HTTP 403. Đề vẫn ở trạng thái
`quizs.status=0`, `draft=1` để không xuất hiện như một đề công khai riêng lẻ.
Chỉ cờ `quiz_exam_metadata.staff_only` của tám bài có câu được chuyển về 0.

## Script và sao lưu

Chạy ở thư mục checkout `production`:

```sh
python3 scripts/curriculum_v2_local.py
python3 scripts/curriculum_v2_local.py --apply --backup /Users/Shared/architecture/artifacts/meduc-local-backups/before-curriculum-v2-20261017-full.sql.gz
python3 scripts/import_curriculum_v2_first_exam.py
python3 scripts/import_curriculum_v2_first_exam.py --apply
python3 scripts/publish_curriculum_v2_catalog.py
python3 scripts/publish_curriculum_v2_catalog.py --apply
python3 scripts/create_curriculum_v2_lesson_quizzes.py
python3 scripts/create_curriculum_v2_lesson_quizzes.py --apply --backup /Users/Shared/architecture/artifacts/meduc-local-backups/before-lesson-quizzes-20261017-full.sql.gz
```

Các script có thể chạy lại để xác nhận dữ liệu và trạng thái hiển thị. Lệnh
`--apply` của script chuyển lộ trình yêu cầu bản sao lưu đầy đủ nằm ngoài
web root.

Bản sao lưu toàn bộ DB local trước khi thay:
`/Users/Shared/architecture/artifacts/meduc-local-backups/before-curriculum-v2-20261017-full.sql.gz`
(SHA-256 `7ce51344084cd0d418e91c895ea092ac1d8c3037c6c7628298edbb15bc3c83bc`).

Bản sao lưu toàn bộ DB local trước khi tạo bài tập:
`/Users/Shared/architecture/artifacts/meduc-local-backups/before-lesson-quizzes-20261017-full.sql.gz`
(SHA-256 `d65b691b21fec63aafb91a4fb34cb4553f8a9923ad7225e37f04828db501599f`).
