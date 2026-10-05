# Meduc — giao diện nền sáng

Trang số 1 trong bộ 16 trang giao diện Meduc. Bố cục lấy cảm hứng từ MasterClass: thanh điều hướng hai tầng, hero với dải chân dung, chọn mục tiêu học, thẻ khóa học, khám phá theo môn, phản hồi và FAQ. Nội dung là của Meduc; nền, khu nội dung và phần lớn thành phần dùng bảng màu sáng.

Trang số 2 là `about.html`: giới thiệu Meduc theo năm phần (tên gọi, khởi nguồn, cách học, đội ngũ, tầm nhìn). Bố cục hero hai cột và thanh tiến trình dựa trên ảnh tham chiếu trang giới thiệu MasterClass. Nội dung dựa trên trang giới thiệu Meduc hiện tại. Ảnh chân dung và cảnh học tập chỉ dùng để minh họa, không gắn với danh tính giảng viên.

Trang số 3 là `feedback.html`: đánh giá chữ dạng carousel cùng thư viện video có lọc theo môn và nút xem thêm. Bố cục thẻ nhận xét đặt chồng lên ảnh theo khu vực phản hồi MasterClass; ảnh học tập trong hero là hình minh họa.

Trang số 4 là `courses.html`: danh sách khóa học đang mở, có tìm kiếm, lọc theo nhóm, sắp xếp và nút xem thêm. Thanh nhóm môn và dải thẻ ảnh lấy nhịp bố cục từ trang danh mục MasterClass; nội dung khóa học là của Meduc.

Trang số 5 là `course-detail.html`: chi tiết của từng khóa trong danh mục đang mở. Hero chia đôi, khung đăng ký, thẻ chủ đề và đề cương mở theo chương lấy cảm hứng từ trang chi tiết MasterClass. Tên khóa, ảnh bìa, số chương và bài, đề cương đều lấy từ dữ liệu Meduc. Hình chân dung chỉ minh họa giao diện, không đại diện giảng viên. Nút thanh toán mở trang số 12; liên kết đề cương vẫn dẫn tới trang khóa học Meduc.

Trang số 6 là `books.html`: danh sách sách Y khoa đang bật. Bố cục chữ lớn, thanh chủ đề và dải nội dung lấy cảm hứng từ trang Articles của MasterClass; bìa sách, tên và giá là dữ liệu Meduc. Có tìm kiếm, lọc theo môn và giai đoạn học, sắp xếp giá/tên, cùng nút xem thêm. Thẻ sách mở trang chi tiết số 7.

Trang số 7 là `book-detail.html`: chi tiết từng sách đang bật. Bố cục biên tập sáng với bìa lớn, dải ảnh thu nhỏ, ảnh sản phẩm phóng to, thông tin bản in và sách liên quan. Tên, ảnh, giá tham khảo và đường dẫn sản phẩm lấy từ Meduc; nút thanh toán mở trang số 12, còn liên kết thông tin sách mở trang sản phẩm Meduc.

## Xem trang

- Bản PHP tích hợp: `http://127.0.0.1:8080/masterclass` khi chạy Docker Compose của Meduc.
- Bản giới thiệu PHP: `http://127.0.0.1:8080/gioi-thieu-v2`. Tuyến `/gioi-thieu` cũ vẫn có thể dùng để đối chiếu nội dung.
- Bản phản hồi PHP: `http://127.0.0.1:8080/phan-hoi-hoc-vien-v2`. Tuyến `/phan-hoi-hoc-vien` cũ vẫn có thể dùng để đối chiếu.
- Bản danh sách khóa học PHP: `http://127.0.0.1:8080/khoa-hoc-v2`. Tuyến `/khoa-hoc` cũ vẫn có thể dùng để đối chiếu.
- Bản chi tiết khóa học PHP: `http://127.0.0.1:8080/khoa-hoc-chi-tiet-v2?course=sinh-ly-1-2-co-ban-chuyen-sau`. Tham số `course` nhận slug của 33 khóa đang mở.
- Bản danh sách sách PHP: `http://127.0.0.1:8080/sach-y-khoa-v2`. Tuyến `/sach-y-khoa` cũ vẫn có thể dùng để đối chiếu.
- Bản chi tiết sách PHP: `http://127.0.0.1:8080/chi-tiet-sach-v2?book=83`. Tham số `book` nhận ID hoặc slug của 46 sách đang bật.
- Bản thanh toán PHP: `http://127.0.0.1:8080/thanh-toan-v2?course=48` hoặc `http://127.0.0.1:8080/thanh-toan-v2?book=66`.
- Bản HTML độc lập: chạy `python3 -m http.server 4176 --bind 127.0.0.1 --directory /Users/Shared/architecture/meduc/hero-light`, rồi mở `http://127.0.0.1:4176/index.html`.
- Bản giới thiệu HTML: `http://127.0.0.1:4176/about.html`.
- Bản phản hồi HTML: `http://127.0.0.1:4176/feedback.html`.
- Bản danh sách khóa học HTML: `http://127.0.0.1:4176/courses.html`.
- Bản chi tiết khóa học HTML: `http://127.0.0.1:4176/course-detail.html?course=sinh-ly-1-2-co-ban-chuyen-sau`.
- Bản danh sách sách HTML: `http://127.0.0.1:4176/books.html`.
- Bản chi tiết sách HTML: `http://127.0.0.1:4176/book-detail.html?book=83`.
- Bản thanh toán HTML: `http://127.0.0.1:4176/checkout.html?course=48`.

