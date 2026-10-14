/* Site header behaviour ported from the main branch (hero-light/assets/original-home.js). */
(() => {
  "use strict";
  const root = document.querySelector("#meduc-header");
  if (!root) return;
  const $ = (selector) => root.querySelector(selector);
  const $$ = (selector) => [...root.querySelectorAll(selector)];

  // Boxes that older scripts pin while scrolling read this to stay below the sticky part of the header.
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

  const browseButton = $("#mhi-browse-button");
  const browseMenu = $("#mhi-browse-menu");
  function setBrowse(open) {
    browseMenu.hidden = !open;
    browseButton.setAttribute("aria-expanded", String(open));
  }
  browseButton.addEventListener("click", () => setBrowse(browseMenu.hidden));

  const networkDropdowns = $$(".mhi-network-dropdown");
  function setNetworkDropdown(dropdown, open) {
    const button = dropdown.querySelector("button");
    const menu = dropdown.querySelector(".mhi-network-menu");
    menu.hidden = !open;
    button.setAttribute("aria-expanded", String(open));
  }
  networkDropdowns.forEach((dropdown) => {
    dropdown.querySelector("button").addEventListener("click", () => {
      const open = dropdown.querySelector(".mhi-network-menu").hidden;
      networkDropdowns.forEach((item) => setNetworkDropdown(item, item === dropdown && open));
    });
  });

  // Mobile: the search box opens below the single header row.
  const searchToggle = $("#mhi-search-toggle");
  const searchForm = $("#mhi-search-form");
  function setSearch(open) {
    root.classList.toggle("is-search-open", open);
    searchToggle.setAttribute("aria-expanded", String(open));
    if (open) $("#mhi-search-input").focus();
  }
  searchToggle.addEventListener("click", () => setSearch(!root.classList.contains("is-search-open")));

  // Mobile: the menu button opens a side panel with every link.
  const menuToggle = $("#mhi-menu-toggle");
  const drawer = $("#mhi-drawer");
  function setDrawer(open) {
    drawer.hidden = !open;
    menuToggle.setAttribute("aria-expanded", String(open));
    document.documentElement.classList.toggle("mhi-scroll-lock", open);
    if (open) drawer.querySelector("[data-mhi-drawer-close]:not(.mhi-drawer-backdrop)").focus();
    else menuToggle.focus();
  }
  menuToggle.addEventListener("click", () => setDrawer(true));
  $$("[data-mhi-drawer-close]").forEach((element) => element.addEventListener("click", () => setDrawer(false)));
  window.matchMedia("(min-width: 992px)").addEventListener("change", (event) => {
    if (event.matches && !drawer.hidden) setDrawer(false);
    if (event.matches) setSearch(false);
  });

  document.addEventListener("click", (event) => {
    if (!browseMenu.hidden && !browseMenu.contains(event.target) && !browseButton.contains(event.target)) setBrowse(false);
    networkDropdowns.forEach((dropdown) => {
      if (!dropdown.contains(event.target)) setNetworkDropdown(dropdown, false);
    });
    if (root.classList.contains("is-search-open") && !searchForm.contains(event.target) && !searchToggle.contains(event.target)) setSearch(false);
  });
  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    if (!drawer.hidden) {
      setDrawer(false);
      return;
    }
    if (root.classList.contains("is-search-open")) {
      setSearch(false);
      searchToggle.focus();
    }
    if (!browseMenu.hidden) {
      setBrowse(false);
      browseButton.focus();
    }
    networkDropdowns.forEach((dropdown) => {
      if (!dropdown.querySelector(".mhi-network-menu").hidden) {
        setNetworkDropdown(dropdown, false);
        dropdown.querySelector("button").focus();
      }
    });
  });
})();
