const chapters = [...document.querySelectorAll('.chapter-nav a, .story-progress a')];
const targets = [...new Set(chapters.map((link) => link.getAttribute('href')))]
  .map((hash) => document.querySelector(hash))
  .filter(Boolean);

if ('IntersectionObserver' in window) {
  const observer = new IntersectionObserver((entries) => {
    const visible = entries.filter((entry) => entry.isIntersecting).sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
    if (!visible) return;
    const current = `#${visible.target.id}`;
    chapters.forEach((link) => {
      const active = link.getAttribute('href') === current;
      link.classList.toggle('is-current', active);
      if (active) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    });
  }, { rootMargin: '-20% 0px -55% 0px', threshold: [0, .25, .5, .75] });
  targets.forEach((section) => observer.observe(section));
}
