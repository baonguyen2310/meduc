(() => {
  "use strict";
  const D = window.MEDUC;
  const page = document.body.dataset.page;
  const params = new URLSearchParams(location.search);
  const $ = (s, root = document) => root.querySelector(s);
  const $$ = (s, root = document) => [...root.querySelectorAll(s)];
  const esc = (value) =>
    String(value ?? "").replace(
      /[&<>"']/g,
      (c) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        })[c],
    );
  const norm = (value) =>
    String(value)
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .replace(/đ/g, "d");
  const number = (value) => new Intl.NumberFormat("vi-VN").format(value);
  const read = (key, fallback) => {
    try {
      const v = JSON.parse(localStorage.getItem("meduc-studio:" + key));
      return v ?? fallback;
    } catch {
      return fallback;
    }
  };
  const write = (key, value) => {
    try {
      localStorage.setItem("meduc-studio:" + key, JSON.stringify(value));
    } catch {
      /* Private browsing still supports the full in-memory demo. */
    }
  };
  const list = (key) => {
    const value = read(key, []);
    return Array.isArray(value) ? value : [];
  };
  const teacher = (id) => D.teachers.find((t) => t.id === id) || D.teachers[0];
  const course = (id) => D.courses.find((c) => c.id === id) || D.courses[0];
  const img = (name) => `assets/images/${name}`;
  const schoolName = (id) =>
    id === "HMU" ? "ĐH Y Hà Nội" : "ĐH Y Dược TP.HCM";
  const icons = {
    arrow: '<path d="M4 12h15m-6-6 6 6-6 6"/>',
    upRight: '<path d="M5 19 19 5M5 5h14v14"/>',
    chevron: '<path d="m6 9 6 6 6-6"/>',
    right: '<path d="m9 5 7 7-7 7"/>',
    left: '<path d="m15 5-7 7 7 7"/>',
    search: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/>',
    play: '<path d="m8 5 11 7-11 7z"/>',
    close: '<path d="m6 6 12 12M6 18 18 6"/>',
    check: '<path d="m5 12 4 4L19 6"/>',
    checkCircle: '<circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/>',
    book: '<path d="M12 5v16m0-16C9 3 5 3 2 4v15c3-1 7-1 10 2 3-3 7-3 10-2V4c-3-1-7-1-10 1Z"/>',
    bookmark: '<path d="M6 3h12v18l-6-4-6 4V3Z"/>',
    heart:
      '<path d="M20.7 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.7 7.8L12 21l8.7-8.6a5.5 5.5 0 0 0 0-7.8Z"/>',
    activity: '<path d="M2 12h5l3-8 4 16 3-8h5"/>',
    pulse: '<path d="M3 4h18v16H3zM3 12h4l2-4 3 8 3-7 2 3h4"/>',
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    grid: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
    star: '<path d="m12 3 2.8 5.8 6.4.9-4.6 4.5 1.1 6.3-5.7-3-5.7 3 1.1-6.3-4.6-4.5 6.4-.9z"/>',
    cap: '<path d="m2 9 10-6 10 6-10 6L2 9Zm4 3v6c4 3 8 3 12 0v-6m4-3v8"/>',
    users:
      '<circle cx="9" cy="7" r="3"/><path d="M2 21v-3a7 7 0 0 1 14 0v3M17 4a3 3 0 0 1 0 6m2 4a5 5 0 0 1 3 5v2"/>',
    target:
      '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1"/>',
    trophy:
      '<path d="M8 3h8v8a4 4 0 0 1-8 0V3Zm0 2H4v3c0 3 2 4 4 4m8-7h4v3c0 3-2 4-4 4m-4 3v6m-5 0h10"/>',
    crown: '<path d="m3 6 5 4 4-7 4 7 5-4-2 13H5L3 6Zm3 10h12"/>',
    fire: '<path d="M13 2c1 6-5 6-3 11 2-1 3-3 3-5 4 3 7 6 5 11-2 4-10 4-12 0-2-4 0-7 2-9-1 5 3 4 3 1s-1-5 2-9Z"/>',
    bulb: '<path d="M9 18h6m-5 3h4M9 15c0-3-4-3-4-7a7 7 0 0 1 14 0c0 4-4 4-4 7H9Z"/>',
    lock: '<rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3m-4 4v3"/>',
    layers: '<path d="m2 7 10-5 10 5-10 5L2 7Zm0 5 10 5 10-5M2 17l10 5 10-5"/>',
    share: '<path d="M12 16V3m-5 5 5-5 5 5M5 12H3v9h18v-9h-2"/>',
    menu: '<path d="M4 6h16M4 12h16M4 18h16"/>',
    reset: '<path d="M3 9a9 9 0 1 1 0 7M3 3v6h6"/>',
    leaf: '<path d="M20 3C9 2 3 7 5 15c7 8 17 1 15-12ZM3 21 16 8"/>',
    shield:
      '<path d="m12 2 8 4v6c0 6-8 10-8 10S4 18 4 12V6l8-4Z"/><path d="m8 12 3 3 5-6"/>',
    pen: '<path d="m15 4 5 5M4 20l5-1L21 7a2 2 0 0 0-4-4L5 15l-1 5Z"/>',
    plus: '<path d="M12 4v16M4 12h16"/>',
  };
  const icon = (name, cls = "") =>
    `<svg class="icon ${cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${icons[name] || icons.book}</svg>`;
  const brand = () =>
    `<a class="brand" href="index.html" aria-label="Meduc — Trang chủ"><svg class="brand-mark" viewBox="0 0 30 28" fill="none" aria-hidden="true"><path d="M3 24V4l12 14L27 4v20" stroke="currentColor" stroke-width="4.5"/></svg>meduc<span class="brand-dot">.</span></a>`;
  const navItems = [
    ["courses.html", "Khám phá", "courses"],
    ["instructors.html", "Giảng viên", "instructors"],
    ["exams.html", "Luyện thi", "exams"],
    ["article_detail.html", "Góc học tập", "article"],
    ["leaderboard.html", "Bảng xếp hạng", "leaderboard"],
  ];
  function header() {
    if (page === "practice")
      return `<header class="site-header practice-header"><div class="container header-inner">${brand()}<span class="practice-header-title">Không gian luyện tập</span><a class="text-link" href="exams.html">${icon("close")} Thoát bài</a></div></header>`;
    return `<header class="site-header"><div class="container header-inner">${brand()}<nav class="main-nav" aria-label="Điều hướng chính" id="main-nav">${navItems.map(([url, title, id]) => `<a href="${url}" class="${page === id || (page === "course" && id === "courses") ? "active" : ""}" ${page === id ? 'aria-current="page"' : ""}>${title}</a>`).join("")}</nav><div class="header-actions"><button class="icon-btn header-search" data-action="search" aria-label="Tìm kiếm khóa học">${icon("search")}</button><a href="exams.html" class="btn btn-dark btn-sm">Vào học ${icon("upRight", "small")}</a><button class="icon-btn menu-toggle" data-action="menu" aria-label="Mở menu" aria-expanded="false" aria-controls="main-nav">${icon("menu")}</button></div></div></header>`;
  }
  function footer() {
    return `<footer class="site-footer"><div class="container"><div class="footer-main"><div class="footer-brand">${brand()}<p>Tri thức mở ra góc nhìn.<br>Sự tận tâm tạo nên người thầy thuốc.</p></div><div class="footer-col"><strong>Hành trình của bạn</strong><a href="courses.html">Khám phá khóa học</a><a href="instructors.html">Gặp gỡ giảng viên</a><a href="exams.html">Luyện tập mỗi ngày</a></div><div class="footer-col"><strong>Cùng nhau tiến bộ</strong><a href="article_detail.html">Meduc Journal</a><a href="leaderboard.html">Bảng xếp hạng</a><a href="index.html#faq">Câu hỏi thường gặp</a></div><div class="footer-col"><strong>Học một điều mới hôm nay.</strong><p style="font-size:11px">Một bài học nhỏ.<br>Một bước tiến dài.</p><a class="text-link" href="courses.html">Bắt đầu hành trình ${icon("arrow", "small")}</a></div></div><div class="footer-bottom"><span>© 2026 Meduc. Dành cho hành trình nghề Y.</span><span>Bản xem trước thiết kế · Dữ liệu, học vị và nhân vật minh họa.</span></div></div></footer>`;
  }
  const link = (label, url, cls = "") =>
    `<a class="text-link ${cls}" href="${url}">${label} ${icon("arrow")}</a>`;
  function saveButton(id, kind = "courses", label = "khóa học") {
    const saved = list("saved-" + kind).includes(id);
    return `<button class="icon-btn save-btn ${saved ? "saved" : ""}" data-action="save" data-kind="${kind}" data-id="${id}" aria-label="${saved ? "Bỏ lưu" : "Lưu"} ${label}" aria-pressed="${saved}">${icon("bookmark")}</button>`;
  }
  function courseCard(c) {
    const t = teacher(c.teacher);
    return `<article class="course-card"><div class="course-cover"><a href="course_detail.html?id=${c.id}" aria-label="${esc(c.title)}"><img src="${img(t.image)}" alt="${t.name}, giảng viên ${t.field.toLowerCase()}" loading="lazy"><span class="cover-label">MEDUC ORIGINALS</span><div class="cover-teacher"><small>${t.degree}</small><h3>${t.name}</h3><span>${c.label}</span></div><span class="cover-play">${icon("play")}</span></a>${saveButton(c.id)}</div><div class="course-meta"><span class="tag ${t.color === "sage" ? "sage" : t.color === "blue" ? "blue" : ""}">${c.category}</span><span>${c.lessons} bài học</span><span>·</span><span>${c.level}</span></div><h3><a href="course_detail.html?id=${c.id}">${c.title}</a></h3><div class="course-bottom"><span class="rating">${icon("star")} <strong>${c.rating}</strong> <span>(${c.students})</span></span><span>Từ <strong>${number(c.price)}đ</strong></span></div></article>`;
  }
  function home() {
    return `<main id="main"><section class="hero"><div class="container hero-grid"><div class="hero-copy"><div class="eyebrow">Kiến thức thật. Giá trị dài lâu.</div><h1>Học sâu hơn.<br><span>Vững nghề hơn.</span></h1><p>Học từ kinh nghiệm của những người thầy tận tâm.<br>Để mỗi kiến thức hôm nay trở thành sự tự tin<br class="desktop-break"> trên hành trình nghề Y ngày mai.</p><div class="button-row hero-actions"><a class="btn btn-red" href="courses.html">Khám phá lớp học ${icon("arrow", "small")}</a><button class="play-link" data-action="lesson" data-id="clinical-thinking"><span class="circle">${icon("play")}</span>Trải nghiệm một bài học</button></div><div class="social-proof"><div class="avatar-stack">${D.teachers.map((t) => `<img src="${img(t.image)}" alt="" width="29" height="29">`).join("")}</div><div><div class="stars" aria-label="Đánh giá 5 sao">★★★★★</div><p>Cùng <strong>12.600+</strong> người học viết tiếp hành trình.</p></div></div></div><div class="hero-gallery">${[D.teachers[1], D.teachers[0], D.teachers[2]].map((t) => `<a class="hero-person" href="instructors.html" aria-label="Gặp ${t.name}"><img src="${img(t.image)}" alt="Chân dung ${t.name}" fetchpriority="high"><div class="hero-person-copy"><small>${t.degree}</small><h3>${t.name}</h3><p>${t.short}</p></div></a>`).join("")}<div class="hero-note">BÀI HỌC TỪ KINH NGHIỆM. GÓC NHÌN TỪ THỰC HÀNH.</div></div></div></section><section class="proof-band" aria-label="Cộng đồng Meduc"><div class="container proof-inner"><p class="proof-intro">Một cộng đồng chung<br>niềm đam mê y học.</p><div class="proof-stat"><strong>12.600<span class="red">+</span></strong><span>người học<br>cùng tiến bộ</span></div><div class="proof-stat"><strong>150<span class="red">+</span></strong><span>chuyên đề<br>chọn lọc</span></div><div class="proof-stat"><strong>4.9<span class="red">/5</span></strong><span>từ những<br>trải nghiệm thật</span></div></div></section><div class="container discipline-bar">${[
      ["heart", "Nội khoa"],
      ["shield", "Ngoại khoa"],
      ["book", "Y khoa cơ sở"],
    ]
      .map(
        ([i, c]) =>
          `<a href="courses.html?category=${encodeURIComponent(c)}">${icon(i)}${c}</a>`,
      )
      .join(
        "",
      )}<a href="exams.html">${icon("layers")}Ngân hàng đề thi</a><a href="leaderboard.html">${icon("trophy")}Cộng đồng học tập</a></div><section class="section white-section"><div class="container"><div class="section-heading"><div><div class="eyebrow">Được chọn bởi người học</div><h2>Những lớp học<br>mở ra góc nhìn mới.</h2></div>${link("Tất cả khóa học", "courses.html")}</div><div class="course-grid home-course-grid">${D.courses.slice(0, 3).map(courseCard).join("")}</div></div></section><section class="section"><div class="container"><div class="mentor-feature"><div class="mentor-visual"><img src="${img("professor.jpg")}" alt="PGS.TS.BS. Nguyễn Hoàng An" loading="lazy"><div class="mentor-caption"><h3>Nguyễn Hoàng An</h3><p>PGS.TS.BS. · Giảng viên Nội khoa</p></div></div><div class="mentor-story"><div class="eyebrow">Học từ những người đã đi trước</div><div class="quote-mark">“</div><blockquote>Một bác sĩ giỏi không chỉ biết câu trả lời. Họ biết đặt đúng câu hỏi.</blockquote><p>Phía sau mỗi bài giảng là nhiều năm thực hành, những trải nghiệm quý giá và mong muốn truyền lại điều có ích cho thế hệ tiếp theo.</p>${link("Gặp những người thầy của bạn", "instructors.html")}</div></div></div></section><section class="section white-section"><div class="container"><div class="section-heading"><div><div class="eyebrow">Một hành trình, nhiều điểm bắt đầu</div><h2>Bạn đang ở đâu<br>trên hành trình nghề Y?</h2></div><p class="subhead">Dù mới bắt đầu hay đã đi một chặng dài,<br>luôn có một lớp học dành cho bạn.</p></div><div class="pathway-grid">${[
      [
        "01",
        "book",
        "Xây nền tảng",
        "Đi từ hiểu cấu trúc đến nắm cơ chế. Cho những năm tháng đầu tiên trên giảng đường.",
        "Khám phá kiến thức cơ sở",
        "courses.html?category=Y%20khoa%20c%C6%A1%20s%E1%BB%9F",
      ],
      [
        "02",
        "heart",
        "Vững lâm sàng",
        "Kết nối kiến thức với tình huống. Học cách quan sát và tư duy từ người đi trước.",
        "Bắt đầu học lâm sàng",
        "courses.html?level=L%C3%A2m%20s%C3%A0ng",
      ],
      [
        "03",
        "target",
        "Sẵn sàng bứt phá",
        "Luyện tập theo từng chủ đề, hiểu từng câu sai và nhìn thấy tiến bộ của chính mình.",
        "Tìm bộ đề phù hợp",
        "exams.html",
      ],
    ]
      .map(
        ([n, i, t, p, l, u]) =>
          `<article class="pathway-card"><div class="pathway-top"><span>${n}</span>${icon(i)}</div><h3>${t}</h3><p>${p}</p>${link(l, u)}</article>`,
      )
      .join(
        "",
      )}</div></div></section><section class="section"><div class="container practice-feature"><div class="practice-feature-copy"><div class="eyebrow">Hiểu thật. Nhớ lâu.</div><h2>Mỗi câu hỏi.<br>Một lần hiểu sâu hơn.</h2><p>Đừng chỉ dừng ở đáp án. Khám phá vì sao bạn đúng, hiểu lại điều mình sai và từng bước làm chủ kiến thức.</p><ul class="check-list"><li>${icon("check")}Bộ đề theo trường, năm học và môn học</li><li>${icon("check")}Giải thích ngay sau từng câu trả lời</li><li>${icon("check")}Lưu tiến độ, ôn lại những câu cần nhớ</li></ul><a class="btn btn-dark" href="exams.html">Vào không gian luyện tập ${icon("arrow", "small")}</a></div><div class="mini-quiz"><div class="mini-quiz-top"><span class="tag sage">GIẢI PHẪU · CƠ BẢN</span><span>01 / 05</span></div><h3>Tim người bình thường<br>có bốn buồng.</h3><div class="mini-options"><button data-action="mini-answer" data-answer="true">${icon("check")} Đúng</button><button data-action="mini-answer" data-answer="false">${icon("close")} Sai</button></div><p id="mini-feedback" class="mini-feedback" aria-live="polite" hidden></p><div class="mini-quiz-foot">${icon("bulb", "small")}Một phút hôm nay. Một chút vững vàng hơn.</div><div class="mini-progress">${icon("leaf", "small")} Kiến thức lớn lên mỗi ngày</div></div></div></section><section class="section white-section"><div class="container"><div class="section-heading"><div><div class="eyebrow">Bạn không đi một mình</div><h2>Cùng học. Cùng tiến bộ.</h2></div>${link("Gặp cộng đồng Meduc", "leaderboard.html")}</div><div class="quote-grid">${[
      [
        "MA",
        "sage",
        "“Lần đầu tiên mình thấy những kiến thức rời rạc được nối lại thành một bức tranh rõ ràng.”",
        "Minh Anh",
        "Sinh viên Y4 · ĐH Y Hà Nội",
      ],
      [
        "DH",
        "blue",
        "“Mình thích nhất phần giải thích câu sai. Mỗi lần làm lại là một lần hiểu thêm điều gì đó.”",
        "Đức Huy",
        "Sinh viên Y3 · ĐH Y Dược TP.HCM",
      ],
      [
        "PT",
        "rose",
        "“Một bài học ngắn mỗi tối. Nhẹ nhàng thôi, nhưng giúp mình giữ được nhịp học đều đặn.”",
        "Phương Thảo",
        "Sinh viên Y5 · ĐH Y Hà Nội",
      ],
    ]
      .map(
        ([a, c, q, n, r]) =>
          `<article class="community-quote"><div class="stars">★★★★★</div><blockquote>${q}</blockquote><div class="quote-person"><span class="initial-avatar ${c}">${a}</span><div><strong>${n}</strong><small>${r}</small></div></div></article>`,
      )
      .join(
        "",
      )}</div></div></section><section class="section"><div class="container journal-teaser"><img src="${img("study-editorial.jpg")}" alt="Sinh viên y khoa cùng học trong thư viện" loading="lazy"><div><div class="eyebrow">Meduc Journal</div><span class="tag">PHƯƠNG PHÁP HỌC · 6 PHÚT ĐỌC</span><h2>Học ít hơn, nhớ sâu hơn.<br>Tìm lại nhịp học của bạn.</h2><p>Có những ngày bạn đọc rất nhiều nhưng nhớ chẳng bao nhiêu. Thử bắt đầu lại bằng một cách học chủ động và vừa sức hơn.</p>${link("Dành vài phút cho góc nhìn mới", "article_detail.html")}</div></div></section><section class="section white-section" id="faq"><div class="container faq-layout"><div><div class="eyebrow">Trước khi bắt đầu</div><h2>Có thể bạn<br>đang muốn biết.</h2><p>Một vài câu trả lời để bạn dễ dàng<br>tìm thấy bước đầu tiên.</p></div><div class="faq-list">${[
      [
        "Meduc phù hợp với ai?",
        "Các lộ trình dành cho sinh viên y khoa ở giai đoạn nền tảng, người học lâm sàng và bác sĩ muốn hệ thống lại kiến thức. Bạn có thể lọc lớp học theo nhu cầu của mình.",
      ],
      [
        "Tôi có thể trải nghiệm trước một lớp học không?",
        "Có. Mở trang chi tiết khóa học và chọn “Trải nghiệm bài học” để xem một bài học đọc mẫu, trước khi quyết định hành trình tiếp theo.",
      ],
      [
        "Luyện đề có giải thích đáp án không?",
        "Mỗi câu hỏi đúng/sai đều có giải thích và một ý chính để ghi nhớ. Sau khi hoàn thành, bạn có thể xem lại toàn bộ bài hoặc chỉ luyện lại các câu làm sai.",
      ],
      [
        "Tôi có thể học trên điện thoại không?",
        "Có. Các trang được thiết kế cho cả máy tính và điện thoại. Những khóa học đã lưu và tiến độ luyện tập được giữ trên trình duyệt bạn đang dùng.",
      ],
    ]
      .map(
        ([q, a]) =>
          `<details><summary>${q}${icon("chevron", "chevron")}</summary><p>${a}</p></details>`,
      )
      .join(
        "",
      )}</div></div></section><section class="section"><div class="container closing-cta"><div class="eyebrow">Bắt đầu từ sự tò mò</div><h2>Người thầy thuốc bạn muốn trở thành.<br>Bắt đầu từ hôm nay.</h2><p>Một bài học, một góc nhìn, một bước tiến mới.</p><div class="button-row"><a class="btn btn-red" href="courses.html">Tìm lớp học của bạn ${icon("arrow", "small")}</a><a class="btn btn-outline" href="exams.html">Thử sức với một bộ đề</a></div></div></section></main>`;
  }

  function catalog() {
    const c = course("clinical-thinking");
    return `<main id="main" class="container"><div class="page-intro row"><div><div class="eyebrow">Thư viện lớp học</div><h1>Một góc nhìn mới.<br>Một bước tiến xa.</h1></div><p class="intro-note">Những lớp học được tạo nên từ kiến thức,<br>kinh nghiệm và sự tận tâm.</p></div><section class="catalog-feature"><div class="catalog-feature-copy"><div class="eyebrow">Lớp học của tháng</div><h2>Tư duy lâm sàng.<br>Bắt đầu từ những câu hỏi.</h2><p>Cùng PGS.TS.BS. Nguyễn Hoàng An xây dựng cách tiếp cận người bệnh có chiều sâu.</p><a class="btn btn-dark btn-sm" href="course_detail.html?id=${c.id}">Khám phá lớp học ${icon("arrow", "small")}</a></div><div class="catalog-feature-img"><img src="${img("professor.jpg")}" alt="Giảng viên Nguyễn Hoàng An"><span>24 BÀI HỌC · 6 GIỜ 20 PHÚT</span></div></section><div class="filter-toolbar"><div class="pill-group" id="course-categories" aria-label="Lọc chuyên ngành">${["Tất cả", "Nội khoa", "Ngoại khoa", "Y khoa cơ sở"].map((x, i) => `<button class="pill ${i === 0 ? "active" : ""}" data-category="${x}" aria-pressed="${i === 0}">${x}</button>`).join("")}</div><label class="search-field">${icon("search")}<input id="course-search" type="search" placeholder="Bạn muốn học điều gì?" aria-label="Tìm khóa học"></label></div><div class="catalog-layout"><aside class="filter-sidebar" aria-label="Bộ lọc khóa học"><h3>Tìm lớp học phù hợp</h3><div class="filter-group"><strong>Hành trình học tập</strong><label><input type="checkbox" name="level" value="Nền tảng">Nền tảng</label><label><input type="checkbox" name="level" value="Lâm sàng">Lâm sàng</label></div><div class="filter-group"><strong>Bộ sưu tập của bạn</strong><label><input id="only-saved-courses" type="checkbox">Đã lưu</label></div><button class="filter-reset" data-action="reset-courses">Xóa bộ lọc</button><div class="sidebar-note">${icon("bulb")}<strong>Chưa biết bắt đầu từ đâu?</strong><p>Hãy thử một lớp học nền tảng. Điều nhỏ hôm nay có thể mở ra một góc nhìn lớn.</p></div></aside><div><div class="results-bar"><span id="course-count" role="status"></span><label>Sắp xếp<select id="course-sort" class="select-plain" aria-label="Sắp xếp khóa học"><option value="popular">Được yêu thích</option><option value="newest">Mới nhất</option><option value="price">Giá từ thấp đến cao</option></select></label></div><div id="course-results" class="course-grid"></div></div></div></main>`;
  }

  function detail() {
    const c = course(params.get("id"));
    const t = teacher(c.teacher);
    document.title = c.title + " — Meduc";
    return `<main id="main"><div class="container"><nav class="bread" aria-label="Đường dẫn"><a href="index.html">Trang chủ</a>${icon("right")}<a href="courses.html">Khóa học</a>${icon("right")}<span>${c.category}</span></nav><section class="course-hero"><div><div class="eyebrow">Meduc Originals · ${c.category}</div><h1>${c.title}</h1><p class="subhead">${c.description}</p><button class="teacher-byline" data-action="profile" data-id="${t.id}"><img src="${img(t.image)}" alt=""><span><strong>${t.degree} ${t.name}</strong><small>${t.years} kinh nghiệm giảng dạy và thực hành</small></span></button><div class="course-rating">${icon("star")}<strong>${c.rating}</strong><span>(${c.students} người học)</span><span>·</span><span>${c.level}</span></div><div class="button-row"><button class="btn btn-red" data-action="lesson" data-id="${c.id}">Trải nghiệm bài học ${icon("arrow", "small")}</button><button class="btn btn-outline" data-action="save" data-kind="courses" data-id="${c.id}" aria-pressed="${list("saved-courses").includes(c.id)}">${icon("bookmark", "small")} <span>${list("saved-courses").includes(c.id) ? "Đã lưu lớp học" : "Lưu lớp học"}</span></button></div></div><div class="detail-cover"><img src="${img(t.image)}" alt="${t.name}"><span class="cover-label">MEDUC ORIGINALS</span><button class="preview-trigger" data-action="lesson" data-id="${c.id}" aria-label="Mở bài học mẫu"><span class="big-play">${icon("book")}</span><span>Khám phá bài học mẫu</span></button><div class="cover-teacher"><small>HỌC CÙNG</small><h3>${t.name}</h3></div></div></section><div class="course-facts"><div>${icon("book")}<span><strong>${c.lessons} bài học</strong><small>Nội dung theo từng chủ đề</small></span></div><div>${icon("clock")}<span><strong>${c.hours}</strong><small>Học theo nhịp của bạn</small></span></div><div>${icon("layers")}<span><strong>Tài liệu đi kèm</strong><small>Hệ thống kiến thức trọng tâm</small></span></div><div>${icon("target")}<span><strong>Luyện tập sau bài</strong><small>Hiểu sâu qua từng câu hỏi</small></span></div></div></div><section class="section white-section" style="padding-top:0"><div class="container course-content-layout"><div class="course-content-main"><div class="detail-tabs" role="tablist" aria-label="Thông tin lớp học">${[
      ["overview", "Tổng quan"],
      ["curriculum", "Nội dung học"],
      ["teacher", "Giảng viên"],
      ["reviews", "Đánh giá"],
    ]
      .map(
        ([id, n], i) =>
          `<button class="detail-tab ${i === 0 ? "active" : ""}" role="tab" id="tab-${id}" aria-selected="${i === 0}" aria-controls="panel-${id}" tabindex="${i === 0 ? "0" : "-1"}" data-tab="${id}">${n}</button>`,
      )
      .join(
        "",
      )}</div><div class="tab-content" id="panel-overview" role="tabpanel" aria-labelledby="tab-overview"><h2>Hiểu bản chất.<br>Tự tin đi xa hơn.</h2><p>${c.description} Lớp học được chia thành những phần ngắn, giúp bạn vừa học vừa suy ngẫm và từng bước kết nối kiến thức.</p><div class="outcomes"><strong>Sau lớp học này, bạn có thể</strong><ul class="check-list">${c.outcomes.map((s) => `<li>${icon("checkCircle")}${s}</li>`).join("")}</ul></div><h3>Lớp học này dành cho bạn nếu…</h3><p>Bạn muốn xây dựng kiến thức ${c.category.toLowerCase()} có hệ thống, tìm lại những điểm chưa thật sự rõ và tạo một nhịp học bền vững. Bạn không cần biết mọi thứ trước khi bắt đầu — chỉ cần sự tò mò.</p><h3>Một phần nội dung lớp học</h3>${chapterMarkup(c, 0, true)}</div><div class="tab-content" id="panel-curriculum" role="tabpanel" aria-labelledby="tab-curriculum" hidden><h2>Hành trình trong lớp học</h2><p>${c.chapters.length} chương · ${c.lessons} bài học · ${c.hours}</p>${c.chapters.map((_, i) => chapterMarkup(c, i, i === 0)).join("")}</div><div class="tab-content" id="panel-teacher" role="tabpanel" aria-labelledby="tab-teacher" hidden><h2>Người đồng hành của bạn</h2><div class="teacher-inline"><img src="${img(t.image)}" alt="${t.name}"><div><h3>${t.name}</h3><p>${t.degree} · ${t.field}</p><p style="margin-top:16px">${t.bio}</p><button class="text-link" data-action="profile" data-id="${t.id}">Tìm hiểu thêm ${icon("arrow")}</button></div></div></div><div class="tab-content" id="panel-reviews" role="tabpanel" aria-labelledby="tab-reviews" hidden><h2>Những điều người học chia sẻ</h2><p><span class="stars">★★★★★</span> <strong>${c.rating}/5</strong> · Đánh giá trong bản xem trước</p>${[
      [
        "MA",
        "Minh Anh",
        "Bài giảng rõ ràng, chia từng phần vừa sức. Mình có thể dừng lại suy nghĩ và kết nối với những gì đã học.",
      ],
      [
        "DH",
        "Đức Huy",
        "Thích cách thầy cô giải thích từ bản chất. Phần tự kiểm tra giúp mình thấy ngay chỗ còn chưa hiểu.",
      ],
    ]
      .map(
        ([a, n, r]) =>
          `<div class="review-card"><div class="quote-person"><span class="initial-avatar">${a}</span><div><strong>${n}</strong><small>Đã học lớp này</small></div></div><p>${r}</p><span class="stars">★★★★★</span></div>`,
      )
      .join(
        "",
      )}</div></div><aside class="enroll-card"><div class="eyebrow">Đầu tư cho hành trình của bạn</div><h3>Một lớp học.<br>Nhiều điều ở lại.</h3><div class="price">${number(c.price)}<small>đ</small></div><p>Học trọn bộ · Theo nhịp của bạn</p><button class="btn btn-red btn-full" data-action="enroll" data-id="${c.id}">Bắt đầu hành trình ${icon("arrow", "small")}</button><button class="btn btn-outline btn-full" data-action="lesson" data-id="${c.id}">Trải nghiệm bài học</button><ul class="check-list"><li>${icon("check")}${c.lessons} bài học chọn lọc</li><li>${icon("check")}Tài liệu và ghi chú trọng tâm</li><li>${icon("check")}Câu hỏi tự luyện sau bài học</li><li>${icon("check")}Học trên máy tính và điện thoại</li></ul><p class="fineprint">Bản trải nghiệm giao diện. Chưa phát sinh thanh toán.</p></aside></div></section><section class="section"><div class="container"><div class="section-heading"><div class="eyebrow">Tiếp tục khám phá</div><h2>Thêm một góc nhìn.</h2></div><div class="course-grid home-course-grid">${D.courses
      .filter((x) => x.id !== c.id)
      .slice(0, 3)
      .map(courseCard)
      .join("")}</div></div></section></main>`;
  }
  function chapterMarkup(c, i, open = false) {
    const total = Math.floor(c.lessons / 4) + (i < c.lessons % 4 ? 1 : 0);
    return `<details class="chapter" ${open ? "open" : ""}><summary><span class="chapter-number">0${i + 1}</span>${c.chapters[i]}<small>${total} bài</small>${icon("chevron", "chevron")}</summary>${Array.from({ length: total }, (_, j) => `<button class="lesson-row ${i === 0 && j === 0 ? "preview" : ""}" data-action="${i === 0 && j === 0 ? "lesson" : "enroll"}" data-id="${c.id}">${icon(i === 0 && j === 0 ? "book" : "lock")}<span>${j === 0 ? "Bắt đầu từ nền tảng" : j === 1 ? "Những câu hỏi cần đặt ra" : j === total - 1 ? "Tổng kết và tự kiểm tra" : `Góc nhìn ${j + 1}: kết nối kiến thức`}</span><small>${i === 0 && j === 0 ? "Học thử" : 12 + j * 3 + " phút"}</small></button>`).join("")}</details>`;
  }

  function instructors() {
    return `<main id="main" class="container"><section class="instructor-intro"><div class="eyebrow">Gặp những người truyền cảm hứng</div><h1>Những người thầy.<br><span class="muted">Những góc nhìn lớn.</span></h1><p>Họ mang đến nhiều hơn một bài giảng.<br>Đó là kinh nghiệm, góc nhìn và tình yêu dành cho nghề Y.</p></section><div class="pill-group instructor-filters" id="teacher-filters" aria-label="Lọc giảng viên">${["Tất cả", "Nội khoa", "Ngoại khoa", "Y khoa cơ sở"].map((f, i) => `<button class="pill ${i === 0 ? "active" : ""}" data-field="${f}" aria-pressed="${i === 0}">${f}</button>`).join("")}</div><div class="instructor-grid" id="instructor-results">${D.teachers.map(instructorPoster).join("")}</div><section class="instructor-manifesto"><div><div class="eyebrow">Phía sau mỗi bài học</div><h2>Tri thức được chia sẻ.<br>Giá trị được nối dài.</h2></div><div class="manifesto-text"><div><h3>Kinh nghiệm trở thành bài học</h3><p>Những điều đúc kết qua nhiều năm thực hành được kể lại bằng một ngôn ngữ rõ ràng, gần gũi.</p></div><div><h3>Một tinh thần học không ngừng</h3><p>Không chỉ truyền đạt điều đã biết, mà còn khơi mở những câu hỏi và sự tò mò trong bạn.</p></div></div></section></main>`;
  }
  function instructorPoster(t) {
    return `<button class="instructor-poster" data-action="profile" data-id="${t.id}" aria-label="Tìm hiểu về ${t.name}"><img src="${img(t.image)}" alt="Chân dung ${t.name}"><span class="poster-top"><span>MEDUC ORIGINALS</span><span>0${D.teachers.indexOf(t) + 1}</span></span><div class="poster-info"><small>${t.degree}</small><h2>${t.name}</h2><p>${t.short}</p><div class="poster-bottom"><span>${t.field}</span><span>Gặp giảng viên ${icon("upRight", "small")}</span></div></div></button>`;
  }

  function article() {
    return `<div class="article-progress" aria-hidden="true"></div><main id="main"><div class="container"><header class="article-header"><div class="eyebrow">Meduc Journal · Phương pháp học</div><h1>Học ít hơn, nhớ sâu hơn:<br>tìm lại nhịp học Y của bạn.</h1><p class="article-deck">Không phải lúc nào học thêm một giờ cũng là câu trả lời.<br>Đôi khi, điều cần thay đổi là cách bạn dành một giờ ấy.</p><div class="article-byline"><span class="initial-avatar">m.</span><strong>Ban biên tập Meduc</strong><span>·</span><time datetime="2026-09-18">18 tháng 9, 2026</time><span>·</span><span>6 phút đọc</span></div></header><figure style="margin:0"><img class="article-hero-image" src="${img("study-editorial.jpg")}" alt="Ba sinh viên y khoa trao đổi bài học bên cửa sổ thư viện"><figcaption class="image-caption">Một nhịp học tốt bắt đầu từ sự chủ động, không phải từ số giờ ngồi vào bàn.</figcaption></figure><div class="article-layout"><aside class="article-toc" aria-label="Mục lục bài viết"><strong>TRONG BÀI VIẾT NÀY</strong><a href="#active-recall">01. Thử nhớ trước khi đọc lại</a><a href="#spacing">02. Để kiến thức có khoảng thở</a><a href="#connect">03. Nối lại những mảnh ghép</a><a href="#small-start">04. Bắt đầu thật nhỏ</a><div class="article-tools"><button class="icon-btn" data-action="save-article" aria-label="Lưu bài viết" aria-pressed="${read("article-saved", false)}">${icon("bookmark")}</button><button class="icon-btn" data-action="share" aria-label="Sao chép liên kết bài viết">${icon("share")}</button></div></aside><article class="article-body"><p class="lead">Có lẽ bạn đã từng trải qua một buổi tối như thế: ngồi trước một chồng giáo trình, đọc hết chương này đến chương khác, rồi khép sách lại với cảm giác mình chưa giữ được bao nhiêu.</p><p>Học Y có rất nhiều điều cần nhớ. Nhưng một cuốn sách được tô kín màu không nhất thiết là một cuốn sách đã được hiểu. Thử dành sự chú ý cho một câu hỏi khác: sau buổi học này, mình có thể tự giải thích được điều gì?</p><h2 id="active-recall">01. Thử nhớ trước khi đọc lại</h2><p>Sau một phần bài học, hãy khép tài liệu và tự kể lại ý chính bằng lời của mình. Viết ra vài dòng, vẽ một sơ đồ nhỏ hoặc đặt cho bản thân ba câu hỏi. Khi chưa nhớ ra, đó chính là điểm để quay lại đọc kỹ hơn.</p><p>Đừng quá vội nhìn đáp án. Khoảng dừng để tự suy nghĩ giúp bạn nhận ra ranh giới giữa “mình thấy quen” và “mình thực sự giải thích được”.</p><blockquote>Đừng chỉ hỏi “Mình đã đọc hết chưa?”.<br>Hãy hỏi “Mình có thể kể lại điều gì?”.</blockquote><h2 id="spacing">02. Để kiến thức có khoảng thở</h2><p>Thay vì đặt tất cả thời gian ôn tập vào một buổi, bạn có thể thử chia thành những cuộc hẹn ngắn với kiến thức. Hôm nay đọc và hiểu. Hôm sau tự kiểm tra. Vài ngày tiếp theo, quay lại phần còn vướng.</p><p>Không cần ép mình theo một lịch cứng. Điều đáng giữ là thói quen quay lại, chú ý điều đã quên và điều chỉnh khoảng cách cho phù hợp với môn học của bạn.</p><div class="article-callout"><strong>Một gợi ý dễ thử</strong><p>Cuối mỗi buổi học, ghi lại ba câu hỏi bạn muốn trả lời vào ngày mai. Chỉ ba câu thôi — đủ nhỏ để không ngại bắt đầu, đủ rõ để biết mình đang ôn điều gì.</p></div><h2 id="connect">03. Nối lại những mảnh ghép</h2><p>Một khái niệm sẽ bớt khô khi có chỗ đứng trong bức tranh chung. Khi học một cấu trúc, thử nối nó với chức năng. Khi gặp một cơ chế, thử mô tả bằng một chuỗi nguyên nhân và kết quả.</p><p>Bạn cũng có thể giải thích cho một người bạn. Những chỗ đang kể mà phải dừng lại thường là những chỗ cần thêm một lần suy nghĩ. Học cùng nhau không nhất thiết là cùng đọc một trang; đôi khi là cùng đặt một câu hỏi hay.</p><h2 id="small-start">04. Bắt đầu thật nhỏ, giữ nhịp thật đều</h2><p>Không cần xây dựng một hệ thống học tập hoàn hảo ngay tối nay. Thử dành một khoảng thời gian ngắn, không xao nhãng, cho một chủ đề cụ thể:</p><ol class="article-plan"><li><strong>10′</strong><span>Đọc hoặc xem một phần bài học. Ghi lại một câu hỏi đáng chú ý.</span></li><li><strong>05′</strong><span>Khép tài liệu. Tự giải thích ý chính bằng lời của bạn.</span></li><li><strong>05′</strong><span>Làm vài câu tự kiểm tra và đọc kỹ phần giải thích.</span></li></ol><p>Hai mươi phút là một gợi ý để bắt đầu, không phải một công thức bắt buộc. Bạn có thể rút ngắn, kéo dài hoặc đổi thứ tự. Một nhịp học hợp với cuộc sống của bạn mới là nhịp học bạn dễ quay lại.</p><div class="article-callout"><div class="eyebrow">Biến một ý tưởng thành hành động</div><strong>Thử một bộ câu hỏi ngắn ngay hôm nay.</strong><p>Chọn một chủ đề quen thuộc, trả lời và dành thêm một phút cho câu mình làm sai.</p>${link("Tìm bộ đề phù hợp", "exams.html")}</div><div class="article-end"><span>Kiến thức · Thói quen · Hành trình học Y</span><button class="text-link ${read("article-saved", false) ? "saved" : ""}" data-action="save-article" aria-pressed="${read("article-saved", false)}">${icon("bookmark", "small")} <span>${read("article-saved", false) ? "Đã lưu" : "Lưu để đọc lại"}</span></button></div></article><span class="article-side-note">MEDUC JOURNAL — GÓC NHÌN CHO NGƯỜI HỌC Y</span></div></div></main>`;
  }

  function exams() {
    return `<main id="main" class="container"><section class="study-intro"><div><div class="eyebrow">Không gian luyện tập</div><h1>Kiến thức vững.<br><span class="muted">Tâm thế sẵn sàng.</span></h1><p>Chọn đúng điều cần học. Hiểu sâu qua từng câu hỏi.</p></div><div class="streak-widget">${icon("fire")}<div><strong>7 ngày giữ nhịp</strong><p>Mỗi ngày một chút. Bạn đang làm rất tốt.</p></div></div></section><div class="learning-path" aria-label="Lộ trình luyện tập"><div class="learning-step active"><span>1</span><div><strong>Chọn bộ đề</strong><small>Theo hành trình của bạn</small></div></div><div class="learning-step"><span>2</span><div><strong>Thử sức & hiểu sâu</strong><small>Giải thích từng câu trả lời</small></div></div><div class="learning-step"><span>3</span><div><strong>Nhìn lại tiến bộ</strong><small>Ôn lại điều cần nhớ</small></div></div></div><div class="exam-layout"><aside class="exam-sidebar" aria-label="Chọn lộ trình luyện thi"><h3>Lộ trình của bạn</h3><div class="tree-group"><label for="exam-school">01 · Trường của bạn</label><select id="exam-school"><option value="">Tất cả các trường</option><option value="HMU">ĐH Y Hà Nội</option><option value="UMP">ĐH Y Dược TP.HCM</option></select></div><div class="tree-line"></div><div class="tree-group"><label for="exam-year">02 · Năm học</label><select id="exam-year"><option value="">Tất cả năm học</option><option>Y1</option><option>Y2</option><option>Y3</option></select></div><div class="tree-line"></div><div class="tree-group"><label for="exam-subject">03 · Môn học</label><select id="exam-subject"><option value="">Tất cả môn học</option><option>Giải phẫu</option><option>Sinh lý</option><option>Nội khoa</option></select></div><div class="tree-topic">${icon("layers")}Chuyên đề Tim mạch</div><label class="saved-filter"><input type="checkbox" id="only-saved-exams">Bộ đề đã lưu</label><button class="filter-reset" data-action="reset-exams" style="margin-top:16px">Xóa bộ lọc</button><div class="sidebar-note">${icon("leaf")}<strong>Hiểu trước, nhớ sau.</strong><p>Dành thời gian cho lời giải. Mỗi câu sai là một cơ hội hiểu thêm.</p></div></aside><div><div class="filter-toolbar"><div class="pill-group" id="exam-levels" aria-label="Độ khó">${["Tất cả", "Cơ bản", "Vận dụng"].map((f, i) => `<button class="pill ${i === 0 ? "active" : ""}" data-level="${f}" aria-pressed="${i === 0}">${f}</button>`).join("")}</div><label class="search-field">${icon("search")}<input type="search" id="exam-search" placeholder="Tìm tên bộ đề…" aria-label="Tìm bộ đề"></label></div><div class="results-bar"><span id="exam-count" role="status"></span><span>Đúng / Sai · Có giải thích</span></div><div class="exam-grid" id="exam-results"></div><div class="library-note"><p>Một bộ đề nhỏ cũng là một bước tiến.<br>Hãy bắt đầu với chủ đề bạn muốn hiểu hơn hôm nay.</p>${link("Xem nhịp học cộng đồng", "leaderboard.html")}</div></div></div></main>`;
  }
  function examCard(e) {
    const saved = read("quiz-" + e.id, null);
    const completed = saved?.complete;
    const progress = Array.isArray(saved?.answers)
      ? Object.values(saved.answers).filter((a) => a !== null).length
      : 0;
    return `<article class="exam-card"><div class="exam-art ${e.color}"><span class="exam-code">MEDUC PRACTICE / ${e.school}</span><span class="tag">${e.level}</span>${icon(e.icon)}${saveButton(e.id, "exams", "bộ đề")}</div><div class="exam-card-body"><div class="exam-meta"><span>${schoolName(e.school)}</span><span>·</span><span>${e.year}</span><span>·</span><span>${e.subject}</span></div><h3>${e.title}</h3><p>${e.description}</p><div class="exam-facts"><span>${icon("layers")}5 câu hỏi</span><span>${icon("clock")}5 phút</span><span>${icon("book")}Có lời giải</span></div><div class="exam-card-footer"><span>${completed ? "Đã hoàn thành" : progress ? `Đã trả lời ${progress}/5 câu` : "Sẵn sàng bắt đầu"}</span>${link(completed ? "Xem kết quả" : progress ? "Tiếp tục" : "Luyện ngay", "practice.html?exam=" + e.id)}</div></div></article>`;
  }

  function leaderboard() {
    return `<main id="main" class="container"><header class="leaderboard-heading"><div class="eyebrow">Cùng nhau tiến bộ</div><h1>Mỗi ngày một chút.<br><span class="muted">Mỗi bước một vươn xa.</span></h1><p>Tôn vinh sự kiên trì, không chỉ những điểm số.<br>Hôm nay, bạn đã tiến xa hơn hôm qua.</p></header><div class="leaderboard-controls"><div class="segmented" id="rank-period" aria-label="Kỳ xếp hạng"><button class="active" data-period="week" aria-pressed="true">Tuần này</button><button data-period="month" aria-pressed="false">Tháng này</button></div><select class="select-plain" id="rank-school" aria-label="Trường trên bảng xếp hạng"><option value="">Tất cả các trường</option><option value="HMU">ĐH Y Hà Nội</option><option value="UMP">ĐH Y Dược TP.HCM</option></select></div><section class="podium" id="rank-podium" aria-label="Ba người học dẫn đầu"></section><div class="ranking-layout"><section class="ranking-table" aria-label="Danh sách xếp hạng"><div class="ranking-table-head"><h2>Những bước tiến nổi bật</h2><span id="rank-period-label">21 — 27 tháng 9, 2026</span></div><div class="ranking-row labels"><span>HẠNG</span><span>NGƯỜI HỌC</span><span>GIỮ NHỊP</span><span style="text-align:right">ĐIỂM XP</span></div><div id="rank-table" role="status"></div></section><aside class="ranking-sidebar"><div class="ranking-aside"><div class="eyebrow">Hành trình của bạn</div><h3>7 ngày thật đáng tự hào.</h3><p>Một chuỗi ngày nhỏ đang tạo nên thói quen lớn. Hãy tiếp tục giữ nhịp nhé.</p><div class="week-streak">${["T3", "T4", "T5", "T6", "T7", "CN", "T2"].map((d) => `<div class="week-day"><span>${icon("check")}</span>${d}</div>`).join("")}</div><a class="btn btn-dark btn-full" href="exams.html">Học tiếp hôm nay ${icon("arrow", "small")}</a></div><div class="ranking-rules"><strong>Điểm số kể câu chuyện gì?</strong><p>Mỗi câu trả lời đúng trong phiên luyện tập nhận 20 XP. Làm lại giúp củng cố kiến thức; bảng xếp hạng ở đây là một bộ dữ liệu minh họa.</p></div></aside></div></main>`;
  }

  function practice() {
    return `<main id="main" class="container practice-shell"><div id="practice-content"></div><div class="practice-bottom">${icon("shield", "small")} Tiến độ được lưu trên trình duyệt này.</div></main>`;
  }

  const pages = {
    home,
    courses: catalog,
    course: detail,
    instructors,
    article,
    exams,
    leaderboard,
    practice,
  };
  $("#app").innerHTML =
    header() +
    (pages[page] || home)() +
    (page === "practice" ? "" : footer()) +
    '<div id="toast" class="toast" role="status" aria-live="polite"></div><dialog id="dialog" aria-labelledby="dialog-title"></dialog>';

  let toastTimer;
  function toast(message) {
    $("#toast").textContent = message;
    $("#toast").classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => $("#toast").classList.remove("show"), 3200);
  }
  const dialog = $("#dialog");
  function openDialog(content, cls = "") {
    dialog.className = cls;
    dialog.innerHTML = `<button class="icon-btn dialog-close" data-action="close-dialog" aria-label="Đóng">${icon("close")}</button>${content}`;
    if (!dialog.open) dialog.showModal();
  }
  dialog.addEventListener("click", (e) => {
    if (e.target === dialog) {
      const r = dialog.getBoundingClientRect();
      if (
        e.clientX < r.left ||
        e.clientX > r.right ||
        e.clientY < r.top ||
        e.clientY > r.bottom
      )
        dialog.close();
    }
  });
  function profile(id) {
    const t = teacher(id);
    openDialog(
      `<div class="profile-dialog"><img src="${img(t.image)}" alt="${t.name}"><div><div class="eyebrow">${t.degree} · ${t.field}</div><h2 id="dialog-title">${t.name}</h2><p>${t.bio}</p><div class="profile-stats"><div><strong>${t.years}</strong><small>Kinh nghiệm giảng dạy</small></div><div><strong>${D.courses.filter((c) => c.teacher === id).length} lớp học</strong><small>Trên Meduc</small></div></div>${link("Học cùng " + t.name.split(" ").slice(-1)[0], "courses.html?teacher=" + t.id)}<p style="font-size:9px;margin-top:16px;color:var(--muted)">Nhân vật và học vị minh họa cho bản thiết kế.</p></div></div>`,
    );
  }
  const lessonSlides = [
    {
      title: "Bắt đầu bằng một câu hỏi",
      body: "Trước khi đọc, hãy ghi lại điều bạn muốn hiểu từ bài học này. Một câu hỏi cụ thể giúp bạn biết mình đang tìm kiếm điều gì.",
    },
    {
      title: "Kết nối với điều đã biết",
      body: "Chọn một khái niệm trong chủ đề. Bạn có thể nối nó với kiến thức nào đã học? Hãy phác một sơ đồ nhỏ bằng lời của mình.",
    },
    {
      title: "Dừng lại để tự giải thích",
      body: "Khép tài liệu và kể lại ý chính. Nếu còn một chỗ chưa rõ, đánh dấu nó để quay lại. Đó chính là điểm bắt đầu của lần học tiếp theo.",
    },
  ];
  let currentLesson = null,
    lessonIndex = 0;
  function lesson(id) {
    currentLesson = course(id);
    lessonIndex = 0;
    drawLesson();
  }
  function drawLesson() {
    const c = currentLesson,
      t = teacher(c.teacher),
      s = lessonSlides[lessonIndex];
    openDialog(
      `<div class="lesson-preview"><div class="lesson-preview-visual"><img src="${img(t.image)}" alt="${t.name}"><div class="cover-teacher"><small>HỌC CÙNG</small><h3>${t.name}</h3><span>${c.label}</span></div></div><div class="lesson-preview-content"><div class="eyebrow">Bài học đọc mẫu · 3 phút</div><h2 id="dialog-title">Một cách bắt đầu<br>để hiểu sâu hơn.</h2><p>Khởi động hành trình ${c.label.toLowerCase()} bằng ba bước nhỏ.</p><div class="lesson-slide"><span>0${lessonIndex + 1} / 03</span><h3>${s.title}</h3><p>${s.body}</p></div><div class="lesson-controls"><button class="icon-btn" data-action="lesson-prev" aria-label="Phần trước" ${lessonIndex === 0 ? "disabled" : ""}>${icon("left")}</button><small>${lessonIndex + 1} / ${lessonSlides.length}</small><button class="btn btn-dark btn-sm" data-action="${lessonIndex === 2 ? "lesson-finish" : "lesson-next"}">${lessonIndex === 2 ? "Hoàn thành" : "Tiếp theo"} ${icon("arrow", "small")}</button></div><div class="lesson-progress"><span style="width:${((lessonIndex + 1) / 3) * 100}%"></span></div></div></div>`,
    );
  }
  function enroll(id) {
    const c = course(id);
    openDialog(
      `<div class="dialog-inner"><div class="eyebrow">Hành trình của bạn</div><h2 id="dialog-title">Bắt đầu bằng một bài học.</h2><p>${c.title}</p><div class="enrollment-note">${icon("book")}<strong>Lớp học đã sẵn sàng để bạn khám phá.</strong><p>Đây là bản trải nghiệm giao diện, không thu phí và không yêu cầu thông tin thanh toán. Bạn có thể đọc bài học mẫu hoặc thử sức với một bộ đề.</p></div><div class="button-row"><button class="btn btn-red" data-action="lesson" data-id="${c.id}">Mở bài học mẫu ${icon("arrow", "small")}</button><a class="btn btn-outline" href="exams.html">Vào luyện tập</a></div></div>`,
    );
  }
  function search() {
    openDialog(
      `<div class="dialog-inner"><div class="eyebrow">Luôn có điều mới để học</div><h2 id="dialog-title">Bạn đang tò mò điều gì?</h2><label class="search-field">${icon("search")}<input id="global-search" type="search" placeholder="Tìm khóa học, giảng viên, chủ đề…" aria-label="Tìm nội dung trên Meduc"></label><div class="search-results" id="global-results"></div></div>`,
      "search-dialog",
    );
    const render = () => {
      const q = norm($("#global-search").value);
      const found = D.courses.filter((c) =>
        norm(
          c.title + " " + c.category + " " + teacher(c.teacher).name,
        ).includes(q),
      );
      $("#global-results").innerHTML = found.length
        ? found
            .slice(0, 5)
            .map(
              (c) =>
                `<a class="search-result" href="course_detail.html?id=${c.id}"><img src="${img(teacher(c.teacher).image)}" alt=""><span><strong>${c.title}</strong><small>${teacher(c.teacher).name} · ${c.category}</small></span>${icon("arrow")}</a>`,
            )
            .join("")
        : "<p>Chưa tìm thấy lớp học. Thử một chủ đề khác nhé.</p>";
    };
    $("#global-search").addEventListener("input", render);
    render();
    $("#global-search").focus();
  }

  document.addEventListener("click", (e) => {
    const b = e.target.closest("[data-action]");
    if (!b) return;
    const a = b.dataset.action;
    if (a === "menu") {
      const open = $("#main-nav").classList.toggle("open");
      b.setAttribute("aria-expanded", String(open));
      b.setAttribute("aria-label", open ? "Đóng menu" : "Mở menu");
    } else if (a === "search") search();
    else if (a === "close-dialog") dialog.close();
    else if (a === "profile") profile(b.dataset.id);
    else if (a === "lesson") lesson(b.dataset.id);
    else if (a === "enroll") enroll(b.dataset.id);
    else if (a === "lesson-prev") {
      lessonIndex = Math.max(0, lessonIndex - 1);
      drawLesson();
    } else if (a === "lesson-next") {
      lessonIndex = Math.min(2, lessonIndex + 1);
      drawLesson();
    } else if (a === "lesson-finish") {
      write("lesson-" + currentLesson.id, true);
      dialog.close();
      toast("Bạn đã hoàn thành bài học mẫu. Một bước tiến mới!");
    } else if (a === "save") {
      const kind = b.dataset.kind,
        id = b.dataset.id;
      let saved = list("saved-" + kind);
      const was = saved.includes(id);
      saved = was ? saved.filter((x) => x !== id) : [...saved, id];
      write("saved-" + kind, saved);
      $$(`[data-action="save"][data-kind="${kind}"][data-id="${id}"]`).forEach(
        (el) => {
          el.classList.toggle("saved", !was);
          el.setAttribute("aria-pressed", String(!was));
          if (el.classList.contains("save-btn"))
            el.setAttribute(
              "aria-label",
              `${was ? "Lưu" : "Bỏ lưu"} ${kind === "exams" ? "bộ đề" : "khóa học"}`,
            );
          const text = $("span", el);
          if (text) text.textContent = was ? "Lưu lớp học" : "Đã lưu lớp học";
        },
      );
      toast(
        was
          ? "Đã bỏ khỏi danh sách lưu."
          : "Đã lưu để bạn quay lại bất cứ lúc nào.",
      );
      if (page === "courses" && $("#only-saved-courses").checked)
        renderCourses();
      if (page === "exams" && $("#only-saved-exams").checked) renderExams();
    } else if (a === "save-article") {
      const saved = !read("article-saved", false);
      write("article-saved", saved);
      $$('[data-action="save-article"]').forEach((el) => {
        el.classList.toggle("saved", saved);
        el.setAttribute("aria-pressed", String(saved));
        const span = $("span", el);
        if (span) span.textContent = saved ? "Đã lưu" : "Lưu để đọc lại";
      });
      toast(
        saved ? "Đã lưu bài viết trên trình duyệt này." : "Đã bỏ lưu bài viết.",
      );
    } else if (a === "share") {
      if (navigator.clipboard?.writeText)
        navigator.clipboard
          .writeText(location.href)
          .then(() => toast("Đã sao chép liên kết bài viết."))
          .catch(() => showShare());
      else showShare();
    } else if (a === "mini-answer") {
      const feedback = $("#mini-feedback");
      feedback.hidden = false;
      feedback.innerHTML =
        (b.dataset.answer === "true" ? "Chính xác. " : "Chưa đúng rồi. ") +
        'Tim có hai tâm nhĩ và hai tâm thất. <a class="text-link" href="practice.html?exam=heart-hmu">Thử thêm một câu ' +
        icon("arrow", "small") +
        "</a>";
    } else if (a === "reset-courses") resetCourses();
    else if (a === "reset-exams") resetExams();
  });
  function showShare() {
    openDialog(
      `<div class="dialog-inner"><h2 id="dialog-title">Chia sẻ bài viết</h2><label class="text-area-label" for="share-url">Sao chép đường dẫn này</label><input id="share-url" class="scratchpad" style="min-height:45px" readonly value="${esc(location.href)}"></div>`,
    );
    $("#share-url").select();
  }

  // Read optional starting filters from shareable category, level and teacher links.
  let activeCategory = params.get("category") || "Tất cả";
  let activeTeacher = params.get("teacher") || "";
  function renderCourses() {
    const q = norm($("#course-search").value);
    const levels = $$('input[name="level"]:checked').map((e) => e.value);
    const saved = $("#only-saved-courses").checked;
    const sort = $("#course-sort").value;
    let found = D.courses.filter(
      (c) =>
        (activeCategory === "Tất cả" || c.category === activeCategory) &&
        (!activeTeacher || c.teacher === activeTeacher) &&
        (!levels.length || levels.includes(c.level)) &&
        (!saved || list("saved-courses").includes(c.id)) &&
        norm(
          c.title + " " + teacher(c.teacher).name + " " + c.category,
        ).includes(q),
    );
    if (sort === "price") found.sort((a, b) => a.price - b.price);
    if (sort === "newest") found.reverse();
    $("#course-count").textContent =
      `${found.length} lớp học${activeTeacher ? " cùng " + teacher(activeTeacher).name : ""}`;
    $("#course-results").innerHTML = found.length
      ? found.map(courseCard).join("")
      : `<div class="empty-state">${icon("search")}<h3>Chưa tìm thấy lớp học phù hợp.</h3><p>Thử một từ khóa khác hoặc mở rộng bộ lọc nhé.</p><button class="btn btn-outline btn-sm" data-action="reset-courses">Xóa bộ lọc</button></div>`;
    $$("#course-categories button").forEach((b) => {
      const a = b.dataset.category === activeCategory;
      b.classList.toggle("active", a);
      b.setAttribute("aria-pressed", String(a));
    });
  }
  function resetCourses() {
    activeCategory = "Tất cả";
    activeTeacher = "";
    $("#course-search").value = "";
    $$('input[name="level"],#only-saved-courses').forEach(
      (x) => (x.checked = false),
    );
    $("#course-sort").value = "popular";
    history.replaceState(null, "", location.pathname);
    renderCourses();
  }
  if (page === "courses") {
    if (
      !["Tất cả", "Nội khoa", "Ngoại khoa", "Y khoa cơ sở"].includes(
        activeCategory,
      )
    )
      activeCategory = "Tất cả";
    if (!D.teachers.some((t) => t.id === activeTeacher)) activeTeacher = "";
    if (params.get("level"))
      $$('input[name="level"]').forEach(
        (e) => (e.checked = e.value === params.get("level")),
      );
    $("#course-categories").addEventListener("click", (e) => {
      const b = e.target.closest("[data-category]");
      if (!b) return;
      activeCategory = b.dataset.category;
      renderCourses();
    });
    $("#course-search").addEventListener("input", renderCourses);
    $$('input[name="level"],#only-saved-courses,#course-sort').forEach((e) =>
      e.addEventListener("change", renderCourses),
    );
    renderCourses();
  }
  if (page === "course") {
    const selectTab = (id) => {
      $$("[data-tab]").forEach((b) => {
        const a = b.dataset.tab === id;
        b.classList.toggle("active", a);
        b.setAttribute("aria-selected", String(a));
        b.tabIndex = a ? 0 : -1;
      });
      $$(".tab-content").forEach((p) => (p.hidden = p.id !== "panel-" + id));
    };
    $$(".detail-tab").forEach((b, i, all) => {
      b.addEventListener("click", () => selectTab(b.dataset.tab));
      b.addEventListener("keydown", (e) => {
        if (!["ArrowRight", "ArrowLeft", "Home", "End"].includes(e.key)) return;
        e.preventDefault();
        const next =
          e.key === "Home"
            ? 0
            : e.key === "End"
              ? all.length - 1
              : (i + (e.key === "ArrowRight" ? 1 : -1) + all.length) %
                all.length;
        selectTab(all[next].dataset.tab);
        all[next].focus();
      });
    });
  }
  if (page === "instructors")
    $("#teacher-filters").addEventListener("click", (e) => {
      const b = e.target.closest("[data-field]");
      if (!b) return;
      $$("#teacher-filters button").forEach((x) => {
        const a = x === b;
        x.classList.toggle("active", a);
        x.setAttribute("aria-pressed", String(a));
      });
      $("#instructor-results").innerHTML = D.teachers
        .filter(
          (t) => b.dataset.field === "Tất cả" || t.field === b.dataset.field,
        )
        .map(instructorPoster)
        .join("");
    });
  if (page === "article") {
    const update = () => {
      const available = document.documentElement.scrollHeight - innerHeight;
      $(".article-progress").style.transform =
        `scaleX(${available > 0 ? Math.min(1, scrollY / available) : 0})`;
    };
    addEventListener("scroll", update, { passive: true });
    update();
  }

  let examLevel = "Tất cả";
  function renderExams() {
    const school = $("#exam-school").value,
      year = $("#exam-year").value,
      subject = $("#exam-subject").value,
      q = norm($("#exam-search").value),
      saved = $("#only-saved-exams").checked;
    const found = D.exams.filter(
      (e) =>
        (!school || e.school === school) &&
        (!year || e.year === year) &&
        (!subject || e.subject === subject) &&
        (examLevel === "Tất cả" || e.level === examLevel) &&
        (!saved || list("saved-exams").includes(e.id)) &&
        norm(e.title + " " + e.subject).includes(q),
    );
    $("#exam-count").textContent =
      `${found.length} bộ đề${school ? " · " + schoolName(school) : ""}${year ? " · " + year : ""}`;
    $("#exam-results").innerHTML = found.length
      ? found.map(examCard).join("")
      : `<div class="empty-state">${icon("layers")}<h3>Chưa có bộ đề trong lựa chọn này.</h3><p>Hãy thử năm học hoặc môn học khác.</p><button class="btn btn-outline btn-sm" data-action="reset-exams">Xem tất cả bộ đề</button></div>`;
  }
  function syncSubjects() {
    const year = $("#exam-year").value,
      school = $("#exam-school").value;
    const subjects = [
      ...new Set(
        D.exams
          .filter(
            (e) =>
              (!year || e.year === year) && (!school || e.school === school),
          )
          .map((e) => e.subject),
      ),
    ];
    const current = $("#exam-subject").value;
    $("#exam-subject").innerHTML =
      '<option value="">Tất cả môn học</option>' +
      subjects
        .map((s) => `<option ${s === current ? "selected" : ""}>${s}</option>`)
        .join("");
  }
  function resetExams() {
    examLevel = "Tất cả";
    $("#exam-school").value = "";
    $("#exam-year").value = "";
    syncSubjects();
    $("#exam-subject").value = "";
    $("#exam-search").value = "";
    $("#only-saved-exams").checked = false;
    $$("#exam-levels button").forEach((b) => {
      const active = b.dataset.level === "Tất cả";
      b.classList.toggle("active", active);
      b.setAttribute("aria-pressed", String(active));
    });
    renderExams();
  }
  if (page === "exams") {
    $$("#exam-school,#exam-year").forEach((e) =>
      e.addEventListener("change", () => {
        syncSubjects();
        renderExams();
      }),
    );
    $$("#exam-subject,#only-saved-exams").forEach((e) =>
      e.addEventListener("change", renderExams),
    );
    $("#exam-search").addEventListener("input", renderExams);
    $("#exam-levels").addEventListener("click", (e) => {
      const b = e.target.closest("[data-level]");
      if (!b) return;
      examLevel = b.dataset.level;
      $$("#exam-levels button").forEach((x) => {
        x.classList.toggle("active", x === b);
        x.setAttribute("aria-pressed", String(x === b));
      });
      renderExams();
    });
    renderExams();
  }

  let rankPeriod = "week";
  function renderRank() {
    const school = $("#rank-school").value;
    const scores = D.learners
      .filter((l) => !school || l.school === school)
      .map((l) => ({ ...l, score: rankPeriod === "week" ? l.points : l.month }))
      .sort((a, b) => b.score - a.score);
    $("#rank-period-label").textContent =
      rankPeriod === "week" ? "21 — 27 tháng 9, 2026" : "Tháng 9, 2026";
    const top = scores.slice(0, 3);
    $("#rank-podium").innerHTML = [1, 0, 2]
      .map((i) => {
        const l = top[i];
        if (!l) return "";
        return `<article class="podium-card ${i === 0 ? "winner" : ""}">${i === 0 ? `<span class="crown">${icon("crown")}</span>` : ""}<span class="initial-avatar ${l.color}">${l.initial}</span><span class="podium-rank">${i + 1}</span><h3>${l.name}</h3><p>${schoolName(l.school)} · ${l.year}</p><div class="podium-points">${number(l.score)} <small>XP</small></div><div class="podium-streak">${icon("fire")}${l.streak} ngày giữ nhịp</div></article>`;
      })
      .join("");
    $("#rank-table").innerHTML = scores
      .map(
        (l, i) =>
          `<div class="ranking-row ${l.me ? "me" : ""}"><span class="rank-number">${String(i + 1).padStart(2, "0")}</span><div class="ranking-person"><span class="initial-avatar ${l.color}">${l.initial}</span><div><strong>${l.name}${l.me ? " · Cứ thế tiến lên!" : ""}</strong><small>${schoolName(l.school)} · ${l.year}</small></div></div><span class="rank-streak">${icon("fire")}${l.streak} ngày</span><span class="rank-score">${number(l.score)}</span></div>`,
      )
      .join("");
  }
  if (page === "leaderboard") {
    $("#rank-school").addEventListener("change", renderRank);
    $("#rank-period").addEventListener("click", (e) => {
      const b = e.target.closest("[data-period]");
      if (!b) return;
      rankPeriod = b.dataset.period;
      $$("#rank-period button").forEach((x) => {
        x.classList.toggle("active", x === b);
        x.setAttribute("aria-pressed", String(x === b));
      });
      renderRank();
    });
    renderRank();
  }

  // A complete local practice session, including review and wrong-answer retry.
  let exam,
    questions,
    session,
    selected = null,
    reviewMode = false;
  function freshSession(order) {
    return {
      version: 1,
      index: 0,
      order: order || questions.map((_, i) => i),
      answers: Array(questions.length).fill(null),
      complete: false,
      seconds: 0,
    };
  }
  function saveSession() {
    write("quiz-" + exam.id, session);
  }
  function currentQuestion() {
    return questions[session.order[session.index]];
  }
  function answerCount() {
    return session.order.filter((i) => session.answers[i] !== null).length;
  }
  function correctCount() {
    return session.order.filter(
      (i) => session.answers[i] === questions[i].answer,
    ).length;
  }
  const timeText = (seconds) =>
    `${String(Math.floor(seconds / 60)).padStart(2, "0")}:${String(seconds % 60).padStart(2, "0")}`;
  function renderPractice() {
    if (session.complete) {
      renderResult();
      return;
    }
    const q = currentQuestion(),
      index = session.order[session.index],
      answer = session.answers[index],
      answered = answer !== null,
      ok = answer === q.answer;
    selected = answered ? answer : null;
    $("#practice-content").innerHTML =
      `<div class="practice-topline"><span>${schoolName(exam.school)} <span class="muted">/</span> ${exam.year} <span class="muted">/</span> ${exam.subject}</span><span class="tag sage">${icon("leaf", "small")} Luyện tập tự do</span></div><div class="practice-layout"><section class="question-card"><div class="question-toolbar"><span>${exam.title}</span><button class="icon-btn ${list("saved-questions").includes(exam.bank + ":" + index) ? "saved" : ""}" data-practice="bookmark" aria-label="Lưu câu hỏi" aria-pressed="${list("saved-questions").includes(exam.bank + ":" + index)}">${icon("bookmark")}</button></div><div class="question-progress" role="progressbar" aria-label="Tiến độ bài luyện tập" aria-valuemin="0" aria-valuemax="${session.order.length}" aria-valuenow="${answerCount()}"><span style="width:${(answerCount() / session.order.length) * 100}%"></span></div><div class="eyebrow">Câu ${String(session.index + 1).padStart(2, "0")} / ${String(session.order.length).padStart(2, "0")} · Nhận định đúng hay sai?</div><h1 id="question-title" tabindex="-1">${q.q}</h1><p class="question-prompt">Chọn một đáp án theo hiểu biết của bạn.</p><div class="answer-options">${[
        true,
        false,
      ]
        .map((value, i) => {
          const state = answered
            ? value === q.answer
              ? "correct"
              : value === answer
                ? "wrong"
                : ""
            : "";
          return `<button class="answer-option ${state}" data-practice="answer" data-answer="${value}" aria-pressed="${answered && value === answer}" ${answered ? "disabled" : ""}><span>${icon(value ? "check" : "close", "small")}</span>${value ? "Đúng" : "Sai"}<small>${i + 1}</small></button>`;
        })
        .join(
          "",
        )}</div>${answered ? `<div class="answer-feedback" role="status"><div class="feedback-status ${ok ? "" : "wrong"}">${icon(ok ? "checkCircle" : "bulb")}${ok ? "Chính xác! Bạn đã hiểu đúng." : "Thêm một điều để ghi nhớ."}</div><p>${q.explain}</p><div class="memory-key">${icon("bulb", "small")}<span>${q.key}</span></div><a class="source" href="https://openstax.org/books/anatomy-and-physiology-2e/pages/${q.source}" target="_blank" rel="noopener">Tham khảo: OpenStax · Anatomy & Physiology 2e ${icon("upRight", "small")}</a></div>` : ""}<div class="question-actions"><span>${answered ? "Hiểu lời giải trước khi đi tiếp nhé." : "Không cần vội. Hãy nghĩ thêm một chút."}</span><button class="btn ${answered ? "btn-dark" : "btn-red"}" data-practice="${answered ? "next" : "check"}" ${!answered ? "disabled" : ""}>${answered ? (session.index === session.order.length - 1 ? "Xem kết quả" : "Câu tiếp theo") : "Kiểm tra đáp án"} ${icon("arrow", "small")}</button></div></section><aside class="practice-sidebar"><section class="session-card"><h3>Hành trình của phiên học</h3><div class="session-count">${answerCount()}<small> / ${session.order.length} câu</small></div><p>${correctCount()} câu đúng · <span id="session-time">${timeText(session.seconds)}</span></p><div class="question-dots">${session.order.map((qi, i) => `<span class="question-dot ${session.answers[qi] !== null ? (session.answers[qi] === questions[qi].answer ? "right" : "wrong") : i === session.index ? "current" : ""}" aria-label="Câu ${i + 1}: ${session.answers[qi] !== null ? (session.answers[qi] === questions[qi].answer ? "đúng" : "sai") : "chưa trả lời"}">${i + 1}</span>`).join("")}</div></section><section class="session-card"><label class="scratchpad-label" for="scratchpad">${icon("pen", "small")} Điều mình muốn nhớ</label><textarea id="scratchpad" class="scratchpad" placeholder="Ghi lại bằng lời của bạn…">${esc(read("note-" + exam.id, ""))}</textarea><p class="note-status" id="note-status">Ghi chú tự lưu trên trình duyệt.</p></section><div class="keyboard-note"><strong>Một chút tiện lợi</strong><kbd>1</kbd>Chọn Đúng<br><kbd>2</kbd>Chọn Sai<br><kbd>Enter</kbd>Kiểm tra / Tiếp tục</div></aside></div>`;
    $("#scratchpad").addEventListener("input", (e) => {
      write("note-" + exam.id, e.target.value);
      $("#note-status").textContent = "Đã lưu ghi chú.";
    });
  }
  function renderResult() {
    const total = session.order.length,
      correct = correctCount(),
      wrong = total - correct;
    $("#practice-content").innerHTML =
      `<section class="result-panel"><div class="result-icon">${icon(correct === total ? "trophy" : "leaf")}</div><div class="eyebrow" style="justify-content:center">Một bước tiến mới</div><h1>${correct === total ? "Bạn đã nắm rất vững!" : "Một lần luyện, thêm một lần hiểu."}</h1><p>Đã hoàn thành “${exam.title}”.<br>${wrong ? "Dành thêm một chút thời gian cho những câu cần nhớ nhé." : "Giữ nhịp học này và khám phá chủ đề tiếp theo nhé."}</p><div class="result-stats"><div><strong>${correct}/${total}</strong><span>CÂU TRẢ LỜI ĐÚNG</span></div><div><strong>${correct * 20}</strong><span>XP PHIÊN HỌC</span></div><div><strong>${timeText(session.seconds)}</strong><span>THỜI GIAN HỌC</span></div></div><div class="button-row">${wrong ? `<button class="btn btn-red" data-practice="retry-wrong">Ôn lại ${wrong} câu sai ${icon("reset", "small")}</button>` : `<a class="btn btn-red" href="exams.html">Khám phá bộ đề khác ${icon("arrow", "small")}</a>`}<button class="btn btn-outline" data-practice="review">${reviewMode ? "Ẩn đáp án" : "Xem lại bài làm"}</button><button class="text-link" data-practice="retry-all">Làm lại toàn bộ ${icon("reset", "small")}</button></div>${
        reviewMode
          ? `<div class="review-list"><h2>Những điều bạn vừa học</h2>${session.order
              .map((i, n) => {
                const q = questions[i],
                  ok = session.answers[i] === q.answer;
                return `<article class="review-question ${ok ? "" : "wrong"}"><strong>${icon(ok ? "checkCircle" : "close")}<span>${n + 1}. ${q.q}</span></strong><span class="tag ${ok ? "sage" : "rose"}">Bạn chọn: ${session.answers[i] ? "Đúng" : "Sai"} · Đáp án: ${q.answer ? "Đúng" : "Sai"}</span><p>${q.explain}</p></article>`;
              })
              .join("")}</div>`
          : ""
      }<div style="margin-top:25px">${link("Quay về thư viện bộ đề", "exams.html")}</div></section>`;
  }
  function chooseAnswer(value) {
    if (
      session.complete ||
      session.answers[session.order[session.index]] !== null
    )
      return;
    selected = value;
    $$(".answer-option").forEach((b) => {
      const active = (b.dataset.answer === "true") === value;
      b.classList.toggle("selected", active);
      b.setAttribute("aria-pressed", String(active));
    });
    $('[data-practice="check"]').disabled = false;
  }
  function checkAnswer() {
    if (
      selected === null ||
      session.complete ||
      session.answers[session.order[session.index]] !== null
    )
      return;
    session.answers[session.order[session.index]] = selected;
    saveSession();
    renderPractice();
    $(".answer-feedback")?.scrollIntoView({
      behavior: "smooth",
      block: "nearest",
    });
  }
  function nextQuestion() {
    if (session.answers[session.order[session.index]] === null) return;
    if (session.index === session.order.length - 1) session.complete = true;
    else session.index++;
    saveSession();
    renderPractice();
    $("#question-title")?.focus({ preventScroll: true });
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
  if (page === "practice") {
    exam = D.exams.find((e) => e.id === params.get("exam")) || D.exams[0];
    questions = D.banks[exam.bank];
    document.title = exam.title + " — Luyện tập Meduc";
    const saved = read("quiz-" + exam.id, null);
    const valid =
      saved?.version === 1 &&
      Array.isArray(saved.order) &&
      saved.order.length > 0 &&
      new Set(saved.order).size === saved.order.length &&
      saved.order.every(
        (i) => Number.isInteger(i) && i >= 0 && i < questions.length,
      ) &&
      Array.isArray(saved.answers) &&
      saved.answers.length === questions.length &&
      saved.answers.every((a) => a === null || typeof a === "boolean") &&
      Number.isInteger(saved.index) &&
      saved.index >= 0 &&
      saved.index < saved.order.length &&
      typeof saved.complete === "boolean" &&
      Number.isFinite(saved.seconds) &&
      saved.seconds >= 0 &&
      (!saved.complete || saved.order.every((i) => saved.answers[i] !== null));
    session = valid ? saved : freshSession();
    renderPractice();
    setInterval(() => {
      if (session.complete || document.hidden || dialog.open) return;
      session.seconds++;
      const label = $("#session-time");
      if (label) label.textContent = timeText(session.seconds);
      if (session.seconds % 5 === 0) saveSession();
    }, 1000);
    addEventListener("pagehide", saveSession);
    document.addEventListener("visibilitychange", () => {
      if (document.hidden) saveSession();
    });
    document.addEventListener("click", (e) => {
      const b = e.target.closest("[data-practice]");
      if (!b) return;
      const a = b.dataset.practice;
      if (a === "answer") chooseAnswer(b.dataset.answer === "true");
      else if (a === "check") checkAnswer();
      else if (a === "next") nextQuestion();
      else if (a === "review") {
        reviewMode = !reviewMode;
        renderResult();
      } else if (a === "retry-wrong" || a === "retry-all") {
        const order =
          a === "retry-wrong"
            ? session.order.filter(
                (i) => session.answers[i] !== questions[i].answer,
              )
            : undefined;
        session = freshSession(order);
        reviewMode = false;
        saveSession();
        renderPractice();
        window.scrollTo({ top: 0, behavior: "smooth" });
      } else if (a === "bookmark") {
        const key = exam.bank + ":" + session.order[session.index],
          saved = list("saved-questions"),
          was = saved.includes(key);
        write(
          "saved-questions",
          was ? saved.filter((i) => i !== key) : [...saved, key],
        );
        b.classList.toggle("saved", !was);
        b.setAttribute("aria-pressed", String(!was));
        toast(
          was ? "Đã bỏ lưu câu hỏi." : "Đã lưu câu hỏi trên trình duyệt này.",
        );
      }
    });
    document.addEventListener("keydown", (e) => {
      if (
        e.repeat ||
        dialog.open ||
        session.complete ||
        /INPUT|TEXTAREA|SELECT/.test(e.target.tagName) ||
        e.target.isContentEditable
      )
        return;
      if (e.key === "1" || e.key === "2") {
        e.preventDefault();
        chooseAnswer(e.key === "1");
      } else if (e.key === "Enter" && !e.target.closest("button,a,summary")) {
        e.preventDefault();
        if (session.answers[session.order[session.index]] !== null)
          nextQuestion();
        else checkAnswer();
      }
    });
  }
})();
