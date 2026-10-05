(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/resource-detail.html');
  const dataURL = staticPreview ? 'assets/resource-detail-data.json' : '/hero-light/assets/resource-detail-data.json';
  const detailPage = staticPreview ? 'resource-detail.html' : '/tai-lieu-chi-tiet-v2';
  const listingPage = staticPreview ? 'documents.html' : '/tai-lieu-hoc-tap-v2';
  const query = new URLSearchParams(location.search);
  const requested = query.get('resource') || query.get('document') || query.get('tai-lieu') || query.get('slug') || query.get('id') || '494';
  const categoryNames = { 73: 'Sinh lý', 74: 'Hóa sinh', 76: 'Nội khoa', 77: 'Ngoại khoa', 78: 'Tiếng Anh Y khoa', 121: 'Ký sinh trùng' };
  const stageNames = { 75: 'Năm 1', 122: 'Năm 2', 123: 'Năm 3', 124: 'Năm 4' };
  const $ = (selector) => document.querySelector(selector);
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const titleParts = (name) => {
    const match = name.match(/^\[([^\]]+)\]\s*(.+)$/);
    return match ? { topic: match[1].trim(), title: match[2].trim() } : { topic: '', title: name.trim() };
  };
  const subject = (resource) => {
    const category = resource.categories.find((id) => categoryNames[id]);
    if (category) return categoryNames[category];
    const topic = titleParts(resource.name).topic.replace(/^Năm\s*[1-6]\s*[-–]?\s*/i, '').trim();
    return topic || 'Y khoa';
  };
  const stage = (resource) => {
    const fromTitle = resource.name.match(/\bNăm\s*([1-6])\b/i);
    if (fromTitle) return `Năm ${fromTitle[1]}`;
    const category = resource.categories.find((id) => stageNames[id]);
    return category ? stageNames[category] : '';
  };
  const detailURL = (resource) => `${detailPage}?resource=${encodeURIComponent(resource.url.slice(1))}`;
  const concise = (text, limit = 300) => {
    if (text.length <= limit) return text;
    const sliced = text.slice(0, limit);
    const boundary = Math.max(sliced.lastIndexOf('. '), sliced.lastIndexOf('! '), sliced.lastIndexOf('? '));
    return (boundary > limit * .55 ? sliced.slice(0, boundary + 1) : sliced.trimEnd()).replace(/[.!?…\s]+$/, '') + '…';
  };

  function renderContent(resource) {
    const source = resource.blocks.length ? resource.blocks : [{ type: 'paragraph', text: resource.description }];
    const chunks = [];
    const toc = [];
    let bullets = [];
    let headingCount = 0;
    const flushBullets = () => {
      if (bullets.length) chunks.push(`<ul>${bullets.map((text) => `<li>${escape(text)}</li>`).join('')}</ul>`);
      bullets = [];
    };
    for (const block of source) {
      if (!block.text) continue;
      if (block.type === 'bullet') { bullets.push(block.text); continue; }
      flushBullets();
      if (block.type === 'heading') {
        const id = `muc-${++headingCount}`;
        chunks.push(`<h3 id="${id}">${escape(block.text)}</h3>`);
        toc.push(`<a href="#${id}">${escape(block.text)}</a>`);
      } else if (block.type === 'quote') chunks.push(`<blockquote>${escape(block.text)}</blockquote>`);
      else chunks.push(`<p>${escape(block.text)}</p>`);
    }
    flushBullets();
    if (!resource.blocks.length) chunks.push('<p>Phần nội dung đầy đủ nằm trong tệp đính kèm bên dưới.</p>');
    $('#resource-content').innerHTML = chunks.join('') || '<p>Phần nội dung đầy đủ nằm trong tệp đính kèm bên dưới.</p>';
    $('#resource-toc').innerHTML = toc.join('') || '<a href="#xem-tai-lieu">Xem tệp đính kèm ↓</a>';
  }

  function renderFiles(resource) {
    const files = resource.files;
    $('#resource-file-list').innerHTML = files.map((file) => `<a class="sidebar-file" href="${escape(file.url)}" target="_blank" rel="noopener noreferrer"><svg class="icon"><use href="#i-file" /></svg><span>${escape(file.name)}<small>${escape(file.type.toUpperCase())} · Mở trong tab mới</small></span></a>`).join('') || '<p>Chưa có tệp đính kèm.</p>';
    $('#preview-open-link').href = `https://meduc.vn${resource.url}`;
    const cover = $('#preview-cover-image');
    if (resource.image) {
      cover.src = resource.image;
      cover.alt = `Ảnh minh họa tài liệu ${resource.name}`;
      cover.onerror = () => { cover.hidden = true; $('#preview-art-fallback').hidden = false; };
    } else { cover.hidden = true; $('#preview-art-fallback').hidden = false; }
    if (!files.length) {
      $('#resource-file-tabs').innerHTML = '';
      $('#preview-file-name').textContent = 'Tài liệu này chưa có tệp đính kèm.';
      $('#preview-button').hidden = true;
      return;
    }
    const tabs = $('#resource-file-tabs');
    const select = (index) => {
      tabs.querySelectorAll('button').forEach((button, buttonIndex) => button.setAttribute('aria-pressed', String(buttonIndex === index)));
      $('#preview-file-name').textContent = files[index].name;
      $('#preview-file-kind').textContent = `TỆP ${files[index].type.toUpperCase()} ĐÍNH KÈM`;
      $('#preview-button').href = files[index].url;
      $('#preview-button').textContent = `Mở ${files[index].type.toUpperCase()} ↗`;
    };
    tabs.innerHTML = files.map((file, index) => `<button type="button" aria-pressed="${index === 0}" title="${escape(file.name)}">Tệp ${escape(file.type.toUpperCase())} ${String(index + 1).padStart(2, '0')} · ${escape(file.name)}</button>`).join('');
    tabs.querySelectorAll('button').forEach((button, index) => button.addEventListener('click', () => select(index)));
    select(0);
  }

  function renderRelated(resource, resources) {
    const categories = resource.categories.filter((id) => id !== 48);
    const related = resources.filter((item) => item.id !== resource.id).map((item) => ({
      item, score: item.categories.filter((id) => categories.includes(id)).length,
    })).sort((a, b) => b.score - a.score || Math.abs(a.item.id - resource.id) - Math.abs(b.item.id - resource.id)).slice(0, 3).map(({ item }) => item);
    $('#resource-related-grid').innerHTML = related.map((item) => `<a class="resource-related-card" href="${escape(detailURL(item))}"><div class="related-image">${item.image ? `<img src="${escape(item.image)}" alt="Ảnh tài liệu ${escape(item.name)}" loading="lazy" />` : '<span>MEDUC LIBRARY</span>'}</div><div class="related-copy"><small>${escape(stage(item) || subject(item))} · TÀI LIỆU PDF</small><h3>${escape(titleParts(item.name).title)}</h3><em>Xem chi tiết <span aria-hidden="true">→</span></em></div></a>`).join('');
    $('#resource-related-grid').querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.replaceWith(Object.assign(document.createElement('span'), { textContent: 'MEDUC LIBRARY' }))));
  }

  function render(resource, resources) {
    const parts = titleParts(resource.name);
    const topic = parts.topic || [stage(resource), subject(resource)].filter(Boolean).join(' · ');
    document.title = `${parts.title} — Meduc`;
    $('#resource-crumb-name').textContent = parts.title;
    $('#resource-topic').textContent = topic ? `/ ${topic.toUpperCase()}` : '';
    $('#resource-title').textContent = parts.title;
    $('#resource-lead').textContent = concise(resource.description || 'Tài liệu học tập trong thư viện Meduc. Xem nội dung giới thiệu và tệp PDF bên dưới.');
    const pdfCount = resource.files.filter((file) => file.type === 'pdf').length;
    $('#resource-meta').innerHTML = [stage(resource), subject(resource), `${pdfCount || resource.files.length} tệp ${pdfCount ? 'PDF' : 'đính kèm'}`].filter(Boolean).map((value) => `<span>${escape(value)}</span>`).join('');
    $('#cover-index').textContent = topic || 'TÀI LIỆU Y KHOA';
    const image = $('#resource-cover-image');
    if (resource.image) {
      image.src = resource.image;
      image.alt = `Ảnh minh họa tài liệu ${resource.name}`;
      image.onerror = () => { image.hidden = true; $('#resource-cover-fallback').hidden = false; };
    } else { image.hidden = true; $('#resource-cover-fallback').hidden = false; }
    $('#resource-original-link').href = `https://meduc.vn${resource.url}`;
    renderContent(resource);
    renderFiles(resource);
    renderRelated(resource, resources);
  }

  for (const id of ['header-list-link', 'crumb-list-link', 'related-list-link']) document.getElementById(id).href = listingPage;
  fetch(dataURL).then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }).then((data) => {
    if (data.resources.length !== data.count) throw new Error('Số tài liệu không khớp dữ liệu');
    const resource = data.resources.find((item) => String(item.id) === requested || item.url.slice(1) === requested);
    if (!resource) throw new Error('Tài liệu không có trong danh mục đang mở');
    render(resource, data.resources);
  }).catch((error) => {
    $('#resource-title').textContent = 'KHÔNG TÌM THẤY TÀI LIỆU.';
    $('#resource-lead').textContent = error.message;
    $('.resource-hero-actions').innerHTML = `<a class="button" href="${escape(listingPage)}">Quay lại danh sách tài liệu</a>`;
    $('.resource-cover').hidden = true;
    for (const selector of ['.resource-body', '.resource-viewer-section', '.resource-related']) $(selector).hidden = true;
  });
})();
