/* Lazy PDF.js reader: a bounded canvas per page; original files remain available in the toolbar. */
(() => {
  'use strict';
  const assets='/templates/app01/assets/meduc-v2/pdfjs/';
  let library;
  window.meducPdf={async open(container,options){
    const pdfjs=await (library ||= import(assets+'pdf.min.mjs'));
    if(options.signal?.aborted)throw new DOMException('Đã đổi tệp.','AbortError');
    pdfjs.GlobalWorkerOptions.workerSrc=assets+'pdf.worker.min.mjs';
    let destroyed=false,task,renderTask,pdf,page=1,zoom=1,sequence=0;
    const el=(tag,className,text)=>{const n=document.createElement(tag);if(className)n.className=className;if(text)n.textContent=text;return n;};
    const button=(text,label,className)=>{const n=el('button',className,text);n.type='button';n.setAttribute('aria-label',label);return n;};
    const root=el('div','mdp');
    const toolbar=el('div','mdp-toolbar');toolbar.setAttribute('aria-label','Điều khiển trang PDF');
    const previous=button('←','Trang PDF trước','mdp-previous');
    const next=button('→','Trang PDF tiếp theo','mdp-next');
    const label=el('label','mdp-page-label','Trang '),input=el('input');input.type='number';input.min='1';input.value='1';input.setAttribute('aria-label','Trang PDF');
    const total=el('span','','/ …');label.append(input,total);
    const smaller=button('−','Thu nhỏ PDF','mdp-zoom-out'),larger=button('+','Phóng to PDF','mdp-zoom-in');
    toolbar.append(previous,label,next,smaller,larger);
    const paper=el('div','mdp-paper'),canvas=el('canvas');canvas.setAttribute('role','img');paper.append(canvas);
    const footer=el('div','mdp-footer'),back=button('← Trang trước','Trang PDF trước ở cuối trang','mdp-bottom-previous'),forward=button('Trang tiếp theo →','Trang PDF tiếp theo ở cuối trang','mdp-bottom-next');footer.append(back,forward);
    root.append(toolbar,paper,footer);container.replaceChildren(root);
    const controls=[previous,next,smaller,larger,input,back,forward];controls.forEach(n=>n.disabled=true);
    function controlsReady(busy=false){previous.disabled=back.disabled=busy||page<=1;next.disabled=forward.disabled=busy||page>=pdf.numPages;input.disabled=busy;smaller.disabled=busy||zoom<=.75;larger.disabled=busy||zoom>=2;}
    async function render(number,scroll=false){
      if(!pdf||destroyed)return;
      const run=++sequence;page=Math.max(1,Math.min(pdf.numPages,Math.trunc(number)||1));input.value=String(page);controlsReady(true);
      if(renderTask){renderTask.cancel();try{await renderTask.promise;}catch(_){} }
      try{
        const sheet=await pdf.getPage(page);if(destroyed||run!==sequence)return;
        const natural=sheet.getViewport({scale:1});
        const width=Math.max(240,container.clientWidth-32);
        const viewport=sheet.getViewport({scale:width/natural.width*zoom});
        const dpr=Math.min(devicePixelRatio||1,2,2400/viewport.width);
        canvas.width=Math.floor(viewport.width*dpr);canvas.height=Math.floor(viewport.height*dpr);canvas.style.width=`${viewport.width}px`;canvas.style.height=`${viewport.height}px`;
        canvas.setAttribute('aria-label',`Trang ${page} / ${pdf.numPages} · ${options.name}`);
        renderTask=sheet.render({canvasContext:canvas.getContext('2d'),viewport,transform:dpr===1?null:[dpr,0,0,dpr,0,0]});await renderTask.promise;
        if(destroyed||run!==sequence)return;
        controlsReady();options.onPage(page,pdf.numPages);
        if(scroll)root.scrollIntoView({block:'start',behavior:'instant'});
      }catch(error){if(!destroyed&&error.name!=='RenderingCancelledException')options.onError(error);}
    }
    previous.addEventListener('click',()=>void render(page-1));next.addEventListener('click',()=>void render(page+1));
    back.addEventListener('click',()=>void render(page-1,true));forward.addEventListener('click',()=>void render(page+1,true));
    input.addEventListener('change',()=>void render(Number(input.value)));
    input.addEventListener('keydown',event=>{if(event.key==='Enter'){event.preventDefault();void render(Number(input.value));}});
    smaller.addEventListener('click',()=>{zoom=Math.max(.75,zoom-.25);void render(page);});larger.addEventListener('click',()=>{zoom=Math.min(2,zoom+.25);void render(page);});
    task=pdfjs.getDocument({url:`/reading-history/pdf/${options.articleId}/${options.fileIndex}`,disableAutoFetch:true,disableStream:true,rangeChunkSize:262144,isEvalSupported:false,cMapUrl:assets+'cmaps/',cMapPacked:true,standardFontDataUrl:assets+'standard_fonts/',wasmUrl:assets+'wasm/',iccUrl:assets+'iccs/'});
    options.signal?.addEventListener('abort',()=>{destroyed=true;sequence++;renderTask?.cancel();void task.destroy();},{once:true});
    task.onPassword=()=>{options.onError(new Error('Tệp yêu cầu mật khẩu.'));void task.destroy();};
    try{pdf=await task.promise;total.textContent=`/ ${pdf.numPages}`;input.max=String(pdf.numPages);await render(options.page||1,true);}
    catch(error){if(!destroyed){void task.destroy();throw error;}}
    if(destroyed)throw new DOMException('Đã đổi tệp.','AbortError');
    let lastWidth=container.clientWidth,resizeTimer;
    const resize=new ResizeObserver(()=>{if(container.clientWidth===lastWidth)return;lastWidth=container.clientWidth;clearTimeout(resizeTimer);resizeTimer=setTimeout(()=>void render(page),180);});resize.observe(container);
    return {destroy(){destroyed=true;sequence++;clearTimeout(resizeTimer);resize.disconnect();renderTask?.cancel();void task.destroy();},getPage(){return page;}};
  }};
})();
