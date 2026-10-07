(() => {
  "use strict";

  const rows = [...document.querySelectorAll("body.meduc-home-v2 > [nh-row]")];
  const row = rows.find((candidate) =>
    candidate.querySelector("h3.title")?.textContent.trim() === "Các Khóa Học Nổi Bật Tại MedUC" &&
    candidate.querySelector(".edu-card[nh-product]")
  );
  if (!row) return;

  const rail = row.querySelector(".row.g-4.mt--10");
  const heading = row.querySelector(".section-title");
  const cards = [...row.querySelectorAll(".edu-card[nh-product]")];
  if (!rail || !heading || !cards.length) return;

  // The PHP product cards remain the source of truth for names, prices, discounts and links.
  const featuredCourses = cards.map((card) => {
    const image = card.querySelector(".thumbnail img");
    const coverLink = card.querySelector(".thumbnail a");
    return {
      id: Number(card.getAttribute("nh-product")),
      title: coverLink?.getAttribute("title")?.trim() || card.querySelector(".content .title a")?.textContent.trim() || "Khóa học MedUC",
      href: coverLink?.getAttribute("href") || "#",
      image: image?.getAttribute("data-src") || image?.getAttribute("src") || "",
      discount: card.querySelector(".eduvibe-status")?.textContent.trim() || "",
      currentPrice: card.querySelector(".current-price")?.textContent.trim() || "",
      oldPrice: card.querySelector(".old-price")?.textContent.trim() || "",
    };
  });
  const illustrations = [
    "doctor-linh.jpg",
    "meduc-doctor-02.jpg",
    "doctor-minh.jpg",
    "professor.jpg",
    "meduc-doctor-01.jpg",
    "meduc-doctor-04.jpg",
  ];
  cards.forEach((card, index) => {
    const image = card.querySelector(".thumbnail img");
    const thumbnail = card.querySelector(".thumbnail");
    if (!image || !thumbnail) return;

    const titleLink = card.querySelector(".content .title a");
    const fullTitle = card.querySelector(".thumbnail a")?.getAttribute("title");
    if (titleLink && fullTitle) titleLink.textContent = fullTitle;
    const title = titleLink?.textContent.trim() || "khóa học";
    image.removeAttribute("nh-lazy");
    image.removeAttribute("data-src");
    image.src = `/hero-light/assets/images/${illustrations[index % illustrations.length]}`;
    image.alt = `Ảnh minh họa cho khóa học ${title}`;
    image.loading = index < 3 ? "eager" : "lazy";
    image.decoding = "async";

    const trialLink = card.querySelector(".card-bottom a");
    trialLink?.classList.remove("edu-btn", "btn-small", "btn-ani", "w-100");
    trialLink?.classList.add("mhi-featured-cta");
  });

  const kicker = document.createElement("p");
  kicker.className = "mhi-featured-kicker";
  kicker.textContent = "KHÓA HỌC MEDUC";
  const description = document.createElement("p");
  description.className = "mhi-featured-description";
  description.textContent = "Từ Y khoa cơ sở đến lâm sàng, chọn khóa học phù hợp với bạn.";
  heading.prepend(kicker);
  heading.append(description);

  const footer = document.createElement("div");
  footer.className = "mhi-featured-footer";
  const note = document.createElement("p");
  note.textContent = "Hình chân dung chỉ để minh họa; thông tin khóa học lấy từ MedUC.";
  const allCourses = document.createElement("a");
  allCourses.href = "/khoa-hoc-v2";
  allCourses.textContent = "Xem tất cả khóa học →";
  footer.append(note, allCourses);
  rail.after(footer);

  for (const attribute of [...heading.attributes]) {
    if (attribute.name.startsWith("data-sal")) heading.removeAttribute(attribute.name);
  }
  row.querySelectorAll(".sal-animate").forEach((element) => element.classList.remove("sal-animate"));
  rail.setAttribute("aria-label", "Các khóa học nổi bật của MedUC");
  row.classList.add("mhi-featured");

  const catalogSection = document.createElement("section");
  catalogSection.className = "mhi-featured-catalog";
  catalogSection.setAttribute("aria-labelledby", "mhi-featured-catalog-title");

  const catalogShell = document.createElement("div");
  catalogShell.className = "mhi-featured-catalog-shell";
  const catalogHeader = document.createElement("div");
  catalogHeader.className = "mhi-featured-catalog-header";
  const catalogHeading = document.createElement("div");
  const catalogKicker = document.createElement("p");
  catalogKicker.className = "mhi-featured-catalog-kicker";
  catalogKicker.textContent = "KHÓA HỌC NỔI BẬT";
  const catalogTitle = document.createElement("h2");
  catalogTitle.id = "mhi-featured-catalog-title";
  catalogTitle.textContent = "Khám phá khóa học MedUC";
  const catalogDescription = document.createElement("p");
  catalogDescription.className = "mhi-featured-catalog-description";
  catalogDescription.textContent = "Học từ nền tảng đến lâm sàng qua các khóa học đang được quan tâm.";
  catalogHeading.append(catalogKicker, catalogTitle, catalogDescription);
  const catalogAll = document.createElement("a");
  catalogAll.className = "mhi-featured-catalog-all";
  catalogAll.href = "/khoa-hoc-v2";
  catalogAll.textContent = "Xem tất cả khóa học →";
  catalogHeader.append(catalogHeading, catalogAll);

  const catalogGrid = document.createElement("div");
  catalogGrid.className = "mhi-featured-catalog-grid";
  featuredCourses.forEach((course) => {
    const article = document.createElement("article");
    article.className = "mhi-featured-catalog-card";
    article.dataset.courseId = String(course.id);
    const cover = document.createElement("a");
    cover.className = "mhi-featured-catalog-cover";
    cover.href = course.href;
    cover.setAttribute("aria-label", `Xem khóa học ${course.title}`);
    if (course.image) {
      const coverImage = document.createElement("img");
      coverImage.src = course.image;
      coverImage.alt = `Ảnh bìa khóa học ${course.title}`;
      coverImage.loading = "lazy";
      coverImage.decoding = "async";
      coverImage.dataset.fallbackSrc = course.image;
      coverImage.addEventListener("error", () => {
        if (coverImage.dataset.fallbackTried !== "1") {
          coverImage.dataset.fallbackTried = "1";
          coverImage.src = coverImage.dataset.fallbackSrc;
        } else {
          coverImage.remove();
        }
      });
      cover.append(coverImage);
    }
    if (course.discount) {
      const discount = document.createElement("span");
      discount.className = "mhi-featured-catalog-badge";
      discount.textContent = course.discount;
      cover.append(discount);
    }

    const body = document.createElement("div");
    body.className = "mhi-featured-catalog-body";
    const title = document.createElement("h3");
    const titleLink = document.createElement("a");
    titleLink.href = course.href;
    titleLink.textContent = course.title;
    title.append(titleLink);
    const meta = document.createElement("div");
    meta.className = "mhi-featured-catalog-meta";
    if (course.currentPrice) {
      const currentPrice = document.createElement("strong");
      currentPrice.textContent = course.currentPrice;
      meta.append(currentPrice);
    }
    if (course.oldPrice) {
      const oldPrice = document.createElement("del");
      oldPrice.textContent = course.oldPrice;
      meta.append(oldPrice);
    }
    const detail = document.createElement("a");
    detail.className = "mhi-featured-catalog-detail";
    detail.href = course.href;
    detail.textContent = "Xem chi tiết khóa học";
    body.append(title, meta, detail);
    article.append(cover, body);
    catalogGrid.append(article);
  });
  catalogShell.append(catalogHeader, catalogGrid);
  catalogSection.append(catalogShell);
  row.after(catalogSection);

  // The course catalog has the original full-size covers and curriculum counts.
  // PHP still decides which featured courses are shown and supplies their live prices.
  fetch("/hero-light/assets/catalog-data.json")
    .then((response) => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.json();
    })
    .then((data) => {
      const catalogById = new Map((data.courses || []).map((course) => [course.id, course]));
      catalogGrid.querySelectorAll(".mhi-featured-catalog-card").forEach((article) => {
        const catalogCourse = catalogById.get(Number(article.dataset.courseId));
        if (!catalogCourse) return;
        const image = article.querySelector(".mhi-featured-catalog-cover img");
        if (image && catalogCourse.image) image.src = catalogCourse.image;
        const meta = article.querySelector(".mhi-featured-catalog-meta");
        const curriculum = [
          catalogCourse.chapters ? `${catalogCourse.chapters} chương` : "",
          catalogCourse.lessons ? `${catalogCourse.lessons} bài học` : "",
        ].filter(Boolean);
        if (curriculum.length) {
          const curriculumLine = document.createElement("span");
          curriculumLine.className = "mhi-featured-catalog-curriculum";
          curriculumLine.textContent = curriculum.join(" · ");
          meta.prepend(curriculumLine);
        }
      });
    })
    .catch(() => {});
})();
