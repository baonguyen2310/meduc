(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/exam-hierarchy.html');
  const dataURL = staticPreview ? 'assets/exam-hierarchy-data.json' : '/hero-light/assets/exam-hierarchy-data.json';
  const params = new URLSearchParams(location.search);
  const state = {
    school: params.get('school') || 'all',
    year: params.get('year') || 'all',
    type: params.get('type') || 'all',
    topic: params.get('topic') || 'all',
    query: params.get('q') || '',
    shown: 12,
    topicsShown: 9,
  };
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const normalize = (value) => String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase();
  const number = (value) => Number(value).toLocaleString('vi-VN');
  const yearLabel = (year) => year === 'none' ? 'Không ghi năm' : year;
  const icon = '<svg class="icon" aria-hidden="true"><use href="#i-arrow" /></svg>';

  if (staticPreview) {
    document.querySelectorAll('a[href="/medduo"]').forEach((link) => { link.href = 'http://127.0.0.1:8080/medduo'; });
  }

  fetch(dataURL).then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }).then((data) => {
    if (data.exams.length !== data.count || data.exams.reduce((sum, item) => sum + item.questions, 0) !== data.questions) {
      throw new Error('Exam totals do not reconcile');
    }
    const exams = data.exams;
    const byId = new Map(exams.map((exam) => [exam.id, exam]));
    const schoolCounts = new Map();
    exams.forEach((exam) => schoolCounts.set(exam.school, (schoolCounts.get(exam.school) || 0) + 1));
    const schools = [...schoolCounts.keys()].sort((a, b) => schoolCounts.get(b) - schoolCounts.get(a) || a.localeCompare(b, 'vi'));
    const years = [...new Set(exams.map((exam) => exam.year).filter(Boolean))].sort((a, b) => b - a);
    const topics = new Set(exams.map((exam) => exam.topic));
    if (schoolCounts.size !== data.schools || topics.size !== data.topics) throw new Error('Hierarchy totals do not reconcile');

    if (state.school !== 'all' && !schoolCounts.has(state.school)) state.school = 'all';
    if (state.year !== 'all' && state.year !== 'none' && !years.includes(Number(state.year))) state.year = 'all';
    if (!['all', 'subject', 'module'].includes(state.type)) state.type = 'all';
    if (state.topic !== 'all' && !topics.has(state.topic)) state.topic = 'all';
    document.querySelector('#exam-search').value = state.query;
    document.querySelector('#hero-exams').textContent = number(data.count);
    document.querySelector('#hero-schools').textContent = number(data.schools);
    document.querySelector('#hero-topics').textContent = number(data.topics);
    document.querySelector('#data-updated').textContent = `Dữ liệu danh mục xuất ngày ${data.exported.split('-').reverse().join('/')}`;

    function matchingQuery(exam) {
      if (!state.query.trim()) return true;
      const term = normalize(state.query.trim());
      return normalize(`${exam.title} ${exam.school} ${exam.topic} ${exam.category} ${exam.group} ${exam.year || ''}`).includes(term);
    }
    const schoolRows = () => exams.filter((exam) => state.school === 'all' || exam.school === state.school);
    const yearRows = (rows) => rows.filter((exam) => state.year === 'all' || (state.year === 'none' ? exam.year === null : exam.year === Number(state.year)));
    const typeRows = (rows) => rows.filter((exam) => state.type === 'all' || exam.type === state.type);
    const topicRows = (rows) => rows.filter((exam) => state.topic === 'all' || exam.topic === state.topic);

    function updateURL() {
      const query = new URLSearchParams();
      for (const key of ['school', 'year', 'type', 'topic']) if (state[key] !== 'all') query.set(key, state[key]);
      if (state.query.trim()) query.set('q', state.query.trim());
      history.replaceState(null, '', `${location.pathname}${query.size ? `?${query}` : ''}${location.hash}`);
    }

    function renderSchools() {
      document.querySelector('#school-list').innerHTML = [
        `<button type="button" data-school="all" class="${state.school === 'all' ? 'is-active' : ''}" aria-pressed="${state.school === 'all'}"><span>Tất cả trường</span><b>${number(data.count)}</b></button>`,
        ...schools.map((school) => `<button type="button" data-school="${escape(school)}" class="${state.school === school ? 'is-active' : ''}" aria-pressed="${state.school === school}"><span>${escape(school)}</span><b>${number(schoolCounts.get(school))}</b></button>`),
      ].join('');
    }

    function renderYears(rows) {
      const counts = new Map();
      rows.forEach((exam) => { const key = exam.year ? String(exam.year) : 'none'; counts.set(key, (counts.get(key) || 0) + 1); });
      const available = [...years.map(String), 'none'].filter((year) => counts.has(year));
      document.querySelector('#year-list').innerHTML = [
        `<button type="button" data-year="all" class="${state.year === 'all' ? 'is-active' : ''}" aria-pressed="${state.year === 'all'}"><strong>Tất cả</strong><span>${number(rows.length)} đề</span></button>`,
        ...available.map((year) => `<button type="button" data-year="${year}" class="${state.year === year ? 'is-active' : ''}" aria-pressed="${state.year === year}"><strong>${yearLabel(year)}</strong><span>${number(counts.get(year))} đề</span></button>`),
      ].join('');
    }

    function renderTypes(rows) {
      const counts = { all: rows.length, subject: rows.filter((exam) => exam.type === 'subject').length, module: rows.filter((exam) => exam.type === 'module').length };
      Object.entries(counts).forEach(([key, value]) => { document.querySelector(`#type-${key}-count`).textContent = number(value); });
      document.querySelectorAll('#type-tabs button').forEach((button) => {
        const active = button.dataset.type === state.type;
        button.classList.toggle('is-active', active);
        button.setAttribute('aria-pressed', String(active));
      });
    }

    function groupedTopics(rows) {
      const groups = new Map();
      rows.forEach((exam) => {
        if (!matchingQuery(exam)) return;
        const group = groups.get(exam.topic) || { topic: exam.topic, type: exam.type, group: exam.group, count: 0, questions: 0 };
        group.count += 1;
        group.questions += exam.questions;
        groups.set(exam.topic, group);
      });
      return [...groups.values()].sort((a, b) => b.count - a.count || a.topic.localeCompare(b.topic, 'vi'));
    }

    function renderTopics(rows) {
      const grouped = groupedTopics(rows);
      const selectedIndex = grouped.findIndex((item) => item.topic === state.topic);
      if (selectedIndex >= state.topicsShown) state.topicsShown = selectedIndex + 1;
      document.querySelector('#topic-count').textContent = `${number(grouped.length)} môn/module`;
      document.querySelector('#topic-grid').innerHTML = grouped.slice(0, state.topicsShown).map((item) => `<button type="button" class="exam-topic-card ${state.topic === item.topic ? 'is-active' : ''}" data-topic="${escape(item.topic)}" aria-pressed="${state.topic === item.topic}"><small>${item.type === 'module' ? 'MODULE TÍCH HỢP' : escape(item.group.toUpperCase())}</small><strong>${escape(item.topic)}</strong><span>${number(item.count)} đề · ${number(item.questions)} câu</span></button>`).join('');
      const more = document.querySelector('#show-topics');
      more.hidden = grouped.length <= state.topicsShown;
      more.innerHTML = `Xem toàn bộ ${number(grouped.length)} môn/module ${icon}`;
    }

    function renderPath() {
      const parts = [state.school === 'all' ? 'Tất cả trường' : state.school, state.year === 'all' ? 'Mọi năm' : yearLabel(state.year), state.type === 'all' ? 'Môn & module' : state.type === 'module' ? 'Module' : 'Môn học'];
      if (state.topic !== 'all') parts.push(state.topic);
      document.querySelector('#selected-path').innerHTML = parts.map((part, index) => `${index ? '<i>›</i>' : ''}<b>${escape(part)}</b>`).join('');
    }

    function resultRow(exam, index) {
      const year = exam.year || 'Không ghi năm';
      return `<article class="exam-result"><span class="exam-result-index">${String(index + 1).padStart(2, '0')}</span><div class="exam-result-main"><strong>${escape(exam.title)}</strong><span>${escape(exam.school)} · ${escape(exam.topic)} · ${escape(year)}</span></div><div class="exam-result-action"><small>${number(exam.questions)} câu</small><button type="button" data-exam="${exam.id}" aria-label="Chi tiết đề ${escape(exam.title)}">Chi tiết ${icon}</button></div></article>`;
    }

    function renderResults(rows) {
      const filtered = topicRows(rows).filter(matchingQuery).sort((a, b) => (b.year || 0) - (a.year || 0) || b.id - a.id);
      const questions = filtered.reduce((sum, exam) => sum + exam.questions, 0);
      document.querySelector('#selection-count').textContent = `${number(filtered.length)} bộ đề phù hợp`;
      document.querySelector('#selection-questions').textContent = `${number(questions)} câu hỏi`;
      document.querySelector('#results-count').textContent = `Hiển thị ${number(Math.min(state.shown, filtered.length))}/${number(filtered.length)} đề`;
      document.querySelector('#exam-list').innerHTML = filtered.slice(0, state.shown).map(resultRow).join('');
      document.querySelector('#exam-empty').hidden = filtered.length !== 0;
      document.querySelector('#exam-more').hidden = filtered.length <= state.shown;
    }

    function render() {
      const bySchool = schoolRows();
      const byYear = yearRows(bySchool);
      const byType = typeRows(byYear);
      renderSchools(); renderYears(bySchool); renderTypes(byYear); renderTopics(byType); renderPath(); renderResults(byType); updateURL();
    }

    const reset = () => {
      Object.assign(state, { school: 'all', year: 'all', type: 'all', topic: 'all', query: '', shown: 12, topicsShown: 9 });
      document.querySelector('#exam-search').value = '';
      render();
    };
    document.querySelector('#reset-hierarchy').addEventListener('click', reset);
    document.querySelector('#clear-empty').addEventListener('click', reset);
    document.querySelector('#exam-search').addEventListener('input', (event) => {
      state.query = event.target.value; state.topic = 'all'; state.shown = 12; state.topicsShown = 9; render();
    });
    document.querySelector('#school-list').addEventListener('click', (event) => {
      const button = event.target.closest('button[data-school]'); if (!button) return;
      state.school = button.dataset.school; state.year = 'all'; state.type = 'all'; state.topic = 'all'; state.shown = 12; state.topicsShown = 9; render();
    });
    document.querySelector('#year-list').addEventListener('click', (event) => {
      const button = event.target.closest('button[data-year]'); if (!button) return;
      state.year = button.dataset.year; state.type = 'all'; state.topic = 'all'; state.shown = 12; state.topicsShown = 9; render();
    });
    document.querySelector('#type-tabs').addEventListener('click', (event) => {
      const button = event.target.closest('button[data-type]'); if (!button) return;
      state.type = button.dataset.type; state.topic = 'all'; state.shown = 12; state.topicsShown = 9; render();
    });
    document.querySelector('#topic-grid').addEventListener('click', (event) => {
      const button = event.target.closest('button[data-topic]'); if (!button) return;
      state.topic = state.topic === button.dataset.topic ? 'all' : button.dataset.topic; state.shown = 12; render();
      document.querySelector('#results-title').scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
    document.querySelector('#show-topics').addEventListener('click', () => { state.topicsShown = data.topics; render(); });
    document.querySelector('#exam-more').addEventListener('click', () => { state.shown += 12; renderResults(typeRows(yearRows(schoolRows()))); });

    const dialog = document.querySelector('#exam-dialog');
    document.querySelector('#exam-list').addEventListener('click', (event) => {
      const button = event.target.closest('button[data-exam]'); if (!button) return;
      const exam = byId.get(Number(button.dataset.exam)); if (!exam) return;
      document.querySelector('#dialog-title').textContent = exam.title;
      document.querySelector('#dialog-meta').innerHTML = [
        ['Mã đề Facourse', `#${exam.id}`], ['Trường', exam.school],
        ['Năm trong tên', exam.year || 'Không ghi năm'], ['Phân loại', exam.type === 'module' ? 'Module tích hợp' : 'Môn học'],
        ['Môn / module', exam.topic], ['Danh mục gốc', exam.category], ['Số câu', number(exam.questions)],
      ].map(([label, value]) => `<div><span>${escape(label)}</span><strong>${escape(value)}</strong></div>`).join('');
      dialog.showModal();
    });
    document.querySelector('#dialog-close').addEventListener('click', () => dialog.close());
    document.querySelector('#dialog-done').addEventListener('click', () => dialog.close());
    dialog.addEventListener('click', (event) => { if (event.target === dialog) dialog.close(); });
    render();
  }).catch(() => {
    document.querySelector('#selection-count').textContent = 'Chưa tải được danh mục đề.';
    document.querySelector('#selection-questions').textContent = 'Vui lòng tải lại trang để thử lại.';
    document.querySelector('#exam-list').innerHTML = '<p class="exam-load-error">Danh mục bộ đề hiện chưa sẵn sàng.</p>';
  });
})();
