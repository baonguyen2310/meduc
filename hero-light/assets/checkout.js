(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/checkout.html');
  const assetBase = staticPreview ? 'assets/' : '/hero-light/assets/';
  const courseList = staticPreview ? 'courses.html' : '/khoa-hoc-v2';
  const bookList = staticPreview ? 'books.html' : '/sach-y-khoa-v2';
  const params = new URLSearchParams(location.search);
  const selection = params.has('book') ? { type: 'book', value: params.get('book') }
    : params.has('course') ? { type: 'course', value: params.get('course') }
      : { type: 'course', value: params.get('product') || '48' };
  const $ = (selector) => document.querySelector(selector);
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const currency = (amount) => `${new Intl.NumberFormat('vi-VN').format(amount)}đ`;
  const displayName = (item) => item.type === 'course'
    ? item.name.replace(/^\[([^\]]+)\]\s*/, '$1: ').replace(/\s*->\s*/g, ' đến ').replace(/\s+/g, ' ').trim()
    : item.name;
  const detail = (item) => item.type === 'course'
    ? [item.chapters ? `${item.chapters} chương` : '', item.lessons ? `${item.lessons} bài học` : ''].filter(Boolean).join(' · ')
    : 'Sách Y khoa Meduc';
  const setProgress = (step) => {
    document.querySelectorAll('[data-progress]').forEach((node) => {
      const number = Number(node.dataset.progress);
      node.classList.toggle('is-complete', number < step);
      node.classList.toggle('is-current', number === step);
      if (number === step) node.setAttribute('aria-current', 'step');
      else node.removeAttribute('aria-current');
    });
  };

  function renderProduct(item, exported) {
    const name = displayName(item);
    const isBook = item.type === 'book';
    const listURL = isBook ? bookList : courseList;
    const kind = isBook ? 'SÁCH Y KHOA' : 'KHÓA HỌC Y KHOA';
    const current = item.special || item.price;
    const productURL = `https://meduc.vn${item.url}`;
    document.title = `${name} — Thanh toán Meduc`;
    $('#header-back').href = listURL;
    $('#change-product').href = listURL;
    $('#footer-browse-link').href = listURL;
    $('#footer-browse-link').textContent = isBook ? 'Khám phá sách ↗' : 'Khám phá khóa học ↗';
    $('#live-checkout-link').href = productURL;
    $('#price-date').textContent = new Date(`${exported}T12:00:00`).toLocaleDateString('vi-VN');
    $('#chosen-product').innerHTML = `<div class="chosen-cover">${item.image ? `<img src="${escape(item.image)}" alt="Ảnh ${escape(name)}" />` : 'MEDUC'}</div><div><span>${kind}</span><h3>${escape(name)}</h3><p>${escape(detail(item))}</p></div>`;
    $('#chosen-product').querySelector('img')?.addEventListener('error', (event) => event.currentTarget.replaceWith('MEDUC'));
    $('#summary-cover').src = item.image || '';
    $('#summary-cover').alt = `Ảnh ${name}`;
    $('#summary-cover').addEventListener('error', () => { $('#summary-cover').hidden = true; });
    $('#summary-kind').textContent = kind;
    $('#summary-name').textContent = name;
    $('#summary-detail').textContent = detail(item);
    $('#summary-price').textContent = currency(item.price);
    $('#summary-total').textContent = currency(current);
    $('#summary-discount-row').hidden = !item.special;
    if (item.special) $('#summary-discount').textContent = `−${currency(item.price - item.special)}`;
    $('#summary-shipping').textContent = isBook
      ? 'Phí vận chuyển và số tiền cuối cùng được xác nhận trong quy trình đặt sách của Meduc.'
      : 'Học phí cuối cùng và quyền truy cập được xác nhận trên trang khóa học Meduc.';
    $('#delivery-field').hidden = !isBook;
    $('#buyer-address').required = isBook;
    $('#review-button').disabled = false;
    $('#buyer-form').addEventListener('submit', (event) => {
      event.preventDefault();
      if (!$('#buyer-form').reportValidity()) return;
      const lines = [
        ['Sản phẩm', name],
        ['Họ và tên', $('#buyer-name').value.trim()],
        ['Số điện thoại', $('#buyer-phone').value.trim()],
        ['Email', $('#buyer-email').value.trim()],
      ];
      if (isBook) lines.push(['Địa chỉ nhận sách', $('#buyer-address').value.trim()]);
      $('#review-details').innerHTML = lines.map(([label, value]) => `<div><span>${escape(label)}</span><strong>${escape(value)}</strong></div>`).join('');
      $('#buyer-form').hidden = true;
      $('#review-panel').hidden = false;
      setProgress(3);
      $('#review-panel').scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
    $('#review-edit').addEventListener('click', () => {
      $('#review-panel').hidden = true;
      $('#buyer-form').hidden = false;
      setProgress(2);
      $('#buyer-form').scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  }

  fetch(`${assetBase}checkout-catalog.json`).then((response) => {
    if (!response.ok) throw new Error(`Không tải được dữ liệu sản phẩm (HTTP ${response.status}).`);
    return response.json();
  }).then((data) => {
    if (data.items.length !== data.count) throw new Error('Danh mục sản phẩm chưa đồng bộ.');
    const item = data.items.find((product) => product.type === selection.type
      && (String(product.id) === selection.value || product.url.slice(1) === selection.value));
    if (!item) throw new Error('Sản phẩm này không có trong danh mục đang mở.');
    renderProduct(item, data.exported);
  }).catch((error) => {
    $('#checkout-layout').hidden = true;
    $('#checkout-status').hidden = false;
    $('#checkout-status').innerHTML = `<strong>Không thể xem bước thanh toán.</strong><p>${escape(error.message)}</p><a href="${escape(courseList)}">Xem danh sách khóa học →</a>`;
  });
})();
