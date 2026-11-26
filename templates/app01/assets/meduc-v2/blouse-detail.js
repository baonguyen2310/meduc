(() => {
  'use strict';
  const page=document.querySelector('#blouse-detail');
  if(!page)return;
  const cart=window.MeducBookCart;
  cart.bindCards(page);
  const photos=[...page.querySelectorAll('[data-blouse-image]')];
  photos.forEach(button=>button.addEventListener('click',()=>{
    page.querySelector('[data-blouse-photo]').src=button.dataset.blouseImage;
    page.querySelector('[data-blouse-photo-link]').href=button.dataset.blouseFullImage;
    photos.forEach(photo=>photo.setAttribute('aria-pressed',String(photo===button)));
  }));
  const items=JSON.parse(page.dataset.blouseItems);
  const controls=page.querySelector('[data-blouse-controls]');
  if(!items.length||!controls)return;
  const quantity=page.querySelector('#blouse-quantity');
  const buttons=[...page.querySelectorAll('[data-blouse-purchase]')];
  const sizeButtons=[...page.querySelectorAll('[data-blouse-size]')];
  const money=value=>`${Number(value).toLocaleString('vi-VN')}đ`;
  let selected=null;
  controls.hidden=false;
  function normalize(){
    const item=items[selected];
    const value=Math.max(1,Math.min(item?.maximum||1,Math.floor(Number(quantity.value)||1)));
    quantity.value=value;
    page.querySelector('[data-blouse-minus]').disabled=selected===null||value<=1;
    page.querySelector('[data-blouse-plus]').disabled=selected===null||value>=(item?.maximum||0);
    return value;
  }
  sizeButtons.forEach(button=>button.addEventListener('click',()=>{
    const index=Number(button.dataset.blouseSize),item=items[index];
    if(!item?.available)return;
    selected=index;
    sizeButtons.forEach(size=>size.setAttribute('aria-pressed',String(size===button)));
    page.querySelector('[data-blouse-price]').textContent=money(item.current);
    const old=page.querySelector('[data-blouse-old]');old.textContent=money(item.price);old.hidden=!item.discount;
    const discount=page.querySelector('[data-blouse-discount]');discount.textContent=`Giảm ${item.discount}%`;discount.hidden=!item.discount;
    page.querySelector('[data-blouse-stock]').textContent=`Size ${item.label} · Còn ${item.maximum} áo`;
    quantity.disabled=false;quantity.max=item.maximum;
    buttons.forEach(purchase=>purchase.disabled=false);
    normalize();
  }));
  quantity.addEventListener('change',normalize);
  page.querySelector('[data-blouse-minus]').addEventListener('click',()=>{quantity.value=Number(quantity.value)-1;normalize();});
  page.querySelector('[data-blouse-plus]').addEventListener('click',()=>{quantity.value=Number(quantity.value)+1;normalize();});
  buttons.forEach(button=>button.addEventListener('click',()=>{
    if(selected===null||!items[selected].available)return;
    const item=items[selected];
    try{
      cart.add(item.cart,normalize(),item.maximum);
      if(button.dataset.blousePurchase==='buy'){
        if(window.MeducCheckout)window.MeducCheckout.go('/dat-hang',button).catch(()=>{location.href='/dat-hang';});
        else location.href='/dat-hang';
      }else cart.showNotice(page,`Đã thêm “${item.cart.name}” vào giỏ hàng.`);
    }catch(error){cart.showNotice(page,error.message||'Chưa thể thêm áo vào giỏ hàng.',false);}
  }));
  normalize();
})();
