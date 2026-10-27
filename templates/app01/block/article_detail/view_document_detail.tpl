{strip}
{$article = $data_block.data|default:[]}
{$categories = $this->Category->getCategories({ARTICLE}, {LANGUAGE}, [{FILTER} => ['parent_id' => 48]])}
{$document_view = $this->loadHelper('Document')}
{$detail = $document_view->getDetail($article, $categories, {LANGUAGE})}
{if !empty($detail)}
{$document = $detail.document}
{$courses = []}
{if !empty($article.attributes.combo_course_in_doc.value)}{$course_ids = json_decode($article.attributes.combo_course_in_doc.value, true)}{if is_array($course_ids) && !empty($course_ids)}{$courses = $this->Product->getProducts(['filter' => ['ids' => $course_ids], 'limit' => 3])}{/if}{/if}
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/document-catalog.css?v=20261015" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/document-detail.css?v=20261028-reader" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/reading-history.css?v=20261028-2" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/reading-history.js?v=20261028-2" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/pdf-reader.js?v=20261028-2" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/document-detail.js?v=20261028-reader" defer></script>
<main class="mdd" id="document-detail-page" data-reading-item="document" data-reading-id="{$document.id}" data-reading-title="{$document.title|escape}" data-reading-topic="{$document.subject|escape}" data-reading-image="{if !empty($document.image)}{CDN_URL}{$document.image|escape}{/if}">
    <svg class="mdd-symbols" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><symbol id="mdd-arrow" viewBox="0 0 24 24"><path d="M4 12h16m-6-6 6 6-6 6"/></symbol><symbol id="mdd-file" viewBox="0 0 24 24"><path d="M14 3H5v18h14V8Zm0 0v5h5M8 13h8m-8 4h6"/></symbol><symbol id="mdd-close" viewBox="0 0 24 24"><path d="m6 6 12 12M6 18 18 6"/></symbol><symbol id="mdd-expand" viewBox="0 0 24 24"><path d="M9 4H4v5m11-5h5v5M4 15v5h5m11-5v5h-5"/></symbol><symbol id="mdd-link" viewBox="0 0 24 24"><path d="m10 7 3-3a5 5 0 0 1 7 7l-3 3M14 17l-3 3a5 5 0 0 1-7-7l3-3m1 6 8-8"/></symbol></svg>
    <div class="mdd-hero"><div class="mdd-shell">
        <nav class="mdd-breadcrumb" aria-label="Đường dẫn"><a href="/">Trang chủ</a><span aria-hidden="true">/</span><a href="/tai-lieu-hoc-tap">Tài liệu học tập</a><span aria-hidden="true">/</span><span aria-current="page">{$document.subject|escape}</span></nav>
        <section class="mdd-intro" aria-labelledby="document-title">
            <div class="mdd-copy"><p class="mdd-eyebrow">MEDUC / {$document.subject|escape}</p><h1 id="document-title">{$document.title|escape}</h1>{if !empty($detail.lead)}<p class="mdd-lead">{$detail.lead|escape}</p>{/if}
                <div class="mdd-facts"><span>{$document.year_label|escape}</span>{if !empty($detail.formats)}<span>{$detail.formats|escape}</span>{/if}<span>{count($detail.files)} tệp đính kèm</span>{if !empty($document.date)}<time datetime="{$document.date_iso}">Đăng {$document.date}</time>{/if}</div>
                <div class="mdd-actions">{if !empty($detail.files)}<a class="mdd-button" href="#document-reader" data-document-read>Đọc tài liệu <svg aria-hidden="true"><use href="#mdd-arrow"/></svg></a>{/if}<a class="mdd-text-link" href="#document-information">Giới thiệu tài liệu <span aria-hidden="true">↓</span></a></div>
            </div>
            <div class="mdd-art"><div class="mdd-cover">{if !empty($document.image)}<img src="{CDN_URL}{$this->Utilities->getThumbs($document.image, 720)}" alt="Bìa tài liệu {$document.name|escape}" decoding="async">{else}<svg aria-hidden="true"><use href="#mdd-file"/></svg>{/if}<span class="mdd-cover-badge">{$document.year_label|escape}</span></div><p class="mdd-art-note"><span>THƯ VIỆN HỌC TẬP MEDUC</span><svg aria-hidden="true"><use href="#mdd-file"/></svg></p></div>
        </section>
    </div></div>
    <nav class="mdd-section-nav" aria-label="Nội dung tài liệu"><div class="mdd-shell">{if !empty($detail.files)}<a href="#document-reader" data-document-read>Đọc tài liệu <span>{count($detail.files)}</span></a>{/if}<a href="#document-information">Giới thiệu</a>{if !empty($detail.related)}<a href="#document-related">Cùng chủ đề</a>{/if}<button type="button" data-document-share hidden><svg aria-hidden="true"><use href="#mdd-link"/></svg>Sao chép liên kết</button><span class="mdd-sr-only" role="status" aria-live="polite" data-document-share-status></span></div></nav>

    {if !empty($detail.files)}<section class="mdd-shell mdd-reading" id="document-reader" aria-labelledby="document-reader-title">
        <div class="mdd-heading"><div><p class="mdd-eyebrow">01 / KHÔNG GIAN ĐỌC</p><h2 id="document-reader-title">MỞ TÀI LIỆU.<br><span>HIỂU SÂU HƠN.</span></h2></div><p>Chọn một tệp để đọc toàn màn hình và tiếp tục từ trang đã xem.</p></div>
        <div class="mdd-reader-layout">
            <aside class="mdd-file-list" aria-label="Tệp đính kèm"><div class="mdd-file-list-heading"><h3>Tệp tài liệu</h3><span>{count($detail.files)|string_format:'%02d'}</span></div>
                {foreach from=$detail.files item=file key=index}<div class="mdd-file-item"><button type="button" class="mdd-file-select" data-document-file="{$index}" data-file-url="{$file.url|escape}" data-file-format="{$file.format|escape}" data-file-preview="{$file.preview|escape}"><span class="mdd-file-type">{$file.format|escape}</span><span class="mdd-file-copy"><strong>{$file.name|escape}</strong><small>Tệp {$index+1|string_format:'%02d'} <span data-file-hint>· Đọc toàn màn hình</span></small></span><span class="mdd-file-indicator" aria-hidden="true">→</span></button></div>{/foreach}
                <p class="mdd-file-help">Bấm vào tên tệp để đọc. Vị trí được ghi nhớ khi bạn chuyển trang.</p>
            </aside>
            <div class="mdd-viewer" data-document-viewer>
                <div class="mdd-viewer-toolbar"><div><span class="mdd-viewer-kicker">ĐANG CHỌN</span><h3 id="document-file-title" data-document-file-title>{$detail.files[0].name|escape}</h3></div><div class="mdd-viewer-tools"><button type="button" data-document-fullscreen hidden aria-label="Phóng to trình đọc"><svg aria-hidden="true"><use href="#mdd-expand"/></svg><span data-document-expand-label>Phóng to</span></button></div></div>
                <div class="mdd-reader-placeholder" data-document-placeholder><div class="mdd-reader-paper"><svg aria-hidden="true"><use href="#mdd-file"/></svg><span data-document-format>{$detail.files[0].format|escape}</span></div><h3>Sẵn sàng cho một góc nhìn mới?</h3><p>Bấm đọc để mở toàn màn hình. Tài liệu dung lượng lớn có thể cần thêm thời gian hiển thị.</p><button class="mdd-button" type="button" data-document-start hidden>Đọc tài liệu này <svg aria-hidden="true"><use href="#mdd-arrow"/></svg></button><noscript><p>Vui lòng bật JavaScript để sử dụng trình đọc tài liệu.</p></noscript></div>
                <div class="mdd-preview" data-document-preview hidden></div>
                <div class="mdd-reader-unavailable" data-document-unavailable hidden><svg aria-hidden="true"><use href="#mdd-file"/></svg><h3 data-document-error-title>Chưa mở được tài liệu.</h3><p data-document-error-message>Vui lòng thử lại sau giây lát.</p><button class="mdd-button" type="button" data-document-retry>Thử lại <svg aria-hidden="true"><use href="#mdd-arrow"/></svg></button></div>
                <p class="mdd-reader-status" role="status" aria-live="polite" data-document-reader-status>Chưa tải tệp · Bấm đọc để bắt đầu.</p>
            </div>
        </div>
    </section><dialog class="mdd-reader-dialog" data-document-dialog aria-labelledby="document-file-title"></dialog>{/if}

    <section class="mdd-information" id="document-information" aria-labelledby="document-information-title"><div class="mdd-shell mdd-information-layout"><div class="mdd-information-label"><p class="mdd-eyebrow">{if !empty($detail.files)}02{else}01{/if} / VỀ TÀI LIỆU</p><h2 id="document-information-title">ĐỌC GẦN HƠN.<br><span>NẮM CHẮC HƠN.</span></h2><div class="mdd-category-links">{foreach from=$article.categories item=category}{if !empty($category.url)}<a href="{$this->Utilities->checkInternalUrl($category.url)|escape}">{$category.name|escape}<span aria-hidden="true">↗</span></a>{/if}{/foreach}</div></div>
        <div class="mdd-editorial">{if !empty($article.content)}<div class="mdd-rich">{$this->LazyLoad->renderContent($article.content)}</div>{elseif !empty($article.description)}<div class="mdd-rich">{$this->LazyLoad->renderContent($article.description)}</div>{else}<p class="mdd-empty-copy">Phần giới thiệu tài liệu đang được cập nhật.{if !empty($detail.files)} Bạn có thể đọc các tệp đính kèm ở trên.{/if}</p>{/if}
        {if !empty($article.url_video) && !empty($article.type_video)}<div class="mdd-video">{if $article.type_video == {VIDEO_YOUTUBE}}<iframe loading="lazy" src="https://www.youtube.com/embed/{$article.url_video|escape}" title="Video giới thiệu {$document.name|escape}" allow="accelerometer; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>{elseif $article.type_video == {VIDEO_SYSTEM}}<video src="{CDN_URL}{$article.url_video|escape}" controls preload="none"></video>{/if}</div>{/if}
        </div>
    </div></section>

    {if !empty($courses)}<section class="mdd-shell mdd-courses" aria-labelledby="document-courses-title"><div class="mdd-heading"><div><p class="mdd-eyebrow">GỢI Ý TỪ MEDUC</p><h2 id="document-courses-title">TỪ TRANG SÁCH.<br><span>ĐẾN BÀI GIẢNG.</span></h2></div><a class="mdd-text-link" href="/khoa-hoc">Học thử miễn phí →</a></div><div class="mdd-course-grid">{foreach from=$courses item=course}<article class="mdd-course"><a href="{$this->Utilities->checkInternalUrl($course.url)|escape}">{if !empty($course.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($course.all_images[0], 500)}" alt="{$course.name|escape}" loading="lazy">{/if}<div><h3>{$course.name|escape}</h3><span>Xem khóa học <svg aria-hidden="true"><use href="#mdd-arrow"/></svg></span></div></a></article>{/foreach}</div></section>{/if}

    {if !empty($detail.related)}<section class="mdd-related" id="document-related" aria-labelledby="document-related-title"><div class="mdd-shell"><div class="mdd-heading"><div><p class="mdd-eyebrow">TIẾP TỤC KHÁM PHÁ / {$document.subject|escape}</p><h2 id="document-related-title">CÙNG CHỦ ĐỀ.<br><span>THÊM GÓC NHÌN.</span></h2></div><a class="mdd-text-link" href="/tai-lieu-hoc-tap">Xem thư viện tài liệu →</a></div><div class="mdc"><div class="mdc-grid">{foreach from=$detail.related item=related}<article class="mdc-card"><a class="mdc-cover" href="{$this->Utilities->checkInternalUrl($related.url)|escape}" aria-label="Xem {$related.name|escape}">{if !empty($related.image)}<img src="{CDN_URL}{$this->Utilities->getThumbs($related.image, 500)}" alt="{$related.name|escape}" loading="lazy">{/if}<span class="mdc-year-badge">{$related.year_label|escape}</span><span class="mdc-format">{$related.formats|escape}</span></a><div class="mdc-card-body"><p class="mdc-card-subject">{$related.subject|escape}</p><h3><a href="{$this->Utilities->checkInternalUrl($related.url)|escape}">{$related.title|escape}</a></h3><p class="mdc-summary">{$related.summary|escape}</p><a class="mdc-card-link" href="{$this->Utilities->checkInternalUrl($related.url)|escape}">Xem tài liệu <svg aria-hidden="true"><use href="#mdd-arrow"/></svg></a></div></article>{/foreach}</div></div></div></section>{/if}
</main>
{else}<div class="mdd-missing"><p>Chưa tìm thấy tài liệu đang mở.</p><a href="/tai-lieu-hoc-tap">Quay lại thư viện tài liệu →</a></div>{/if}
{/strip}
