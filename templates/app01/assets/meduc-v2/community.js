/* Count the community figures once when they enter the viewport. Final values remain available without JavaScript. */
(() => {
  "use strict";
  if (matchMedia("(prefers-reduced-motion: reduce)").matches || !("IntersectionObserver" in window)) return;
  const format = new Intl.NumberFormat("vi-VN");
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.querySelectorAll(".mhi-count-value[data-count]").forEach((element) => {
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
      });
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.2 });
  document.querySelectorAll(".mhi-community-grid").forEach((grid) => {
    if (grid.dataset.communityReady) return;
    grid.dataset.communityReady = "1";
    grid.querySelectorAll(".mhi-count-value[data-count]").forEach((element) => { element.textContent = "0"; });
    observer.observe(grid);
  });
})();
