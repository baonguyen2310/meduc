/* Keep explicit switches in order. Observing or syncing a page is not a user switch. */
(() => {
  'use strict';
  const root = document.documentElement, api = window.meducTheme;
  const csrf = root.getAttribute('csrf-token');
  if (!csrf || !api || !document.getElementById('meduc-header')) return;
  let queue = [], running = false, generation = 0, revision = 0, lastSent = 0, retryTimer;
  function eventId() {
    const bytes = new Uint8Array(16);
    window.crypto.getRandomValues(bytes);
    return Array.from(bytes, n => n.toString(16).padStart(2, '0')).join('');
  }
  function browserTheme() {
    try {
      if (localStorage.getItem('meduc-theme-version') === api.version) {
        const saved = localStorage.getItem('meduc-theme');
        if (['light', 'dark'].includes(saved)) return saved;
      }
    } catch (_) {}
    return root.dataset.meducTheme === 'dark' ? 'dark' : 'light';
  }
  async function drain() {
    if (running) return;
    clearTimeout(retryTimer); running = true;
    try {
      while (queue.length) {
        const job = queue.shift();
        if (job.generation !== generation) continue;
        const body = {mode:job.mode, version:api.version, customer_id:String(api.customerId),
          theme:job.theme};
        if (job.eventId) body.event_id = job.eventId;
        if (api.legacyTheme) body.legacy_theme = api.legacyTheme;
        try {
          const response = await fetch('/theme-usage/record', {
            method:'POST', credentials:'same-origin', cache:'no-store', keepalive:true,
            headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8', 'X-CSRF-Token':csrf, 'X-Requested-With':'XMLHttpRequest'},
            body:new URLSearchParams(body).toString()
          });
          if (job.generation !== generation) continue;
          if (response.status === 409) {
            generation++; queue = [{mode:'sync', theme:browserTheme(), generation, revision}]; continue;
          }
          if (!response.ok) throw new Error('Theme preference unavailable');
          const state = await response.json();
          if (job.generation !== generation) continue;
          if (!['light', 'dark'].includes(state.theme) || String(state.version) !== api.version) throw new Error('Invalid theme state');
          api.customerId = Number(state.customer_id) || 0;
          api.legacyTheme = null; lastSent = Date.now();
          // An earlier response must not flash over a newer click or account sign-in.
          if (job.revision === revision) api.apply(state.theme);
        } catch (_) {
          if (job.generation === generation) {
            queue.unshift(job);
            retryTimer = setTimeout(drain, 5000);
            break;
          }
        }
      }
    } finally { running = false; }
  }
  function sync(force = false) {
    if (document.hidden || (!force && Date.now() - lastSent < 60000)) return;
    if (!queue.some(job => job.mode === 'sync' && job.generation === generation)) queue.push({mode:'sync', theme:browserTheme(), generation, revision});
    drain();
  }
  window.addEventListener('meduc:theme-change', event => {
    if (!['light', 'dark'].includes(event.detail?.theme)) return;
    revision++;
    queue.push({mode:'change', theme:event.detail.theme, eventId:eventId(), generation, revision});
    drain();
  });
  window.addEventListener('meduc:authenticated', () => {
    generation++; queue = [];
    sync(true);
  });
  window.addEventListener('storage', event => {
    if (event.key === 'meduc-theme') sync(true);
  });
  window.addEventListener('focus', () => sync());
  window.addEventListener('pageshow', () => sync());
  document.addEventListener('visibilitychange', () => sync());
  sync(true);
})();
