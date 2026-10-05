(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/documents.html');
  const dataURL = staticPreview ? 'assets/document-catalog.json' : '/hero-light/assets/document-catalog.json';
  const grid = document.querySelector('#document-grid');
  const pathGrid = document.querySelector('#document-path-grid');
  const status = document.querySelector('#document-status');
  const search = document.querySelector('#document-search');
  const heroSearch = document.querySelector('#hero-document-search');
  const sort = document.querySelector('#document-sort');
  const yearFilters = [...document.querySelectorAll('[data-year]')];
  const subjectLinks = [...document.querySelectorAll('[data-jump-subject]')];
  const more = document.querySelector('#document-more');
  const empty = document.querySelector('#document-empty');
  const subjectLabels = { physiology: 'Sinh lý', biochem: 'Hóa sinh', internal: 'Nội khoa', surgery: 'Ngoại khoa', english: 'Tiếng Anh Y khoa', parasite: 'Ký sinh trùng', other: 'Môn khác' };
  const subjectCategories = { physiology: 73, biochem: 74, internal: 76, surgery: 77, english: 78, parasite: 121 };
  const yearCategories = { 1: 75, 2: 122, 3: 123, 4: 124 };
  const pathIDs = { 1: 476, 2: 494, 3: 457, 4: 463 };
  const pathColors = { 1: '#e9e7dc', 2: '#e4e8e6', 3: '#e9e6ec', 4: '#ede4df' };
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const dateLabel = (value) => value.split('-').reverse().join('/');
  const detailURL = (item) => `${staticPreview ? 'resource-detail.html' : '/tai-lieu-chi-tiet-v2'}?resource=${encodeURIComponent(item.url.slice(1))}`;
  const cover = (item) => `${item.image ? `<img src="${escape(item.image)}" alt="Ảnh đại diện tài liệu ${escape(item.name)}" loading="lazy" />` : ''}<b class="document-image-fallback" aria-hidden="true">${escape(item.title)}</b>`;
  const imageFallback = (root) => root.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));

  function prepare(item) {
    const bracket = item.name.match(/^\[([^\]]+)\]\s*(.*)$/);
    const topic = bracket ? bracket[1].replace(/^Năm\s*[1-4]\s*[-–]?\s*/i, '').trim() : '';
    const years = Object.entries(yearCategories).filter(([, category]) => item.categories.includes(category)).map(([year]) => year);
    if (!years.length) {
      const fromTitle = item.name.match(/^\[Năm\s*([1-4])\b/i);
      if (fromTitle) years.push(fromTitle[1]);
    }
    const subjects = Object.entries(subjectCategories).filter(([, category]) => item.categories.includes(category)).map(([subject]) => subject);
    const normalizedName = normalize(item.name);
    for (const [group, keyword] of Object.entries({ physiology: 'sinh ly', biochem: 'hoa sinh', internal: 'noi khoa', surgery: 'ngoai khoa', english: 'tieng anh', parasite: 'ky sinh trung' })) {
      if (normalizedName.includes(keyword) && !subjects.includes(group)) subjects.push(group);
    }
    if (!subjects.length) subjects.push('other');
    const subject = subjects[0];
    return {
      ...item, years, subjects, title: bracket?.[2] || item.name,
      kicker: topic || subjectLabels[subject],
      searchable: normalize(`${item.name} ${item.summary} ${topic} ${subjects.map((group) => subjectLabels[group]).join(' ')}`),
    };
  }

  let documents = [];
  let year = 'all';
  let subject = 'all';
  let visibleCount = 12;

  function renderPaths() {
    pathGrid.innerHTML = [1, 2, 3, 4].map((number) => {
      const item = documents.find((document) => document.id === pathIDs[number]);
      const count = documents.filter((document) => document.years.includes(String(number))).length;
      return `<a class="document-path-card" href="#catalog" data-path-year="${number}" style="--path-bg:${pathColors[number]}">
        <span class="document-path-picture">${item ? cover(item) : ''}<span class="document-path-number">0${number}</span></span>
        <span class="document-path-copy"><small>CHẶNG 0${number}</small><strong>Y khoa năm ${number}</strong><em>${count} tài liệu <svg class="icon"><use href="#i-arrow" /></svg></em></span>
      </a>`;
    }).join('');
    imageFallback(pathGrid);
    pathGrid.querySelectorAll('[data-path-year]').forEach((link) => link.addEventListener('click', () => setYear(link.dataset.pathYear)));
  }

  function filteredDocuments() {
    const term = normalize(search.value.trim());
    const result = documents.filter((item) =>
      (year === 'all' || (year === 'other' ? item.years.length === 0 : item.years.includes(year))) &&
      (subject === 'all' || item.subjects.includes(subject)) &&
      (!term || item.searchable.includes(term))
    );
    if (sort.value === 'oldest') result.sort((a, b) => a.date.localeCompare(b.date) || a.id - b.id);
    else if (sort.value === 'az') result.sort((a, b) => a.title.localeCompare(b.title, 'vi'));
    else result.sort((a, b) => b.date.localeCompare(a.date) || b.id - a.id);
    return result;
  }

  function renderDocuments() {
    const result = filteredDocuments();
    grid.innerHTML = result.slice(0, visibleCount).map((item) => `
      <article class="document-card">
        <a class="document-card-cover" href="${escape(detailURL(item))}" aria-label="Xem tài liệu ${escape(item.name)}">${cover(item)}<span class="document-card-badge">${item.years.length ? `Năm ${item.years.join(', ')}` : 'Tài liệu Y khoa'}</span></a>
        <div class="document-card-body"><span class="document-card-kicker">${escape(item.kicker)}</span><h3>${escape(item.title)}</h3><p>${escape(item.summary || 'Xem mô tả và tệp đính kèm trên Meduc.')}</p><div class="document-card-meta"><svg class="icon"><use href="#i-file" /></svg><span>${item.fileCount} tệp đính kèm</span><span>·</span><span>${dateLabel(item.date)}</span></div><a class="document-card-link" href="${escape(detailURL(item))}">Xem tài liệu <svg class="icon"><use href="#i-arrow" /></svg></a></div>
      </article>`).join('');
    status.textContent = result.length ? `Hiển thị ${Math.min(visibleCount, result.length)} / ${result.length} tài liệu đang mở` : 'Không tìm thấy tài liệu phù hợp';
    empty.hidden = result.length > 0;
    more.hidden = visibleCount >= result.length;
    document.querySelector('#active-filter-label').textContent = subject === 'all' ? 'Tất cả môn học' : subjectLabels[subject];
    imageFallback(grid);
  }

  function setYear(next) {
    year = next;
    visibleCount = 12;
    yearFilters.forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.year === next)));
    renderDocuments();
  }

  function setSubject(next) {
    subject = next;
    visibleCount = 12;
    subjectLinks.forEach((link) => {
      if (link.dataset.jumpSubject === next) link.setAttribute('aria-current', 'page');
      else link.removeAttribute('aria-current');
    });
    renderDocuments();
  }

  yearFilters.forEach((button) => button.addEventListener('click', () => setYear(button.dataset.year)));
  subjectLinks.forEach((link) => link.addEventListener('click', () => setSubject(link.dataset.jumpSubject)));
  search.addEventListener('input', () => { heroSearch.value = search.value; visibleCount = 12; renderDocuments(); });
  heroSearch.addEventListener('input', () => { search.value = heroSearch.value; visibleCount = 12; renderDocuments(); });
  document.querySelector('#hero-search-form').addEventListener('submit', (event) => { event.preventDefault(); document.querySelector('#catalog').scrollIntoView({ behavior: 'smooth' }); });
  sort.addEventListener('change', renderDocuments);
  more.addEventListener('click', () => { visibleCount += 12; renderDocuments(); });
  document.querySelector('#document-clear').addEventListener('click', () => { search.value = ''; heroSearch.value = ''; sort.value = 'newest'; setYear('all'); setSubject('all'); search.focus(); });

  fetch(dataURL).then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }).then((data) => {
    documents = data.documents.map(prepare);
    if (documents.length !== data.count) throw new Error('Số tài liệu không khớp dữ liệu');
    document.querySelector('#document-total').textContent = `${documents.length} tài liệu đang mở tại Meduc`;
    for (const group of ['all', '1', '2', '3', '4', 'other']) {
      const count = group === 'all' ? documents.length : group === 'other' ? documents.filter((item) => item.years.length === 0).length : documents.filter((item) => item.years.includes(group)).length;
      document.querySelector(`[data-year-count="${group}"]`).textContent = count;
    }
    renderPaths();
    const requested = new URLSearchParams(location.search).get('nam');
    setYear(['1', '2', '3', '4'].includes(requested) ? requested : 'all');
  }).catch(() => {
    status.innerHTML = 'Không tải được danh mục. <a href="https://meduc.vn/tai-lieu-hoc-tap">Xem tài liệu trên Meduc ↗</a>';
    more.hidden = true;
  });
})();
