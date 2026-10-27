/* Continuous PDF.js viewer: pages render near the viewport and scrolling updates reading history. */
(() => {
  'use strict';
  const assets='/templates/app01/assets/meduc-v2/pdfjs/';
  let library;
  async function libraries(){
    const pdfjs=await import(assets+'pdf.min.mjs');
    globalThis.pdfjsLib=pdfjs;
    const components=await import(assets+'pdf_viewer.mjs');
    pdfjs.GlobalWorkerOptions.workerSrc=assets+'pdf.worker.min.mjs';
    return {pdfjs,components};
  }
  window.meducPdf={async open(container,options){
    const {pdfjs,components}=await (library ||= libraries());
    if(options.signal?.aborted)throw new DOMException('Đã đổi tệp.','AbortError');
    const life=new AbortController();
    let destroyed=false,task,pdf,viewer,resize,ready=false,page=1,zoom=1,fitScale=1,resizeTimer,initTimer;
    const el=(tag,cls,text)=>{const n=document.createElement(tag);if(cls)n.className=cls;if(text)n.textContent=text;return n;};
    const button=(text,label)=>{const n=el('button','',text);n.type='button';n.setAttribute('aria-label',label);return n;};
    const root=el('div','mdp'),toolbar=el('div','mdp-toolbar');toolbar.setAttribute('aria-label','Điều khiển PDF');
    const previous=button('←','Trang PDF trước'),next=button('→','Trang PDF tiếp theo');
    const label=el('label','mdp-page-label','Trang '),input=el('input');input.type='number';input.min='1';input.value='1';input.setAttribute('aria-label','Trang PDF');
    const total=el('span','','/ …');label.append(input,total);
    const smaller=button('−','Thu nhỏ PDF'),larger=button('+','Phóng to PDF');
    toolbar.append(previous,label,next,smaller,larger,el('span','mdp-scroll-hint','Cuộn để đọc liên tục'));
    const area=el('div','mdp-view-area'),scroll=el('div','mdp-scroll'),pages=el('div','pdfViewer');
    scroll.setAttribute('tabindex','0');scroll.setAttribute('role','region');scroll.setAttribute('aria-label','Các trang PDF · Cuộn để đọc');scroll.append(pages);area.append(scroll);root.append(toolbar,area);
    container.classList.add('mdp-host');container.replaceChildren(root);
    const controls=[previous,next,input,smaller,larger];controls.forEach(n=>n.disabled=true);
    function update(){
      if(!ready||destroyed)return;
      page=viewer.currentPageNumber;input.value=String(page);
      previous.disabled=page<=1;next.disabled=page>=pdf.numPages;input.disabled=false;smaller.disabled=zoom<=.75;larger.disabled=zoom>=2;
      root.dataset.currentPage=String(page);options.onPage(page,pdf.numPages);
    }
    function jump(number){if(ready&&!destroyed)viewer.currentPageNumber=Math.max(1,Math.min(pdf.numPages,Math.trunc(number)||1));}
    function fit(){
      if(!ready||destroyed||!scroll.clientWidth)return;
      const keep=viewer.currentPageNumber;viewer.currentScaleValue='page-width';fitScale=viewer.currentScale;
      if(zoom!==1)viewer.currentScale=fitScale*zoom;
      viewer.currentPageNumber=keep;
    }
    function setZoom(value){if(!ready)return;zoom=Math.max(.75,Math.min(2,value));viewer.currentScale=fitScale*zoom;update();}
    previous.addEventListener('click',()=>jump(page-1));next.addEventListener('click',()=>jump(page+1));
    input.addEventListener('change',()=>jump(Number(input.value)));input.addEventListener('keydown',event=>{if(event.key==='Enter'){event.preventDefault();jump(Number(input.value));}});
    smaller.addEventListener('click',()=>setZoom(zoom-.25));larger.addEventListener('click',()=>setZoom(zoom+.25));
    const eventBus=new components.EventBus();
    function destroy(){
      if(destroyed)return;destroyed=true;clearTimeout(initTimer);clearTimeout(resizeTimer);resize?.disconnect();life.abort();viewer?.setDocument(null);void task?.destroy();
    }
    options.signal?.addEventListener('abort',destroy,{once:true,signal:life.signal});
    viewer=new components.PDFViewer({container:scroll,viewer:pages,eventBus,abortSignal:life.signal,
      textLayerMode:0,annotationMode:0,annotationEditorMode:-1,enableAutoLinking:false,
      removePageBorders:true,maxCanvasPixels:3000000,maxCanvasDim:2400,enableDetailCanvas:false});
    eventBus.on('pagechanging',update,{signal:life.signal});
    eventBus.on('pagerendered',event=>{
      if(destroyed)return;
      const canvas=viewer.getPageView(event.pageNumber-1)?.div.querySelector('canvas');
      if(canvas){canvas.setAttribute('role','img');canvas.setAttribute('aria-label',`Trang ${event.pageNumber} / ${pdf.numPages} · ${options.name}`);}
      if(event.error)options.onError(event.error);
    },{signal:life.signal});
    task=pdfjs.getDocument({url:`/reading-history/pdf/${options.articleId}/${options.fileIndex}`,disableAutoFetch:true,disableStream:true,rangeChunkSize:262144,isEvalSupported:false,cMapUrl:assets+'cmaps/',cMapPacked:true,standardFontDataUrl:assets+'standard_fonts/',wasmUrl:assets+'wasm/',iccUrl:assets+'iccs/'});
    task.onPassword=()=>{options.onError(new Error('Tệp yêu cầu mật khẩu.'));destroy();};
    try{
      pdf=await task.promise;await pdf.getPage(1);if(destroyed)throw new DOMException('Đã đổi tệp.','AbortError');
      total.textContent=`/ ${pdf.numPages}`;input.max=String(pdf.numPages);
      await new Promise((resolve,reject)=>{
        initTimer=setTimeout(()=>reject(new Error('Chưa mở được trình đọc.')),30000);
        life.signal.addEventListener('abort',()=>reject(new DOMException('Đã đổi tệp.','AbortError')),{once:true});
        eventBus.on('pagesinit',()=>{
          clearTimeout(initTimer);viewer.currentScaleValue='page-width';fitScale=viewer.currentScale;
          viewer.currentPageNumber=Math.max(1,Math.min(pdf.numPages,Math.trunc(options.page)||1));ready=true;update();
          if(container.closest('dialog[open]')&&document.activeElement?.hasAttribute('data-document-fullscreen'))scroll.focus({preventScroll:true});
          resolve();
        },{once:true,signal:life.signal});
        viewer.setDocument(pdf);
      });
      let lastWidth=scroll.clientWidth;
      resize=new ResizeObserver(()=>{if(scroll.clientWidth===lastWidth)return;lastWidth=scroll.clientWidth;clearTimeout(resizeTimer);resizeTimer=setTimeout(fit,180);});resize.observe(scroll);
      return {destroy,getPage(){return page;}};
    }catch(error){destroy();throw error;}
  }};
})();
