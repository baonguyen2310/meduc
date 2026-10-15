(() => {
 'use strict';
 const page=document.querySelector('.mco');
 if(!page)return;
 let toastTimer;
 const announce=message=>{const status=page.querySelector('[data-checkout-status]');if(!status)return;status.textContent=message;clearTimeout(toastTimer);toastTimer=setTimeout(()=>{status.textContent='';},3500);};
 page.querySelectorAll('[data-qr-tab]').forEach(button=>{
   function select(){page.querySelectorAll('[data-qr-tab]').forEach(tab=>{const active=tab===button;tab.setAttribute('aria-selected',String(active));tab.tabIndex=active?0:-1;});page.querySelectorAll('[data-qr-panel]').forEach(panel=>{panel.hidden=panel.dataset.qrPanel!==button.dataset.qrTab;});}
   button.addEventListener('click',select);
   button.addEventListener('keydown',event=>{if(!['ArrowLeft','ArrowRight','Home','End'].includes(event.key))return;event.preventDefault();const tabs=[...page.querySelectorAll('[data-qr-tab]')],index=tabs.indexOf(button),next=event.key==='Home'?0:event.key==='End'?tabs.length-1:(index+(event.key==='ArrowRight'?1:-1)+tabs.length)%tabs.length;tabs[next].click();tabs[next].focus();});
 });
 page.querySelectorAll('[data-copy],[data-copy-reference]').forEach(button=>button.addEventListener('click',async()=>{
   const text=button.hasAttribute('data-copy-reference')?page.querySelector('[data-payment-reference]').textContent.trim():button.dataset.copy;
   try{await navigator.clipboard.writeText(text);announce('Đã sao chép.');}catch(_){announce('Không thể sao chép tự động. Bạn có thể chọn và sao chép nội dung bên cạnh.');}
 }));
 page.querySelectorAll('[nh-gateway-item]').forEach(button=>button.addEventListener('click',event=>{
   event.preventDefault();page.querySelectorAll('[nh-gateway-item]').forEach(item=>item.classList.toggle('active',item===button));page.querySelectorAll('[data-gateway-panel]').forEach(panel=>panel.classList.toggle('active',panel.dataset.gatewayPanel===button.getAttribute('nh-gateway-item')));
 }));
 if(!page.hasAttribute('data-book-checkout'))return;
 const form=page.querySelector('[data-checkout-form]'),empty=page.querySelector('[data-checkout-empty]'),error=page.querySelector('[data-cart-error]'),list=page.querySelector('[data-cart-products]'),submit=page.querySelector('[data-place-order]');
 const money=value=>new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND',maximumFractionDigits:0}).format(value);
 const catalog=JSON.parse(page.querySelector('[data-checkout-catalog]').textContent);
 let cart;
 function fail(message){error.textContent=message;error.hidden=false;submit.disabled=true;}
 try{cart=JSON.parse(sessionStorage.getItem('cart'));}catch(_){fail('Không thể đọc giỏ hàng. Vui lòng chọn lại sản phẩm từ danh sách sách.');empty.hidden=false;return;}
 if(!cart||!Array.isArray(cart.cartProducts)||!cart.cartProducts.length){empty.hidden=false;return;}
 cart.cartInfo=cart.cartInfo&&typeof cart.cartInfo==='object'?cart.cartInfo:{};
 if(!/^MEDUC\d{6,}$/.test(cart.cartId||''))cart.cartId=`MEDUC${Math.floor(100000+Math.random()*900000)}`;
 function save(){try{sessionStorage.setItem('cart',JSON.stringify(cart));return true;}catch(_){fail('Trình duyệt không lưu được giỏ hàng. Vui lòng cho phép lưu trữ và tải lại trang.');return false;}}
 const element=(tag,className,text)=>{const node=document.createElement(tag);if(className)node.className=className;if(text!==undefined)node.textContent=text;return node;};
 function url(value){const path=String(value||'');return /^\/?[a-z0-9][a-z0-9_/-]*(?:\.html)?$/i.test(path)?'/'+path.replace(/^\/+/,''):'/sach-y-khoa';}
 function render(){
   const fragments=document.createDocumentFragment();let total=0,subtotal=0,count=0,unavailable=false;
   cart.cartProducts=cart.cartProducts.filter(stored=>stored&&typeof stored==='object').map(stored=>{const item=catalog[stored.id],quantity=Math.max(1,Math.min(999,Math.floor(Number(stored.quantity)||1)));return item?{...item,quantity}:{id:stored.id,name:'Sản phẩm không còn được mở bán',quantity,unavailable:true};});
   for(const item of cart.cartProducts){
     const row=element('article','mco-cart-item');row.dataset.itemId=String(item.id);const picture=element('a','mco-cart-picture');picture.href=url(item.url);picture.tabIndex=-1;picture.setAttribute('aria-hidden','true');
     if(item.image){const img=element('img');img.src=String(item.image).startsWith('/')?page.dataset.cdn+item.image:item.image;img.alt='';picture.append(img);}else picture.textContent='MedUC';
     const copy=element('div','mco-cart-copy'),title=element('h3'),link=element('a',null,item.name);link.href=url(item.url);title.append(link);copy.append(title);
     const bottom=element('div','mco-item-bottom'),controls=element('div','mco-item-controls'),qty=element('div','mco-quantity');
     const minus=element('button',null,'−'),plus=element('button',null,'+'),input=element('input');minus.type=plus.type='button';minus.setAttribute('aria-label','Giảm số lượng '+item.name);plus.setAttribute('aria-label','Tăng số lượng '+item.name);minus.disabled=item.quantity<=1;plus.disabled=item.quantity>=999;
     input.type='number';input.min=1;input.max=999;input.step=1;input.value=item.quantity;input.setAttribute('aria-label','Số lượng '+item.name);
     function update(quantity,source){item.quantity=Math.max(1,Math.min(999,Math.floor(Number(quantity)||1)));if(save()){render();const current=[...list.querySelectorAll('.mco-cart-item')].find(row=>row.dataset.itemId===String(item.id));if(current){const target=current.querySelector(source);if(target&&!target.disabled)target.focus();}}}
     minus.addEventListener('click',()=>update(item.quantity-1,'.mco-quantity>button:first-child'));plus.addEventListener('click',()=>update(item.quantity+1,'.mco-quantity>button:last-child'));input.addEventListener('change',()=>update(input.value,'.mco-quantity>input'));qty.append(minus,input,plus);
     const remove=element('button','mco-remove','Xóa');remove.type='button';remove.setAttribute('aria-label','Xóa '+item.name);remove.addEventListener('click',()=>{cart.cartProducts=cart.cartProducts.filter(product=>String(product.id)!==String(item.id));if(save()){render();announce('Đã xóa sản phẩm khỏi giỏ hàng.');}});controls.append(qty,remove);bottom.append(controls);
     const prices=element('div','mco-item-prices');if(item.unavailable){unavailable=true;prices.append(element('span',null,'Vui lòng xóa sản phẩm này.'));}else{total+=item.price_special*item.quantity;subtotal+=item.price*item.quantity;count+=item.quantity;prices.append(element('strong',null,money(item.price_special*item.quantity)));if(item.price>item.price_special)prices.append(element('del',null,money(item.price*item.quantity)));}
     bottom.append(prices);copy.append(bottom);row.append(picture,copy);fragments.append(row);
   }
   list.replaceChildren(fragments);form.hidden=!cart.cartProducts.length;empty.hidden=cart.cartProducts.length>0;
   page.querySelector('[data-cart-code]').textContent=cart.cartId;page.querySelector('[data-payment-reference]').textContent=cart.cartId;
   page.querySelector('[data-cart-count]').textContent=`(${count})`;page.querySelector('[data-cart-subtotal]').textContent=money(subtotal);page.querySelector('[data-cart-total]').textContent=money(total);page.querySelector('[data-payment-amount]').textContent=money(total);page.querySelector('[data-cart-discount]').textContent='−'+money(subtotal-total);page.querySelector('[data-cart-discount-row]').hidden=subtotal<=total;
   page.querySelector('[data-cart-input]').value=JSON.stringify(cart.cartProducts.map(({id,quantity,name})=>({id,quantity,name})));page.querySelector('[data-cart-id-input]').value=cart.cartId;page.querySelector('[data-cart-total-input]').value=total;
   document.querySelectorAll('[nh-mini-cart-book-quantity]').forEach(counter=>{counter.textContent=cart.cartProducts.length;});
   error.hidden=!unavailable;submit.disabled=unavailable;if(unavailable)fail('Có sản phẩm không còn mở bán. Vui lòng xóa sản phẩm đó để tiếp tục.');save();
 }
 const keys={full_name:'fullName',phone:'phone',email:'email',address:'address',note:'note'};
 Object.entries(keys).forEach(([name,key])=>{const field=form.elements[name];field.value=cart.cartInfo[key]||'';field.addEventListener('input',()=>{cart.cartInfo[key]=field.value;save();});});
 function payment(){const bank=form.elements.payment.value==='bank';page.querySelector('[data-transfer-panel]').hidden=!bank;page.querySelector('[data-payment-note]').textContent=bank?'Chỉ nhấn “Đặt hàng” sau khi đã chuyển khoản. MedUC sẽ kiểm tra và xác nhận thanh toán.':'Bạn thanh toán cho đơn vị giao hàng khi nhận sản phẩm. MedUC sẽ liên hệ xác nhận đơn hàng.';cart.cartInfo.payment=bank?'bank':'cod';save();}
 if(cart.cartInfo.payment==='cod')form.querySelector('[value="cod"]').checked=true;
 form.querySelectorAll('[name="payment"]').forEach(radio=>radio.addEventListener('change',payment));
 submit.addEventListener('click',event=>{if(submit.disabled||!cart.cartProducts.length){event.preventDefault();event.stopImmediatePropagation();return;}if(!save()){event.preventDefault();event.stopImmediatePropagation();}},true);
 form.addEventListener('submit',event=>event.preventDefault());
 render();payment();
})();
