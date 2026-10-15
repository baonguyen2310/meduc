/* The server supplies the live book catalogue. Purchases use MedUC's existing sessionStorage book cart. */
(() => {
  'use strict';
  const page = document.querySelector('#book-catalog-page');
  if (!page) return;
  const grid = page.querySelector('[data-book-grid]');
  const cards = [...grid.querySelectorAll('[data-book-card]')];
  const input = page.querySelector('#book-search');
  const stage = page.querySelector('#book-stage');
  const sort = page.querySelector('#book-sort');
  const status = page.querySelector('[data-book-status]');
  const empty = page.querySelector('[data-book-empty]');
  const more = page.querySelector('[data-book-more]');
  const clear = page.querySelector('[data-book-clear]');
  const reset = page.querySelector('[data-book-reset]');
  const normalize = value => value.toLocaleLowerCase('vi').normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/đ/g,'d');
  const names = new Map(cards.map(card => [card,normalize(card.dataset.bookSearch)]));
  const collator = new Intl.Collator('vi',{sensitivity:'base',numeric:true});
  let visibleCount = 12;
  page.querySelector('[data-book-tools]').hidden = false;
  window.MeducBookCart.bindCards(page);
  function render() {
    const words = normalize(input.value.trim()).split(/\s+/).filter(Boolean);
    const filtered = cards.filter(card => (stage.value === 'all' || card.dataset.bookCategories.split(',').includes(stage.value)) && words.every(word => names.get(card).includes(word)));
    filtered.sort((a,b) => {
      if (sort.value === 'name') return collator.compare(a.dataset.bookName,b.dataset.bookName);
      if (sort.value === 'price-up') return (Number(a.dataset.bookPrice) || Infinity) - (Number(b.dataset.bookPrice) || Infinity);
      if (sort.value === 'price-down') return Number(b.dataset.bookPrice) - Number(a.dataset.bookPrice);
      return Number(a.dataset.bookOrder) - Number(b.dataset.bookOrder);
    });
    cards.forEach(card => { card.hidden = true; });
    filtered.forEach((card,index) => { card.hidden = index >= visibleCount; grid.append(card); });
    status.textContent = `Hiển thị ${Math.min(visibleCount,filtered.length)} / ${filtered.length} đầu sách`;
    empty.hidden = filtered.length > 0;
    more.hidden = visibleCount >= filtered.length;
    clear.hidden = input.value.length === 0;
    reset.hidden = input.value.length === 0 && stage.value === 'all';
  }
  input.addEventListener('input',() => { visibleCount = 12; render(); });
  stage.addEventListener('change',() => { visibleCount = 12; render(); });
  sort.addEventListener('change',render);
  more.addEventListener('click',() => { visibleCount += 12; render(); });
  clear.addEventListener('click',() => { input.value = ''; visibleCount = 12; render(); input.focus(); });
  reset.addEventListener('click',() => { input.value = ''; stage.value = 'all'; sort.value = 'default'; visibleCount = 12; render(); input.focus(); });
  render();
})();
