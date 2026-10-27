/* Native section links work without JS. Keep the current chapter and anchor offset in sync. */
(() => {
  'use strict';
  const page = document.querySelector('#meduc-method');
  const nav = page?.querySelector('.mmp-jump');
  if (!nav) return;
  const links = [...nav.querySelectorAll('a[href^="#"]')];
  const sections = links.map(link => page.querySelector(link.getAttribute('href')));
  let pending = false;
  function update() {
    pending = false;
    page.style.setProperty('--mp-nav-h', `${nav.offsetHeight}px`);
    const header = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--mhi-header-h')) || 66;
    const readingLine = header + nav.offsetHeight + 35;
    let current = 0;
    sections.forEach((section, index) => {
      if (section && section.getBoundingClientRect().top <= readingLine) current = index;
    });
    links.forEach((link, index) => {
      if (index === current) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    });
  }
  function schedule() {
    if (pending) return;
    pending = true;
    requestAnimationFrame(update);
  }
  window.addEventListener('scroll', schedule, {passive:true});
  window.addEventListener('resize', schedule);
  window.addEventListener('load', schedule, {once:true});
  update();
})();
