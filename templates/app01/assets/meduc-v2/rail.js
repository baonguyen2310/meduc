/* Sideways card rails on the homepage (faculty and student videos): previous/next buttons and a "01–03 / 06" counter.
   Markup: [data-mrail] holds [data-mrail-track] (the scrolling row of cards) and optional
   [data-mrail-prev], [data-mrail-next] and [data-mrail-counter]. Several views load this file, so each rail is set up once. */
(() => {
  "use strict";
  const pad = (number) => String(number).padStart(2, "0");

  function setUp(root) {
    if (root.dataset.mrailReady) return;
    root.dataset.mrailReady = "1";
    const track = root.querySelector("[data-mrail-track]");
    const cards = track ? [...track.children] : [];
    if (!cards.length) return;
    const prev = root.querySelector("[data-mrail-prev]");
    const next = root.querySelector("[data-mrail-next]");
    const counter = root.querySelector("[data-mrail-counter]");

    const step = () => cards[0].getBoundingClientRect().width + (parseFloat(getComputedStyle(track).columnGap) || 0);
    const visibleCount = () => Math.max(1, Math.round(track.clientWidth / step()));
    const currentIndex = () => Math.max(0, Math.round(track.scrollLeft / step()));
    function update() {
      const first = currentIndex();
      const last = Math.min(cards.length, first + visibleCount());
      if (counter) counter.textContent = `${pad(first + 1)}–${pad(last)} / ${pad(cards.length)}`;
      if (prev) prev.disabled = track.scrollLeft < 2;
      if (next) next.disabled = track.scrollLeft + track.clientWidth >= track.scrollWidth - 2;
    }
    function move(direction) {
      const target = Math.max(0, Math.min(cards.length - 1, currentIndex() + direction * visibleCount()));
      const instant = matchMedia("(prefers-reduced-motion: reduce)").matches;
      track.scrollTo({ left: cards[target].offsetLeft - cards[0].offsetLeft, behavior: instant ? "instant" : "smooth" });
    }
    if (prev) prev.addEventListener("click", () => move(-1));
    if (next) next.addEventListener("click", () => move(1));
    track.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    update();
  }

  document.querySelectorAll("[data-mrail]").forEach(setUp);
})();
