(() => {
  'use strict';
  const key = 'meduc-course-package-cart-v1';
  let memory = {plans:{}, active:null};
  function read() {
    try {
      const value = JSON.parse(localStorage.getItem(key));
      memory = value && value.plans && typeof value.plans === 'object' ? value : {plans:{},active:null};
    } catch (_) { /* Selections remain available in this page if browser storage is unavailable. */ }
    return memory;
  }
  function save(value) {
    memory = value;
    try { localStorage.setItem(key, JSON.stringify(value)); } catch (_) {}
    window.dispatchEvent(new CustomEvent('meduc:course-cart'));
  }
  const api = window.MeducCourseCart = {
    get(list, pack) {
      const ids = read().plans[`${list}:${pack}`];
      return Array.isArray(ids) ? [...new Set(ids.map(String))] : null;
    },
    set(list, pack, ids) {
      const value = read(); value.plans[`${list}:${pack}`] = [...new Set(ids.map(String))]; save(value);
    },
    activate(list, pack) { const value = read(); value.active = {list:Number(list),pack:Number(pack)}; save(value); },
    active() { return read().active; },
    stop() { const value = read(); value.active = null; save(value); },
    configure(config) { setup(config); }
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
    function selection() { return (api.get(board.id,pack.id) || []).filter(id => board.courses.includes(Number(id))).slice(0,pack.count); }
    function toggle(id) {
      if (!board || !board.courses.includes(Number(id))) return;
      const ids = selection(), index = ids.indexOf(String(id));
      if (index >= 0) ids.splice(index,1);
      else if (ids.length < pack.count) ids.push(String(id));
      else { alert.textContent = `Gói đã đủ ${pack.count} môn. Bỏ chọn một môn để đổi.`; return; }
      alert.textContent = ''; api.set(board.id,pack.id,ids);
    }
    function update() {
      const active = api.active();
      if (!active || !board || active.list !== board.id || active.pack !== pack.id) {
        if (banner) {const url=new URL(location.href);url.searchParams.delete('bang_gia');url.searchParams.delete('goi');history.replaceState(null,'',url.pathname+url.search+url.hash);location.reload();}
        return;
      }
      const ids = selection();
      counter.textContent = `Đã chọn ${ids.length}/${pack.count} môn`;
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
})();
