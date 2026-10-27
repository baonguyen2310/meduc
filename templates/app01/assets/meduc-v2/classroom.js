/* Course page as a classroom (block/product_detail/view_classroom.tpl).
   - The course overview stays above the classroom. The outline selects a lesson; ?bai=N keeps the address
     in step so a lesson can be shared and the Back button works.
   - Lesson videos play inside the page (YouTube IFrame API). Students continue to the next video after
     a short countdown; visitors trying a free lesson see the sign-up card and may choose another free video.
   - The overview has independent tabs and an expandable description. Existing ratings and related courses move into their places (data-mcr-slot).
   - Progress (lessons watched, last lesson) is kept in this browser only. */
(() => {
  "use strict";
  const root = document.querySelector("[data-mcr]");
  if (!root || root.dataset.mcrReady) return;
  root.dataset.mcrReady = "1";

  let licensed = root.dataset.mcrLicensed === "1";
  const $ = (selector) => root.querySelector(selector);
  const $$ = (selector) => [...root.querySelectorAll(selector)];
  const pad = (number) => String(number).padStart(2, "0");
  const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const narrow = () => matchMedia("(max-width: 991.98px)").matches;

  const lessons = $$("[data-mcr-lesson]").map((link) => ({
    number: Number(link.dataset.mcrLesson),
    link,
    title: link.dataset.title || "",
    chapter: link.dataset.chapter || "",
    video: link.dataset.video || "",
    access: link.dataset.access,
    trial: link.dataset.trial === "1",
    freeQuiz: link.dataset.freeQuiz === "1",
    quiz: link.dataset.quiz === "1",
    quizzes: Number(link.dataset.quizzes) || 0,
  }));
  const byNumber = new Map(lessons.map((lesson) => [lesson.number, lesson]));
  const total = lessons.length;
  const examPrep = root.dataset.mcrExamPrep === "1";
  const canWatch = (lesson) => Boolean(lesson && lesson.video) && (licensed || lesson.trial);

  const overview = $("[data-mcr-overview]");
  const lessonView = $('[data-mcr-view="lesson"]');
  const stages = Object.fromEntries($$("[data-mcr-stage]").map((stage) => [stage.dataset.mcrStage, stage]));
  const poster = $("[data-mcr-poster]");
  const playerHolder = $("[data-mcr-player]");

  // Progress in this browser: which lessons were played, and the last one opened.
  const storeKey = `meduc-classroom:${location.pathname}`;
  const readStore = () => {
    try { return JSON.parse(localStorage.getItem(storeKey)) || {}; } catch (error) { return {}; }
  };
  const writeStore = (patch) => {
    try { localStorage.setItem(storeKey, JSON.stringify({ ...readStore(), ...patch })); } catch (error) { /* private mode */ }
  };
  const watched = () => new Set(readStore().watched || []);
  function markWatched(number) {
    const set = watched();
    set.add(number);
    writeStore({ watched: [...set] });
    renderProgress();
  }

  function renderProgress() {
    const set = watched();
    const progress = $("[data-mcr-progress]");
    if (progress) progress.textContent = `Đã học ${[...set].filter((n) => byNumber.has(n)).length}/${total} bài`;
    // The start button picks up where the visitor left off.
    const last = byNumber.get(readStore().last);
    $$("[data-mcr-start]").forEach((button) => {
      const label = button.querySelector("[data-mcr-start-label]");
      if (!label || !last || !canWatch(last) || !set.size) return;
      button.dataset.mcrStart = String(last.number);
      button.setAttribute("href", `?bai=${last.number}`);
      label.textContent = licensed ? `Học tiếp: Bài ${last.number}` : `Tiếp tục học thử: Bài ${last.number}`;
    });
  }

  // Address: ?bai=N for a lesson, no parameter for the introduction; other parameters (e.g. ?a= affiliate) stay.
  function addressFor(number) {
    const url = new URL(location.href);
    if (number) url.searchParams.set("bai", number); else url.searchParams.delete("bai");
    url.hash = "";
    return url.pathname + url.search;
  }

  // YouTube player
  let player = null;
  let apiPromise = null;
  let endTimer = null;
  function loadApi() {
    if (window.YT && window.YT.Player) return Promise.resolve(true);
    if (!apiPromise) {
      apiPromise = new Promise((resolve) => {
        const previous = window.onYouTubeIframeAPIReady;
        window.onYouTubeIframeAPIReady = () => {
          if (typeof previous === "function") previous();
          resolve(true);
        };
        const script = document.createElement("script");
        script.src = "https://www.youtube.com/iframe_api";
        script.onerror = () => resolve(false);
        document.head.append(script);
        setTimeout(() => resolve(Boolean(window.YT && window.YT.Player)), 8000);
      });
    }
    return apiPromise;
  }
  function showStage(name) {
    Object.entries(stages).forEach(([key, stage]) => { stage.hidden = key !== name; });
  }
  function stopPlayer() {
    clearInterval(endTimer);
    endTimer = null;
    if (player && typeof player.stopVideo === "function") {
      try { player.stopVideo(); } catch (error) { /* player not ready yet */ }
    }
    if (!player) playerHolder.replaceChildren();
  }
  async function play(lesson, authorized = false) {
    if (!canWatch(lesson)) return;
    if (!authorized) return root.mcrStudyAccess.request({
      kind:'video',trigger:$("[data-mcr-play-lesson]"),free:lesson.trial,
      valid:()=>current===lesson && !lessonView.hidden && !$("[data-mcr-panel='video']").hidden,
      resume:()=>play(lesson,true),
    });
    showStage("player");
    markWatched(lesson.number);
    const ready = await loadApi();
    if (current !== lesson || $("[data-mcr-panel='video']").hidden) return;
    if (ready) {
      if (player && typeof player.loadVideoById === "function") {
        player.loadVideoById(lesson.video);
        return;
      }
      const target = document.createElement("div");
      playerHolder.replaceChildren(target);
      player = new window.YT.Player(target, {
        videoId: lesson.video,
        host: "https://www.youtube-nocookie.com",
        playerVars: { autoplay: 1, rel: 0, modestbranding: 1, playsinline: 1 },
        events: {
          onStateChange: (event) => { if (event.data === window.YT.PlayerState.ENDED) onEnded(); },
          // A private, deleted or non-embeddable video: say so in MedUC's words instead of YouTube's error screen.
          onError: () => showVideoError(),
        },
      });
      return;
    }
    // The API did not load (blocked network): a plain embed still plays, without the automatic next lesson.
    const frame = document.createElement("iframe");
    frame.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(lesson.video)}?autoplay=1&rel=0`;
    frame.title = lesson.title;
    frame.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
    frame.allowFullscreen = true;
    playerHolder.replaceChildren(frame);
  }

  function showPaywall(title, text, offerQuiz, nextTrial = null) {
    const heading = $("[data-mcr-paywall-title]");
    const body = $("[data-mcr-paywall-text]");
    if (heading) heading.textContent = title;
    if (body) body.textContent = text;
    const quizLink = $("[data-mcr-goto-quiz]");
    if (quizLink) quizLink.hidden = !offerQuiz;
    const trialLink = $("[data-mcr-paywall-next]");
    if (trialLink) {
      trialLink.hidden = !nextTrial;
      trialLink.dataset.mcrPaywallNext = nextTrial ? String(nextTrial.number) : "";
    }
    showStage("paywall");
  }
  function showVideoError() {
    if (!current) return;
    const quizButton = $("[data-mcr-goto-quiz-error]");
    if (quizButton) quizButton.hidden = !current.quiz;
    $("[data-mcr-error-next]").hidden = current.number >= total;
    showStage("error");
  }
  function nextWatchable(from) {
    return lessons.find((lesson) => lesson.number > from && canWatch(lesson));
  }
  function onEnded() {
    const lesson = current;
    if (!lesson) return;
    const next = nextWatchable(lesson.number);
    if (!licensed) {
      const following = byNumber.get(lesson.number + 1);
      showPaywall(
        "Bạn đã xem xong video học thử",
        !next && following ? `Đăng ký để học tiếp từ “${following.title}” và trọn ${total} bài của khoá học.` : `Đăng ký để học trọn ${total} bài của khoá học.`,
        false,
        next,
      );
      return;
    }
    if (!next) {
      return;
    }
    $("[data-mcr-end-title]").textContent = next.title;
    const count = $("[data-mcr-end-count]");
    let seconds = 6;
    count.textContent = `Tự chuyển sau ${seconds} giây`;
    showStage("end");
    clearInterval(endTimer);
    endTimer = setInterval(() => {
      seconds -= 1;
      count.textContent = `Tự chuyển sau ${seconds} giây`;
      if (seconds <= 0) selectLesson(next.number, { autoplay: true });
    }, 1000);
  }
  $("[data-mcr-end-next]")?.addEventListener("click", () => {
    const next = current && nextWatchable(current.number);
    if (next) selectLesson(next.number, { autoplay: true });
  });
  $("[data-mcr-end-stay]")?.addEventListener("click", () => {
    clearInterval(endTimer);
    if (current) setLessonStage(current);
  });
  $("[data-mcr-paywall-next]")?.addEventListener("click", (event) => {
    const next = byNumber.get(Number(event.currentTarget.dataset.mcrPaywallNext));
    if (next && canWatch(next)) selectLesson(next.number, { autoplay: true });
  });

  // Refresh identity after popup login/OTP; queue only the action the visitor actually requested.
  let pendingStudy = null;
  let studyRequest = 0;
  let accessRequest = null;
  const accessError = document.createElement('p');
  accessError.className = 'mcr-empty'; accessError.hidden = true; accessError.setAttribute('role','alert');
  lessonView.querySelector('.mcr-toolbar').after(accessError);
  async function refreshAccess() {
    if (accessRequest) return accessRequest;
    accessRequest = (async () => {
      const response = await fetch(`/khoa-hoc/trang-thai/${root.dataset.mcrProduct}`, {credentials:'same-origin',cache:'no-store',headers:{Accept:'application/json'}});
      const body = await response.json().catch(() => null);
      if (!response.ok || body?.code !== 'success') throw new Error('Chưa kiểm tra được tài khoản. Vui lòng thử lại.');
      const access = body.data;
      licensed = access.licensed === true;
      root.dataset.mcrLicensed = licensed ? '1' : '0';
      root.dataset.mcrMember = String(Number(access.member_id) || 0);
      root.dataset.mcrMemberCode = access.member_code || '';
      root.dataset.mcrClassRoom = String(Number(access.class_room_id) || 0);
      lessons.forEach(lesson => {lesson.access=licensed?'open':lesson.trial?'trial':'locked';lesson.quiz=licensed?lesson.quizzes>0:lesson.freeQuiz;});
      $$('[data-mcr-quiz-start]').forEach(button => {
        const open=licensed || button.dataset.mcrQuizFree==='1';
        button.hidden=!open;
        const card=button.closest('.mcr-quiz-card');
        card.classList.toggle('is-locked',!open);
        const enroll=card.querySelector('[data-mcr-quiz-enroll]');if(enroll)enroll.hidden=open;
      });
      root.dispatchEvent(new CustomEvent('mcr:access',{detail:access}));
      return access;
    })().finally(() => {accessRequest=null;});
    return accessRequest;
  }
  function resumeStudy() {
    const pending=pendingStudy;
    const modal=document.getElementById('login-modal');
    if (!pending?.ready || (modal && modal.style.display!=='none')) return;
    pendingStudy=null;
    if (Number(root.dataset.mcrMember)>0 && pending.valid()) pending.resume();
  }
  root.mcrStudyAccess = {
    async request({kind,trigger,resume,valid,free=true}) {
      const ticket=++studyRequest;
      accessError.hidden=true;
      try {
        const access=await refreshAccess();
        if (ticket!==studyRequest || !valid()) return;
        if (access.member_id) {pendingStudy=null;return resume();}
        const message=free ? (kind==='video'
          ? 'Đăng nhập hoặc đăng ký tài khoản để xem video miễn phí. Bạn không cần mua khóa học để học thử.'
          : 'Đăng nhập hoặc đăng ký tài khoản để làm bài tập miễn phí. Bạn không cần mua khóa học để làm thử.')
          : 'Đăng nhập để tiếp tục bài học. Bạn sẽ trở lại đúng nội dung vừa chọn.';
        if (!window.meducAuth) throw new Error('Chưa mở được cửa sổ đăng nhập. Vui lòng thử lại.');
        pendingStudy={resume,valid,ready:false};
        window.meducAuth.open('login',trigger,{message});
      } catch(error) {accessError.textContent=error.message;accessError.hidden=false;}
    }
  };
  window.addEventListener('meduc:authenticated',async () => {
    const pending=pendingStudy;
    try {
      await refreshAccess();
      if (pending && pendingStudy===pending) {pending.ready=true;resumeStudy();}
    } catch(error) {pendingStudy=null;accessError.textContent=error.message;accessError.hidden=false;}
  });
  window.addEventListener('meduc:auth-closed',event => {
    if (!event.detail?.authenticated) {pendingStudy=null;studyRequest++;}
    else resumeStudy();
  });

  // Tabs
  const tabs = $$("[data-mcr-tab]");
  function selectTab(name, focus = false) {
    tabs.forEach((tab) => {
      const active = tab.dataset.mcrTab === name;
      tab.setAttribute("aria-selected", String(active));
      tab.tabIndex = active ? 0 : -1;
      if (active && focus) tab.focus();
    });
    $$("[data-mcr-panel]").forEach((panel) => { panel.hidden = panel.dataset.mcrPanel !== name; });
    if (name !== "video") {
      clearInterval(endTimer);
      if (player && typeof player.pauseVideo === "function") {
        try { player.pauseVideo(); } catch (error) { /* not ready */ }
      }
    }
  }
  tabs.forEach((tab, index) => {
    tab.addEventListener("click", () => selectTab(tab.dataset.mcrTab));
    tab.addEventListener("keydown", (event) => {
      const step = event.key === "ArrowRight" ? 1 : event.key === "ArrowLeft" ? -1 : 0;
      if (!step) return;
      event.preventDefault();
      selectTab(tabs[(index + step + tabs.length) % tabs.length].dataset.mcrTab, true);
    });
  });
  $("[data-mcr-goto-quiz]")?.addEventListener("click", () => selectTab("quiz", true));
  $("[data-mcr-goto-quiz-error]")?.addEventListener("click", () => selectTab("quiz", true));
  $("[data-mcr-goto-quiz-novideo]")?.addEventListener("click", () => selectTab("quiz", true));
  $("[data-mcr-goto-quiz-soon]")?.addEventListener("click", () => selectTab("quiz", true));
  $("[data-mcr-error-next]")?.addEventListener("click", () => current && selectLesson(current.number + 1));

  // Views
  let current = null;
  function setLessonStage(lesson) {
    if (examPrep && !lesson.video) {
      // Exam-prep courses have no videos yet: a placeholder, with a way to the lesson's exams.
      const quizButton = $("[data-mcr-goto-quiz-soon]");
      if (quizButton) quizButton.hidden = !lesson.quizzes;
      showStage("soon");
    } else if (canWatch(lesson)) {
      poster.src = `https://i.ytimg.com/vi/${lesson.video}/hqdefault.jpg`;
      showStage("poster");
    } else if (licensed) {
      const quizButton = $("[data-mcr-goto-quiz-novideo]");
      if (quizButton) quizButton.hidden = !lesson.quiz;
      showStage("novideo");
    } else {
      // lesson.quiz: the lesson has a quiz the visitor may take (free to try), even when its video is locked.
      showPaywall(
        lesson.access === "trial" ? "Video buổi này dành cho học viên đã đăng ký" : "Buổi này dành cho học viên đã đăng ký",
        lesson.quiz ? "Bài tập của buổi này vẫn làm thử miễn phí." : `Đăng ký để học trọn ${total} bài của khoá học.`,
        lesson.quiz,
      );
    }
  }
  function markCurrent(link) {
    lessons.forEach((lesson) => {
      lesson.link.classList.toggle("is-current", lesson.link === link);
      if (lesson.link === link) lesson.link.setAttribute("aria-current", "page"); else lesson.link.removeAttribute("aria-current");
    });
  }
  // Keep the current lesson visible inside the sticky outline (only the outline scrolls, not the page).
  function revealInOutline(link) {
    const outline = $(".mcr-sidebar");
    if (!outline || narrow() || outline.scrollHeight <= outline.clientHeight) return;
    const box = outline.getBoundingClientRect();
    const item = link.getBoundingClientRect();
    if (item.top < box.top + 60 || item.bottom > box.bottom - 20) outline.scrollTop += item.top - box.top - box.height / 3;
  }
  function selectLesson(number, { autoplay = false, push = true, scroll = true } = {}) {
    const lesson = byNumber.get(number);
    if (!lesson) { showIntro({ push }); return; }
    stopPlayer();
    current = lesson;
    markCurrent(lesson.link);
    const chapter = lesson.link.closest("details");
    if (chapter) chapter.open = true;
    revealInOutline(lesson.link);
    lessonView.hidden = false;

    // Keep the active lesson available to screen readers without repeating its heading visually.
    $("[data-mcr-heading]").textContent = lesson.title;
    $("[data-mcr-position]").textContent = `${pad(lesson.number)} / ${pad(total)}`;
    $("[data-mcr-prev]").disabled = lesson.number <= 1;
    $("[data-mcr-next]").disabled = lesson.number >= total;
    $$("[data-mcr-files]").forEach((block) => { block.hidden = Number(block.dataset.mcrFiles) !== lesson.number; });
    $$("[data-mcr-quiz]").forEach((block) => { block.hidden = Number(block.dataset.mcrQuiz) !== lesson.number; });

    setLessonStage(lesson);
    // classroom-quiz.js listens to switch the "Bài tập" tab to this lesson's quiz.
    root.dispatchEvent(new CustomEvent("mcr:lesson", { detail: { number: lesson.number } }));
    if (autoplay && canWatch(lesson)) {
      selectTab("video");
      play(lesson);
    }
    writeStore({ last: lesson.number });
    if (push) history.pushState({ mcrLesson: lesson.number }, "", addressFor(lesson.number));
    if (scroll) lessonView.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
  }
  function showIntro({ push = true } = {}) {
    stopPlayer();
    selectOverview("about");
    if (push) history.pushState({ mcrLesson: 0 }, "", addressFor(0));
    overview.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
  }
  // Result screens can return to the course information without a sidebar introduction button.
  root.addEventListener("mcr:overview", () => showIntro());
  $("[data-mcr-back-to-intro]")?.addEventListener("click", (event) => {
    event.preventDefault();
    showIntro();
  });
  $("[data-mcr-outline-jump]")?.addEventListener("click", (event) => {
    event.preventDefault();
    const target = narrow() ? $(".mcr-sidebar") : $("#mcr-learning");
    target?.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
  });

  $("[data-mcr-mock-exam]")?.addEventListener("click", (event) => {
    const number = Number(event.currentTarget.dataset.mcrMockExam);
    if (!byNumber.has(number)) return;
    selectLesson(number, { scroll: false });
    selectTab("quiz");
    lessonView.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
  });

  lessons.forEach((lesson) => lesson.link.addEventListener("click", (event) => {
    event.preventDefault();
    selectLesson(lesson.number);
  }));
  $$("[data-mcr-start]").forEach((button) => button.addEventListener("click", (event) => {
    event.preventDefault();
    selectLesson(Number(button.dataset.mcrStart), { autoplay: true });
  }));
  $("[data-mcr-play-lesson]").addEventListener("click", () => { if (current) play(current); });
  $("[data-mcr-prev]").addEventListener("click", () => current && selectLesson(current.number - 1));
  $("[data-mcr-next]").addEventListener("click", () => current && selectLesson(current.number + 1));
  window.addEventListener("popstate", () => {
    const number = Number(new URLSearchParams(location.search).get("bai"));
    if (byNumber.has(number)) selectLesson(number, { push: false }); else showIntro({ push: false });
  });

  // Intro video and student feedback videos play in place.
  $$("[data-mcr-embed]").forEach((button) => button.addEventListener("click", () => {
    const frame = document.createElement("iframe");
    frame.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(button.dataset.mcrEmbed)}?autoplay=1&rel=0`;
    frame.title = button.getAttribute("aria-label") || "Video MedUC";
    frame.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
    frame.allowFullscreen = true;
    button.replaceWith(frame);
  }));

  // Accent-insensitive filtering for long exam lists inside a lesson.
  const fold = (value) => value.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase();
  // Long quiz lists (exam-prep lessons hold dozens of exams): filter the cards by name, accents ignored.
  $$("[data-mcr-quiz-filter]").forEach((input) => {
    const holder = input.closest("[data-mcr-quiz]");
    const cards = [...holder.querySelectorAll(".mcr-quiz-card")].map((card) => [card, fold(card.querySelector("h3")?.textContent || "")]);
    const count = holder.querySelector("[data-mcr-quiz-filter-count]");
    input.addEventListener("input", () => {
      const words = fold(input.value).split(/\s+/).filter(Boolean);
      let shown = 0;
      cards.forEach(([card, name]) => {
        const match = words.every((word) => name.includes(word));
        card.hidden = !match;
        if (match) shown += 1;
      });
      if (count) count.textContent = words.length ? `${shown}/${cards.length} đề` : `${cards.length} đề`;
    });
  });

  // The old FAQ, questions and written reviews no longer belong on the course detail page.
  ["6a5tyhf", "zdi3rma", "5y31vx8"].forEach((id) => document.querySelector(`[nh-block="${id}"]`)?.remove());

  // Keep the page's related courses in their designated section.
  $$("[data-mcr-slot]").forEach((slot) => {
    const block = document.querySelector(`[nh-block="${slot.dataset.mcrSlot}"]`);
    if (block && !root.contains(block)) slot.append(block);
  });
  // Their headings are often typed in capitals ("ĐẶT CÂU HỎI"); they read as sentences here.
  $$(".mcr-slot .title-section-2 span, .mcr-slot .mfq-title").forEach((heading) => {
    const words = heading.textContent.trim();
    if (words && words === words.toLocaleUpperCase("vi") && words !== words.toLocaleLowerCase("vi")) {
      const lower = words.toLocaleLowerCase("vi");
      heading.textContent = lower.charAt(0).toLocaleUpperCase("vi") + lower.slice(1);
    }
  });
  // Course overview tabs are independent of the lesson tabs below.
  const overviewTabs = $$("[data-mcr-overview-tab]");
  function selectOverview(name, focus = false) {
    overviewTabs.forEach((tab) => {
      const active = tab.dataset.mcrOverviewTab === name;
      tab.setAttribute("aria-selected", String(active));
      tab.tabIndex = active ? 0 : -1;
      if (active && focus) tab.focus();
    });
    $$("[data-mcr-overview-panel]").forEach((panel) => { panel.hidden = panel.dataset.mcrOverviewPanel !== name; });
  }
  overviewTabs.forEach((tab, index) => {
    tab.addEventListener("click", () => selectOverview(tab.dataset.mcrOverviewTab));
    tab.addEventListener("keydown", (event) => {
      let next = index;
      if (event.key === "ArrowRight") next = (index + 1) % overviewTabs.length;
      else if (event.key === "ArrowLeft") next = (index - 1 + overviewTabs.length) % overviewTabs.length;
      else if (event.key === "Home") next = 0;
      else if (event.key === "End") next = overviewTabs.length - 1;
      else return;
      event.preventDefault();
      selectOverview(overviewTabs[next].dataset.mcrOverviewTab, true);
    });
  });
  const description = $("[data-mcr-description-full]");
  const preview = $("[data-mcr-description-preview]");
  const more = $("[data-mcr-description-toggle]");
  if (description && preview && more) {
    const clean = (text) => text.replace(/\s+/g, " ").trim();
    const paragraph = [...description.querySelectorAll("p")].map((p) => clean(p.textContent)).find((text) => text.length > 80);
    const excerpt = paragraph || clean(description.textContent);
    preview.textContent = excerpt.length > 480 ? `${excerpt.slice(0, 480).replace(/\s+\S*$/, "")}…` : excerpt;
    more.hidden = clean(description.textContent) === preview.textContent && !description.querySelector("img,table,ul,ol");
    more.addEventListener("click", () => {
      const expanded = more.getAttribute("aria-expanded") !== "true";
      more.setAttribute("aria-expanded", String(expanded));
      description.hidden = !expanded;
      preview.hidden = expanded;
      more.textContent = expanded ? "Thu gọn ↑" : "Xem thêm ↓";
      if (!expanded) $(".mcr-overview-tabs").scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
    });
  }

  renderProgress();
  const initial = Number(new URLSearchParams(location.search).get("bai"));
  const defaultLesson = byNumber.get(readStore().last) || lessons.find((lesson) => canWatch(lesson) || lesson.quiz) || lessons[0];
  const selected = byNumber.has(initial) ? initial : defaultLesson?.number;
  if (selected) {
    selectLesson(selected, { push: false, scroll: false });
    if (new URLSearchParams(location.search).get("tab") === "quiz") selectTab("quiz");
    if (byNumber.has(initial)) requestAnimationFrame(() => lessonView.scrollIntoView({ block: "start", behavior: "instant" }));
  }
})();
