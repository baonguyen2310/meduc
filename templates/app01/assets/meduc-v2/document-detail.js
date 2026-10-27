(() => {
    'use strict';
    const page=document.getElementById('document-detail-page');if(!page)return;
    const files=[...page.querySelectorAll('[data-document-file]')],viewer=page.querySelector('[data-document-viewer]'),preview=page.querySelector('[data-document-preview]');
    const placeholder=page.querySelector('[data-document-placeholder]'),unavailable=page.querySelector('[data-document-unavailable]'),start=page.querySelector('[data-document-start]'),status=page.querySelector('[data-document-reader-status]'),fullscreen=page.querySelector('[data-document-fullscreen]');
    const dialog=page.querySelector('[data-document-dialog]'),retry=page.querySelector('[data-document-retry]');
    const positions=new Map();let active=0,loaded=-1,instance=null,sequence=0,userActed=false,loadController,expanded=false,lastFocus;
    const marker=document.createComment('Document reader position');if(viewer)viewer.before(marker);
    function labelExpanded(open){
        if(!fullscreen)return;
        fullscreen.setAttribute('aria-label',open?'Đóng trình đọc':'Phóng to trình đọc');
        fullscreen.querySelector('use').setAttribute('href',open?'#mdd-close':'#mdd-expand');
        page.querySelector('[data-document-expand-label]').textContent=open?'Đóng':'Phóng to';
    }
    function restoreReader(){
        if(!expanded)return;
        expanded=false;marker.after(viewer);document.body.classList.remove('meduc-document-reading');labelExpanded(false);
        if(preview.classList.contains('mdp-host')&&!preview.hidden&&unavailable.hidden){preview.hidden=true;placeholder.hidden=false;start.firstChild.textContent=`Tiếp tục từ trang ${positions.get(active)||1} `;}
        window.meducReading?.flush(true);lastFocus?.focus({preventScroll:true});
    }
    function collapse(){
        if(!dialog||!expanded)return;
        if(typeof dialog.close==='function')dialog.close();else dialog.removeAttribute('open');
        restoreReader();
    }
    function expand(opener){
        if(!viewer||!dialog||expanded)return;
        lastFocus=opener||document.activeElement;dialog.append(viewer);
        if(typeof dialog.showModal==='function')dialog.showModal();else dialog.setAttribute('open','');
        if(loaded===active&&preview.childElementCount&&unavailable.hidden){preview.hidden=false;placeholder.hidden=true;}
        expanded=true;document.body.classList.add('meduc-document-reading');labelExpanded(true);fullscreen?.focus({preventScroll:true});
    }
    function openReader(index,opener){userActed=true;expand(opener);void select(index,true);}
    dialog?.addEventListener('close',restoreReader);
    dialog?.addEventListener('cancel',event=>{event.preventDefault();collapse();});
    dialog?.addEventListener('keydown',event=>{if(event.key==='Escape'){event.preventDefault();collapse();}});
    function remember(index,number){positions.set(index,number);window.meducReading?.set({file_index:index,page:number});}
    function failure(index,message,retryable=true){
        if(loaded!==index)return;
        preview.hidden=true;unavailable.hidden=false;retry.hidden=!retryable;page.querySelector('[data-document-error-message]').textContent=message;status.textContent=message;
    }
    async function select(index,read){
        const file=files[index];if(!file||!viewer)return;
        active=index;
        files.forEach((link,i)=>{if(i===index)link.setAttribute('aria-current','true');else link.removeAttribute('aria-current');});
        const name=file.querySelector('strong').textContent;
        page.querySelector('[data-document-file-title]').textContent=name;page.querySelector('[data-document-format]').textContent=file.dataset.fileFormat;
        if(!read||loaded===index)return;
        const run=++sequence;loaded=index;loadController?.abort();loadController=new AbortController();instance?.destroy();instance=null;preview.classList.remove('mdp-host');preview.replaceChildren();placeholder.hidden=true;
        const kind=file.dataset.filePreview;preview.hidden=!kind;unavailable.hidden=!!kind;
        fullscreen.hidden=false;
        viewer.querySelector('.mdd-viewer-kicker').textContent='TỆP ĐANG ĐỌC';
        if(!kind){failure(index,'Định dạng này chưa hỗ trợ đọc trực tiếp. Vui lòng chọn tệp khác.',false);return;}
        status.textContent='Đang mở tệp '+file.dataset.fileFormat+'… Tệp lớn có thể cần thêm thời gian.';
        if(kind==='pdf'){
            try{
                await window.meducReading?.ready;
                if(run!==sequence)return;
                const saved=window.meducReading?.progress()||{};
                const number=positions.get(index)||(saved.file_index===index?saved.page:1)||1;
                const reader=await window.meducPdf.open(preview,{articleId:Number(page.dataset.readingId),fileIndex:index,page:number,name,signal:loadController.signal,
                    onPage(number,total){if(run!==sequence)return;remember(index,number);status.textContent=`Trang ${number} / ${total} · Vị trí đọc được ghi nhớ tự động.`;},
                    onError(){if(run===sequence)failure(index,'Chưa mở được tài liệu. Vui lòng thử lại sau giây lát.');}
                });
                if(run!==sequence)reader.destroy();else instance=reader;
            }catch(_){if(run===sequence)failure(index,'Chưa mở được tài liệu. Vui lòng thử lại sau giây lát.');}
            return;
        }
        const frame=document.createElement(kind==='image'?'img':'iframe');if(kind==='image')frame.alt=name;else frame.title='Đọc tài liệu: '+name;
        frame.referrerPolicy='strict-origin-when-cross-origin';frame.src=kind==='image'?file.dataset.fileUrl:'https://view.officeapps.live.com/op/embed.aspx?src='+encodeURIComponent(file.dataset.fileUrl);
        frame.addEventListener('load',()=>{if(run===sequence)status.textContent='Đang đọc tài liệu · Nhấn Đóng để quay lại trang.';});
        frame.addEventListener('error',()=>failure(index,'Chưa mở được tài liệu. Vui lòng thử lại sau giây lát.'));
        preview.append(frame);remember(index,1);
    }
    files.forEach((file,index)=>{
        const hint=file.querySelector('[data-file-hint]');if(hint)hint.textContent='· Đọc toàn màn hình';
        file.addEventListener('click',event=>{event.preventDefault();openReader(index,event.currentTarget);});
    });
    if(files.length){
        void select(0,false);start.hidden=false;fullscreen.hidden=false;start.addEventListener('click',event=>openReader(active,event.currentTarget));
        page.querySelectorAll('[data-document-read]').forEach(link=>link.addEventListener('click',event=>{event.preventDefault();openReader(active,event.currentTarget);}));
        retry?.addEventListener('click',event=>{loaded=-1;openReader(active,event.currentTarget);});
        window.meducReading?.ready.then(saved=>{
            const index=Number(saved?.file_index);if(Number.isInteger(index)&&files[index])positions.set(index,Number(saved.page)||1);
            if(userActed)return;
            if(Number.isInteger(index)&&files[index]){
                void select(index,false);start.firstChild.textContent=`Tiếp tục từ trang ${saved.page||1} `;
            }
            if(window.meducReading.resumeRequested){expand();void select(active,true);}
        });
    }
    fullscreen?.addEventListener('click',event=>{if(expanded)collapse();else openReader(active,event.currentTarget);});
    const share=page.querySelector('[data-document-share]');
    if(share&&navigator.clipboard&&isSecureContext){share.hidden=false;share.addEventListener('click',async()=>{const label=page.querySelector('[data-document-share-status]');try{const url=new URL(location.href);url.hash='';url.searchParams.delete('tiep-tuc');await navigator.clipboard.writeText(url.href);label.textContent='Đã sao chép liên kết tài liệu.';share.lastChild.textContent='Đã sao chép';}catch(_){label.textContent='Chưa sao chép được. Bạn có thể sao chép địa chỉ trên thanh trình duyệt.';}});}
})();
