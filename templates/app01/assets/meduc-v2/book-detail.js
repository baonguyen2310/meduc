(() => {
  'use strict';
  const page = document.querySelector('#book-detail');
  if (!page) return;
  const cart = window.MeducBookCart;
  cart.bindCards(page);
  const images = [...page.querySelectorAll('[data-book-image]')];
  const mainImage = page.querySelector('[data-book-main-image]');
  const mainZoom = page.querySelector('[data-book-main-zoom]');
  const dialog = page.querySelector('#book-image-dialog');
  const dialogImage = dialog.querySelector('[data-book-dialog-image]');
  const caption = dialog.querySelector('[data-book-dialog-caption]');
  let activeImage = 0;
  let dialogIndex = 0;
  let opener;
  const moveIndex = index => (index + images.length) % images.length;
  function selectImage(index) {
    if (!images.length) return;
    activeImage = moveIndex(index);
    mainImage.src = images[activeImage].dataset.bookDisplayImage;
    mainImage.alt = `Ảnh ${activeImage + 1} của ${page.dataset.bookName}`;
    mainZoom.dataset.bookZoom = activeImage;
    page.querySelector('[data-book-image-count]').textContent = `${String(activeImage+1).padStart(2,'0')} / ${String(images.length).padStart(2,'0')}`;
    images.forEach((button,index) => button.setAttribute('aria-pressed',String(index===activeImage)));
  }
  images.forEach((button,index) => button.addEventListener('click',() => selectImage(index)));
  if (images.length) {
    page.querySelector('[data-book-gallery-controls]').hidden = images.length<2;
    page.querySelector('[data-book-image-prev]').addEventListener('click',() => selectImage(activeImage-1));
    page.querySelector('[data-book-image-next]').addEventListener('click',() => selectImage(activeImage+1));
  }
  function showDialogImage(index) {
    dialogIndex = moveIndex(index);
    dialogImage.src = images[dialogIndex].dataset.bookFullImage;
    dialogImage.alt = `Ảnh ${dialogIndex+1} của ${page.dataset.bookName}`;
    caption.textContent = `${dialogIndex+1} / ${images.length} · ${page.dataset.bookName}`;
  }
  page.querySelectorAll('[data-book-zoom]').forEach(button => button.addEventListener('click',() => {
    if (!images.length) return;
    opener = button;
    showDialogImage(Number(button.dataset.bookZoom));
    dialog.showModal();
    document.body.classList.add('meduc-book-dialog-open');
  }));
  dialog.querySelector('[data-book-dialog-close]').addEventListener('click',() => dialog.close());
  dialog.querySelector('[data-book-dialog-prev]').addEventListener('click',() => showDialogImage(dialogIndex-1));
  dialog.querySelector('[data-book-dialog-next]').addEventListener('click',() => showDialogImage(dialogIndex+1));
  dialog.querySelector('[data-book-dialog-prev]').hidden = images.length<2;
  dialog.querySelector('[data-book-dialog-next]').hidden = images.length<2;
  dialog.addEventListener('click',event => { if (event.target===dialog) dialog.close(); });
  dialog.addEventListener('keydown',event => {
    if (event.key==='ArrowLeft' || event.key==='ArrowRight') { event.preventDefault(); showDialogImage(dialogIndex+(event.key==='ArrowRight'?1:-1)); }
  });
  dialog.addEventListener('close',() => { document.body.classList.remove('meduc-book-dialog-open'); if (opener) opener.focus(); });

  const tabs = [...page.querySelectorAll('[data-book-tab]')];
  const panels = [...page.querySelectorAll('[data-book-panel]')];
  function selectTab(code) {
    for (const tab of tabs) { const active=tab.dataset.bookTab===code; tab.setAttribute('aria-selected',String(active)); tab.tabIndex=active?0:-1; }
    for (const panel of panels) { panel.hidden=panel.dataset.bookPanel!==code; if (panel.hidden) panel.querySelectorAll('video').forEach(video=>video.pause()); }
  }
  if (tabs.length) {
    page.querySelector('[data-book-tabs]').hidden=false;
    panels.forEach(panel=>{ panel.setAttribute('role','tabpanel'); panel.setAttribute('aria-labelledby',`book-tab-${panel.dataset.bookPanel}`); panel.tabIndex=0; });
    tabs.forEach((tab,index)=>{
      tab.addEventListener('click',()=>selectTab(tab.dataset.bookTab));
      tab.addEventListener('keydown',event=>{
        let next;
        if (event.key==='ArrowRight') next=(index+1)%tabs.length;
        else if (event.key==='ArrowLeft') next=(index-1+tabs.length)%tabs.length;
        else if (event.key==='Home') next=0;
        else if (event.key==='End') next=tabs.length-1;
        if (next===undefined) return;
        event.preventDefault(); selectTab(tabs[next].dataset.bookTab); tabs[next].focus();
      });
    });
    selectTab(tabs[0].dataset.bookTab);
  }

  const items=JSON.parse(page.dataset.bookItems);
  const controls=page.querySelector('[data-book-order-controls]');
  const edition=page.querySelector('#book-edition');
  const quantity=page.querySelector('#book-quantity');
  const money=value=>`${Number(value).toLocaleString('vi-VN')}đ`;
  let selected=0;
  function normalizeQuantity() {
    const item=items[selected];
    let value=Math.max(1,Math.floor(Number(quantity.value)||1));
    if (item.maximum!==null && item.maximum>0) value=Math.min(value,item.maximum);
    quantity.value=value;
    return value;
  }
  function selectItem(index) {
    selected=index;
    const item=items[selected];
    page.querySelector('[data-book-current-price]').textContent=item.current>0?money(item.current):'Liên hệ tư vấn';
    const old=page.querySelector('[data-book-old-price]'); old.textContent=money(item.price); old.hidden=!item.discount;
    const discount=page.querySelector('[data-book-discount]'); discount.textContent=`Giảm ${item.discount}%`; discount.hidden=!item.discount;
    const stock=page.querySelector('[data-book-stock]'); stock.textContent=item.maximum===0?'Ấn bản này tạm hết hàng.':''; stock.hidden=item.maximum!==0;
    page.querySelectorAll('[data-book-purchase]').forEach(button=>{ button.disabled=!item.available; });
    if (item.maximum!==null && item.maximum>0) quantity.max=item.maximum; else quantity.removeAttribute('max');
    normalizeQuantity();
  }
  if (items.length && controls) {
    controls.hidden=false;
    selectItem(0);
    if (edition) edition.addEventListener('change',()=>selectItem(Number(edition.value)));
    quantity.addEventListener('change',normalizeQuantity);
    page.querySelector('[data-book-quantity-minus]').addEventListener('click',()=>{ quantity.value=Number(quantity.value)-1; normalizeQuantity(); });
    page.querySelector('[data-book-quantity-plus]').addEventListener('click',()=>{ quantity.value=Number(quantity.value)+1; normalizeQuantity(); });
    page.querySelectorAll('[data-book-purchase]').forEach(button=>button.addEventListener('click',()=>{
      const item=items[selected];
      if (!item.available) return;
      try {
        cart.add(item.cart,normalizeQuantity());
        if (button.dataset.bookPurchase==='buy') { window.location.href='/dat-hang'; return; }
        cart.showNotice(page,`Đã thêm “${item.cart.name}” vào giỏ sách.`);
      } catch (_) { cart.showNotice(page,'Chưa thể thêm sách vào giỏ. Vui lòng thử lại hoặc liên hệ MedUC để được hỗ trợ.',false); }
    }));
  }
})();
