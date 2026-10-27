(() => {
  'use strict';
  const form = document.querySelector('[data-faculty-application-form]');
  if (!form) return;
  const input = form.querySelector('[data-application-files]');
  const picker = form.querySelector('[data-application-pick]');
  const drop = form.querySelector('[data-application-drop]');
  const list = form.querySelector('[data-application-file-list]');
  const counter = form.querySelector('[data-application-file-count]');
  const message = form.querySelector('[data-application-message]');
  const submit = form.querySelector('[type="submit"]');
  const label = submit.querySelector('[data-application-submit-label]');
  const allowed = /\.(pdf|docx?|jpe?g|png|webp)$/i;
  let files = [];
  let sending = false;
  const bytes = new Uint8Array(16);
  crypto.getRandomValues(bytes);
  form.elements.submission_token.value = [...bytes].map(byte => byte.toString(16).padStart(2, '0')).join('');
  const showError = text => { message.textContent = text; };
  const draw = () => {
    list.replaceChildren();
    files.forEach((file, index) => {
      const item = document.createElement('li');
      const name = document.createElement('span'); name.className = 'mft-application-file-name'; name.textContent = file.name;
      const size = document.createElement('span'); size.className = 'mft-application-file-size'; size.textContent = file.size >= 1048576 ? `${(file.size / 1048576).toFixed(1)} MB` : `${Math.max(1, Math.round(file.size / 1024))} KB`;
      const remove = document.createElement('button'); remove.type = 'button'; remove.className = 'mft-application-remove'; remove.textContent = '×'; remove.setAttribute('aria-label', `Xóa file ${file.name}`);
      remove.disabled = sending;
      remove.addEventListener('click', () => { if (!sending) { files.splice(index, 1); draw(); picker.focus({preventScroll: true}); } });
      item.append(name, size, remove); list.append(item);
    });
    counter.textContent = `Đã chọn ${files.length}/5 file`;
    picker.textContent = files.length ? 'Chọn thêm file +' : 'Chọn file đính kèm +';
    picker.disabled = files.length >= 5 || sending;
  };
  const addFiles = selected => {
    if (sending) return;
    const incoming = [...selected].filter(file => !files.some(old => old.name === file.name && old.size === file.size && old.lastModified === file.lastModified));
    if (files.length + incoming.length > 5) return showError('Chỉ được đính kèm tối đa 5 file. Vui lòng bỏ bớt file đã chọn.');
    if (incoming.some(file => !allowed.test(file.name))) return showError('Chỉ nhận file PDF, DOC, DOCX, JPG, PNG hoặc WebP.');
    if (incoming.some(file => !file.size || file.size > 10 * 1024 * 1024)) return showError('Mỗi file phải có dữ liệu và không quá 10 MB.');
    files.push(...incoming); showError(''); draw();
  };
  picker.addEventListener('click', () => input.click());
  input.addEventListener('change', () => { addFiles(input.files); input.value = ''; });
  ['dragenter', 'dragover'].forEach(type => drop.addEventListener(type, event => { event.preventDefault(); drop.dataset.dragging = 'true'; }));
  ['dragleave', 'drop'].forEach(type => drop.addEventListener(type, event => { event.preventDefault(); drop.dataset.dragging = 'false'; }));
  drop.addEventListener('drop', event => addFiles(event.dataTransfer.files));
  form.addEventListener('submit', async event => {
    event.preventDefault();
    if (sending || !form.reportValidity()) return;
    showError(''); sending = true; submit.disabled = true; label.textContent = 'Đang gửi hồ sơ…'; draw();
    const body = new FormData(form);
    body.delete('attachments[]');
    files.forEach(file => body.append('attachments[]', file, file.name));
    const csrf = document.documentElement.getAttribute('csrf-token') || form.elements._csrfToken.value;
    try {
      const response = await fetch(form.action, {method: 'POST', credentials: 'same-origin', headers: {'X-CSRF-Token': csrf, 'X-Requested-With': 'XMLHttpRequest'}, body});
      const result = await response.json().catch(() => null);
      if (!response.ok || result?.code !== 'success') throw new Error(result?.message || 'Chưa gửi được hồ sơ. Vui lòng giữ thông tin và thử lại.');
      const success = document.querySelector('[data-application-success]');
      success.querySelector('[data-application-reference]').textContent = `Mã hồ sơ: #${result.data.id}`;
      form.hidden = true; success.hidden = false; success.focus({preventScroll: true});
      files = []; input.value = ''; form.reset();
    } catch (error) {
      showError(error.message || 'Kết nối bị gián đoạn. Thông tin của bạn vẫn được giữ lại, vui lòng thử lại.');
      message.scrollIntoView({block: 'nearest', behavior: 'smooth'});
    } finally {
      sending = false; submit.disabled = false; label.textContent = 'Gửi hồ sơ ứng tuyển'; draw();
    }
  });
  draw();
})();
