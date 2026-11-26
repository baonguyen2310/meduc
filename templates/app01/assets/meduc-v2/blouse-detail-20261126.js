(() => {
  'use strict';
  const page=document.querySelector('#blouse-detail');
  if(!page)return;
  const cart=window.MeducBookCart;
  cart.bindCards(page);
  const data=JSON.parse(page.dataset.blouse||'{}');
  const items=Array.isArray(data.items)?data.items:[];
  const attributes=Array.isArray(data.attributes)?data.attributes:[];
  const fee=Number(data.embroidery_fee)||0;
  const money=value=>`${Number(value).toLocaleString('vi-VN')}đ`;

  /* Gallery: show the photos of the chosen model and colour, falling back to every photo. */
  const stage=page.querySelector('[data-blouse-photo]'),stageLink=page.querySelector('[data-blouse-photo-link]'),thumbs=page.querySelector('[data-blouse-thumbnails]');
  let galleryKey='';
  function showPhoto(image){
    if(!stage||!image)return;
    stage.src=image.large;stageLink.href=image.full;
    thumbs?.querySelectorAll('button').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.blouseFullImage===image.full)));
  }
  function setGallery(images){
    if(!stage||!thumbs||!images.length)return;
    const key=images.map(image=>image.full).join('\n');
    if(key===galleryKey)return;
    galleryKey=key;
    thumbs.replaceChildren(...images.map((image,index)=>{
      const button=document.createElement('button'),img=document.createElement('img');
      button.type='button';button.dataset.blouseImage=image.large;button.dataset.blouseFullImage=image.full;
      button.setAttribute('aria-label',`Xem ảnh ${index+1}`);button.setAttribute('aria-pressed','false');
      img.src=image.small;img.alt='';img.loading='lazy';button.append(img);
      button.addEventListener('click',()=>showPhoto(image));
      return button;
    }));
    thumbs.hidden=images.length<2;
    showPhoto(images[0]);
  }

  const controls=page.querySelector('[data-blouse-controls]');
  if(!items.length||!controls||!attributes.length)return;
  const quantity=page.querySelector('#blouse-quantity');
  const purchases=[...page.querySelectorAll('[data-blouse-purchase]')];
  const embroidery=page.querySelector('[data-blouse-embroidery]');
  const embroideryError=page.querySelector('[data-blouse-embroidery-error]');
  const groups=attributes.map(attribute=>({
    ...attribute,id:String(attribute.id),
    root:page.querySelector(`[data-blouse-attribute="${attribute.id}"]`),
  }));
  const selected={};
  groups.forEach(group=>{selected[group.id]=null;});
  controls.hidden=false;

  const matches=(item,choice)=>Object.entries(choice).every(([id,option])=>option===null||Number(item.values[id])===Number(option));
  // Each choice only depends on the choices above it (Kiểu dáng → Màu → Size); settle() fixes the ones below.
  function scope(group){
    const choice={};
    for(const other of groups){if(other.id===group.id)break;choice[other.id]=selected[other.id];}
    return choice;
  }
  function optionState(group,option){
    const list=items.filter(item=>matches(item,{...scope(group),[group.id]:option}));
    if(list.some(item=>item.available))return {enabled:true,note:''};
    if(!list.length)return {enabled:false,note:'Không có'};
    return {enabled:false,note:list.some(item=>item.current>0)?'Hết hàng':'Chưa có giá'};
  }
  function current(){
    if(groups.some(group=>selected[group.id]===null))return null;
    return items.find(item=>matches(item,selected))||null;
  }
  function settle(changed){
    // Keep earlier choices; move later ones to an option that still has stock.
    for(const group of groups){
      if(group.id===changed||selected[group.id]===null)continue;
      if(!optionState(group,selected[group.id]).enabled){
        const next=group.kind==='size'?null:group.options.find(option=>optionState(group,option.id).enabled);
        selected[group.id]=next?next.id:(group.kind==='size'?null:selected[group.id]);
      }
    }
  }
  function embroideryText(){
    if(!embroidery)return {text:'',valid:true};
    const text=embroidery.value.replace(/\s+/g,' ').trim().normalize('NFC');
    let message='';
    if([...text].length>(Number(data.embroidery_max)||30))message=`Tên thêu tối đa ${data.embroidery_max} ký tự.`;
    else if(text&&!/^[\p{L}\p{M}\p{N} .,'-]+$/u.test(text))message='Tên thêu chỉ gồm chữ, số, dấu cách và các dấu . , \' -';
    embroideryError.textContent=message;embroideryError.hidden=!message;
    embroidery.setAttribute('aria-invalid',String(!!message));
    return {text,valid:!message};
  }
  function normalize(){
    const item=current();
    const value=Math.max(1,Math.min(item?.maximum||1,Math.floor(Number(quantity.value)||1)));
    quantity.value=value;
    page.querySelector('[data-blouse-minus]').disabled=!item||value<=1;
    page.querySelector('[data-blouse-plus]').disabled=!item||value>=(item?.maximum||0);
    return value;
  }
  function render(){
    for(const group of groups){
      if(!group.root)continue;
      group.root.querySelectorAll('[data-blouse-option]').forEach(button=>{
        const option=Number(button.dataset.blouseOption),state=optionState(group,option);
        button.disabled=!state.enabled;
        button.setAttribute('aria-pressed',String(Number(selected[group.id])===option));
        const note=button.querySelector('[data-blouse-note]');
        if(note)note.textContent=group.kind==='size'&&!state.enabled?state.note:'';
        if(button.classList.contains('mbl-swatch'))button.title=state.enabled?button.getAttribute('aria-label'):`${button.getAttribute('aria-label')} · ${state.note}`;
      });
      const chosen=group.root.querySelector('[data-blouse-chosen]');
      if(chosen)chosen.textContent=group.options.find(option=>Number(option.id)===Number(selected[group.id]))?.name||'';
    }
    const item=current(),words=embroideryText();
    const look={};groups.forEach(group=>{if(group.kind!=='size')look[group.id]=selected[group.id];});
    const lookItems=items.filter(entry=>matches(entry,look));
    setGallery(lookItems.find(entry=>entry.images?.length)?.images||data.gallery||[]);
    const price=page.querySelector('[data-blouse-price]'),old=page.querySelector('[data-blouse-old]'),discount=page.querySelector('[data-blouse-discount]'),extra=page.querySelector('[data-blouse-extra]'),stock=page.querySelector('[data-blouse-stock]');
    if(item){
      price.textContent=money(item.current);
      old.textContent=money(item.price);old.hidden=!item.discount;
      discount.textContent=`Giảm ${item.discount}%`;discount.hidden=!item.discount;
    }else{
      const prices=lookItems.filter(entry=>entry.available).map(entry=>entry.current);
      const low=Math.min(...prices),high=Math.max(...prices);
      price.textContent=prices.length?(low===high?money(low):`Từ ${money(low)}`):(items.some(entry=>entry.current>0)?'Tạm hết hàng':'Giá đang cập nhật');
      old.hidden=discount.hidden=true;
    }
    extra.hidden=!(fee>0&&words.text&&words.valid);
    extra.textContent=`+ ${money(fee)} thêu tên mỗi áo`;
    const size=groups.find(group=>group.kind==='size');
    if(item?.available)stock.textContent=`${item.label} · Còn ${item.maximum} áo`;
    else if(!lookItems.some(entry=>entry.available))stock.textContent='Mẫu và màu này đang hết hàng hoặc chưa có giá.';
    else stock.textContent=size&&selected[size.id]===null?'Chọn size để đặt mua.':'Chọn đủ mẫu và size trước khi đặt mua.';
    quantity.disabled=!item?.available;
    if(item)quantity.max=item.maximum;
    purchases.forEach(button=>{button.disabled=!item?.available||!words.valid;});
    normalize();
  }

  for(const group of groups){
    group.root?.querySelectorAll('[data-blouse-option]').forEach(button=>button.addEventListener('click',()=>{
      const option=Number(button.dataset.blouseOption);
      if(!optionState(group,option).enabled)return;
      selected[group.id]=option;
      settle(group.id);
      render();
    }));
  }
  // Start from the first look that can be bought; the buyer still picks a size.
  for(const group of groups){
    if(group.kind==='size'&&group.options.length>1)continue;
    const first=group.options.find(option=>optionState(group,option.id).enabled)||group.options[0];
    selected[group.id]=first?Number(first.id):null;
  }
  thumbs?.querySelectorAll('button').forEach(button=>button.addEventListener('click',()=>showPhoto({large:button.dataset.blouseImage,full:button.dataset.blouseFullImage})));
  page.querySelector('[data-blouse-size-guide]')?.addEventListener('click',()=>{const guide=document.querySelector('#blouse-size-guide');if(guide)guide.open=true;});
  embroidery?.addEventListener('input',render);
  quantity.addEventListener('change',normalize);
  page.querySelector('[data-blouse-minus]').addEventListener('click',()=>{quantity.value=Number(quantity.value)-1;normalize();});
  page.querySelector('[data-blouse-plus]').addEventListener('click',()=>{quantity.value=Number(quantity.value)+1;normalize();});
  purchases.forEach(button=>button.addEventListener('click',()=>{
    const item=current(),words=embroideryText();
    if(!item?.available||!words.valid)return;
    const line={...item.cart};
    if(words.text&&fee>0){line.embroidery=words.text;line.embroidery_fee=fee;}
    try{
      cart.add(line,normalize(),item.maximum);
      if(button.dataset.blousePurchase==='buy'){
        if(window.MeducCheckout)window.MeducCheckout.go('/dat-hang',button).catch(()=>{location.href='/dat-hang';});
        else location.href='/dat-hang';
      }else cart.showNotice(page,`Đã thêm “${item.cart.name}”${line.embroidery?` · thêu “${line.embroidery}”`:''} vào giỏ hàng.`);
    }catch(error){cart.showNotice(page,error.message||'Chưa thể thêm áo vào giỏ hàng.',false);}
  }));
  render();
})();
