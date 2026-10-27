/* The three most recently opened courses, kept separately for each public catalogue. */
(() => {
  'use strict';
  const detail=document.querySelector('[data-mcr-product]');
  const catalog=document.getElementById('course-catalog');
  if(!detail&&!catalog)return;
  const kind=(detail?detail.dataset.mcrExamPrep==='1':!!catalog.querySelector('.mcl-catalog-hero--exam'))?'exam_course':'course';
  const id=Number(detail?.dataset.mcrProduct)||0;
  const key=`meduc-reading:guest:v1:${kind}`;
  let owner=null,generation=0,lastCheck=0,box;
  const node=(tag,cls,text)=>{const n=document.createElement(tag);if(cls)n.className=cls;if(text)n.textContent=text;return n;};
  function local(){
    try{const rows=JSON.parse(localStorage.getItem(key)||'[]');return Array.isArray(rows)?rows.filter(r=>Number.isInteger(r.article_id)&&r.article_id>0).filter((r,i,a)=>a.findIndex(x=>x.article_id===r.article_id)===i).slice(0,3):[];}
    catch(_){return [];}
  }
  function safeURL(value,image=false){
    if(!value)return '';
    try{const u=new URL(value,location.origin);return ['https:','http:'].includes(u.protocol)&&(image||u.origin===location.origin)?u.href:'';}catch(_){return '';}
  }
  const money=value=>`${Number(value).toLocaleString('vi-VN')}đ`;
  if(catalog){
    box=node('section','mch');box.hidden=true;box.setAttribute('aria-labelledby','recent-courses-title');box.dataset.courseHistory=kind;
    const heading=node('div','mch-heading'),copy=node('div');
    copy.append(node('p','mch-eyebrow','TIẾP TỤC KHÁM PHÁ'));
    const title=node('h2','mch-title',kind==='course'?'KHOÁ HỌC VỪA XEM.':'KHOÁ LUYỆN THI VỪA XEM.');title.id='recent-courses-title';copy.append(title);
    heading.append(copy,node('p','mch-description','Tiếp tục khám phá những khoá bạn vừa quan tâm.'));
    box.append(heading,node('div','mch-grid'));
    const listing=catalog.querySelector('#course-listing');if(listing)listing.before(box);else catalog.append(box);
  }
  function render(items){
    if(!box)return;
    const grid=box.querySelector('.mch-grid');grid.replaceChildren();
    items.slice(0,3).forEach(course=>{
      const url=safeURL(course.url);if(!url)return;
      const card=node('article','mch-card');card.dataset.courseHistoryId=String(course.article_id);
      const cover=node('a','mch-cover');cover.href=url;cover.setAttribute('aria-label',`Xem ${course.title}`);
      const placeholder=node('span','mch-cover-placeholder');placeholder.setAttribute('aria-hidden','true');placeholder.append(node('small','',kind==='course'?'HỌC TỪ CƠ BẢN ĐẾN CHUYÊN SÂU':'LUYỆN THI THEO MÔN'),node('strong','',course.title));cover.append(placeholder);
      const image=safeURL(course.image,true);
      if(image){const img=node('img');img.src=image;img.alt='';img.loading='lazy';img.decoding='async';img.addEventListener('error',()=>img.remove(),{once:true});cover.append(img);}
      cover.append(node('span','mch-cover-label',kind==='course'?'MEDUC / KHOÁ HỌC':'MEDUC / LUYỆN THI'));
      const body=node('div','mch-copy'),title=node('h3'),link=node('a','',course.title);link.href=url;title.append(link);body.append(title);
      const meta=node('p','mch-meta'),facts=[];if(course.chapters>0)facts.push(`${course.chapters} chương`);if(course.lessons>0)facts.push(`${course.lessons} bài học`);meta.textContent=facts.join(' · ');if(facts.length)body.append(meta);
      if(course.price>0){const price=node('p','mch-price');price.append(node('strong','',money(course.price)));if(course.old_price>course.price)price.append(node('del','',money(course.old_price)));body.append(price);}
      const go=node('a','mch-action',course.preview_label||'Xem lại khoá học');go.href=safeURL(course.preview_url)||url;go.append(node('span','','→'));body.append(go);card.append(cover,body);grid.append(card);
    });
    box.hidden=grid.children.length===0;
  }
  async function boot(visit=false){
    const run=++generation,previous=owner;if(box)box.hidden=true;
    const browser=local();
    const ids=(id?[{article_id:id},...browser]:browser).filter((r,i,a)=>a.findIndex(x=>x.article_id===r.article_id)===i).slice(0,3).map(r=>r.article_id);
    try{
      const res=await fetch(`/reading-history?kind=${kind}&ids=${ids.join(',')}`,{credentials:'same-origin',cache:'no-store',headers:{'X-Requested-With':'XMLHttpRequest'}});
      if(!res.ok)throw new Error('history');
      const result=await res.json();if(run!==generation)return;
      owner=Number(result.data.customer_id)||0;const items=result.data.items||[];
      if(id&&(visit||(previous!==null&&previous!==owner))){
        if(owner){
          const body=new URLSearchParams({kind,article_id:String(id),expected_customer_id:String(owner),action:'visit'});
          const saved=await fetch('/reading-history/save',{method:'POST',body,credentials:'same-origin',headers:{'X-CSRF-Token':document.documentElement.getAttribute('csrf-token')||'','X-Requested-With':'XMLHttpRequest'}});
          if(!saved.ok)throw new Error('visit');
        }else if(items.some(r=>r.article_id===id)){
          try{localStorage.setItem(key,JSON.stringify([{article_id:id,visited_at:Date.now()},...local().filter(r=>r.article_id!==id)].slice(0,3)));}catch(_){}
        }
      }
      if(run!==generation)return;
      lastCheck=Date.now();if(detail)detail.dataset.courseHistoryReady='true';render(items);
    }catch(_){if(run===generation&&box)box.hidden=true;}
  }
  void boot(true);
  window.addEventListener('meduc:authenticated',()=>void boot(true));
  window.addEventListener('focus',()=>{if(Date.now()-lastCheck>15000)void boot();});
  window.addEventListener('pageshow',event=>{if(event.persisted)void boot();});
  window.addEventListener('storage',event=>{if(event.key===key&&box&&owner===0)void boot();});
})();
