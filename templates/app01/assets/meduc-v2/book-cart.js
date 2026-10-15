/* Shared adapter for the original MedUC book/equipment session cart. No order is submitted here. */
(() => {
  'use strict';
  function add(product, quantity = 1) {
    quantity = Math.floor(Number(quantity));
    if (!product || !Number(product.id) || !Number.isFinite(quantity) || quantity < 1) throw new Error('Invalid book or quantity');
    const saved = sessionStorage.getItem('cart');
    const cart = saved ? JSON.parse(saved) : {cartId:`MEDUC${Math.floor(100000+Math.random()*900000)}`,cartInfo:{},cartProducts:[]};
    if (!cart || !Array.isArray(cart.cartProducts)) throw new Error('Invalid cart');
    const existing = cart.cartProducts.find(item => String(item.id) === String(product.id));
    if (existing) Object.assign(existing,product,{quantity:Math.max(0,Number(existing.quantity) || 0) + quantity});
    else cart.cartProducts.push({...product,quantity});
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
    root.querySelectorAll('[data-book-add]').forEach(button => {
      button.hidden = false;
      button.addEventListener('click',() => {
        try {
          const product = JSON.parse(button.dataset.bookProduct);
          add(product);
          showNotice(root,`Đã thêm “${product.name}” vào giỏ sách.`);
        } catch (_) {
          showNotice(root,'Chưa thể thêm sách vào giỏ. Bạn có thể mở chi tiết sách để tiếp tục chọn mua.',false);
        }
      });
    });
    const close = root.querySelector('[data-book-cart-close]');
    if (close) close.addEventListener('click',() => { root.querySelector('[data-book-cart-notice]').hidden = true; });
  }
  window.MeducBookCart = Object.freeze({add,bindCards,showNotice});
})();
