{strip}
{* Reuses the homepage learning stages; copy and images remain editable in the normal block settings. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/roadmap-page.css?v=20261021-2" rel="stylesheet">

<main class="mlr" id="meduc-roadmap">
    <section class="mlr-shell mlr-hero" aria-labelledby="roadmap-title">
        <div>
            <p class="mlr-eyebrow">MEDUC / LỘ TRÌNH HỌC</p>
            <h1 id="roadmap-title">{$text.tieu_de_1|default:'TỪ CƠ BẢN.'|escape}<span>{$text.tieu_de_2|default:'ĐẾN CHUYÊN SÂU.'|escape}</span></h1>
            <p class="mlr-lead">{$text.mo_ta|default:'Mỗi giai đoạn học Y có một trọng tâm. Chọn điểm bắt đầu phù hợp, xây chắc kiến thức nền rồi kết nối với lâm sàng và luyện tập.'|escape}</p>
            <a class="mlr-button" href="#cac-chang-hoc">Chọn chặng học của bạn <span aria-hidden="true">↓</span></a>
        </div>
        <aside class="mlr-guide" aria-label="Cách chọn lộ trình">
            <p class="mlr-eyebrow">BẮT ĐẦU TỪ ĐIỀU BẠN CẦN</p>
            <h2>MỘT HÀNH TRÌNH.<br>NHIỀU ĐIỂM BẮT ĐẦU.</h2>
            <ol>
                <li><span>01</span><div><strong>Xác định nền tảng</strong><p>Bạn đang học giai đoạn nào? Phần kiến thức nào cần củng cố?</p></div></li>
                <li><span>02</span><div><strong>Học theo từng chặng</strong><p>Đi từ khái niệm đến mối liên hệ và cách vận dụng.</p></div></li>
                <li><span>03</span><div><strong>Luyện tập và quay lại</strong><p>Từ câu chưa chắc, tìm đúng phần cần học lại.</p></div></li>
            </ol>
        </aside>
    </section>

    <nav class="mlr-jump" aria-label="Các chặng trong lộ trình">
        <div class="mlr-shell">
            {foreach from = $data_block item = stage}
                {if !empty($stage.name)}<a href="#chang-{$stage@iteration}"><span>{$stage@iteration|string_format:'%02d'}</span>{$stage.name|escape}</a>{/if}
            {/foreach}
        </div>
    </nav>

    <section class="mlr-shell mlr-stages" id="cac-chang-hoc" aria-label="Lộ trình từ nền tảng đến chuyên sâu">
        <div class="mlr-section-intro"><p class="mlr-eyebrow">CHỌN CHẶNG ĐƯỜNG CỦA BẠN</p><p>Bắt đầu từ giai đoạn phù hợp với mình. Bạn có thể quay lại kiến thức nền hoặc luyện đề ở bất kỳ chặng nào.</p></div>
        {foreach from = $data_block item = stage}
            {if !empty($stage.name)}
                {$picture = ''}
                {if !empty($stage.image)}
                    {if $stage.image_source == 'cdn'}{$picture = "{CDN_URL}{$this->Utilities->getThumbs($stage.image, 720)}"}
                    {else}{$picture = $stage.image}{/if}
                {/if}
                {$link = $stage.url|default:'/khoa-hoc'|trim}
                {if $link == '/danh-sach-de-thi'}{$link = '/khoa-luyen-thi'}{/if}
                {if !preg_match('/^(https?:)?\/\//', $link) && substr($link, 0, 1) != '/'}{$link = "/{$link}"}{/if}
                <article class="mlr-stage" id="chang-{$stage@iteration}" aria-labelledby="stage-title-{$stage@iteration}">
                    <div class="mlr-stage-copy">
                        <span class="mlr-number" aria-hidden="true">{$stage@iteration|string_format:'%02d'}</span>
                        <div>
                            <p class="mlr-eyebrow">{$stage.description_short|default:'LỘ TRÌNH MEDUC'|escape}</p>
                            <h2 id="stage-title-{$stage@iteration}">{$stage.name|escape}</h2>
                            {if !empty($stage.description)}<p class="mlr-description">{$stage.description|escape|nl2br}</p>{/if}
                            <a class="mlr-stage-link" href="{$link|escape}">{if $link == '/khoa-luyen-thi'}Tìm môn luyện thi{else}Tìm khóa học phù hợp{/if}<span aria-hidden="true">→</span></a>
                        </div>
                    </div>
                    <div class="mlr-visual{if $picture == ''} mlr-visual--type{/if}">
                        {if $picture != ''}<img src="{$picture|escape}" alt="" loading="lazy" decoding="async">
                        {else}<span>HỌC.<br>LUYỆN.<br>HIỂU SÂU.</span>{/if}
                    </div>
                </article>
            {/if}
        {/foreach}
    </section>

    <section class="mlr-shell mlr-outro" aria-labelledby="roadmap-next-title">
        <div><p class="mlr-eyebrow">LỘ TRÌNH ĐI CÙNG PHƯƠNG PHÁP</p><h2 id="roadmap-next-title">BIẾT HỌC GÌ.<br><span>HIỂU CÁCH HỌC.</span></h2><p>Tìm hiểu Core Learning và những người đồng hành cùng bạn trong từng buổi học.</p></div>
        <div class="mlr-outro-links"><a class="mlr-button" href="/phuong-phap-hoc">Phương pháp học tại MedUC <span aria-hidden="true">→</span></a><a class="mlr-stage-link" href="/doi-ngu-giang-vien">Gặp đội ngũ giảng viên <span aria-hidden="true">→</span></a></div>
    </section>
</main>
{/strip}
