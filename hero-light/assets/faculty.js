(() => {
  "use strict";

  const featured = document.querySelector("body.meduc-home-v2 > .mhi-featured");
  if (!featured) return;

  const section = document.createElement("section");
  section.className = "mhi-faculty";
  section.setAttribute("aria-labelledby", "mhi-faculty-title");
  section.innerHTML = `
    <div class="mhi-faculty-shell">
      <div class="mhi-faculty-heading">
        <p class="mhi-faculty-kicker">CON NGƯỜI MEDUC</p>
        <h2 id="mhi-faculty-title">Đội Ngũ Giảng Viên Và Cố Vấn</h2>
        <p class="mhi-faculty-intro">Gặp gỡ những người đồng hành cùng bạn trên hành trình học Y.</p>
      </div>
      <div class="mhi-faculty-rail" aria-label="Giảng viên và cố vấn MedUC" tabindex="0"></div>
      <div class="mhi-faculty-footer">
        <p>Học từ kinh nghiệm của đội ngũ MedUC.</p>
        <a href="/gioi-thieu">Xem toàn bộ đội ngũ →</a>
      </div>
    </div>`;
  featured.after(section);

  const rail = section.querySelector(".mhi-faculty-rail");
  fetch("/hero-light/assets/faculty-data.json?v=20261007-faculty")
    .then((response) => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.json();
    })
    .then((data) => {
      const people = Array.isArray(data.people) ? data.people : [];
      if (!people.length) throw new Error("No faculty profiles");
      people.forEach((person) => {
        const fullName = String(person.name || "").trim();
        if (!fullName) return;
        const subject = fullName.match(/\(([^()]*)\)\s*$/)?.[1]?.replace(/^\s*Dạy\s+/i, "").trim() || "Giảng viên MedUC";
        const displayName = fullName.replace(/\s*\([^()]*\)\s*$/, "").replace(/\s+/g, " ").trim();
        const courseURL = /^\/(?!\/)/.test(person.url || "") ? person.url : "";
        const href = courseURL || "/gioi-thieu";

        const card = document.createElement("article");
        card.className = "mhi-faculty-card";
        const photo = document.createElement("a");
        photo.className = "mhi-faculty-photo";
        photo.href = href;
        photo.setAttribute("aria-label", `Tìm hiểu về ${fullName}`);
        if (person.image) {
          const image = document.createElement("img");
          image.src = person.image;
          image.alt = `Chân dung ${displayName}`;
          image.loading = "lazy";
          image.decoding = "async";
          image.addEventListener("error", () => image.remove());
          photo.append(image);
        }

        const badge = document.createElement("span");
        badge.className = "mhi-faculty-subject";
        badge.textContent = subject;
        const copy = document.createElement("div");
        copy.className = "mhi-faculty-copy";
        const name = document.createElement("h3");
        const nameLink = document.createElement("a");
        nameLink.href = href;
        nameLink.textContent = displayName;
        name.append(nameLink);
        const description = document.createElement("p");
        description.className = "mhi-faculty-description";
        description.textContent = String(person.description || "").replace(/^\s*-\s*/, "").trim();
        const detail = document.createElement("a");
        detail.className = "mhi-faculty-cta";
        detail.href = href;
        detail.textContent = courseURL ? "Tìm hiểu khóa học" : "Tìm hiểu đội ngũ";
        copy.append(name, description, detail);
        card.append(photo, badge, copy);
        rail.append(card);
      });
      if (!rail.children.length) section.remove();
    })
    .catch(() => section.remove());
})();
