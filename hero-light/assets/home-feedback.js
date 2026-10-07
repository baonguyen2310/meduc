(() => {
  "use strict";

  const books = document.querySelector("body.meduc-home-v2 > .mhi-books");
  const source = [...document.querySelectorAll("body.meduc-home-v2 > [nh-row]")].find((row) =>
    row.querySelector("h3.title")?.textContent.trim() === "Cảm Nhận Của Học Viên" &&
    row.querySelector('a[href*="youtube.com/watch"]')
  );
  if (!books || !source) return;

  const videoMeta = {
    "g9wXdFv1mTw": { title: "Phản hồi khóa học Giải phẫu, Tiếng Anh Y khoa", subject: "Giải phẫu · Tiếng Anh Y khoa" },
    "mvoFlFPB-rE": { title: "Phản hồi khóa học Sinh lý", subject: "Sinh lý" },
    "YfhMZ9LwkZo": { title: "Phản hồi khóa học Giải phẫu", subject: "Giải phẫu" },
    "sJDkfvW7oxk": { title: "Phản hồi khóa học Sinh lý", subject: "Sinh lý" },
    "OlefssQgsXY": { title: "Phản hồi khóa học Tiếng Anh Y khoa", subject: "Tiếng Anh Y khoa" },
    "bn_BJlYt9jI": { title: "Phản hồi khóa học Sinh lý", subject: "Sinh lý" },
  };
  const seen = new Set();
  const videos = [...source.querySelectorAll('a[href*="youtube.com/watch"]')].map((link) => {
    let id = "";
    try { id = new URL(link.href).searchParams.get("v") || ""; } catch (_) {}
    if (!/^[\w-]{11}$/.test(id) || seen.has(id)) return null;
    seen.add(id);
    const image = link.querySelector(".thumbnail img");
    return {
      id,
      url: link.href,
      title: videoMeta[id]?.title || link.querySelector(".hover-text .title")?.textContent.trim() || image?.alt?.trim() || "Cảm nhận học viên MedUC",
      subject: videoMeta[id]?.subject || "Hành trình học Y",
      image: image?.getAttribute("data-src") || image?.getAttribute("src") || `https://img.youtube.com/vi/${id}/sddefault.jpg`,
    };
  }).filter(Boolean);
  // Slick may prepend cloned slides; restore the order of the six PHP source videos.
  const order = Object.keys(videoMeta);
  const rank = (id) => {
    const index = order.indexOf(id);
    return index < 0 ? order.length : index;
  };
  videos.sort((a, b) => rank(a.id) - rank(b.id));
  if (!videos.length) return;

  const section = document.createElement("section");
  section.className = "mhi-voices";
  section.setAttribute("aria-labelledby", "mhi-voices-title");
  section.innerHTML = `
    <div class="mhi-voices-shell">
      <div class="mhi-voices-heading">
        <div>
          <p class="mhi-voices-kicker">CẢM NHẬN CỦA HỌC VIÊN</p>
          <h2 id="mhi-voices-title">HỌC THẬT.<br><span>CẢM NHẬN THẬT.</span></h2>
        </div>
        <p>Nghe chính người học chia sẻ về hành trình học Y cùng MedUC.</p>
      </div>
      <div class="mhi-voices-rail" aria-label="Video cảm nhận của học viên" tabindex="0"></div>
      <div class="mhi-voices-footer">
        <a href="/phan-hoi-hoc-vien-v2">Xem tất cả cảm nhận <span aria-hidden="true">↗</span></a>
        <div class="mhi-voices-controls">
          <span class="mhi-voices-counter" aria-live="polite"></span>
          <button type="button" class="mhi-voices-prev" aria-label="Xem video trước">←</button>
          <button type="button" class="mhi-voices-next" aria-label="Xem video tiếp theo">→</button>
        </div>
      </div>
    </div>
    <dialog class="mhi-voices-dialog" aria-labelledby="mhi-voices-dialog-title">
      <button type="button" class="mhi-voices-close" aria-label="Đóng video">×</button>
      <div class="mhi-voices-player"></div>
      <div class="mhi-voices-dialog-info">
        <div><span>VIDEO CẢM NHẬN · MEDUC</span><h3 id="mhi-voices-dialog-title"></h3></div>
        <a href="#" target="_blank" rel="noopener noreferrer">Mở trên YouTube ↗</a>
      </div>
    </dialog>`;

  const rail = section.querySelector(".mhi-voices-rail");
  videos.forEach((video, index) => {
    const article = document.createElement("article");
    article.className = "mhi-voices-card";
    const play = document.createElement("button");
    play.type = "button";
    play.className = "mhi-voices-poster";
    play.setAttribute("aria-label", `Phát video ${video.title}: ${video.subject}`);
    const image = document.createElement("img");
    image.src = video.image;
    image.alt = "";
    image.loading = "lazy";
    image.decoding = "async";
    image.addEventListener("error", () => image.remove());
    const fallback = document.createElement("span");
    fallback.className = "mhi-voices-fallback";
    fallback.textContent = "MEDUC · CẢM NHẬN HỌC VIÊN";
    const playIcon = document.createElement("span");
    playIcon.className = "mhi-voices-play-icon";
    playIcon.setAttribute("aria-hidden", "true");
    playIcon.textContent = "▶";
    const corner = document.createElement("span");
    corner.className = "mhi-voices-corner";
    corner.textContent = "MEDUC / HỌC VIÊN";
    play.append(image, fallback, playIcon, corner);
    play.addEventListener("click", () => openVideo(video));

    const meta = document.createElement("div");
    meta.className = "mhi-voices-meta";
    const number = document.createElement("span");
    number.className = "mhi-voices-number";
    number.textContent = String(index + 1).padStart(2, "0");
    const copy = document.createElement("div");
    const subject = document.createElement("span");
    subject.className = "mhi-voices-subject";
    subject.textContent = video.subject;
    const title = document.createElement("h3");
    title.textContent = video.title;
    copy.append(subject, title);
    meta.append(number, copy);
    article.append(play, meta);
    rail.append(article);
  });

  books.after(section);
  source.remove();

  const dialog = section.querySelector(".mhi-voices-dialog");
  const player = dialog.querySelector(".mhi-voices-player");
  const dialogTitle = dialog.querySelector("h3");
  const youtubeLink = dialog.querySelector(".mhi-voices-dialog-info a");
  function openVideo(video) {
    dialogTitle.textContent = video.title;
    youtubeLink.href = video.url;
    const frame = document.createElement("iframe");
    frame.src = `https://www.youtube-nocookie.com/embed/${video.id}?autoplay=1&rel=0`;
    frame.title = video.title;
    frame.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
    frame.allowFullscreen = true;
    player.replaceChildren(frame);
    dialog.showModal();
  }
  dialog.querySelector(".mhi-voices-close").addEventListener("click", () => dialog.close());
  dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close(); });
  dialog.addEventListener("close", () => player.replaceChildren());

  const prev = section.querySelector(".mhi-voices-prev");
  const next = section.querySelector(".mhi-voices-next");
  const counter = section.querySelector(".mhi-voices-counter");
  const cards = [...rail.children];
  const visibleCount = () => Math.max(1, Math.round(rail.clientWidth / (cards[0].getBoundingClientRect().width + 14)));
  const currentIndex = () => {
    const cardWidth = cards[0].getBoundingClientRect().width + 14;
    return Math.max(0, Math.round(rail.scrollLeft / cardWidth));
  };
  const updateControls = () => {
    const first = currentIndex();
    const last = Math.min(videos.length, first + visibleCount());
    counter.textContent = `${String(first + 1).padStart(2, "0")}–${String(last).padStart(2, "0")} / ${String(videos.length).padStart(2, "0")}`;
    prev.disabled = rail.scrollLeft < 2;
    next.disabled = rail.scrollLeft + rail.clientWidth >= rail.scrollWidth - 2;
  };
  const move = (direction) => {
    const target = Math.max(0, Math.min(cards.length - 1, currentIndex() + direction * visibleCount()));
    rail.scrollTo({ left: cards[target].offsetLeft - cards[0].offsetLeft, behavior: matchMedia("(prefers-reduced-motion: reduce)").matches ? "instant" : "smooth" });
  };
  prev.addEventListener("click", () => move(-1));
  next.addEventListener("click", () => move(1));
  rail.addEventListener("scroll", updateControls, { passive: true });
  window.addEventListener("resize", updateControls);
  updateControls();
})();
