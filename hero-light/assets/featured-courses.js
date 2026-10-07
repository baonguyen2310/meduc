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
})();
