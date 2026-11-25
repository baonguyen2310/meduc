(() => {
  'use strict';

  const widget = document.querySelector('[data-online-widget]');
  if (!widget) return;
  const contact = document.querySelector('.contact-fixed');
  if (contact) {
    contact.append(widget);
    widget.addEventListener('click', event => event.stopPropagation());
  }

  const root = document.documentElement;
  const page = document.querySelector('[data-voucher-center]');
  const dashboard = page?.querySelector('[data-online-dashboard]');
  const notice = page?.querySelector('[data-voucher-notice]');
  const clock = widget.querySelector('[data-online-clock]');
  const formatDate = new Intl.DateTimeFormat('vi-VN', {day: 'numeric', month: 'numeric', timeZone: 'Asia/Ho_Chi_Minh'});
  const formatMoney = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'});
  const interval = 30000;
  let signedIn = Number(root.dataset.meducThemeUser) > 0 || !!dashboard;
  let stream, timer, noticeTimer, lastSent = 0, saving = false, current = null, milestoneKey = '';
  let pendingPulse = null, claimRevision = 0;

  function duration(seconds, compact = false) {
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    if (!minutes) return Math.floor(seconds) + (compact ? 's' : ' giây');
    if (!hours) return minutes + (compact ? 'p' : ' phút');
    const rest = minutes % 60;
    return hours + (compact ? 'g' : ' giờ') + (rest ? ' ' + rest + (compact ? 'p' : ' phút') : '');
  }

  function text(tag, value, className = '') {
    const element = document.createElement(tag);
    element.textContent = value;
    if (className) element.className = className;
    return element;
  }

  function button(label) {
    const element = text('button', label);
    element.type = 'button';
    return element;
  }

  function message(value) {
    if (!notice) return;
    notice.textContent = value;
    clearTimeout(noticeTimer);
    noticeTimer = setTimeout(() => { notice.textContent = ''; }, 4500);
  }

  async function request(path, data, keepalive = false) {
    const response = await fetch(path, {
      method: 'POST', credentials: 'same-origin', cache: 'no-store', keepalive,
      headers: {
        'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': root.getAttribute('csrf-token') || '',
      },
      body: new URLSearchParams(data),
    });
    const result = await response.json();
    if (!response.ok || result.code !== 'success') {
      const error = new Error(result.message || 'Vui lòng thử lại.');
      error.status = response.status;
      throw error;
    }
    return result.data;
  }

  function renderMilestones(rewards) {
    const key = JSON.stringify(rewards);
    if (key === milestoneKey) return;
    milestoneKey = key;
    const list = dashboard.querySelector('[data-online-milestones]');
    list.replaceChildren();
    for (const reward of rewards) {
      const tile = document.createElement('li');
      tile.className = 'mvp-milestone';
      tile.dataset.onlineReward = String(reward.id);
      const value = reward.type === 'percent' ? reward.value + '%' : formatMoney.format(reward.value);
      tile.append(text('h3', duration(reward.target_seconds)), text('strong', 'Giảm ' + value, 'mvp-discount'));
      if (reward.code) {
        const code = document.createElement('div');
        code.className = 'mvp-code';
        const copy = button('Sao chép');
        copy.dataset.copyVoucher = reward.code;
        code.append(text('code', reward.code), copy);
        tile.append(code, text('p', 'Dùng đến hết ' + formatDate.format((reward.expires_at - 1) * 1000)));
      } else if (reward.claimable) {
        const claim = button('Nhận mã');
        claim.className = 'mvp-claim';
        claim.dataset.claimOnline = String(reward.id);
        tile.append(claim);
      } else {
        tile.append(text('p', 'Chưa đạt mốc'));
      }
      list.append(tile);
    }
  }

  function render(data) {
    if (!data.enabled) {
      widget.hidden = true;
      if (dashboard) dashboard.querySelector('[data-online-next]').textContent = 'Chưa tải được thời gian online.';
      return;
    }
    if (current && (data.week_start < current.week_start ||
      (data.week_start === current.week_start && data.server_at < current.server_at))) return;
    current = data;
    const next = data.rewards.find(reward => reward.target_seconds > data.seconds);
    const target = next?.target_seconds || data.goal_seconds;
    const fill = target ? Math.min(100, 100 * data.seconds / target) : 0;
    widget.style.setProperty('--mob-fill', fill + '%');
    widget.setAttribute('aria-label', 'Online tuần này ' + duration(data.seconds) + '. Xem ưu đãi');
    const compactTime = duration(data.seconds, true);
    clock.textContent = compactTime;
    clock.style.setProperty('--mob-clock-length', String(compactTime.length));
    widget.hidden = false;

    if (!dashboard) return;
    const waiting = data.rewards.filter(reward => reward.claimable).length;
    dashboard.querySelector('[data-online-total]').textContent = duration(data.seconds);
    dashboard.querySelector('[data-online-reset]').textContent =
      'Tính lại lúc 00:00 thứ Hai, ' + formatDate.format(data.resets_at * 1000);
    const meter = dashboard.querySelector('[data-online-meter]');
    meter.max = target || 1;
    meter.value = target ? Math.min(target, data.seconds) : 0;
    meter.hidden = !target;
    dashboard.querySelector('[data-online-next]').textContent = waiting
      ? waiting + ' mã đang chờ nhận'
      : next ? 'Còn ' + duration(Math.ceil((next.target_seconds - data.seconds) / 60) * 60) + ' đến mốc tiếp theo'
        : target ? 'Đã đạt các mốc tuần này' : 'Hiện chưa có mốc thưởng.';
    renderMilestones(data.rewards);
  }

  function newStream() {
    return Array.from(crypto.getRandomValues(new Uint8Array(16)), byte => byte.toString(16).padStart(2, '0')).join('');
  }

  function start() {
    if (!signedIn || stream) return;
    stream = newStream();
    pulse();
  }

  async function pulse() {
    if (!stream || pendingPulse === stream) return;
    clearTimeout(timer);
    const active = stream;
    const revision = claimRevision;
    pendingPulse = active;
    lastSent = Date.now();
    try {
      const data = await request('/uu-dai/online', {stream: active});
      if (stream === active && revision === claimRevision && !saving) render(data);
    } catch (error) {
      if (stream === active && error.status === 401) {
        signedIn = false;
        stream = null;
        current = null;
        widget.hidden = true;
      }
    } finally {
      if (pendingPulse === active) pendingPulse = null;
      if (stream === active) timer = setTimeout(pulse, interval);
    }
  }

  async function claim(control) {
    if (saving || !current) return;
    saving = true;
    claimRevision++;
    const campaign = Number(control.dataset.claimOnline);
    control.disabled = true;
    try {
      const data = await request('/uu-dai/online/nhan-ma', {
        campaign_id: campaign, week_start: current.week_start,
      });
      render(data.progress);
      dashboard.querySelector(`[data-online-reward="${campaign}"] [data-copy-voucher]`)?.focus();
      message('Đã nhận mã. Dùng mã khi thanh toán Khoá ôn kiến thức.');
    } catch (error) {
      message(error.message);
      if (error.status === 422) pulse();
    } finally {
      saving = false;
      control.disabled = false;
    }
  }

  async function copy(control) {
    try {
      await navigator.clipboard.writeText(control.dataset.copyVoucher);
      message('Đã sao chép mã.');
    } catch (_) {
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(control.parentElement.querySelector('code'));
      selection?.removeAllRanges();
      selection?.addRange(range);
      message('Mã đã được chọn để sao chép.');
    }
  }

  page?.addEventListener('click', event => {
    const claimControl = event.target.closest('[data-claim-online]');
    const copyControl = event.target.closest('[data-copy-voucher]');
    if (claimControl) claim(claimControl);
    if (copyControl) copy(copyControl);
  });

  window.addEventListener('meduc:authenticated', () => {
    signedIn = true;
    start();
  });
  window.addEventListener('pagehide', () => {
    const active = stream;
    stream = null;
    clearTimeout(timer);
    if (active) request('/uu-dai/online', {stream: active, leaving: '1'}, true).catch(() => {});
  });
  window.addEventListener('pageshow', start);
  window.addEventListener('online', () => pulse());
  document.addEventListener('visibilitychange', () => {
    if (!document.hidden && Date.now() - lastSent >= interval) pulse();
  });
  start();
})();
