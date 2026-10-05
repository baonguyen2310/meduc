(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/course-detail.html');
  const assetBase = staticPreview ? 'assets/' : '/hero-light/assets/';
  const catalogURL = `${assetBase}catalog-data.json`;
  const outlineURL = `${assetBase}course-outline.json`;
  const catalogPage = staticPreview ? 'courses.html' : '/khoa-hoc-v2';
  const params = new URLSearchParams(location.search);
  const requested = params.get('course') || params.get('id') || 'sinh-ly-1-2-co-ban-chuyen-sau';
  const labels = { foundation: 'Y khoa cơ sở', clinical: 'Lâm sàng', residency: 'Nội trú', english: 'Tiếng Anh Y khoa' };
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const displayName = (value) => value.replace(/^\[([^\]]+)\]\s*/, '$1: ').replace(/[\[\]]/g, '').replace(/\s*->\s*/g, ' đến ').replace(/\s+/g, ' ').trim();
  const displayChapter = (value) => value.replace(/\s*\(\d+\s*(?:bài|buổi)\)\s*$/i, '').trim();
  const category = (course) => {
    const ids = course.categories;
    if (ids.includes(105)) return 'english';
    if (ids.includes(103)) return 'residency';
    if (ids.some((id) => [72, 70, 71, 106].includes(id))) return 'clinical';
    return 'foundation';
  };
  const detailPageURL = (course) => `${staticPreview ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2'}?course=${encodeURIComponent(course.url.slice(1))}`;
  const lessonText = (count) => `${count} bài học`;
  const chapterText = (count) => `${count} chương`;

  function renderOverview(chapters) {
    const grid = document.querySelector('#overview-grid');
    const candidates = chapters.filter((chapter) => chapter.title !== 'Nội dung khóa học');
    const items = candidates.length ? candidates.slice(0, 3).map((chapter) => ({
      title: displayChapter(chapter.title),
      label: chapter.lessons.length ? lessonText(chapter.lessons.length) : 'Xem đề cương',
    })) : chapters.flatMap((chapter) => chapter.lessons).slice(0, 3).map((title) => ({ title, label: 'Bài học trong đề cương' }));
    if (!items.length) {
      grid.innerHTML = '<article class="overview-card"><span class="overview-index">ĐỀ CƯƠNG</span><h3>Chưa có dữ liệu chương và bài học trong bản kiểm kê hiện tại.</h3><p>Xem trang khóa học Meduc để biết thông tin mới nhất.</p></article>';
      return;
    }
    grid.innerHTML = items.map((item, index) => `<article class="overview-card"><span class="overview-index">${String(index + 1).padStart(2, '0')} / CHỦ ĐỀ</span><h3>${escape(item.title)}</h3><p>${escape(item.label)}</p></article>`).join('');
  }

  function renderCurriculum(course, chapters) {
    const list = document.querySelector('#chapter-list');
    if (!course.chapters) {
      document.querySelector('#curriculum-title').innerHTML = course.lessons
        ? 'KHÁM PHÁ<br /><span>TỪNG BÀI HỌC.</span>'
        : 'NỘI DUNG<br /><span>KHÓA HỌC.</span>';
    }
    document.querySelector('#curriculum-description').textContent = chapters.length
      ? 'Mở từng phần để xem tên bài học trong đề cương Meduc. Tên chương và bài được lấy từ bản kiểm kê.'
      : 'Bản kiểm kê hiện chưa có tên chương và bài học cho khóa này.';
    document.querySelector('#curriculum-count').innerHTML = `${course.chapters ? `<span>${chapterText(course.chapters)}</span>` : ''}${course.lessons ? `<span>${lessonText(course.lessons)}</span>` : ''}`;
    if (!chapters.length) {
      list.innerHTML = '<div class="chapter-empty"><h3>Chưa có đề cương trong bản kiểm kê.</h3><p>Khóa học đang bật trên Meduc. Hãy mở trang khóa học hiện tại để xem nội dung mới nhất.</p></div>';
      return;
    }
    list.innerHTML = chapters.map((chapter, index) => `<details class="chapter" ${index === 0 ? 'open' : ''}><summary><span class="chapter-number">${String(index + 1).padStart(2, '0')}</span><span class="chapter-title">${escape(displayChapter(chapter.title))}</span><span class="chapter-lessons-count">${chapter.lessons.length ? lessonText(chapter.lessons.length) : 'Chưa có bài'}</span><svg class="icon" aria-hidden="true"><use href="#i-chevron" /></svg></summary>${chapter.lessons.length ? `<ol class="chapter-items">${chapter.lessons.map((lesson, lessonIndex) => `<li><span>${String(lessonIndex + 1).padStart(2, '0')}</span>${escape(lesson)}</li>`).join('')}</ol>` : '<p class="chapter-no-lessons">Chưa có tên bài học trong bản kiểm kê.</p>'}</details>`).join('');
  }

  function renderRelated(course, catalog) {
    const currentCategories = course.categories.filter((id) => id !== 50);
    const related = catalog.filter((other) => other.id !== course.id).map((other) => ({
      course: other,
      score: other.categories.filter((id) => currentCategories.includes(id)).length,
    })).sort((a, b) => b.score - a.score || Math.abs(a.course.id - course.id) - Math.abs(b.course.id - course.id)).slice(0, 3).map((item) => item.course);
    const grid = document.querySelector('#related-grid');
    grid.innerHTML = related.map((item) => `<a class="related-card" href="${escape(detailPageURL(item))}">${item.image ? `<img src="${escape(item.image)}" alt="Ảnh bìa khóa học ${escape(displayName(item.name))}" loading="lazy" />` : ''}<b class="related-fallback" aria-hidden="true">MEDUC</b><div><small>${escape(labels[category(item)])}</small><h3>${escape(displayName(item.name))}</h3><span>Xem khóa học →</span></div></a>`).join('');
    grid.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
  }

  Promise.all([fetch(catalogURL), fetch(outlineURL)]).then(async ([catalogResponse, outlineResponse]) => {
    if (!catalogResponse.ok || !outlineResponse.ok) throw new Error('Không tải được dữ liệu khóa học');
    const catalog = await catalogResponse.json();
    const outline = await outlineResponse.json();
    const course = catalog.courses.find((item) => item.url.slice(1) === requested || String(item.id) === requested);
    if (!course) throw new Error('Không tìm thấy khóa học trong danh mục đang mở');
    const name = displayName(course.name);
    const group = category(course);
    const chapters = outline.outlines[String(course.id)] || [];
    const currentURL = `https://meduc.vn${course.url}`;
    const checkoutURL = `${staticPreview ? 'checkout.html' : '/thanh-toan-v2'}?course=${encodeURIComponent(course.url.slice(1))}`;
    document.title = `${name} — Meduc`;
    document.querySelector('#breadcrumb-current').textContent = name;
    document.querySelector('#detail-category').textContent = labels[group].toUpperCase();
    document.querySelector('#detail-title').textContent = name;
    document.querySelector('#detail-intro').textContent = `Khám phá đề cương ${name} theo từng phần. Xem tên chương và bài học trước khi chọn lộ trình phù hợp với bạn.`;
    document.querySelector('#detail-stats').innerHTML = `${course.chapters ? `<span>${chapterText(course.chapters)}</span>` : ''}${course.lessons ? `<span>${lessonText(course.lessons)}</span>` : ''}<span>Đang mở trên Meduc</span>`;
    document.querySelector('#detail-photo').src = `${assetBase}images/${{ foundation: 'doctor-linh.jpg', clinical: 'doctor-minh.jpg', residency: 'meduc-doctor-04.jpg', english: 'study-editorial.jpg' }[group]}`;
    const cover = document.querySelector('#detail-cover');
    if (course.image) {
      cover.src = course.image;
      cover.alt = `Ảnh bìa khóa học ${name}`;
      cover.addEventListener('error', () => document.querySelector('#detail-cover-box').remove());
    } else {
      document.querySelector('#detail-cover-box').remove();
    }
    for (const id of ['enroll-link', 'bottom-enroll-link']) document.getElementById(id).href = checkoutURL;
    document.getElementById('curriculum-live-link').href = currentURL;
    document.querySelectorAll('a[href="courses.html"]').forEach((link) => link.href = catalogPage);
    renderOverview(chapters);
    renderCurriculum(course, chapters);
    renderRelated(course, catalog.courses);
  }).catch((error) => {
    document.querySelector('#detail-title').textContent = 'KHÔNG TÌM THẤY KHÓA HỌC.';
    document.querySelector('#detail-intro').textContent = error.message;
    document.querySelector('#detail-stats').innerHTML = `<a href="${catalogPage}">Quay lại danh sách khóa học →</a>`;
    document.querySelector('#detail-cover-box').remove();
    for (const id of ['tong-quan', 'de-cuong', 'khoa-hoc-lien-quan']) document.getElementById(id).hidden = true;
  });
})();
