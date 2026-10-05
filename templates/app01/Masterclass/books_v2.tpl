<!-- Generated from hero-light/books.html by scripts/sync_books_template.py. -->
<!doctype html>
<html lang="vi">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#ffffff" />
    <meta name="description" content="Khám phá sách Y khoa đang mở tại Meduc theo môn học và giai đoạn học." />
    <title>Sách Y khoa — Meduc</title>
    <link rel="icon" type="image/svg+xml" href="/hero-light/assets/favicon.svg" />
    <link rel="preload" href="/hero-light/assets/fonts/anton-regular.ttf" as="font" type="font/ttf" crossorigin />
    <link rel="preload" href="/hero-light/assets/fonts/Inter-Regular.woff2" as="font" type="font/woff2" crossorigin />
    <link rel="stylesheet" href="/hero-light/assets/hero.css" />
    <link rel="stylesheet" href="/hero-light/assets/light.css" />
    <link rel="stylesheet" href="/hero-light/assets/about.css" />
    <link rel="stylesheet" href="/hero-light/assets/books.css" />
    <script src="/hero-light/assets/books.js" defer></script>
  </head>
  <body>
    <a class="skip-link" href="#main">Đến nội dung chính</a>
    <svg class="svg-definitions" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
      <symbol id="i-arrow" viewBox="0 0 24 24"><path d="M4 12h16m-6-6 6 6-6 6" /></symbol>
      <symbol id="i-search" viewBox="0 0 24 24"><circle cx="10.8" cy="10.8" r="6.8" /><path d="m16 16 5 5" /></symbol>
      <symbol id="i-book" viewBox="0 0 24 24"><path d="M12 6.5C8 4.4 4.8 4.2 2 5v13c3-.8 6.3-.6 10 1.5 3.7-2.1 7-2.3 10-1.5V5c-2.8-.8-6-.6-10 1.5ZM12 6.5v13" /></symbol>
    </svg>

    <header class="site-header about-header">
      <div class="shell about-header-inner">
        <a class="brand" href="/masterclass" aria-label="Meduc — Trang chủ"><svg class="brand-mark" viewBox="0 0 30 28" fill="none" aria-hidden="true"><path d="M3 24V4l12 14L27 4v20" stroke="currentColor" stroke-width="4.5" /></svg><span>meduc<span class="brand-dot">.</span></span></a>
        <span class="header-page-name">Thư viện sách Y khoa</span>
        <div class="header-actions"><a class="header-home" href="/khoa-hoc-v2">Khóa học</a><a class="button header-course" href="#catalog">Khám phá sách <svg class="icon"><use href="#i-arrow" /></svg></a></div>
      </div>
    </header>

    <main id="main">
      <nav class="book-topic-nav" aria-label="Chủ đề sách"><div class="shell book-topic-inner">
        <span>KHÁM PHÁ THEO MÔN</span>
        <a href="#catalog" data-jump-subject="all" aria-current="page">Tất cả</a>
        <a href="#catalog" data-jump-subject="physiology">Sinh lý</a>
        <a href="#catalog" data-jump-subject="anatomy">Giải phẫu</a>
        <a href="#catalog" data-jump-subject="internal">Nội khoa</a>
        <a href="#catalog" data-jump-subject="english">Tiếng Anh Y khoa</a>
        <a href="#catalog" data-jump-subject="other">Chủ đề khác</a>
      </div></nav>

      <section class="book-hero" aria-labelledby="book-hero-title"><div class="shell book-hero-inner">
        <div class="book-hero-copy"><span class="eyebrow"><span class="eyebrow-line"></span> SÁCH Y KHOA MEDUC</span><h1 id="book-hero-title">MỞ SÁCH.<br /><span>MỞ THÊM</span><br />GÓC NHÌN.</h1><p>Từ kiến thức nền tảng đến những ca lâm sàng. Tìm cuốn sách phù hợp với môn học và chặng đường của bạn.</p><div class="book-hero-actions"><a class="button" href="#catalog">Xem tất cả sách <svg class="icon"><use href="#i-arrow" /></svg></a><span id="book-total">Danh mục sách đang mở tại Meduc</span></div></div>
        <div class="book-hero-art" aria-label="Bìa sách Y khoa Meduc"><span class="art-backdrop"></span><div id="hero-books" class="hero-books"></div><div class="hero-art-note"><svg class="icon"><use href="#i-book" /></svg><span>HỌC SÂU HƠN<br />MỖI NGÀY.</span></div></div>
      </div></section>

      <section class="book-feature" aria-labelledby="feature-title"><div class="shell"><div class="book-section-head"><div><span class="eyebrow">GỢI Ý ĐỂ BẮT ĐẦU</span><h2 id="feature-title">MỖI MÔN HỌC,<br /><span>MỘT KỆ SÁCH.</span></h2></div><p>Những đầu sách trong danh mục Meduc, từ nền tảng sinh lý đến khám lâm sàng và tiếng Anh Y khoa.</p></div><div class="feature-rail" id="feature-rail" aria-label="Sách tiêu biểu"></div></div></section>

      <section class="book-catalog" id="catalog" aria-labelledby="catalog-title"><div class="shell"><div class="book-section-head"><div><span class="eyebrow">DANH MỤC ĐANG MỞ</span><h2 id="catalog-title">TÌM CUỐN SÁCH<br /><span>BẠN CẦN.</span></h2></div><p>Tra cứu theo tên, môn học hoặc giai đoạn. Chọn bìa sách để xem ảnh và thông tin chi tiết.</p></div>
        <div class="book-tools"><label class="book-search"><svg class="icon" aria-hidden="true"><use href="#i-search" /></svg><span class="sr-only">Tìm sách</span><input id="book-search" type="search" placeholder="Tìm sách theo tên hoặc môn học..." autocomplete="off" /></label><label class="book-select">Giai đoạn học <select id="book-stage"><option value="all">Tất cả</option><option value="early">Năm 1–2</option><option value="middle">Năm 3–4</option><option value="late">Năm 5–6</option></select></label><label class="book-select">Sắp xếp <select id="book-sort"><option value="default">Mặc định</option><option value="az">Tên A–Z</option><option value="price-asc">Giá tăng dần</option><option value="price-desc">Giá giảm dần</option></select></label></div>
        <div class="book-filters" role="group" aria-label="Lọc sách theo môn"><button type="button" data-subject="all" aria-pressed="true">Tất cả <span data-count="all"></span></button><button type="button" data-subject="physiology" aria-pressed="false">Sinh lý <span data-count="physiology"></span></button><button type="button" data-subject="anatomy" aria-pressed="false">Giải phẫu <span data-count="anatomy"></span></button><button type="button" data-subject="internal" aria-pressed="false">Nội khoa <span data-count="internal"></span></button><button type="button" data-subject="english" aria-pressed="false">Tiếng Anh Y khoa <span data-count="english"></span></button><button type="button" data-subject="other" aria-pressed="false">Chủ đề khác <span data-count="other"></span></button></div>
        <div class="book-result-bar"><p id="book-status" role="status">Đang tải danh mục sách...</p><span>Giá hiển thị theo bản dữ liệu xem trước</span></div>
        <div class="book-grid" id="book-grid"></div><div class="book-empty" id="book-empty" hidden><h3>Chưa tìm thấy sách phù hợp.</h3><p>Thử một tên sách khác hoặc bỏ bộ lọc để xem toàn bộ danh mục.</p><button type="button" id="book-clear">Xem tất cả sách</button></div><button type="button" class="book-more" id="book-more" hidden>Xem thêm sách <svg class="icon"><use href="#i-arrow" /></svg></button>
        <noscript><p>Bật JavaScript để xem danh mục này, hoặc mở <a href="https://meduc.vn/sach-y-khoa">sách Y khoa trên Meduc</a>.</p></noscript>
      </div></section>

      <section class="book-next"><div class="shell book-next-inner"><div><span class="eyebrow">TIẾP TỤC HỌC CÙNG MEDUC</span><h2>ĐỌC SÁCH.<br /><span>RỒI HỌC SÂU HƠN.</span></h2><p>Khám phá các khóa học theo môn để nối kiến thức trong sách với bài giảng và thực hành.</p></div><a class="button" href="/khoa-hoc-v2">Khám phá khóa học <svg class="icon"><use href="#i-arrow" /></svg></a></div></section>
    </main>

    <footer class="about-footer"><div class="shell footer-top"><div><a class="brand" href="/masterclass" aria-label="Meduc — Trang chủ"><svg class="brand-mark" viewBox="0 0 30 28" fill="none" aria-hidden="true"><path d="M3 24V4l12 14L27 4v20" stroke="currentColor" stroke-width="4.5" /></svg><span>meduc<span class="brand-dot">.</span></span></a><p>Học sâu, hiểu đúng.<br />Vững bước nghề Y.</p></div><nav aria-label="Liên kết cuối trang"><a href="/masterclass">Trang chủ</a><a href="/gioi-thieu-v2">Giới thiệu</a><a href="/phan-hoi-hoc-vien-v2">Phản hồi</a><a href="/khoa-hoc-v2">Khóa học</a></nav></div><div class="shell footer-bottom"><span>© 2026 Meduc</span><a href="#main">Lên đầu trang ↑</a></div></footer>
  </body>
</html>
