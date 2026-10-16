(() => {
  const root = document.querySelector('#member-dashboard');
  if (!root) return;
  const more = root.querySelector('[data-mdb-more]');
  if (more) {
    const initialLabel = more.textContent;
    more.addEventListener('click', () => {
      const expanded = more.getAttribute('aria-expanded') !== 'true';
      root.querySelectorAll('[data-mdb-extra]').forEach((course) => { course.hidden = !expanded; });
      more.setAttribute('aria-expanded', String(expanded));
      more.textContent = expanded ? 'Thu gọn khóa học ↑' : initialLabel;
    });
  }
  const links = [...root.querySelectorAll('[data-mdb-nav]')];
  links.forEach((link) => link.addEventListener('click', () => {
    links.forEach((other) => other.removeAttribute('aria-current'));
    link.setAttribute('aria-current', 'location');
  }));
  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver((entries) => {
      const first = entries.filter((entry) => entry.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)[0];
      if (!first) return;
      const active = links.find((link) => link.hash === '#' + first.target.id);
      if (!active) return;
      links.forEach((link) => link.removeAttribute('aria-current'));
      active.setAttribute('aria-current', 'location');
    }, { rootMargin: '-90px 0px -55% 0px', threshold: 0 });
    root.querySelectorAll('[data-mdb-section]').forEach((section) => observer.observe(section));
  }
})();
