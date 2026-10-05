(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/book-detail.html');
  const assetBase = staticPreview ? 'assets/' : '/hero-light/assets/';
  const detailPage = staticPreview ? 'book-detail.html' : '/chi-tiet-sach-v2';
  const listingPage = staticPreview ? 'books.html' : '/sach-y-khoa-v2';
  const requested = new URLSearchParams(location.search).get('book') || new URLSearchParams(location.search).get('id') || '83';
  const subjectNames = { 81: 'Sinh lý', 82: 'Hóa sinh', 83: 'Giải phẫu', 84: 'Nội khoa', 85: 'Ngoại khoa', 86: 'Tiếng Anh Y khoa' };
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const formatPrice = (value) => `${new Intl.NumberFormat('vi-VN').format(value)} ₫`;
  const $ = (selector) => document.querySelector(selector);

  function subject(book) {
    const category = book.categories.find((id) => subjectNames[id]);
    return category ? subjectNames[category] : 'Sách Y khoa';
  }

  function facts(book) {
    const name = book.name;
    const result = [];
    const volumes = name.match(/\b(\d+)\s*tập\b/i);
    if (volumes) result.push(['SỐ TẬP', `${volumes[1]} tập`]);
    if (/song ngữ/i.test(name)) result.push(['NGÔN NGỮ', 'Song ngữ']);
    else if (/tiếng việt/i.test(name)) result.push(['NGÔN NGỮ', 'Tiếng Việt']);
    else if (/tiếng anh/i.test(name)) result.push(['NGÔN NGỮ', 'Tiếng Anh']);
    if (/in (?:full\s*)?màu/i.test(name)) result.push(['BẢN IN', 'In màu']);
    else if (/in đen trắng/i.test(name)) result.push(['BẢN IN', 'In đen trắng']);
    if (/khóa học theo sách|tặng khóa học/i.test(name)) result.push(['HỌC KÈM', 'Có khóa học theo sách']);
    result.push(['CHỦ ĐỀ', subject(book)]);
    return result;
  }

  function bookURL(book) {
    return `${detailPage}?book=${encodeURIComponent(book.url.slice(1))}`;
  }

  function showImage(book, index) {
    const image = $('#stage-image');
    const url = book.images[index];
    image.hidden = false;
    $('#stage-fallback').hidden = true;
    image.src = url;
    image.alt = index === 0 ? `Bìa sách ${book.name}` : `Ảnh sách ${book.name}, hình ${index + 1}`;
    $('#stage-count').textContent = `${String(index + 1).padStart(2, '0')} / ${String(book.images.length).padStart(2, '0')}`;
    $('#book-thumbnails').querySelectorAll('button').forEach((button, buttonIndex) => {
      button.setAttribute('aria-pressed', buttonIndex === index ? 'true' : 'false');
    });
    image.onerror = () => {
      image.hidden = true;
      $('#stage-fallback').hidden = false;
    };
    $('#stage-zoom').onclick = () => openLightbox(url, image.alt);
  }

  function openLightbox(url, caption) {
    $('#lightbox-image').src = url;
    $('#lightbox-image').alt = caption;
    $('#lightbox-caption').textContent = caption;
    $('#book-lightbox').hidden = false;
    document.body.classList.add('book-lightbox-open');
    $('#lightbox-close').focus();
  }

  function closeLightbox() {
    $('#book-lightbox').hidden = true;
    document.body.classList.remove('book-lightbox-open');
    $('#stage-zoom').focus();
  }

  function renderImages(book) {
    if (!book.images.length) {
      $('#stage-image').hidden = true;
      $('#stage-fallback').hidden = false;
      $('#stage-zoom').hidden = true;
      $('#book-thumbnails').hidden = true;
      $('#gallery-caption').textContent = 'Chưa có ảnh sách trong danh mục.';
      $('#book-sample-grid').innerHTML = '<p class="sample-empty">Chưa có ảnh trang mẫu cho cuốn sách này. Xem trang sản phẩm Meduc để cập nhật hình ảnh mới nhất.</p>';
      return;
    }
    $('#book-thumbnails').innerHTML = book.images.map((url, index) => `<button class="book-thumb" type="button" aria-label="Xem ảnh ${index + 1} của sách" aria-pressed="${index === 0}"><img src="${escape(url)}" alt="" loading="lazy" /></button>`).join('');
    $('#book-thumbnails').querySelectorAll('button').forEach((button, index) => {
      button.addEventListener('click', () => showImage(book, index));
    });
    showImage(book, 0);
    const gallery = book.images.slice(1, 7);
    if (!gallery.length) {
      $('#book-sample-grid').innerHTML = '<p class="sample-empty">Hiện Meduc chỉ có ảnh bìa của cuốn sách này. Xem trang sản phẩm để biết thông tin mới nhất.</p>';
      return;
    }
    $('#book-sample-grid').innerHTML = gallery.map((url, index) => `<button class="sample-card" type="button" aria-label="Phóng to ảnh sách ${index + 2}"><span><img src="${escape(url)}" alt="Ảnh mẫu ${index + 1} của sách ${escape(book.name)}" loading="lazy" /></span><strong>Ảnh sách ${String(index + 2).padStart(2, '0')} ↗</strong></button>`).join('');
    $('#book-sample-grid').querySelectorAll('button').forEach((button, index) => {
      button.addEventListener('click', () => openLightbox(gallery[index], `Ảnh ${index + 2} — ${book.name}`));
      button.querySelector('img').addEventListener('error', () => button.remove());
    });
  }

  function renderRelated(book, books) {
    const currentCategories = book.categories.filter((id) => id !== 79 && id !== 109 && id !== 110 && id !== 111);
    const related = books.filter((item) => item.id !== book.id).map((item) => ({
      item,
      score: item.categories.filter((id) => currentCategories.includes(id)).length,
    })).sort((a, b) => b.score - a.score || Math.abs(a.item.id - book.id) - Math.abs(b.item.id - book.id)).slice(0, 3).map(({ item }) => item);
    $('#book-related-grid').innerHTML = related.map((item) => `<a class="book-related-card" href="${escape(bookURL(item))}"><div class="book-related-cover">${item.images.length ? `<img src="${escape(item.images[0])}" alt="Bìa sách ${escape(item.name)}" loading="lazy" />` : '<span>MEDUC BOOKS</span>'}</div><div><small>${escape(subject(item))}</small><h3>${escape(item.name)}</h3><em>Xem chi tiết <span aria-hidden="true">→</span></em></div></a>`).join('');
    $('#book-related-grid').querySelectorAll('img').forEach((image) => image.addEventListener('error', () => {
      image.replaceWith(Object.assign(document.createElement('span'), { textContent: 'MEDUC BOOKS' }));
    }));
  }

  function render(book, books) {
    const name = book.name.trim();
    const productURL = `https://meduc.vn${book.url}`;
    const checkoutURL = `${staticPreview ? 'checkout.html' : '/thanh-toan-v2'}?book=${encodeURIComponent(book.url.slice(1))}`;
    document.title = `${name} — Meduc`;
    $('#crumb-book').textContent = name;
    $('#book-category').textContent = subject(book).toUpperCase();
    $('#book-title').textContent = name;
    $('#book-lead').textContent = 'Xem bìa, ảnh sản phẩm và thông tin bản in trước khi chọn cuốn sách phù hợp với hành trình học Y của bạn.';
    const details = facts(book);
    $('#book-quick-facts').innerHTML = details.filter(([label]) => label !== 'CHỦ ĐỀ').slice(0, 3).map(([, value]) => `<span>${escape(value)}</span>`).join('') || `<span>${escape(subject(book))}</span>`;
    $('#book-fact-grid').innerHTML = details.map(([label, value]) => `<article class="book-fact"><small>${escape(label)}</small><strong>${escape(value)}</strong></article>`).join('');
    $('#information-summary').textContent = 'Những chi tiết về bản in và cách học kèm được Meduc ghi trong tên sản phẩm, giúp bạn chọn đúng phiên bản cần đọc.';
    $('#book-buy-button').href = checkoutURL;
    $('#information-link').href = productURL;
    const base = book.price > 0 ? book.price : null;
    const special = book.special > 0 && (!base || book.special < base) ? book.special : null;
    $('#book-price').innerHTML = special
      ? `<strong>${formatPrice(special)}</strong>${base ? `<del>${formatPrice(base)}</del>` : ''}`
      : base ? `<strong>${formatPrice(base)}</strong>` : '<span>Xem giá trên Meduc</span>';
    renderImages(book);
    renderRelated(book, books);
  }

  $('#lightbox-close').addEventListener('click', closeLightbox);
  $('#book-lightbox').addEventListener('click', (event) => {
    if (event.target === $('#book-lightbox')) closeLightbox();
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !$('#book-lightbox').hidden) closeLightbox();
  });

  fetch(`${assetBase}book-detail-data.json`).then(async (response) => {
    if (!response.ok) throw new Error('Không tải được dữ liệu sách');
    const catalog = await response.json();
    const book = catalog.books.find((item) => String(item.id) === requested || item.url.slice(1) === requested);
    if (!book) throw new Error('Không tìm thấy sách trong danh mục đang mở');
    render(book, catalog.books);
  }).catch((error) => {
    $('#book-title').textContent = 'KHÔNG TÌM THẤY SÁCH.';
    $('#book-lead').textContent = error.message;
    $('#book-quick-facts').innerHTML = `<a href="${listingPage}">Quay lại danh sách sách →</a>`;
    $('#book-stage').hidden = true;
    $('#book-thumbnails').hidden = true;
    $('#gallery-caption').hidden = true;
    $('.book-buy-box').hidden = true;
    for (const id of ['thong-tin-sach', 'trang-mau', 'sach-lien-quan']) document.getElementById(id).hidden = true;
  });
})();
