(() => {
    'use strict';
    const page=document.getElementById('document-detail-page');if(!page)return;
    const files=[...page.querySelectorAll('[data-document-file]')],viewer=page.querySelector('[data-document-viewer]'),preview=page.querySelector('[data-document-preview]');
    const placeholder=page.querySelector('[data-document-placeholder]'),unavailable=page.querySelector('[data-document-unavailable]'),start=page.querySelector('[data-document-start]'),status=page.querySelector('[data-document-reader-status]'),fullscreen=page.querySelector('[data-document-fullscreen]');
    const positions=new Map();let active=0,loaded=-1,instance=null,sequence=0,userActed=false,loadController;
    function remember(index,number){positions.set(index,number);window.meducReading?.set({file_index:index,page:number});}
    function original(index,message){
        if(loaded!==index)return;
        preview.hidden=true;unavailable.hidden=false;fullscreen.hidden=true;status.textContent=message;
    }
    async function select(index,read){
        const file=files[index];if(!file||!viewer)return;
        active=index;
        files.forEach((link,i)=>{if(i===index)link.setAttribute('aria-current','true');else link.removeAttribute('aria-current');});
        const name=file.querySelector('strong').textContent;
        page.querySelector('[data-document-file-title]').textContent=name;page.querySelector('[data-document-format]').textContent=file.dataset.fileFormat;
        page.querySelectorAll('[data-document-open],[data-document-fallback]').forEach(link=>link.href=file.dataset.fileUrl);
        if(!read||loaded===index)return;
        const run=++sequence;loaded=index;loadController?.abort();loadController=new AbortController();instance?.destroy();instance=null;preview.replaceChildren();placeholder.hidden=true;
        const kind=file.dataset.filePreview;preview.hidden=!kind;unavailable.hidden=!!kind;
        fullscreen.hidden=!kind||!viewer.requestFullscreen||!document.fullscreenEnabled;
        viewer.querySelector('.mdd-viewer-kicker').textContent='TỆP ĐANG ĐỌC';
        if(!kind){remember(index,1);status.textContent='Mở tệp gốc để xem hoặc lưu về thiết bị.';return;}
        status.textContent='Đang mở tệp '+file.dataset.fileFormat+'… Tệp lớn có thể cần thêm thời gian.';
        if(kind==='pdf'){
            try{
                await window.meducReading?.ready;
                if(run!==sequence)return;
                const saved=window.meducReading?.progress()||{};
                const number=positions.get(index)||(saved.file_index===index?saved.page:1)||1;
                const reader=await window.meducPdf.open(preview,{articleId:Number(page.dataset.readingId),fileIndex:index,page:number,name,signal:loadController.signal,
                    onPage(number,total){if(run!==sequence)return;remember(index,number);status.textContent=`Trang ${number} / ${total} · Vị trí đọc được ghi nhớ khi bạn chuyển trang.`;},
                    onError(){if(run===sequence)original(index,'Chưa mở được trình xem PDF. Chọn “Mở tệp gốc” để tiếp tục; số trang trong trình xem bên ngoài sẽ không được ghi nhớ.');}
                });
                if(run!==sequence)reader.destroy();else instance=reader;
            }catch(_){if(run===sequence)original(index,'Chưa mở được trình xem PDF. Chọn “Mở tệp gốc” để tiếp tục; số trang trong trình xem bên ngoài sẽ không được ghi nhớ.');}
            return;
        }
        const frame=document.createElement(kind==='image'?'img':'iframe');if(kind==='image')frame.alt=name;else frame.title='Đọc tài liệu: '+name;
        frame.referrerPolicy='strict-origin-when-cross-origin';frame.src=kind==='image'?file.dataset.fileUrl:'https://view.officeapps.live.com/op/embed.aspx?src='+encodeURIComponent(file.dataset.fileUrl);
        frame.addEventListener('load',()=>{if(run===sequence)status.textContent='Nếu khung đọc không hiển thị, chọn “Mở tệp gốc” để đọc trong thẻ riêng.';});
        frame.addEventListener('error',()=>original(index,'Chưa mở được bản xem trước. Bạn có thể chọn “Mở tệp gốc”.'));
        preview.append(frame);remember(index,1);
    }
    files.forEach((file,index)=>{
        const hint=file.querySelector('[data-file-hint]');if(hint)hint.textContent='· Chọn để đọc';
        file.addEventListener('click',event=>{if(event.ctrlKey||event.metaKey||event.shiftKey||event.altKey||event.button!==0)return;event.preventDefault();userActed=true;void select(index,true);});
    });
    if(files.length){
        void select(0,false);start.hidden=false;start.addEventListener('click',()=>{userActed=true;void select(active,true);});
        window.meducReading?.ready.then(saved=>{
            const index=Number(saved?.file_index);if(Number.isInteger(index)&&files[index])positions.set(index,Number(saved.page)||1);
            if(userActed)return;
            if(Number.isInteger(index)&&files[index]){
                void select(index,false);start.firstChild.textContent=`Tiếp tục từ trang ${saved.page||1} `;
            }
            if(window.meducReading.resumeRequested)void select(active,true);
        });
    }
    if(fullscreen){
        fullscreen.addEventListener('click',async()=>{try{if(document.fullscreenElement===viewer)await document.exitFullscreen();else await viewer.requestFullscreen();}catch(_){status.textContent='Trình duyệt chưa mở được toàn màn hình. Chọn “Mở tệp gốc” để đọc trong thẻ riêng.';}});
        document.addEventListener('fullscreenchange',()=>fullscreen.setAttribute('aria-label',document.fullscreenElement===viewer?'Thoát toàn màn hình':'Đọc toàn màn hình'));
    }
    const share=page.querySelector('[data-document-share]');
    if(share&&navigator.clipboard&&isSecureContext){share.hidden=false;share.addEventListener('click',async()=>{const label=page.querySelector('[data-document-share-status]');try{const url=new URL(location.href);url.hash='';url.searchParams.delete('tiep-tuc');await navigator.clipboard.writeText(url.href);label.textContent='Đã sao chép liên kết tài liệu.';share.lastChild.textContent='Đã sao chép';}catch(_){label.textContent='Chưa sao chép được. Bạn có thể sao chép địa chỉ trên thanh trình duyệt.';}});}
})();
