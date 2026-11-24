/* Bottom shortcuts and their disclosure menus. */
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

  const menus = [...bar.querySelectorAll("[data-mhb-menu]")].map((wrap) => ({
    wrap,
    button: wrap.querySelector("button[aria-controls]"),
    panel: wrap.querySelector(".mhb-menu")
  }));
  let openMenu = null;
  function showMenu(menu) {
    if (openMenu) {
      openMenu.panel.hidden = true;
      openMenu.button.setAttribute("aria-expanded", "false");
    }
    openMenu = menu;
    if (openMenu) {
      openMenu.panel.hidden = false;
      openMenu.button.setAttribute("aria-expanded", "true");
    }
  }
  menus.forEach((menu) => {
    menu.button.addEventListener("click", () => showMenu(openMenu === menu ? null : menu));
  });
  function closeOutsideMenu(event) {
    if (openMenu && !openMenu.wrap.contains(event.target)) showMenu(null);
  }
  document.addEventListener("click", closeOutsideMenu);
  document.addEventListener("focusin", closeOutsideMenu);
  bar.addEventListener("keydown", (event) => {
    if (event.key !== "Escape" || !openMenu) return;
    event.preventDefault();
    event.stopPropagation();
    const {button} = openMenu;
    showMenu(null);
    button.focus();
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
    if (!shown) showMenu(null);
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
