(() => {
  "use strict";

  const source = document.querySelector('.course-details-card[nh-anchor="noidung"]');
  const courseArea = document.querySelector('.edu-course-details-area.product-detail-main__wrap');
  const outline = source?.querySelector('.accordion-list');
  if (!source || !courseArea || !outline?.querySelector('.accordion-item')) return;

  const chapters = [];
  const lessons = [];
  let chapter;
  [...outline.children].forEach((row) => {
    if (row.classList.contains('accordion-chapter')) {
      const title = row.querySelector('h2')?.textContent.trim() || 'Nội dung khóa học';
      chapter = { title: title.replace(/\s*\(\d+\s+bài\)\s*$/i, ''), lessons: [] };
      chapters.push(chapter);
      return;
    }
    if (!row.classList.contains('accordion-item')) return;
    if (!chapter) {
      chapter = { title: 'Nội dung khóa học', lessons: [] };
      chapters.push(chapter);
    }
    const video = row.querySelector('.glightbox-video-course[href]');
    const quiz = row.querySelector('.btn-quiz[data-id-quiz]');
    const lesson = {
      index: lessons.length,
      title: row.querySelector('h3 span')?.textContent.trim() || `Bài học ${lessons.length + 1}`,
      chapter,
      video,
      quiz,
      hasVideo: row.dataset.mclHasVideo === '1',
      hasQuiz: row.dataset.mclHasQuiz === '1',
      files: [...row.querySelectorAll('[btn-view-file]')],
      trial: row.dataset.mclTrial === '1',
      lockedFiles: Boolean(row.querySelector('.inner-files .isax-lock')),
    };
    chapter.lessons.push(lesson);
    lessons.push(lesson);
  });
  if (!lessons.length) return;

  const title = document.querySelector('.course-details-content h1.title')?.textContent.trim()
    || document.querySelector('.product-title-detail')?.textContent.trim()
    || 'Khóa học MedUC';
  const licensed = source.dataset.mclLicensed === '1';
  const enrollment = document.querySelector('.course-details-sidebar');
  if (enrollment) enrollment.id = 'mcl-enroll';
  courseArea.id = 'mcl-about';

  const section = document.createElement('section');
  section.className = 'mcl';
  section.id = 'mcl-classroom';
  section.setAttribute('aria-labelledby', 'mcl-title');
  section.innerHTML = `
    <div class="mcl-heading">
      <div><span class="mcl-eyebrow">MEDUC / KHÔNG GIAN HỌC TẬP</span><h2 id="mcl-title"></h2></div>
      <div class="mcl-heading-side"><span id="mcl-summary"></span><a href="#mcl-about">Thông tin &amp; đăng ký <span aria-hidden="true">↗</span></a></div>
    </div>
    <div class="mcl-layout">
      <aside class="mcl-sidebar" aria-label="Danh sách chương và bài học">
        <div class="mcl-sidebar-top"><strong>Đề cương khóa học</strong><span id="mcl-sidebar-count"></span></div>
        <label class="mcl-search"><span class="mcl-sr-only">Tìm bài học</span><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="11" cy="11" r="6.5"/><path d="m16 16 5 5"/></svg><input id="mcl-search" type="search" placeholder="Tìm chương hoặc bài học" autocomplete="off"></label>
        <nav class="mcl-outline-scroll" id="mcl-outline" aria-label="Chọn bài học"></nav>
        <p class="mcl-sidebar-foot">Chọn một bài để xem video, tài liệu và bài tập.</p>
      </aside>
      <div class="mcl-main">
        <div class="mcl-main-top"><div><span class="mcl-current-kicker" id="mcl-location"></span><h3 id="mcl-lesson-title"></h3></div><span class="mcl-access" id="mcl-access"></span></div>
        <div class="mcl-tabs" role="tablist" aria-label="Nội dung bài học">
          <button type="button" role="tab" id="mcl-tab-video" aria-controls="mcl-panel" data-tab="video">Video</button>
          <button type="button" role="tab" id="mcl-tab-documents" aria-controls="mcl-panel" data-tab="documents">Tài liệu</button>
          <button type="button" role="tab" id="mcl-tab-exercise" aria-controls="mcl-panel" data-tab="exercise">Bài tập</button>
        </div>
        <div class="mcl-panel-scroll" id="mcl-panel" role="tabpanel" tabindex="0"></div>
        <div class="mcl-main-foot"><span id="mcl-position"></span><div><button type="button" id="mcl-previous">← Bài trước</button><button type="button" id="mcl-next">Bài tiếp →</button></div></div>
      </div>
    </div>`;
  courseArea.before(section);
  document.body.classList.add('mcl-enhanced');
  section.querySelector('#mcl-title').textContent = title;
  section.querySelector('#mcl-summary').textContent = `${chapters.length} chương · ${lessons.length} bài học`;
  section.querySelector('#mcl-sidebar-count').textContent = `${chapters.length} chương`;

  const outlineNode = section.querySelector('#mcl-outline');
  chapters.forEach((item, chapterIndex) => {
    const details = document.createElement('details');
    details.className = 'mcl-chapter';
    item.details = details;
    const summary = document.createElement('summary');
    const number = document.createElement('span');
    number.className = 'mcl-chapter-index';
    number.textContent = String(chapterIndex + 1).padStart(2, '0');
    const name = document.createElement('strong');
    name.textContent = item.title;
    const count = document.createElement('small');
    count.textContent = `${item.lessons.length} bài`;
    summary.append(number, name, count);
    details.append(summary);
    const list = document.createElement('div');
    list.className = 'mcl-lesson-list';
    item.lessons.forEach((lesson) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'mcl-lesson';
      button.dataset.index = String(lesson.index);
      button.setAttribute('aria-label', lesson.title);
      const index = document.createElement('span');
      index.className = 'mcl-lesson-index';
      index.textContent = String(lesson.index + 1).padStart(2, '0');
      const label = document.createElement('span');
      label.textContent = lesson.title;
      const state = document.createElement('span');
      state.className = 'mcl-lesson-state';
      state.textContent = lesson.video || lesson.quiz || lesson.files.length ? '●' : '○';
      state.setAttribute('aria-hidden', 'true');
      button.append(index, label, state);
      button.addEventListener('click', () => {
        selectLesson(lesson.index);
        if (window.matchMedia('(max-width: 900px)').matches) {
          section.querySelector('.mcl-main').scrollIntoView({
            behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth',
            block: 'start',
          });
        }
      });
      list.append(button);
      lesson.button = button;
      lesson.details = details;
    });
    if (!item.lessons.length) {
      const empty = document.createElement('p');
      empty.className = 'mcl-chapter-empty';
      empty.textContent = 'Chưa có bài học trong phần này.';
      list.append(empty);
    }
    details.append(list);
    outlineNode.append(details);
  });
  const searchEmpty = document.createElement('p');
  searchEmpty.className = 'mcl-search-empty';
  searchEmpty.textContent = 'Không tìm thấy chương hoặc bài học.';
  searchEmpty.hidden = true;
  outlineNode.append(searchEmpty);

  const panel = section.querySelector('#mcl-panel');
  const tabs = [...section.querySelectorAll('.mcl-tabs [role="tab"]')];
  let selected = 0;
  let activeTab = 'video';

  function youtubeId(href) {
    try {
      const url = new URL(href);
      const host = url.hostname.toLowerCase();
      const id = host === 'youtu.be' ? url.pathname.slice(1)
        : ['youtube.com', 'www.youtube.com', 'm.youtube.com'].includes(host) ? url.searchParams.get('v') : '';
      return /^[a-zA-Z0-9_-]{11}$/.test(id || '') ? id : '';
    } catch (_) { return ''; }
  }

  function emptyPanel(heading, message, showEnrollment = false) {
    const box = document.createElement('div');
    box.className = 'mcl-empty';
    box.innerHTML = '<span class="mcl-empty-icon" aria-hidden="true">✦</span><h4></h4><p></p>';
    box.querySelector('h4').textContent = heading;
    box.querySelector('p').textContent = message;
    if (showEnrollment && enrollment) {
      const link = document.createElement('a');
      link.href = '#mcl-enroll';
      link.textContent = 'Đăng ký khóa học ↗';
      box.append(link);
    }
    panel.append(box);
  }

  function renderVideo(lesson) {
    if (!lesson.video) {
      const locked = lesson.hasVideo && !licensed;
      emptyPanel(locked ? 'Video chưa mở' : 'Bài này chưa có video', locked
        ? 'Bạn có thể xem các bài học thử hoặc đăng ký khóa học để mở nội dung đầy đủ.'
        : 'MedUC hiện chưa gắn video cho bài học này.', locked);
      return;
    }
    const id = youtubeId(lesson.video.href);
    if (!id) {
      const link = document.createElement('a');
      link.className = 'mcl-open-link';
      link.href = lesson.video.href;
      link.target = '_blank';
      link.rel = 'noopener noreferrer';
      link.textContent = 'Mở video bài học ↗';
      panel.append(link);
      return;
    }
    const frame = document.createElement('div');
    frame.className = 'mcl-video';
    const play = document.createElement('button');
    play.type = 'button';
    play.className = 'mcl-video-play';
    play.setAttribute('aria-label', `Phát video ${lesson.title}`);
    play.innerHTML = '<em>MEDUC / VIDEO BÀI HỌC</em><span aria-hidden="true">▶</span><strong>Phát bài giảng</strong>';
    play.addEventListener('click', () => {
      const iframe = document.createElement('iframe');
      iframe.title = `Video bài học: ${lesson.title}`;
      iframe.src = `https://www.youtube-nocookie.com/embed/${id}?autoplay=1&rel=0`;
      iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share';
      iframe.allowFullscreen = true;
      frame.replaceChildren(iframe);
    });
    frame.append(play);
    const note = document.createElement('p');
    note.className = 'mcl-content-note';
    note.textContent = lesson.trial && !licensed ? 'Bài giảng học thử · Bạn có thể xem trước khi đăng ký.' : 'Bài giảng thuộc khóa học MedUC của bạn.';
    panel.append(frame, note);
  }

  function renderDocuments(lesson) {
    if (!lesson.files.length) {
      emptyPanel(lesson.lockedFiles ? 'Tài liệu đã khóa' : 'Chưa có tài liệu trong bài này', lesson.lockedFiles
        ? 'Tài liệu bài học sẽ được mở khi bạn tham gia khóa học.'
        : 'MedUC hiện chưa đính kèm tài liệu riêng cho bài học này.', lesson.lockedFiles);
      return;
    }
    const intro = document.createElement('p');
    intro.className = 'mcl-content-note';
    intro.textContent = `${lesson.files.length} tài liệu đính kèm cho bài học này.`;
    const list = document.createElement('div');
    list.className = 'mcl-files';
    lesson.files.forEach((original, index) => {
      const row = document.createElement('div');
      row.className = 'mcl-file';
      const name = document.createElement('span');
      name.textContent = original.dataset.name || `Tài liệu ${index + 1}`;
      const button = document.createElement('button');
      button.type = 'button';
      button.textContent = 'Xem tài liệu ↗';
      button.addEventListener('click', () => original.click());
      row.append(name, button);
      list.append(row);
    });
    panel.append(intro, list);
  }

  function renderExercise(lesson) {
    if (!lesson.quiz) {
      const locked = lesson.hasQuiz && !licensed;
      emptyPanel(locked ? 'Bài tập chưa mở' : 'Bài này chưa có bài tập', locked
        ? 'Hãy chọn một bài học thử có bài tập hoặc tham gia khóa học để luyện tập.'
        : 'MedUC hiện chưa gắn bài tập cho bài học này.', locked);
      return;
    }
    const card = document.createElement('div');
    card.className = 'mcl-exercise';
    card.innerHTML = '<span>BÀI TẬP CỦNG CỐ</span><h4>Luyện tập ngay sau bài học.</h4><p>Làm bài, xem đáp án và lời giải theo hệ thống kiểm tra của MedUC.</p>';
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = 'Bắt đầu làm bài →';
    const status = document.createElement('small');
    status.setAttribute('role', 'status');
    button.addEventListener('click', () => {
      if (!document.getElementById(`modalQuiz${lesson.quiz.dataset.idQuiz}`)) {
        status.textContent = 'Bài tập đang tải, vui lòng thử lại sau giây lát.';
        return;
      }
      status.textContent = '';
      lesson.quiz.click();
    });
    card.append(button, status);
    panel.append(card);
  }

  function setTab(tab) {
    activeTab = tab;
    tabs.forEach((button) => {
      const active = button.dataset.tab === tab;
      button.setAttribute('aria-selected', String(active));
      button.tabIndex = active ? 0 : -1;
    });
    panel.setAttribute('aria-labelledby', `mcl-tab-${tab}`);
    panel.replaceChildren();
    const lesson = lessons[selected];
    if (tab === 'video') renderVideo(lesson);
    if (tab === 'documents') renderDocuments(lesson);
    if (tab === 'exercise') renderExercise(lesson);
    panel.scrollTop = 0;
  }

  function selectLesson(index) {
    if (!lessons[index]) return;
    selected = index;
    const lesson = lessons[index];
    lessons.forEach((item) => {
      item.button.classList.toggle('is-active', item === lesson);
      if (item === lesson) item.button.setAttribute('aria-current', 'true');
      else item.button.removeAttribute('aria-current');
    });
    lesson.details.open = true;
    section.querySelector('#mcl-location').textContent = `${lesson.chapter.title} · Bài ${index + 1}/${lessons.length}`;
    section.querySelector('#mcl-lesson-title').textContent = lesson.title;
    const badge = section.querySelector('#mcl-access');
    badge.textContent = licensed ? 'ĐÃ MỞ KHÓA' : lesson.trial ? 'HỌC THỬ' : 'XEM ĐỀ CƯƠNG';
    badge.dataset.state = licensed ? 'open' : lesson.trial ? 'trial' : 'locked';
    section.querySelector('#mcl-position').textContent = `${String(index + 1).padStart(2, '0')} / ${String(lessons.length).padStart(2, '0')} BÀI HỌC`;
    section.querySelector('#mcl-previous').disabled = index === 0;
    section.querySelector('#mcl-next').disabled = index === lessons.length - 1;
    setTab('video');
  }

  tabs.forEach((button, index) => {
    button.addEventListener('click', () => setTab(button.dataset.tab));
    button.addEventListener('keydown', (event) => {
      if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
      event.preventDefault();
      const next = (index + (event.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length;
      tabs[next].focus();
      setTab(tabs[next].dataset.tab);
    });
  });
  section.querySelector('#mcl-previous').addEventListener('click', () => selectLesson(selected - 1));
  section.querySelector('#mcl-next').addEventListener('click', () => selectLesson(selected + 1));
  section.querySelector('#mcl-search').addEventListener('input', (event) => {
    const query = event.target.value.trim().toLocaleLowerCase('vi');
    chapters.forEach((item) => {
      const matchesChapter = item.title.toLocaleLowerCase('vi').includes(query);
      item.lessons.forEach((lesson) => {
        lesson.button.hidden = Boolean(query) && !matchesChapter && !lesson.title.toLocaleLowerCase('vi').includes(query);
      });
      item.details.hidden = Boolean(query) && !matchesChapter && item.lessons.every((lesson) => lesson.button.hidden);
      if (query && !item.details.hidden) item.details.open = true;
    });
    searchEmpty.hidden = !query || chapters.some((item) => !item.details.hidden);
  });

  const requested = Number(new URLSearchParams(location.search).get('bai'));
  const firstAvailable = lessons.findIndex((lesson) => lesson.video || lesson.quiz || lesson.files.length);
  selectLesson(Number.isInteger(requested) && requested >= 1 && requested <= lessons.length
    ? requested - 1 : Math.max(firstAvailable, 0));
})();
