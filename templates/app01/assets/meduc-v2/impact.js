/* Community figures (block/slider/view_impact_stats.tpl): each number counts up from 0 the first time it scrolls into view.
   The page already shows the final numbers, so nothing is lost without JavaScript or with reduced motion. */
(() => {
  "use strict";
  if (matchMedia("(prefers-reduced-motion: reduce)").matches || !("IntersectionObserver" in window)) return;
  const format = new Intl.NumberFormat("vi-VN");

  function count(element) {
    const target = Number(element.dataset.count);
    if (!Number.isFinite(target)) return;
    let start;
    function tick(now) {
      if (start === undefined) start = now;
      const progress = Math.min((now - start) / 2000, 1);
      element.textContent = format.format(Math.round(target * (1 - (1 - progress) ** 3)));
      if (progress < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.querySelectorAll(".mim-count[data-count]").forEach(count);
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.2 });

  document.querySelectorAll(".mim-grid").forEach((grid) => {
    if (grid.dataset.mimReady) return;
    grid.dataset.mimReady = "1";
    grid.querySelectorAll(".mim-count[data-count]").forEach((element) => { element.textContent = "0"; });
    observer.observe(grid);
  });
})();
