(() => {
  "use strict";
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [
    ...root.querySelectorAll(selector),
  ];
  const localPreview =
    ["127.0.0.1", "localhost", "[::1]"].includes(location.hostname) &&
    location.port === "4175";
  const demoBase = localPreview
    ? new URL("http://127.0.0.1:4174/")
    : new URL("../studio-bright/", location.href);
  const demoURL = (path) => new URL(path, demoBase).href;
  $$("[data-demo]").forEach((link) => {
    link.href = demoURL(link.dataset.demo);
  });
  const normalize = (text) =>
    text
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/đ/gi, "d")
      .toLowerCase()
      .trim();
  const icon = (name) =>
    `<svg class="icon" aria-hidden="true"><use href="#i-${name}"/></svg>`;

  const browseMenu = $("#browse-menu");
  const browseButtons = [$("#browse-button"), $("#mobile-menu")];
  function setBrowse(open, returnFocus = false) {
    browseMenu.hidden = !open;
    browseButtons.forEach((button) =>
      button.setAttribute("aria-expanded", String(open)),
    );
    $("#mobile-menu").setAttribute(
      "aria-label",
      open ? "Đóng menu" : "Mở menu",
    );
    if (open) closeSearch(false);
    if (!open && returnFocus)
      browseButtons.find((button) => button.getClientRects().length)?.focus();
  }
  browseButtons.forEach((button) =>
    button.addEventListener("click", () => setBrowse(browseMenu.hidden)),
  );

  const courseList = [
    {
      id: "clinical-thinking",
      title: "Tư duy lâm sàng: bắt đầu từ những câu hỏi",
      field: "Nội khoa · Nguyễn Hoàng An",
    },
    {
      id: "anatomy",
      title: "Giải phẫu học: nhìn để hiểu, học để nhớ",
      field: "Y khoa cơ sở · Trần Khánh Linh",
    },
    {
      id: "surgery",
      title: "Ngoại khoa cơ sở: sự tự tin từ nền tảng",
      field: "Ngoại khoa · Lê Quang Minh",
    },
    {
      id: "ecg",
      title: "Điện tâm đồ: đọc có hệ thống, hiểu có cơ sở",
      field: "Nội khoa · Nguyễn Hoàng An",
    },
    {
      id: "physiology",
      title: "Sinh lý học: hiểu cơ thể như một hệ thống",
      field: "Y khoa cơ sở · Trần Khánh Linh",
    },
    {
      id: "examination",
      title: "Khám bệnh ngoại khoa: quan sát có chủ đích",
      field: "Ngoại khoa · Lê Quang Minh",
    },
  ];
  const search = $("#course-search");
  const searchWrap = $("#search-wrap");
  const results = $("#search-results");
  function renderSearch() {
    const query = normalize(search.value);
    const matches = courseList.filter((course) =>
      normalize(`${course.title} ${course.field}`).includes(query),
    );
    $("#search-status").textContent = query
      ? matches.length
        ? `${matches.length} lớp học dành cho bạn`
        : "Chưa tìm thấy lớp học phù hợp. Thử “giải phẫu”, “nội khoa” hoặc “điện tâm đồ”."
      : "Khám phá các lớp học Meduc";
    $("#search-list").replaceChildren();
    matches.forEach((course) => {
      const link = document.createElement("a");
      link.className = "search-result";
      link.href = demoURL(`course_detail.html?id=${course.id}`);
      link.innerHTML = `<span><strong>${course.title}</strong><small>${course.field}</small></span>${icon("arrow")}`;
      $("#search-list").append(link);
    });
    results.hidden = false;
    setBrowse(false);
  }
  function closeSearch(returnFocus = false) {
    results.hidden = true;
    searchWrap.classList.remove("is-open");
    if (returnFocus) $("#mobile-search").focus();
  }
  search.addEventListener("input", renderSearch);
  search.addEventListener("focus", renderSearch);
  $("#search-form").addEventListener("submit", (event) => {
    event.preventDefault();
    renderSearch();
  });
  $("#mobile-search").addEventListener("click", () => {
    setBrowse(false);
    searchWrap.classList.add("is-open");
    search.focus();
  });
  $("#close-search").addEventListener("click", () => closeSearch(true));
  document.addEventListener("click", (event) => {
    if (
      !browseMenu.contains(event.target) &&
      !browseButtons.some((button) => button.contains(event.target))
    )
      setBrowse(false);
    if (
      !searchWrap.contains(event.target) &&
      !$("#mobile-search").contains(event.target)
    )
      closeSearch(false);
  });
  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    if (!browseMenu.hidden) setBrowse(false, true);
    if (!results.hidden || searchWrap.classList.contains("is-open")) {
      const mobileOpen = searchWrap.classList.contains("is-open");
      closeSearch(mobileOpen);
      if (!mobileOpen) search.blur();
    }
  });

  const wall = $("#portrait-wall");
  const motionButton = $("#motion-toggle");
  const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)");
  let paused = reducedMotion.matches;
  $$(".portrait-track").forEach((track) => {
    const group = $(".portrait-set", track);
    // Three equal groups keep the strip filled even at the end of an animation cycle.
    for (let i = 0; i < 2; i += 1) track.append(group.cloneNode(true));
  });
  function setPaused(value) {
    paused = value;
    wall.classList.toggle("is-paused", value);
    motionButton.setAttribute("aria-pressed", String(value));
    const label = value ? "Phát chuyển động ảnh" : "Tạm dừng chuyển động ảnh";
    motionButton.setAttribute("aria-label", label);
    motionButton.title = label;
    motionButton.innerHTML = icon(value ? "play" : "pause");
    // An explicit play action can opt into motion after the reduced-motion default.
    $$(".portrait-track").forEach((track) => {
      track.style.animationPlayState = value ? "paused" : "running";
    });
  }
  setPaused(paused);
  motionButton.addEventListener("click", () => setPaused(!paused));
  reducedMotion.addEventListener("change", (event) => setPaused(event.matches));

  const recommendations = {
    foundation: {
      title: "Xây nền tảng giải phẫu",
      label: "Lớp học · Y khoa cơ sở",
      path: "course_detail.html?id=anatomy",
    },
    clinical: {
      title: "Bắt đầu với tư duy lâm sàng",
      label: "Lớp học · Nội khoa",
      path: "course_detail.html?id=clinical-thinking",
    },
    semester: {
      title: "Tìm bộ đề theo trường và năm học",
      label: "Luyện tập · Bộ đề phân cấp",
      path: "exams.html",
    },
    residency: {
      title: "Hệ thống lại kiến thức, luyện tập mỗi ngày",
      label: "Luyện tập · Thư viện bộ đề",
      path: "exams.html",
    },
    practice: {
      title: "Thử một bài luyện có giải thích",
      label: "Bài học mẫu · Giải phẫu tim",
      path: "practice.html?exam=heart-hmu",
    },
    mentors: {
      title: "Gặp những người thầy của bạn",
      label: "Khám phá · Giảng viên",
      path: "instructors.html",
    },
    habits: {
      title: "Học ít hơn, nhớ sâu hơn",
      label: "Meduc Journal · Phương pháp học",
      path: "article_detail.html",
    },
  };
  const selectedGoals = () =>
    $$("#goal-form input:checked").map((input) => input.value);
  $("#goal-form").addEventListener("change", () => {
    const count = selectedGoals().length;
    $("#goal-hint").textContent = count
      ? `Đã chọn ${count} mục tiêu. Cùng tìm bước đầu tiên nhé.`
      : "Bạn có thể chọn nhiều mục tiêu.";
    $("#goal-error").hidden = true;
  });
  $("#goal-form").addEventListener("submit", (event) => {
    event.preventDefault();
    const selected = selectedGoals();
    if (!selected.length) {
      $("#goal-error").hidden = false;
      $("#goal-form input").focus();
      return;
    }
    const unique = [
      ...new Map(
        selected.map((goal) => [
          recommendations[goal].path,
          recommendations[goal],
        ]),
      ).values(),
    ];
    $("#path-description").textContent =
      `Từ ${selected.length} mục tiêu bạn vừa chọn, đây là một vài điểm bắt đầu để khám phá Meduc.`;
    $("#path-links").replaceChildren();
    unique.forEach((item) => {
      const link = document.createElement("a");
      link.className = "path-link";
      link.href = demoURL(item.path);
      link.innerHTML = `<span><small>${item.label}</small><strong>${item.title}</strong></span>${icon("arrow")}`;
      $("#path-links").append(link);
    });
    $("#path-dialog").showModal();
  });
  $("#login-button").addEventListener("click", () =>
    $("#login-dialog").showModal(),
  );
  $$("[data-close]").forEach((button) =>
    button.addEventListener("click", () => button.closest("dialog").close()),
  );
  $$("dialog").forEach((dialog) =>
    dialog.addEventListener("click", (event) => {
      if (event.target !== dialog) return;
      const rect = dialog.getBoundingClientRect();
      if (
        event.clientX < rect.left ||
        event.clientX > rect.right ||
        event.clientY < rect.top ||
        event.clientY > rect.bottom
      )
        dialog.close();
    }),
  );
})();
