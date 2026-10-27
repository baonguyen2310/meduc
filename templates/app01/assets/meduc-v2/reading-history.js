/* Three recent items per library. Account ownership is always established by the server. */
(() => {
  'use strict';
  if (window.meducReading) return;
  const item = document.querySelector('[data-reading-item]');
  const box = document.querySelector('[data-reading-history]');
  const kind = item?.dataset.readingItem || box?.dataset.readingHistory;
  if (!['blog','document'].includes(kind)) return;
  const id = Number(item?.dataset.readingId) || 0;
  const key = `meduc-reading:guest:v1:${kind}`;
  let customer = null, known = false, entries = [], pending = null, timer, generation = 0, lastCheck = 0;
  let writing = Promise.resolve();
  let snapshot = () => {};
  const resumeRequested = new URLSearchParams(location.search).get('tiep-tuc') === '1';
  function local() {
    try {
      const data = JSON.parse(localStorage.getItem(key) || '[]');
      return Array.isArray(data) ? data.filter(e => Number.isInteger(e.article_id) && e.article_id > 0).filter((e,i,a)=>a.findIndex(v=>v.article_id===e.article_id)===i).slice(0,3) : [];
    } catch (_) { return []; }
  }
  function store(data) { try { localStorage.setItem(key,JSON.stringify(data.slice(0,3))); } catch (_) {} }
  function ownMetadata() {
    return {article_id:id,kind,title:item.dataset.readingTitle || '',topic:item.dataset.readingTopic || '',image:item.dataset.readingImage || '',url:location.pathname};
  }
  function safeURL(value,image = false) {
    try {
      const u = new URL(value,location.origin);
      if (!['https:','http:'].includes(u.protocol) || (!image && u.origin !== location.origin)) return '';
      return u.href;
    } catch (_) { return ''; }
  }
  function node(tag,className,text) { const n=document.createElement(tag);if(className)n.className=className;if(text)n.textContent=text;return n; }
  function render() {
    if (!box || !known) return;
    const grid=box.querySelector('[data-reading-cards]');
    grid.replaceChildren();
    entries.slice(0,3).forEach(entry=>{
      const href=safeURL(entry.url);if(!href)return;
      const url=new URL(href);url.searchParams.set('tiep-tuc','1');url.hash=kind==='blog'?'blog-prose':'document-reader';
      const card=node('article','mrh-card');
      const cover=node('a','mrh-cover');cover.href=url.href;cover.setAttribute('aria-label',`Đọc tiếp ${entry.title}`);
      const image=safeURL(entry.image,true);
      if(image){const img=node('img');img.src=image;img.alt='';img.loading='lazy';img.decoding='async';img.addEventListener('error',()=>img.remove(),{once:true});cover.append(img);}
      cover.append(node('span','mrh-cover-label',kind==='blog'?'MEDUC / JOURNAL':'MEDUC / TÀI LIỆU'));
      const copy=node('div','mrh-copy');copy.append(node('p','mrh-topic',entry.topic));
      const title=node('h3');const link=node('a','',entry.title);link.href=url.href;title.append(link);copy.append(title);
      let hint='Đọc tiếp';const p=entry.progress||{};
      if(kind==='blog' && Number(p.ratio)>0)hint=`Đã đọc ${Math.min(100,Math.round(p.ratio*100))}% · Đọc tiếp`;
      if(kind==='document' && Number(p.page)>0)hint=`${Number(p.file_index)>0?`Tệp ${Number(p.file_index)+1} · `:''}Trang ${p.page} · Đọc tiếp`;
      const go=node('a','mrh-continue',hint);go.href=url.href;go.append(node('span','','→'));copy.append(go);card.append(cover,copy);grid.append(card);
    });
    box.querySelector('[data-reading-empty]').hidden=grid.children.length>0;
    box.hidden=false;
  }
  async function post(action,progress,owner=customer,keepalive=false) {
    const body=new URLSearchParams({kind,article_id:String(id),expected_customer_id:String(owner),action});
    if(progress)body.set('progress',JSON.stringify(progress));
    const response=await fetch('/reading-history/save',{method:'POST',body,credentials:'same-origin',keepalive,headers:{'X-CSRF-Token':document.documentElement.getAttribute('csrf-token') || '','X-Requested-With':'XMLHttpRequest'}});
    if(response.status===409 || response.status===401){known=false;return false;}
    if(!response.ok) return false;
    return true;
  }
  async function boot(visit=false) {
    const run=++generation, previous=customer;known=false;
    if(box)box.hidden=true;
    if(item)delete item.dataset.readingReady;
    const browser=local();
    const ids=(id?[{article_id:id},...browser]:browser).filter((e,i,a)=>a.findIndex(v=>v.article_id===e.article_id)===i).slice(0,3).map(e=>e.article_id);
    try {
      const response=await fetch(`/reading-history?kind=${kind}&ids=${ids.join(',')}`,{credentials:'same-origin',cache:'no-store',headers:{'X-Requested-With':'XMLHttpRequest'}});
      if(!response.ok)throw new Error('history');
      const result=await response.json();if(run!==generation)return;
      customer=Number(result.data.customer_id)||0;
      if(previous!==null && previous!==customer){pending=null;clearTimeout(timer);}
      entries=(result.data.items||[]).slice(0,3);
      if(!customer)entries=entries.map(e=>({...e,progress:browser.find(v=>v.article_id===e.article_id)?.progress || {},visited_at:browser.find(v=>v.article_id===e.article_id)?.visited_at || 0})).filter(e=>browser.some(v=>v.article_id===e.article_id));
      if(id && (visit || (previous!==null && previous!==customer))) {
        const old=entries.find(e=>e.article_id===id);
        const visited=customer?await post('visit',null,customer):result.data.items.some(e=>e.article_id===id);
        if(customer&&!visited)throw new Error('visit');
        if(visited) {
          entries=[{...ownMetadata(),progress:old?.progress||{},visited_at:Date.now()},...entries.filter(e=>e.article_id!==id)].slice(0,3);
          if(!customer)store(entries);
        }
      }
      if(run!==generation)return;
      known=true;lastCheck=Date.now();if(item)item.dataset.readingReady='true';render();
      return entries.find(e=>e.article_id===id)?.progress || {};
    } catch (_) { if(run===generation)known=false;return {}; }
  }
  function progress() { return entries.find(e=>e.article_id===id)?.progress || {}; }
  function set(position) {
    if(!id || !known)return;
    const entry=entries.find(e=>e.article_id===id);if(!entry)return;
    entry.progress=position;
    if(!customer) {
      const browser=local(), target=browser.find(e=>e.article_id===id);
      if(target){target.progress=position;store(browser);}
    } else {
      pending={position,owner:customer};
      if(!timer)timer=setTimeout(()=>{timer=null;flush();},4000);
    }
  }
  function flush(keepalive=false) {
    if(!pending)return;
    clearTimeout(timer);timer=null;
    const save=pending;pending=null;
    if(keepalive){void post('progress',save.position,save.owner,true).catch(()=>{});return;}
    writing=writing.catch(()=>{}).then(()=>post('progress',save.position,save.owner)).catch(()=>{});
  }
  const ready=boot(true);
  window.meducReading={ready,progress,set,flush,resumeRequested};
  window.addEventListener('meduc:authenticated',()=>void boot(true));
  window.addEventListener('focus',()=>{if(Date.now()-lastCheck>15000)void boot(false);});
  window.addEventListener('pageshow',e=>{if(e.persisted)void boot(false);});
  window.addEventListener('storage',e=>{if(e.key===key && box && customer===0)void boot(false);});
  document.addEventListener('visibilitychange',()=>{if(document.hidden){snapshot();flush(true);}});
  window.addEventListener('pagehide',()=>{snapshot();flush(true);});

  if(kind!=='blog' || !id)return;
  const prose=item.querySelector('#blog-prose');if(!prose)return;
  const anchors=[...prose.querySelectorAll('h2,h3,h4,p,li,figure,table,blockquote')];
  const text=el=>(el?.textContent||'').replace(/\s+/g,' ').trim().slice(0,160);
  const offset=()=> (parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--mhi-header-h'))||66)+25;
  let active=false, changed=false, captureTimer, restoring=false;
  const interact=()=>{changed=true;restoring=false;};
  ['wheel','touchstart','pointerdown','keydown'].forEach(name=>window.addEventListener(name,interact,{passive:true}));
  function capture(force=false) {
    if(!active || !changed || restoring || (document.hidden && !force))return;
    const rect=prose.getBoundingClientRect();if(rect.top>innerHeight || rect.bottom<offset())return;
    let index=0;anchors.forEach((a,i)=>{if(a.getBoundingClientRect().top<=offset()+8)index=i;});
    const anchor=anchors[index] || prose;
    set({ratio:Math.max(0,Math.min(1,(offset()-rect.top)/Math.max(1,rect.height-innerHeight+offset()))),anchor_index:index,anchor_text:text(anchor),offset:Math.max(0,Math.round(offset()-anchor.getBoundingClientRect().top))});
  }
  window.addEventListener('scroll',()=>{clearTimeout(captureTimer);captureTimer=setTimeout(capture,650);},{passive:true});
  snapshot = () => capture(true);
  ready.then(async saved=>{
    if(!resumeRequested || !saved || !Object.keys(saved).length){active=true;return;}
    await Promise.race([document.fonts?.ready || Promise.resolve(),new Promise(resolve=>setTimeout(resolve,1500))]);
    await new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve)));
    if(changed){active=true;return;}
    const index=Number.isInteger(saved.anchor_index)?saved.anchor_index:0;
    let anchor=anchors[index];
    if(saved.anchor_text && text(anchor)!==saved.anchor_text)anchor=anchors.find(a=>text(a)===saved.anchor_text);
    function restore() {
      const top=anchor?anchor.getBoundingClientRect().top+scrollY-offset()+Math.min(Number(saved.offset)||0,Math.max(0,anchor.getBoundingClientRect().height-10)):prose.getBoundingClientRect().top+scrollY+Math.max(0,Math.min(1,Number(saved.ratio)||0))*Math.max(1,prose.offsetHeight-innerHeight+offset())-offset();
      scrollTo({top:Math.max(0,top),behavior:'instant'});
    }
    restoring=true;restore();active=true;
    const observer=new ResizeObserver(()=>{if(restoring)restore();});observer.observe(prose);
    setTimeout(()=>{restoring=false;observer.disconnect();},3000);
  });
})();
