(() => {
 'use strict';
 const page=document.querySelector('.mco');
 if(!page)return;
 let confirmation=null, confirmationReturn='/khoa-hoc';
 const paymentCatalogs=new Set(['/khoa-hoc','/khoa-chua-de','/trac-nghiem','/tai-lieu-hoc-tap','/sach-y-khoa']);
 window.MeducPaymentConfirmation={show({orderCode,returnUrl}){
   confirmationReturn=paymentCatalogs.has(returnUrl)?returnUrl:'/khoa-hoc';
   if(!confirmation){
     confirmation=document.createElement('dialog');confirmation.className='mco-payment-confirmation';
     confirmation.setAttribute('aria-labelledby','mco-payment-confirmation-title');
     confirmation.setAttribute('aria-describedby','mco-payment-confirmation-message mco-payment-confirmation-support mco-payment-confirmation-code');
     confirmation.innerHTML='<span class="mco-payment-confirmation-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="m6 12 4 4 8-8"/></svg></span><h2 id="mco-payment-confirmation-title">MedUC đã nhận được thông tin đăng ký của bạn.</h2><p id="mco-payment-confirmation-message">Chúng tôi đang kiểm tra trong giây lát.</p><div class="mco-payment-confirmation-support" id="mco-payment-confirmation-support"><p>Vui lòng liên hệ số điện thoại</p><a class="mco-payment-confirmation-phone" href="tel:0973996822" aria-label="Gọi MedUC: 0973 996 822">0973 996 822</a><p>để được kích hoạt sớm nhất.</p></div><p class="mco-payment-confirmation-code" id="mco-payment-confirmation-code">Mã đơn hàng: <strong data-confirmation-order></strong></p><button type="button" class="mco-button mco-button--primary" autofocus>OK</button>';
     confirmation.querySelector('button').addEventListener('click',()=>location.assign(confirmationReturn));
     confirmation.addEventListener('cancel',event=>event.preventDefault());
     page.append(confirmation);
   }
   confirmation.querySelector('[data-confirmation-order]').textContent=String(orderCode||'—');
   if(!confirmation.open)confirmation.showModal();
 }};
 let toastTimer;
 const announce=message=>{const status=page.querySelector('[data-checkout-status]');if(!status)return;status.textContent=message;clearTimeout(toastTimer);toastTimer=setTimeout(()=>{status.textContent='';},3500);};
 page.querySelectorAll('[data-qr-tab]').forEach(button=>{
   function select(){
     const method=button.dataset.qrTab;
     page.querySelectorAll('[data-qr-tab]').forEach(tab=>{const active=tab===button;tab.setAttribute('aria-selected',String(active));tab.tabIndex=active?0:-1;});
     page.querySelectorAll('[data-qr-panel]').forEach(panel=>{panel.hidden=panel.dataset.qrPanel!==method;});
     page.querySelectorAll('[data-transfer-reference],[data-transfer-help]').forEach(el=>{el.hidden=method==='cod';});
     if(page.hasAttribute('data-book-checkout'))page.dispatchEvent(new CustomEvent('meduc:payment-method',{detail:{method}}));
   }
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
 const orderForm=page.querySelector('[data-order-payment-form]');
 if(orderForm){
   let saving=false,completed=false;
   orderForm.addEventListener('submit',async event=>{
     event.preventDefault();if(saving||completed||!orderForm.reportValidity())return;
     const submit=orderForm.querySelector('[type="submit"]'),error=orderForm.querySelector('[data-order-payment-error]');
     saving=true;submit.disabled=true;error.hidden=true;
     try{
       const response=await fetch('/order/checkout/process',{method:'POST',credentials:'same-origin',body:new FormData(orderForm),
         headers:{'X-CSRF-Token':document.documentElement.getAttribute('csrf-token')||'','X-Requested-With':'XMLHttpRequest'}});
       const result=await response.json();
       if(response.status===401){window.MeducCheckout.login(submit,()=>location.reload());return;}
       if(!response.ok||result.code!=='success')throw new Error(result.message||'Chưa hoàn tất được thanh toán.');
       window.MeducPaymentConfirmation.show({orderCode:result.data.code||orderForm.elements.code.value,returnUrl:orderForm.dataset.paymentReturn});
       completed=true;
     }catch(e){error.textContent=e.message||'Kết nối gián đoạn. Vui lòng thử lại.';error.hidden=false;}
     finally{saving=false;submit.disabled=completed;}
   });
 }else if(page.hasAttribute('data-order-checkout')){
   window.MeducCheckout?.login(page.querySelector('[data-ma-open]'),()=>location.reload());
 }
 if(!page.hasAttribute('data-book-checkout'))return;
 async function initializeBooks(){
 const form=page.querySelector('[data-checkout-form]'),empty=page.querySelector('[data-checkout-empty]'),error=page.querySelector('[data-cart-error]'),list=page.querySelector('[data-cart-products]'),submit=page.querySelector('[data-place-order]');
 const money=value=>new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND',maximumFractionDigits:0}).format(value);
 const catalog=JSON.parse(page.querySelector('[data-checkout-catalog]').textContent);
 let cart, owner=0, voucherReady=true, saleTotal=0, unavailableItems=false;
 const payable=page.querySelector('[data-cart-total]'), charge=page.querySelector('[data-cart-total-input]');
 const voucherHost=page.querySelector('[data-shop-vouchers]');
 const voucherPanel=window.MeducVouchers && voucherHost && window.MeducVouchers.panel(voucherHost,(quote,pending,payload)=>{
   voucherReady=!pending && !!quote;
   submit.disabled=unavailableItems || !voucherReady;
   const displayed=quote?.enabled ? quote.total : saleTotal;
   payable.textContent=money(displayed);
   charge.value=displayed;
   window.MeducVouchers.fields(form,quote ? payload : {});
 });
 function fail(message){error.textContent=message;error.hidden=false;submit.disabled=true;}
 try{cart=JSON.parse(sessionStorage.getItem('cart'));}catch(_){fail('Không thể đọc giỏ hàng. Vui lòng chọn lại sản phẩm từ danh mục.');empty.hidden=false;return;}
 if(!cart||!Array.isArray(cart.cartProducts)||!cart.cartProducts.length){empty.hidden=false;return;}
 cart.cartInfo=cart.cartInfo&&typeof cart.cartInfo==='object'?cart.cartInfo:{};
 if(!/^MEDUC\d{6,24}$/.test(cart.cartId||'')){
   const values=crypto.getRandomValues(new Uint32Array(2));
   cart.cartId='MEDUC'+Array.from(values,number=>String(number).padStart(10,'0')).join('');
 }
 function save(){try{sessionStorage.setItem('cart',JSON.stringify(cart));return true;}catch(_){fail('Trình duyệt không lưu được giỏ hàng. Vui lòng cho phép lưu trữ và tải lại trang.');return false;}}
 const element=(tag,className,text)=>{const node=document.createElement(tag);if(className)node.className=className;if(text!==undefined)node.textContent=text;return node;};
 function url(value){const path=String(value||'');return /^\/?[a-z0-9][a-z0-9_/-]*(?:\.html)?$/i.test(path)?'/'+path.replace(/^\/+/,''):'/sach-y-khoa';}
 function render(){
   const fragments=document.createDocumentFragment();let total=0,subtotal=0,count=0,unavailable=false;
   const ordered={};
   cart.cartProducts=cart.cartProducts.filter(stored=>stored&&typeof stored==='object').map(stored=>{
     const item=catalog[stored.id],embroidery=typeof stored.embroidery==='string'?stored.embroidery:'';
     const stock=item?.maximum===undefined?999:Math.max(0,Math.min(999,Number(item.maximum))),used=ordered[stored.id]||0;
     const maximum=Math.max(0,stock-used),quantity=Math.max(1,Math.min(maximum||1,Math.floor(Number(stored.quantity)||1)));
     ordered[stored.id]=used+quantity;
     if(!item)return {id:stored.id,name:'Sản phẩm không còn được mở bán',quantity,embroidery,unavailable:true};
     const fee=embroidery?Math.max(0,Number(item.embroidery_fee)||0):0;
     const line={...item,quantity,stock,embroidery_fee:fee,unavailable:maximum===0||(!!embroidery&&!fee)};
     if(embroidery)line.embroidery=embroidery;else delete line.embroidery;
     if(embroidery&&!fee)line.notice='Mẫu này không còn nhận thêu tên. Vui lòng xóa và chọn lại.';
     return line;
   });
   // Lines of one SKU share its stock: each line may grow into what the other lines leave.
   for(const line of cart.cartProducts)if(line.stock!==undefined)line.maximum=Math.max(0,line.stock-((ordered[line.id]||0)-line.quantity));
   const keyOf=item=>window.MeducBookCart?.lineKey?window.MeducBookCart.lineKey(item):String(item.id)+'\n'+(item.embroidery||'');
   for(const item of cart.cartProducts){
     const row=element('article','mco-cart-item');row.dataset.itemId=String(item.id);row.dataset.lineKey=keyOf(item);const picture=element('a','mco-cart-picture');picture.href=url(item.url);picture.tabIndex=-1;picture.setAttribute('aria-hidden','true');
     if(item.image){const img=element('img');img.src=String(item.image).startsWith('/')?page.dataset.cdn+item.image:item.image;img.alt='';picture.append(img);}else picture.textContent='MedUC';
     const copy=element('div','mco-cart-copy'),title=element('h3'),link=element('a',null,item.name);link.href=url(item.url);title.append(link);copy.append(title);if(item.embroidery){const note=element('p','mco-item-note');note.append('Thêu tên: ',element('strong',null,`“${item.embroidery}”`),item.embroidery_fee?` · +${money(item.embroidery_fee)}/áo`:'');copy.append(note);}
     const bottom=element('div','mco-item-bottom'),controls=element('div','mco-item-controls'),qty=element('div','mco-quantity');
     const maximum=Math.max(0,Math.min(999,Number(item.maximum??999)));
     const minus=element('button',null,'−'),plus=element('button',null,'+'),input=element('input');minus.type=plus.type='button';minus.setAttribute('aria-label','Giảm số lượng '+item.name);plus.setAttribute('aria-label','Tăng số lượng '+item.name);minus.disabled=item.quantity<=1;plus.disabled=item.quantity>=maximum;
     input.type='number';input.min=1;input.max=maximum||1;input.disabled=!!item.unavailable;input.step=1;input.value=item.quantity;input.setAttribute('aria-label','Số lượng '+item.name);
     function update(quantity,source){item.quantity=Math.max(1,Math.min(maximum||1,Math.floor(Number(quantity)||1)));if(save()){render();const current=[...list.querySelectorAll('.mco-cart-item')].find(row=>row.dataset.lineKey===keyOf(item));if(current){const target=current.querySelector(source);if(target&&!target.disabled)target.focus();}}}
     minus.addEventListener('click',()=>update(item.quantity-1,'.mco-quantity>button:first-child'));plus.addEventListener('click',()=>update(item.quantity+1,'.mco-quantity>button:last-child'));input.addEventListener('change',()=>update(input.value,'.mco-quantity>input'));qty.append(minus,input,plus);
     const remove=element('button','mco-remove','Xóa');remove.type='button';remove.setAttribute('aria-label','Xóa '+item.name);remove.addEventListener('click',()=>{cart.cartProducts=cart.cartProducts.filter(product=>keyOf(product)!==keyOf(item));if(save()){render();announce('Đã xóa sản phẩm khỏi giỏ hàng.');}});controls.append(qty,remove);bottom.append(controls);
     const prices=element('div','mco-item-prices');if(item.unavailable){unavailable=true;prices.append(element('span',null,item.notice||'Vui lòng xóa sản phẩm này.'));}else{const extra=Number(item.embroidery_fee)||0,unit=item.price_special+extra,listed=item.price+extra;total+=unit*item.quantity;subtotal+=listed*item.quantity;count+=item.quantity;prices.append(element('strong',null,money(unit*item.quantity)));if(listed>unit)prices.append(element("del",null,money(listed*item.quantity)));}
     bottom.append(prices);copy.append(bottom);row.append(picture,copy);fragments.append(row);
   }
   list.replaceChildren(fragments);form.hidden=!cart.cartProducts.length||!owner;empty.hidden=cart.cartProducts.length>0;
   page.querySelector('[data-cart-code]').textContent=cart.cartId;page.querySelector('[data-payment-reference]').textContent=cart.cartId;
   page.querySelector('[data-cart-count]').textContent=`(${count})`;page.querySelector('[data-cart-subtotal]').textContent=money(subtotal);page.querySelector('[data-cart-total]').textContent=money(total);page.querySelector('[data-cart-subtotal]').hidden=subtotal<=total;
   page.querySelector('[data-cart-input]').value=JSON.stringify(cart.cartProducts.map(({id,quantity,name,embroidery})=>embroidery?{id,quantity,name,embroidery}:{id,quantity,name}));page.querySelector('[data-cart-id-input]').value=cart.cartId;page.querySelector('[data-cart-total-input]').value=total;
   document.querySelectorAll('[nh-mini-cart-book-quantity]').forEach(counter=>{counter.textContent=cart.cartProducts.length;});
   unavailableItems=unavailable;
   saleTotal=total;
   error.hidden=!unavailable;submit.disabled=unavailable;
   if(unavailable)fail('Có sản phẩm không còn mở bán. Vui lòng xóa sản phẩm đó để tiếp tục.');
   if(voucherPanel && owner && cart.cartProducts.length && !unavailable) {
     voucherPanel.refresh({source:'shop',items:cart.cartProducts.map(({id,quantity,embroidery})=>embroidery?{id,quantity,embroidery}:{id,quantity})});
   }
   save();
 }
 async function authenticate(){
   const data=await window.MeducCheckout.context();
   owner=data.customer_id;
   const gate=page.querySelector('[data-checkout-login]');gate.hidden=!!owner;
   if(!owner){form.hidden=true;window.MeducCheckout.login(gate.querySelector('button'),()=>authenticate().catch(e=>fail(e.message)));return;}
   if(Number(cart.customerId)!==owner)cart.cartInfo={};
   cart.customerId=owner;
   const profile={...data.contact};
   for(const key of ['full_name','phone','address'])if(cart.cartInfo[key])profile[key]=cart.cartInfo[key];
   window.MeducCheckout.fill(form,profile,true);
   form.querySelectorAll('[data-checkout-contact] input').forEach(input=>input.addEventListener('input',()=>{cart.cartInfo[input.name]=input.value;save();}));
   save();render();
 }
 function payment(method){
   const bank=method!=='cod';form.elements.payment.value=bank?'bank':'cod';
   page.querySelector('[data-payment-note]').textContent=bank?'Sau khi chuyển khoản, nhấn hoàn tất để MedUC kiểm tra và xác nhận thanh toán.':'Nhấn hoàn tất để đặt hàng. Bạn thanh toán khi nhận hàng.';
   cart.cartInfo.payment=bank?'bank':'cod';save();
 }
 page.addEventListener('meduc:payment-method',event=>payment(event.detail.method));
 payment('bank');
 let checkingAccount=false, allowSubmit=false;
 submit.addEventListener('click',async event=>{
   if(allowSubmit){allowSubmit=false;return;}
   event.preventDefault();event.stopImmediatePropagation();
   if(checkingAccount||!form.reportValidity()||!owner||submit.disabled||!voucherReady||!cart.cartProducts.length)return;
   checkingAccount=true;
   try{
     const current=await window.MeducCheckout.context();
     if(!current.member){window.MeducCheckout.login(submit,()=>authenticate().catch(e=>fail(e.message)));return;}
     if(current.customer_id!==owner){await authenticate();announce('Tài khoản đã thay đổi. Vui lòng kiểm tra thông tin nhận hàng.');return;}
     if(save() && voucherReady && !submit.disabled){allowSubmit=true;submit.click();}
   }catch(e){fail(e.message);}finally{checkingAccount=false;}
 },true);
 form.addEventListener('submit',event=>event.preventDefault());
 render();await authenticate();
 }
 initializeBooks().catch(error=>{const message=page.querySelector('[data-cart-error]');message.textContent=error.message||'Chưa tải được thông tin thanh toán.';message.hidden=false;});
})();
