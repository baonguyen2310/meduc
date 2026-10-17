/* Quiz flow in the course classroom's "Bài tập" tab (block/product_detail/view_classroom.tpl).
   It replaces the Bootstrap modal built by assets/js/custom.js, whose close button reloaded the page:
   - all questions in a scrollable column, a right-side question map, and a countdown when time is limited;
   - submitting (or running out of time) shows the score, then each question with the right answer and the explanation;
   - a signed-in student's result is saved to /quizs-answer/add with the same fields as before.
   A lesson may have several quizzes: list -> that quiz's saved history -> player/review, with a back button at each level.
   A quiz's questions load from /khoa-hoc/bai-tap/{course}/{quiz} when it starts
   (QuizsAnswerController::player, which also checks the visitor may take it).
   An attempt stays in memory while the visitor moves between lessons, tabs and quizzes; nothing reloads the page. */
(() => {
  "use strict";
  const root = document.querySelector("[data-mcr]");
  const host = root && root.querySelector("[data-mcr-quiz-player]");
  if (!root || !host || host.dataset.mcqReady) return;
  host.dataset.mcqReady = "1";

  const quizzes = {}; // quiz id -> {id, name, minutes, questions}, loaded on first start
  const productId = Number(root.dataset.mcrProduct) || 0;

  const memberId = Number(root.dataset.mcrMember) || 0;
  const policy = root.querySelector("[data-mcr-policy]");
  const letters = ["A", "B", "C", "D", "E"];
  const pad = (number) => String(number).padStart(2, "0");
  const clock = (seconds) => `${pad(Math.floor(seconds / 60))}:${pad(seconds % 60)}`;
  const percentText = (value) => `${value.toLocaleString("vi-VN", { maximumFractionDigits: 1 })}%`;
  const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const inlineMobileQuery = matchMedia("(max-width: 767.98px)");
  // Question texts usually start with their own "Câu 3." — the player already shows the number.
  const dropNumber = (html) => html.replace(/^(\s*<p>)?\s*Câu\s*\d+\s*[.:)]\s*/i, "$1");

  const attempts = new Map(); // quiz id -> attempt
  let active = null;
  let lessonNumber = 0;
  let view = "list"; // list -> history of one quiz -> player/review
  let selected = null;
  let historyRequest = 0;

  function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  }
  function button(className, text) {
    const node = el("button", className, text);
    node.type = "button";
    return node;
  }

  // Attempts
  function newAttempt(quiz, lesson) {
    return {
      quiz,
      lesson,
      answers: new Map(), // question index -> chosen value
      index: 0,
      state: "doing", // doing | done | review
      started: Date.now(),
      deadline: quiz.minutes > 0 ? Date.now() + quiz.minutes * 60000 : 0,
      spent: 0,
      timeUp: false,
      confirming: false,
      saved: "",
    };
  }
  function correctCount(attempt) {
    if (attempt.record) return attempt.record.correct;
    return attempt.quiz.questions.filter((question, index) => attempt.answers.get(index) === question.answer).length;
  }

  // Timer: one interval for whichever attempt is running, even while it is out of sight.
  setInterval(() => {
    attempts.forEach((attempt) => {
      if (attempt.state !== "doing") return;
      if (attempt.deadline && Date.now() >= attempt.deadline) {
        attempt.timeUp = true;
        submit(attempt);
      } else if (attempt === active && !host.hidden) {
        renderTimer();
      }
    });
    updateStartButtons();
  }, 1000);

  // The quizzes of a lesson, in the order of their cards (only those the visitor may take have a start button).
  const lessonStarts = (number) => [...root.querySelectorAll(`[data-mcr-quiz="${number}"] [data-mcr-quiz-start]`)];
  const lessonQuizCount = (number) => root.querySelectorAll(`[data-mcr-quiz="${number}"] .mcr-quiz-card`).length;

  // Layout of the player
  const bar = el("div", "mcq-bar");
  const back = button("mcq-back", "← Danh sách đề");
  back.addEventListener("click", () => {
    if (view === "player" && selected) openHistory(selected);
    else showList();
  });
  const barTitle = el("div", "mcq-bar-title");
  const kicker = el("span", "mcq-kicker");
  const name = el("strong", "mcq-name");
  barTitle.append(kicker, name);
  const barMeta = el("div", "mcq-bar-meta");
  const progress = el("span", "mcq-progress");
  const timer = el("span", "mcq-timer");
  timer.setAttribute("role", "timer");
  const submitButton = button("mcr-btn mcr-btn--primary mcq-submit", "Nộp bài");
  const resultButton = button("mcr-btn mcr-btn--ghost mcq-to-result", "Xem kết quả");
  barMeta.append(progress, timer, submitButton, resultButton);
  bar.append(back, barTitle, barMeta);
  const confirmBox = el("div", "mcq-confirm");
  confirmBox.setAttribute("role", "alert");
  const workspace = el("div", "mcq-workspace");
  const stage = el("div", "mcq-stage");
  stage.setAttribute("aria-label", "Nội dung bài tập");
  const mapPanel = el("aside", "mcq-map-panel");
  mapPanel.setAttribute("aria-label", "Điều hướng câu hỏi");
  const mapHead = el("div", "mcq-map-head");
  mapHead.append(el("strong", "", "Danh sách câu"));
  const expandButton = button("mcq-expand");
  expandButton.setAttribute("aria-label", "Phóng to vùng làm bài");
  expandButton.title = "Phóng to vùng làm bài";
  expandButton.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 3H4a1 1 0 0 0-1 1v5m12-6h5a1 1 0 0 1 1 1v5M3 15v5a1 1 0 0 0 1 1h5m12-6v5a1 1 0 0 1-1 1h-5"/></svg>';
  mapHead.append(expandButton);
  const map = el("div", "mcq-map");
  map.setAttribute("aria-label", "Chọn câu hỏi");
  mapPanel.append(mapHead, map);
  workspace.append(stage, mapPanel);
  const playerPolicy = el("p", "mcq-policy", "Bộ đề được đội ngũ ThS, BSNT của MedUC tổng hợp, rà soát và giải đáp, có hỗ trợ một phần của AI. Nội dung có thể còn sai sót; MedUC trân trọng mọi góp ý về đề, đáp án và lộ trình học.");
  host.append(bar, confirmBox, workspace, playerPolicy);

  function setExpanded(expanded) {
    host.classList.toggle("is-expanded", expanded);
    document.body.classList.toggle("mcr-quiz-expanded", expanded);
    if (expanded) {
      host.setAttribute("role", "dialog");
      host.setAttribute("aria-modal", "true");
      host.setAttribute("aria-label", "Làm bài tập");
    } else {
      host.removeAttribute("role");
      host.removeAttribute("aria-modal");
      host.removeAttribute("aria-label");
    }
    expandButton.setAttribute("aria-label", expanded ? "Thu nhỏ vùng làm bài" : "Phóng to vùng làm bài");
    expandButton.title = expanded ? "Thu nhỏ vùng làm bài" : "Phóng to vùng làm bài";
    expandButton.setAttribute("aria-pressed", String(expanded));
    expandButton.innerHTML = expanded
      ? '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 9h5a1 1 0 0 0 1-1V3m12 6h-5a1 1 0 0 1-1-1V3M3 15h5a1 1 0 0 1 1 1v5m12-6h-5a1 1 0 0 0-1 1v5"/></svg>'
      : '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 3H4a1 1 0 0 0-1 1v5m12-6h5a1 1 0 0 1 1 1v5M3 15v5a1 1 0 0 0 1 1h5m12-6v5a1 1 0 0 1-1 1h-5"/></svg>';
  }
  expandButton.addEventListener("click", () => setExpanded(!host.classList.contains("is-expanded")));
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && host.classList.contains("is-expanded")) {
      event.preventDefault();
      setExpanded(false);
    }
    if (event.key === "Tab" && host.classList.contains("is-expanded")) {
      const controls = [...host.querySelectorAll('button:not([disabled]):not([hidden]), a[href]:not([hidden])')]
        .filter((control) => control.getClientRects().length);
      if (!controls.length) return;
      const first = controls[0], last = controls[controls.length - 1];
      if (event.shiftKey && (document.activeElement === first || !host.contains(document.activeElement))) {
        event.preventDefault(); last.focus();
      } else if (!event.shiftKey && (document.activeElement === last || !host.contains(document.activeElement))) {
        event.preventDefault(); first.focus();
      }
    }
  });
  root.addEventListener("mcr:contribute", () => setExpanded(false));

  function renderTimer() {
    const attempt = active;
    if (!attempt) return;
    if (attempt.state !== "doing") {
      timer.textContent = `Thời gian làm: ${clock(attempt.spent)}`;
      timer.classList.remove("is-low");
      return;
    }
    if (attempt.deadline) {
      const left = Math.max(0, Math.ceil((attempt.deadline - Date.now()) / 1000));
      timer.textContent = `Còn ${clock(left)}`;
      timer.classList.toggle("is-low", left <= 60);
    } else {
      timer.textContent = clock(Math.floor((Date.now() - attempt.started) / 1000));
    }
  }

  function renderConfirm(attempt) {
    confirmBox.replaceChildren();
    confirmBox.hidden = !attempt.confirming;
    if (attempt.confirming) {
      const left = attempt.quiz.questions.length - attempt.answers.size;
      const sendAnyway = button("mcr-btn mcr-btn--primary", "Nộp luôn");
      const keepGoing = button("mcr-btn mcr-btn--ghost", "Làm tiếp");
      sendAnyway.addEventListener("click", () => submit(attempt));
      keepGoing.addEventListener("click", () => { attempt.confirming = false; renderConfirm(attempt); });
      confirmBox.append(el("p", "", `Còn ${left} câu chưa làm. Câu bỏ trống được tính là sai.`), sendAnyway, keepGoing);
    }
  }

  function render() {
    const attempt = active;
    if (!attempt || view !== "player") return;
    const total = attempt.quiz.questions.length;
    const count = lessonQuizCount(attempt.lesson.number);
    const place = lessonStarts(attempt.lesson.number).findIndex((startButton) => Number(startButton.dataset.mcrQuizStart) === attempt.quiz.id);
    kicker.textContent = count > 1 && place >= 0 ? `Bài tập ${place + 1}/${count} · Buổi ${attempt.lesson.number}` : `Bài tập · Buổi ${attempt.lesson.number}`;
    back.hidden = false;
    back.textContent = "← Lịch sử bài tập";
    barMeta.hidden = false;
    name.textContent = attempt.quiz.name;
    progress.textContent = attempt.state === "doing" ? `Đã làm ${attempt.answers.size}/${total}` : `${correctCount(attempt)}/${total} câu đúng`;
    submitButton.hidden = attempt.state !== "doing";
    resultButton.hidden = attempt.state !== "review";
    renderTimer();
    renderConfirm(attempt);

    if (attempt.state === "done") renderResult(attempt); else renderQuestions(attempt);
    renderMap(attempt);
    stage.scrollTop = 0;
    if (attempt.state === "doing" && attempt.index > 0) jumpToQuestion(attempt, attempt.index, false);
  }

  function buildQuestion(attempt, index, inline = false) {
    const questions = attempt.quiz.questions;
    const question = questions[index];
    const chosen = attempt.answers.get(index);
    const reviewing = attempt.state !== "doing";
    const wrap = el("div", `mcq-question${inline && reviewing ? " mcq-review-question" : ""}`);
    wrap.dataset.mcqQuestion = String(index);
    wrap.append(el("p", "mcq-count", `Câu ${index + 1} / ${questions.length}`));
    const text = el("div", "mcq-text");
    text.innerHTML = dropNumber(question.question);
    wrap.append(text);
    if (question.note) {
      const extra = el("div", "mcq-note");
      extra.innerHTML = question.note;
      wrap.append(extra);
    }

    const options = el("div", "mcq-options");
    options.setAttribute("role", "radiogroup");
    options.setAttribute("aria-label", "Chọn đáp án");
    question.options.forEach(([value, html], position) => {
      const option = button("mcq-option");
      option.setAttribute("role", "radio");
      option.setAttribute("aria-checked", String(chosen === value));
      option.classList.toggle("is-selected", chosen === value);
      if (reviewing) {
        option.disabled = true;
        if (value === question.answer) option.classList.add("is-correct");
        else if (chosen === value) option.classList.add("is-wrong");
      }
      const letter = el("span", "mcq-letter", letters[position] || String(value));
      const body = el("span", "mcq-option-text");
      body.innerHTML = html;
      option.append(letter, body);
      if (!reviewing) option.addEventListener("click", () => choose(attempt, index, value));
      options.append(option);
    });
    wrap.append(options);

    if (reviewing) {
      if (chosen === undefined) wrap.append(el("p", "mcq-skipped", attempt.incompleteHistory ? "Bài nộp cũ không lưu được lựa chọn của câu này; bạn vẫn có thể xem đáp án và lời giải." : "Bạn chưa trả lời câu này."));
      const parts = question.explanation_parts;
      if ((parts && parts.options && parts.options.length) || question.explain) {
        const explain = el("div", "mcq-explain");
        explain.append(el("p", "mcq-explain-title", "Lời giải"));
        const body = el("div", "mcq-explain-body");
        if (parts && parts.options && parts.options.length) {
          if (parts.concept) {
            body.append(el("h3", "mcq-explain-heading", "Khái niệm"));
            body.append(el("p", "mcq-explain-concept", parts.concept));
          }
          if (parts.source) {
            body.append(el("h3", "mcq-explain-heading", "Giải thích gốc"));
            body.append(el("p", "mcq-explain-concept", parts.source));
          }
          body.append(el("h3", "mcq-explain-heading", "Giải thích từng lựa chọn"));
          const list = el("div", "mcq-explain-options");
          parts.options.forEach((part) => {
            const row = el("div", `mcq-explain-option ${part.correct ? "is-correct" : "is-wrong"}`);
            row.append(el("span", "mcq-explain-option-key", `${part.key}.`));
            const detail = el("span");
            detail.append(el("strong", "mcq-explain-verdict", part.correct ? "Đúng vì " : "Sai vì "));
            detail.append(document.createTextNode(part.reason));
            row.append(detail);
            list.append(row);
          });
          body.append(list);
        } else {
          const legacy = el("div", "mcq-explain-legacy");
          legacy.innerHTML = question.explain;
          body.append(legacy);
        }
        explain.append(body);
        wrap.append(explain);
      }
    }

    const nav = el("div", "mcq-nav");
    if (reviewing) {
      const contribute = button("mcq-contribute-question", "Góp ý câu này ↗");
      contribute.addEventListener("click", () => root.dispatchEvent(new CustomEvent("mcr:contribute", {
        detail: { quizId: attempt.quiz.id, questionNumber: index + 1, type: "answer" }
      })));
      nav.append(contribute);
    }
    if (nav.childElementCount) wrap.append(nav);
    return wrap;
  }

  function renderQuestions(attempt) {
    const list = el("div", "mcq-question-list");
    attempt.quiz.questions.forEach((question, index) => list.append(buildQuestion(attempt, index, true)));
    stage.replaceChildren(list);
    mapPanel.hidden = false;
  }

  function renderMap(attempt) {
    map.replaceChildren();
    mapPanel.hidden = false;
    attempt.quiz.questions.forEach((question, index) => {
      const cell = button("mcq-cell", String(index + 1));
      const chosen = attempt.answers.get(index);
      if (attempt.state !== "doing") {
        cell.classList.add(chosen === undefined ? (attempt.incompleteHistory ? "is-unknown" : "is-skipped") : chosen === question.answer ? "is-correct" : "is-wrong");
      } else if (chosen !== undefined) {
        cell.classList.add("is-answered");
      }
      if (index === attempt.index) {
        cell.classList.add("is-current");
        cell.setAttribute("aria-current", "true");
      }
      cell.setAttribute("aria-label", `Câu ${index + 1}`);
      cell.addEventListener("click", () => jumpToQuestion(attempt, index));
      map.append(cell);
    });
  }

  function renderResult(attempt) {
    const total = attempt.quiz.questions.length;
    const correct = correctCount(attempt);
    const skipped = total - attempt.answers.size;
    const ratio = total ? (correct / total) * 100 : 0;
    const box = el("div", "mcq-result");
    box.append(el("p", "mcq-result-kicker", attempt.timeUp ? "Hết giờ · Bài đã được nộp" : "Kết quả bài làm"));
    const score = el("p", "mcq-score");
    score.append(el("strong", "", String(correct)), el("span", "", ` / ${total} câu đúng`));
    box.append(score);
    const meter = el("div", "mcq-meter");
    meter.setAttribute("aria-hidden", "true");
    const fill = el("span");
    fill.style.width = `${ratio}%`;
    meter.append(fill);
    box.append(meter);
    const stats = el("dl", "mcq-stats");
    [["Tỉ lệ đúng", percentText(ratio)], ["Câu sai", String(total - correct - skipped)], ["Bỏ trống", String(skipped)], ["Thời gian", clock(attempt.spent)]].forEach(([term, value]) => {
      const row = el("div");
      row.append(el("dt", "", term), el("dd", "", value));
      stats.append(row);
    });
    box.append(stats);

    const saved = el("p", "mcq-saved");
    if (memberId) {
      saved.textContent = attempt.saved || "Đang lưu kết quả…";
    } else {
      saved.append("Kết quả chưa được lưu. ");
      const login = el("a", "", "Đăng nhập");
      login.href = "javascript:;";
      login.setAttribute("data-bs-toggle", "modal");
      login.setAttribute("data-bs-target", "#login-modal");
      saved.append(login, " để lưu vào lịch sử làm bài.");
    }
    box.append(saved);

    if (root.dataset.mcrLicensed !== "1") {
      const priceSource = root.querySelector(".mcr-intro-side .mcr-price");
      if (priceSource) {
        const offer = el("div", "mcq-result-offer");
        offer.append(el("p", "mcq-result-offer-label", "Học trọn khóa học"), priceSource.cloneNode(true));
        box.append(offer);
      }
    }

    const postActions = el("div", "mcq-post-actions");
    if (root.dataset.mcrLicensed === "1") {
      const course = button("mcr-btn mcr-btn--primary", "Về khóa học");
      course.addEventListener("click", () => { setExpanded(false); root.querySelector("[data-mcr-intro]")?.click(); });
      postActions.append(course);
    } else {
      const buySource = root.querySelector(".mcr-toolbar-buy .mcr-btn--primary");
      if (buySource) {
        const buy = buySource.cloneNode(true);
        buy.textContent = "Đăng ký khóa học";
        buy.addEventListener("click", () => setExpanded(false));
        postActions.append(buy);
      }
    }
    const contribute = button("mcr-btn mcr-btn--ghost", "Góp ý bài này");
    contribute.addEventListener("click", () => root.dispatchEvent(new CustomEvent("mcr:contribute", {
      detail: { quizId: attempt.quiz.id, type: "general" }
    })));
    postActions.append(contribute);
    box.append(postActions);

    const review = el("section", "mcq-result-review");
    review.append(el("h3", "mcq-result-review-title", `Xem lại ${total} câu hỏi và lời giải`));
    attempt.quiz.questions.forEach((question, index) => review.append(buildQuestion(attempt, index, true)));
    box.append(review);

    const actions = el("div", "mcq-actions");
    const retry = button("mcr-btn mcr-btn--ghost", "Làm lại");
    retry.addEventListener("click", () => start(attempt.quiz, attempt.lesson, true));
    actions.append(retry);
    const history = button("mcr-btn mcr-btn--ghost", "Lịch sử bài tập");
    history.addEventListener("click", () => selected && openHistory(selected));
    const list = button("mcr-btn mcr-btn--ghost", "Danh sách đề");
    list.addEventListener("click", showList);
    actions.append(history, list);
    box.append(actions);
    stage.replaceChildren(box);
  }
  function showList() {
    historyRequest++;
    view = "list";
    active = null;
    selected = null;
    sync();
    updateStartButtons();
  }

  function historyRows() {
    const rows = [...(selected.history || [])];
    const local = attempts.get(selected.id);
    if (local && local.state !== "doing" && !rows.some((row) => row.id === local.savedRecordId)) {
      rows.unshift({
        id: 0, localAttempt: local, created: Math.floor(Date.now() / 1000),
        total: local.quiz.questions.length, correct: correctCount(local), seconds: local.spent,
      });
    }
    return rows;
  }

  function renderHistory() {
    if (view !== "history" || !selected) return;
    back.hidden = false;
    back.textContent = "← Danh sách đề";
    kicker.textContent = `Lịch sử bài tập · Buổi ${selected.lesson.number}`;
    name.textContent = selected.title;
    barMeta.hidden = true;
    confirmBox.hidden = true;
    mapPanel.hidden = true;
    const panel = el("div", "mcq-history");
    panel.append(el("p", "mcq-result-kicker", "Bài tập đã chọn"));
    panel.append(el("h2", "mcq-history-title", selected.title));
    panel.append(el("p", "mcq-history-subtitle", "Xem các lần đã làm hoặc bắt đầu một lần mới."));
    const current = attempts.get(selected.id);
    const startButton = button("mcr-btn mcr-btn--primary", current && current.state === "doing" ? "Tiếp tục làm bài" : "Bắt đầu làm bài");
    startButton.addEventListener("click", () => beginSelected(startButton));
    panel.append(startButton);
    if (current && current.state === "doing" && current.deadline) {
      panel.append(el("p", "mcq-history-hint", "Bài đang làm vẫn tiếp tục tính giờ khi bạn rời màn hình làm bài."));
    }
    const rows = historyRows();
    const heading = el("h3", "mcq-history-heading", `Lịch sử làm bài${selected.loading ? "" : ` · ${rows.length} lần`}`);
    panel.append(heading);
    if (selected.loading) {
      panel.append(el("p", "mcq-history-empty", "Đang tải lịch sử…"));
    } else if (selected.error) {
      const error = el("p", "mcq-history-error", selected.error);
      error.setAttribute("role", "alert");
      panel.append(error);
    } else if (!rows.length) {
      panel.append(el("p", "mcq-history-empty", memberId ? "Bạn chưa làm bài tập này. Hãy bắt đầu lần đầu tiên." : "Đăng nhập để lưu và xem lịch sử làm bài của bạn."));
    } else {
      const list = el("div", "mcq-history-list");
      rows.forEach((record, index) => {
        const item = el("div", "mcq-history-item");
        const copy = el("div", "mcq-history-copy");
        copy.append(el("strong", "", `Lần ${rows.length - index}`));
        copy.append(el("span", "", record.localAttempt && !record.localAttempt.savedRecordId ? (record.localAttempt.saved || "Bài vừa làm · đang chờ lưu") : new Date(record.created * 1000).toLocaleString("vi-VN")));
        const score = el("div", "mcq-history-score");
        score.append(el("strong", "", `${record.correct}/${record.total}`));
        score.append(el("span", "", `${record.total ? Math.round(record.correct / record.total * 100) : 0}% đúng · ${clock(record.seconds)}`));
        const review = button("mcr-btn mcr-btn--ghost", "Xem lại");
        review.addEventListener("click", () => reviewHistory(record, review));
        item.append(copy, score, review);
        list.append(item);
      });
      panel.append(list);
    }
    stage.replaceChildren(panel);
    stage.scrollTop = 0;
  }

  async function openHistory(context) {
    const request = ++historyRequest;
    selected = context;
    selected.loading = true;
    selected.error = "";
    view = "history";
    active = null;
    sync();
    renderHistory();
    reveal();
    try {
      const response = await fetch(`/khoa-hoc/bai-tap/${productId}/${context.id}/lich-su`, { credentials: "same-origin", headers: { Accept: "application/json" } });
      const body = await response.json().catch(() => null);
      if (!response.ok || !body || body.code !== "success" || !Array.isArray(body.data)) throw new Error((body && body.message) || "Chưa tải được lịch sử làm bài.");
      if (request !== historyRequest || view !== "history") return;
      context.history = body.data;
    } catch (error) {
      if (request !== historyRequest || view !== "history") return;
      context.error = error.message || "Chưa tải được lịch sử làm bài.";
    }
    context.loading = false;
    renderHistory();
  }

  async function beginSelected(control) {
    if (!selected) return;
    const context = selected;
    control.disabled = true;
    control.textContent = "Đang tải đề…";
    try {
      const quiz = await load(context.id);
      if (view !== "history" || selected !== context) return;
      const current = attempts.get(context.id);
      start(quiz, context.lesson, !current || current.state !== "doing");
    } catch (error) {
      if (view === "history" && selected === context) {
        context.error = error.message || "Chưa tải được đề. Bạn thử lại sau ít phút nhé.";
        renderHistory();
      }
    } finally {
      control.disabled = false;
    }
  }

  async function reviewHistory(record, control) {
    if (!selected) return;
    const context = selected;
    control.disabled = true;
    control.textContent = "Đang tải…";
    try {
      const quiz = await load(context.id);
      if (view !== "history" || selected !== context) return;
      const attempt = record.localAttempt || newAttempt(quiz, context.lesson);
      if (!record.localAttempt) {
        attempt.record = record;
        attempt.spent = record.seconds;
        attempt.saved = "Đây là bài làm đã lưu trong lịch sử của bạn.";
        const positions = new Map();
        quiz.questions.forEach((question, index) => {
          const matches = positions.get(question.code) || [];
          matches.push(index);
          positions.set(question.code, matches);
        });
        (record.answers || []).forEach((answer) => {
          const index = Number(answer.index);
          const position = answer.index !== undefined && Number.isInteger(index) && index >= 0 && index < quiz.questions.length
            ? index : (positions.get(answer.code) || []).length === 1 ? positions.get(answer.code)[0] : -1;
          const value = Number(answer.answer);
          if (position >= 0 && Number.isInteger(value) && value >= 1 && value <= 5) attempt.answers.set(position, value);
          else attempt.incompleteHistory = true;
        });
      }
      attempt.state = "review";
      attempt.index = 0;
      active = attempt;
      view = "player";
      sync();
      render();
      reveal();
    } catch (error) {
      if (view === "history" && selected === context) {
        context.error = error.message || "Chưa mở được bài làm này.";
        renderHistory();
      }
    } finally {
      control.disabled = false;
    }
  }

  // Actions
  function setCurrentQuestion(attempt, index) {
    attempt.index = index;
    [...map.children].forEach((cell, position) => {
      cell.classList.toggle("is-current", position === index);
      if (position === index) cell.setAttribute("aria-current", "true");
      else cell.removeAttribute("aria-current");
    });
  }
  function choose(attempt, index, value) {
    attempt.answers.set(index, value);
    attempt.confirming = false;
    renderConfirm(attempt);
    progress.textContent = `Đã làm ${attempt.answers.size}/${attempt.quiz.questions.length}`;
    const card = stage.querySelector(`[data-mcq-question="${index}"]`);
    card?.querySelectorAll(".mcq-option").forEach((option, position) => {
      const selected = attempt.quiz.questions[index].options[position][0] === value;
      option.classList.toggle("is-selected", selected);
      option.setAttribute("aria-checked", String(selected));
    });
    map.children[index]?.classList.add("is-answered");
    setCurrentQuestion(attempt, index);
  }
  function jumpToQuestion(attempt, index, animate = true) {
    if (index < 0 || index >= attempt.quiz.questions.length) return;
    const card = stage.querySelector(`[data-mcq-question="${index}"]`);
    if (!card) return;
    setCurrentQuestion(attempt, index);
    const mobileInline = !host.classList.contains("is-expanded") && inlineMobileQuery.matches;
    if (mobileInline) {
      card.scrollIntoView({ block: "start", behavior: animate && !reducedMotion ? "smooth" : "auto" });
      return;
    }
    const top = card.getBoundingClientRect().top - stage.getBoundingClientRect().top + stage.scrollTop - 16;
    stage.scrollTo({ top, behavior: animate && !reducedMotion ? "smooth" : "auto" });
  }
  function trackVisibleQuestion() {
    if (view !== "player" || !active) return;
    const mobileInline = !host.classList.contains("is-expanded") && inlineMobileQuery.matches;
    const top = mobileInline ? Math.min(180, window.innerHeight * 0.3) : stage.getBoundingClientRect().top + Math.min(160, stage.clientHeight * 0.3);
    const cards = stage.querySelectorAll("[data-mcq-question]");
    for (const card of cards) {
      if (card.getBoundingClientRect().bottom > top) {
        const index = Number(card.dataset.mcqQuestion);
        if (index !== active.index) setCurrentQuestion(active, index);
        break;
      }
    }
  }
  let questionScrollFrame = 0;
  function scheduleQuestionTracking() {
    if (questionScrollFrame) return;
    questionScrollFrame = requestAnimationFrame(() => {
      questionScrollFrame = 0;
      trackVisibleQuestion();
    });
  }
  stage.addEventListener("scroll", scheduleQuestionTracking, { passive: true });
  window.addEventListener("scroll", () => {
    if (!host.classList.contains("is-expanded") && inlineMobileQuery.matches) scheduleQuestionTracking();
  }, { passive: true });
  function askSubmit(attempt) {
    if (attempt.answers.size < attempt.quiz.questions.length) {
      attempt.confirming = true;
      renderConfirm(attempt);
      confirmBox.querySelector("button")?.focus();
      return;
    }
    submit(attempt);
  }
  function submit(attempt) {
    if (attempt.state !== "doing") return;
    attempt.state = "done";
    attempt.index = 0;
    attempt.confirming = false;
    attempt.spent = Math.max(0, Math.round((Math.min(Date.now(), attempt.deadline || Date.now()) - attempt.started) / 1000));
    save(attempt);
    if (attempt === active) { render(); reveal(); }
    updateStartButtons();
  }
  function save(attempt) {
    if (!memberId) return;
    const total = attempt.quiz.questions.length;
    const correct = correctCount(attempt);
    // index: the question's place in the quiz, which the server uses to mark the answers (codes repeat in old quizzes).
    const answers = attempt.quiz.questions
      .map((question, index) => ({ index, code: question.code, answer: attempt.answers.get(index) }))
      .filter((item) => item.answer !== undefined)
      .map((item) => ({ index: item.index, code: item.code, answer: String(item.answer) }));
    const data = {
      class_room_id: Number(root.dataset.mcrClassRoom) || 0,
      member_code: root.dataset.mcrMemberCode || "",
      quiz_id: attempt.quiz.id,
      product_id: Number(root.dataset.mcrProduct) || 0,
      customer_id: memberId,
      lesson_name: attempt.lesson.title,
      lesson_code: attempt.lesson.code,
      answers: JSON.stringify(answers),
      answer_total: total,
      answer_correct: correct,
      answer_wrong: total - correct,
      answer_correct_percent: (total ? (correct / total) * 100 : 0).toFixed(2),
      total_time: attempt.spent,
    };
    const done = (message, savedId = 0) => {
      attempt.saved = message;
      if (savedId) attempt.savedRecordId = savedId;
      if (attempt === active && attempt.state === "done" && view === "player") {
        const saved = stage.querySelector(".mcq-saved");
        if (saved) saved.textContent = message;
      }
      if (view === "history" && selected && selected.id === attempt.quiz.id) openHistory(selected);
    };
    if (window.nhMain && typeof window.nhMain.callAjax === "function") {
      window.nhMain.callAjax({ async: true, url: "/quizs-answer/add", data })
        .done((response) => {
          let result = response;
          if (typeof result === "string") { try { result = JSON.parse(result); } catch (error) { result = null; } }
          if (result && result.code === "success") done("Đã lưu vào lịch sử làm bài của bạn.", Number(result.data && result.data.id) || 0);
          else done(`Chưa lưu được kết quả${result && result.message ? `: ${result.message}` : "."} Bạn vẫn xem được lời giải bên dưới.`);
        })
        .fail(() => done("Chưa lưu được kết quả. Bạn vẫn xem được lời giải bên dưới."));
    } else {
      done("Chưa lưu được kết quả. Bạn vẫn xem được lời giải bên dưới.");
    }
  }

  function start(quiz, lesson, fresh) {
    let attempt = attempts.get(quiz.id);
    if (!attempt || fresh) {
      attempt = newAttempt(quiz, lesson);
      attempts.set(quiz.id, attempt);
    }
    active = attempt;
    selected = selected && selected.id === quiz.id ? selected : { id: quiz.id, title: quiz.name, lesson };
    view = "player";
    sync();
    render();
    reveal();
    stage.querySelector(".mcq-option, button")?.focus({ preventScroll: true });
  }
  // Keep the top of the player in view (the page header is sticky).
  function reveal() {
    if (host.hidden) return;
    const top = host.getBoundingClientRect().top;
    if (top < 70 || top > window.innerHeight * 0.6) host.scrollIntoView({ block: "start", behavior: reducedMotion ? "auto" : "smooth" });
  }

  // The selected quiz's history or player replaces the lesson's quiz list.
  function sync() {
    const showing = view !== "list" && selected && selected.lesson.number === lessonNumber;
    if (view !== "player" || !showing) setExpanded(false);
    host.hidden = !showing;
    if (policy) policy.hidden = !!showing;
    root.querySelectorAll("[data-mcr-quiz]").forEach((card) => {
      card.classList.toggle("is-covered", showing && Number(card.dataset.mcrQuiz) === lessonNumber);
    });
  }
  function updateStartButtons() {
    root.querySelectorAll("[data-mcr-quiz-start]").forEach((startButton) => {
      const attempt = attempts.get(Number(startButton.dataset.mcrQuizStart));
      startButton.textContent = attempt && attempt.state === "doing" ? "Xem lịch sử · Đang làm" : "Xem lịch sử & làm bài";
    });
  }

  async function load(id) {
    if (quizzes[id]) return quizzes[id];
    const response = await fetch(`/khoa-hoc/bai-tap/${productId}/${id}`, { credentials: "same-origin", headers: { Accept: "application/json" } });
    const body = await response.json().catch(() => null);
    if (!response.ok || !body || body.code !== "success" || !body.data) throw new Error((body && body.message) || "");
    quizzes[id] = body.data;
    return body.data;
  }
  root.querySelectorAll("[data-mcr-quiz-start]").forEach((startButton) => startButton.addEventListener("click", () => {
    if (startButton.disabled) return;
    const id = Number(startButton.dataset.mcrQuizStart);
    const card = startButton.closest(".mcr-quiz-card");
    lessonNumber = Number(startButton.dataset.lesson);
    openHistory({
      id, title: card?.querySelector("h3")?.textContent?.trim() || "Bài tập",
      lesson: { number: lessonNumber, title: startButton.dataset.lessonTitle || "", code: startButton.dataset.lessonCode || "" },
    });
  }));
  submitButton.addEventListener("click", () => active && askSubmit(active));
  resultButton.addEventListener("click", () => { if (active) { active.state = "done"; render(); reveal(); } });
  root.addEventListener("mcr:lesson", (event) => {
    lessonNumber = event.detail.number;
    showList();
  });

  // Keyboard: 1–5 or A–E pick an answer, ← → move between questions.
  document.addEventListener("keydown", (event) => {
    if (!active || host.hidden || active.state === "done" || event.altKey || event.ctrlKey || event.metaKey) return;
    const target = event.target;
    if (target && (target.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName))) return;
    if (!host.contains(target) && target !== document.body) return;
    const key = event.key.toLowerCase();
    const position = "12345".indexOf(key) >= 0 ? "12345".indexOf(key) : "abcde".indexOf(key);
    if (position >= 0 && active.state === "doing") {
      const option = active.quiz.questions[active.index].options[position];
      if (option) { event.preventDefault(); choose(active, active.index, option[0]); }
    } else if (event.key === "ArrowRight") {
      event.preventDefault();
      jumpToQuestion(active, active.index + 1);
    } else if (event.key === "ArrowLeft") {
      event.preventDefault();
      jumpToQuestion(active, active.index - 1);
    }
  });

  // Leaving the page in the middle of a quiz loses it, so the browser asks first.
  window.addEventListener("beforeunload", (event) => {
    if ([...attempts.values()].some((attempt) => attempt.state === "doing")) {
      event.preventDefault();
      event.returnValue = "";
    }
  });
})();
