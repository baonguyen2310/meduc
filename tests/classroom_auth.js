/* Run the actual classroom auth coordinator with controlled HTTP response ordering. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const source = fs.readFileSync(path.join(__dirname, '../templates/app01/assets/meduc-v2/classroom.js'), 'utf8');
const coordinator = source.slice(source.indexOf('  // Refresh identity after popup'), source.indexOf('  // Tabs\n'));
assert.ok(coordinator.includes('root.mcrStudyAccess'), 'Classroom auth coordinator not found');
const flush = () => new Promise(resolve => setImmediate(resolve));
function fixture() {
  const root = new EventTarget();
  root.dataset = {mcrProduct: '436', mcrMember: '0'};
  const window = new EventTarget();
  const modal = {style: {display: 'none'}};
  const requests = [];
  const state = {opened: 0, resumed: 0};
  window.meducAuth = {open() {state.opened++; modal.style.display = 'block';}};
  const context = {
    root, window, licensed: false, lessons: [], $$: () => [], CustomEvent,
    document: {createElement: () => ({setAttribute() {}}), getElementById: () => modal},
    lessonView: {querySelector: () => ({after() {}})},
    fetch: () => new Promise(resolve => requests.push(data => resolve({ok: true, json: async () => ({code: 'success', data})}))),
  };
  vm.runInNewContext(coordinator, context);
  return {
    root, window, modal, requests, state,
    start: () => root.mcrStudyAccess.request({kind: 'quiz', trigger: {}, valid: () => true, resume: () => state.resumed++}),
  };
}
const guest = {member_id: 0, licensed: false};
const member = {member_id: 352, member_code: 'TEST', licensed: false};
(async () => {
  for (const staleFirst of [false, true]) {
    const f = fixture();
    const start = f.start();
    f.window.dispatchEvent(new CustomEvent('meduc:authenticated'));
    await flush();
    assert.equal(f.requests.length, 2, 'Authentication reused an access request sent before sign-in');
    if (staleFirst) {f.requests[0](guest); await flush(); f.requests[1](member);}
    else {f.requests[1](member); await flush(); f.requests[0](guest);}
    await start;
    await flush();
    assert.equal(f.state.opened, 0, 'A stale guest response reopened login after authentication');
    assert.equal(f.root.dataset.mcrMember, '352', 'A stale response cleared the signed-in member');
    assert.equal(f.state.resumed, 1, 'Quiz did not resume exactly once');
  }
  const guestFlow = fixture();
  const start = guestFlow.start();
  guestFlow.requests[0](guest);
  await start;
  assert.equal(guestFlow.state.opened, 1, 'Guests must still sign in');
  guestFlow.window.dispatchEvent(new CustomEvent('meduc:authenticated'));
  guestFlow.requests[1](member);
  await flush();
  assert.equal(guestFlow.state.resumed, 0, 'Quiz started before the login modal closed');
  guestFlow.modal.style.display = 'none';
  guestFlow.window.dispatchEvent(new CustomEvent('meduc:auth-closed', {detail: {authenticated: true}}));
  assert.equal(guestFlow.state.resumed, 1, 'Quiz did not resume after popup sign-in');
  const loggedIn = fixture();
  const run = loggedIn.start();
  loggedIn.requests[0](member);
  await run;
  assert.equal(loggedIn.state.opened, 0, 'Signed-in member was asked to sign in');
  assert.equal(loggedIn.state.resumed, 1);
  const closed = fixture();
  const closingRequest = closed.start();
  closed.root.dispatchEvent(new CustomEvent('mcr:modal-close'));
  closed.requests[0](member);
  await closingRequest;
  assert.equal(closed.state.resumed, 0, 'A late access response resumed study after the lesson dialog closed');
  assert.equal(closed.state.opened, 0, 'A closed lesson dialog reopened authentication');
  console.log('Classroom authentication: response races, signed-in access, guest gate and popup resume passed.');
})().catch(error => {console.error(error.message); process.exitCode = 1;});
