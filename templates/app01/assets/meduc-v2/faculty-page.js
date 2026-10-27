/* Section navigation, faculty layouts and a native dialog for profile dossiers. */
(() => {
  'use strict';
  const page = document.querySelector('#faculty-page');
  if (!page) return;
  const sectionNav = page.querySelector('[data-faculty-sections]');
  if (sectionNav) {
    const track = sectionNav.querySelector('.mft-section-links');
    const links = [...track.querySelectorAll('a[href^="#"]')];
    const sections = links.map(link => page.querySelector(link.getAttribute('href')));
    // The theme's legacy anchor handler uses a fixed header offset. Keep these links scoped to the actual sticky bars.
    sectionNav.addEventListener('click', (event) => {
      const link = event.target.closest('a[href^="#"]');
      if (!link || event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
      const target = page.querySelector(link.getAttribute('href'));
      if (!target) return;
      event.preventDefault();
      event.stopPropagation();
      history.pushState(null, '', link.getAttribute('href'));
      target.scrollIntoView({ block: 'start', behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth' });
    }, { capture: true });
    let pending = false;
    let previous = null;
    let previousWidth = 0;
    const updateSections = () => {
      pending = false;
      page.style.setProperty('--mft-nav-h', `${sectionNav.offsetHeight}px`);
      const headerHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--mhi-header-h')) || 66;
      const readingLine = headerHeight + sectionNav.offsetHeight + 40;
      let current = 0;
      sections.forEach((section, index) => {
        if (section && section.getBoundingClientRect().top <= readingLine) current = index;
      });
      links.forEach((link, index) => {
        if (index === current) link.setAttribute('aria-current', 'location');
        else link.removeAttribute('aria-current');
      });
      if (current !== previous || track.clientWidth !== previousWidth) {
        previous = current;
        previousWidth = track.clientWidth;
        if (track.scrollWidth > track.clientWidth) {
          track.scrollLeft = links[current].offsetLeft - (track.clientWidth - links[current].offsetWidth) / 2;
        }
      }
    };
    const scheduleSections = () => {
      if (pending) return;
      pending = true;
      requestAnimationFrame(updateSections);
    };
    window.addEventListener('scroll', scheduleSections, { passive: true });
    window.addEventListener('resize', scheduleSections);
    window.addEventListener('load', scheduleSections, { once: true });
    if ('ResizeObserver' in window) new ResizeObserver(scheduleSections).observe(sectionNav);
    updateSections();
  }
  const directory = page.querySelector('[data-faculty-view]');
  const layoutSwitch = page.querySelector('[data-faculty-layout-switch]');
  if (directory && layoutSwitch) {
    layoutSwitch.hidden = false;
    layoutSwitch.addEventListener('click', (event) => {
      const button = event.target.closest('[data-faculty-layout]');
      if (!button) return;
      const view = button.dataset.facultyLayout;
      if (view !== 'list' && view !== 'grid') return;
      directory.dataset.facultyView = view;
      layoutSwitch.querySelectorAll('[data-faculty-layout]').forEach((option) => {
        option.setAttribute('aria-pressed', String(option === button));
      });
    });
  }
  const showMore = page.querySelector('[data-faculty-more]');
  if (directory && showMore) {
    showMore.addEventListener('click', () => {
      directory.dataset.facultyExpanded = 'true';
      showMore.setAttribute('aria-expanded', 'true');
      page.querySelector('[data-faculty-more-wrap]').hidden = true;
      const cards = [...directory.querySelectorAll('.mft-grid > .mgv-card')];
      page.querySelector('[data-faculty-count]').textContent = `${cards.length} giảng viên & cố vấn`;
      cards[6]?.querySelector('[data-faculty-open]')?.focus({ preventScroll: true });
    });
  }
  const dialog = page.querySelector('#faculty-profile-dialog');
  const content = dialog.querySelector('[data-faculty-content]');
  let opener = null;

  page.addEventListener('click', (event) => {
    const button = event.target.closest('[data-faculty-open]');
    if (!button) return;
    const template = page.querySelector(`#${button.dataset.facultyOpen}`);
    if (!template) return;
    opener = button;
    content.replaceChildren(template.content.cloneNode(true));
    dialog.showModal();
    document.documentElement.classList.add('mft-profile-open');
    content.scrollTop = 0;
  });
  dialog.querySelector('[data-faculty-close]').addEventListener('click', () => dialog.close());
  let startedOnBackdrop = false;
  dialog.addEventListener('pointerdown', (event) => { startedOnBackdrop = event.target === dialog; });
  dialog.addEventListener('click', (event) => {
    if (startedOnBackdrop && event.target === dialog) {
      const rect = dialog.getBoundingClientRect();
      if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
    }
    startedOnBackdrop = false;
  });
  dialog.addEventListener('close', () => {
    document.documentElement.classList.remove('mft-profile-open');
    content.replaceChildren();
    if (opener?.isConnected) opener.focus({ preventScroll: true });
  });
})();
