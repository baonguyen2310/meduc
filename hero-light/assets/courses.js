(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/courses.html');
  const dataURL = staticPreview ? 'assets/catalog-data.json' : '/hero-light/assets/catalog-data.json';
  const grid = document.querySelector('#course-grid');
  const rail = document.querySelector('#spotlight-rail');
  const status = document.querySelector('#catalog-status');
  const search = document.querySelector('#course-search');
  const sort = document.querySelector('#course-sort');
  const filters = [...document.querySelectorAll('.catalog-filters button')];
  const more = document.querySelector('#load-more');
  const empty = document.querySelector('#catalog-empty');
  const groupLabels = {
    foundation: 'Y khoa cơ sở', clinical: 'Lâm sàng', residency: 'Nội trú', english: 'Tiếng Anh Y khoa',
  };
  const colors = {
    foundation: '#28515e', clinical: '#4c374a', residency: '#31384d', english: '#58614c',
  };
  const featuredIDs = [48, 51, 52, 99, 157];
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const displayName = (value) => value.replace(/^\[([^\]]+)\]\s*/, '$1: ').replace(/[\[\]]/g, '').replace(/\s*->\s*/g, ' đến ').replace(/\s+/g, ' ').trim();
  const groupsFor = (course) => {
    const categories = course.categories;
    const groups = [];
    if (categories.some((id) => [102, 67, 68, 69].includes(id))) groups.push('foundation');
    if (categories.some((id) => [72, 70, 71, 106].includes(id))) groups.push('clinical');
    if (categories.includes(103)) groups.push('residency');
    if (categories.includes(105)) groups.push('english');
    return groups.length ? groups : ['foundation'];
  };
  const primaryFor = (course) => {
    const groups = groupsFor(course);
    return ['english', 'residency', 'clinical', 'foundation'].find((group) => groups.includes(group));
  };
  const detailURL = (course) => `${staticPreview ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2'}?course=${encodeURIComponent(course.url.slice(1))}`;
  const linkAttributes = '';
  const cardImage = (course) => course.image
    ? `<img src="${escape(course.image)}" alt="Ảnh bìa khóa học ${escape(displayName(course.name))}" loading="lazy" />`
    : '';
  const fallback = (course) => `<b class="course-image-fallback" aria-hidden="true">${escape(displayName(course.name).split(':')[0])}</b>`;
  const lessonMeta = (course) => [
    course.chapters ? `${course.chapters} chương` : '',
    course.lessons ? `${course.lessons} bài học` : '',
  ].filter(Boolean).map((item) => `<span>${item}</span>`).join('');
  const prepared = (course) => ({ ...course, groups: groupsFor(course), primary: primaryFor(course), displayName: displayName(course.name) });
  let courses = [];
  let selectedGroup = 'all';
  let visibleCount = 9;

  function renderSpotlight() {
    rail.innerHTML = featuredIDs.map((id) => courses.find((course) => course.id === id)).filter(Boolean).map((course, index) => `
      <a class="spotlight-card" href="${escape(detailURL(course))}"${linkAttributes} style="--card-color:${colors[course.primary]}">
        ${cardImage(course)}${fallback(course)}
        <span class="spotlight-card-copy"><small>${String(index + 1).padStart(2, '0')} / ${escape(groupLabels[course.primary].toUpperCase())}</small><strong>${escape(course.displayName)}</strong><em>${course.lessons ? `${course.lessons} bài học` : 'Xem nội dung khóa học'} <svg class="icon"><use href="#i-arrow" /></svg></em></span>
      </a>`).join('');
  }

  function filteredCourses() {
    const term = normalize(search.value.trim());
    const filtered = courses.filter((course) =>
      (selectedGroup === 'all' || course.groups.includes(selectedGroup)) &&
      (!term || normalize(course.name + ' ' + course.groups.map((group) => groupLabels[group]).join(' ')).includes(term))
    );
    if (sort.value === 'az') filtered.sort((a, b) => a.displayName.localeCompare(b.displayName, 'vi'));
    if (sort.value === 'za') filtered.sort((a, b) => b.displayName.localeCompare(a.displayName, 'vi'));
    if (sort.value === 'lessons') filtered.sort((a, b) => b.lessons - a.lessons || a.id - b.id);
    return filtered;
  }

  function renderCourses() {
    const filtered = filteredCourses();
    grid.innerHTML = filtered.slice(0, visibleCount).map((course) => `
      <article class="course-card" style="--card-color:${colors[course.primary]}">
        <a class="course-card-image" href="${escape(detailURL(course))}"${linkAttributes} aria-label="Xem khóa học ${escape(course.displayName)}">
          ${cardImage(course)}${fallback(course)}<span>${escape(groupLabels[course.primary])}</span>
        </a>
        <div class="course-card-body"><h3>${escape(course.displayName)}</h3><div class="course-card-meta">${lessonMeta(course)}</div><a class="course-card-link" href="${escape(detailURL(course))}"${linkAttributes}>Xem chi tiết khóa học <svg class="icon"><use href="#i-arrow" /></svg></a></div>
      </article>`).join('');
    status.textContent = filtered.length
      ? `Hiển thị ${Math.min(visibleCount, filtered.length)} / ${filtered.length} khóa học đang mở`
      : 'Không tìm thấy khóa học phù hợp';
    empty.hidden = filtered.length > 0;
    more.hidden = visibleCount >= filtered.length;
    grid.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
  }

  function setGroup(group) {
    selectedGroup = group;
    visibleCount = 9;
    filters.forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.group === group)));
    renderCourses();
  }

  filters.forEach((button) => button.addEventListener('click', () => setGroup(button.dataset.group)));
  document.querySelectorAll('[data-jump-group]').forEach((link) => link.addEventListener('click', () => setGroup(link.dataset.jumpGroup)));
  search.addEventListener('input', () => { visibleCount = 9; renderCourses(); });
  sort.addEventListener('change', renderCourses);
  more.addEventListener('click', () => { visibleCount += 9; renderCourses(); });
  document.querySelector('#clear-filters').addEventListener('click', () => { search.value = ''; setGroup('all'); search.focus(); });

  fetch(dataURL).then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }).then((data) => {
    courses = data.courses.map(prepared);
    if (courses.length !== data.count) throw new Error('Số khóa học không khớp dữ liệu');
    document.querySelector('#hero-total').textContent = `${courses.length} khóa học đang mở tại Meduc`;
    for (const group of ['all', 'foundation', 'clinical', 'residency', 'english']) {
      const count = group === 'all' ? courses.length : courses.filter((course) => course.groups.includes(group)).length;
      document.querySelector(`[data-count="${group}"]`).textContent = count;
    }
    renderSpotlight();
    rail.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
    const requestedGroup = new URLSearchParams(location.search).get('nhom');
    setGroup(groupLabels[requestedGroup] ? requestedGroup : 'all');
  }).catch(() => {
    status.innerHTML = 'Không tải được danh mục. <a href="https://meduc.vn/khoa-hoc">Xem khóa học trên Meduc ↗</a>';
    more.hidden = true;
  });
})();
