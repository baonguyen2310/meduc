(() => {
  'use strict';

  const staticPreview = location.pathname.endsWith('/blog-detail.html');
  const dataURL = staticPreview ? 'assets/blog-detail-data.json' : '/hero-light/assets/blog-detail-data.json';
  const detailBase = staticPreview ? 'blog-detail.html' : '/bai-viet-chi-tiet-v2';
  const categoryNames = [
    [100, 'Kinh nghiệm học tập'], [98, 'Kinh nghiệm học tập'],
    [93, 'Giải phẫu'], [117, 'Giải phẫu'],
    [91, 'Sinh lý'], [119, 'Sinh lý'],
    [92, 'Hóa sinh'], [118, 'Hóa sinh'],
    [94, 'Nội khoa'], [116, 'Nội khoa'],
    [95, 'Ngoại khoa'], [115, 'Ngoại khoa'],
    [96, 'Tiếng Anh Y khoa'], [114, 'Tiếng Anh Y khoa'],
  ];
  const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  const dateLabel = (value) => value ? value.split('-').reverse().join('/') : '';
  const labelFor = (article) => categoryNames.find(([id]) => article.categories.includes(id))?.[1] || 'Blog Meduc';
  const relatedLink = (article) => `${detailBase}?post=${encodeURIComponent(article.url.slice(1))}`;
  const current = new URLSearchParams(location.search);
  const requested = (current.get('post') || current.get('article') || current.get('slug') || current.get('id') || 'cach-hoc-giai-phau-hieu-qua-qua-co-the-chinh-minh')
    .replace(/^https?:\/\/[^/]+\//, '').replace(/^\//, '').split('?')[0];

  function renderRelated(articles, selected) {
    const specificCategories = selected.categories.filter((id) => id !== 45 && id !== 113);
    const others = articles.filter((item) => item.id !== selected.id).sort((a, b) => {
      const scoreA = a.categories.some((id) => specificCategories.includes(id)) ? 1 : 0;
      const scoreB = b.categories.some((id) => specificCategories.includes(id)) ? 1 : 0;
      return scoreB - scoreA || b.date.localeCompare(a.date) || b.id - a.id;
    }).slice(0, 3);
    const grid = document.querySelector('#related-grid');
    grid.innerHTML = others.map((item) => `
      <a class="blog-related-card" href="${escape(relatedLink(item))}">
        <div class="blog-related-image">${item.image ? `<img src="${escape(item.image)}" alt="Ảnh bài viết ${escape(item.name)}" loading="lazy" />` : ''}<span>MEDUC<br />JOURNAL</span></div>
        <div class="blog-related-copy"><small>${escape(labelFor(item))}</small><strong>${escape(item.name)}</strong><em>${dateLabel(item.date)} · ${item.minutes} phút đọc</em></div>
      </a>`).join('');
    grid.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
  }

  function renderToc(content) {
    const headings = [...content.querySelectorAll('h2, h3')].filter((heading) => heading.textContent.trim()).slice(0, 18);
    headings.forEach((heading, index) => { heading.id = `muc-${index + 1}`; });
    const toc = document.querySelector('#article-toc');
    toc.innerHTML = headings.map((heading) => `<a href="#${heading.id}">${escape(heading.textContent.trim())}</a>`).join('');
    if (!headings.length) toc.innerHTML = '<a href="#article-content">Nội dung bài viết</a>';
    return headings;
  }

  function readingProgress(content, headings) {
    const articleTop = window.scrollY + content.getBoundingClientRect().top;
    const articleBottom = articleTop + content.offsetHeight;
    const percent = Math.max(0, Math.min(100, Math.round(100 * (window.scrollY - articleTop + 130) / Math.max(1, articleBottom - articleTop - window.innerHeight + 130))));
    document.querySelector('#reading-progress-bar').style.width = `${percent}%`;
    document.querySelector('#reading-progress-number').textContent = `${percent}%`;
    const active = [...headings].reverse().find((heading) => heading.getBoundingClientRect().top <= 155);
    document.querySelectorAll('#article-toc a').forEach((link) => link.classList.toggle('is-current', Boolean(active && link.hash === `#${active.id}`)));
  }

  function showMissing() {
    document.querySelector('#blog-article').hidden = true;
    document.querySelector('.blog-related').hidden = true;
    document.querySelector('.blog-learning-next').hidden = true;
    document.querySelector('#article-error').hidden = false;
    document.title = 'Không tìm thấy bài viết — Meduc';
  }

  fetch(dataURL).then((response) => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }).then((data) => {
    if (data.articles.length !== data.count) throw new Error('Số bài viết không khớp dữ liệu');
    const article = data.articles.find((item) => String(item.id) === requested || item.url.slice(1) === requested);
    if (!article) { showMissing(); return; }

    document.title = `${article.name} — Meduc`;
    document.querySelector('meta[name="description"]').content = article.summary;
    document.querySelector('#crumb-title').textContent = article.name;
    document.querySelector('#article-topic').textContent = labelFor(article).toUpperCase();
    document.querySelector('#article-title').textContent = article.name;
    document.querySelector('#article-lead').textContent = article.summary;
    const date = document.querySelector('#article-date');
    date.dateTime = article.date;
    date.textContent = `Đăng ngày ${dateLabel(article.date)}`;
    document.querySelector('#article-minutes').textContent = `${article.minutes} phút đọc`;
    document.querySelector('#original-article-link').href = `https://meduc.vn${article.url}`;

    const heroImage = document.querySelector('#article-hero-image');
    const heroFallback = document.querySelector('#article-hero-fallback');
    if (article.image) {
      heroImage.src = article.image;
      heroImage.alt = `Ảnh đại diện bài viết ${article.name}`;
      heroImage.addEventListener('error', () => { heroImage.hidden = true; heroFallback.hidden = false; });
    } else {
      heroImage.hidden = true;
      heroFallback.hidden = false;
    }

    const content = document.querySelector('#article-content');
    content.innerHTML = article.content || '<p>Nội dung đang được cập nhật trên Meduc.</p>';
    content.querySelectorAll('img').forEach((image) => image.addEventListener('error', () => image.remove()));
    const headings = renderToc(content);
    const update = () => readingProgress(content, headings);
    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);
    update();
    renderRelated(data.articles, article);

    const copy = document.querySelector('#copy-article-link');
    copy.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(location.href);
        copy.querySelector('span').textContent = 'Đã sao chép liên kết';
      } catch (_) {
        copy.querySelector('span').textContent = 'Không thể sao chép';
      }
      setTimeout(() => { copy.querySelector('span').textContent = 'Sao chép liên kết'; }, 2500);
    });
  }).catch(showMissing);
})();
