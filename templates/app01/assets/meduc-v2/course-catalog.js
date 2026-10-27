/* Search/sort enhance the server-rendered, year-grouped catalogue. All course and registration links work without this script. */
(() => {
  'use strict';
  const page = document.querySelector('#course-catalog');
  if (!page) return;
  const input = page.querySelector('#catalog-search');
  const sort = page.querySelector('#catalog-sort');
  const status = page.querySelector('[data-catalog-status]');
  const empty = page.querySelector('[data-catalog-empty]');
  const clear = page.querySelector('[data-catalog-clear]');
  const reset = page.querySelector('[data-catalog-reset]');
  const groups = [...page.querySelectorAll('[data-course-group]')].map(section => ({section,list:section.querySelector('[data-course-list]'),cards:[...section.querySelectorAll('[data-course-card]')]}));
  const normalize = text => text.toLocaleLowerCase('vi').normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/đ/g,'d');
  const collator = new Intl.Collator('vi', {sensitivity:'base',numeric:true});
  const names = new Map(groups.flatMap(group => group.cards.map(card => [card,normalize(card.dataset.courseName)])));
  const total = new Set(groups.flatMap(group => group.cards.map(card => card.dataset.courseId))).size;
  page.querySelector('[data-catalog-tools]').hidden = false;
  const mobileLayout = matchMedia("(max-width: 767.98px)");
  for (const group of groups) {
    const key = `meduc-course-layout-${group.section.dataset.courseGroupId}`;
    const buttons = [...group.section.querySelectorAll('[data-catalog-layout]')];
    function setLayout(layout) {
      group.section.dataset.courseLayout = layout === 'grid' ? 'grid' : 'list';
      for (const button of buttons) button.setAttribute('aria-pressed', String(button.dataset.catalogLayout === group.section.dataset.courseLayout));
    }
    let desktopLayout = 'list';
    try { desktopLayout = localStorage.getItem(key) === 'grid' ? 'grid' : 'list'; } catch (_) { /* Keep the desktop default. */ }
    const switcher = group.section.querySelector('[data-layout-switch]');
    function syncLayout() {
      setLayout(mobileLayout.matches ? 'grid' : desktopLayout);
      switcher.hidden = mobileLayout.matches;
    }
    for (const button of buttons) button.addEventListener('click', () => {
      if (mobileLayout.matches) return;
      desktopLayout = button.dataset.catalogLayout;
      syncLayout();
      try { localStorage.setItem(key, desktopLayout); } catch (_) { /* Layout switching still works when storage is unavailable. */ }
    });
    mobileLayout.addEventListener('change', syncLayout);
    syncLayout();
  }
  function update() {
    const words = normalize(input.value.trim()).split(/\s+/).filter(Boolean);
    const ids = new Set();
    for (const group of groups) {
      const cards = [...group.cards].sort((a,b) => {
        if (sort.value==='name') return collator.compare(a.dataset.courseName,b.dataset.courseName);
        if (sort.value==='price-up') return Number(a.dataset.coursePrice)-Number(b.dataset.coursePrice);
        if (sort.value==='price-down') return Number(b.dataset.coursePrice)-Number(a.dataset.coursePrice);
        return Number(a.dataset.courseOrder)-Number(b.dataset.courseOrder);
      });
      let visible = 0;
      for (const card of cards) {
        card.hidden = !words.every(word => names.get(card).includes(word));
        if (!card.hidden) { visible++; ids.add(card.dataset.courseId); }
        group.list.append(card);
      }
      group.section.hidden = visible===0;
      group.section.querySelector('[data-group-count]').textContent = visible;
    }
    empty.hidden = ids.size>0;
    reset.hidden = input.value.length===0;
    clear.hidden = input.value.length===0;
    // data-catalog-noun: "môn luyện thi" on the exam-prep page.
    const noun = status.dataset.catalogNoun || "khóa học";
    status.textContent = words.length ? `Tìm thấy ${ids.size} / ${total} ${noun}` : `Hiển thị ${total} ${status.dataset.catalogNoun || "khóa học đang mở"}`;
  }
  input.addEventListener('input',update);
  sort.addEventListener('change',update);
  function clearSearch() { input.value=''; update(); input.focus(); }
  clear.addEventListener('click',clearSearch);
  reset.addEventListener('click',clearSearch);
  update();
})();
