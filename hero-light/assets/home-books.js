(() => {
  "use strict";

  const catalog = document.querySelector("body.meduc-home-v2 > .mhi-featured-catalog");
  const source = [...document.querySelectorAll("body.meduc-home-v2 > [nh-row]")].find((row) =>
    row.querySelector("h3.title")?.textContent.trim() === "Top Đầu Sách Y Khoa Chất Lượng" &&
    row.querySelector(".edu-card[nh-product]")
  );
  if (!catalog || !source) return;

  // Keep the PHP homepage's selected books, prices, and product links as the source of truth.
  const books = [...source.querySelectorAll(".edu-card[nh-product]")].map((card) => {
    const originalLink = card.querySelector(".thumbnail a[href]");
    const image = card.querySelector(".thumbnail img");
    return {
      id: Number(card.getAttribute("nh-product")),
      name: originalLink?.getAttribute("title")?.trim() || card.querySelector(".content .title")?.textContent.trim() || "Sách Y khoa MedUC",
      href: originalLink?.getAttribute("href") || "/sach-y-khoa-v2",
      image: image?.getAttribute("data-src") || image?.getAttribute("src") || "",
      price: card.querySelector(".current-price")?.textContent.trim() || "",
      oldPrice: card.querySelector(".old-price")?.textContent.trim() || "",
    };
  });
  if (!books.length) return;

  const section = document.createElement("section");
  section.className = "mhi-books";
  section.setAttribute("aria-labelledby", "mhi-books-title");
  section.innerHTML = `
    <div class="mhi-books-shell">
      <div class="mhi-books-heading">
        <div>
          <p class="mhi-books-kicker">DANH MỤC ĐANG MỞ</p>
          <h2 id="mhi-books-title">TÌM CUỐN SÁCH<br><span>BẠN CẦN.</span></h2>
        </div>
        <p>Top đầu sách Y khoa chất lượng tại MedUC. Chọn bìa sách để xem thông tin chi tiết.</p>
      </div>
      <div class="mhi-books-grid"></div>
      <a class="mhi-books-all" href="/sach-y-khoa-v2">Xem tất cả sách <span aria-hidden="true">→</span></a>
    </div>`;
  const grid = section.querySelector(".mhi-books-grid");

  books.forEach((book) => {
    const article = document.createElement("article");
    article.className = "mhi-books-card";
    article.dataset.bookId = String(book.id);

    const cover = document.createElement("a");
    cover.className = "mhi-books-cover";
    cover.href = book.href;
    cover.setAttribute("aria-label", `Xem chi tiết sách ${book.name}`);
    const fallback = document.createElement("b");
    fallback.className = "mhi-books-fallback";
    fallback.textContent = book.name;
    cover.append(fallback);
    if (book.image) {
      const image = document.createElement("img");
      image.src = book.image;
      image.alt = `Bìa sách ${book.name}`;
      image.loading = "lazy";
      image.decoding = "async";
      image.dataset.originalSrc = book.image;
      image.addEventListener("error", () => {
        if (image.src !== image.dataset.originalSrc) image.src = image.dataset.originalSrc;
        else { image.remove(); cover.classList.add("is-empty"); }
      });
      cover.append(image);
    } else cover.classList.add("is-empty");

    const body = document.createElement("div");
    body.className = "mhi-books-card-body";
    const subject = document.createElement("span");
    subject.className = "mhi-books-subject";
    subject.textContent = "SÁCH Y KHOA";
    const title = document.createElement("h3");
    title.textContent = book.name;
    const prices = document.createElement("div");
    prices.className = "mhi-books-prices";
    if (book.price) {
      const current = document.createElement("strong");
      current.textContent = book.price;
      prices.append(current);
      if (book.oldPrice) {
        const old = document.createElement("del");
        old.textContent = book.oldPrice;
        prices.append(old);
      }
    } else prices.textContent = "Xem giá trên MedUC";
    const detail = document.createElement("a");
    detail.className = "mhi-books-detail";
    detail.href = book.href;
    detail.textContent = "Xem chi tiết sách";
    const arrow = document.createElement("span");
    arrow.setAttribute("aria-hidden", "true");
    arrow.textContent = "→";
    detail.append(arrow);
    body.append(subject, title, prices, detail);
    article.append(cover, body);
    grid.append(article);
  });

  // The original PHP row remains available if this script cannot complete.
  catalog.after(section);
  source.remove();

  const subjectFor = (categories) => {
    if (categories.includes(81)) return "SINH LÝ";
    if (categories.includes(83)) return "GIẢI PHẪU";
    if (categories.includes(84)) return "NỘI KHOA";
    if (categories.includes(86)) return "TIẾNG ANH Y KHOA";
    return "CHỦ ĐỀ KHÁC";
  };
  fetch("/hero-light/assets/book-catalog.json")
    .then((response) => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.json();
    })
    .then((data) => {
      const byID = new Map((data.books || []).map((book) => [book.id, book]));
      grid.querySelectorAll(".mhi-books-card").forEach((card) => {
        const book = byID.get(Number(card.dataset.bookId));
        if (!book) return;
        card.querySelector(".mhi-books-subject").textContent = subjectFor(book.categories || []);
        const image = card.querySelector(".mhi-books-cover img");
        if (image && book.image) image.src = book.image;
      });
    })
    .catch(() => {});
})();
