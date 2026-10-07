(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/my-courses.html');
  const assetsBase = staticPreview ? 'assets/' : '/hero-light/assets/';
  const courseBase = staticPreview ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2';
  const examples = [
    { id: 48, completed: 14, subject: 'Sinh lý học' },
    { id: 99, completed: 9, subject: 'Giải phẫu' },
    { id: 112, completed: 5, subject: 'Điện tâm đồ' },
    { id: 51, completed: 30, subject: 'Lâm sàng nội khoa' },
  ];
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase();
  const cleanName = (value) => value.replace(/^\[/, '').replace(/\]/g, '').replace(/\s*-?>\s*/g, ' → ').replace(/\s+/g, ' ').trim();
  const detailLink = (item) => `${courseBase}?course=${encodeURIComponent(item.url.slice(1))}`;
  const icon = '<svg class="icon" aria-hidden="true"><use href="#i-arrow" /></svg>';

  if (staticPreview) {
    document.querySelectorAll('a[href="/member/login"]').forEach((link) => { link.href = 'https://meduc.vn/member/login'; });
  }

  function enrich(catalog, outline) {
    const byId = new Map(catalog.courses.map((course) => [course.id, course]));
    return examples.map((sample) => {
      const course = byId.get(sample.id);
      const modules = outline.outlines[String(sample.id)] || [];
      if (!course || !course.url || !course.image) throw new Error(`Missing example course ${sample.id}`);
      const lessons = modules.flatMap((module) => module.lessons);
      if (lessons.length !== course.lessons) throw new Error(`Outline count mismatch for ${sample.id}`);
      return {
        ...course, ...sample, title: cleanName(course.name),
        percent: Math.round(100 * sample.completed / course.lessons),
        complete: sample.completed >= course.lessons,
        nextLesson: lessons[sample.completed] || '',
      };
    });
  }

  function progress(item) {
    return `<div class="learning-progress"><div class="learning-progress-label"><span>${item.completed}/${item.lessons} bài minh họa</span><strong>${item.percent}%</strong></div><div class="learning-progress-track" aria-label="Tiến độ minh họa ${item.percent}%"><span style="width:${item.percent}%"></span></div></div>`;
  }

  function renderFeatured(item) {
    const feature = document.querySelector('#featured-course');
    feature.innerHTML = `<div class="learning-feature-image"><img src="${escape(item.image)}" alt="Ảnh bìa khóa ${escape(item.title)}" /><a href="${escape(detailLink(item))}" aria-label="Xem đề cương khóa ${escape(item.title)}"><svg class="icon" aria-hidden="true"><use href="#i-book" /></svg></a></div><div class="learning-feature-content"><small>KHÓA ĐANG HỌC · TIẾN ĐỘ MINH HỌA</small><h3>${escape(item.title)}</h3><p>${escape(item.subject)} · ${item.chapters} chương · ${item.lessons} bài học</p><div class="learning-feature-lesson"><span>BÀI TIẾP THEO TRONG ĐỀ CƯƠNG</span><strong>${escape(item.nextLesson)}</strong></div>${progress(item)}<div class="learning-feature-actions"><a class="button" href="${escape(detailLink(item))}">Xem đề cương ${icon}</a><span>Nội dung khóa học từ Meduc</span></div></div>`;
    feature.querySelector('img').addEventListener('error', (event) => event.currentTarget.remove());

    document.querySelector('#next-lesson-title').textContent = item.nextLesson;
    document.querySelector('#next-lesson-course').textContent = item.title;
    document.querySelector('#next-lesson-link').href = detailLink(item);
  }

  function card(item) {
    const status = item.complete ? 'HOÀN THÀNH · MINH HỌA' : 'ĐANG HỌC · MINH HỌA';
    const note = item.complete ? 'Đã xem hết danh sách bài học trong ví dụ.' : `Tiếp theo: ${item.nextLesson}`;
    return `<article class="learning-card"><div class="learning-card-cover"><img src="${escape(item.image)}" alt="Ảnh bìa khóa ${escape(item.title)}" loading="lazy" /><span class="${item.complete ? 'is-complete' : ''}">${status}</span></div><div class="learning-card-body"><small>${escape(item.subject)}</small><h3>${escape(item.title)}</h3><p class="learning-card-lesson">${escape(note)}</p>${progress(item)}<a class="learning-card-link" href="${escape(detailLink(item))}">Xem đề cương khóa học ${icon}</a></div></article>`;
  }

  Promise.all([
    fetch(`${assetsBase}catalog-data.json`).then((response) => { if (!response.ok) throw new Error('Catalog unavailable'); return response.json(); }),
    fetch(`${assetsBase}course-outline.json`).then((response) => { if (!response.ok) throw new Error('Outline unavailable'); return response.json(); }),
  ]).then(([catalog, outline]) => {
    const items = enrich(catalog, outline);
    if (window.renderMyCoursesInsights) window.renderMyCoursesInsights(items);
    renderFeatured(items[0]);
    const grid = document.querySelector('#course-grid');
    const empty = document.querySelector('#course-empty');
    const search = document.querySelector('#course-search');
    const buttons = [...document.querySelectorAll('.learning-tabs button')];
    let filter = 'all';

    document.querySelector('#count-all').textContent = items.length;
    document.querySelector('#count-active').textContent = items.filter((item) => !item.complete).length;
    document.querySelector('#count-complete').textContent = items.filter((item) => item.complete).length;

    function render() {
      const term = normalize(search.value.trim());
      const visible = items.filter((item) => (filter === 'all' || (filter === 'complete') === item.complete) && normalize(`${item.title} ${item.subject}`).includes(term));
      grid.innerHTML = visible.map(card).join('');
      grid.hidden = visible.length === 0;
      empty.hidden = visible.length !== 0;
      grid.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
    }
    buttons.forEach((button) => button.addEventListener('click', () => {
      filter = button.dataset.filter;
      buttons.forEach((candidate) => { const active = candidate === button; candidate.classList.toggle('is-active', active); candidate.setAttribute('aria-pressed', String(active)); });
      render();
    }));
    search.addEventListener('input', render);
    document.querySelector('#reset-filters').addEventListener('click', () => {
      search.value = '';
      buttons.find((button) => button.dataset.filter === 'all').click();
    });
    render();
  }).catch(() => {
    document.querySelector('#featured-course').innerHTML = '<div class="learning-feature-loading">Chưa tải được danh mục. <a href="/khoa-hoc-v2">Xem các khóa học Meduc ↗</a></div>';
    document.querySelector('#course-grid').innerHTML = '<p>Chưa tải được danh mục khóa học.</p>';
    document.querySelector('#next-lesson-title').textContent = 'Khám phá các khóa học Meduc';
  });
})();
