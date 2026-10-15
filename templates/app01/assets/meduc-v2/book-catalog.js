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
  const notice = page.querySelector('[data-book-cart-notice]');
  const message = page.querySelector('[data-book-cart-message]');
  const normalize = value => value.toLocaleLowerCase('vi').normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/đ/g,'d');
  const names = new Map(cards.map(card => [card,normalize(card.dataset.bookSearch)]));
  const collator = new Intl.Collator('vi',{sensitivity:'base',numeric:true});
  let visibleCount = 12;
  page.querySelector('[data-book-tools]').hidden = false;
  page.querySelectorAll('[data-book-add]').forEach(button => { button.hidden = false; });
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
  page.querySelector('[data-book-cart-close]').addEventListener('click',() => { notice.hidden = true; });
  page.querySelectorAll('[data-book-add]').forEach(button => button.addEventListener('click',() => {
    try {
      const product = JSON.parse(button.dataset.bookProduct);
      const saved = sessionStorage.getItem('cart');
      const cart = saved ? JSON.parse(saved) : {cartId:`MEDUC${Math.floor(100000+Math.random()*900000)}`,cartInfo:{},cartProducts:[]};
      if (!cart || !Array.isArray(cart.cartProducts)) throw new Error('Invalid cart');
      const existing = cart.cartProducts.find(item => String(item.id) === String(product.id));
      if (existing) {
        // Refresh the current catalogue price while preserving the selected quantity.
        const quantity = Math.max(0,Number(existing.quantity) || 0) + 1;
        Object.assign(existing,product,{quantity});
      } else cart.cartProducts.push(product);
      sessionStorage.setItem('cart',JSON.stringify(cart));
      document.querySelectorAll('[nh-mini-cart-book-quantity]').forEach(counter => { counter.textContent = cart.cartProducts.length; });
      message.textContent = `Đã thêm “${product.name}” vào giỏ sách.`;
      notice.classList.remove('mbc-cart-notice--error');
      notice.querySelector('a').hidden = false;
    } catch (_) {
      message.textContent = 'Chưa thể thêm sách vào giỏ. Bạn có thể mở chi tiết sách để tiếp tục chọn mua.';
      notice.classList.add('mbc-cart-notice--error');
      notice.querySelector('a').hidden = true;
    }
    notice.hidden = false;
  }));
  render();
})();
