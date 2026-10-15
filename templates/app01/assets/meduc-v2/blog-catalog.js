(() => {
    'use strict';
    const root = document.querySelector('#blog-catalog-page');
    if (!root || root.dataset.ready) return;
    root.dataset.ready = 'true';
    const grid = root.querySelector('[data-blog-grid]');
    const search = root.querySelector('#blog-search');
    const sort = root.querySelector('#blog-sort');
    const links = [...root.querySelectorAll('[data-blog-topic]')];
    const clear = root.querySelector('[data-blog-clear]');
    const more = root.querySelector('[data-blog-more]');
    const empty = root.querySelector('[data-blog-empty]');
    const reset = root.querySelector('[data-blog-reset]');
    const status = root.querySelector('[data-blog-status]');
    const normalize = value => value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLocaleLowerCase('vi').trim();
    const cards = [...grid.querySelectorAll('[data-blog-card]')].map((node, index) => ({
        node, index, name: node.querySelector('h3').textContent.trim(),
        text: normalize(node.querySelector('.mbl-card-copy').textContent),
        topics: node.dataset.topics.split(' '), created: Number(node.dataset.created) || 0,
    }));
    const collator = new Intl.Collator('vi', { sensitivity: 'base', numeric: true });
    const params = new URLSearchParams(location.search);
    let active = String(root.dataset.initialTopic || '0');
    if (links.some(link => link.dataset.blogTopic === params.get('topic'))) active = params.get('topic');
    let limit = 12;

    function render() {
        const words = normalize(search.value).split(/\s+/).filter(Boolean);
        const matches = cards.filter(card => (active === '0' || card.topics.includes(active)) && words.every(word => card.text.includes(word)));
        matches.sort((a, b) => sort.value === 'name' ? collator.compare(a.name, b.name) : (sort.value === 'oldest' ? a.created - b.created : b.created - a.created) || a.index - b.index);
        cards.forEach(card => { card.node.hidden = true; });
        const fragment = document.createDocumentFragment();
        matches.forEach((card, index) => { card.node.hidden = index >= limit; fragment.append(card.node); });
        grid.append(fragment);
        links.forEach(link => {
            if (link.dataset.blogTopic === active) link.setAttribute('aria-current', 'true');
            else link.removeAttribute('aria-current');
        });
        const selected = links.find(link => link.dataset.blogTopic === active);
        const label = active !== '0' ? selected.childNodes[0].textContent.trim() : '';
        status.textContent = `Hiển thị ${Math.min(limit, matches.length)} / ${matches.length} bài viết${label ? ` · ${label}` : ''}`;
        more.hidden = matches.length <= limit;
        empty.hidden = matches.length > 0;
        clear.hidden = search.value.length === 0;
        return matches;
    }
    function remember() {
        const url = new URL(location.href);
        if (search.value.trim()) url.searchParams.set('keyword', search.value.trim()); else url.searchParams.delete('keyword');
        if (active !== String(root.dataset.initialTopic || '0')) url.searchParams.set('topic', active); else url.searchParams.delete('topic');
        history.replaceState(null, '', url);
    }
    search.addEventListener('input', () => { limit = 12; render(); remember(); });
    sort.addEventListener('change', () => { limit = 12; render(); });
    links.forEach(link => link.addEventListener('click', event => {
        if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        event.preventDefault(); active = link.dataset.blogTopic; limit = 12; render(); remember();
    }));
    clear.addEventListener('click', () => { search.value = ''; limit = 12; render(); remember(); search.focus(); });
    reset.addEventListener('click', () => { active = '0'; search.value = ''; sort.value = 'newest'; limit = 12; render(); remember(); search.focus(); });
    more.addEventListener('click', () => {
        const previousLimit = limit;
        limit += 12;
        const matches = render();
        const next = matches[previousLimit];
        if (next) next.node.querySelector('h3 a').focus({ preventScroll: true });
    });
    root.querySelector('[data-blog-tools]').hidden = false;
    reset.hidden = false;
    render();
})();
