(() => {
  "use strict";

  const groups = [...document.querySelectorAll(".mhi-community-grid, .mhi-impact-grid")];
  if (!groups.length) return;

  const format = new Intl.NumberFormat("vi-VN");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function startCounter(element) {
    const target = Number(element.dataset.count);
    if (!Number.isFinite(target)) return;

    if (reducedMotion) {
      element.textContent = format.format(target);
      return;
    }

    if (typeof window.Odometer === "function") {
      const odometer = new window.Odometer({
        el: element,
        value: 0,
        duration: 2000,
        format: "(.ddd)",
        theme: "default",
      });
      requestAnimationFrame(() => odometer.update(target));
      return;
    }

    let startTime;
    function tick(now) {
      if (startTime === undefined) startTime = now;
      const progress = Math.min((now - startTime) / 2000, 1);
      const eased = 1 - (1 - progress) ** 3;
      element.textContent = format.format(Math.round(target * eased));
      if (progress < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  }

  function startGroup(group) {
    group.querySelectorAll(".mhi-count-value[data-count]").forEach(startCounter);
  }

  if (reducedMotion || !window.IntersectionObserver) {
    groups.forEach(startGroup);
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      startGroup(entry.target);
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.2 });
  groups.forEach((group) => observer.observe(group));
})();
