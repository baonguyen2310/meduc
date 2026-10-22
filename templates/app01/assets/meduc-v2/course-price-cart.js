(() => {
  'use strict';
  const key = 'meduc-course-selection-v2';
  let memory = {lists:{}, packages:{}, active:null};
  const unique = ids => [...new Set(ids.map(String).filter(id => /^[1-9][0-9]*$/.test(id)))];
  function read() {
    try {
      const raw = localStorage.getItem(key);
      if (raw === null) {
        const legacy = JSON.parse(localStorage.getItem('meduc-course-package-cart-v1'));
        memory = {lists:{},packages:{},active:legacy?.active || null};
        // Combine the old package selections without silently dropping any subject.
        for (const [plan,ids] of Object.entries(legacy?.plans || {})) {
          const list = plan.split(':')[0];
          if (!/^[1-9][0-9]*$/.test(list) || !Array.isArray(ids)) continue;
          memory.lists[list] = unique([...(memory.lists[list] || []), ...ids]);
        }
        localStorage.setItem(key,JSON.stringify(memory));
      } else {
        const value = JSON.parse(raw);
        memory = value && value.lists && typeof value.lists === 'object' ? value : {lists:{},packages:{},active:null};
      }
    } catch (_) { /* Keep selections in this page when browser storage is unavailable. */ }
    if (!memory.packages || typeof memory.packages !== 'object') memory.packages={};
    return memory;
  }
  function save(value) {
    memory = value;
    try { localStorage.setItem(key, JSON.stringify(value)); } catch (_) {}
    window.dispatchEvent(new CustomEvent('meduc:course-cart'));
  }
  const api = window.MeducCourseCart = {
    key,
    get(list) {
      const ids = read().lists[String(list)];
      return Array.isArray(ids) ? unique(ids) : null;
    },
    set(list, ids) {
      const value = read(); value.lists[String(list)] = unique(ids); save(value);
    },
    activate(list, pack) { const value = read(); value.active = {list:Number(list),pack:Number(pack)};value.packages[String(list)]=Number(pack); save(value); },
    packageId(list) {const value=read();return Number(value.packages[String(list)] || (value.active?.list===Number(list) ? value.active.pack : 0));},
    choosePackage(list,pack) {const value=read();value.packages[String(list)]=Number(pack);save(value);},
    active() { return read().active; },
    stop() { const value = read(); value.active = null; save(value); },
    configure(config) { setup(config);setupCart(config); }
  };
  window.addEventListener('storage', event => { if (event.key === key) window.dispatchEvent(new CustomEvent('meduc:course-cart')); });

  function setup(config) {
    const params = new URLSearchParams(location.search);
    const boardId = Number(params.get('bang_gia')), packageId = Number(params.get('goi'));
    const requested = config.boards.find(b => b.id === boardId && b.packages.some(p => p.id === packageId));
    if (requested) api.activate(boardId, packageId);
    let board = null, pack = null, banner = null, alert = null, counter = null, detailButton = null;
    const controls = [];
    const catalog = document.querySelector('#course-catalog');
    const detail = document.querySelector('[data-mcr-product]');
    const detailId = detail?.getAttribute('data-mcr-product');
    function selection() { return (api.get(board.id) || []).filter(id => board.courses.includes(Number(id))); }
    function toggle(id) {
      if (!board || !board.courses.includes(Number(id))) return;
      const ids = selection(), index = ids.indexOf(String(id));
      if (index >= 0) ids.splice(index,1);
      else if (ids.length < pack.count) ids.push(String(id));
      else { alert.textContent = `Gói đã đủ ${pack.count} môn. Bỏ chọn một môn để đổi.`; return; }
      alert.textContent = ''; api.set(board.id,ids);
    }
    function update() {
      const active = api.active();
      if (!active || !board || active.list !== board.id || active.pack !== pack.id) {
        if (banner) {const url=new URL(location.href);url.searchParams.delete('bang_gia');url.searchParams.delete('goi');history.replaceState(null,'',url.pathname+url.search+url.hash);location.reload();}
        return;
      }
      const ids = selection();
      counter.textContent = ids.length > pack.count ? `Đã chọn ${ids.length} môn · ${pack.name}` : `Đã chọn ${ids.length}/${pack.count} môn`;
      if (ids.length > pack.count) alert.textContent = `Gói này gồm ${pack.count} môn. Bỏ bớt ${ids.length-pack.count} môn hoặc chọn gói lớn hơn.`;
      for (const {button,id} of controls) {
        const selected = ids.includes(id);
        button.classList.toggle('is-selected',selected);button.setAttribute('aria-pressed',String(selected));
        button.textContent = selected ? '✓ Đã chọn · Bỏ chọn' : 'Chọn vào gói +';
      }
      if (detailButton) {
        const selected = ids.includes(String(detailId));
        detailButton.textContent = selected ? '✓ Đã chọn · Bỏ chọn' : 'Chọn môn này +';
        detailButton.setAttribute('aria-pressed',String(selected));
      }
    }
    const active = api.active();
    board = active && config.boards.find(b => b.id === active.list);
    pack = board && board.packages.find(p => p.id === active.pack);
    const matchingCatalog = catalog && (board?.kind === 'exam_prep' ? !!catalog.querySelector('[data-catalog-noun="môn luyện thi"]') : !catalog.querySelector('[data-catalog-noun="môn luyện thi"]'));
    if (pack && (matchingCatalog || (detailId && board.courses.includes(Number(detailId))))) {
      banner = document.createElement('aside');banner.className = 'mpc-bar';banner.setAttribute('aria-label','Các môn trong gói đang chọn');
      const copy = document.createElement('div'), name = document.createElement('span');name.textContent = `${board.name} · ${pack.name}`;
      counter = document.createElement('strong');copy.append(name,counter);
      alert = document.createElement('p');alert.className = 'mpc-error';alert.setAttribute('role','status');copy.append(alert);
      const actions = document.createElement('div');actions.className = 'mpc-actions';
      if (detailId) { detailButton=document.createElement('button');detailButton.type='button';detailButton.className='mpc-select';detailButton.addEventListener('click',()=>toggle(detailId));actions.append(detailButton); }
      const back=document.createElement('a');back.href=`/bang-bao-gia/${board.slug}?goi=${pack.id}`;back.textContent='Về bảng giá →';back.className='mpc-back';actions.append(back);
      const close=document.createElement('button');close.type='button';close.className='mpc-close';close.textContent='×';close.setAttribute('aria-label','Thoát chọn gói, giữ các môn đã chọn');close.addEventListener('click',()=>{const url=new URL(location.href);url.searchParams.delete('bang_gia');url.searchParams.delete('goi');history.replaceState(null,'',url.pathname+url.search+url.hash);api.stop();});actions.append(close);
      banner.append(copy,actions);document.body.append(banner);document.body.classList.add('mpc-has-cart');
      if (matchingCatalog) catalog.querySelectorAll('[data-course-card]').forEach(card => {
        const id=card.dataset.courseId;
        if (!board.courses.includes(Number(id))) return;
        const old=card.querySelector('.mcl-register');if(!old)return;
        const button=document.createElement('button');button.type='button';button.className='mcl-register mpc-catalog-select';button.addEventListener('click',()=>toggle(id));old.replaceWith(button);controls.push({button,id});
      });
      window.addEventListener('meduc:course-cart',update);update();
    }
    document.addEventListener('click', event => {
      const link=event.target.closest('a[nh-btn-action="add-cart"],a.mcl-register,a.mcr-btn[href="/order/info"]');
      if (!link) return;
      const id=link.closest('[nh-product]')?.getAttribute('nh-product') || document.querySelector('[data-mcr-product]')?.getAttribute('data-mcr-product');
      if (!config.links[id]) return;
      event.preventDefault();event.stopImmediatePropagation();
      if (banner && board.courses.includes(Number(id))) toggle(id);
      else location.href=config.links[id];
    },true);
  }
  function setupCart(config) {
    const triggers=[...document.querySelectorAll('[data-course-cart-open]')];
    if (!triggers.length) return;
    let boards=config.boards, context=null, pending=null, confirmation=null, busy=false, view='cart';
    let legacyUnknown=Number(triggers[0].dataset.courseCartLegacy || 0), previousOverflow='', opener=null;
    const money=value=>new Intl.NumberFormat('vi-VN').format(value)+'đ';
    const node=(tag,cls,text)=>{const el=document.createElement(tag);if(cls)el.className=cls;if(text!==undefined)el.textContent=text;return el;};
    const path=course=>{const u=new URL(course.url || '/',location.origin+'/');return u.pathname+u.search;};
    const idsFor=board=>(api.get(board.id)||[]).filter(id=>board.courses.includes(Number(id)));
    const packageFor=(board,ids)=>board.packages.find(p=>p.id===api.packageId(board.id)) || board.packages.find(p=>p.count===ids.length) || board.packages[0];
    const catalogPath=(board,pack)=>(board.kind==='exam_prep'?'/khoa-luyen-thi':'/khoa-hoc')+`?bang_gia=${board.id}&goi=${pack.id}`;
    const link=(href,text,cls)=>{const a=node('a',cls,text);a.href=href;return a;};
    const button=(text,cls,action)=>{const b=node('button',cls,text);b.type='button';if(action)b.addEventListener('click',action);return b;};
    function priceDisplay(pack,priceClass='mpc-group-price') {
      const discounted=Number(pack.price)>Number(pack.amount);
      const prices=node('div','mpc-price-stack'+(priceClass==='mpc-confirm-price'?' mpc-confirm-prices':''));
      if(discounted){const original=node('del','mpc-price-original',money(pack.price));original.setAttribute('aria-label',`Giá gốc ${money(pack.price)}`);prices.append(original);}
      const current=node('strong',priceClass+(discounted?' is-discounted':''),money(pack.amount));
      current.setAttribute('aria-label',`${discounted?'Giá ưu đãi':'Giá gốc'} ${money(pack.amount)}`);prices.append(current);return prices;
    }
    const dialog=node('dialog','mpc-dialog');dialog.id='meduc-course-cart';dialog.setAttribute('aria-labelledby','mpc-cart-title');
    const head=node('header','mpc-dialog-head'), heading=node('div');heading.append(node('p','mpc-eyebrow','MEDUC / GIỎ KHÓA HỌC'));
    const title=node('h2','', 'Các môn bạn đã chọn.');title.id='mpc-cart-title';heading.append(title);
    const close=button('×','mpc-dialog-close',()=>closeDialog());close.setAttribute('aria-label','Đóng giỏ khóa học');head.append(heading,close);
    const body=node('div','mpc-dialog-body'), foot=node('footer','mpc-dialog-foot','Mỗi bảng giá được thanh toán thành một đơn riêng.');
    dialog.append(head,body,foot);document.body.append(dialog);
    triggers.forEach(t=>{t.setAttribute('aria-controls',dialog.id);t.addEventListener('click',event=>{event.preventDefault();event.stopImmediatePropagation();openCart(t);},true);});
    function updateBadge() {
      const count=boards.reduce((sum,b)=>sum+idsFor(b).length,0)+legacyUnknown;
      document.querySelectorAll('[data-course-cart-count]').forEach(b=>{b.textContent=String(count);});
    }
    function ensureOpen(trigger) {
      if(dialog.open)return;
      opener=trigger||document.activeElement;previousOverflow=document.body.style.overflow;document.body.style.overflow='hidden';dialog.showModal();
    }
    function closeDialog(restore=true) {
      if(busy || !dialog.open)return;
      dialog.close();document.body.style.overflow=previousOverflow;
      if(restore && opener?.isConnected)opener.focus({preventScroll:true});
    }
    dialog.addEventListener('cancel',event=>{event.preventDefault();closeDialog();});
    dialog.addEventListener('click',event=>{if(event.target!==dialog)return;const r=dialog.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)closeDialog();});
    function importLegacy(legacy) {
      const value=read(), fingerprint=JSON.stringify(legacy.map(i=>[i.item_id,i.product_id,i.quantity]).sort((a,b)=>a[0]-b[0]));
      legacyUnknown=legacy.filter(i=>!boards.some(b=>b.courses.includes(i.product_id))).reduce((n,i)=>n+i.quantity,0);
      if(value.legacyFingerprint!==fingerprint){
        for(const item of legacy){const board=boards.find(b=>b.courses.includes(item.product_id));if(board)value.lists[String(board.id)]=unique([...(value.lists[String(board.id)]||[]),String(item.product_id)]);}
        value.legacyFingerprint=fingerprint;save(value);
      }
      updateBadge();
    }
    async function refreshContext(forCheckout=false) {
      const response=await fetch('/bang-bao-gia/phien-dang-ky'+(forCheckout?'?checkout=1':''),{credentials:'same-origin',headers:{'X-Requested-With':'XMLHttpRequest'},cache:'no-store'});
      const result=await response.json();if(!response.ok||result.code!=='success')throw new Error(result.message||'Chưa tải được giỏ khóa học.');
      context=result.data;boards=context.boards;importLegacy(context.legacy||[]);return context;
    }
    function loading(text='Đang tải giỏ khóa học…'){body.replaceChildren(node('p','mpc-loading',text));}
    function showError(message){const error=node('p','mpc-cart-error',message);error.setAttribute('role','alert');body.prepend(error);}
    async function openCart(trigger){
      view='loading';confirmation=null;title.textContent='Các môn bạn đã chọn.';ensureOpen(trigger);loading();
      try{await refreshContext();if(dialog.open){view='cart';renderCart();}}catch(error){if(dialog.open){view='cart';body.replaceChildren();showError(error.message);body.append(button('Thử lại','mpc-primary',()=>openCart(trigger)));}}
    }
    function courseRow(board,course,remove=true) {
      const row=node('article','mpc-course-row');
      const cover=link(path(course),'','mpc-course-cover');cover.setAttribute('aria-label',`Xem môn ${course.name}`);
      const fallback=node('span','mpc-cover-fallback',course.name.replace(/^[\[\s]+/,'').slice(0,2).toLocaleUpperCase('vi'));fallback.setAttribute('aria-hidden','true');cover.append(fallback);
      if(course.image){const image=node('img');image.alt='';image.loading='lazy';image.decoding='async';let original=false;image.src=course.image.replace('/media/','/thumbs/').replace(/(\.[a-z0-9]+)(\?.*)?$/i,'_thumb_250$1$2');image.addEventListener('error',()=>{if(!original){original=true;image.src=course.image;}else image.remove();});cover.append(image);}
      const copy=node('div','mpc-course-copy');copy.append(link(path(course),course.name,'mpc-course-title'),link(path(course),'Xem môn →','mpc-course-view'));
      row.append(cover,copy);
      if(remove){const del=button('×','mpc-remove',()=>api.set(board.id,idsFor(board).filter(id=>id!==String(course.id))));del.setAttribute('aria-label',`Bỏ ${course.name} khỏi giỏ`);row.append(del);}
      return row;
    }
    function renderCart(){
      title.textContent='Các môn bạn đã chọn.';body.replaceChildren();foot.hidden=false;confirmation=null;
      let groups=0;
      for(const board of boards){
        const ids=idsFor(board);if(!ids.length)continue;groups++;
        const group=node('section','mpc-cart-group');group.dataset.cartGroup=String(board.id);
        const groupHead=node('div','mpc-group-head'), label=node('div');label.append(node('p','mpc-eyebrow',board.kind==='exam_prep'?'LUYỆN THI':'KHÓA HỌC'),node('h3','',board.name));
        const clear=button('Xóa nhóm','mpc-link-button',()=>api.set(board.id,[]));clear.setAttribute('aria-label',`Xóa nhóm ${board.name}`);groupHead.append(label,clear);group.append(groupHead);
        const courses=new Map((board.course_data||[]).map(c=>[String(c.id),c]));
        ids.forEach(id=>{const course=courses.get(id);if(course)group.append(courseRow(board,course));});
        const pack=packageFor(board,ids);if(!pack){group.append(node('p','mpc-cart-error','Bảng giá đang cập nhật. Vui lòng chọn lại sau.'));body.append(group);continue;}
        const choices=node('div','mpc-package-choice'), field=node('label');field.textContent='Gói học';const select=node('select');select.setAttribute('aria-label',`Gói học cho ${board.name}`);
        board.packages.forEach(p=>{const option=node('option','',`${p.name} · ${money(p.amount)}`);option.value=String(p.id);option.selected=p.id===pack.id;select.append(option);});
        select.addEventListener('change',()=>api.choosePackage(board.id,Number(select.value)));field.append(select);choices.append(field);
        const count=node('strong','mpc-group-count',ids.length<=pack.count?`Đã chọn ${ids.length}/${pack.count} môn`:`Đã chọn ${ids.length} môn · Gói ${pack.count} môn`);choices.append(count);group.append(choices);
        if(ids.length!==pack.count)group.append(node('p','mpc-group-hint',ids.length<pack.count?`Chọn thêm ${pack.count-ids.length} môn hoặc đổi sang gói phù hợp.`:`Bỏ bớt ${ids.length-pack.count} môn hoặc đổi sang gói lớn hơn.`));
        const actions=node('div','mpc-group-actions');actions.append(link(catalogPath(board,pack),'Chọn thêm / đổi môn','mpc-link-button'));
        const total=node('div','mpc-group-payment');total.append(priceDisplay(pack));
        const checkout=button('Thanh toán nhóm này →','mpc-primary',()=>startCheckout(board.id));checkout.disabled=ids.length!==pack.count;checkout.setAttribute('aria-label',`Thanh toán nhóm ${board.name}`);total.append(checkout);actions.append(total);group.append(actions);body.append(group);
      }
      if(legacyUnknown){const old=node('div','mpc-legacy');old.append(node('p','',`Bạn còn ${legacyUnknown} mục đã thêm từ giỏ trước đây.`),link('/order/info','Xem các mục này →','mpc-link-button'));body.append(old);}
      if(!groups&&!legacyUnknown){const empty=node('div','mpc-cart-empty');empty.append(node('span','mpc-empty-symbol','+'),node('h3','','Giỏ khóa học đang trống.'),node('p','','Chọn môn phù hợp với chặng đường của bạn.'));
        const links=node('div','mpc-empty-links');links.append(link('/khoa-hoc','Khám phá khóa học →','mpc-primary'),link('/khoa-luyen-thi','Khám phá luyện thi →','mpc-secondary'));empty.append(links);body.append(empty);}
    }
    async function startCheckout(boardId){
      if(busy)return;
      view='loading';ensureOpen(triggers[0]);loading('Đang kiểm tra gói học…');
      try{
        await refreshContext(true);if(!dialog.open)return;
        const board=boards.find(b=>b.id===Number(boardId));if(!board)throw new Error('Bảng giá không còn mở.');
        const ids=idsFor(board),pack=packageFor(board,ids);
        if(!pack||ids.length!==pack.count){view='cart';renderCart();return;}
        api.choosePackage(board.id,pack.id);
        if(!context.member){pending=board.id;view='cart';closeDialog(false);if(window.meducAuth)window.meducAuth.open('login',triggers[0]);else{ensureOpen(triggers[0]);renderCart();showError('Vui lòng đăng nhập để tiếp tục.');}return;}
        confirmation={board,pack,ids:[...ids],token:context.token};view='confirm';renderConfirmation();
      }catch(error){view='cart';if(dialog.open){renderCart();showError(error.message);}}
    }
    function renderConfirmation(){
      const {board,pack,ids}=confirmation;title.textContent='Kiểm tra đăng ký.';body.replaceChildren();foot.hidden=true;
      const summary=node('div','mpc-confirm-summary');summary.append(node('p','mpc-eyebrow',board.name),node('h3','',pack.name),priceDisplay(pack,'mpc-confirm-price'));body.append(summary);
      const courses=new Map(board.course_data.map(c=>[String(c.id),c]));ids.forEach(id=>body.append(courseRow(board,courses.get(id),false)));
      const form=node('form','mpc-confirm-form'), label=node('label','','Số điện thoại liên hệ'), phone=node('input');phone.name='phone';phone.type='tel';phone.autocomplete='tel';phone.required=true;phone.value=context.phone||'';phone.placeholder='Nhập số điện thoại';label.append(phone);form.append(label,node('p','mpc-confirm-note','Bạn sẽ chọn phương thức thanh toán ở bước tiếp theo.'));
      const error=node('p','mpc-cart-error');error.setAttribute('role','alert');form.append(error);
      const actions=node('div','mpc-confirm-actions');actions.append(button('← Quay lại giỏ','mpc-link-button',()=>{if(!busy){view='cart';renderCart();}}));const submit=node('button','mpc-primary','Tiếp tục thanh toán →');submit.type='submit';actions.append(submit);form.append(actions);body.append(form);
      form.addEventListener('submit',async event=>{
        event.preventDefault();if(busy)return;
        if(JSON.stringify(idsFor(board))!==JSON.stringify(ids)){view='cart';renderCart();showError('Các môn đã thay đổi. Vui lòng kiểm tra lại gói học.');return;}
        busy=true;submit.disabled=true;close.disabled=true;error.textContent='';
        try{
          const data=new FormData(form);data.append('package_id',pack.id);data.append('token',confirmation.token);ids.forEach(id=>data.append('course_ids[]',id));
          const response=await fetch('/bang-bao-gia/dang-ky',{method:'POST',credentials:'same-origin',body:data,headers:{'X-CSRF-Token':document.documentElement.getAttribute('csrf-token'),'X-Requested-With':'XMLHttpRequest'}});
          const result=await response.json();
          if(response.status===401){busy=false;close.disabled=false;await startCheckout(board.id);return;}
          if(!response.ok||result.code!=='success')throw new Error(result.message||'Chưa tạo được đơn đăng ký.');
          api.set(board.id,[]);location.href=result.data.redirect;
        }catch(e){error.textContent=e.message||'Kết nối gián đoạn. Vui lòng thử lại.';}
        finally{busy=false;submit.disabled=false;close.disabled=false;}
      });
    }
    window.addEventListener('meduc:course-cart',()=>{
      updateBadge();if(!dialog.open||busy)return;
      if(view==='cart')renderCart();
      else if(view==='confirm'&&confirmation&&(JSON.stringify(idsFor(confirmation.board))!==JSON.stringify(confirmation.ids)||packageFor(confirmation.board,idsFor(confirmation.board))?.id!==confirmation.pack.id)){view='cart';renderCart();showError('Các môn hoặc gói học đã thay đổi. Vui lòng kiểm tra lại.');}
    });
    window.addEventListener('meduc:authenticated',()=>{
      if(!pending)return;const boardId=pending;pending=null;const auth=document.getElementById('login-modal');
      if(window.jQuery&&auth&&auth.style.display!=='none')window.jQuery(auth).one('hidden.bs.modal',()=>startCheckout(boardId));else startCheckout(boardId);
    });
    updateBadge();if(legacyUnknown)refreshContext().catch(()=>{});
  }
})();