`hero-light/index.html` là nguồn giao diện. Chạy `python3 scripts/sync_homepage_template.py` từ thư mục gốc Meduc sau mỗi lần sửa nguồn để cập nhật `templates/app01/Masterclass/index.tpl`. Template PHP dùng tài nguyên trong `/hero-light/assets/` và liên kết tới các tuyến Meduc hiện có. Trang chủ không cần truy vấn sản phẩm để tải giao diện.

`hero-light/about.html` là nguồn của trang giới thiệu. Chạy `python3 scripts/sync_about_template.py` để cập nhật `templates/app01/Masterclass/about.tpl`.

`hero-light/feedback.html` là nguồn của trang phản hồi. Chạy `python3 scripts/sync_feedback_template.py` để cập nhật `templates/app01/Masterclass/feedback.tpl`. Danh sách video nằm trong `hero-light/assets/feedback.js`.

`hero-light/courses.html` là nguồn của trang danh sách khóa học. Chạy `python3 scripts/sync_courses_template.py` để cập nhật `templates/app01/Masterclass/courses_v2.tpl`. Chạy `python3 scripts/export_course_catalog.py` khi dữ liệu khóa học thay đổi để tạo lại `hero-light/assets/catalog-data.json` từ cơ sở dữ liệu Meduc đang chạy trong Docker Compose. Bộ lọc hoạt động trên bản xuất này; đây là giao diện xem trước, chưa truy vấn cơ sở dữ liệu tại mỗi lượt xem.

`hero-light/course-detail.html` là nguồn của trang chi tiết khóa học. Chạy `python3 scripts/sync_course_detail_template.py` để cập nhật `templates/app01/Masterclass/course_detail_v2.tpl`. Chạy `python3 scripts/export_course_outline.py` sau khi cập nhật bản kiểm kê Markdown hoặc danh mục để tạo lại `hero-light/assets/course-outline.json`. Mỗi đề cương được kiểm tra khớp tổng chương và bài với danh mục.

`hero-light/books.html` là nguồn của trang danh sách sách. Chạy `python3 scripts/sync_books_template.py` để cập nhật `templates/app01/Masterclass/books_v2.tpl`. Chạy `python3 scripts/export_book_catalog.py` khi dữ liệu sách hoặc giá thay đổi để tạo lại `hero-light/assets/book-catalog.json` từ cơ sở dữ liệu Meduc trong Docker Compose. Đây là bản xem trước dùng dữ liệu xuất tĩnh; giá mới nhất nằm trên trang sản phẩm Meduc.

`hero-light/book-detail.html` là nguồn của trang chi tiết sách. Chạy `python3 scripts/sync_book_detail_template.py` để cập nhật `templates/app01/Masterclass/book_detail_v2.tpl`. Chạy `python3 scripts/export_book_detail_data.py` khi dữ liệu sách, giá hoặc ảnh thay đổi để tạo lại `hero-light/assets/book-detail-data.json` từ cơ sở dữ liệu Meduc trong Docker Compose.

`hero-light/checkout.html` là nguồn của trang thanh toán xem trước. Chạy `python3 scripts/export_checkout_catalog.py` sau khi danh mục hoặc giá đổi; script xuất giá của 33 khóa học và 46 sách đang bật vào `hero-light/assets/checkout-catalog.json`. Chạy `python3 scripts/sync_checkout_template.py` để cập nhật `templates/app01/Masterclass/checkout_v2.tpl`.

