(() => {
  'use strict';
  const detail = document.getElementById('document-detail-page');
  const payment = document.querySelector('[data-document-payment]');
  if (!detail && !payment) return;
  let context = null, busy = false, loginIntent = null, requestSerial = 0;
  const query = (selector) => (payment || detail).querySelector(selector);
  const message = (text, error = false) => {
    (payment || detail).querySelectorAll('[data-download-message]').forEach((node) => { node.textContent = text; node.hidden = !text; node.toggleAttribute('data-error', error); });
  };
  async function api(path, body) {
    const response = await fetch('/document-download/' + path, {
      method: body ? 'POST' : 'GET', credentials: 'same-origin', cache: 'no-store',
      headers: {'X-Requested-With':'XMLHttpRequest', ...(body ? {'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8', 'X-CSRF-Token':document.documentElement.getAttribute('csrf-token') || ''} : {})},
      ...(body ? {body:new URLSearchParams(body).toString()} : {})
    });
    let result; try { result = await response.json(); } catch (_) { throw new Error('Chưa kết nối được. Vui lòng thử lại.'); }
    if (!response.ok) { const error = new Error(result.message || 'Vui lòng thử lại.'); error.status = response.status; throw error; }
    return result.data;
  }
  function authenticate(trigger, intent) {
    loginIntent = intent;
    const dialog = detail?.querySelector('[data-document-dialog]');
    if (dialog?.open) dialog.querySelector('[data-document-fullscreen]')?.click();
    if (window.meducAuth?.open) window.meducAuth.open('login', trigger, {message:'Đăng nhập để mua và lưu lượt tải tài liệu vào tài khoản của bạn.'});
    else document.querySelector('[data-ma-open="login"]')?.click();
  }
  function download(url) {
    const link = document.createElement('a'); link.href = url; link.hidden = true;
    document.body.append(link); link.click(); link.remove();
  }
  function selectedIndex() {
    return Number(detail?.querySelector('[data-document-file][aria-current="true"]')?.dataset.documentFile || 0);
  }
  function updateButtons() {
    detail?.querySelectorAll('[data-download-buy]').forEach((button) => {
      const index = button.dataset.downloadBuy === 'selected' ? selectedIndex() : Number(button.dataset.downloadBuy);
      const file = context?.files.find((item) => item.index === index);
      const state = file?.purchase?.state;
      button.disabled = busy || !!file?.unavailable;
      button.textContent = file?.unavailable ? 'Chưa hỗ trợ tải tệp này' : ['available','active'].includes(state) ? 'Tải tệp đã mua ↓' : state === 'pending' ? (file.purchase.reported ? 'Xem đơn chờ xác nhận' : 'Tiếp tục thanh toán') : 'Mua lượt tải · 9.999đ';
    });
  }
  async function refreshDetail() {
    const serial = ++requestSerial;
    const next = await api('context?article=' + encodeURIComponent(detail.dataset.readingId));
    if (serial === requestSerial) { context = next; updateButtons(); }
    return context;
  }
  async function buy(index, trigger) {
    if (busy) return;
    busy = true; updateButtons(); message('');
    try {
      await refreshDetail();
      if (!context.customer_id) { authenticate(trigger, index); return; }
      const file = context.files.find((item) => item.index === index);
      if (!file || file.unavailable) throw new Error('Tệp này chưa hỗ trợ mua lượt tải.');
      if (['available','active'].includes(file.purchase?.state)) {
        const ticket = await api('start/' + file.purchase.code, {}); download(ticket.url);
        message('Đã bắt đầu tải. Bạn có thể thử lại trong 30 phút nếu mạng bị gián đoạn.');
      } else if (file.purchase?.state === 'pending') location.assign(file.purchase.payment_url);
      else {
        const result = await api('purchase', {nonce:file.nonce, expected_customer_id:context.customer_id});
        location.assign(result.redirect);
      }
    } catch (error) {
      if (error.status === 401) authenticate(trigger, index); else message(error.message, true);
    } finally { busy = false; updateButtons(); }
  }
  let paymentData = null;
  const labels = {pending:'Chờ thanh toán',available:'Đã thanh toán · Sẵn sàng tải',active:'Đã mở lượt tải',used:'Lượt tải đã sử dụng',cancelled:'Đơn đã huỷ',revoked:'Thanh toán không còn hiệu lực'};
  function paintPayment(data) {
    paymentData = data;
    query('[data-download-login]').hidden = true; query('[data-download-private]').hidden = false;
    query('[data-download-title]').textContent = data.document_title;
    query('[data-download-filename]').textContent = data.file_name;
    query('[data-download-order]').textContent = data.order_code;
    query('[data-download-state]').textContent = data.state === 'pending' && data.reported ? 'Chờ MedUC xác nhận' : labels[data.state];
    query('[data-payment-reference]').textContent = data.order_code;
    query('[data-download-back]').href = data.document_url + '?tiep-tuc=1#document-reader';
    const ready = ['available','active'].includes(data.state);
    query('[data-download-file]').hidden = !ready;
    query('.mds-invoice').classList.toggle('is-ready', ready);
    query('[data-download-qr]').hidden = data.state !== 'pending';
    const transfer = query('[data-download-transfer]');
    transfer.disabled = data.reported || busy;
    transfer.textContent = data.reported ? 'Đang chờ xác nhận' : 'Đã chuyển khoản';
    message(data.state === 'pending' ? data.reported ? 'Đã nhận thông báo chuyển khoản. MedUC sẽ kiểm tra và mở lượt tải sau khi xác nhận.' : 'Chuyển khoản 9.999đ với đúng nội dung mã đơn dưới đây, rồi bấm “Đã chuyển khoản”.' : ready ? 'Thanh toán đã được xác nhận. Bạn có thể tải đúng tệp đã mua.' : data.state === 'used' ? 'Lượt tải này đã sử dụng và hết thời gian thử lại. Về tài liệu để mua lượt mới.' : 'Lượt tải này hiện không khả dụng.', ['cancelled','revoked'].includes(data.state));
  }
  async function refreshPayment(quiet = false) {
    try { paintPayment(await api('status/' + payment.dataset.documentPayment)); }
    catch (error) {
      if (error.status === 401) { paymentData = null; query('[data-download-private]').hidden = true; query('[data-download-login]').hidden = false; message('Vui lòng đăng nhập để xem đơn mua lượt tải.'); }
      else if (!quiet || error.status === 404) { query('[data-download-private]').hidden = true; message(error.message, true); }
    }
  }
  if (detail) {
    detail.addEventListener('click', (event) => {
      const button = event.target.closest('[data-download-buy]');
      if (button) buy(button.dataset.downloadBuy === 'selected' ? selectedIndex() : Number(button.dataset.downloadBuy), button);
    });
    new MutationObserver(updateButtons).observe(detail, {subtree:true,attributes:true,attributeFilter:['aria-current']});
    refreshDetail().catch((error) => message(error.message, true));
  } else {
    payment.addEventListener('click', async (event) => {
      const transfer = event.target.closest('[data-download-transfer]');
      const start = event.target.closest('[data-download-file]');
      if ((!transfer && !start) || busy) return;
      busy = true; (transfer || start).disabled = true;
      try {
        if (transfer) paintPayment(await api('transfer/' + payment.dataset.documentPayment, {}));
        else { const ticket = await api('start/' + payment.dataset.documentPayment, {}); download(ticket.url); message('Đã bắt đầu tải. Bạn có thể thử lại trong 30 phút.'); }
      } catch (error) {
        if (error.status === 401) { query('[data-download-private]').hidden = true; authenticate(start || transfer, 'payment'); }
        else message(error.message, true);
      } finally { busy = false; if (start) start.disabled = false; if (transfer) transfer.disabled = !!paymentData?.reported; }
    });
    refreshPayment();
    setInterval(() => { if (!document.hidden && !busy && paymentData?.state === 'pending') refreshPayment(true); }, 5000);
  }
  window.addEventListener('meduc:authenticated', async () => {
    const intent = loginIntent; loginIntent = null;
    if (detail) { try { await refreshDetail(); if (Number.isInteger(intent)) buy(intent, query('[data-download-buy]')); } catch (error) { message(error.message, true); } }
    else refreshPayment();
  });
  window.addEventListener('meduc:auth-closed', (event) => { if (!event.detail?.authenticated) loginIntent = null; });
  window.addEventListener('focus', () => { if (!busy) { if (detail) refreshDetail().catch(() => {}); else refreshPayment(true); } });
})();
