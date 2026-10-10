(() => {
  const root = '/admin/teacher-exams';
  const state = { data: null, shown: 40, examId: null };
  const $ = (selector) => document.querySelector(selector);
  const safe = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);
  const normalized = (value) => String(value ?? '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  const plain = (value) => {
    const documentFragment = new DOMParser().parseFromString(String(value ?? ''), 'text/html');
    documentFragment.querySelectorAll('script,style').forEach((node) => node.remove());
    documentFragment.querySelectorAll('br').forEach((node) => node.replaceWith('\n'));
    documentFragment.querySelectorAll('p,div,li,tr').forEach((node) => node.append('\n'));
    return documentFragment.body.textContent.trim();
  };
  const number = (value) => new Intl.NumberFormat('vi-VN').format(value);
  const status = (message, type = '') => {
    $('#status').textContent = message;
    $('#status').className = `status ${type}`;
  };

  function courseName(id) {
    return state.data.courses.find((course) => Number(course.id) === Number(id))?.name || `Khóa #${id}`;
  }

  function checks(target, chosen = []) {
    const ids = new Set(chosen.map(Number));
    $(target).innerHTML = state.data.courses.map((course) => `<label><input type="checkbox" value="${Number(course.id)}" ${ids.has(Number(course.id)) ? 'checked' : ''}><span>${safe(course.name)}${Number(course.status) === 0 ? ' · Đã tắt' : ''}</span></label>`).join('') || '<p>Chưa có khóa học.</p>';
  }

  function selectedChecks(target) {
    return [...$(target).querySelectorAll('input:checked')].map((input) => Number(input.value));
  }

  function options(select, values, placeholder) {
    select.innerHTML = `<option value="">${safe(placeholder)}</option>` + values.map((value) => `<option value="${safe(value)}">${safe(value)}</option>`).join('');
  }

  function renderManage() {
    const data = state.data;
    if (!data.manager) return;
    const teacherId = $('#teacher-select').value;
    const topic = $('#topic-select').value;
    $('#management').hidden = false;
    $('#teacher-select').innerHTML = '<option value="">Chọn giáo viên</option>' + (data.teachers || []).map((teacher) => `<option value="${Number(teacher.id)}">${safe(teacher.full_name)} · ${safe(teacher.username)}</option>`).join('');
    options($('#topic-select'), [...new Set(data.exams.map((exam) => exam.topic))].sort((a, b) => a.localeCompare(b, 'vi')), 'Chọn môn/module');
    $('#teacher-select').value = teacherId;
    $('#topic-select').value = topic;
    checks('#teacher-courses', data.teacherAssignments[teacherId] || []);
    checks('#topic-courses', data.topicMappings[topic] || []);
    const exam = data.exams.find((row) => Number(row.id) === state.examId);
    checks('#exam-courses', exam?.directCourseIds || []);
    if (exam) $('#selected-exam').textContent = `${exam.title} · ${exam.school} · #${exam.id}`;
  }

  function filtered() {
    const query = normalized($('#search').value.trim());
    const course = Number($('#filter-course').value);
    const school = $('#filter-school').value;
    const topic = $('#filter-topic').value;
    return state.data.exams.filter((exam) =>
      (!query || normalized(`${exam.title} ${exam.school} ${exam.topic} ${exam.category} ${exam.year || ''}`).includes(query)) &&
      (!course || exam.courseIds.includes(course)) &&
      (!school || exam.school === school) &&
      (!topic || exam.topic === topic)
    );
  }

  function renderList() {
    const rows = filtered();
    $('#shown-count').textContent = `${number(Math.min(rows.length, state.shown))} / ${number(rows.length)} đề`;
    $('#exam-list').innerHTML = rows.slice(0, state.shown).map((exam) => `<article class="exam-card">
      <div class="card-top"><span>${safe(exam.topic)}</span><span class="count">${number(exam.questions)} CÂU</span></div>
      <h3>${safe(exam.title)}</h3>
      <p>${safe(exam.school)} · ${safe(exam.year || 'Không ghi năm')}${state.data.manager ? `<br>${exam.courseIds.length ? exam.courseIds.map(courseName).map(safe).join(' · ') : 'Chưa gán khóa học'}` : ''}</p>
      <div class="card-bottom"><button type="button" data-preview="${Number(exam.id)}">Xem đề</button><a href="${root}/word/${Number(exam.id)}">Tải Word ↗</a>${state.data.manager ? `<button class="assign" type="button" data-assign="${Number(exam.id)}">Gán khóa</button>` : ''}</div>
    </article>`).join('') || '<div class="empty">Không có đề phù hợp với bộ lọc hoặc khóa học được giao.</div>';
    $('#show-more').hidden = rows.length <= state.shown;
  }

  async function load(showStatus = true) {
    const filters = ['#filter-course', '#filter-school', '#filter-topic'].map((selector) => $(selector).value);
    const response = await fetch(root + '/data', { credentials: 'same-origin' });
    if (!response.ok) throw new Error(`Không tải được danh mục (${response.status}).`);
    state.data = await response.json();
    const data = state.data;
    $('#exam-total').textContent = number(data.count);
    options($('#filter-course'), data.courses.map((course) => course.id), 'Tất cả khóa học');
    [...$('#filter-course').options].slice(1).forEach((option) => { option.textContent = courseName(Number(option.value)); });
    options($('#filter-school'), [...new Set(data.exams.map((exam) => exam.school))].sort((a, b) => a.localeCompare(b, 'vi')), 'Tất cả trường');
    options($('#filter-topic'), [...new Set(data.exams.map((exam) => exam.topic))].sort((a, b) => a.localeCompare(b, 'vi')), 'Tất cả môn/module');
    ['#filter-course', '#filter-school', '#filter-topic'].forEach((selector, index) => { $(selector).value = filters[index]; });
    renderManage();
    renderList();
    if (showStatus) status(data.manager ? `${number(data.count)} / ${number(data.totalCatalog)} đề trong kho. Các đề chưa gán khóa chỉ quản trị viên xem được.` : `${number(data.count)} đề thuộc các khóa học đã được giao.`);
  }

  async function preview(id) {
    const exam = state.data.exams.find((row) => Number(row.id) === id);
    if (!exam) return;
    $('#preview-body').innerHTML = `<h2>${safe(exam.title)}</h2><p class="meta">${safe(exam.school)} · ${safe(exam.topic)}</p><p>Đang tải câu hỏi...</p>`;
    $('#preview').showModal();
    try {
      const response = await fetch(`${root}/detail/${id}`, { credentials: 'same-origin' });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || `Lỗi ${response.status}`);
      $('#preview-body').innerHTML = `<h2>${safe(data.exam.name)}</h2><p class="meta">${safe(data.exam.school)} · ${safe(data.exam.module)} · ${number(data.questions.length)} câu</p>` + data.questions.map((question, index) => {
        const options = (question.options || []).map((option) => `<li>${safe(option.key)}. ${safe(plain(option.content))}${option.is_correct ? ' <span class="answer">✓ Đáp án</span>' : ''}</li>`).join('');
        const images = (question.images || []).filter((image) => /^[a-zA-Z0-9_-]{16,128}$/.test(image.url_hash || '')).map((image) => `<img loading="lazy" src="https://meduc.duckdns.org/api/media/${encodeURIComponent(image.url_hash)}" alt="Hình minh họa câu ${index + 1}">`).join('');
        return `<article><h3>Câu ${index + 1}</h3><p>${safe(plain(question.content))}</p>${images}${options ? `<ol style="list-style:none;padding:0">${options}</ol>` : ''}${question.explanation ? `<p><strong>Giải thích:</strong> ${safe(plain(question.explanation))}</p>` : ''}${question.rubric?.sample_answer ? `<p><strong>Gợi ý:</strong> ${safe(plain(question.rubric.sample_answer))}</p>` : ''}</article>`;
      }).join('');
    } catch (error) {
      $('#preview-body').innerHTML = `<h2>${safe(exam.title)}</h2><p>${safe(error.message)}</p>`;
    }
  }

  async function save(path, fields) {
    const body = new URLSearchParams();
    body.set('_csrfToken', $('meta[name="csrf-token"]').content);
    Object.entries(fields).forEach(([key, value]) => {
      if (Array.isArray(value)) value.forEach((item) => body.append(`${key}[]`, item));
      else body.set(key, value);
    });
    const response = await fetch(`${root}/${path}`, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body });
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || `Không lưu được (${response.status}).`);
    await load(false);
    status('Đã lưu phân quyền. Danh sách đề đã được cập nhật.', 'success');
  }

  $('#exam-list').addEventListener('click', (event) => {
    const view = event.target.closest('[data-preview]');
    const assign = event.target.closest('[data-assign]');
    if (view) preview(Number(view.dataset.preview));
    if (assign) {
      state.examId = Number(assign.dataset.assign);
      const exam = state.data.exams.find((row) => Number(row.id) === state.examId);
      $('#selected-exam').textContent = `${exam.title} · ${exam.school} · #${exam.id}`;
      checks('#exam-courses', exam.directCourseIds);
      $('#management').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
  $('#close-preview').addEventListener('click', () => $('#preview').close());
  $('#preview').addEventListener('click', (event) => { if (event.target === $('#preview')) $('#preview').close(); });
  $('#show-more').addEventListener('click', () => { state.shown += 40; renderList(); });
  $('#teacher-select').addEventListener('change', () => { if (state.data) checks('#teacher-courses', state.data.teacherAssignments[$('#teacher-select').value] || []); });
  $('#topic-select').addEventListener('change', () => { if (state.data) checks('#topic-courses', state.data.topicMappings[$('#topic-select').value] || []); });
  ['#search', '#filter-course', '#filter-school', '#filter-topic'].forEach((selector) => $(selector).addEventListener(selector === '#search' ? 'input' : 'change', () => { state.shown = 40; if (state.data) renderList(); }));
  $('#save-teacher').addEventListener('click', async () => {
    if (!$('#teacher-select').value) return status('Hãy chọn giáo viên.', 'error');
    try { await save('save-teacher', { user_id: $('#teacher-select').value, course_ids: selectedChecks('#teacher-courses') }); }
    catch (error) { status(error.message, 'error'); }
  });
  $('#save-topic').addEventListener('click', async () => {
    if (!$('#topic-select').value) return status('Hãy chọn môn/module.', 'error');
    try { await save('save-topic', { topic: $('#topic-select').value, course_ids: selectedChecks('#topic-courses') }); }
    catch (error) { status(error.message, 'error'); }
  });
  $('#save-exam').addEventListener('click', async () => {
    if (!state.examId) return status('Hãy chọn một đề.', 'error');
    try { await save('save-exam', { exam_id: state.examId, course_ids: selectedChecks('#exam-courses') }); }
    catch (error) { status(error.message, 'error'); }
  });
  load().catch((error) => status(error.message, 'error'));
})();
