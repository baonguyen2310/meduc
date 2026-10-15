/* Student video feedback (block/slider/view_video_feedback.tpl): a poster opens its YouTube video in the pop-up player.
   Without JavaScript or <dialog> support the posters stay plain links to YouTube. */
(() => {
  "use strict";
  document.querySelectorAll(".mvd").forEach((section) => {
    const dialog = section.querySelector(".mvd-dialog");
    if (!dialog || typeof dialog.showModal !== "function" || dialog.dataset.mvdReady) return;
    dialog.dataset.mvdReady = "1";
    const player = dialog.querySelector(".mvd-player");
    const title = dialog.querySelector("#mvd-dialog-title");
    const youtubeLink = dialog.querySelector(".mvd-dialog-info a");

    section.querySelectorAll("[data-mvd-video]").forEach((poster) => {
      poster.addEventListener("click", (event) => {
        event.preventDefault();
        const id = poster.dataset.mvdVideo;
        title.textContent = poster.dataset.mvdTitle || "";
        youtubeLink.href = poster.href;
        const frame = document.createElement("iframe");
        frame.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(id)}?autoplay=1&rel=0`;
        frame.title = poster.dataset.mvdTitle || "Video cảm nhận học viên";
        frame.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
        frame.allowFullscreen = true;
        player.replaceChildren(frame);
        dialog.showModal();
      });
    });
    dialog.querySelector(".mvd-close").addEventListener("click", () => dialog.close());
    // A click on the dark backdrop lands on the dialog element itself.
    dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close(); });
    // Removing the player stops the video.
    dialog.addEventListener("close", () => player.replaceChildren());
  });
})();
