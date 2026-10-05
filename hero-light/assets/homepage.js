(() => {
  "use strict";

  const tabs = [...document.querySelectorAll(".category-tab")];
  const cards = [...document.querySelectorAll(".subject-card")];
  const status = document.querySelector("#filter-status");

  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      const filter = tab.dataset.filter;
      tabs.forEach((item) => {
        const selected = item === tab;
        item.classList.toggle("is-active", selected);
        item.setAttribute("aria-pressed", String(selected));
      });
      let visible = 0;
      cards.forEach((card) => {
        const show = filter === "all" || card.dataset.category === filter;
        card.hidden = !show;
        if (show) visible += 1;
      });
      status.textContent = `Đang xem ${visible} chủ đề.`;
    });
  });
})();
