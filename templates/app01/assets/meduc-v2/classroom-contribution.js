/* Course feedback: answer corrections, photographed exams and curriculum suggestions. */
(() => {
  "use strict";
  const root = document.querySelector("[data-mcr]");
  const panel = root?.querySelector("[data-mcr-contribution]");
  const form = panel?.querySelector("[data-mcr-contribution-form]");
  if (!root || !panel) return;
  const trigger = root.querySelector("[data-mcr-contribution-trigger]");
  const closeButton = panel.querySelector("[data-mcr-contribution-close]");
  const studyModal = root.querySelector("[data-mcr-study-modal]");
  let opener = null;
  let previousInert = false;
  let previousAriaHidden = null;
  const updateTrigger = () => trigger?.setAttribute("aria-expanded", String(!panel.hidden));
  function closeContribution({restoreFocus = true} = {}) {
    if (panel.hidden) return;
    panel.hidden = true;
    document.body.classList.remove("mcr-contribution-open");
    if (studyModal) {
      studyModal.inert = previousInert;
      if (previousAriaHidden === null) studyModal.removeAttribute("aria-hidden");
      else studyModal.setAttribute("aria-hidden", previousAriaHidden);
    }
    updateTrigger();
    if (restoreFocus && opener?.isConnected && opener.getClientRects().length) opener.focus({preventScroll:true});
  }
  function openContribution() {
    if (!panel.hidden) return;
    opener = document.activeElement;
    previousInert = studyModal?.inert || false;
    previousAriaHidden = studyModal?.getAttribute("aria-hidden") ?? null;
    panel.hidden = false;
    document.body.classList.add("mcr-contribution-open");
    updateTrigger();
    closeButton?.focus({preventScroll:true});
    if (studyModal) { studyModal.inert = true; studyModal.setAttribute("aria-hidden", "true"); }
    panel.querySelector(".mcr-contribution-body").scrollTop = 0;
  }
  trigger?.addEventListener("click", () => root.dispatchEvent(new CustomEvent("mcr:contribute", {detail: {}})));
  closeButton?.addEventListener("click", () => closeContribution());
  panel.addEventListener("click", (event) => { if (event.target === panel) closeContribution(); });
  root.addEventListener("mcr:modal-close", () => closeContribution({restoreFocus:false}));
  document.addEventListener("keydown", (event) => {
    if (panel.hidden || document.body.classList.contains("ma-auth-open")) return;
    if (event.key === "Escape") { event.preventDefault(); closeContribution(); return; }
    if (event.key !== "Tab") return;
    const controls = [...panel.querySelectorAll('button:not([disabled]),a[href],input:not([disabled]),select:not([disabled]),textarea:not([disabled])')].filter(control => control.getClientRects().length);
    const first = controls[0], last = controls[controls.length - 1];
    if (!first) { event.preventDefault(); panel.focus(); return; }
    if (event.shiftKey && (document.activeElement === first || !panel.contains(document.activeElement))) { event.preventDefault(); last.focus(); }
    else if (!event.shiftKey && (document.activeElement === last || !panel.contains(document.activeElement))) { event.preventDefault(); first.focus(); }
  });

  const lessonField = form?.querySelector("[data-contribution-lesson]");
  const typeField = form?.querySelector("[data-contribution-type]");
  const quizField = form?.querySelector("[data-contribution-quiz]");
  const questionField = form?.querySelector('[name="question_number"]');
  const answerField = form?.querySelector('[name="suggested_answer"]');
  const photoField = form?.querySelector('[name="photos[]"]');
  const status = form?.querySelector("[data-contribution-status]");
  let lesson = 0;

  function showFields() {
    if (!form) return;
    const answer = typeField.value === "answer";
    const exam = typeField.value === "exam";
    form.querySelector("[data-contribution-quiz-field]").hidden = !answer;
    form.querySelector("[data-contribution-question-field]").hidden = !answer;
    form.querySelector("[data-contribution-answer-field]").hidden = !answer;
    form.querySelector("[data-contribution-photo-field]").hidden = !exam;
    quizField.required = answer;
    questionField.required = answer;
    answerField.required = answer;
    photoField.required = exam;
    if (!answer) { questionField.value = ""; answerField.value = ""; }
    if (!exam) photoField.value = "";
  }

  function syncLesson(number) {
    lesson = Number(number) || 0;
    if (!form) return;
    lessonField.value = lesson || "";
    const previous = quizField.value;
    quizField.replaceChildren(new Option("Chọn đề trong bài này", ""));
    root.querySelectorAll(`[data-mcr-quiz="${lesson}"] [data-mcr-quiz-start]`).forEach((button) => {
      const label = button.closest(".mcr-quiz-card")?.querySelector("h3")?.textContent?.trim() || "Bài tập";
      quizField.add(new Option(label, button.dataset.mcrQuizStart));
    });
    if ([...quizField.options].some((option) => option.value === previous)) quizField.value = previous;
  }

  root.addEventListener("mcr:lesson", (event) => syncLesson(event.detail.number));
  root.addEventListener("mcr:contribute", (event) => {
    openContribution();
    if (form) {
      if (event.detail.type) typeField.value = event.detail.type;
      showFields();
      if (event.detail.quizId) quizField.value = String(event.detail.quizId);
      if (event.detail.questionNumber) questionField.value = String(event.detail.questionNumber);
      status.textContent = "";
    }

    if (form) form.querySelector("textarea")?.focus({ preventScroll: true });
  });

  if (!form) return;
  typeField.addEventListener("change", showFields);
  showFields();
  syncLesson(Number(new URLSearchParams(location.search).get("bai")) || 0);

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (!form.reportValidity()) return;
    const button = form.querySelector('[type="submit"]');
    const files = [...photoField.files];
    if (files.length > 5 || files.some((file) => file.size > 8 * 1024 * 1024)) {
      status.textContent = "Chỉ nhận tối đa 5 ảnh, mỗi ảnh dưới 8 MB.";
      return;
    }
    const payload = new FormData(form);
    if (typeField.value !== "answer" && !quizField.value) payload.delete("quiz_id");
    if (typeField.value !== "exam") payload.delete("photos[]");
    button.disabled = true;
    status.textContent = "Đang gửi đóng góp…";
    try {
      const response = await fetch("/khoa-hoc/dong-gop", {
        method: "POST", body: payload, credentials: "same-origin",
        headers: { "X-CSRF-Token": document.documentElement.getAttribute("csrf-token") || "", "X-Requested-With": "XMLHttpRequest", Accept: "application/json" }
      });
      const body = await response.json();
      if (!response.ok || body.code !== "success") throw new Error(body.message || "Chưa gửi được đóng góp.");
      const currentLesson = lesson;
      form.reset();
      syncLesson(currentLesson);
      showFields();
      status.textContent = body.message;
      status.classList.add("is-success");
    } catch (error) {
      status.classList.remove("is-success");
      status.textContent = error.message || "Chưa gửi được đóng góp. Vui lòng thử lại.";
    } finally {
      button.disabled = false;
    }
  });
})();
