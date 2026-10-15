/* Chapter navigation follows the reading position. Native anchors work even when JavaScript is unavailable. */
(() => {
  'use strict';
  const page = document.querySelector('#meduc-about');
  if (!page) return;
  const nav = page.querySelector('.mab-chapters');
  const links = [...nav.querySelectorAll('a[href^="#"]')];
  const sections = links.map(link => page.querySelector(link.getAttribute('href')));
  let pending = false;
  function update() {
    pending = false;
    const headerHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--mhi-header-h')) || 66;
    const readingLine = headerHeight + nav.offsetHeight + 40;
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
