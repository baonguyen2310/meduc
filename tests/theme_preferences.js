/* Run the shipped palette scripts with controlled browser storage, sign-in and HTTP ordering. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const crypto = require('node:crypto').webcrypto;
const files = name => fs.readFileSync(path.join(__dirname, '../templates/app01/assets/meduc-v2/', name), 'utf8');
class CustomEvent extends Event { constructor(type, init = {}) { super(type); this.detail = init.detail; } }
const flush = () => new Promise(resolve => setImmediate(resolve));
function fixture(storage = {}, account = 0, backend = 'light') {
  const values = new Map(Object.entries(storage));
  const localStorage = {getItem:k => values.get(k) ?? null, setItem:(k,v) => values.set(k,String(v))};
  const root = {dataset:{meducThemeUser:String(account), meducThemeSaved:backend}, getAttribute:()=>'fixture-csrf'};
  const window = new EventTarget(); window.crypto = crypto;
  const document = new EventTarget(); document.hidden = false; document.documentElement = root; document.getElementById = ()=>({});
  const requests = [], retries = [];
  const context = {window, document, localStorage, CustomEvent, URLSearchParams, Uint8Array, Date,
    setTimeout:callback => {retries.push(callback);return retries.length;}, clearTimeout:()=>{},
    fetch:(url, options) => new Promise(resolve => requests.push({data:Object.fromEntries(new URLSearchParams(options.body)),
      answer:(theme, customer = 0, status = 200) => resolve({ok:status===200, status, json:async()=>({theme, customer_id:customer, version:20261113})})}))};
  vm.runInNewContext(files('theme-init.js'), context);
  return {window, root, values, requests, retries, boot:()=>vm.runInNewContext(files('theme-usage.js'), context)};
}
(async () => {
  const old = fixture({'meduc-theme':'dark'});
  assert.equal(old.root.dataset.meducTheme, 'light');
  assert.equal(old.values.get('meduc-theme-version'), '20261113');
  old.boot(); assert.equal(old.requests[0].data.legacy_theme, 'dark');
  old.requests[0].answer('light'); await flush();
  old.window.meducTheme.select('dark');
  assert.equal(old.requests[1].data.mode, 'change');
  old.requests[1].answer('dark'); await flush();
  const again = fixture(Object.fromEntries(old.values));
  assert.equal(again.root.dataset.meducTheme, 'dark', 'The reset must run only once.');
  const signedIn = fixture({'meduc-theme':'dark', 'meduc-theme-version':'20261113'}, 71, 'light');
  assert.equal(signedIn.root.dataset.meducTheme, 'light', 'An account wins over a stale browser.');
  const device = fixture({}, 71, 'dark');
  assert.equal(device.root.dataset.meducTheme, 'dark', 'Render the persisted account preference before paint on a new device.');
  const privateBrowser = fixture(); privateBrowser.boot();
  privateBrowser.window.meducTheme.select('dark');
  privateBrowser.window.meducTheme.select('light');
  privateBrowser.requests[0].answer('light'); await flush();
  assert.equal(privateBrowser.requests.length, 2);
  privateBrowser.requests[1].answer('dark'); await flush();
  assert.equal(privateBrowser.root.dataset.meducTheme, 'light', 'A slow earlier response must not flash over the latest click.');
  privateBrowser.requests[2].answer('light'); await flush();
  assert.deepEqual(privateBrowser.requests.map(r=>r.data.theme), ['light','dark','light']);
  assert.notEqual(privateBrowser.requests[1].data.event_id, privateBrowser.requests[2].data.event_id);
  const signInRace = fixture(); signInRace.boot();
  signInRace.window.meducTheme.select('dark');
  signInRace.window.dispatchEvent(new CustomEvent('meduc:authenticated'));
  signInRace.requests[0].answer('dark', 0); await flush();
  assert.equal(signInRace.requests[1].data.mode, 'sync', 'Drop guest changes queued before authentication.');
  signInRace.requests[1].answer('light', 71); await flush();
  assert.equal(signInRace.root.dataset.meducTheme, 'light');
  signInRace.window.meducTheme.select('dark');
  assert.equal(signInRace.requests[2].data.customer_id, '71');
  signInRace.requests[2].answer('dark', 71); await flush();
  const retry = fixture(); retry.boot(); retry.requests[0].answer('light'); await flush();
  retry.window.meducTheme.select('dark');
  retry.requests[1].answer('dark', 0, 503); await flush();
  retry.retries.at(-1)();
  assert.equal(retry.requests[1].data.event_id, retry.requests[2].data.event_id, 'Retries preserve event identity.');
  retry.requests[2].answer('dark'); await flush();
  console.log('PASS: one-time reset, backend precedence, first paint, rapid switches, stale responses, sign-in race, idempotent retry');
})();
