# Meduc PHP

Ứng dụng Meduc PHP (CakePHP) và bộ 16 trang giao diện nền sáng nằm trong cùng repository. Danh sách trang, nguồn dữ liệu và cách làm mới các bản xuất JSON được ghi tại [hero-light/README.md](hero-light/README.md).

## Chạy cục bộ

1. Sao chép `.env.example` thành `.env` và điền mật khẩu cơ sở dữ liệu, salt và khóa tải tệp. Với volume dữ liệu đã có, dùng đúng tài khoản/mật khẩu của volume đó.
2. Chạy `docker compose up -d --build`.
3. Mở `http://127.0.0.1:8080/masterclass` để xem trang chủ mới. Các tuyến trang còn lại được khai báo trong `coredaca/config/routes.php`.

## Triển khai Meduc PHP

`compose.production.yml` chạy MariaDB riêng và chỉ mở Apache tại `127.0.0.1:8081` trên máy chủ. [deploy/Caddyfile.uc-01](deploy/Caddyfile.uc-01) định tuyến `meducnew.duckdns.org` vào cổng này. Kho đề Meduc Cao tiếp tục chạy tại `127.0.0.1:3000` và cơ sở dữ liệu `fhd_quiz` ở các container riêng. Caddy nhận cổng 80/443 cho cả hai tên miền.

Thông tin bí mật được lấy từ tệp môi trường **ngoài** thư mục ứng dụng, ví dụ `/opt/meduc-php/secrets/meduc.env`. Tệp Google service account được mount từ thư mục bí mật đó. Database dump được chuyển và nhập riêng qua SSH; không commit vào Git. Bộ thư viện PHP `coredaca/vendor` cũng được đồng bộ từ bản Meduc PHP đang chạy vì repository cũ không lưu `composer.lock` và bỏ qua thư mục này. Trên VPS `uc-01`, Compose là chương trình `docker-compose`; chạy bản production bằng:

```sh
docker-compose --env-file /opt/meduc-php/secrets/meduc.env -f compose.production.yml up -d --build
```

Các trang danh mục hiện dùng JSON xuất từ dữ liệu Meduc. Trang lịch sử làm bài truy vấn dữ liệu theo tài khoản; trang phân cấp bộ đề dùng bản xuất metadata từ Meduc Cao. Trang thanh toán và tiến độ học vẫn là bản xem trước theo mô tả trong `hero-light/README.md`.
