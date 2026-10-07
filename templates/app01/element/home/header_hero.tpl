<div class="mhi" id="meduc-home-intro">
  <a class="mhi-skip" href="#meduc-home-content">Đến nội dung chính</a>
  <header class="mhi-header">
    <div class="mhi-network">
      <nav class="mhi-shell mhi-network-links" aria-label="Hệ sinh thái Meduc">
        <a href="/" aria-current="page">Meduc</a>
        <a href="/khoa-hoc-v2">Khóa học</a>
        <a href="/danh-sach-de-thi">Luyện thi</a>
        <a href="/blog-v2">Góc học tập</a>
        <a href="/danh-sach-de-thi">Bảng xếp hạng</a>
      </nav>
    </div>
    <div class="mhi-shell mhi-header-main">
      <a class="mhi-brand" href="/" aria-label="Meduc — Trang chủ">
        <svg viewBox="0 0 30 28" fill="none" aria-hidden="true"><path d="M3 24V4l12 14L27 4v20" stroke="currentColor" stroke-width="4.5" /></svg>
        <span>meduc<span class="mhi-brand-dot">.</span></span>
      </a>
      <div class="mhi-browse-wrap">
        <button class="mhi-browse-button" id="mhi-browse-button" type="button" aria-expanded="false" aria-controls="mhi-browse-menu">
          Khám phá <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="m5 9 7 7 7-7" /></svg>
        </button>
        <nav class="mhi-browse-menu" id="mhi-browse-menu" aria-label="Khám phá Meduc" hidden>
          <p>Học điều bạn cần. Theo cách của bạn.</p>
          <a href="/khoa-hoc-v2?nhom=foundation">Y khoa cơ sở <span aria-hidden="true">↗</span></a>
          <a href="/khoa-hoc-v2?nhom=clinical">Nội khoa &amp; lâm sàng <span aria-hidden="true">↗</span></a>
          <a href="/danh-sach-de-thi">Ngân hàng đề thi <span aria-hidden="true">↗</span></a>
          <a href="/gioi-thieu">Về Meduc <span aria-hidden="true">↗</span></a>
          <a class="mhi-browse-all" href="/khoa-hoc-v2">Xem tất cả khóa học <span aria-hidden="true">→</span></a>
        </nav>
      </div>
      <form class="mhi-search" action="/tim-kiem" method="get" role="search">
        <button type="submit" aria-label="Tìm kiếm"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="10.5" cy="10.5" r="7"/><path d="m16 16 5 5"/></svg></button>
        <label class="mhi-sr-only" for="mhi-search-input">Tìm khóa học, sách, đề thi</label>
        <input id="mhi-search-input" name="keyword" type="search" placeholder="Hôm nay bạn muốn học gì?" autocomplete="off" />
      </form>
      <nav class="mhi-utility" aria-label="Tài khoản và tiện ích">
        <a class="mhi-plans" href="/khoa-hoc-v2">Gói học</a>
        <a class="mhi-login" href="/member/login">Đăng nhập</a>
      </nav>
      <button class="mhi-theme-toggle" id="mhi-theme-toggle" type="button" aria-label="Chuyển sang chế độ sáng" aria-pressed="true" title="Chuyển sang chế độ sáng">
        <svg class="mhi-sun" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M4.93 4.93l1.42 1.42m11.3 11.3 1.42 1.42M2 12h2m16 0h2M4.93 19.07l1.42-1.42m11.3-11.3 1.42-1.42"/></svg>
        <svg class="mhi-moon" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M20.3 15.4A8.5 8.5 0 0 1 8.6 3.7 8.5 8.5 0 1 0 20.3 15.4Z"/></svg>
      </button>
      <a class="mhi-header-cta" href="#mhi-learning-goals">Bắt đầu học</a>
    </div>
  </header>

  <main class="mhi-shell mhi-hero" id="meduc-home-content">
    <div class="mhi-copy">
      <h1><span>HỌC TỪ NGƯỜI GIỎI,</span><span>VỮNG BƯỚC NGHỀ Y.</span></h1>
      <p class="mhi-subtitle">Học sâu, hiểu đúng. Vững vàng trên hành trình nghề Y.</p>
      <div class="mhi-actions">
        <a class="mhi-primary" href="/khoa-hoc-v2">Khám phá khóa học</a>
        <a class="mhi-secondary" href="/gioi-thieu">Tìm hiểu về Meduc</a>
      </div>
      <div class="mhi-red-rule" aria-hidden="true"></div>
      <form id="mhi-goal-form" novalidate>
        <fieldset id="mhi-learning-goals" aria-describedby="mhi-goal-hint mhi-goal-error">
          <legend>Điều gì đưa bạn đến với Meduc hôm nay?</legend>
          <div class="mhi-goal-options">
            <label><input type="checkbox" name="goal" value="foundation" /><span>Củng cố kiến thức Y khoa cơ sở</span></label>
            <label><input type="checkbox" name="goal" value="clinical" /><span>Nâng cao tư duy và kỹ năng lâm sàng</span></label>
            <label><input type="checkbox" name="goal" value="semester" /><span>Ôn thi học phần, tự tin qua môn</span></label>
            <label><input type="checkbox" name="goal" value="residency" /><span>Chinh phục kỳ thi bác sĩ nội trú</span></label>
            <label><input type="checkbox" name="goal" value="practice" /><span>Luyện đề và hiểu sâu từng đáp án</span></label>
            <label><input type="checkbox" name="goal" value="mentors" /><span>Học từ kinh nghiệm của giảng viên</span></label>
            <label><input type="checkbox" name="goal" value="habits" /><span>Tìm lại cảm hứng và nhịp học mỗi ngày</span></label>
          </div>
        </fieldset>
        <p class="mhi-goal-error" id="mhi-goal-error" role="alert" hidden>Chọn ít nhất một mục tiêu để Meduc gợi ý cho bạn nhé.</p>
        <button class="mhi-goal-submit" type="submit">Tìm lộ trình của tôi <span aria-hidden="true">→</span></button>
        <p class="mhi-goal-hint" id="mhi-goal-hint" role="status">Bạn có thể chọn nhiều mục tiêu.</p>
      </form>
    </div>

    <div class="mhi-portrait-wall" id="mhi-portrait-wall">
      <div class="mhi-portrait-window" aria-hidden="true">
        <div class="mhi-portrait-track mhi-track-one"><div class="mhi-portrait-set">
          <div class="mhi-portrait"><img src="/hero-light/assets/images/doctor-linh.jpg" alt="" width="1086" height="1448" fetchpriority="high" /></div>
          <div class="mhi-portrait"><img src="/hero-light/assets/images/professor.jpg" alt="" width="1086" height="1448" /></div>
          <div class="mhi-portrait"><img src="/hero-light/assets/images/meduc-doctor-04.jpg" alt="" width="600" height="750" /></div>
        </div></div>
        <div class="mhi-portrait-track mhi-track-two"><div class="mhi-portrait-set">
          <div class="mhi-portrait"><img src="/hero-light/assets/images/meduc-doctor-01.jpg" alt="" width="600" height="400" /></div>
          <div class="mhi-portrait"><img src="/hero-light/assets/images/doctor-minh.jpg" alt="" width="1086" height="1448" fetchpriority="high" /></div>
          <div class="mhi-portrait"><img src="/hero-light/assets/images/meduc-doctor-02.jpg" alt="" width="600" height="400" /></div>
        </div></div>
      </div>
      <button class="mhi-motion-toggle" id="mhi-motion-toggle" type="button" aria-label="Tạm dừng chuyển động ảnh" aria-pressed="false" title="Tạm dừng chuyển động ảnh">Ⅱ</button>
    </div>
  </main>

  <dialog class="mhi-dialog" id="mhi-path-dialog" aria-labelledby="mhi-path-title">
    <button class="mhi-dialog-close" type="button" aria-label="Đóng">×</button>
    <span class="mhi-dialog-kicker">GỢI Ý DÀNH CHO BẠN</span>
    <h2 id="mhi-path-title">Bắt đầu từ điều bạn cần.</h2>
    <p id="mhi-path-description"></p>
    <div class="mhi-path-links" id="mhi-path-links"></div>
  </dialog>
</div>
