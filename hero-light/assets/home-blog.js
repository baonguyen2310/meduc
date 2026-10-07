(() => {
  "use strict";

  const voices = document.querySelector("body.meduc-home-v2 > .mhi-voices");
  const source = [...document.querySelectorAll("body.meduc-home-v2 > [nh-row]")].find((row) =>
    row.querySelector("h3.title")?.textContent.trim() === "Danh Sách Bài Viết" &&
    row.querySelector(".edu-card .thumbnail a[href]")
  );
  if (!voices || !source) return;

  // Read the homepage's selected PHP articles. Slick can add cloned slides around them.
  const seen = new Set();
  const articles = [...source.querySelectorAll(".edu-card")].filter((card) => !card.closest(".slick-cloned")).map((card) => {
    const link = card.querySelector(".thumbnail a[href]");
    const title = card.querySelector(".content h6.title a")?.textContent.trim() || link?.getAttribute("title")?.trim();
    const href = link?.getAttribute("href");
    if (!title || !href || seen.has(href)) return null;
    seen.add(href);
    const image = card.querySelector(".thumbnail img");
    return {
      title,
      href,
      image: image?.getAttribute("data-src") || image?.getAttribute("src") || "",
      summary: card.querySelector(".inner-desc")?.textContent.replace(/\s+/g, " ").trim() || "",
      order: Number(card.getAttribute("data-slick-index")),
    };
  }).filter(Boolean).sort((a, b) => a.order - b.order);
  if (!articles.length) return;

  const section = document.createElement("section");
  section.className = "mhi-home-blog";
  section.setAttribute("aria-labelledby", "mhi-home-blog-title");
  section.innerHTML = `
    <div class="mhi-home-blog-shell">
      <div class="mhi-home-blog-heading">
        <div>
          <p class="mhi-home-blog-kicker">GÓC HỌC TẬP MEDUC</p>
          <h2 id="mhi-home-blog-title">ĐỌC MỘT BÀI.<br><span>HIỂU THÊM MỘT ĐIỀU.</span></h2>
        </div>
        <p>Những bài viết Y khoa được chọn từ MedUC, giúp bạn mở rộng kiến thức và tìm thêm góc nhìn cho việc học.</p>
      </div>
      <div class="mhi-home-blog-grid"></div>
      <a class="mhi-home-blog-all" href="/blog-v2">Xem tất cả bài viết <span aria-hidden="true">→</span></a>
    </div>`;

  const grid = section.querySelector(".mhi-home-blog-grid");
  articles.forEach((item, index) => {
    const article = document.createElement("article");
    article.className = "mhi-home-blog-card";

    const imageLink = document.createElement("a");
    imageLink.className = "mhi-home-blog-image";
    imageLink.href = item.href;
    imageLink.setAttribute("aria-label", `Đọc ${item.title}`);
    const fallback = document.createElement("span");
    fallback.className = "mhi-home-blog-fallback";
    fallback.textContent = "MEDUC JOURNAL";
    imageLink.append(fallback);
    if (item.image) {
      const image = document.createElement("img");
      image.src = item.image;
      image.alt = `Ảnh minh họa bài viết ${item.title}`;
      image.loading = "lazy";
      image.decoding = "async";
      image.addEventListener("error", () => { image.remove(); imageLink.classList.add("is-empty"); });
      imageLink.append(image);
    } else imageLink.classList.add("is-empty");

    const body = document.createElement("div");
    body.className = "mhi-home-blog-card-body";
    const meta = document.createElement("span");
    meta.className = "mhi-home-blog-meta";
    meta.textContent = `MEDUC JOURNAL · ${String(index + 1).padStart(2, "0")}`;
    const title = document.createElement("h3");
    const titleLink = document.createElement("a");
    titleLink.href = item.href;
    titleLink.textContent = item.title;
    title.append(titleLink);
    const summary = document.createElement("p");
    summary.textContent = item.summary;
    const detail = document.createElement("a");
    detail.className = "mhi-home-blog-detail";
    detail.href = item.href;
    detail.innerHTML = 'Đọc bài viết <span aria-hidden="true">→</span>';
    body.append(meta, title, summary, detail);
    article.append(imageLink, body);
    grid.append(article);
  });

  voices.after(section);
  source.remove();
})();
