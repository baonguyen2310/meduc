# Meduc PHP

Ứng dụng Meduc PHP (CakePHP) và bộ 16 trang giao diện nền sáng nằm trong cùng repository. Danh sách trang, nguồn dữ liệu và cách làm mới các bản xuất JSON được ghi tại [hero-light/README.md](hero-light/README.md).

## Chạy cục bộ

1. Sao chép `.env.example` thành `.env` và điền mật khẩu cơ sở dữ liệu, salt và khóa tải tệp. Với volume dữ liệu đã có, dùng đúng tài khoản/mật khẩu của volume đó.
2. Chạy `docker compose up -d --build`.
3. Mở `http://127.0.0.1:8080/masterclass` để xem trang chủ mới. Các tuyến trang còn lại được khai báo trong `coredaca/config/routes.php`.

## Triển khai Meduc PHP trên civo-01

Máy production hiện tại là SSH alias **`civo-01`** (cũng có alias `civo-001`). Không triển khai Meduc lên `uc-01` nữa. Trên Civo, Git checkout nằm ở `/opt/meduc-php/src`, còn Docker Compose chạy từ `/opt/meduc-php/app`; mã đã cập nhật cần được đồng bộ từ `src` sang `app` trước khi kiểm tra bản chạy.

`compose.production.yml` chạy MariaDB riêng và chỉ mở Apache tại `127.0.0.1:8081` trên máy chủ. Caddy trên `civo-01` định tuyến `meducnew.duckdns.org` và `meducv2.duckdns.org` vào cổng này. Domain `meducnew` chuyển riêng đường dẫn `/` sang bản trang chủ mới tại `/masterclass`; domain `meducv2` mở trực tiếp trang chủ PHP gốc. Kho đề Meduc Cao chạy tại `127.0.0.1:3000` và cơ sở dữ liệu `fhd_quiz` ở các container riêng; `meduc.duckdns.org` trỏ vào kho đề này. Caddy nhận cổng 80/443 cho cả ba tên miền. [deploy/Caddyfile.uc-01](deploy/Caddyfile.uc-01) chỉ là bản cấu hình cũ để tham khảo, không phải cấu hình đang dùng trên Civo.

Thông tin bí mật được lấy từ tệp môi trường **ngoài** thư mục ứng dụng, ví dụ `/opt/meduc-php/secrets/meduc.env`. Tệp Google service account được mount từ thư mục bí mật đó. Database dump được chuyển và nhập riêng qua SSH; không commit vào Git. Bộ thư viện PHP `coredaca/vendor` cũng được đồng bộ từ bản Meduc PHP đang chạy vì repository cũ không lưu `composer.lock` và bỏ qua thư mục này. Trên `civo-01`, dùng Docker Compose v2 khi cần tạo lại container:

```sh
cd /opt/meduc-php/app
sudo docker compose --env-file /opt/meduc-php/secrets/meduc.env -f compose.production.yml up -d --build
```

Các trang danh mục hiện dùng JSON xuất từ dữ liệu Meduc. Trang lịch sử làm bài truy vấn dữ liệu theo tài khoản; trang phân cấp bộ đề dùng bản xuất metadata từ Meduc Cao. Trang thanh toán và tiến độ học vẫn là bản xem trước theo mô tả trong `hero-light/README.md`.

## Trang chủ PHP gốc

Trang chủ tại `meducv2.duckdns.org/` dùng `templates/app01/layout/default.tpl` và dữ liệu trang từ database. Header và hero mới nằm trong `templates/app01/element/home/header_hero.tpl`; hai chế độ màu của khu vực này dùng `hero-light/assets/original-home.css`. Nút trăng/mặt trời lưu lựa chọn với khóa `meduc-theme` trong `localStorage`. Các hàng nội dung cũ dưới hero vẫn do database Meduc PHP render; những khu vực đó sẽ được thay giao diện lần lượt.

## Kho 2.033 đề cho giáo viên

Sau khi triển khai mã, chạy một lần `scripts/teacher_exam_access.sql` trên database MedUC PHP. Script tạo nhóm `Giáo viên`, bảng gán giáo viên–khóa học, bảng gán môn/module–khóa học, bảng gán từng đề–khóa học và nhật ký tải Word. Có thể chạy lại script an toàn; các gán do quản trị viên đã sửa sẽ không bị đặt lại.

Đặt `MEDUC_2033_API_KEY` trong file môi trường riêng của máy chủ bằng khóa API của kho đề MedUC Cao. PHP chỉ gọi API này ở phía server. `MEDUC_2033_API_BASE` mặc định là `https://meduc.duckdns.org/api/2033`. Trên Civo, người có quyền root có thể chạy `bash /opt/meduc-php/src/scripts/deploy_teacher_exams_civo.sh` để kéo mã, đồng bộ các file thay đổi, chạy migration, tạo lại container PHP và kiểm tra trang đăng nhập.

Trang làm việc: `/admin/teacher-exams`. Quản trị viên thấy đủ 2.033 đề, tạo tài khoản quản trị với nhóm `Giáo viên` tại `/admin/user/add`, rồi gán các khóa được dạy trên trang làm việc. Giáo viên chỉ thấy và tải Word đề thuộc khóa đã được gán. Quyền này được kiểm tra lại trên từng yêu cầu xem đề và tải file; giáo viên không vào được các trang quản trị khác.

24 môn/module có liên hệ rõ với khóa học được gán sẵn, bao phủ 1.349 đề trong danh mục kiểm tra ngày 10/10/2026. 684 đề còn lại vẫn có thể xem/tải bằng tài khoản quản trị và chỉ hiện với giáo viên sau khi quản trị viên gán môn/module hoặc đề riêng. Danh mục và số câu trên thẻ lấy từ bản xuất JSON đã đối chiếu với API (131.940 câu); nội dung đề và file Word lấy trực tiếp từ API MedUC Cao. Word bao gồm câu hỏi, lựa chọn, đáp án, lời giải và các ảnh đã đồng bộ; HTML phức tạp trong nội dung được chuyển thành văn bản có thể chỉnh sửa.
