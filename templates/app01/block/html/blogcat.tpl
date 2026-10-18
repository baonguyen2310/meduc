{strip}
{$blog_helper = $this->loadHelper('Blog')}
{$journal = $blog_helper->catalogue(PAGE_CATEGORY_ID, {LANGUAGE})}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$keyword = $this->getRequest()->getQuery('keyword')}{if !is_string($keyword)}{$keyword = ''}{/if}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blog-catalog.css?v=20261015" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blog-catalog.js?v=20261015" defer></script>
<main class="mbl" id="blog-catalog-page" data-initial-topic="{$journal.active}">
    <section class="mbl-hero {if $journal.active}mbl-hero--subject{/if}" aria-labelledby="journal-title">
        <div class="mbl-shell">
            <p class="mbl-eyebrow"><span aria-hidden="true"></span> MEDUC JOURNAL / GÓC HỌC TẬP</p>
            {if $journal.active}<a class="mbl-back" href="/blog">← Tất cả bài viết</a><h1 id="journal-title">{$journal.title|escape}</h1>
            {else}<h1 id="journal-title">{$text.tieu_de_1|default:'ĐỌC MỘT BÀI.'|escape}<span>{$text.tieu_de_2|default:'HIỂU THÊM MỘT ĐIỀU.'|escape}</span></h1>{/if}
            <p class="mbl-intro">{$text.mo_ta|default:'Những bài viết Y khoa và kinh nghiệm học tập từ MedUC. Tìm góc nhìn phù hợp với môn học bạn đang theo đuổi.'|escape}</p>
            <div class="mbl-hero-meta"><span><strong>{$journal.selected_count}</strong> bài viết để khám phá</span><span aria-hidden="true">/</span><a href="#bai-viet">Tìm điều bạn muốn đọc <span aria-hidden="true">↓</span></a></div>
        </div>
    </section>

    {if !empty($journal.lead)}{$lead = $journal.lead}
    <section class="mbl-shell mbl-feature" aria-labelledby="journal-feature-title">
        <div class="mbl-section-line"><p>GÓC ĐỌC HÔM NAY</p><span>01 / MEDUC JOURNAL</span></div>
        <article class="mbl-feature-layout">
            <a class="mbl-feature-image" href="{$this->Utilities->checkInternalUrl($lead.url)|escape}" aria-label="Đọc {$lead.name|escape}"><img src="{CDN_URL}{$lead.image|escape}" alt="{$lead.name|escape}" fetchpriority="high" decoding="async"></a>
            <div class="mbl-feature-copy"><p class="mbl-category">{$lead.topic_name|escape}</p><h2 id="journal-feature-title"><a href="{$this->Utilities->checkInternalUrl($lead.url)|escape}">{$lead.name|escape}</a></h2><p class="mbl-feature-summary">{$lead.summary|escape}</p><div class="mbl-feature-bottom">{if $lead.date}<time datetime="{$lead.datetime}">{$lead.date}</time>{/if}<a class="mbl-read" href="{$this->Utilities->checkInternalUrl($lead.url)|escape}">Đọc bài viết <span aria-hidden="true">↗</span></a></div></div>
        </article>
    </section>
    {/if}

    <section class="mbl-shell mbl-catalog" id="bai-viet" aria-labelledby="journal-catalog-title">
        <div class="mbl-heading"><div><p class="mbl-eyebrow">THƯ VIỆN BÀI VIẾT</p><h2 id="journal-catalog-title">TÌM BÀI VIẾT<br><span>BẠN CẦN.</span></h2></div><p>Từ những môn học nền tảng đến góc nhìn lâm sàng và kinh nghiệm học Y. Bắt đầu từ điều bạn đang tò mò.</p></div>
        <div class="mbl-tools" data-blog-tools hidden>
            <label class="mbl-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="mbl-sr-only">Tìm bài viết</span><input type="search" id="blog-search" placeholder="Tìm bài viết, môn học, từ khóa..." value="{$keyword|escape}" autocomplete="off"><button type="button" data-blog-clear aria-label="Xóa từ khóa" hidden>×</button></label>
            <label class="mbl-sort">Sắp xếp<select id="blog-sort"><option value="newest">Mới nhất</option><option value="oldest">Cũ nhất</option><option value="name">Tên A–Z</option></select></label>
        </div>
        <nav class="mbl-topics" aria-label="Chủ đề bài viết">
            <a href="/blog#bai-viet" data-blog-topic="0" {if !$journal.active}aria-current="true"{/if}>Tất cả <span>{count($journal.items)}</span></a>
            {foreach from=$journal.topics item=topic}<a href="{$this->Utilities->checkInternalUrl($topic.url)|escape}#bai-viet" data-blog-topic="{$topic.id}" {if $journal.active == $topic.id}aria-current="true"{/if}>{$topic.name|escape} <span>{$topic.count}</span></a>{/foreach}
        </nav>
        <div class="mbl-result"><p role="status" aria-live="polite" aria-atomic="true" data-blog-status>{$journal.selected_count} bài viết</p><span>KIẾN THỨC / KINH NGHIỆM / CẢM HỨNG</span></div>
        <div class="mbl-grid" data-blog-grid>
            {foreach from=$journal.items item=article}
            <article class="mbl-card" data-blog-card data-topics="{$article.topic_ids}" data-created="{$article.created}" {if $journal.active && !in_array($journal.active,$article.topics)}hidden{/if}>
                <a class="mbl-card-image" href="{$this->Utilities->checkInternalUrl($article.url)|escape}" aria-label="Đọc {$article.name|escape}">
                    {if $article.image}<img src="{CDN_URL}{$article.image|escape}" alt="{$article.name|escape}" loading="lazy" decoding="async">{else}<span class="mbl-image-placeholder" aria-hidden="true">MEDUC<span>JOURNAL / {$article.topic_name|escape}</span></span>{/if}
                </a>
                <div class="mbl-card-copy"><p class="mbl-category">{$article.topic_name|escape}</p><h3><a href="{$this->Utilities->checkInternalUrl($article.url)|escape}">{$article.name|escape}</a></h3><p class="mbl-summary">{$article.summary|escape}</p><div class="mbl-card-bottom">{if $article.date}<time datetime="{$article.datetime}">{$article.date}</time>{/if}<a class="mbl-read" href="{$this->Utilities->checkInternalUrl($article.url)|escape}">Đọc tiếp <span aria-hidden="true">↗</span></a></div></div>
            </article>
            {/foreach}
        </div>
        <div class="mbl-empty" data-blog-empty {if $journal.selected_count}hidden{/if}><span aria-hidden="true">↗</span><h3>Chưa tìm thấy bài viết phù hợp.</h3><p>Thử một từ khóa hoặc chủ đề khác.</p><button type="button" data-blog-reset hidden>Xóa bộ lọc</button><a href="/blog">Xem tất cả bài viết →</a></div>
        <button class="mbl-more" type="button" data-blog-more hidden>Xem thêm bài viết <span aria-hidden="true">↓</span></button>
    </section>
    <aside class="mbl-next"><div class="mbl-shell mbl-next-inner"><div><p class="mbl-eyebrow">TIẾP TỤC HỌC CÙNG MEDUC</p><h2>ĐỌC ĐỂ HIỂU.<br><span>HỌC ĐỂ VẬN DỤNG.</span></h2><p>Kết nối kiến thức bạn vừa đọc với bài giảng và thực hành trong các khóa học tại MedUC.</p></div><a href="/khoa-hoc" class="mbl-button">Học thử miễn phí <span aria-hidden="true">→</span></a></div></aside>
</main>
{/strip}