## Dữ liệu và hình ảnh

- Tên khóa học, trạng thái đang bật và số chương/bài trong các thẻ lấy từ bản xuất `danh-sach-63-khoa-hoc-chuong-bai.md`, dựa trên dump Meduc ngày 20/09/2026. Đây là nội dung tĩnh cho bản thiết kế; thay đổi sản phẩm sau ngày đó cần cập nhật lại.
- Trích dẫn phản hồi lấy từ dữ liệu đánh giá Meduc, bỏ thông tin cá nhân.
- Chân dung trong hero và các thẻ là ảnh minh họa sẵn có của bộ thiết kế, không xác nhận danh tính giảng viên của khóa học.
- Trang phản hồi dùng bốn nhận xét khác nhau trong các đánh giá 5/5 đã duyệt của bảng `comments` (không hiển thị tên, email, điện thoại), cùng 18 video công khai từ `/phan-hoi-hoc-vien`. Ảnh xem trước video lấy từ YouTube; nếu ảnh lỗi, thẻ có nền chữ thay thế. Liên kết khóa học dùng slug của sản phẩm đang bật trong bảng `links`, vì hai slug trên trang phản hồi cũ đang chuyển về trang chủ.
- Trang danh sách khóa học dùng 33 sản phẩm khóa học đang bật trong cơ sở dữ liệu cục bộ; tên, trạng thái, danh mục, đường dẫn chi tiết và ảnh bìa lấy từ dữ liệu sản phẩm. Số chương và bài dựa trên bản kiểm kê ngày 20/09/2026. Ảnh bìa tải từ CDN Meduc, có thẻ nền chữ thay thế nếu ảnh lỗi. Khóa đã tắt không hiện trên danh mục công khai. Các thẻ mở trang chi tiết mới tại `/khoa-hoc-chi-tiet-v2`.
- Trang danh sách sách dùng 46 sản phẩm sách đang bật trong cơ sở dữ liệu cục bộ, lọc theo danh mục sách Y khoa và các danh mục con. 31 sản phẩm đã tắt không hiển thị. Bản xuất gồm tên, ảnh bìa, danh mục, URL và giá; giá khuyến mãi chỉ dùng khi dương và thấp hơn giá gốc. Ảnh bìa tải từ CDN Meduc và có nền chữ thay thế khi lỗi. Thẻ sách mở trang chi tiết mới; nút thanh toán trên trang chi tiết mở trang số 12.
- Bản HTML ở cổng 4176 dẫn sang các demo `studio-bright` ở cổng 4174 cho những trang chưa làm. Tuyến PHP `/masterclass` dẫn tới các trang Meduc hiện có và `/member/login`.

## Tương tác và kiểm tra

- Menu, tìm kiếm khóa học, chọn nhiều mục tiêu, gợi ý lộ trình, tạm dừng dải ảnh, lọc nhóm môn và FAQ hoạt động bằng JavaScript hoặc HTML gốc.
- Đã xem ở desktop 1440 px và mobile 390 px: ảnh tải đủ, không tràn ngang ở mobile.
- Tuyến PHP `/masterclass` trả HTTP 200; các tuyến khóa học, tài nguyên và đăng nhập được kiểm tra qua bản Docker Compose cục bộ. Bộ điều khiển PHP qua `php -l` trong container.
- Tuyến PHP `/phan-hoi-hoc-vien-v2` trả HTTP 200; carousel, lọc môn và xem thêm đã kiểm tra trong trình duyệt. Bản mobile 390 px không tràn ngang; các ảnh video và liên kết khóa học được kiểm tra.
- Tuyến PHP `/khoa-hoc-v2` trả HTTP 200; 33 ảnh bìa trả HTTP 200. Tìm kiếm, lọc nhóm, sắp xếp và xem thêm đã được thử trong trình duyệt. Bản mobile 390 px không tràn ngang.
- Tuyến PHP `/khoa-hoc-chi-tiet-v2` trả HTTP 200; dữ liệu đề cương của 33 khóa khớp tổng số chương/bài. Hero, thẻ đăng ký, đề cương, khóa liên quan và liên kết từ trang số 4 được kiểm tra trên trình duyệt. Bản mobile 390 px không tràn ngang; khóa thiếu dữ liệu đề cương có trạng thái riêng.
- Tuyến PHP `/sach-y-khoa-v2` và JSON sách trả HTTP 200; cả 46 ảnh bìa và một URL sản phẩm tiêu biểu trả HTTP 200. Tìm kiếm, lọc môn, lọc giai đoạn, xóa bộ lọc và xem thêm đã thử trong trình duyệt. Bản mobile 390 px không tràn ngang.

