/* Shared desktop category menus and mobile navigation. */
(() => {
  "use strict";
  const root = document.querySelector("#meduc-header");
  if (!root) return;
  const $ = (selector) => root.querySelector(selector);
  const $$ = (selector) => [...root.querySelectorAll(selector)];

  const network = $(".mhi-network");
  function setHeaderHeight() {
    const scrolledAway = getComputedStyle(network).display === "none" ? 0 : network.offsetHeight;
    document.documentElement.style.setProperty("--mhi-header-h", `${root.offsetHeight - scrolledAway}px`);
  }
  setHeaderHeight();
  if ("ResizeObserver" in window) new ResizeObserver(setHeaderHeight).observe(root);
  window.addEventListener("resize", setHeaderHeight);

  const themeButtons = $$("[data-mhi-theme-toggle]");
  function updateThemeButtons() {
    const dark = document.documentElement.dataset.meducTheme !== "light";
    const label = dark ? "Chuyển sang chế độ sáng" : "Chuyển sang chế độ tối";
    themeButtons.forEach((button) => {
      button.setAttribute("aria-label", label);
      button.setAttribute("aria-pressed", String(dark));
      button.title = label;
    });
  }
  updateThemeButtons();
  themeButtons.forEach((button) => button.addEventListener("click", () => {
    const next = document.documentElement.dataset.meducTheme === "light" ? "dark" : "light";
    document.documentElement.dataset.meducTheme = next;
    try { localStorage.setItem("meduc-theme", next); } catch (_) { /* Storage may be disabled. */ }
    updateThemeButtons();
  }));

  const dropdowns = $$("[data-mhi-dropdown], .mhi-network-dropdown").map((wrap) => ({
    wrap,
    button: wrap.querySelector("button[aria-controls]"),
    menu: wrap.querySelector("nav")
  })).filter((item) => item.button && item.menu);
  function setDropdown(item, open) {
    item.menu.hidden = !open;
    item.button.setAttribute("aria-expanded", String(open));
  }
  function closeDropdowns(except = null) {
    dropdowns.forEach((item) => { if (item !== except) setDropdown(item, false); });
  }
  dropdowns.forEach((item) => {
    item.button.addEventListener("click", () => {
      const open = item.menu.hidden;
      closeDropdowns();
      setDropdown(item, open);
    });
    item.button.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
      event.preventDefault();
      closeDropdowns(item);
      setDropdown(item, true);
      const links = [...item.menu.querySelectorAll("a[href]")];
      (event.key === "ArrowUp" ? links.at(-1) : links[0])?.focus();
    });
    item.menu.addEventListener("keydown", (event) => {
      const links = [...item.menu.querySelectorAll("a[href]")];
      const index = links.indexOf(document.activeElement);
      let next;
      if (event.key === "ArrowDown") next = (index + 1) % links.length;
      if (event.key === "ArrowUp") next = (index - 1 + links.length) % links.length;
      if (event.key === "Home") next = 0;
      if (event.key === "End") next = links.length - 1;
      if (next === undefined || !links.length) return;
      event.preventDefault();
      links[next].focus();
    });
  });

  const searchToggle = $("#mhi-search-toggle");
  const searchForm = $("#mhi-search-form");
  function setSearch(open) {
    root.classList.toggle("is-search-open", open);
    searchToggle.setAttribute("aria-expanded", String(open));
    if (open) { closeDropdowns(); $("#mhi-search-input").focus(); }
  }
  searchToggle.addEventListener("click", () => setSearch(!root.classList.contains("is-search-open")));

  const menuToggle = $("#mhi-menu-toggle");
  const drawer = $("#mhi-drawer");
  function setDrawer(open) {
    drawer.hidden = !open;
    menuToggle.setAttribute("aria-expanded", String(open));
    document.documentElement.classList.toggle("mhi-scroll-lock", open);
    if (open) {
      closeDropdowns();
      setSearch(false);
      drawer.querySelector("button[data-mhi-drawer-close]").focus();
    } else menuToggle.focus();
  }
  menuToggle.addEventListener("click", () => setDrawer(true));
  $$("[data-mhi-drawer-close]").forEach((element) => element.addEventListener("click", () => setDrawer(false)));
  window.matchMedia("(min-width: 992px)").addEventListener("change", (event) => {
    closeDropdowns();
    if (event.matches && !drawer.hidden) setDrawer(false);
    if (event.matches) setSearch(false);
  });

  document.addEventListener("click", (event) => {
    dropdowns.forEach((item) => { if (!item.wrap.contains(event.target)) setDropdown(item, false); });
    if (root.classList.contains("is-search-open") && !searchForm.contains(event.target) && !searchToggle.contains(event.target)) setSearch(false);
  });
  document.addEventListener("focusin", (event) => {
    dropdowns.forEach((item) => { if (!item.wrap.contains(event.target)) setDropdown(item, false); });
  });
  document.addEventListener("keydown", (event) => {
    if (!drawer.hidden && event.key === "Tab") {
      const focusable = [...drawer.querySelectorAll("a[href], button, summary")].filter((el) => el.getClientRects().length);
      const first = focusable[0], last = focusable.at(-1);
      if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last?.focus(); }
      else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first?.focus(); }
    }
    if (event.key !== "Escape") return;
    if (!drawer.hidden) { setDrawer(false); return; }
    if (root.classList.contains("is-search-open")) { setSearch(false); searchToggle.focus(); }
    const open = dropdowns.find((item) => !item.menu.hidden);
    if (open) { setDropdown(open, false); open.button.focus(); }
  });
})();
