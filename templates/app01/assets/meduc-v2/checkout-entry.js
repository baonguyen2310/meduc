(() => {
  'use strict';
  let pending = null, checking = false;
  async function context() {
    const response = await fetch('/checkout/customer', {credentials:'same-origin', cache:'no-store'});
    const result = await response.json();
    if (!response.ok || result.code !== 'success') throw new Error('Chưa lấy được thông tin tài khoản. Vui lòng thử lại.');
    return result.data;
  }
  function login(trigger, resume) {
    pending = resume;
    window.meducAuth?.open('login', trigger);
  }
  function fill(root, contact, overwrite = false) {
    root.querySelectorAll('[data-checkout-contact] input[name]').forEach(input => {
      if (overwrite || !input.dataset.edited || input.name === 'email') input.value = contact[input.name] || '';
      if (!input.dataset.contactBound) {
        input.dataset.contactBound = '1';
        input.addEventListener('input', () => { input.dataset.edited = '1'; });
      }
    });
  }
  async function go(href, trigger) {
    const url = new URL(href, location.origin);
    if (url.origin !== location.origin || url.pathname !== '/dat-hang') { location.assign(href); return; }
    const data = await context();
    if (data.member) location.assign(url.href);
    else login(trigger, () => location.assign(url.href));
  }
  window.MeducCheckout = {context, login, fill, go};
  window.addEventListener('meduc:authenticated', () => {
    if (!pending) return;
    const resume = pending;pending = null;
    const auth = document.getElementById('login-modal');
    if (window.jQuery && auth && auth.style.display !== 'none') window.jQuery(auth).one('hidden.bs.modal', resume);
    else resume();
  });
  window.addEventListener('meduc:auth-closed', event => {if (!event.detail?.authenticated) pending = null;});
  document.addEventListener('click', async event => {
    const link = event.target.closest('a[href]');
    if (!link || event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    const url = new URL(link.href, location.origin);
    if (url.origin !== location.origin || url.pathname !== '/dat-hang') return;
    event.preventDefault();event.stopImmediatePropagation();
    if (checking) return;
    checking = true;
    try {
      await go(url.href, link);
    } catch (_) { location.assign(url.href); }
    finally { checking = false; }
  }, true);
})();