## Trang số 8 — Danh sách tài liệu

- Xem bản PHP tại `http://127.0.0.1:8080/tai-lieu-hoc-tap-v2`; bản HTML độc lập là `hero-light/documents.html`.
- Trang lấy nhịp bố cục tìm kiếm và nội dung từ trang Learning Toolkit của MasterClass, dùng nền sáng và dữ liệu tài liệu Meduc.
- Có 198 tài liệu đang bật thuộc danh mục `Tài liệu học tập` và các danh mục con. Mỗi mục có ảnh, slug và ít nhất một tệp đính kèm. Bộ lọc năm học và môn dùng danh mục cùng nhãn rõ ràng trong tên; sáu tài liệu ký sinh trùng có nhãn năm 1 trong tên cũng được xếp vào năm 1.
- `scripts/export_document_catalog.py` tạo `hero-light/assets/document-catalog.json` từ cơ sở dữ liệu đang chạy. Chạy lại sau khi dữ liệu đổi. `scripts/sync_documents_template.py` cập nhật `templates/app01/Masterclass/documents_v2.tpl` từ HTML nguồn.
- Thẻ tài liệu dẫn tới trang chi tiết số 9. Tuyến PHP, JSON, một URL chi tiết và cả 198 ảnh trả HTTP 200. Tìm kiếm, lọc năm/môn, xóa lọc, xem thêm và bản mobile 390 px đã kiểm tra.

## Trang số 9 — Chi tiết tài liệu

- Xem bản PHP tại `http://127.0.0.1:8080/tai-lieu-chi-tiet-v2?resource=nam-2-thong-ke-y-hoc-giao-trinh-hoc-tap`; bản HTML độc lập là `hero-light/resource-detail.html` với cùng tham số.
- Trang hiển thị tiêu đề, ảnh, phần giới thiệu, mục lục nội dung, các tệp đính kèm và ba tài liệu liên quan. Có 196 tài liệu chứa PDF và hai tài liệu chỉ đính kèm ảnh; mọi tệp mở trực tiếp từ CDN Meduc trong tab mới.
- `scripts/export_resource_detail.py` tạo `hero-light/assets/resource-detail-data.json` cho 198 tài liệu đang bật. Chạy lại khi dữ liệu thay đổi. `scripts/sync_resource_detail_template.py` cập nhật `templates/app01/Masterclass/resource_detail_v2.tpl` từ HTML nguồn.
- Dữ liệu nội dung được chuyển thành các khối văn bản an toàn khi xuất; giao diện chỉ chèn văn bản đã escape. Trang danh sách số 8 dẫn trực tiếp tới từng tài liệu của trang này.

## Trang số 10 — Danh sách blog

- Xem bản PHP tại `http://127.0.0.1:8080/blog-v2`; bản HTML độc lập là `hero-light/blog.html`.
- Trang dùng bố cục biên tập sáng lấy cảm hứng từ mục Articles của MasterClass: điều hướng chủ đề, dải ảnh bài chọn lọc, bài tiêu biểu, thẻ gợi ý và thư viện bài viết. Nội dung và ảnh lấy từ Meduc.
- Danh mục gồm 162 bài viết đang bật. Có tìm kiếm không phân biệt dấu tiếng Việt, lọc theo môn/chủ đề, sắp xếp theo ngày hoặc tên, và nút xem thêm. Các thẻ dẫn tới trang chi tiết số 11.
- `scripts/export_blog_catalog.py` tạo `hero-light/assets/blog-catalog.json` từ cơ sở dữ liệu Meduc đang chạy. Chạy lại khi dữ liệu bài viết thay đổi. `scripts/sync_blog_template.py` cập nhật `templates/app01/Masterclass/blog_v2.tpl` từ HTML nguồn.
- Đã kiểm tra tuyến PHP, dữ liệu JSON, tìm kiếm, lọc, sắp xếp, trạng thái không có kết quả, nút xem thêm và bố cục mobile 390 px.

## Trang số 11 — Chi tiết blog

