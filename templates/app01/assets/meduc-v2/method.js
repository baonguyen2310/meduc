/* Teaching method banner (block/slider/view_method_feature.tpl): the video button plays the YouTube video
   inside the large frame; the close button or Escape brings the picture back. */
(() => {
  "use strict";
  document.querySelectorAll(".mcl").forEach((section) => {
    const button = section.querySelector("[data-mcl-video]");
    const player = section.querySelector(".mcl-player");
    if (!button || !player || section.dataset.mclReady) return;
    section.dataset.mclReady = "1";
    const frame = player.querySelector(".mcl-frame");
    const close = player.querySelector(".mcl-close");

    function stop() {
      frame.replaceChildren();
      player.hidden = true;
      button.focus();
    }
    button.addEventListener("click", (event) => {
      event.preventDefault();
      const iframe = document.createElement("iframe");
      iframe.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(button.dataset.mclVideo)}?autoplay=1&rel=0`;
      iframe.title = section.querySelector(".mcl-title")?.textContent || "Video MedUC";
      iframe.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
      iframe.allowFullscreen = true;
      frame.replaceChildren(iframe);
      player.hidden = false;
      close.focus();
    });
    close.addEventListener("click", stop);
    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && !player.hidden) stop();
    });
  });
})();
