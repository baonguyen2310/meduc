(() => {
  "use strict";

  const source = document.querySelector('body.meduc-home-v2 > [nh-row="gdj39ru"]');
  if (!source || source.querySelector("h2.box_title")?.textContent.trim() !== "MEDUC.VN LEARNING SYSTEM") return;

  const entries = [...source.querySelectorAll(".item")].map((item) => ({
    title: item.querySelector("h4")?.textContent.trim(),
    href: item.querySelector("a[href]")?.getAttribute("href"),
    image: item.querySelector("img")?.getAttribute("data-src") || item.querySelector("img")?.getAttribute("src"),
  }));
  if (entries.length !== 6 || entries.some((entry) => !entry.title || !entry.href)) return;

  const description = source.querySelector("h3.sub_title")?.textContent.trim() || "";
  const section = document.createElement("section");
  section.className = "mhi-system";
  section.setAttribute("aria-labelledby", "mhi-system-title");
  section.innerHTML = `
    <div class="mhi-system-shell">
      <div class="mhi-system-panel">
        <div class="mhi-system-copy">
          <div class="mhi-system-mark"><span>MedUC<span class="mhi-system-domain">.vn</span></span><small>LEARNING SYSTEM</small></div>
          <h2 id="mhi-system-title">Học Y khoa trong<br>một hệ sinh thái.</h2>
          <p class="mhi-system-description"></p>
          <a class="mhi-system-cta"><span>Khám phá khóa học</span><span class="mhi-system-cta-arrow" aria-hidden="true">→</span></a>
        </div>
        <div class="mhi-system-visual">
          <div class="mhi-system-frame">
            <div class="mhi-system-board">
              <div class="mhi-system-board-head"><span>MEDUC <i>×</i> LEARNING SYSTEM</span><small>CHỌN NƠI BẮT ĐẦU</small></div>
              <div class="mhi-system-links" id="mhi-system-links" aria-label="Các danh mục học tập của MedUC"></div>
              <p class="mhi-system-board-foot">HỌC SÂU · HIỂU ĐÚNG · VỮNG NGHỀ Y</p>
            </div>
          </div>
        </div>
      </div>
    </div>`;

  section.querySelector(".mhi-system-description").textContent = description;
  section.querySelector(".mhi-system-cta").href = entries[0].href;
  const links = section.querySelector(".mhi-system-links");
  entries.forEach((entry, index) => {
    const link = document.createElement("a");
    link.className = "mhi-system-link";
    link.href = entry.href;
    link.setAttribute("aria-label", entry.title);

    const icon = document.createElement("span");
    icon.className = "mhi-system-icon";
    if (entry.image) {
      const image = document.createElement("img");
      image.src = entry.image;
      image.alt = "";
      image.loading = "lazy";
      image.decoding = "async";
      image.addEventListener("error", () => {
        image.remove();
        icon.textContent = entry.title[0];
      });
      icon.append(image);
    } else {
      icon.textContent = entry.title[0];
    }

    const title = document.createElement("span");
    title.className = "mhi-system-link-title";
    title.textContent = entry.title;
    const arrow = document.createElement("span");
    arrow.className = "mhi-system-link-arrow";
    arrow.setAttribute("aria-hidden", "true");
    arrow.textContent = "↗";
    link.append(icon, title, arrow);
    link.dataset.item = String(index + 1);
    links.append(link);
  });

  source.replaceWith(section);
})();
