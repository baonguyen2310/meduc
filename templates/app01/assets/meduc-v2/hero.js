/* Free gifts in the homepage hero. */
(() => {
  "use strict";
  document.querySelectorAll(".mhw-gift").forEach((box) => {
    const button = box.querySelector("button");
    const menu = box.querySelector("nav");
    const links = [...menu.querySelectorAll("a")];
    function setOpen(open) {
      menu.hidden = !open;
      button.setAttribute("aria-expanded", String(open));
    }
    button.addEventListener("click", () => setOpen(menu.hidden));
    button.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
      event.preventDefault();
      setOpen(true);
      links[event.key === "ArrowUp" ? links.length - 1 : 0].focus();
    });
    document.addEventListener("click", (event) => {
      if (!box.contains(event.target)) setOpen(false);
    });
    document.addEventListener("focusin", (event) => {
      if (!box.contains(event.target)) setOpen(false);
    });
    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && !menu.hidden) {
        setOpen(false);
        button.focus();
      }
    });
  });
})();
