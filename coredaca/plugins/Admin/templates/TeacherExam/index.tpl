<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="csrf-token" content="{$csrfToken|escape:'html'}">
  <title>Kho đề theo khóa học — MedUC</title>
  <link rel="stylesheet" href="/hero-light/assets/teacher-exams.css">
  <script src="/hero-light/assets/teacher-exams.js" defer></script>
</head>
<body>
  <header class="topbar">
    <a class="brand" href="/masterclass" aria-label="MedUC - Trang chủ"><img src="https://cdn.meduc.vn/media/core/logo/logo-meduc.png" alt="MedUC"></a>
    <nav><a href="/masterclass">Trang chủ</a>{if $isManager}<a href="#management">Phân quyền</a>{/if}<a href="/admin/user/profile">Tài khoản</a><a href="/admin/logout">Đăng xuất</a></nav>
  </header>
  <main class="page">
    <section class="hero">
      <div><span class="eyebrow">MEDUC / FACOURSE</span><h1>Kho đề theo <em>khóa học.</em></h1><p>Giáo viên chỉ xem nội dung và tải Word những đề thuộc khóa học được giao. Quản trị viên có thể phân loại và gán quyền tại đây.</p></div>
      <div class="hero-stat"><strong id="exam-total">—</strong><span>ĐỀ CÓ THỂ TRUY CẬP</span><small>Danh mục nguồn: 2.033 đề</small></div>
    </section>

    <div class="status" id="status" role="status" aria-live="polite">Đang tải danh mục đề...</div>
    <section class="toolbar" aria-label="Bộ lọc đề">
      <label class="search"><span>Tìm đề</span><input id="search" type="search" placeholder="Tên đề, trường, môn/module..." autocomplete="off"></label>
      <label><span>Khóa học</span><select id="filter-course"><option value="">Tất cả khóa học</option></select></label>
      <label><span>Trường</span><select id="filter-school"><option value="">Tất cả trường</option></select></label>
      <label><span>Môn/module</span><select id="filter-topic"><option value="">Tất cả môn/module</option></select></label>
    </section>
    <div class="list-head"><div><span class="eyebrow">DANH MỤC ĐỀ</span><h2>Chọn đề cần xem</h2></div><strong id="shown-count">—</strong></div>
    <div id="exam-list" class="exam-list"></div>
    <button id="show-more" class="show-more" type="button" hidden>Xem thêm đề ↓</button>

    <section id="management" class="management" hidden>
      <div class="management-intro"><span class="eyebrow">DÀNH CHO QUẢN TRỊ VIÊN</span><h2>Phân quyền theo khóa học</h2><p>Gán giáo viên vào khóa học, rồi gắn đề theo môn/module hoặc theo từng đề. Các đề chưa gắn khóa sẽ không hiện với giáo viên.</p></div>
      <div class="manage-grid">
        <article class="manage-card"><span class="step">01 / GIÁO VIÊN</span><h3>Khóa học được dạy</h3><label>Giáo viên<select id="teacher-select"><option value="">Chọn giáo viên</option></select></label><div id="teacher-courses" class="course-checks"></div><button id="save-teacher" type="button">Lưu khóa học của giáo viên</button><p class="hint">Chưa có tài khoản? <a href="/admin/user/add">Tạo tài khoản</a> và chọn nhóm “Giáo viên”.</p></article>
        <article class="manage-card"><span class="step">02 / MÔN VÀ MODULE</span><h3>Gán hàng loạt đề</h3><label>Môn/module<select id="topic-select"><option value="">Chọn môn/module</option></select></label><div id="topic-courses" class="course-checks"></div><button id="save-topic" type="button">Lưu gán môn/module</button><p class="hint">Tất cả đề trong môn/module này sẽ thuộc các khóa được chọn.</p></article>
        <article class="manage-card"><span class="step">03 / TỪNG ĐỀ</span><h3>Bổ sung đề riêng</h3><p id="selected-exam">Chọn “Gán khóa” ở một đề phía trên.</p><div id="exam-courses" class="course-checks"></div><button id="save-exam" type="button">Lưu gán đề riêng</button><p class="hint">Gán đề riêng được cộng thêm vào gán theo môn/module.</p></article>
      </div>
    </section>
  </main>

  <dialog id="preview" class="preview"><div class="preview-head"><span>MEDUC / NỘI DUNG ĐỀ</span><button id="close-preview" type="button" aria-label="Đóng">×</button></div><div id="preview-body"></div></dialog>
</body>
</html>
