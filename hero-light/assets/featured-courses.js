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
    "meduc-doctor-01.jpg",
    "doctor-minh.jpg",
    "professor.jpg",
    "meduc-doctor-04.jpg",
    "meduc-doctor-02.jpg",
  ];
  cards.forEach((card, index) => {
    const image = card.querySelector(".thumbnail img");
    const thumbnail = card.querySelector(".thumbnail");
    if (!image || !thumbnail) return;

    const title = card.querySelector(".content .title a")?.textContent.trim() || "khóa học";
    image.removeAttribute("nh-lazy");
    image.removeAttribute("data-src");
    image.src = `/hero-light/assets/images/${illustrations[index % illustrations.length]}`;
    image.alt = `Ảnh minh họa cho khóa học ${title}`;
    image.loading = index < 3 ? "eager" : "lazy";
    image.decoding = "async";

    const note = document.createElement("span");
    note.className = "mhi-featured-illustration-note";
    note.textContent = "Ảnh minh họa";
    thumbnail.append(note);
  });

  const controls = document.createElement("div");
  controls.className = "mhi-featured-controls";
  controls.innerHTML = '<button type="button" aria-label="Khóa học trước" data-direction="previous">←</button><button type="button" aria-label="Khóa học tiếp theo" data-direction="next">→</button>';
  heading.append(controls);
  rail.setAttribute("aria-label", "Các khóa học nổi bật của MedUC");
  row.classList.add("mhi-featured");

  const previous = controls.querySelector('[data-direction="previous"]');
  const next = controls.querySelector('[data-direction="next"]');
  const updateControls = () => {
    previous.disabled = rail.scrollLeft <= 2;
    next.disabled = rail.scrollLeft + rail.clientWidth >= rail.scrollWidth - 2;
  };
  controls.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-direction]");
    if (!button) return;
    const distance = cards[0].getBoundingClientRect().width + 20;
    rail.scrollBy({ left: button === next ? distance : -distance, behavior: "smooth" });
  });
  rail.addEventListener("scroll", updateControls, { passive: true });
  window.addEventListener("resize", updateControls);
  updateControls();
})();
