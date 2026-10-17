/* Course page as a classroom (block/product_detail/view_classroom.tpl).
   - The outline switches the right-hand side between the course introduction and a lesson; ?bai=N keeps the address
     in step so a lesson can be shared and the Back button works.
   - Lesson videos play inside the page (YouTube IFrame API). Students continue to the next video after
     a short countdown; visitors trying a free lesson see the sign-up card and may choose another free video.
   - The introduction: the FAQ, questions, ratings and related-course blocks rendered below on the page move into their
     places (data-mcr-slot), and the tabs above it follow the reader through its sections.
   - Progress (lessons watched, last lesson) is kept in this browser only. */
(() => {
  "use strict";
  const root = document.querySelector("[data-mcr]");
  if (!root || root.dataset.mcrReady) return;
  root.dataset.mcrReady = "1";

  const licensed = root.dataset.mcrLicensed === "1";
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
    quiz: link.dataset.quiz === "1",
    quizzes: Number(link.dataset.quizzes) || 0,
  }));
  const byNumber = new Map(lessons.map((lesson) => [lesson.number, lesson]));
  const total = lessons.length;
  const examPrep = root.dataset.mcrExamPrep === "1";
  const canWatch = (lesson) => Boolean(lesson && lesson.video) && (licensed || lesson.access === "trial");

  const introView = $('[data-mcr-view="intro"]');
  const lessonView = $('[data-mcr-view="lesson"]');
  const introLink = $("[data-mcr-intro]");
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
  async function play(lesson) {
    if (!canWatch(lesson)) return;
    showStage("player");
    markWatched(lesson.number);
    const ready = await loadApi();
    if (current !== lesson) return;
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
    introLink.classList.toggle("is-active", !link);
    if (link) introLink.removeAttribute("aria-current"); else introLink.setAttribute("aria-current", "page");
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
    introView.hidden = true;
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
    if (scroll) {
      const top = lessonView.getBoundingClientRect().top;
      if (narrow() || top < 60) lessonView.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
    }
  }
  function showIntro({ push = true } = {}) {
    stopPlayer();
    current = null;
    markCurrent(null);
    lessonView.hidden = true;
    introView.hidden = false;
    root.dispatchEvent(new CustomEvent("mcr:lesson", { detail: { number: 0 } }));
    if (push) history.pushState({ mcrLesson: 0 }, "", addressFor(0));
  }

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
  introLink.addEventListener("click", (event) => {
    event.preventDefault();
    showIntro();
    if (narrow()) introView.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
  });
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

  // The page's own FAQ, questions, ratings and related-course blocks move into the introduction.
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
  // A section left empty (e.g. no FAQ block on the page) loses its tab.
  $$(".mcr-section--slots").forEach((section) => {
    if (section.querySelector("[nh-block]")) return;
    section.hidden = true;
    root.querySelector(`[data-mcr-anchor][href="#${section.id}"]`)?.remove();
  });

  // Introduction tabs: jump to a section; the tab of the section being read stays highlighted.
  const anchors = $$("[data-mcr-anchor]");
  const sections = anchors.map((anchor) => root.querySelector(anchor.getAttribute("href"))).filter(Boolean);
  function highlight(id) {
    anchors.forEach((anchor) => {
      const active = anchor.getAttribute("href") === `#${id}`;
      anchor.classList.toggle("is-active", active);
      if (active) anchor.setAttribute("aria-current", "true"); else anchor.removeAttribute("aria-current");
    });
  }
  anchors.forEach((anchor) => anchor.addEventListener("click", (event) => {
    const target = root.querySelector(anchor.getAttribute("href"));
    if (!target) return;
    event.preventDefault();
    target.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
    highlight(target.id);
  }));
  if (sections.length) {
    highlight(sections[0].id);
    window.addEventListener("scroll", () => {
      if (introView.hidden) return;
      // The section whose top has passed a line just under the sticky tabs is the one being read.
      const line = 150;
      let currentId = sections[0].id;
      sections.forEach((section) => { if (!section.hidden && section.getBoundingClientRect().top <= line) currentId = section.id; });
      highlight(currentId);
    }, { passive: true });
  }

  renderProgress();
  const initial = Number(new URLSearchParams(location.search).get("bai"));
  if (byNumber.has(initial)) selectLesson(initial, { push: false, scroll: false });
})();
