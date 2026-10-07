/* Apply the saved palette before CSS paints the PHP homepage. */
(() => {
  let theme = "dark";
  try {
    if (localStorage.getItem("meduc-theme") === "light") theme = "light";
  } catch (_) {
    // The page remains usable when storage is disabled.
  }
  document.documentElement.dataset.meducTheme = theme;
})();
