(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/recommendations.html');
  const catalogURL = staticPreview ? 'assets/catalog-data.json' : '/hero-light/assets/catalog-data.json';
  const interestInputs = [...document.querySelectorAll('input[name="interest"]')];
  const goalInputs = [...document.querySelectorAll('input[name="goal"]')];
  const steps = [
    document.querySelector('#interest-step'),
    document.querySelector('#goal-step'),
    document.querySelector('#result-step'),
  ];
  const interestLabels = {
    anatomy: 'Giải phẫu', physiology: 'Sinh lý', biochemistry: 'Hóa sinh',
    internal: 'Nội khoa', surgery: 'Ngoại khoa', pediatrics: 'Nhi khoa',
    obstetrics: 'Sản khoa', english: 'Tiếng Anh Y khoa',
  };
  const goalLabels = {
    foundation: 'Y khoa cơ sở', clinical: 'Lâm sàng',
    residency: 'Thi nội trú', english: 'Tiếng Anh Y khoa',
  };
  const subjectIDs = {
    anatomy: [99, 201, 203],
    physiology: [48, 176, 193, 199],
    biochemistry: [180, 195, 215],
    internal: [51, 96, 112, 157, 200, 206],
    surgery: [52, 174, 220],
    pediatrics: [107, 158],
    obstetrics: [53, 106],
    english: [101, 192],
  };
  const fallbackOrder = [99, 48, 51, 52, 157, 101, 195, 107, 53];
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const displayName = (value) => value.replace(/^\[([^\]]+)\]\s*/, '$1: ').replace(/[\[\]]/g, '').replace(/\s*->\s*/g, ' đến ').replace(/\s+/g, ' ').trim();
  const detailURL = (course) => (staticPreview ? 'course-detail.html' : '/khoa-hoc-chi-tiet-v2') + '?course=' + encodeURIComponent(course.url.slice(1));
  const checkoutURL = (course) => (staticPreview ? 'checkout.html' : '/thanh-toan-v2') + '?course=' + encodeURIComponent(course.url.slice(1));
  const selectedInterests = () => interestInputs.filter((input) => input.checked).map((input) => input.value);
  const selectedGoal = () => goalInputs.find((input) => input.checked)?.value || '';
  let courses = [];
  let catalogError = false;
  let activeStep = 1;

  function goalMatches(course, goal) {
    const categories = course.categories;
    if (goal === 'foundation') return categories.some((id) => [102, 67, 68, 69].includes(id)) && !categories.includes(103);
    if (goal === 'clinical') return categories.some((id) => [72, 70, 71, 106].includes(id)) && !categories.includes(103);
    if (goal === 'residency') return categories.includes(103);
    if (goal === 'english') return categories.includes(105);
    return false;
  }

  function interestMatches(course, interests) {
    return interests.filter((interest) => subjectIDs[interest].includes(course.id));
  }

  function score(course, interests, goal) {
    const subjectHits = interestMatches(course, interests).length;
    const goalHit = goalMatches(course, goal);
    const curated = fallbackOrder.indexOf(course.id);
    return subjectHits * 8 + (goalHit ? 16 : 0) + (subjectHits && goalHit ? 6 : 0)
      + (curated === -1 ? 0 : (fallbackOrder.length - curated) / 10);
  }

  function reason(course, interests, goal) {
    const matched = interestMatches(course, interests);
    if (matched.length && goalMatches(course, goal)) {
      return interestLabels[matched[0]] === goalLabels[goal]
        ? 'Đúng môn và mục tiêu: ' + interestLabels[matched[0]]
        : interestLabels[matched[0]] + ' · ' + goalLabels[goal];
    }
    if (matched.length) return 'Môn bạn quan tâm: ' + interestLabels[matched[0]];
    if (goalMatches(course, goal)) return 'Theo mục tiêu: ' + goalLabels[goal];
    return 'Khóa học đang mở tại Meduc';
  }

  function imageHTML(course) {
    return '<span class="recommend-image-fallback" aria-hidden="true">MEDUC<br />COURSES</span>'
      + (course.image ? '<img src="' + escape(course.image) + '" alt="Ảnh bìa khóa học ' + escape(displayName(course.name)) + '" loading="lazy" />' : '');
  }

  function renderResults() {
    const status = document.querySelector('#result-status');
    if (catalogError) {
      status.innerHTML = 'Không tải được danh mục. <a href="' + (staticPreview ? 'courses.html' : '/khoa-hoc-v2') + '">Xem tất cả khóa học ↗</a>';
      return;
    }
    if (!courses.length) {
      status.textContent = 'Đang tải danh mục khóa học...';
      return;
    }

    const interests = selectedInterests();
    const goal = selectedGoal();
    const ranked = courses.filter((course) => course.lessons > 0)
      .sort((a, b) => score(b, interests, goal) - score(a, interests, goal) || b.lessons - a.lessons || a.id - b.id);
    const recommended = ranked.slice(0, 6);
    const primary = recommended[0];
    const summary = interests.map((interest) => interestLabels[interest]);
    if (goal) summary.push('Mục tiêu: ' + goalLabels[goal]);
    document.querySelector('#selection-summary').innerHTML = (summary.length ? summary : ['Khám phá chung'])
      .map((label) => '<b>' + escape(label) + '</b>').join('');
    document.querySelector('#result-lead').textContent = summary.length
      ? 'Dựa trên lựa chọn của bạn, đây là những khóa học nên khám phá trước.'
      : 'Bắt đầu từ các khóa học tiêu biểu của Meduc, rồi chọn môn bạn muốn đi sâu.';
    status.textContent = 'GỢI Ý ' + recommended.length + ' KHÓA HỌC TỪ ' + courses.length + ' KHÓA ĐANG MỞ';
    document.querySelector('#primary-result').innerHTML =
      '<article class="recommend-feature"><div class="recommend-feature-copy"><small>01 / GỢI Ý ĐẦU TIÊN · ' + escape(reason(primary, interests, goal).toUpperCase()) + '</small>'
      + '<h2>' + escape(displayName(primary.name)) + '</h2>'
      + '<p>Khám phá đề cương và các bài học để xem khóa học này có hợp với nhịp học hiện tại của bạn.</p>'
      + '<div class="recommend-feature-meta"><span><svg class="icon"><use href="#i-book" /></svg>' + (primary.chapters ? primary.chapters + ' chương' : 'Xem đề cương') + '</span><span>' + primary.lessons + ' bài học</span></div>'
      + '<div class="recommend-feature-actions"><a href="' + escape(detailURL(primary)) + '">Xem nội dung khóa học <svg class="icon"><use href="#i-arrow" /></svg></a>'
      + '<a href="' + escape(checkoutURL(primary)) + '">Xem học phí tham khảo ↗</a></div></div>'
      + '<a class="recommend-feature-media" href="' + escape(detailURL(primary)) + '" aria-label="Xem khóa học ' + escape(displayName(primary.name)) + '">' + imageHTML(primary) + '</a></article>';
    document.querySelector('#result-grid').innerHTML = recommended.slice(1).map((course, index) =>
      '<article class="recommend-card"><a class="recommend-card-image" href="' + escape(detailURL(course)) + '" aria-label="Xem khóa học ' + escape(displayName(course.name)) + '">' + imageHTML(course) + '</a>'
      + '<div class="recommend-card-body"><small>' + String(index + 2).padStart(2, '0') + ' / ' + escape(reason(course, interests, goal).toUpperCase()) + '</small>'
      + '<h3>' + escape(displayName(course.name)) + '</h3><div class="recommend-card-meta">'
      + (course.chapters ? '<span>' + course.chapters + ' chương</span>' : '') + '<span>' + course.lessons + ' bài học</span></div>'
      + '<a href="' + escape(detailURL(course)) + '">Xem chi tiết <svg class="icon"><use href="#i-arrow" /></svg></a></div></article>'
    ).join('');
    document.querySelectorAll('#primary-result img, #result-grid img').forEach((image) =>
      image.addEventListener('error', () => image.remove())
    );
  }

  function updateButtons() {
    document.querySelector('#next-interest').disabled = selectedInterests().length === 0;
    document.querySelector('#next-goal').disabled = !selectedGoal();
  }

  function showStep(step) {
    activeStep = step;
    steps.forEach((section, index) => { section.hidden = index !== step - 1; });
    document.querySelectorAll('[data-step-marker]').forEach((marker) => {
      const markerStep = Number(marker.dataset.stepMarker);
      marker.classList.toggle('is-current', markerStep === step);
      marker.classList.toggle('is-complete', markerStep < step);
      if (markerStep === step) marker.setAttribute('aria-current', 'step');
      else marker.removeAttribute('aria-current');
    });
    if (step === 3) renderResults();
    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  interestInputs.concat(goalInputs).forEach((input) => input.addEventListener('change', updateButtons));
  document.querySelector('#next-interest').addEventListener('click', () => showStep(2));
  document.querySelector('#skip-interest').addEventListener('click', () => showStep(2));
  document.querySelector('#back-goal').addEventListener('click', () => showStep(1));
  document.querySelector('#next-goal').addEventListener('click', () => showStep(3));
  document.querySelector('#skip-goal').addEventListener('click', () => showStep(3));
  document.querySelector('#edit-selection').addEventListener('click', () => showStep(1));

  fetch(catalogURL).then((response) => {
    if (!response.ok) throw new Error('HTTP ' + response.status);
    return response.json();
  }).then((data) => {
    if (!Array.isArray(data.courses) || data.courses.length !== data.count) throw new Error('Số khóa học không khớp');
    courses = data.courses;
    document.querySelector('#course-count').textContent = courses.length + ' khóa học đang mở tại Meduc';
    if (activeStep === 3) renderResults();
  }).catch(() => {
    catalogError = true;
    document.querySelector('#course-count').textContent = 'Xem danh mục khóa học trên Meduc';
    if (activeStep === 3) renderResults();
  });
  updateButtons();
})();
