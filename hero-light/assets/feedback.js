const quotes = [...document.querySelectorAll('.quote-slide')];
const dots = [...document.querySelectorAll('.slider-dots button')];
let quoteIndex = 0;

function showQuote(index) {
  quoteIndex = (index + quotes.length) % quotes.length;
  quotes.forEach((quote, i) => {
    const active = i === quoteIndex;
    quote.hidden = !active;
    quote.classList.toggle('is-active', active);
    dots[i].classList.toggle('is-active', active);
    if (active) dots[i].setAttribute('aria-current', 'true');
    else dots[i].removeAttribute('aria-current');
  });
}

document.querySelector('.slider-prev').addEventListener('click', () => showQuote(quoteIndex - 1));
document.querySelector('.slider-next').addEventListener('click', () => showQuote(quoteIndex + 1));
dots.forEach((dot, i) => dot.addEventListener('click', () => showQuote(i)));

// Snapshot of the 18 public video links on Meduc's existing feedback page.
const videos = [
  { id: 'g9wXdFv1mTw', title: 'Phản Hồi Khoá Học Giải Phẫu, TAYK', subject: 'giai-phau', label: 'Giải phẫu · Tiếng Anh Y khoa', course: '/giai-phau-1-2-co-ban-chuyen-sau' },
  { id: 'mvoFlFPB-rE', title: 'Phản Hồi Khóa Học Sinh Lý', subject: 'sinh-ly', label: 'Sinh lý', course: '/sinh-ly-1-2-co-ban-chuyen-sau' },
  { id: 'YfhMZ9LwkZo', title: 'Phản Hồi Khóa Học Giải Phẫu', subject: 'giai-phau', label: 'Giải phẫu', course: '/giai-phau-1-2-co-ban-chuyen-sau' },
  { id: 'sJDkfvW7oxk', title: 'Phản Hồi Khóa Học Sinh Lý', subject: 'sinh-ly', label: 'Sinh lý', course: '/sinh-ly-1-2-co-ban-chuyen-sau' },
  { id: 'OlefssQgsXY', title: 'Phản Hồi Khóa Học Tiếng Anh Y Khoa', subject: 'tieng-anh', label: 'Tiếng Anh Y khoa', course: '/tieng-anh-y-khoa-12-co-ban-chuyen-sau' },
  { id: 'bn_BJlYt9jI', title: 'Phản Hồi Khóa Học Sinh Lý', subject: 'sinh-ly', label: 'Sinh lý', course: '/sinh-ly-1-2-co-ban-chuyen-sau' },
  { id: '0tuRJk4A0XI', title: 'Phản Hồi Khóa Học Tiếng Anh Y Khoa', subject: 'tieng-anh', label: 'Tiếng Anh Y khoa', course: '/tieng-anh-y-khoa-12-co-ban-chuyen-sau' },
  { id: 'pgTpfhb8lbI', title: 'Phản Hồi Khóa Học Giải Phẫu', subject: 'giai-phau', label: 'Giải phẫu', course: '/giai-phau-1-2-co-ban-chuyen-sau' },
  { id: 'm2ZYIqQbJz8', title: 'Phản Hồi Khóa Tiếng Anh Y Khoa SĐH', subject: 'tieng-anh', label: 'Tiếng Anh Y khoa · Sau đại học', course: '/tieng-anh-y-khoa-12-co-ban-chuyen-sau' },
  { id: 'Oo3DJw_guIU', title: 'Phản Hồi Khóa Học Giải Phẫu SĐH', subject: 'giai-phau', label: 'Giải phẫu · Sau đại học', course: '/giai-phau-noi-tru-co-ban-chuyen-sau' },
  { id: 'jgPymEG6A00', title: 'Phản Hồi Khóa Học Sinh Lý Sau Đại Học', subject: 'sinh-ly', label: 'Sinh lý · Sau đại học', course: '/sinh-ly-noi-tru-co-ban-chuyen' },
  { id: 'J2yiarvLxj4', title: 'Phản Hồi Khóa Học Tiếng Anh Y Khoa', subject: 'tieng-anh', label: 'Tiếng Anh Y khoa', course: '/tieng-anh-y-khoa-12-co-ban-chuyen-sau' },
  { id: 'ysWvZ6Zz6p8', title: 'Phản Hồi Khóa Học Sinh Lý', subject: 'sinh-ly', label: 'Sinh lý', course: '/sinh-ly-1-2-co-ban-chuyen-sau' },
  { id: 'zcd3Mj-VsNU', title: 'Phản Hồi Khóa Học Sinh Lý', subject: 'sinh-ly', label: 'Sinh lý', course: '/sinh-ly-1-2-co-ban-chuyen-sau' },
  { id: '9vy0PhvunS4', title: 'Phản Hồi Khóa Học Giải Phẫu', subject: 'giai-phau', label: 'Giải phẫu', course: '/giai-phau-1-2-co-ban-chuyen-sau' },
  { id: '-XMriPiTsw8', title: 'Phản Hồi Khóa Học Giải Phẫu', subject: 'giai-phau', label: 'Giải phẫu', course: '/giai-phau-1-2-co-ban-chuyen-sau' },
  { id: 'QwZk07ZP8sw', title: 'Phản Hồi Khóa Học Giải Phẫu', subject: 'giai-phau', label: 'Giải phẫu', course: '/giai-phau-1-2-co-ban-chuyen-sau' },
  { id: 'UNl0xfqVFPo', title: 'Phản Hồi Khóa Ôn Thi Nội Trú SĐH', subject: 'noi-tru', label: 'Ôn thi Nội trú', course: '/khoa-hoc-noi-tru-sau-dai-hoc' },
];

