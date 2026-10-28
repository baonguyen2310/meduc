/* Count the current palette, including the default, without counting repeat views as new people. */
(() => {
  'use strict';
  const root = document.documentElement;
  const csrf = root.getAttribute('csrf-token');
  if (!csrf || !document.getElementById('meduc-header')) return;
  let running = false, queued = '', timer, lastTheme = '', lastSent = 0;
  async function drain() {
    if (running) return;
    running = true;
    try {
      while (queued) {
        const theme = queued; queued = '';
        try {
          const response = await fetch('/theme-usage/record', {
            method:'POST', credentials:'same-origin', cache:'no-store',
            headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8', 'X-CSRF-Token':csrf, 'X-Requested-With':'XMLHttpRequest'},
            body:new URLSearchParams({theme}).toString()
          });
          if (response.ok) { lastTheme = theme; lastSent = Date.now(); }
        } catch (_) { /* Statistics must never interrupt browsing or palette changes. */ }
      }
    } finally { running = false; }
  }
  function report(force = false) {
    if (document.hidden) return;
    const theme = root.dataset.meducTheme;
    if (!['dark','light'].includes(theme)) return;
    if (!force && theme === lastTheme && Date.now() - lastSent < 60000) return;
    queued = theme; drain();
  }
  new MutationObserver(() => {
    clearTimeout(timer); timer = setTimeout(() => report(), 250);
  }).observe(root, {attributes:true, attributeFilter:['data-meduc-theme']});
  window.addEventListener('meduc:authenticated', () => report(true));
  window.addEventListener('focus', () => report());
  window.addEventListener('pageshow', () => report());
  document.addEventListener('visibilitychange', () => report());
  report();
})();
