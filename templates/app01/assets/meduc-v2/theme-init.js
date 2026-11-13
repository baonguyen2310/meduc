/* Restore the account preference before paint. Invalidate pre-rollout browser choices once. */
(() => {
  'use strict';
  const version = '20261113';
  const root = document.documentElement;
  let saved = null, previous = null;
  try {
    saved = localStorage.getItem('meduc-theme');
    if (localStorage.getItem('meduc-theme-version') !== version) {
      previous = ['light', 'dark'].includes(saved) ? saved : null;
      saved = 'light';
      localStorage.setItem('meduc-theme', saved);
      localStorage.setItem('meduc-theme-version', version);
    }
  } catch (_) { saved = 'light'; }
  const account = Number(root.dataset.meducThemeUser) || 0;
  const api = window.meducTheme = {
    version, customerId:account, legacyTheme:previous,
    apply(next) {
      if (!['light', 'dark'].includes(next)) return;
      root.dataset.meducTheme = next;
      try {
        localStorage.setItem('meduc-theme', next);
        localStorage.setItem('meduc-theme-version', version);
      } catch (_) { /* The palette also works when browser storage is disabled. */ }
      window.dispatchEvent(new CustomEvent('meduc:theme-applied'));
    },
    select(next) {
      api.apply(next);
      window.dispatchEvent(new CustomEvent('meduc:theme-change', {detail:{theme:next}}));
    }
  };
  api.apply(account ? (root.dataset.meducThemeSaved === 'dark' ? 'dark' : 'light') : (saved === 'dark' ? 'dark' : 'light'));
})();