- Xem bản PHP tại `http://127.0.0.1:8080/bai-viet-chi-tiet-v2?post=cach-hoc-giai-phau-hieu-qua-qua-co-the-chinh-minh`; bản HTML độc lập là `hero-light/blog-detail.html` với cùng tham số. Có thể dùng slug `post` hoặc ID `id` của bài.
- Trang dùng bố cục bài viết sáng lấy cảm hứng từ MasterClass: tiêu đề lớn, ảnh bìa, nội dung đọc, mục lục, tiến độ đọc, liên kết sao chép, bài liên quan và lối vào khóa học. Trang số 10 dẫn tới trang này.
- `scripts/export_blog_detail_data.py` tạo `hero-light/assets/blog-detail-data.json` từ cơ sở dữ liệu Meduc đang chạy. Bản xuất gồm đủ 162 bài đang bật, nội dung HTML đã lọc thẻ và URL an toàn; ảnh nhúng trực tiếp dạng `data:image` quá lớn được bỏ khỏi bản xem trước. Chạy lại sau khi dữ liệu bài viết thay đổi. `scripts/sync_blog_detail_template.py` cập nhật `templates/app01/Masterclass/blog_detail_v2.tpl` từ HTML nguồn.
- Đã kiểm tra PHP và JavaScript, tuyến PHP/JSON, một bài có ảnh, một bài thiếu ảnh, một bài có HTML nguồn lớn, đường dẫn không tồn tại, liên kết từ trang số 10 và bố cục mobile 390 px không tràn ngang.

## Trang số 12 — Thanh toán

- Xem tại `/thanh-toan-v2?course=48` hoặc `/thanh-toan-v2?book=66`; `/checkout-v2` là tuyến tương đương. Trang chi tiết khóa học và sách dẫn sang bước này với đúng sản phẩm đã chọn.
- Bố cục theo bước chọn gói của MasterClass nhưng dùng sản phẩm riêng của Meduc: tiến trình ba bước, biểu mẫu người mua, tóm tắt giá và bước xác nhận. Với sách, biểu mẫu thêm địa chỉ nhận hàng.
- `scripts/export_checkout_catalog.py` xuất giá của 33 khóa học và 46 sách đang bật từ cơ sở dữ liệu vào `hero-light/assets/checkout-catalog.json`. Giá ưu đãi chỉ dùng khi dương và thấp hơn giá niêm yết.
- Đây là bản xem trước giao diện: biểu mẫu không gửi thông tin, không tạo đơn và không nhận thanh toán. Nút ở bước cuối mở trang sản phẩm Meduc để thực hiện quy trình đặt hàng thật và xác nhận giá hiện hành. Tuyến `/checkout-v2` cũ đã chuyển sang bản này, bỏ QR và thông báo thanh toán giả.
- Đã kiểm tra tuyến PHP, dữ liệu sản phẩm, đường dẫn từ trang số 5 và số 7, bước xác nhận khóa học/sách và bố cục mobile 390 px không tràn ngang.

## Trang số 13 — Khóa học đang tham gia

- Xem bản PHP tại `http://127.0.0.1:8080/khoa-hoc-dang-tham-gia-v2`; `/khoa-hoc-cua-toi-v2` là tuyến tương đương. Bản HTML độc lập là `hero-light/my-courses.html`.
- Trang dùng bố cục học tập sáng lấy cảm hứng từ MasterClass, gồm khóa nổi bật, bài tiếp theo trong đề cương, tiến độ, thư viện khóa học, lọc trạng thái, tìm kiếm và gợi ý bước học tiếp.
- Bốn khóa minh họa lấy tên, ảnh, số chương/bài và slug từ `hero-light/assets/catalog-data.json`. Tên bài học lấy từ `hero-light/assets/course-outline.json`. Các con số tiến độ là ví dụ trình bày, được ghi rõ trên trang; dữ liệu Meduc PHP hiện tại chưa có tiến độ bài học theo tài khoản. Nút vào khóa mở đề cương, không giả lập phát bài hoặc quyền truy cập.
- `scripts/sync_my_courses_template.py` cập nhật `templates/app01/Masterclass/my_courses_v2.tpl` từ HTML nguồn. Đã kiểm tra PHP/JavaScript, tuyến trang và tuyến khóa học, bộ lọc, tìm kiếm không dấu, trạng thái rỗng và mobile 390 px không tràn ngang.

## Trang số 14 — Các khóa học nên mua

