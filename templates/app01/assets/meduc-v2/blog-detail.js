(() => {
    'use strict';
    const root = document.querySelector('#blog-detail-page');
    const content = root?.querySelector('.mbj-reading-column');
    if (!content || root.dataset.ready) return;
    root.dataset.ready = 'true';
    const toc = root.querySelector('.mbj-toc');
    const links = [...root.querySelectorAll('[data-toc-link]')];
    const targets = links.map(link => ({link, heading:[...content.querySelectorAll('[id]')].find(node => node.id === decodeURIComponent(link.hash.slice(1)))})).filter(item => item.heading);
    const bar = root.querySelector('[data-reading-bar]');
    const number = root.querySelector('[data-reading-number]');
    const progress = root.querySelector('[data-reading-progress]');
    const mobile = matchMedia('(max-width:850px)');
    const reducedMotion = matchMedia('(prefers-reduced-motion:reduce)');
    function setTocLayout() { toc.open = !mobile.matches; }
    setTocLayout();
    mobile.addEventListener('change', setTocLayout);
    root.querySelector('[data-reading-status]').hidden = false;
    bar.hidden = false;
    let scheduled = false;
    let lastPercent = -1;
    function update() {
        scheduled = false;
        const header = document.querySelector('#meduc-header');
        const offset = (header?.getBoundingClientRect().height || 66) + 30;
        const rect = content.getBoundingClientRect();
        const percent = Math.max(0, Math.min(100, Math.round((-rect.top + offset) * 100 / Math.max(1, rect.height - innerHeight + offset))));
        if (percent !== lastPercent) {
            number.textContent = `${percent}%`;
            progress.setAttribute('aria-valuenow', String(percent));
            progress.firstElementChild.style.transform = bar.firstElementChild.style.transform = `scaleX(${percent / 100})`;
            lastPercent = percent;
        }
        let active = rect.top <= offset ? targets[0] : null;
        targets.forEach(item => { if (item.heading.getBoundingClientRect().top <= offset + 12) active = item; });
        targets.forEach(item => { if (item === active) item.link.setAttribute('aria-current','location'); else item.link.removeAttribute('aria-current'); });
    }
    function schedule() { if (!scheduled) { scheduled = true; requestAnimationFrame(update); } }
    window.addEventListener('scroll', schedule, {passive:true});
    window.addEventListener('resize', schedule);
    const observer = new ResizeObserver(schedule);
    observer.observe(content);
    targets.forEach(({link,heading}) => link.addEventListener('click', event => {
        if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        event.preventDefault();
        if (mobile.matches) toc.open = false;
        history.replaceState(null,'',link.hash);
        heading.setAttribute('tabindex','-1');
        heading.focus({preventScroll:true});
        heading.scrollIntoView({behavior:reducedMotion.matches?'instant':'smooth',block:'start'});
    }));
    const copy = root.querySelector('[data-copy-link]');
    const copyStatus = root.querySelector('[data-copy-status]');
    copy.hidden = false;
    let resetCopy;
    copy.addEventListener('click', async () => {
        const url = new URL(location.href);
        url.hash = ''; url.search = '';
        try {
            await navigator.clipboard.writeText(url.href);
            copyStatus.textContent = 'Đã sao chép liên kết bài viết.';
            copy.lastChild.textContent = 'Đã sao chép';
            clearTimeout(resetCopy);
            resetCopy = setTimeout(() => { copy.lastChild.textContent = 'Sao chép liên kết'; },2500);
        } catch (_) {
            const dialog = root.querySelector('[data-copy-dialog]');
            const input = dialog.querySelector('input');
            input.value = url.href;
            dialog.showModal(); input.focus(); input.select();
        }
    });
    update();
})();
