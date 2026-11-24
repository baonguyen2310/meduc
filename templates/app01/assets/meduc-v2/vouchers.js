(() => {
  'use strict';

  const referralKey = 'meduc-voucher-referral';
  const fromLink = new URLSearchParams(location.search).get('a');
  let referral = fromLink || '';
  try {
    if (fromLink) sessionStorage.setItem(referralKey, fromLink);
    else referral = sessionStorage.getItem(referralKey) || '';
  } catch (_) {}
  referral ||= document.cookie.split('; ').find(cookie => cookie.startsWith('affiliate='))?.slice('affiliate='.length) || '';

  const money = amount => new Intl.NumberFormat('vi-VN', {
    style: 'currency', currency: 'VND', maximumFractionDigits: 0
  }).format(amount);
  const date = new Intl.DateTimeFormat('vi-VN', {dateStyle: 'short', timeZone: 'Asia/Ho_Chi_Minh'});
  const headers = () => ({
    'X-CSRF-Token': document.documentElement.getAttribute('csrf-token') || '',
    'X-Requested-With': 'XMLHttpRequest'
  });

  function node(tag, className, text) {
    const element = document.createElement(tag);
    if (className) element.className = className;
    if (text !== undefined) element.textContent = text;
    return element;
  }

  function button(text, action, className = 'mv-button') {
    const element = node('button', className, text);
    element.type = 'button';
    element.addEventListener('click', action);
    return element;
  }

  async function request(context, codes = [], skipReferral = false) {
    const body = new FormData();
    body.set('source', context.source);
    if (context.source === 'shop') {
      body.set('items', JSON.stringify(context.items));
    } else {
      body.set('package_id', context.packageId);
      context.courseIds.forEach(id => body.append('course_ids[]', id));
    }
    body.set('voucher_codes', JSON.stringify(codes));
    body.set('voucher_referral', referral);
    if (skipReferral) body.set('voucher_skip_referral', '1');
    const response = await fetch('/uu-dai/xem-truoc', {
      method: 'POST', credentials: 'same-origin', body, headers: headers(), cache: 'no-store'
    });
    const result = await response.json().catch(() => null);
    if (!response.ok || result?.code !== 'success') {
      throw new Error(result?.message || 'Chưa kiểm tra được ưu đãi. Vui lòng thử lại.');
    }
    return result.data;
  }

  function panel(host, onChange) {
    host.classList.add('mv-panel');
    const title = node('h3', 'mv-title', 'Mã ưu đãi');
    const entry = node('div', 'mv-entry');
    const input = node('input', 'mv-input');
    input.placeholder = 'Nhập mã ưu đãi';
    input.setAttribute('aria-label', 'Nhập mã ưu đãi');
    input.autocomplete = 'off';
    input.maxLength = 32;
    const apply = button('Áp dụng', () => applyCode(input.value));
    const message = node('p', 'mv-message');
    message.setAttribute('role', 'status');
    const applied = node('ul', 'mv-applied');
    const offers = node('div', 'mv-offers');
    entry.append(input, apply);
    host.replaceChildren(title, entry, message, applied, offers);

    let context, quote, codes = [], skipReferral = false, revision = 0, pending = false;
    host.hidden = true;
    function payload() {
      if (!quote?.enabled) return referral ? {voucher_referral: referral, voucher_skip_referral: '1'} : {};
      return {
        voucher_codes: JSON.stringify(codes),
        voucher_referral: referral,
        voucher_skip_referral: skipReferral ? '1' : '',
        voucher_expected_amount: String(quote.total)
      };
    }

    function draw() {
      host.hidden = !quote?.enabled;
      applied.replaceChildren();
      offers.replaceChildren();
      for (const discount of quote?.discounts || []) {
        const line = node('li', 'mv-applied-line');
        const label = node('div');
        label.append(node('strong', '', discount.label), node('small', '', discount.code));
        const remove = button('Bỏ', () => {
          const next = codes.filter(code => code !== discount.code);
          return refresh(context, next, skipReferral || discount.kind === 'referral', true);
        }, 'mv-remove');
        remove.setAttribute('aria-label', 'Bỏ mã ' + discount.code);
        line.append(label, node('strong', 'mv-amount', '−' + money(discount.amount)), remove);
        applied.append(line);
      }
      if (quote?.partner && !quote.discounts.some(discount => discount.kind === 'referral')) {
        offers.append(node('p', 'mv-message', 'Đã ghi nhận link giới thiệu.'));
      }
      for (const offer of quote?.offers || []) {
        if (quote.discounts.some(discount => discount.code === offer.code)) continue;
        const value = offer.type === 'percent' ? offer.value + '%' : money(offer.value);
        const choice = node('div', 'mv-choice');
        const description = node('div');
        description.append(node('strong', '', offer.name + ' · Giảm ' + value));
        if (offer.expires_at) {
          description.append(node('small', '', 'Dùng đến hết ' + date.format((offer.expires_at - 1) * 1000)));
        }
        choice.append(description, button('Dùng', () => applyCode(offer.code), 'mv-choice-button'));
        offers.append(choice);
      }
      onChange?.(quote, pending, payload());
    }

    function applyCode(value) {
      const code = value.trim().toUpperCase();
      if (!code || pending) return;
      return refresh(context, codes.includes(code) ? codes : [...codes, code], skipReferral, true);
    }

    async function refresh(nextContext, nextCodes = codes, nextSkip = skipReferral, editing = false, initial = null) {
      context = nextContext;
      const run = ++revision;
      const previous = editing ? quote : null;
      if (!editing) quote = null;
      pending = !initial;
      apply.disabled = pending;
      message.textContent = '';
      onChange?.(quote, pending, {});
      try {
        const result = initial || await request(context, nextCodes, nextSkip);
        if (run !== revision) return;
        quote = result;
        codes = nextCodes;
        skipReferral = nextSkip;
        if (editing) input.value = '';
      } catch (error) {
        if (run !== revision) return;
        quote = previous;
        host.hidden = false;
        message.textContent = error.message || 'Chưa tải được mã ưu đãi.';
        onChange?.(null, false, {});
      } finally {
        if (run === revision) {
          pending = false;
          apply.disabled = false;
          if (quote) draw();
        }
      }
    }

    input.addEventListener('keydown', event => {
      if (event.key === 'Enter') {
        event.preventDefault();
        applyCode(input.value);
      }
    });
    return {refresh, payload};
  }

  async function review(context, trigger, requireVoucher = false) {
    const initial = await request(context);
    if (!initial.enabled) {
      if (requireVoucher) throw new Error('Gói này hiện chưa có chương trình ưu đãi.');
      return referral ? {voucher_referral: referral, voucher_skip_referral: '1'} : {};
    }
    return new Promise(resolve => {
      const dialog = node('dialog', 'mv-dialog');
      dialog.setAttribute('aria-label', 'Ưu đãi cho đơn hàng');
      const host = node('div');
      const total = node('strong', 'mv-total');
      const continueOrder = button('Tiếp tục thanh toán', () => {
        result = editor.payload();
        dialog.close();
      });
      const actions = node('div', 'mv-actions');
      actions.append(button('Quay lại', () => dialog.close(), 'mv-remove'), continueOrder);
      dialog.append(host, total, actions);
      let result = null;
      const editor = panel(host, (quote, pending) => {
        total.textContent = quote ? 'Tổng thanh toán ' + money(quote.total) : '';
        continueOrder.disabled = pending || !quote;
      });
      dialog.addEventListener('close', () => {
        dialog.remove();
        trigger?.focus();
        resolve(result);
      }, {once: true});
      document.body.append(dialog);
      editor.refresh(context, [], false, false, initial);
      dialog.showModal();
    });
  }

  function fields(form, payload) {
    form.querySelectorAll('[data-voucher-input]').forEach(input => input.remove());
    Object.entries(payload).forEach(([name, value]) => {
      if (value === '') return;
      const input = node('input');
      input.type = 'hidden';
      input.name = name;
      input.value = value;
      input.setAttribute('data-voucher-input', '');
      form.append(input);
    });
  }

  window.MeducVouchers = {panel, review, fields};

  let member = document.getElementById('meduc-header')?.dataset.voucherMember === '1';
  let studyAvailable = true;
  let lastActivity = Date.now(), lastPing = 0;
  function markActivity() {
    lastActivity = Date.now();
  }
  function study() {
    const now = Date.now();
    if (!member || !studyAvailable || document.visibilityState !== 'visible' || !document.hasFocus()
      || now - lastActivity > 120000 || now - lastPing < 29000) return;
    lastPing = now;
    fetch('/uu-dai/thoi-gian', {method: 'POST', headers: headers(), credentials: 'same-origin', cache: 'no-store'})
      .then(response => { if (response.headers.get('X-Meduc-Study') === 'inactive') studyAvailable = false; })
      .catch(() => {});
  }
  ['pointerdown', 'keydown', 'scroll'].forEach(event => window.addEventListener(event, markActivity, {passive: true}));
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      markActivity();
      study();
    }
  });
  window.addEventListener('meduc:authenticated', () => { member = true; studyAvailable = true; markActivity(); study(); });
  study();
  window.setInterval(study, 30000);
})();
