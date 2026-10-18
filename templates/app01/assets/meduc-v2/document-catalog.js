(() => {
  'use strict';
  const root = document.querySelector('#document-catalog-page');
  if (!root) return;
  // Keep native library anchors clear of both the header and the year navigation.
  const paths = root.querySelector('.mdc-paths');
  if (paths) {
    const years = paths.querySelector('.mdc-year-grid');
    let previousWidth = 0;
    const measurePaths = () => {
      root.style.setProperty('--mdc-paths-h', `${paths.offsetHeight}px`);
      if (years && years.clientWidth !== previousWidth) {
        previousWidth = years.clientWidth;
        const current = years.querySelector('[aria-current]');
        if (current && years.scrollWidth > years.clientWidth) {
          years.scrollLeft = current.offsetLeft - (years.clientWidth - current.offsetWidth) / 2;
        }
      }
    };
    measurePaths();
    if ('ResizeObserver' in window) new ResizeObserver(measurePaths).observe(paths);
    else window.addEventListener('resize', measurePaths);
  }
  const grid = root.querySelector('[data-document-grid]');
  const cards = [...root.querySelectorAll('[data-document-card]')];
  const search = root.querySelector('#document-search');
  const subject = root.querySelector('#document-subject');
  const sort = root.querySelector('#document-sort');
  const status = root.querySelector('[data-document-status]');
  const more = root.querySelector('[data-document-more]');
  const clear = root.querySelector('[data-document-clear]');
  const reset = root.querySelector('[data-document-reset]');
  const empty = root.querySelector('[data-document-empty]');
  const normalize = value => value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase().replace(/\s+/g, ' ').trim();
  const items = cards.map((card, index) => ({
    card, index, subject: card.dataset.subject,
    text: normalize(card.textContent),
    title: card.querySelector('[data-document-title]').textContent.trim(),
    created: Number(card.dataset.created) || 0
  }));
  let limit = 12;
  root.querySelectorAll('.mdc-cover img, .mdc-paper-grid img').forEach(img => {
    const fallback = () => img.remove();
    img.addEventListener('error', fallback, { once: true });
    if (img.complete && img.naturalWidth === 0) fallback();
  });
  function render() {
    const term = normalize(search.value);
    const matches = items.filter(item => (subject.value === 'all' || item.subject === subject.value) && (!term || item.text.includes(term)));
    const collator = new Intl.Collator('vi', { numeric: true, sensitivity: 'base' });
    matches.sort((a, b) => {
      if (sort.value === 'newest') return b.created - a.created || a.index - b.index;
      if (sort.value === 'oldest') return a.created - b.created || a.index - b.index;
      if (sort.value === 'name') return collator.compare(a.title, b.title);
      return a.index - b.index;
    });
    cards.forEach(card => { card.hidden = true; });
    const fragment = document.createDocumentFragment();
    matches.slice(0, limit).forEach(item => { item.card.hidden = false; fragment.append(item.card); });
    grid.append(fragment);
    status.textContent = matches.length ? `Hiển thị ${Math.min(limit, matches.length)} / ${matches.length} tài liệu` : 'Không tìm thấy tài liệu phù hợp';
    more.hidden = limit >= matches.length;
    more.textContent = `Xem thêm tài liệu (${Math.max(0, matches.length - limit)}) ↓`;
    empty.hidden = matches.length > 0;
    clear.hidden = !search.value;
    reset.hidden = !term && subject.value === 'all' && sort.value === 'default';
  }
  function resetFilters() {
    search.value = ''; subject.value = 'all'; sort.value = 'default'; limit = 12;
    render(); search.focus({ preventScroll: true });
  }
  root.querySelector('[data-document-tools]').hidden = false;
  root.querySelector('[data-document-tools]').addEventListener('submit', event => { event.preventDefault(); render(); });
  search.addEventListener('input', () => { limit = 12; render(); });
  subject.addEventListener('change', () => { limit = 12; render(); });
  sort.addEventListener('change', () => { limit = 12; render(); });
  clear.addEventListener('click', () => { search.value = ''; limit = 12; render(); search.focus({ preventScroll: true }); });
  reset.addEventListener('click', resetFilters);
  root.querySelector('[data-document-empty-reset]').addEventListener('click', resetFilters);
  more.addEventListener('click', () => {
    const previous = limit;
    limit += 12; render();
    // Keep keyboard focus at the first newly revealed resource.
    const visible = [...grid.querySelectorAll('[data-document-card]:not([hidden])')];
    visible[previous]?.querySelector('.mdc-cover')?.focus({ preventScroll: true });
  });
  render();
})();
