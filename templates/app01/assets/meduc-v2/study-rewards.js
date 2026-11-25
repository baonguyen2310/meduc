(() => {
  'use strict';
  const root = document.querySelector('[data-mcr][data-mcr-kind="knowledge"]');
  const panel = root?.querySelector('[data-study-rewards]');
  if (!panel) return;

  const modal = root.querySelector('[data-mcr-study-modal]');
  const player = root.querySelector('[data-mcr-player]');
  const quiz = root.querySelector('[data-mcr-quiz-player]');
  const dialog = root.querySelector('[data-study-dialog]');
  const toast = root.querySelector('[data-study-toast]');
  const idleLimit = 120000;
  const money = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'});
  const date = new Intl.DateTimeFormat('vi-VN', {day: 'numeric', month: 'numeric', timeZone: 'Asia/Ho_Chi_Minh'});
  const discount = tier => tier.type === 'percent' ? tier.value + '%' : money.format(tier.value);
  const duration = seconds => {
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    return hours ? hours + ' giờ' + (minutes % 60 ? ' ' + minutes % 60 + ' phút' : '') : minutes + ' phút';
  };

  let member = 0, progress = null, active = null, blocked = '', lastQuiz = '', lastAction = 0;
  let requested = 0, applied = 0, resetTimer, toastTimer, idleTimer;

  function announce(text) {
    clearTimeout(toastTimer);
    toast.textContent = text;
    toastTimer = setTimeout(() => { toast.textContent = ''; }, 4500);
  }

  function paint(data) {
    const previous = progress;
    progress = data;
    panel.hidden = !data.enabled;
    clearTimeout(resetTimer);
    if (!data.enabled) {
      active = null;
      return;
    }

    panel.querySelector('[data-study-elapsed]').textContent = duration(data.seconds);
    const next = data.rewards.find(tier => tier.target_seconds > data.seconds);
    const meter = panel.querySelector('[data-study-meter]');
    meter.max = data.rewards[data.rewards.length - 1].target_seconds;
    meter.value = Math.min(data.seconds, meter.max);
    panel.querySelector('[data-study-next]').textContent = next
      ? 'Còn ' + duration(Math.ceil((next.target_seconds - data.seconds) / 60) * 60) + ' để nhận mã giảm ' + discount(next)
      : 'Đã đạt tất cả mốc tuần này';
    dialog.querySelector('[data-study-reset]').textContent =
      'Tính lại từ 0 giờ thứ Hai, ' + date.format(data.resets_at * 1000) + ' (giờ Việt Nam).';
    if (dialog.open) renderMilestones();

    const earned = previous?.week_start === data.week_start && data.rewards.filter(tier =>
      tier.code && tier.target_seconds > previous.seconds && tier.target_seconds <= data.seconds);
    if (earned?.length) announce('Đã nhận mã giảm ' + discount(earned[earned.length - 1]) + ' cho Khoá ôn kiến thức.');
    resetTimer = setTimeout(() => update(), Math.max(200, (data.resets_at - data.server_at) * 1000 + 200));
  }

  function renderMilestones() {
    const list = dialog.querySelector('[data-study-milestones]');
    list.replaceChildren();
    for (const tier of progress.rewards) {
      const row = document.createElement('li');
      const name = document.createElement('strong');
      name.textContent = duration(tier.target_seconds) + ' · Giảm ' + discount(tier);
      row.append(name);
      const status = document.createElement('span');
      status.textContent = tier.used ? 'Đã dùng' : 'Chưa đạt';
      if (tier.code) {
        const code = document.createElement('code');
        code.textContent = tier.code;
        status.replaceChildren(code);
        if (navigator.clipboard) {
          const copy = document.createElement('button');
          copy.type = 'button';
          copy.className = 'mst-action';
          copy.textContent = 'Sao chép';
          copy.addEventListener('click', async () => {
            try {
              await navigator.clipboard.writeText(tier.code);
              copy.textContent = 'Đã sao chép';
            } catch (_) {
              window.getSelection()?.selectAllChildren(code);
            }
          });
          status.append(copy);
        }
      }
      row.append(status);
      list.append(row);
    }
  }

  async function update(stream = null, stop = false) {
    if (!member) return;
    const owner = member;
    const serial = ++requested;
    const headers = {Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest'};
    const options = {credentials: 'same-origin', cache: 'no-store', headers};
    if (stream) {
      headers['X-CSRF-Token'] = document.documentElement.getAttribute('csrf-token') || '';
      options.method = 'POST';
      options.keepalive = stop;
      options.body = new URLSearchParams({
        course_id: root.dataset.mcrProduct, item_id: stream.item,
        activity: stream.kind, stream: stream.id, stop: stop ? '1' : '0'
      });
    }
    try {
      const response = await fetch('/uu-dai/thoi-gian', options);
      const body = await response.json();
      if (member !== owner || serial < applied) return;
      if (response.status === 401) {
        member = 0;
        active = null;
        paint({enabled: false});
      } else if (response.status === 422 && stream && stream === active) {
        blocked = stream.kind + ':' + stream.item;
        active = null;
        announce(body.message);
      } else if (response.ok && body.code === 'success') {
        applied = serial;
        paint(body.data);
        sync();
      }
    } catch (_) {
      // The next heartbeat starts a new interval if the connection was down.
    }
  }

  function source() {
    if (!member || !progress?.enabled || document.hidden || !modal || modal.hidden) return null;
    if (modal.dataset.mcrContent === 'video' && player?.dataset.studyVideo) {
      return {kind: 'video', item: player.dataset.studyVideo};
    }
    if (modal.dataset.mcrContent === 'quiz' && quiz?.dataset.studyQuiz && !quiz.hidden && Date.now() - lastAction < idleLimit) {
      return {kind: 'quiz', item: quiz.dataset.studyQuiz};
    }
    return null;
  }

  function stop() {
    const previous = active;
    active = null;
    if (previous) update(previous, true);
  }

  function sync() {
    const candidate = source();
    if (!candidate) blocked = '';
    if (candidate?.kind === active?.kind && candidate?.item === active?.item) return;
    stop();
    if (!candidate || blocked === candidate.kind + ':' + candidate.item) return;
    const id = Array.from(crypto.getRandomValues(new Uint8Array(12)), byte => byte.toString(16).padStart(2, '0')).join('');
    active = {...candidate, id};
    update(active);
  }

  function noteAction() {
    lastAction = Date.now();
    clearTimeout(idleTimer);
    idleTimer = setTimeout(sync, idleLimit);
  }

  function readMember() {
    const id = Number(root.dataset.mcrMember) || 0;
    if (member === id) return;
    stop();
    member = id;
    paint({enabled: false});
    if (member) update();
  }

  const changes = new MutationObserver(() => {
    const currentQuiz = quiz?.dataset.studyQuiz || '';
    if (currentQuiz !== lastQuiz) {
      lastQuiz = currentQuiz;
      if (lastQuiz) noteAction();
    }
    sync();
  });
  changes.observe(root, {subtree: true, attributes: true, attributeFilter: ['data-study-video', 'data-study-quiz', 'data-mcr-content', 'hidden']});
  ['pointerdown', 'keydown', 'scroll'].forEach(event => modal?.addEventListener(event, () => {
    if (modal.dataset.mcrContent === 'quiz' && quiz?.dataset.studyQuiz && !document.hidden) { noteAction(); sync(); }
  }, {capture: true, passive: true}));

  panel.querySelector('[data-study-open]').addEventListener('click', () => {
    renderMilestones();
    dialog.showModal();
    update();
  });
  root.addEventListener('mcr:access', readMember);
  window.addEventListener('pagehide', stop);
  window.addEventListener('pageshow', event => { if (event.persisted) { update(); sync(); } });
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) stop();
    else { update(); sync(); }
  });
  setInterval(() => {
    const existing = active;
    sync();
    if (active && active === existing) update(active);
  }, 15000);
  readMember();
})();
