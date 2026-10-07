(() => {
  "use strict";
  const root = document.querySelector("#meduc-home-intro");
  if (!root) return;
  const $ = (selector) => root.querySelector(selector);
  const $$ = (selector) => [...root.querySelectorAll(selector)];

  const themeButton = $("#mhi-theme-toggle");
  function updateThemeButton() {
    const dark = document.documentElement.dataset.meducTheme !== "light";
    const label = dark ? "Chuyển sang chế độ sáng" : "Chuyển sang chế độ tối";
    themeButton.setAttribute("aria-label", label);
    themeButton.setAttribute("aria-pressed", String(dark));
    themeButton.title = label;
  }
  updateThemeButton();
  themeButton.addEventListener("click", () => {
    const next = document.documentElement.dataset.meducTheme === "light" ? "dark" : "light";
    document.documentElement.dataset.meducTheme = next;
    try { localStorage.setItem("meduc-theme", next); } catch (_) { /* Storage may be disabled. */ }
    updateThemeButton();
  });

  const browseButton = $("#mhi-browse-button");
  const browseMenu = $("#mhi-browse-menu");
  function setBrowse(open) {
    browseMenu.hidden = !open;
    browseButton.setAttribute("aria-expanded", String(open));
  }
  browseButton.addEventListener("click", () => setBrowse(browseMenu.hidden));
  document.addEventListener("click", (event) => {
    if (!browseMenu.hidden && !browseMenu.contains(event.target) && !browseButton.contains(event.target)) setBrowse(false);
  });
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !browseMenu.hidden) {
      setBrowse(false);
      browseButton.focus();
    }
  });

  const wall = $("#mhi-portrait-wall");
  const motionButton = $("#mhi-motion-toggle");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  $$(".mhi-portrait-track").forEach((track) => {
    const group = track.querySelector(".mhi-portrait-set");
    for (let index = 0; index < 2; index += 1) track.append(group.cloneNode(true));
  });
  function setPaused(paused) {
    wall.classList.toggle("is-paused", paused);
    motionButton.setAttribute("aria-pressed", String(paused));
    motionButton.setAttribute("aria-label", paused ? "Phát chuyển động ảnh" : "Tạm dừng chuyển động ảnh");
    motionButton.title = motionButton.getAttribute("aria-label");
  }
  setPaused(reducedMotion.matches);
  motionButton.addEventListener("click", () => setPaused(!wall.classList.contains("is-paused")));
  reducedMotion.addEventListener("change", (event) => setPaused(event.matches));

  const paths = {
    foundation: ["Lớp học · Y khoa cơ sở", "Giải Phẫu 1, 2: Cơ bản đến Chuyên sâu", "/khoa-hoc-chi-tiet-v2?course=giai-phau-1-2-co-ban-chuyen-sau"],
    clinical: ["Lớp học · Nội khoa", "Lâm sàng Nội Khoa: Cơ bản đến Chuyên sâu", "/khoa-hoc-chi-tiet-v2?course=lam-sang-noi-khoa-co-ban-chuyen-sau"],
    semester: ["Luyện tập · Bộ đề", "Tìm bộ đề theo môn và năm học", "/bo-de-v2"],
    residency: ["Luyện tập · Nội trú", "Hệ thống lại kiến thức, luyện tập mỗi ngày", "/danh-sach-de-thi"],
    practice: ["Luyện tập · Bộ đề", "Thử một bài luyện có giải thích", "/danh-sach-de-thi"],
    mentors: ["Khám phá · Đội ngũ", "Gặp những người thầy của bạn", "/gioi-thieu"],
    habits: ["Góc học tập · Bài viết", "Học ít hơn, nhớ sâu hơn", "/blog-v2"],
  };
  const goalForm = $("#mhi-goal-form");
  const selectedGoals = () => $$("#mhi-goal-form input:checked").map((input) => input.value);
  goalForm.addEventListener("change", () => {
    const count = selectedGoals().length;
    $("#mhi-goal-hint").textContent = count ? `Đã chọn ${count} mục tiêu. Cùng tìm bước đầu tiên nhé.` : "Bạn có thể chọn nhiều mục tiêu.";
    $("#mhi-goal-error").hidden = true;
  });
  const dialog = $("#mhi-path-dialog");
  goalForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const selected = selectedGoals();
    if (!selected.length) {
      $("#mhi-goal-error").hidden = false;
      $("#mhi-goal-form input").focus();
      return;
    }
    $("#mhi-path-description").textContent = `Từ ${selected.length} mục tiêu bạn vừa chọn, đây là một vài điểm bắt đầu để khám phá Meduc.`;
    const links = $("#mhi-path-links");
    links.replaceChildren();
    const unique = new Map(selected.map((goal) => [paths[goal][2], paths[goal]]));
    unique.forEach(([label, title, href]) => {
      const link = document.createElement("a");
      const copy = document.createElement("span");
      const small = document.createElement("small");
      const strong = document.createElement("strong");
      small.textContent = label;
      strong.textContent = title;
      copy.append(small, strong);
      link.href = href;
      link.append(copy, document.createTextNode("→"));
      links.append(link);
    });
    dialog.showModal();
  });
  $(".mhi-dialog-close").addEventListener("click", () => dialog.close());
  dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close(); });
})();
