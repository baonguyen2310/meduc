(() => {
  'use strict';
  document.addEventListener('DOMContentLoaded', () => {
    const page = document.querySelector('[data-price-page]');
    const catalogNode = page?.querySelector('[data-price-catalog]');
    if (!catalogNode) return;
    const courses = JSON.parse(catalogNode.textContent);
    const byId = new Map(courses.map(c => [String(c.id), c]));
    const cart = window.MeducCourseCart, listId = page.dataset.listId;
    function stored() {
      const saved = cart?.get(listId);
      return saved !== null && saved !== undefined ? saved.filter(id => byId.has(id)) : [];
    }
    let chosen = stored();
    if (byId.has(page.dataset.from) && !chosen.includes(page.dataset.from)) chosen.push(page.dataset.from);
    if (page.dataset.from) {
      const url=new URL(location.href);url.searchParams.delete('mon');
      history.replaceState(null,'',url.pathname+url.search+url.hash);
    }
    const plans = new Map([...page.querySelectorAll('[data-package]')].map(el => [el.dataset.package, {
      el, id: el.dataset.package, count: Number(el.dataset.count), amount: Number(el.dataset.amount), name: el.dataset.name
    }]));
    const picker = page.querySelector('[data-course-dialog]');
    const checkout = page.querySelector('[data-checkout-dialog]');
    const search = picker.querySelector('[data-course-search]');
    const year = picker.querySelector('[data-year-filter]');
    const form = checkout.querySelector('[data-price-form]');
    const error = checkout.querySelector('[data-price-error]');
    const submit = checkout.querySelector('[data-checkout]');
    const firstSelected = chosen.find(id => byId.get(id)?.years?.length);
    const preferredYear = page.dataset.recommendedYear || byId.get(firstSelected)?.years?.[0] || '';
    const money = n => new Intl.NumberFormat('vi-VN').format(n) + 'đ';
    const normalize = s => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
    let plan = null, draft = [], busy = false;
    let authenticated = page.dataset.member === '1', pendingPlan = null, opener = null;
    let previousOverflow = '';
    const allPath = page.dataset.catalogUrl || ({knowledge:'/khoa-hoc',exam_solution:'/khoa-chua-de',quiz:'/trac-nghiem'}[page.dataset.courseType] || '/khoa-hoc');
    const contextUrl = path => { const url = new URL(path || '/', location.origin + '/'); url.searchParams.set('bang_gia',listId);url.searchParams.set('goi',plan.id);return url.pathname + url.search; };
    function persist() { cart?.set(listId,chosen); }
    persist();
    window.addEventListener('meduc:course-cart', () => {
      const next=stored();if (JSON.stringify(next)===JSON.stringify(chosen)) return;
      chosen=next;updateCards();
      if (picker.open) {draft=[...chosen];renderCourses();}
      if (checkout.open && !busy) {closeDialog(checkout,false);openPicker(plan.id);}
    });

    function openDialog(dialog, trigger) {
      opener = trigger || document.activeElement;
      previousOverflow = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      dialog.showModal();
    }
    function closeDialog(dialog, restore = true) {
      if (!dialog.open) return;
      dialog.close();
      document.body.style.overflow = previousOverflow;
      if (restore && opener?.isConnected) opener.focus({preventScroll:true});
    }
    [picker, checkout].forEach(dialog => {
      dialog.addEventListener('cancel', event => { event.preventDefault(); if (!busy) closeDialog(dialog); });
      dialog.addEventListener('click', event => {
        if (event.target.closest('[data-close-dialog]')) { if (!busy) closeDialog(dialog); return; }
        if (event.target === dialog) {
          const r = dialog.getBoundingClientRect();
          if (!busy && (event.clientX < r.left || event.clientX > r.right || event.clientY < r.top || event.clientY > r.bottom)) closeDialog(dialog);
        }
      });
    });

    function updateCards() {
      plans.forEach(p => {
        const overflow=chosen.length>p.count;
        p.el.querySelector('[data-plan-count]').textContent = overflow ? `Đã chọn ${chosen.length} môn` : `Đã chọn ${chosen.length}/${p.count} môn`;
        let hint=p.el.querySelector('[data-plan-warning]');
        if (!hint) {hint=document.createElement('p');hint.className='mpr-choice-warning';hint.dataset.planWarning='';p.el.querySelector('.mpr-choice-head').after(hint);}
        hint.hidden=!overflow;hint.textContent=overflow ? `Gói này gồm ${p.count} môn. Bỏ bớt ${chosen.length-p.count} môn hoặc chọn gói lớn hơn.` : '';
        const edit = p.el.querySelector('[data-edit-plan]');
        edit.textContent = chosen.length < p.count ? 'Chọn thêm +' : 'Thay đổi';
        edit.setAttribute('aria-label', `${edit.textContent} môn cho ${p.name}`);
        const area = p.el.querySelector('[data-plan-courses]');
        area.replaceChildren();
        chosen.forEach(id => {
          const c = byId.get(id), chip = document.createElement('span');
          chip.className = 'mpr-course-chip';
          const label = document.createElement('span'); label.textContent = c.name;
          const remove = document.createElement('button'); remove.type = 'button'; remove.textContent = '×';
          remove.setAttribute('aria-label', `Bỏ chọn ${c.name} trong ${p.name}`);
          remove.addEventListener('click', () => { chosen = chosen.filter(v => v !== id); persist(); updateCards(); });
          chip.append(label, remove); area.append(chip);
        });
        if (!chosen.length) { const hint = document.createElement('p'); hint.textContent = 'Thêm môn bạn muốn học.'; area.append(hint); }
      });
    }
    function updateDraftCount() {
      picker.querySelector('[data-dialog-error]').textContent='';
      picker.querySelector('[data-dialog-count]').textContent = draft.length>plan.count ? `Đã chọn ${draft.length} môn · Gói ${plan.count} môn` : `Đã chọn ${draft.length}/${plan.count} môn`;
      if (draft.length>plan.count) picker.querySelector('[data-dialog-error]').textContent=`Bỏ bớt ${draft.length-plan.count} môn để đăng ký gói này. Các lựa chọn được dùng chung cho các gói.`;
    }
    function renderCourses() {
      const q = normalize(search.value.trim());
      const filtered = courses.filter(c => (!year.value || c.years.includes(year.value)) && (!q || normalize(c.name).includes(q)));
      const selected = chosen.map(id => byId.get(id));
      const visible = q ? filtered : [...selected,...filtered.filter(c => !chosen.includes(String(c.id)))].slice(0,Math.max(6,selected.length));
      const container = picker.querySelector('[data-dialog-courses]'); container.replaceChildren();
      picker.querySelector('[data-course-list-title]').textContent = q ? `Môn phù hợp (${filtered.length})` : 'Đề xuất cho bạn';
      picker.querySelector('[data-browse-all]').href = contextUrl(allPath);
      picker.querySelector('[data-suggestion-caption]').textContent = year.value ? (year.value === 'graduate' ? 'Các môn dành cho giai đoạn sau tốt nghiệp.' : `Ưu tiên môn dành cho sinh viên năm ${year.value}.`) : 'Chọn môn trong bảng giá này.';
      picker.querySelector('[data-empty]').hidden = visible.length > 0;
      visible.forEach(c => {
        const row = document.createElement('article'); row.className = 'mpr-course';
        const href = contextUrl(c.url);
        const cover = document.createElement('a'); cover.className = 'mpr-mini-cover';cover.href=href;cover.setAttribute('aria-label',`Xem môn ${c.name}`);
        const fallback = document.createElement('span'); fallback.className='mpr-mini-placeholder';fallback.setAttribute('aria-hidden','true');
        const brand = document.createElement('small');brand.textContent='MEDUC';
        const initial = document.createElement('strong');initial.textContent=c.name.replace(/^[\[\s]+/,'').slice(0,2).toLocaleUpperCase('vi');
        fallback.append(brand,initial);cover.append(fallback);
        if (c.image) {
          const img = document.createElement('img');img.alt='';img.loading='lazy';img.decoding='async';
          const image = new URL(c.image,location.origin);let original=false;
          img.src=image.href.replace('/media/','/thumbs/').replace(/(\.[a-z0-9]+)(\?.*)?$/i,'_thumb_250$1$2');
          img.addEventListener('error',()=>{if(!original){original=true;img.src=image.href;}else img.remove();});cover.append(img);
        }
        const copy = document.createElement('div');copy.className='mpr-mini-copy';
        const title = document.createElement('h4'), link = document.createElement('a');link.href=href;link.textContent=c.name;title.append(link);
        const meta = document.createElement('p');meta.className='mpr-mini-meta';
        meta.textContent=[c.chapters ? `${c.chapters} chương` : '',c.lessons ? `${c.lessons} bài học` : ''].filter(Boolean).join(' · ');
        const view = document.createElement('a');view.className='mpr-mini-view';view.href=href;view.textContent='Xem môn →';
        copy.append(title,meta,view);
        const label = document.createElement('label');label.className='mpr-course-toggle';
        const input = document.createElement('input'); input.type = 'checkbox'; input.value = c.id; input.checked = draft.includes(String(c.id));input.setAttribute('aria-label',`Chọn ${c.name}`);
        const check = document.createElement('span'); check.className = 'mpr-course-check'; check.textContent = '✓'; check.setAttribute('aria-hidden', 'true');
        input.addEventListener('change', () => {
          const id = String(c.id), status = picker.querySelector('[data-dialog-error]'); status.textContent = '';
          if (input.checked && draft.length >= plan.count) { input.checked = false; status.textContent = `Gói này gồm ${plan.count} môn. Bỏ chọn một môn nếu bạn muốn đổi.`; return; }
          draft = input.checked ? [...draft, id] : draft.filter(v => v !== id);
          chosen=[...draft];persist();updateCards();updateDraftCount();
        });
        label.append(input,check);row.append(cover,copy,label);container.append(row);
      });
      updateDraftCount();
    }
    function openPicker(id, trigger) {
      plan = plans.get(String(id)); if (!plan) return;
      draft = [...chosen]; search.value = ''; year.value = preferredYear;cart?.activate(listId,plan.id);
      picker.querySelector('#mpr-dialog-title').textContent = `Chọn môn · ${plan.name}`;
      picker.querySelector('[data-dialog-error]').textContent = '';
      renderCourses(); openDialog(picker, trigger);
    }
    search.addEventListener('input', renderCourses); year.addEventListener('change', renderCourses);
    picker.querySelector('[data-apply-courses]').addEventListener('click', () => { chosen = [...draft]; persist(); updateCards(); closeDialog(picker); });

    function openCheckout(id, trigger) {
      const p = plans.get(String(id)); if (!p) return;
      if (chosen.length !== p.count) { openPicker(id, trigger); return; }
      plan = p;
      if (!authenticated) { pendingPlan = id; window.meducAuth?.open('login', trigger); return; }
      checkout.querySelector('[data-checkout-name]').textContent = p.name;
      checkout.querySelector('[data-checkout-price]').textContent = money(p.amount);
      const list = checkout.querySelector('[data-checkout-courses]'); list.replaceChildren();
      chosen.forEach(id => { const li = document.createElement('li'); li.textContent = byId.get(id).name; list.append(li); });
      error.textContent = ''; openDialog(checkout, trigger);
    }
    page.querySelectorAll('[data-edit-plan]').forEach(b => b.addEventListener('click', () => openPicker(b.dataset.editPlan, b)));
    page.querySelectorAll('[data-register-plan]').forEach(b => b.addEventListener('click', () => openCheckout(b.dataset.registerPlan, b)));
    checkout.querySelector('[data-back-to-courses]').addEventListener('click', () => { if (busy) return; const id = plan.id; closeDialog(checkout, false); openPicker(id, plans.get(id).el.querySelector('[data-edit-plan]')); });
    window.addEventListener('meduc:authenticated', () => {
      authenticated = true;
      if (!pendingPlan) return;
      const id = pendingPlan; pendingPlan = null;
      const auth = document.getElementById('login-modal');
      if (window.jQuery && auth && auth.style.display !== 'none') window.jQuery(auth).one('hidden.bs.modal', () => openCheckout(id));
      else openCheckout(id);
    });
    form.addEventListener('submit', async event => {
      event.preventDefault(); if (busy || !plan) return;
      if (chosen.length !== plan.count) { error.textContent = 'Vui lòng chọn đủ số môn của gói.'; return; }
      busy = true; submit.disabled = true; error.textContent = '';
      try {
        const body = new FormData(form); body.append('package_id', plan.id); body.append('token', page.querySelector('[data-price-token]').value);
        chosen.forEach(id => body.append('course_ids[]', id));
        const response = await fetch('/bang-bao-gia/dang-ky', {method:'POST', body, credentials:'same-origin', headers:{'X-CSRF-Token':document.documentElement.getAttribute('csrf-token'),'X-Requested-With':'XMLHttpRequest'}});
        const result = await response.json();
        if (response.status === 401) { authenticated = false; pendingPlan = plan.id; busy = false; closeDialog(checkout, false); window.meducAuth?.open('login'); return; }
        if (!response.ok || result.code !== 'success') throw new Error(result.message || 'Chưa đăng ký được.');
        cart?.set(listId,[]);
        location.href = result.data.redirect;
      } catch (e) { error.textContent = e.message || 'Kết nối gián đoạn. Vui lòng thử lại.'; }
      finally { busy = false; submit.disabled = false; }
    });
    updateCards();
  });
})();
