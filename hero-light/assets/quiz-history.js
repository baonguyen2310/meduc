(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/quiz-history.html');
  const detailPage = staticPreview ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2';
  const $ = (selector) => document.querySelector(selector);
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
  const dateText = (stamp) => new Intl.DateTimeFormat('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(new Date(stamp * 1000));
  const shortDuration = (seconds) => seconds >= 3600
    ? `${Math.floor(seconds / 3600)} giờ ${Math.floor(seconds % 3600 / 60)} phút`
    : `${Math.floor(seconds / 60)} phút ${String(seconds % 60).padStart(2, '0')} giây`;
  const courseURL = (slug) => `${detailPage}?course=${encodeURIComponent(slug)}`;
  const safeURL = (url) => /^\/khoa-hoc-chi-tiet-v2\?course=[^"'<>\s]+$/.test(url) || url === '/medduo' || /^course-detail\.html\?course=[^"'<>\s]+$/.test(url)
    ? url : '/medduo';
  const demoSource = [
    ['Sinh Lý: Trắc nghiệm bài 01', 'Sinh Lý 1, 2: Cơ Bản đến Chuyên Sâu', 'sinh-ly-1-2-co-ban-chuyen-sau', 34, 40, 1412, 0],
    ['BTVN Giải Phẫu Buổi 1', 'Giải Phẫu 1, 2: Cơ Bản đến Chuyên Sâu', 'giai-phau-1-2-co-ban-chuyen-sau', 32, 40, 1615, 1],
    ['BTVN Nội Khoa Buổi 1', 'Lâm Sàng - Nội Khoa: Cơ Bản đến Chuyên Sâu', 'lam-sang-noi-khoa-co-ban-chuyen-sau', 28, 40, 1578, 2],
    ['Đề thi Sinh lý - Chương 1', 'Sinh Lý 1, 2: Cơ Bản đến Chuyên Sâu', 'sinh-ly-1-2-co-ban-chuyen-sau', 36, 40, 1820, 4],
    ['BTVN Giải Phẫu Buổi 2', 'Giải Phẫu 1, 2: Cơ Bản đến Chuyên Sâu', 'giai-phau-1-2-co-ban-chuyen-sau', 30, 40, 1432, 6],
    ['Môn sinh lý bài trắc nghiệm 05', 'Sinh Lý 1, 2: Cơ Bản đến Chuyên Sâu', 'sinh-ly-1-2-co-ban-chuyen-sau', 26, 40, 1265, 8],
    ['Đề Thi Giải Phẫu 01', 'Giải Phẫu 1, 2: Cơ Bản đến Chuyên Sâu', 'giai-phau-1-2-co-ban-chuyen-sau', 22, 40, 1511, 10],
    ['BTVN Giải Phẫu Buổi 3', 'Giải Phẫu 1, 2: Cơ Bản đến Chuyên Sâu', 'giai-phau-1-2-co-ban-chuyen-sau', 38, 40, 1743, 13],
    ['Đề thi giải phẫu số 02', 'Giải Phẫu 1, 2: Cơ Bản đến Chuyên Sâu', 'giai-phau-1-2-co-ban-chuyen-sau', 18, 40, 1920, 18],
    ['Đề thi Sinh lý - Chương 9: Sinh lý tuyến tụy nội tiết', 'Sinh Lý 1, 2: Cơ Bản đến Chuyên Sâu', 'sinh-ly-1-2-co-ban-chuyen-sau', 33, 40, 1650, 24],
  ];
  const demoAttempts = () => demoSource.map(([title, course, slug, correct, total, duration, days], index) => ({
    id: `demo-${index + 1}`, title, course, correct, total, duration,
    score: correct * 100 / total,
    created: Math.floor(Date.now() / 1000) - days * 86400 - 9 * 3600,
    course_url: courseURL(slug),
  }));

  let attempts = [];
  let visibleCount = 8;
  let mode = 'loading';

  function renderOverview() {
    const total = attempts.length;
    const average = total ? Math.round(attempts.reduce((sum, item) => sum + item.score, 0) / total) : 0;
    const correct = attempts.reduce((sum, item) => sum + item.correct, 0);
    const best = total ? Math.round(Math.max(...attempts.map((item) => item.score))) : 0;
    $('#stat-attempts').textContent = new Intl.NumberFormat('vi-VN').format(total);
    $('#stat-average').textContent = `${average}%`;
    $('#stat-correct').textContent = new Intl.NumberFormat('vi-VN').format(correct);
    $('#stat-best').textContent = `${best}%`;
    $('#visual-average').textContent = `${average}%`;
    const recent = [...attempts].sort((a, b) => b.created - a.created || b.id - a.id).slice(0, 7).reverse();
    $('#score-bars').innerHTML = recent.length
      ? recent.map((item) => `<span class="history-bar" style="--height:${Math.max(8, Math.min(100, item.score))}%" data-score="${Math.round(item.score)}%" role="img" aria-label="Bài ${escape(item.title)}: ${Math.round(item.score)}%"></span>`).join('')
      : '<span class="history-no-bars">Chưa có kết quả để hiển thị.</span>';
    const latest = attempts[0];
    if (latest) {
      $('#next-course').textContent = latest.course;
      $('#next-course-detail').textContent = `Bài gần nhất: ${latest.title}. Xem lại đề cương và chọn phần cần ôn tiếp.`;
      $('#next-course-link').href = safeURL(latest.course_url);
      $('#next-course-link').textContent = 'Xem khóa học ↗';
    }
  }

  function updateCourseOptions() {
    const courses = [...new Set(attempts.map((item) => item.course))].sort((a, b) => a.localeCompare(b, 'vi'));
    $('#history-course').innerHTML = '<option value="all">Tất cả khóa học</option>'
      + courses.map((course) => `<option value="${escape(course)}">${escape(course)}</option>`).join('');
  }

  function filtered() {
    const term = normalize($('#history-search').value.trim());
    const course = $('#history-course').value;
    const period = $('#history-period').value;
    const score = $('#history-score').value;
    const threshold = period === 'all' ? 0 : Math.floor(Date.now() / 1000) - Number(period) * 86400;
    return attempts.filter((item) =>
      (course === 'all' || item.course === course)
      && (!threshold || item.created >= threshold)
      && (score === 'all' || (score === 'high' ? item.score >= 80 : score === 'middle' ? item.score >= 50 && item.score < 80 : item.score < 50))
      && (!term || normalize(`${item.title} ${item.course} ${item.quiz || ''}`).includes(term))
    );
  }

  function renderList() {
    const result = filtered();
    $('#history-count').textContent = `Hiển thị ${Math.min(visibleCount, result.length)} / ${result.length} lượt làm bài${mode === 'demo' ? ' minh họa' : ''}`;
    $('#history-list').innerHTML = result.slice(0, visibleCount).map((item) => {
      const date = new Date(item.created * 1000);
      const day = String(date.getDate()).padStart(2, '0');
      const month = `THÁNG ${String(date.getMonth() + 1).padStart(2, '0')}`;
      const score = Math.round(item.score);
      return `<article class="history-record"><div class="record-day"><strong>${day}</strong><span>${month}</span></div><div class="record-main"><span class="record-kicker">${escape(item.course)}</span><h3>${escape(item.title)}</h3><p><svg class="icon"><use href="#i-clock" /></svg>${dateText(item.created)} · ${shortDuration(item.duration)}</p></div><div class="record-score"><strong class="${score >= 80 ? 'is-high' : ''}">${score}%</strong><span>${item.correct}/${item.total} câu đúng</span><span class="record-meter"><i style="width:${Math.max(0, Math.min(100, item.score))}%"></i></span></div><a class="record-link" href="${escape(safeURL(item.course_url))}" aria-label="Xem khóa học của bài ${escape(item.title)}"><svg class="icon"><use href="#i-arrow" /></svg></a></article>`;
    }).join('');
    $('#history-empty').hidden = result.length > 0;
    $('#history-more').hidden = visibleCount >= result.length;
    if (!result.length) {
      const noHistory = attempts.length === 0;
      $('#history-empty-title').textContent = noHistory ? 'Chưa có bài làm nào.' : 'Chưa có bài phù hợp.';
      $('#history-empty-message').textContent = noHistory
        ? 'Bắt đầu một bài luyện tập trên MedDuo, kết quả sẽ xuất hiện tại đây sau khi hoàn thành.'
        : 'Thử thay đổi bộ lọc hoặc tìm bằng tên môn khác.';
    }
  }

  function showData(data, nextMode) {
    mode = nextMode;
    attempts = data.sort((a, b) => b.created - a.created || String(b.id).localeCompare(String(a.id)));
    visibleCount = 8;
    const notice = $('#history-notice');
    notice.classList.toggle('is-live', mode === 'live');
    notice.innerHTML = mode === 'live'
      ? '<span class="history-notice-mark"><svg class="icon"><use href="#i-check" /></svg></span><p><strong>Lịch sử của bạn.</strong> Kết quả được lấy từ những lượt làm bài gắn với tài khoản Meduc đang đăng nhập.</p>'
      : '<span class="history-notice-mark">i</span><p><strong>Dữ liệu minh họa.</strong> Điểm số và ngày làm bên dưới chỉ để xem trước giao diện, chưa phải lịch sử của tài khoản.</p><a href="/member/login">Đăng nhập xem kết quả thật ↗</a>';
    $('#visual-mode').textContent = mode === 'live' ? 'KẾT QUẢ CỦA BẠN' : 'DỮ LIỆU MINH HỌA';
    if (mode === 'live') {
      $('#header-login').textContent = 'Tài khoản Meduc ↗';
      $('#header-login').href = '/member/dashboard';
    }
    updateCourseOptions();
    renderOverview();
    renderList();
  }

  for (const selector of ['#history-search', '#history-course', '#history-period', '#history-score']) {
    $(selector).addEventListener(selector === '#history-search' ? 'input' : 'change', () => { visibleCount = 8; renderList(); });
  }
  $('#history-more').addEventListener('click', () => { visibleCount += 8; renderList(); });
  $('#history-reset').addEventListener('click', () => {
    $('#history-search').value = '';
    $('#history-course').value = 'all';
    $('#history-period').value = 'all';
    $('#history-score').value = 'all';
    visibleCount = 8;
    renderList();
  });

  if (staticPreview || new URLSearchParams(location.search).get('demo') === '1') {
    showData(demoAttempts(), 'demo');
  } else {
    fetch('/lich-su-lam-bai-v2/data', { credentials: 'same-origin', cache: 'no-store' }).then(async (response) => {
      if (response.status === 401) { showData(demoAttempts(), 'demo'); return; }
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      if (!Array.isArray(data.attempts) || data.attempts.length !== data.count) throw new Error('Dữ liệu lịch sử không hợp lệ');
      showData(data.attempts, 'live');
    }).catch(() => {
      $('#history-notice').innerHTML = '<span class="history-notice-mark">!</span><p><strong>Không tải được lịch sử làm bài.</strong> Hãy tải lại trang sau ít phút.</p>';
      $('#history-count').textContent = 'Chưa tải được dữ liệu';
      $('#history-empty').hidden = false;
      $('#history-empty-title').textContent = 'Không tải được lịch sử.';
      $('#history-empty-message').textContent = 'Kết quả tài khoản hiện chưa khả dụng. Thử tải lại trang.';
    });
  }
})();
