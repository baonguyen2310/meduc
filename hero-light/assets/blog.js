(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/blog.html');
  const dataURL = staticPreview ? 'assets/blog-catalog.json' : '/hero-light/assets/blog-catalog.json';
  const grid = document.querySelector('#blog-grid');
  const rail = document.querySelector('#blog-hero-rail');
  const spotlight = document.querySelector('#blog-spotlight-grid');
  const status = document.querySelector('#blog-status');
  const search = document.querySelector('#blog-search');
  const sort = document.querySelector('#blog-sort');
  const filters = [...document.querySelectorAll('[data-topic]')];
  const topicLinks = [...document.querySelectorAll('[data-topic-jump]')];
  const more = document.querySelector('#blog-more');
  const empty = document.querySelector('#blog-empty');
  const topicLabels = { all: 'Tất cả chủ đề', anatomy: 'Giải phẫu', physiology: 'Sinh lý', biochemistry: 'Hóa sinh', internal: 'Nội khoa', english: 'Tiếng Anh Y khoa', experience: 'Kinh nghiệm học Y', other: 'Chủ đề khác' };
  const heroIDs = [314, 321, 327, 324, 363];
  const spotlightIDs = [326, 325, 319];
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const dateLabel = (value) => value.split('-').reverse().join('/');
  const cleanName = (name) => name.replace(/^\[[^\]]+\]\s*/, '').trim();
  const articleURL = (item) => `${staticPreview ? 'blog-detail.html' : '/bai-viet-chi-tiet-v2'}?post=${encodeURIComponent(item.url.slice(1))}`;
  const imageHTML = (item) => `${item.image ? `<img src="${escape(item.image)}" alt="Ảnh minh họa bài viết ${escape(cleanName(item.name))}" loading="lazy" />` : ''}<span class="blog-image-fallback" aria-hidden="true">MEDUC<br />JOURNAL</span>`;

  function topicFor(item) {
    const ids = item.categories;
    if (ids.includes(93) || ids.includes(117)) return 'anatomy';
    if (ids.includes(91) || ids.includes(119)) return 'physiology';
    if (ids.includes(92) || ids.includes(118)) return 'biochemistry';
    if (ids.includes(94) || ids.includes(116)) return 'internal';
    if (ids.includes(96) || ids.includes(114)) return 'english';
    if (ids.includes(100)) return 'experience';
    return 'other';
  }

  function prepare(item) {
    return { ...item, title: cleanName(item.name), topic: topicFor(item), searchable: normalize(`${item.name} ${item.summary} ${topicLabels[topicFor(item)]}`) };
  }

  function imageFallback(root) {
    root.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
  }

  let articles = [];
  let topic = 'all';
  let visibleCount = 12;

  function featuredByIDs(ids) {
    return ids.map((id) => articles.find((item) => item.id === id)).filter(Boolean);
  }

  function renderHero() {
    rail.innerHTML = featuredByIDs(heroIDs).map((item) => `<a class="blog-hero-card" href="${escape(articleURL(item))}"><span class="blog-hero-image">${imageHTML(item)}</span><span><small>${escape(topicLabels[item.topic])}</small><strong>${escape(item.title)}</strong></span></a>`).join('');
    imageFallback(rail);
  }

  function renderFeature() {
    const item = articles.find((article) => article.id === 331) || articles[0];
    document.querySelector('#blog-feature').innerHTML = `<div class="blog-feature-copy"><small>${escape(topicLabels[item.topic])} · BÀI VIẾT TIÊU BIỂU</small><h2 id="feature-title">${escape(item.title)}</h2><p>${escape(item.summary)}</p><div class="blog-feature-meta"><time datetime="${escape(item.date)}">${dateLabel(item.date)}</time><span>·</span><span>Meduc Journal</span></div><a class="blog-feature-link" href="${escape(articleURL(item))}">Đọc bài viết <svg class="icon"><use href="#i-arrow" /></svg></a></div><a class="blog-feature-media" href="${escape(articleURL(item))}" aria-label="Đọc ${escape(item.title)}">${imageHTML(item)}</a>`;
    imageFallback(document.querySelector('#blog-feature'));
  }

  function renderSpotlight() {
    spotlight.innerHTML = featuredByIDs(spotlightIDs).map((item) => `<a class="blog-spotlight-card" href="${escape(articleURL(item))}"><span class="blog-spotlight-image">${imageHTML(item)}</span><span class="blog-spotlight-copy"><small>${escape(topicLabels[item.topic])} · ${dateLabel(item.date)}</small><strong>${escape(item.title)}</strong><em>Đọc bài viết <span aria-hidden="true">→</span></em></span></a>`).join('');
    imageFallback(spotlight);
  }

  function filteredArticles() {
    const term = normalize(search.value.trim());
    const result = articles.filter((item) => (topic === 'all' || item.topic === topic) && (!term || item.searchable.includes(term)));
    if (sort.value === 'oldest') result.sort((a, b) => a.date.localeCompare(b.date) || a.id - b.id);
    else if (sort.value === 'az') result.sort((a, b) => a.title.localeCompare(b.title, 'vi'));
    else result.sort((a, b) => b.date.localeCompare(a.date) || b.id - a.id);
    return result;
  }

  function renderGrid() {
    const result = filteredArticles();
    grid.innerHTML = result.slice(0, visibleCount).map((item) => `<article class="blog-card"><a class="blog-card-image" href="${escape(articleURL(item))}" aria-label="Đọc ${escape(item.title)}">${imageHTML(item)}</a><span class="blog-card-category">${escape(topicLabels[item.topic])}</span><h3>${escape(item.title)}</h3><p>${escape(item.summary)}</p><div class="blog-card-footer"><time datetime="${escape(item.date)}">${dateLabel(item.date)}</time><a href="${escape(articleURL(item))}">Đọc bài <svg class="icon"><use href="#i-arrow" /></svg></a></div></article>`).join('');
    status.textContent = result.length ? `Hiển thị ${Math.min(visibleCount, result.length)} / ${result.length} bài viết` : 'Không tìm thấy bài viết phù hợp';
    document.querySelector('#blog-active-topic').textContent = topicLabels[topic];
    empty.hidden = result.length > 0;
    more.hidden = visibleCount >= result.length;
    imageFallback(grid);
  }

  function setTopic(next) {
    topic = next;
    visibleCount = 12;
    filters.forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.topic === next)));
    topicLinks.forEach((link) => {
      if (link.dataset.topicJump === next) link.setAttribute('aria-current', 'page');
      else link.removeAttribute('aria-current');
    });
    renderGrid();
  }

  filters.forEach((button) => button.addEventListener('click', () => setTopic(button.dataset.topic)));
  topicLinks.forEach((link) => link.addEventListener('click', () => setTopic(link.dataset.topicJump)));
  search.addEventListener('input', () => { visibleCount = 12; renderGrid(); });
  sort.addEventListener('change', renderGrid);
  more.addEventListener('click', () => { visibleCount += 12; renderGrid(); });
  document.querySelector('#blog-clear').addEventListener('click', () => { search.value = ''; sort.value = 'newest'; setTopic('all'); search.focus(); });

  fetch(dataURL).then(async (response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    articles = data.articles.map(prepare);
    if (articles.length !== data.count) throw new Error('Số bài viết không khớp dữ liệu');
    document.querySelector('#blog-total').textContent = `${articles.length} bài viết đang mở tại Meduc`;
    for (const key of Object.keys(topicLabels)) document.querySelector(`[data-count="${key}"]`).textContent = key === 'all' ? articles.length : articles.filter((item) => item.topic === key).length;
    renderHero();
    renderFeature();
    renderSpotlight();
    const requested = new URLSearchParams(location.search).get('chu-de');
    setTopic(requested && topicLabels[requested] ? requested : 'all');
  }).catch(() => {
    status.innerHTML = 'Không tải được danh mục. <a href="https://meduc.vn/bai-viet">Xem blog trên Meduc ↗</a>';
    document.querySelector('#blog-feature').innerHTML = '<p class="blog-feature-placeholder">Chưa tải được bài viết tiêu biểu.</p>';
    more.hidden = true;
  });
})();
