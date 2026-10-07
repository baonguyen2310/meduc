(() => {
  "use strict";

  const source = document.querySelector('body.meduc-home-v2 > [nh-row="p4tomue"]');
  if (!source) return;

  const figures = [...source.querySelectorAll(".rbt-counterup")].map((card) => ({
    count: Number(card.querySelector("[data-count]")?.getAttribute("data-count")),
    label: card.querySelector(".subtitle")?.textContent.trim(),
  }));
  if (figures.length !== 4 || figures.some((figure) => !Number.isFinite(figure.count) || !figure.label)) return;

  const section = document.createElement("section");
  section.className = "mhi-impact";
  section.setAttribute("aria-labelledby", "mhi-impact-title");
  section.innerHTML = `
    <div class="mhi-impact-shell">
      <div class="mhi-impact-heading">
        <div>
          <p class="mhi-impact-kicker">MEDUC / CỘNG ĐỒNG HỌC Y</p>
          <h2 id="mhi-impact-title">Cùng nhau học Y<br><em>tốt hơn.</em></h2>
        </div>
        <p class="mhi-impact-intro">Những dấu mốc trên hành trình học tập cùng MedUC.</p>
      </div>
      <div class="mhi-impact-grid" aria-label="Các chỉ số của MedUC"></div>
    </div>`;

  const grid = section.querySelector(".mhi-impact-grid");
  figures.forEach((figure, index) => {
    const item = document.createElement("div");
    item.className = "mhi-impact-item";
    const indexText = document.createElement("span");
    indexText.className = "mhi-impact-index";
    indexText.textContent = `0${index + 1} / 04`;
    const number = document.createElement("strong");
    number.className = "mhi-impact-number";
    number.dataset.count = String(figure.count);
    number.setAttribute("aria-label", `${new Intl.NumberFormat("vi-VN").format(figure.count)}+`);
    number.innerHTML = `<span class="mhi-count-value" data-count="${figure.count}" aria-hidden="true">0</span><span aria-hidden="true">+</span>`;
    const label = document.createElement("span");
    label.className = "mhi-impact-label";
    label.textContent = figure.label;
    item.append(indexText, number, label);
    grid.append(item);
  });

  source.replaceWith(section);
})();