const grid = document.querySelector('#video-grid');
const status = document.querySelector('#video-status');
const loadMore = document.querySelector('#load-more');
const filters = [...document.querySelectorAll('.filter-bar button')];
const staticPreview = location.pathname.endsWith('/feedback.html');
let selectedSubject = 'all';
let visibleCount = 6;

function renderVideos() {
  const filtered = selectedSubject === 'all' ? videos : videos.filter((video) => video.subject === selectedSubject);
  grid.innerHTML = filtered.slice(0, visibleCount).map((video, index) => {
    const videoURL = `https://www.youtube.com/watch?v=${video.id}`;
    const slug = video.course.slice(1);
    const courseURL = slug === 'khoa-hoc-noi-tru-sau-dai-hoc'
      ? (staticPreview ? 'courses.html?nhom=residency' : '/khoa-hoc-v2?nhom=residency')
      : `${staticPreview ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2'}?course=${encodeURIComponent(slug)}`;
    return `<article class="video-card">
      <a class="video-media" href="${videoURL}" target="_blank" rel="noopener noreferrer" aria-label="Xem video: ${video.title}">
        <img src="https://img.youtube.com/vi/${video.id}/hqdefault.jpg" alt="Ảnh xem trước video ${video.title}" loading="lazy" />
        <span class="video-fallback" aria-hidden="true">MEDUC<br />PHẢN HỒI</span>
        <span class="play-badge" aria-hidden="true"><svg class="icon"><use href="#i-play" /></svg></span>
      </a>
      <div class="video-card-body"><span class="video-subject">${video.label}</span><h3>${video.title}</h3><div class="video-card-actions"><a href="${videoURL}" target="_blank" rel="noopener noreferrer">Xem video ${String(index + 1).padStart(2, '0')} ↗</a><a href="${courseURL}">Xem khóa học →</a></div></div>
    </article>`;
  }).join('');
  grid.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
  status.textContent = `Đang hiển thị ${Math.min(visibleCount, filtered.length)} / ${filtered.length} video.`;
  loadMore.hidden = visibleCount >= filtered.length;
}

filters.forEach((button) => button.addEventListener('click', () => {
  selectedSubject = button.dataset.filter;
  visibleCount = 6;
  filters.forEach((filter) => filter.setAttribute('aria-pressed', String(filter === button)));
  renderVideos();
}));
loadMore.addEventListener('click', () => { visibleCount += 6; renderVideos(); });
renderVideos();
