(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/books.html');
  const dataURL = staticPreview ? 'assets/book-catalog.json' : '/hero-light/assets/book-catalog.json';
  const grid = document.querySelector('#book-grid');
  const rail = document.querySelector('#feature-rail');
  const hero = document.querySelector('#hero-books');
  const status = document.querySelector('#book-status');
  const search = document.querySelector('#book-search');
  const stage = document.querySelector('#book-stage');
  const sort = document.querySelector('#book-sort');
  const filters = [...document.querySelectorAll('.book-filters button')];
  const navLinks = [...document.querySelectorAll('[data-jump-subject]')];
  const more = document.querySelector('#book-more');
  const empty = document.querySelector('#book-empty');
  const subjectLabels = { physiology: 'Sinh lý', anatomy: 'Giải phẫu', internal: 'Nội khoa', english: 'Tiếng Anh Y khoa', other: 'Chủ đề khác' };
  const featuredIDs = [83, 151, 190, 147];
  const heroIDs = [83, 151, 190];
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const money = (value) => `${Number(value).toLocaleString('vi-VN')}₫`;
  const effectivePrice = (book) => book.special > 0 && book.special < book.price ? book.special : book.price;
  const subjectsFor = (book) => {
    const groups = [];
    if (book.categories.includes(81)) groups.push('physiology');
    if (book.categories.includes(83)) groups.push('anatomy');
    if (book.categories.includes(84)) groups.push('internal');
    if (book.categories.includes(86)) groups.push('english');
    return groups.length ? groups : ['other'];
  };
  const stagesFor = (book) => {
    const stages = [];
    if (book.categories.includes(109)) stages.push('early');
    if (book.categories.includes(110)) stages.push('middle');
    if (book.categories.includes(111)) stages.push('late');
    return stages;
  };
  const primaryFor = (book) => ['physiology', 'anatomy', 'internal', 'english', 'other'].find((subject) => book.subjects.includes(subject));
  const prepared = (book) => ({ ...book, subjects: subjectsFor(book), stages: stagesFor(book) });
  const cover = (book, label = '') => `${book.image ? `<img src="${escape(book.image)}" alt="Bìa sách ${escape(book.name)}" loading="${label === 'hero' ? 'eager' : 'lazy'}" />` : ''}<b class="book-fallback" aria-hidden="true">${escape(book.name)}</b>`;
  const detailURL = (book) => `${staticPreview ? 'book-detail.html' : '/chi-tiet-sach-v2'}?book=${encodeURIComponent(book.url.slice(1))}`;
  const prices = (book) => {
    const current = effectivePrice(book);
    if (!current) return '<span class="price-missing">Xem giá trên Meduc</span>';
    return `<strong>${money(current)}</strong>${current < book.price ? `<del>${money(book.price)}</del>` : ''}`;
  };
  const pictureFallback = (root) => root.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));

  let books = [];
  let subject = 'all';
  let visibleCount = 12;

  function renderHero() {
    hero.innerHTML = heroIDs.map((id) => books.find((book) => book.id === id)).filter(Boolean).map((book) =>
      `<a class="hero-book" href="${escape(detailURL(book))}" aria-label="Xem chi tiết sách ${escape(book.name)}">${cover(book, 'hero')}</a>`
    ).join('');
    pictureFallback(hero);
  }

  function renderFeatures() {
    rail.innerHTML = featuredIDs.map((id) => books.find((book) => book.id === id)).filter(Boolean).map((book) => `
      <a class="feature-card" href="${escape(detailURL(book))}">
        <span class="feature-image">${cover(book)}</span>
        <span class="feature-copy"><small>${escape(subjectLabels[primaryFor(book)])}</small><strong>${escape(book.name)}</strong><em>Xem thông tin sách <svg class="icon"><use href="#i-arrow" /></svg></em></span>
      </a>`).join('');
    pictureFallback(rail);
  }

  function filteredBooks() {
    const term = normalize(search.value.trim());
    const result = books.filter((book) =>
      (subject === 'all' || book.subjects.includes(subject)) &&
      (stage.value === 'all' || book.stages.includes(stage.value)) &&
      (!term || normalize(book.name + ' ' + book.subjects.map((item) => subjectLabels[item]).join(' ')).includes(term))
    );
    if (sort.value === 'az') result.sort((a, b) => a.name.localeCompare(b.name, 'vi'));
    else if (sort.value === 'price-asc') result.sort((a, b) => (effectivePrice(a) || Infinity) - (effectivePrice(b) || Infinity) || a.id - b.id);
    else if (sort.value === 'price-desc') result.sort((a, b) => (effectivePrice(b) || 0) - (effectivePrice(a) || 0) || a.id - b.id);
    else result.sort((a, b) => b.id - a.id);
    return result;
  }

  function renderBooks() {
    const result = filteredBooks();
    grid.innerHTML = result.slice(0, visibleCount).map((book) => `
      <article class="book-card">
        <a class="book-cover" href="${escape(detailURL(book))}" aria-label="Xem chi tiết sách ${escape(book.name)}">${cover(book)}</a>
        <div class="book-card-body"><span class="book-subject">${escape(subjectLabels[primaryFor(book)])}</span><h3>${escape(book.name)}</h3><div class="book-prices">${prices(book)}</div><a class="book-detail-link" href="${escape(detailURL(book))}">Xem chi tiết sách <svg class="icon"><use href="#i-arrow" /></svg></a></div>
      </article>`).join('');
    status.textContent = result.length ? `Hiển thị ${Math.min(visibleCount, result.length)} / ${result.length} sách đang mở` : 'Không tìm thấy sách phù hợp';
    empty.hidden = result.length > 0;
    more.hidden = visibleCount >= result.length;
    pictureFallback(grid);
  }

  function setSubject(next) {
    subject = next;
    visibleCount = 12;
    filters.forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.subject === next)));
    navLinks.forEach((link) => {
      if (link.dataset.jumpSubject === next) link.setAttribute('aria-current', 'page');
      else link.removeAttribute('aria-current');
    });
    renderBooks();
  }

  filters.forEach((button) => button.addEventListener('click', () => setSubject(button.dataset.subject)));
  navLinks.forEach((link) => link.addEventListener('click', () => setSubject(link.dataset.jumpSubject)));
  search.addEventListener('input', () => { visibleCount = 12; renderBooks(); });
  stage.addEventListener('change', () => { visibleCount = 12; renderBooks(); });
  sort.addEventListener('change', renderBooks);
  more.addEventListener('click', () => { visibleCount += 12; renderBooks(); });
  document.querySelector('#book-clear').addEventListener('click', () => { search.value = ''; stage.value = 'all'; sort.value = 'default'; setSubject('all'); search.focus(); });

  fetch(dataURL).then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }).then((data) => {
    books = data.books.map(prepared);
    if (books.length !== data.count) throw new Error('Số sách không khớp dữ liệu');
    document.querySelector('#book-total').textContent = `${books.length} đầu sách đang mở tại Meduc`;
    for (const group of ['all', ...Object.keys(subjectLabels)]) {
      document.querySelector(`[data-count="${group}"]`).textContent = group === 'all' ? books.length : books.filter((book) => book.subjects.includes(group)).length;
    }
    renderHero();
    renderFeatures();
    const requested = new URLSearchParams(location.search).get('mon');
    setSubject(subjectLabels[requested] ? requested : 'all');
  }).catch(() => {
    status.innerHTML = 'Không tải được danh mục. <a href="https://meduc.vn/sach-y-khoa">Xem sách trên Meduc ↗</a>';
    more.hidden = true;
  });
})();
