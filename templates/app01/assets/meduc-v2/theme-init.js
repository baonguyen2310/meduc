/* Apply the saved palette before the header CSS paints. */
(() => {
  let theme = "dark";
  try {
    if (localStorage.getItem("meduc-theme") === "light") theme = "light";
  } catch (_) {
    // The page remains usable when storage is disabled.
  }
  document.documentElement.dataset.meducTheme = theme;
})();
