(() => {
  'use strict';
  document.addEventListener('DOMContentLoaded', () => {
    const page = document.querySelector('[data-price-page]');
    const catalogNode = page?.querySelector('[data-price-catalog]');
    if (!catalogNode) return;
    const courses = JSON.parse(catalogNode.textContent);
    const byId = new Map(courses.map(c => [String(c.id), c]));
    const plans = new Map([...page.querySelectorAll('[data-package]')].map(el => [el.dataset.package, {
      el, id: el.dataset.package, count: Number(el.dataset.count), amount: Number(el.dataset.amount), name: el.dataset.name,
      chosen: byId.has(page.dataset.from) ? [page.dataset.from] : []
    }]));
    const picker = page.querySelector('[data-course-dialog]');
    const checkout = page.querySelector('[data-checkout-dialog]');
    const search = picker.querySelector('[data-course-search]');
    const year = picker.querySelector('[data-year-filter]');
    const form = checkout.querySelector('[data-price-form]');
    const error = checkout.querySelector('[data-price-error]');
    const submit = checkout.querySelector('[data-checkout]');
    const preferredYear = page.dataset.recommendedYear || '';
    const money = n => new Intl.NumberFormat('vi-VN').format(n) + 'đ';
    const normalize = s => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase();
    let plan = null, draft = [], showAll = false, busy = false;
    let authenticated = page.dataset.member === '1', pendingPlan = null, opener = null;
    let previousOverflow = '';

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
        p.el.querySelector('[data-plan-count]').textContent = `Đã chọn ${p.chosen.length}/${p.count} môn`;
        const edit = p.el.querySelector('[data-edit-plan]');
        edit.textContent = p.chosen.length < p.count ? 'Chọn thêm +' : 'Thay đổi';
        edit.setAttribute('aria-label', `${edit.textContent} môn cho ${p.name}`);
        const area = p.el.querySelector('[data-plan-courses]');
        area.replaceChildren();
        p.chosen.forEach(id => {
          const c = byId.get(id), chip = document.createElement('span');
          chip.className = 'mpr-course-chip';
          const label = document.createElement('span'); label.textContent = c.name;
          const remove = document.createElement('button'); remove.type = 'button'; remove.textContent = '×';
          remove.setAttribute('aria-label', `Bỏ chọn ${c.name} trong ${p.name}`);
          remove.addEventListener('click', () => { p.chosen = p.chosen.filter(v => v !== id); updateCards(); });
          chip.append(label, remove); area.append(chip);
        });
        if (!p.chosen.length) { const hint = document.createElement('p'); hint.textContent = 'Thêm môn bạn muốn học.'; area.append(hint); }
      });
    }
    function updateDraftCount() {
      picker.querySelector('[data-dialog-count]').textContent = `Đã chọn ${draft.length}/${plan.count} môn`;
    }
    function renderCourses() {
      const q = normalize(search.value.trim());
      const filtered = courses.filter(c => (!year.value || c.years.includes(year.value)) && (!q || normalize(c.name).includes(q)));
      const visible = showAll || q ? filtered : filtered.slice(0, 6);
      const container = picker.querySelector('[data-dialog-courses]'); container.replaceChildren();
      picker.querySelector('[data-course-list-title]').textContent = showAll || q ? `Môn học (${filtered.length})` : 'Đề xuất cho bạn';
      picker.querySelector('[data-toggle-all]').textContent = showAll ? '← Gợi ý' : 'Xem tất cả →';
      picker.querySelector('[data-suggestion-caption]').textContent = year.value ? (year.value === 'graduate' ? 'Các môn dành cho giai đoạn sau tốt nghiệp.' : `Ưu tiên môn dành cho sinh viên năm ${year.value}.`) : 'Chọn môn trong bảng giá này.';
      picker.querySelector('[data-empty]').hidden = visible.length > 0;
      visible.forEach(c => {
        const label = document.createElement('label'); label.className = 'mpr-course';
        const input = document.createElement('input'); input.type = 'checkbox'; input.value = c.id; input.checked = draft.includes(String(c.id));
        const check = document.createElement('span'); check.className = 'mpr-course-check'; check.textContent = '✓'; check.setAttribute('aria-hidden', 'true');
        const name = document.createElement('span'); name.textContent = c.name;
        input.addEventListener('change', () => {
          const id = String(c.id), status = picker.querySelector('[data-dialog-error]'); status.textContent = '';
          if (input.checked && draft.length >= plan.count) { input.checked = false; status.textContent = `Gói này gồm ${plan.count} môn. Bỏ chọn một môn nếu bạn muốn đổi.`; return; }
          draft = input.checked ? [...draft, id] : draft.filter(v => v !== id); updateDraftCount();
        });
        label.append(input, check, name); container.append(label);
      });
      updateDraftCount();
    }
    function openPicker(id, trigger) {
      plan = plans.get(String(id)); if (!plan) return;
      draft = [...plan.chosen]; showAll = false; search.value = ''; year.value = preferredYear;
      picker.querySelector('#mpr-dialog-title').textContent = `Chọn môn · ${plan.name}`;
      picker.querySelector('[data-dialog-error]').textContent = '';
      renderCourses(); openDialog(picker, trigger);
    }
    picker.querySelector('[data-toggle-all]').addEventListener('click', () => { showAll = !showAll; search.value = ''; year.value = showAll ? '' : preferredYear; renderCourses(); });
    search.addEventListener('input', renderCourses); year.addEventListener('change', renderCourses);
    picker.querySelector('[data-apply-courses]').addEventListener('click', () => { plan.chosen = [...draft]; updateCards(); closeDialog(picker); });

    function openCheckout(id, trigger) {
      const p = plans.get(String(id)); if (!p) return;
      if (p.chosen.length !== p.count) { openPicker(id, trigger); return; }
      plan = p;
      if (!authenticated) { pendingPlan = id; window.meducAuth?.open('login', trigger); return; }
      checkout.querySelector('[data-checkout-name]').textContent = p.name;
      checkout.querySelector('[data-checkout-price]').textContent = money(p.amount);
      const list = checkout.querySelector('[data-checkout-courses]'); list.replaceChildren();
      p.chosen.forEach(id => { const li = document.createElement('li'); li.textContent = byId.get(id).name; list.append(li); });
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
      if (plan.chosen.length !== plan.count) { error.textContent = 'Vui lòng chọn đủ số môn của gói.'; return; }
      busy = true; submit.disabled = true; error.textContent = '';
      try {
        const body = new FormData(form); body.append('package_id', plan.id); body.append('token', page.querySelector('[data-price-token]').value);
        plan.chosen.forEach(id => body.append('course_ids[]', id));
        const response = await fetch('/bang-bao-gia/dang-ky', {method:'POST', body, credentials:'same-origin', headers:{'X-CSRF-Token':document.documentElement.getAttribute('csrf-token'),'X-Requested-With':'XMLHttpRequest'}});
        const result = await response.json();
        if (response.status === 401) { authenticated = false; pendingPlan = plan.id; busy = false; closeDialog(checkout, false); window.meducAuth?.open('login'); return; }
        if (!response.ok || result.code !== 'success') throw new Error(result.message || 'Chưa đăng ký được.');
        location.href = result.data.redirect;
      } catch (e) { error.textContent = e.message || 'Kết nối gián đoạn. Vui lòng thử lại.'; }
      finally { busy = false; submit.disabled = false; }
    });
    updateCards();
  });
})();
