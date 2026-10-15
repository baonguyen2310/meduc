{strip}
{$article = $data_block.data|default:[]}
{$blog_helper = $this->loadHelper('BlogDetail')}
{$journal = $blog_helper->prepare($article, {LANGUAGE})}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blog-detail.css?v=20261016" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blog-detail.js?v=20261015" defer></script>
<main class="mbj" id="blog-detail-page">
    {if !empty($journal)}{$current = $journal.current}
    <div class="mbj-progress" data-reading-bar hidden aria-hidden="true"><span></span></div>
    <nav class="mbj-shell mbj-crumb" aria-label="Đường dẫn trang"><a href="/">Trang chủ</a><span aria-hidden="true">/</span><a href="/blog">Blog</a><span aria-hidden="true">/</span><a href="{$this->Utilities->checkInternalUrl($journal.topic.url)|escape}">{$journal.topic.name|escape}</a></nav>
    <article aria-labelledby="blog-article-title">
        <header class="mbj-shell mbj-intro">
            <div class="mbj-reading-width"><a class="mbj-eyebrow" href="{$this->Utilities->checkInternalUrl($journal.topic.url)|escape}">MEDUC JOURNAL <span aria-hidden="true">/</span> {$journal.topic.name|escape}</a><h1 id="blog-article-title">{$current.name|escape}</h1>{if $journal.description}<p class="mbj-lead">{$journal.description|escape}</p>{/if}
                <div class="mbj-meta">{if $current.date}<time datetime="{$current.datetime}">Đăng ngày {$current.date}</time><span class="mbj-dot" aria-hidden="true"></span>{/if}<span class="mbj-time"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>Khoảng {$journal.minutes} phút đọc</span><button class="mbj-copy" type="button" data-copy-link hidden><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m10 13 4-4m-6 6-1 1a4 4 0 0 1-6-6l4-4a4 4 0 0 1 6 0m2 2 1-1a4 4 0 0 1 6 6l-4 4a4 4 0 0 1-6 0"/></svg>Sao chép liên kết</button></div>
            </div>
        </header>
        {if $current.image}<figure class="mbj-shell mbj-cover"><img src="{CDN_URL}{$current.image|escape}" alt="{$current.name|escape}" fetchpriority="high" decoding="async"><figcaption>MEDUC / {$journal.topic.name|escape}</figcaption></figure>{/if}

        <div class="mbj-shell mbj-body-layout">
            <aside class="mbj-aside" aria-label="Điều hướng bài viết"><div class="mbj-aside-sticky">
                <details class="mbj-toc" open><summary>TRONG BÀI VIẾT NÀY <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg></summary><nav aria-label="Mục lục bài viết">{if !empty($journal.toc)}{foreach from=$journal.toc item=section}<a href="#{$section.id|escape}" data-toc-link>{$section.name|escape}</a>{/foreach}{else}<a href="#blog-prose" data-toc-link>Nội dung bài viết</a>{/if}</nav></details>
                <div class="mbj-reading-status" data-reading-status hidden><span>TIẾN ĐỘ ĐỌC</span><strong data-reading-number>0%</strong><div role="progressbar" aria-label="Tiến độ đọc bài viết" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" data-reading-progress><span></span></div></div>
                <a class="mbj-back" href="{$this->Utilities->checkInternalUrl($journal.topic.url)|escape}">← Xem thêm {$journal.topic.name|escape}</a>
            </div></aside>
            <div class="mbj-reading-column">
                {if !empty($article.url_video) && !empty($article.type_video)}<div class="mbj-media">{if $article.type_video == {VIDEO_YOUTUBE}}<iframe src="https://www.youtube.com/embed/{$article.url_video|escape}" title="Video bài viết {$current.name|escape}" loading="lazy" allow="accelerometer; encrypted-media; picture-in-picture" allowfullscreen></iframe>{elseif $article.type_video == {VIDEO_SYSTEM}}<video src="{CDN_URL}{$article.url_video|escape}" controls playsinline preload="none"></video>{/if}</div>{/if}
                <div class="mbj-prose" id="blog-prose">{$journal.html}</div>
                {if !empty($journal.gallery)}<div class="mbj-gallery">{foreach from=$journal.gallery item=image}<a href="{CDN_URL}{$image|escape}" target="_blank" rel="noopener" aria-label="Mở ảnh trong bài viết"><img src="{CDN_URL}{$image|escape}" alt="Ảnh trong bài viết {$current.name|escape}" loading="lazy" decoding="async"></a>{/foreach}</div>{/if}
                {if !empty($article.has_file) && !empty($article.files)}<section class="mbj-files" aria-labelledby="blog-files-title"><h2 id="blog-files-title">Tài liệu đính kèm</h2>{foreach from=$article.files item=file}<a href="{CDN_URL}{$this->Utilities->checkInternalUrl($file)|escape}" target="_blank" rel="noopener"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 2H5v20h14V7Zm0 0v5h5M8 13h8m-8 4h5"/></svg>{$this->Utilities->getFileNameInUrl($file)|urldecode|escape}<span aria-hidden="true">↗</span></a>{/foreach}</section>{/if}
                {if !empty($journal.faqs)}<section class="mbj-faq" aria-labelledby="blog-faq-title"><p class="mbj-eyebrow">GIẢI ĐÁP THÊM</p><h2 id="blog-faq-title">Câu hỏi thường gặp</h2>{foreach from=$journal.faqs item=faq}<details><summary>{$faq.name|escape}<span aria-hidden="true">+</span></summary><div class="mbj-prose">{$faq.html}</div></details>{/foreach}</section>{/if}
                {if !empty($article.tags)}<nav class="mbj-tags" aria-label="Thẻ bài viết">{foreach from=$article.tags item=tag}{if !empty($tag.name) && !empty($tag.url)}<a href="{TAG_PATH}/{$tag.url|escape}"># {$tag.name|escape}</a>{/if}{/foreach}</nav>{/if}
                <div class="mbj-end"><span aria-hidden="true">M<span>EDUC</span> / JOURNAL</span><a href="/blog">Khám phá tất cả bài viết <span aria-hidden="true">↗</span></a></div>
                {if !empty($journal.previous) || !empty($journal.next)}<nav class="mbj-adjacent" aria-label="Đọc tiếp trong cùng chủ đề">{if !empty($journal.previous)}<a href="{$this->Utilities->checkInternalUrl($journal.previous.url)|escape}"><span>← BÀI MỚI HƠN</span><strong>{$journal.previous.name|escape}</strong></a>{/if}{if !empty($journal.next)}<a href="{$this->Utilities->checkInternalUrl($journal.next.url)|escape}"><span>BÀI TRƯỚC ĐÓ →</span><strong>{$journal.next.name|escape}</strong></a>{/if}</nav>{/if}
            </div>
        </div>
    </article>

    {if !empty($journal.related)}<section class="mbj-related" aria-labelledby="blog-related-title"><div class="mbj-shell"><div class="mbj-section-heading"><div><p class="mbj-eyebrow">TIẾP TỤC KHÁM PHÁ</p><h2 id="blog-related-title">ĐỌC THÊM.<br><span>HIỂU SÂU HƠN.</span></h2></div><a href="/blog">Xem tất cả bài viết <span aria-hidden="true">↗</span></a></div><div class="mbj-related-grid">{foreach from=$journal.related item=item}<article class="mbj-card"><a class="mbj-card-image" href="{$this->Utilities->checkInternalUrl($item.url)|escape}" aria-label="Đọc {$item.name|escape}">{if $item.image}<img src="{CDN_URL}{$item.image|escape}" alt="{$item.name|escape}" loading="lazy" decoding="async">{else}<span>MEDUC JOURNAL</span>{/if}</a><div class="mbj-card-copy"><p class="mbj-eyebrow">{$item.topic_name|escape}</p><h3><a href="{$this->Utilities->checkInternalUrl($item.url)|escape}">{$item.name|escape}</a></h3><p>{$item.summary|escape}</p><div><time datetime="{$item.datetime}">{$item.date}</time><a href="{$this->Utilities->checkInternalUrl($item.url)|escape}">Đọc tiếp <span aria-hidden="true">↗</span></a></div></div></article>{/foreach}</div></div></section>{/if}

    {if !empty($journal.course_ids)}{$courses = $this->Product->getProducts(['filter'=>['ids'=>$journal.course_ids,'draft'=>'0'],'limit'=>6])}{if !empty($courses)}<section class="mbj-shell mbj-courses" aria-labelledby="blog-courses-title"><div class="mbj-section-heading"><div><p class="mbj-eyebrow">TỪ KIẾN THỨC ĐẾN THỰC HÀNH</p><h2 id="blog-courses-title">HỌC TIẾP<br><span>CÙNG MEDUC.</span></h2></div><p>Các khóa học được MedUC giới thiệu trong bài viết.</p></div><div class="mbj-course-grid">{foreach from=$courses item=course}<article><a class="mbj-course-image" href="{$this->Utilities->checkInternalUrl($course.url)|escape}">{if !empty($course.all_images[0])}<img src="{CDN_URL}{$course.all_images[0]|escape}" alt="{$course.name|escape}" loading="lazy" decoding="async">{/if}</a><div><h3><a href="{$this->Utilities->checkInternalUrl($course.url)|escape}">{$course.name|escape}</a></h3><a class="mbj-button" href="{$this->Utilities->checkInternalUrl($course.url)|escape}">Khám phá khóa học <span aria-hidden="true">→</span></a></div></article>{/foreach}</div></section>{/if}
    {else}<aside class="mbj-next"><div class="mbj-shell mbj-next-inner"><div><p class="mbj-eyebrow">TIẾP TỤC HỌC CÙNG MEDUC</p><h2>ĐỌC ĐỂ HIỂU.<br><span>HỌC ĐỂ VẬN DỤNG.</span></h2><p>Nối điều vừa đọc với bài giảng và thực hành theo lộ trình học Y của bạn.</p></div><a class="mbj-button" href="/khoa-hoc">Khám phá khóa học <span aria-hidden="true">→</span></a></div></aside>{/if}
    <dialog class="mbj-copy-dialog" data-copy-dialog aria-labelledby="copy-link-title"><h2 id="copy-link-title">Liên kết bài viết</h2><p>Chọn và sao chép liên kết bên dưới.</p><label for="blog-copy-url" class="mbj-sr-only">Địa chỉ bài viết</label><input id="blog-copy-url" type="url" readonly><form method="dialog"><button type="submit">Đóng</button></form></dialog>
    <p class="mbj-sr-only" data-copy-status role="status" aria-live="polite"></p>
    {else}<section class="mbj-shell mbj-unavailable"><p class="mbj-eyebrow">MEDUC JOURNAL</p><h1>Bài viết hiện chưa khả dụng.</h1><a class="mbj-button" href="/blog">Về danh sách blog <span aria-hidden="true">→</span></a></section>{/if}
</main>
{/strip}