- Xem bản PHP tại http://127.0.0.1:8080/goi-y-khoa-hoc-v2; /khoa-hoc-nen-mua-v2 là tuyến tương đương. Bản HTML độc lập là hero-light/recommendations.html.
- Luồng ba bước theo ảnh tham chiếu MasterClass: chọn nhiều môn quan tâm, chọn một mục tiêu học, rồi xem sáu khóa gợi ý. Có thể bỏ qua từng bước và quay lại sửa lựa chọn.
- Gợi ý được xếp hạng từ 33 khóa đang bật trong hero-light/assets/catalog-data.json, ưu tiên khóa khớp môn và mục tiêu, chỉ hiển thị khóa có bài học. Đây là gợi ý theo lựa chọn trên trang, chưa sử dụng lịch sử mua hay tiến độ của tài khoản.
- Thẻ mở trang chi tiết khóa học; khóa đầu tiên có thêm lối xem học phí tham khảo ở trang số 12. Trang danh sách khóa học số 4 dẫn tới luồng này ở phần “Cùng tìm lộ trình”.
- Chạy python3 scripts/sync_recommendations_template.py sau khi sửa HTML nguồn để cập nhật templates/app01/Masterclass/recommendations_v2.tpl. Dữ liệu khóa học được làm mới bằng scripts/export_course_catalog.py.

## Trang số 15 — Lịch sử làm bài

- Xem bản PHP tại `http://127.0.0.1:8080/lich-su-lam-bai-v2`; bản HTML độc lập là `hero-light/quiz-history.html`.
- Trang có biểu đồ điểm, bốn chỉ số, lịch sử từng lượt làm bài, tìm kiếm, lọc theo khóa học/thời gian/điểm và trạng thái chưa có kết quả. Giao diện sáng theo hệ thiết kế của các trang Meduc mới.
- `/lich-su-lam-bai-v2/data` chỉ trả các lượt trong `quizs_answer` của tài khoản đang đăng nhập, kèm tên bài, tên khóa, số câu đúng, thời gian và ngày làm. API không xuất đáp án, địa chỉ IP hay mã thành viên và gửi `Cache-Control: private, no-store`.
- Khi chưa đăng nhập, trang hiện dữ liệu minh họa có nhãn rõ ràng; điểm số và ngày minh họa không nằm trong tệp xuất từ cơ sở dữ liệu. Tài khoản đã đăng nhập mà chưa có lượt làm bài sẽ thấy trạng thái rỗng.
- Chạy `python3 scripts/sync_quiz_history_template.py` sau khi sửa HTML nguồn để cập nhật `templates/app01/QuizHistory/index.tpl`. Đã kiểm tra tuyến trang HTTP 200, API chưa đăng nhập HTTP 401, cú pháp PHP/JavaScript, câu truy vấn SQL, các bộ lọc và mobile 390 px không tràn ngang. Chưa kiểm thử phiên đăng nhập thật vì không có tài khoản thử được cấp trong môi trường này.

## Trang số 16 — Hệ thống phân cấp bộ đề

- Xem bản PHP tại `http://127.0.0.1:8080/bo-de-v2`; `/he-thong-bo-de-v2` là tuyến tương đương. Bản HTML độc lập là `hero-light/exam-hierarchy.html`.
- Giao diện sáng theo hệ Meduc mới, với đường duyệt **trường → năm trong tên đề → môn học hoặc module → bộ đề**. Có tìm kiếm không dấu, chọn từng tầng, xem thêm, đường dẫn lọc trong URL và hộp thông tin của từng đề.
- `scripts/export_exam_hierarchy.py` xuất `hero-light/assets/exam-hierarchy-data.json` từ hai CSV đã rà soát trong `../meduc-cao/data/`. Chỉ mục gồm 2.033 đề, 131.980 câu, 445 danh mục gốc, 32 nhãn trường đã chuẩn hóa và 88 môn/module. Trong đó có 1.011 đề không ghi năm. Chạy lại script khi CSV nguồn thay đổi.
- Năm được gán theo số bốn chữ số 20xx lớn nhất trong tên đề, gồm cả mã khóa như `Y2022`; chưa xác minh đây là năm thi. Nhánh “Không ghi năm” dành cho tên không có chuỗi năm 20xx. Môn học và module là hai nhánh song song.
- `scripts/sync_exam_hierarchy_template.py` cập nhật `templates/app01/Masterclass/exam_hierarchy_v2.tpl` từ HTML nguồn. Trang này duyệt metadata; nội dung câu hỏi chưa được nối vào giao diện, nên hộp chi tiết không giả lập bắt đầu làm bài.
- Đã kiểm tra tuyến PHP và JSON trả HTTP 200, cú pháp PHP/JavaScript, tổng dữ liệu, bộ lọc trường/năm/module/môn, tìm kiếm không dấu, xem thêm, chi tiết đề và mobile 390 px không tràn ngang.
