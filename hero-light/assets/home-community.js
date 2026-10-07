(() => {
  "use strict";

  const consult = document.querySelector("body.meduc-home-v2 > .mhi-consult");
  const source = [...document.querySelectorAll("body.meduc-home-v2 > [nh-row]")].find((row) =>
    row.querySelector("h3.title")?.textContent.trim() === "Thông Tin Liên Hệ" &&
    row.querySelectorAll(".edu-counterup a[href]").length === 4
  );
  if (!consult || !source) return;

  const platforms = ["YOUTUBE", "NHÓM FACEBOOK", "FACEBOOK", "ZALO"];
  const entries = [...source.querySelectorAll(".edu-counterup a[href]")].map((link, index) => {
    const image = link.querySelector(".icon img");
    return {
      href: link.getAttribute("href"),
      count: Number(link.querySelector("[data-count]")?.getAttribute("data-count") || link.getAttribute("title")),
      label: link.querySelector(".content > span")?.textContent.trim() || "Thành viên",
      image: image?.getAttribute("data-src") || image?.getAttribute("src") || "",
      platform: platforms[index],
    };
  });
  if (entries.some((item) => !item.href || !Number.isFinite(item.count))) return;

  const actions = [...source.querySelectorAll(".load-more-btn > a")];
  const modal = source.querySelector("#modalEmail");
  const section = document.createElement("section");
  section.className = "mhi-community";
  section.setAttribute("aria-labelledby", "mhi-community-title");
  section.innerHTML = `
    <div class="mhi-community-shell">
      <div class="mhi-community-panel">
        <div class="mhi-community-grid" aria-label="Cộng đồng MedUC trên các nền tảng"></div>
        <div class="mhi-community-copy">
          <p class="mhi-community-kicker">THÔNG TIN LIÊN HỆ · MEDUC</p>
          <h2 id="mhi-community-title">KẾT NỐI<br>CÙNG MEDUC.</h2>
          <p class="mhi-community-description">Theo dõi nội dung và trao đổi kiến thức Y khoa cùng cộng đồng MedUC trên YouTube, Facebook và Zalo.</p>
          <div class="mhi-community-actions"></div>
        </div>
      </div>
    </div>`;

  const grid = section.querySelector(".mhi-community-grid");
  entries.forEach((item, index) => {
    const card = document.createElement("a");
    card.className = "mhi-community-card";
    card.href = item.href;
    card.target = "_blank";
    card.rel = "noopener noreferrer";
    card.setAttribute("aria-label", `${item.platform}: ${new Intl.NumberFormat("vi-VN").format(item.count)}+ ${item.label}`);
    const top = document.createElement("span");
    top.className = "mhi-community-card-top";
    const icon = document.createElement("span");
    icon.className = "mhi-community-icon";
    if (item.image) {
      const image = document.createElement("img");
      image.src = item.image;
      image.alt = "";
      image.loading = "lazy";
      image.decoding = "async";
      image.addEventListener("error", () => image.remove());
      icon.append(image);
    }
    const arrow = document.createElement("span");
    arrow.className = "mhi-community-card-arrow";
    arrow.setAttribute("aria-hidden", "true");
    arrow.textContent = "↗";
    top.append(icon, arrow);
    const details = document.createElement("span");
    details.className = "mhi-community-card-details";
    const platform = document.createElement("small");
    platform.textContent = item.platform;
    const count = document.createElement("strong");
    count.dataset.count = String(item.count);
    count.innerHTML = `<span class="mhi-count-value" data-count="${item.count}" aria-hidden="true">0</span><span aria-hidden="true">+</span>`;
    const label = document.createElement("span");
    label.textContent = item.label;
    details.append(platform, count, label);
    card.append(top, details);
    card.dataset.platform = String(index + 1);
    grid.append(card);
  });

  const buttons = section.querySelector(".mhi-community-actions");
  actions.slice(0, 2).forEach((original, index) => {
    const link = document.createElement("a");
    link.className = index === 0 ? "mhi-community-primary" : "mhi-community-secondary";
    link.href = original.getAttribute("href");
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    link.setAttribute("aria-label", original.textContent.trim());
    link.innerHTML = index === 0 ? 'Tham gia nhóm Facebook' : 'Nhóm học tập Zalo <span aria-hidden="true">→</span>';
    buttons.append(link);
  });
  if (modal && actions[2]) {
    const emailButton = document.createElement("button");
    emailButton.type = "button";
    emailButton.className = "mhi-community-email";
    emailButton.setAttribute("data-bs-toggle", "modal");
    emailButton.setAttribute("data-bs-target", "#modalEmail");
    emailButton.textContent = "Nhận tài liệu Y khoa miễn phí ↗";
    emailButton.setAttribute("aria-label", actions[2].textContent.trim());
    buttons.append(emailButton);
    document.body.append(modal);
  }

  consult.after(section);
  source.remove();
})();
