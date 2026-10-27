/* Self-assessment after submission, shared by result review, history and the wrong-answer notebook. */
(() => {
  'use strict';
  const states = new WeakMap();
  const levels = [['confident', 'Chắc chắn'], ['unsure', 'Phân vân'], ['guess', 'Đoán']];
  const getId = attempt => Number(attempt.savedRecordId || attempt.record?.id) || 0;
  const element = (tag, className, text) => {
    const node = document.createElement(tag);
    node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  };
  const endpoint = state => `/khoa-hoc/bai-tap/${state.productId}/${state.attempt.quiz.id}/tu-tin/${getId(state.attempt)}`;
  function paintWidget(state, widget) {
    const {index, node, status, retry, choices, question} = widget;
    const pending = state.busy.has(index);
    const available = getId(state.attempt) && state.loaded && !state.loadError && question.key;
    choices.forEach((choice, position) => {
      choice.disabled = !available || pending;
      choice.setAttribute('aria-pressed', String(state.ratings.get(index) === levels[position][0]));
    });
    node.dataset.confidenceQuestion = String(index);
    status.textContent = state.errors.get(index) || state.loadError || (!getId(state.attempt)
      ? (state.attempt.saved ? 'Chưa lưu được bài làm.' : 'Đang lưu bài làm…')
      : pending ? 'Đang lưu…' : !state.loaded ? 'Đang tải…' : !question.key ? 'Tải lại trang để đánh giá câu này.' : state.ratings.has(index) ? 'Đã lưu' : '');
    status.classList.toggle('is-error', Boolean(state.errors.get(index) || state.loadError));
    retry.hidden = !state.loadError;
  }
  function paint(state) { state.widgets.forEach(widget => paintWidget(state, widget)); }
  async function load(state) {
    if (!getId(state.attempt) || state.loading || state.loaded) return;
    state.loading = true; state.loadError = ''; paint(state);
    try {
      const response = await fetch(endpoint(state), {credentials:'same-origin', headers:{Accept:'application/json'}});
      const body = await response.json().catch(() => null);
      if (!response.ok || body?.code !== 'success') throw new Error(body?.message || 'Chưa tải được mức độ tự tin.');
      state.ratings = new Map(Object.entries(body.data.ratings || {}).map(([index, level]) => [Number(index), level]));
      state.loaded = true;
    } catch (error) {
      state.loadError = error.message || 'Chưa tải được mức độ tự tin.';
    } finally { state.loading = false; paint(state); }
  }
  async function save(state, widget, level) {
    const {index, question} = widget;
    if (state.busy.has(index) || !state.loaded || !getId(state.attempt)) return;
    if (state.ratings.get(index) === level && !state.errors.has(index)) return;
    state.busy.add(index); state.errors.delete(index); paint(state);
    try {
      const token = document.documentElement.getAttribute('csrf-token') || '';
      const response = await fetch(endpoint(state), {method:'POST',credentials:'same-origin',headers:{
        'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8','Accept':'application/json','X-CSRF-Token':token,'X-Requested-With':'XMLHttpRequest',
      },body:new URLSearchParams({question_index:String(index),question_key:question.key,confidence:level}).toString()});
      const body = await response.json().catch(() => null);
      if (!response.ok || body?.code !== 'success') throw new Error(body?.message || 'Chưa lưu được. Bạn thử lại nhé.');
      state.ratings.set(index, body.data.confidence);
    } catch (error) { state.errors.set(index, error.message || 'Chưa lưu được. Bạn thử lại nhé.'); }
    finally { state.busy.delete(index); paint(state); }
  }
  window.MeducQuizConfidence = {
    create({attempt, productId, index, question}) {
      let state = states.get(attempt);
      if (!state) {
        state = {attempt,productId,widgets:new Set(),ratings:new Map(),busy:new Set(),errors:new Map(),loaded:false,loading:false,loadError:''};
        states.set(attempt,state);
      }
      // Drop detached widgets from previous renders, keeping the ones still being built this turn.
      for (const old of state.widgets) if (old.mounted && !old.node.isConnected) state.widgets.delete(old);
      const node = element('div','mcq-confidence');
      const label = element('span','mcq-confidence-label','Mức độ tự tin:');
      const group = element('div','mcq-confidence-choices');
      group.setAttribute('role','group');
      group.setAttribute('aria-label',`Mức độ tự tin của câu ${index+1}`);
      const status = element('span','mcq-confidence-status'); status.setAttribute('role','status');
      const retry = element('button','mcq-confidence-retry','Thử lại'); retry.type='button'; retry.hidden=true;
      const widget = {node,index,question,status,retry,choices:[],mounted:false};
      levels.forEach(([value,text]) => {
        const choice = element('button','mcq-confidence-choice',text); choice.type='button'; choice.setAttribute('aria-pressed','false');
        choice.addEventListener('click',()=>save(state,widget,value)); widget.choices.push(choice); group.append(choice);
      });
      retry.addEventListener('click',()=>load(state));
      node.append(label,group,status,retry); state.widgets.add(widget); paintWidget(state,widget);
      queueMicrotask(()=>{ widget.mounted = node.isConnected; });
      void load(state);
      return node;
    },
    recordSaved(attempt) {
      const state = states.get(attempt);
      if (!state) return;
      paint(state); void load(state);
    },
  };
})();
