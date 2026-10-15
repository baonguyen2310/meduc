/* Quiz player in the course classroom's "Bài tập" tab (block/product_detail/view_classroom.tpl).
   It replaces the Bootstrap modal built by assets/js/custom.js, whose close button reloaded the page:
   - one question at a time, a map of every question, and a countdown when the quiz has a time limit;
   - submitting (or running out of time) shows the score, then each question with the right answer and the explanation;
   - a signed-in student's result is saved to /quizs-answer/add with the same fields as before.
   An attempt stays in memory while the visitor moves between lessons and tabs; nothing reloads the page. */
(() => {
  "use strict";
  const root = document.querySelector("[data-mcr]");
  const dataTag = root && root.querySelector("[data-mcr-quiz-data]");
  const host = root && root.querySelector("[data-mcr-quiz-player]");
  if (!root || !dataTag || !host || host.dataset.mcqReady) return;
  host.dataset.mcqReady = "1";

  let quizzes = {};
  try { quizzes = JSON.parse(dataTag.textContent) || {}; } catch (error) { return; }

  const note = root.querySelector("[data-mcr-quiz-note]");
  const memberId = Number(root.dataset.mcrMember) || 0;
  const letters = ["A", "B", "C", "D", "E"];
  const pad = (number) => String(number).padStart(2, "0");
  const clock = (seconds) => `${pad(Math.floor(seconds / 60))}:${pad(seconds % 60)}`;
  const percentText = (value) => `${value.toLocaleString("vi-VN", { maximumFractionDigits: 1 })}%`;
  const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  // Question texts usually start with their own "Câu 3." — the player already shows the number.
  const dropNumber = (html) => html.replace(/^(\s*<p>)?\s*Câu\s*\d+\s*[.:)]\s*/i, "$1");

  const attempts = new Map(); // quiz id -> attempt
  let active = null;
  let lessonNumber = 0;

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

  // Layout of the player
  const bar = el("div", "mcq-bar");
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
  bar.append(barTitle, barMeta);
  const confirmBox = el("div", "mcq-confirm");
  confirmBox.setAttribute("role", "alert");
  const stage = el("div", "mcq-stage");
  const map = el("div", "mcq-map");
  map.setAttribute("aria-label", "Chọn câu hỏi");
  host.append(bar, confirmBox, stage, map);

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

  function render() {
    const attempt = active;
    if (!attempt) return;
    const total = attempt.quiz.questions.length;
    kicker.textContent = `Bài tập · Buổi ${attempt.lesson.number}`;
    name.textContent = attempt.quiz.name;
    progress.textContent = attempt.state === "doing" ? `Đã làm ${attempt.answers.size}/${total}` : `${correctCount(attempt)}/${total} câu đúng`;
    submitButton.hidden = attempt.state !== "doing";
    resultButton.hidden = attempt.state !== "review";
    renderTimer();

    confirmBox.replaceChildren();
    confirmBox.hidden = !attempt.confirming;
    if (attempt.confirming) {
      const left = total - attempt.answers.size;
      const sendAnyway = button("mcr-btn mcr-btn--primary", "Nộp luôn");
      const keepGoing = button("mcr-btn mcr-btn--ghost", "Làm tiếp");
      sendAnyway.addEventListener("click", () => submit(attempt));
      keepGoing.addEventListener("click", () => { attempt.confirming = false; render(); });
      confirmBox.append(el("p", "", `Còn ${left} câu chưa làm. Câu bỏ trống được tính là sai.`), sendAnyway, keepGoing);
    }

    if (attempt.state === "done") renderResult(attempt); else renderQuestion(attempt);
    renderMap(attempt);
    if (note) note.hidden = attempt.state === "done";
  }

  function renderQuestion(attempt) {
    const questions = attempt.quiz.questions;
    const question = questions[attempt.index];
    const chosen = attempt.answers.get(attempt.index);
    const reviewing = attempt.state === "review";
    const wrap = el("div", "mcq-question");
    wrap.append(el("p", "mcq-count", `Câu ${attempt.index + 1} / ${questions.length}`));
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
      if (!reviewing) option.addEventListener("click", () => choose(attempt, value));
      options.append(option);
    });
    wrap.append(options);

    if (reviewing) {
      if (chosen === undefined) wrap.append(el("p", "mcq-skipped", "Bạn chưa trả lời câu này."));
      if (question.explain) {
        const explain = el("div", "mcq-explain");
        explain.append(el("p", "mcq-explain-title", "Lời giải"));
        const body = el("div", "mcq-explain-body");
        body.innerHTML = question.explain;
        explain.append(body);
        wrap.append(explain);
      }
    }

    const nav = el("div", "mcq-nav");
    const previous = button("mcr-nav-button", "← Câu trước");
    const next = button("mcr-nav-button", attempt.index === questions.length - 1 && !reviewing ? "Nộp bài" : "Câu tiếp →");
    previous.disabled = attempt.index === 0;
    next.disabled = reviewing && attempt.index === questions.length - 1;
    previous.addEventListener("click", () => go(attempt, attempt.index - 1));
    next.addEventListener("click", () => {
      if (!reviewing && attempt.index === questions.length - 1) askSubmit(attempt);
      else go(attempt, attempt.index + 1);
    });
    nav.append(previous, next);
    wrap.append(nav);
    stage.replaceChildren(wrap);
    map.hidden = false;
  }

  function renderMap(attempt) {
    map.replaceChildren();
    if (attempt.state === "done") { map.hidden = true; return; }
    attempt.quiz.questions.forEach((question, index) => {
      const cell = button("mcq-cell", String(index + 1));
      const chosen = attempt.answers.get(index);
      if (attempt.state === "review") {
        cell.classList.add(chosen === undefined ? "is-skipped" : chosen === question.answer ? "is-correct" : "is-wrong");
      } else if (chosen !== undefined) {
        cell.classList.add("is-answered");
      }
      if (index === attempt.index) {
        cell.classList.add("is-current");
        cell.setAttribute("aria-current", "true");
      }
      cell.setAttribute("aria-label", `Câu ${index + 1}`);
      cell.addEventListener("click", () => go(attempt, index));
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

    const actions = el("div", "mcq-actions");
    const review = button("mcr-btn mcr-btn--primary", "Xem lời giải chi tiết");
    review.addEventListener("click", () => { attempt.state = "review"; attempt.index = firstToReview(attempt); render(); reveal(); });
    const retry = button("mcr-btn mcr-btn--ghost", "Làm lại");
    retry.addEventListener("click", () => start(attempt.quiz, attempt.lesson, true));
    actions.append(review, retry);
    const nextLesson = root.querySelector("[data-mcr-next]");
    if (nextLesson && !nextLesson.disabled) {
      const onward = button("mcr-btn mcr-btn--ghost", "Sang bài tiếp theo →");
      onward.addEventListener("click", () => nextLesson.click());
      actions.append(onward);
    }
    box.append(actions);
    stage.replaceChildren(box);
  }
  // Review opens on the first question that was wrong or skipped.
  function firstToReview(attempt) {
    const index = attempt.quiz.questions.findIndex((question, i) => attempt.answers.get(i) !== question.answer);
    return index < 0 ? 0 : index;
  }

  // Actions
  function choose(attempt, value) {
    attempt.answers.set(attempt.index, value);
    attempt.confirming = false;
    render();
  }
  function go(attempt, index) {
    if (index < 0 || index >= attempt.quiz.questions.length) return;
    attempt.index = index;
    if (attempt.state === "done") attempt.state = "review";
    render();
    reveal();
  }
  function askSubmit(attempt) {
    if (attempt.answers.size < attempt.quiz.questions.length) {
      attempt.confirming = true;
      render();
      confirmBox.querySelector("button")?.focus();
      return;
    }
    submit(attempt);
  }
  function submit(attempt) {
    if (attempt.state !== "doing") return;
    attempt.state = "done";
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
    const answers = attempt.quiz.questions
      .map((question, index) => ({ code: question.code, answer: attempt.answers.get(index) }))
      .filter((item) => item.answer !== undefined)
      .map((item) => ({ code: item.code, answer: String(item.answer) }));
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
    const done = (message) => {
      attempt.saved = message;
      if (attempt === active && attempt.state === "done") render();
    };
    if (window.nhMain && typeof window.nhMain.callAjax === "function") {
      window.nhMain.callAjax({ async: true, url: "/quizs-answer/add", data })
        .done(() => done("Đã lưu vào lịch sử làm bài của bạn."))
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

  // The player belongs to one lesson: it shows only on that lesson's "Bài tập" tab and covers that lesson's card.
  function sync() {
    const showing = Boolean(active) && active.lesson.number === lessonNumber;
    host.hidden = !showing;
    root.querySelectorAll("[data-mcr-quiz]").forEach((card) => {
      card.classList.toggle("is-covered", showing && Number(card.dataset.mcrQuiz) === lessonNumber);
    });
    if (note) note.hidden = !showing || active.state === "done";
  }
  function updateStartButtons() {
    root.querySelectorAll("[data-mcr-quiz-start]").forEach((startButton) => {
      const attempt = attempts.get(Number(startButton.dataset.mcrQuizStart));
      if (!attempt) return;
      if (attempt.state === "doing") {
        const left = attempt.deadline ? ` (còn ${clock(Math.max(0, Math.ceil((attempt.deadline - Date.now()) / 1000)))})` : "";
        startButton.textContent = `Tiếp tục làm bài${left}`;
      } else {
        startButton.textContent = "Xem kết quả";
      }
    });
  }

  root.querySelectorAll("[data-mcr-quiz-start]").forEach((startButton) => startButton.addEventListener("click", () => {
    const quiz = quizzes[startButton.dataset.mcrQuizStart];
    if (!quiz) return;
    lessonNumber = Number(startButton.dataset.lesson);
    start(quiz, { number: lessonNumber, title: startButton.dataset.lessonTitle || "", code: startButton.dataset.lessonCode || "" }, false);
  }));
  submitButton.addEventListener("click", () => active && askSubmit(active));
  resultButton.addEventListener("click", () => { if (active) { active.state = "done"; render(); reveal(); } });
  root.addEventListener("mcr:lesson", (event) => {
    lessonNumber = event.detail.number;
    if (active && active.lesson.number !== lessonNumber) {
      // Another lesson: its own quiz attempt (if any) becomes the one shown.
      const card = root.querySelector(`[data-mcr-quiz="${lessonNumber}"] [data-mcr-quiz-start]`);
      const other = card && attempts.get(Number(card.dataset.mcrQuizStart));
      active = other || active;
    }
    sync();
    if (active && !host.hidden) render();
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
      if (option) { event.preventDefault(); choose(active, option[0]); }
    } else if (event.key === "ArrowRight") {
      event.preventDefault();
      go(active, active.index + 1);
    } else if (event.key === "ArrowLeft") {
      event.preventDefault();
      go(active, active.index - 1);
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
