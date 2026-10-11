(() => {
  'use strict';
  const library = document.querySelector('[data-course-exams]');
  if (!library) return;
  const base = library.dataset.base;
  const course = library.dataset.course;
  const dialog = library.querySelector('dialog');
  document.body.appendChild(dialog);
  const $ = selector => dialog.querySelector(selector);
  let current = null, quizId = null, mode = 'view', answers = {}, graded = false, fetchId = 0, previousOverflow = '';
  const notice = library.querySelector('[data-exam-notice]');
  const plain = (tag, value, className) => { const el = document.createElement(tag); el.textContent = value; if (className) el.className = className; return el; };
  const normalize = text => text.toLocaleLowerCase('vi').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
  const rows = Array.from(library.querySelectorAll('[data-exam-row]'));
  const search = library.querySelector('[data-exam-search]');
  if (search) search.addEventListener('input', () => {
    const term = normalize(search.value.trim()); let visible = 0;
    rows.forEach(row => { row.hidden = !normalize(row.textContent).includes(term); if (!row.hidden) visible++; });
    library.querySelector('[data-exam-visible]').textContent = visible + ' / ' + rows.length + ' bài';
    library.querySelector('[data-exam-empty]').hidden = visible > 0;
  });
  const error = message => { notice.textContent = message; notice.hidden = false; };
  const close = () => { dialog.close(); document.body.style.overflow = previousOverflow; fetchId++; };
  $('[data-exam-close]').addEventListener('click', close);
  dialog.addEventListener('cancel', event => { event.preventDefault(); close(); });
  dialog.addEventListener('click', event => { if (event.target === dialog && (event.clientX < dialog.getBoundingClientRect().left || event.clientX > dialog.getBoundingClientRect().right)) close(); });

  function progress() {
    const completed = Object.values(answers).filter(value => Array.isArray(value) ? value.length : !!value.trim()).length;
    $('[data-exam-progress]').textContent = mode === 'practice' ? completed + ' / ' + current.questions.length + ' câu đã làm' : current.questions.length + ' câu trong đề';
    dialog.querySelectorAll('[data-jump]').forEach(button => { const value = answers[button.dataset.jump]; button.classList.toggle('mx-filled', !!value && (Array.isArray(value) ? value.length > 0 : !!value.trim())); });
  }

  function render() {
    if (!current) return;
    const wrap = $('[data-exam-questions]'), nav = $('[data-exam-nav]'); wrap.replaceChildren(); nav.replaceChildren();
    const fragment = document.createDocumentFragment();
    current.questions.forEach((q, index) => {
      const correct = q.options.filter(o => o.is_correct).map(o => o.key);
      const checkable = q.options.length > 0 && correct.length > 0;
      const selected = Array.isArray(answers[index]) ? answers[index] : [];
      const isRight = checkable && correct.length === selected.length && correct.every(key => selected.includes(key));
      const question = plain('section', '', 'mx-question'); question.id = 'mx-question-' + index;
      const label = plain('div', '', 'mx-question-label'); label.append(plain('span', 'Câu ' + (index + 1)));
      label.append(plain('span', q.options.length ? (correct.length > 1 ? 'Chọn nhiều đáp án' : 'Trắc nghiệm') : 'Tự luận · tự đối chiếu'));
      question.append(label);
      const content = plain('div', '', 'mx-question-content'); content.innerHTML = q.content; question.append(content);
      (q.images || []).forEach(image => { const img = document.createElement('img'); img.src = image.url; img.alt = 'Hình minh hoạ câu ' + (index + 1); img.loading = 'lazy'; question.append(img); });
      q.options.forEach(option => {
        const row = plain('label', '', 'mx-option');
        if (mode === 'practice') {
          const input = document.createElement('input'); input.type = correct.length > 1 ? 'checkbox' : 'radio'; input.name = 'mx-answer-' + index;
          input.value = option.key; input.checked = selected.includes(option.key); input.disabled = graded;
          input.addEventListener('change', () => {
            if (input.type === 'checkbox') {
              const values = new Set(answers[index] || []); input.checked ? values.add(option.key) : values.delete(option.key); answers[index] = Array.from(values);
            } else answers[index] = [option.key];
            progress();
          });
          row.append(input);
        }
        row.append(plain('span', option.key + '.', 'mx-option-key'));
        const optionContent = document.createElement('div'); optionContent.innerHTML = option.content; row.append(optionContent);
        if (graded && mode === 'practice' && checkable) {
          row.classList.toggle('mx-correct', option.is_correct);
          row.classList.toggle('mx-wrong', selected.includes(option.key) && !option.is_correct);
        }
        question.append(row);
      });
      if (!q.options.length && mode === 'practice') {
        const essay = document.createElement('textarea'); essay.className = 'mx-essay'; essay.placeholder = 'Viết câu trả lời để đối chiếu với gợi ý…'; essay.setAttribute('aria-label', 'Trả lời câu ' + (index + 1)); essay.value = answers[index] || ''; essay.disabled = graded;
        essay.addEventListener('input', () => { answers[index] = essay.value; progress(); }); question.append(essay);
      }
      if (mode === 'view' || graded) {
        const explanation = document.createElement('details'); explanation.className = 'mx-answer'; explanation.open = graded;
        explanation.append(plain('summary', graded && checkable ? (isRight ? 'Đúng · xem giải thích' : 'Chưa đúng · xem đáp án') : 'Đáp án & giải thích'));
        const body = plain('div', '', 'mx-answer-body'); body.append(plain('div', correct.length ? 'Đáp án: ' + correct.join(', ') : 'Tự đối chiếu · câu này chưa có đáp án chấm tự động', 'mx-answer-key'));
        const text = document.createElement('div'); text.innerHTML = q.explanation || ''; body.append(text);
        (q.rubrics || []).forEach(rubric => { if (rubric.criteria) body.append(plain('p', rubric.criteria)); if (rubric.sample_answer) body.append(plain('p', rubric.sample_answer)); });
        explanation.append(body); question.append(explanation);
      }
      fragment.append(question);
      const jump = plain('button', index + 1); jump.type = 'button'; jump.dataset.jump = index; jump.setAttribute('aria-label', 'Câu ' + (index + 1));
      jump.addEventListener('click', () => question.scrollIntoView({ behavior: 'smooth', block: 'start' })); nav.append(jump);
    });
    wrap.append(fragment);
    $('[data-exam-grade]').hidden = mode !== 'practice'; $('[data-exam-grade]').textContent = graded ? 'Làm lại' : 'Chấm điểm';
    $('[data-exam-mode-note]').textContent = mode === 'practice' ? 'Làm thử tại đây · kết quả không lưu vào bài nộp' : 'Xem câu hỏi, đáp án và giải thích';
    dialog.querySelectorAll('[data-exam-mode]').forEach(button => button.setAttribute('aria-selected', String(button.dataset.examMode === mode)));
    progress();
  }

  async function open(id) {
    const request = ++fetchId; quizId = id; current = null; mode = 'view'; answers = {}; graded = false; notice.hidden = true;
    $('#mx-dialog-title').textContent = 'Đang tải đề…'; $('[data-exam-summary]').textContent = '';
    $('[data-exam-questions]').replaceChildren(plain('div', 'Đang tải nội dung đề…', 'mx-loading')); $('[data-exam-nav]').replaceChildren();
    $('[data-exam-result]').textContent = 'Chọn “Làm thử” để tự kiểm tra kiến thức.'; $('[data-exam-grade]').hidden = true;
    previousOverflow = document.body.style.overflow; document.body.style.overflow = 'hidden'; dialog.showModal();
    try {
      const response = await fetch(base + '/course-exam/preview/' + course + '/' + id, {credentials:'same-origin', headers:{Accept:'application/json'}});
      if (!response.ok || !(response.headers.get('content-type') || '').includes('application/json')) throw new Error('Không mở được đề. Vui lòng kiểm tra quyền truy cập hoặc đăng nhập lại.');
      const data = await response.json(); if (request !== fetchId) return;
      if (!data.exam || !Array.isArray(data.questions)) throw new Error('Nội dung đề chưa sẵn sàng.');
      current = data; $('#mx-dialog-title').textContent = data.exam.name;
      $('[data-exam-summary]').textContent = [data.exam.school, data.exam.year ? 'Năm ' + data.exam.year : '', data.questions.length + ' câu', data.exam.duration ? data.exam.duration + ' phút' : ''].filter(Boolean).join(' · ');
      render(); $('[data-exam-scroll]').scrollTop = 0;
    } catch (failure) { if (request === fetchId) { $('#mx-dialog-title').textContent = 'Chưa tải được đề'; $('[data-exam-questions]').replaceChildren(plain('div', failure.message, 'mx-loading')); } }
  }

  dialog.querySelectorAll('[data-exam-mode]').forEach(button => button.addEventListener('click', () => {
    mode = button.dataset.examMode; if (!current) return;
    render(); if (!graded) $('[data-exam-result]').textContent = mode === 'practice' ? 'Có thể chấm điểm bất cứ lúc nào.' : 'Chọn “Làm thử” để tự kiểm tra kiến thức.';
  }));
  $('[data-exam-grade]').addEventListener('click', () => {
    if (!current) return;
    if (graded) { answers = {}; graded = false; $('[data-exam-result]').textContent = 'Bắt đầu lượt làm thử mới.'; render(); $('[data-exam-scroll]').scrollTop=0; return; }
    let total=0, right=0, unanswered=0;
    current.questions.forEach((q,index) => {
      const correct=q.options.filter(o=>o.is_correct).map(o=>o.key); if(!correct.length)return;
      total++;const selected=Array.isArray(answers[index])?answers[index]:[];if(!selected.length)unanswered++;
      if(correct.length===selected.length && correct.every(key=>selected.includes(key)))right++;
    });
    graded=true;render();
    $('[data-exam-result]').replaceChildren(plain('strong', total ? right+' / '+total+' câu đúng' : 'Đề này cần tự đối chiếu', 'mx-result-strong'), plain('span', (total?' · '+Math.round(100*right/total)+'%':'')+(unanswered?' · '+unanswered+' câu chưa trả lời':'')+(current.questions.length>total?' · '+(current.questions.length-total)+' câu tự đối chiếu':'')));
  });

  async function download(id, button) {
    if (library.dataset.download !== '1') return;
    const old=button.textContent; button.disabled=true;button.textContent='Đang tạo Word…';
    try {
      const response=await fetch(base+'/course-exam/word/'+course+'/'+id,{credentials:'same-origin'});
      if(!response.ok || !(response.headers.get('content-type')||'').includes('wordprocessingml'))throw Error('Không tải được Word. Vui lòng thử lại.');
      const blob=await response.blob();const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download='meduc-de-'+id+'.docx';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),10000);
    } catch(failure) { error(failure.message); if(dialog.open)$('[data-exam-result]').textContent=failure.message; }
    finally {button.disabled=false;button.textContent=old;}
  }
  library.addEventListener('click', event => {const target=event.target.closest('[data-exam-open],[data-exam-word]');if(!target)return;target.hasAttribute('data-exam-open')?open(target.dataset.examOpen):download(target.dataset.examWord,target);});
  $('[data-exam-modal-word]').addEventListener('click', event => {if(current)download(quizId,event.currentTarget);});
})();
