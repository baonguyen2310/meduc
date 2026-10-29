/* Bottom action bar (element/layout/action_bar.tpl): slides in after a little scrolling, plus the gift menu. */
(() => {
  "use strict";
  const bar = document.querySelector("#meduc-action-bar");
  if (!bar) return;
  const root = document.documentElement;

  // The page keeps room for the bar, and floating buttons move above it, using its real height.
  const setHeight = () => root.style.setProperty("--mhb-h", `${bar.offsetHeight}px`);
  setHeight();
  if ("ResizeObserver" in window) new ResizeObserver(() => { setHeight(); scheduleUpdate(); }).observe(bar);
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

  // A small gap between show/hide thresholds avoids flicker around the boundary.
  const showAfter = 320, hideBefore = 280;
  let shown = false, pendingFrame = false;
  function update() {
    pendingFrame = false;
    const visible = getComputedStyle(bar).display !== "none" && bar.offsetHeight > 0;
    const next = visible && window.scrollY > (shown ? hideBefore : showAfter);
    if (next === shown) return;
    shown = next;
    bar.classList.toggle("is-shown", shown);
    document.body.classList.toggle("mhb-on", shown);
    if (!shown) setGift(false);
    document.dispatchEvent(new CustomEvent("meduc:action-bar", {detail:{shown}}));
  }
  function scheduleUpdate() {
    if (pendingFrame) return;
    pendingFrame = true;
    requestAnimationFrame(update);
  }
  window.addEventListener("scroll", scheduleUpdate, {passive:true});
  window.addEventListener("resize", scheduleUpdate);
  window.addEventListener("pageshow", scheduleUpdate);
  update();
})();
