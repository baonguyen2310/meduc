/* Bottom action bar (element/layout/action_bar.tpl): slides in after a little scrolling, plus the gift menu. */
(() => {
  "use strict";
  const bar = document.querySelector("#meduc-action-bar");
  if (!bar) return;
  const root = document.documentElement;

  // The page keeps room for the bar, and floating buttons move above it, using its real height.
  const setHeight = () => root.style.setProperty("--mhb-h", `${bar.offsetHeight}px`);
  setHeight();
  if ("ResizeObserver" in window) new ResizeObserver(setHeight).observe(bar);
  document.body.classList.add("mhb-ready");

  const giftBox = bar.querySelector(".mhb-gift");
  const giftButton = giftBox.querySelector("button");
  const giftMenu = bar.querySelector("#mhb-gift-menu");
  function setGift(open) {
    giftMenu.hidden = !open;
    giftButton.setAttribute("aria-expanded", String(open));
  }
  giftButton.addEventListener("click", () => setGift(giftMenu.hidden));
  document.addEventListener("click", (event) => {
    if (!giftMenu.hidden && !giftBox.contains(event.target)) setGift(false);
  });
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !giftMenu.hidden) {
      setGift(false);
      giftButton.focus();
    }
  });

  // Like MasterClass, the bar appears once the page has scrolled a little.
  const showAfter = 320;
  let shown = false;
  function update() {
    const next = window.scrollY > showAfter;
    if (next === shown) return;
    shown = next;
    bar.classList.toggle("is-shown", shown);
    document.body.classList.toggle("mhb-on", shown);
    if (!shown) setGift(false);
  }
  window.addEventListener("scroll", update, { passive: true });
  update();
})();
