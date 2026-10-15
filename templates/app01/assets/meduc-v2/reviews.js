/* Student reviews (block/slider/view_student_reviews.tpl): one review at a time, with arrows, dots and the arrow keys. */
(() => {
  "use strict";
  document.querySelectorAll(".mrv").forEach((section) => {
    if (section.dataset.mrvReady) return;
    section.dataset.mrvReady = "1";
    const slides = [...section.querySelectorAll(".mrv-slide")];
    const dots = [...section.querySelectorAll(".mrv-dot")];
    if (slides.length < 2) return;

    let active = 0;
    function show(index) {
      active = (index + slides.length) % slides.length;
      slides.forEach((slide, i) => { slide.hidden = i !== active; });
      dots.forEach((dot, i) => dot.setAttribute("aria-current", String(i === active)));
    }
    section.querySelector(".mrv-prev").addEventListener("click", () => show(active - 1));
    section.querySelector(".mrv-next").addEventListener("click", () => show(active + 1));
    dots.forEach((dot, i) => dot.addEventListener("click", () => show(i)));
    section.addEventListener("keydown", (event) => {
      if (event.key === "ArrowLeft") { event.preventDefault(); show(active - 1); }
      if (event.key === "ArrowRight") { event.preventDefault(); show(active + 1); }
    });
  });
})();
