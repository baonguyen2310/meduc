(() => {
    'use strict';
    const page = document.getElementById('document-detail-page');
    if (!page) return;
    const files = Array.from(page.querySelectorAll('[data-document-file]'));
    const viewer = page.querySelector('[data-document-viewer]');
    const preview = page.querySelector('[data-document-preview]');
    const placeholder = page.querySelector('[data-document-placeholder]');
    const unavailable = page.querySelector('[data-document-unavailable]');
    const start = page.querySelector('[data-document-start]');
    const status = page.querySelector('[data-document-reader-status]');
    const fullscreen = page.querySelector('[data-document-fullscreen]');
    let active = 0;
    let loaded = -1;

    function select(index, read) {
        const file = files[index];
        if (!file || !viewer) return;
        active = index;
        files.forEach((link, position) => {
            if (position === index) link.setAttribute('aria-current', 'true');
            else link.removeAttribute('aria-current');
        });
        const name = file.querySelector('strong').textContent;
        page.querySelector('[data-document-file-title]').textContent = name;
        page.querySelector('[data-document-format]').textContent = file.dataset.fileFormat;
        page.querySelectorAll('[data-document-open],[data-document-fallback]').forEach(link => { link.href = file.dataset.fileUrl; });
        if (!read || loaded === index) return;
        loaded = index;
        preview.replaceChildren();
        placeholder.hidden = true;
        const kind = file.dataset.filePreview;
        preview.hidden = !kind;
        unavailable.hidden = !!kind;
        fullscreen.hidden = !kind || !viewer.requestFullscreen || !document.fullscreenEnabled;
        viewer.querySelector('.mdd-viewer-kicker').textContent = 'TỆP ĐANG ĐỌC';
        if (!kind) {
            status.textContent = 'Mở tệp gốc để xem hoặc lưu về thiết bị.';
            return;
        }
        const frame = document.createElement(kind === 'image' ? 'img' : 'iframe');
        if (kind === 'image') frame.alt = name;
        else frame.title = 'Đọc tài liệu: ' + name;
        frame.referrerPolicy = 'strict-origin-when-cross-origin';
        frame.src = kind === 'pdf' ? file.dataset.fileUrl + '#view=FitH' : (kind === 'image' ? file.dataset.fileUrl : 'https://view.officeapps.live.com/op/embed.aspx?src=' + encodeURIComponent(file.dataset.fileUrl));
        frame.addEventListener('load', () => {
            if (loaded === index) status.textContent = 'Nếu khung đọc không hiển thị, chọn “Mở tệp gốc” để đọc trong thẻ riêng.';
        });
        frame.addEventListener('error', () => {
            if (loaded !== index) return;
            preview.hidden = true;
            unavailable.hidden = false;
            fullscreen.hidden = true;
            status.textContent = 'Chưa mở được bản xem trước. Bạn có thể chọn “Mở tệp gốc”.';
        });
        status.textContent = 'Đang mở tệp ' + file.dataset.fileFormat + '… Tệp lớn có thể cần thêm thời gian. Bạn cũng có thể chọn “Mở tệp gốc”.';
        preview.append(frame);
    }

    files.forEach((file, index) => {
        const hint = file.querySelector('[data-file-hint]');
        if (hint) hint.textContent = '· Chọn để đọc';
        file.addEventListener('click', event => {
            if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button !== 0) return;
            event.preventDefault();
            select(index, true);
        });
    });
    if (files.length) {
        select(0, false);
        start.hidden = false;
        start.addEventListener('click', () => select(active, true));
    }
    if (fullscreen) {
        fullscreen.addEventListener('click', async () => {
            try {
                if (document.fullscreenElement === viewer) await document.exitFullscreen();
                else await viewer.requestFullscreen();
            } catch (_) {
                status.textContent = 'Trình duyệt chưa mở được toàn màn hình. Chọn “Mở tệp gốc” để đọc trong thẻ riêng.';
            }
        });
        document.addEventListener('fullscreenchange', () => {
            fullscreen.setAttribute('aria-label', document.fullscreenElement === viewer ? 'Thoát toàn màn hình' : 'Đọc toàn màn hình');
        });
    }

    const share = page.querySelector('[data-document-share]');
    if (share && navigator.clipboard && window.isSecureContext) {
        share.hidden = false;
        share.addEventListener('click', async () => {
            const label = page.querySelector('[data-document-share-status]');
            try {
                const url = new URL(window.location.href);
                url.hash = '';
                await navigator.clipboard.writeText(url.href);
                label.textContent = 'Đã sao chép liên kết tài liệu.';
                share.lastChild.textContent = 'Đã sao chép';
            } catch (_) { label.textContent = 'Chưa sao chép được. Bạn có thể sao chép địa chỉ trên thanh trình duyệt.'; }
        });
    }
})();
