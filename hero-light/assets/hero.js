(() => {
  "use strict";
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [
    ...root.querySelectorAll(selector),
  ];
  const localPreview =
    ["127.0.0.1", "localhost", "[::1]"].includes(location.hostname) &&
    location.port === "4176";
  const previewMode = localPreview || location.pathname.startsWith("/hero-light/");
  const demoBase = localPreview
    ? new URL("http://127.0.0.1:4174/")
    : new URL("../studio-bright/", location.href);
  const demoURL = (path) => new URL(path, demoBase).href;
  const realCourses = {
    anatomy: "/giai-phau-1-2-co-ban-chuyen-sau",
    "clinical-thinking": "/lam-sang-noi-khoa-co-ban-chuyen-sau",
    surgery: "/lam-sang-ngoai-khoa-co-ban-chuyen-sau",
    ecg: "/ly-thuyet-lam-sang-ecg-co-ban-chuyen-sau",
    physiology: "/sinh-ly-1-2-co-ban-chuyen-sau",
    examination: "/ngoai-co-so-ngoai-trieu-chung-co-ban-chuyen-sau",
  };
  const liveURL = (path) => {
    if (path.startsWith("course_detail.html")) {
      const id = new URL(path, location.href).searchParams.get("id");
      const slug = realCourses[id]?.slice(1);
      return slug ? `/khoa-hoc-chi-tiet-v2?course=${encodeURIComponent(slug)}` : "/khoa-hoc-v2";
    }
    if (path.startsWith("courses.html")) {
      const group = new URL(path, location.href).searchParams.get("nhom");
      return `/khoa-hoc-v2${group ? `?nhom=${encodeURIComponent(group)}` : ""}`;
    }
    if (path.startsWith("exams.html") || path.startsWith("practice.html"))
      return "/danh-sach-de-thi";
    if (path.startsWith("instructors.html")) return "/gioi-thieu-v2#doi-ngu";
    if (path.startsWith("blog.html") || path.startsWith("article_detail.html")) return "/blog-v2";
    if (path.startsWith("leaderboard.html")) return "/danh-sach-de-thi";
    return "/khoa-hoc-v2";
  };
  $$("[data-demo]").forEach((link) => {
    const path = link.dataset.demo;
    if (previewMode && path.startsWith("blog.html")) {
      link.href = new URL(path, location.href).href;
    } else if (previewMode && path.startsWith("courses.html")) {
      link.href = new URL(path, location.href).href;
    } else if (previewMode && path.startsWith("course_detail.html")) {
      const id = new URL(path, location.href).searchParams.get("id");
      const slug = realCourses[id]?.slice(1);
      link.href = slug ? new URL(`course-detail.html?course=${encodeURIComponent(slug)}`, location.href).href : new URL("courses.html", location.href).href;
    } else {
      link.href = previewMode ? demoURL(path) : liveURL(path);
    }
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
      title: "Lâm sàng Nội Khoa: Cơ bản đến Chuyên sâu",
      field: "Nội khoa · 7 chương · 30 bài",
    },
    {
      id: "anatomy",
      title: "Giải Phẫu 1, 2: Cơ bản đến Chuyên sâu",
      field: "Y khoa cơ sở · 9 chương · 47 bài",
    },
    {
      id: "surgery",
      title: "Lâm sàng Ngoại Khoa: Cơ bản đến Chuyên sâu",
      field: "Ngoại khoa · 4 chương · 37 bài",
    },
    {
      id: "ecg",
      title: "Lý thuyết và Lâm sàng ECG",
      field: "Lâm sàng · 6 chương · 35 bài",
    },
    {
      id: "physiology",
      title: "Sinh Lý 1, 2: Cơ bản đến Chuyên sâu",
      field: "Y khoa cơ sở · 13 chương · 44 bài",
    },
    {
      id: "examination",
      title: "Ngoại Cơ Sở và Ngoại Triệu Chứng",
      field: "Ngoại khoa · 5 chương · 25 bài",
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
      const path = `course_detail.html?id=${course.id}`;
      link.href = previewMode ? demoURL(path) : liveURL(path);
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
      title: "Giải Phẫu 1, 2: Cơ bản đến Chuyên sâu",
      label: "Lớp học · Y khoa cơ sở",
      path: "course_detail.html?id=anatomy",
    },
    clinical: {
      title: "Lâm sàng Nội Khoa: Cơ bản đến Chuyên sâu",
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
      path: "blog.html",
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
      link.href = previewMode && item.path === "blog.html" ? new URL(item.path, location.href).href : previewMode ? demoURL(item.path) : liveURL(item.path);
      link.innerHTML = `<span><small>${item.label}</small><strong>${item.title}</strong></span>${icon("arrow")}`;
      $("#path-links").append(link);
    });
    $("#path-dialog").showModal();
  });
  $("#login-button").addEventListener("click", () => {
    if (previewMode) $("#login-dialog").showModal();
    else location.assign("/member/login");
  });
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
