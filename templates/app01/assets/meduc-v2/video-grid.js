/* Student video grid (block/slider/view_video_grid.tpl): subject filters and "show more".
   Without JavaScript every video stays visible and the filters stay hidden. */
(() => {
  "use strict";
  document.querySelectorAll("[data-mvd-grid]").forEach((section) => {
    if (section.dataset.mvdGridReady) return;
    section.dataset.mvdGridReady = "1";
    const cards = [...section.querySelectorAll(".mvd-grid > .mvd-card")];
    const filters = [...section.querySelectorAll("[data-mvd-filter]")];
    const filterBar = section.querySelector(".mvd-filters");
    const more = section.querySelector(".mvd-more");
    const status = section.querySelector(".mvd-status");
    const pageSize = Math.max(1, Number(section.dataset.mvdPage) || 6);
    let subject = "";
    let visible = pageSize;

    function render() {
      const matching = cards.filter((card) => !subject || card.dataset.mvdSubject === subject);
      cards.forEach((card) => { card.hidden = true; });
      matching.slice(0, visible).forEach((card) => { card.hidden = false; });
      const shown = Math.min(visible, matching.length);
      if (status) status.textContent = `Đang hiển thị ${shown} / ${matching.length} video.`;
      if (more) more.hidden = shown >= matching.length;
    }

    filters.forEach((button) => button.addEventListener("click", () => {
      subject = button.dataset.mvdFilter;
      visible = pageSize;
      filters.forEach((other) => other.setAttribute("aria-pressed", String(other === button)));
      render();
    }));
    if (more) more.addEventListener("click", () => {
      const firstNew = cards.filter((card) => card.hidden && (!subject || card.dataset.mvdSubject === subject))[0];
      visible += pageSize;
      render();
      // Move focus to the first newly shown video so keyboard users continue from there.
      firstNew?.querySelector(".mvd-poster")?.focus();
    });
    if (filterBar) filterBar.hidden = false;
    render();
  });
})();
