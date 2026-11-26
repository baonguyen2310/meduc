/* Shared adapter for the original MedUC book/equipment session cart. No order is submitted here. */
(() => {
  'use strict';
  function reference() {
    const values = crypto.getRandomValues(new Uint32Array(2));
    return 'MEDUC' + Array.from(values, number => String(number).padStart(10, '0')).join('');
  }
  // A cart line is one SKU plus the name to embroider, so the same blouse can carry different names.
  function lineKey(item) {
    return String(item?.id) + '\n' + (typeof item?.embroidery === 'string' ? item.embroidery : '');
  }
  function add(product, quantity = 1, maximum = null) {
    quantity = Math.floor(Number(quantity));
    if (!product || !Number(product.id) || !Number.isFinite(quantity) || quantity < 1) throw new Error('Invalid book or quantity');
    const saved = sessionStorage.getItem('cart');
    const cart = saved ? JSON.parse(saved) : {cartId:reference(),cartInfo:{},cartProducts:[]};
    if (!cart || !Array.isArray(cart.cartProducts)) throw new Error('Invalid cart');
    const line = {...product};
    if (!line.embroidery) { delete line.embroidery; line.embroidery_fee = 0; }
    const key = lineKey(line);
    const existing = cart.cartProducts.find(item => item && lineKey(item) === key);
    const sameSku = cart.cartProducts.filter(item => item && String(item.id) === String(line.id))
      .reduce((total, item) => total + Math.max(0, Number(item.quantity) || 0), 0);
    if (maximum !== null && (!Number.isInteger(maximum) || maximum < 1 || sameSku + quantity > maximum)) throw new Error('Mẫu áo đã chọn không đủ số lượng để thêm vào giỏ.');
    if (existing) Object.assign(existing,line,{quantity:Math.max(0,Number(existing.quantity) || 0) + quantity});
    else cart.cartProducts.push({...line,quantity});
    sessionStorage.setItem('cart',JSON.stringify(cart));
    document.querySelectorAll('[nh-mini-cart-book-quantity]').forEach(counter => { counter.textContent = cart.cartProducts.length; });
  }
  function showNotice(root, text, success = true) {
    const notice = root.querySelector('[data-book-cart-notice]');
    if (!notice) return;
    notice.querySelector('[data-book-cart-message]').textContent = text;
    notice.querySelector('a').hidden = !success;
    notice.hidden = false;
  }
  function bindCards(root) {
    const productNoun = root.dataset.productNoun || 'sách';
    const cartLabel = root.dataset.cartLabel || 'giỏ sách';
    root.querySelectorAll('[data-book-add]').forEach(button => {
      button.hidden = false;
      button.addEventListener('click',() => {
        try {
          const product = JSON.parse(button.dataset.bookProduct);
          add(product);
          showNotice(root,`Đã thêm “${product.name}” vào ${cartLabel}.`);
        } catch (_) {
          showNotice(root,`Chưa thể thêm ${productNoun} vào giỏ. Bạn có thể mở chi tiết ${productNoun} để tiếp tục chọn mua.`,false);
        }
      });
    });
    const close = root.querySelector('[data-book-cart-close]');
    if (close) close.addEventListener('click',() => { root.querySelector('[data-book-cart-notice]').hidden = true; });
  }
  window.MeducBookCart = Object.freeze({add,bindCards,showNotice,lineKey});
})();
