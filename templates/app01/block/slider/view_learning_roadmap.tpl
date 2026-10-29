{strip}
{* The stages keep their existing names, images and destinations from the homepage block. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$stages = []}
{foreach from = $data_block item = stage}{if !empty($stage.name)}{$stages[] = $stage}{/if}{/foreach}
{$path_copy = [
    ['title_1' => 'XÂY CHẮC.', 'title_2' => 'NỀN TẢNG.', 'audience' => 'Sinh viên năm 1–2; người cần củng cố nền tảng.', 'entry' => 'Khởi đầu từ kiến thức nhập môn.', 'goal' => 'Hiểu và kết nối Giải phẫu, Sinh lý, Hoá sinh.', 'button' => 'Xem khóa học cơ sở', 'photo_note' => 'HIỂU TỪ GỐC.'],
    ['title_1' => 'KẾT NỐI.', 'title_2' => 'LÂM SÀNG.', 'audience' => 'Sinh viên năm 3–4, bắt đầu học lâm sàng.', 'entry' => 'Tiếp nối các môn Y học cơ sở.', 'goal' => 'Vận dụng kiến thức vào tình huống lâm sàng.', 'button' => 'Xem khóa học lâm sàng', 'photo_note' => 'HỌC ĐỂ VẬN DỤNG.'],
    ['title_1' => 'ĐI SÂU.', 'title_2' => 'CHUYÊN MÔN.', 'audience' => 'Người đã tốt nghiệp, ôn Nội trú – Sau đại học.', 'entry' => 'Vững kiến thức cơ sở và lâm sàng.', 'goal' => 'Đào sâu kiến thức, ôn theo mục tiêu thi.', 'button' => 'Xem khóa học chuyên sâu', 'photo_note' => 'VỮNG BƯỚC TIẾP THEO.']
]}
{$hero_picture = $this->Utilities->replaceVariableSystem($text.anh_mo_dau|default:'/templates/app01/assets/meduc-v2/feedback/hoc-vien-meduc.jpg')}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/roadmap-page.css?v=20261028-2" rel="stylesheet">

<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/roadmap-nav.css?v=20261028-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/roadmap-nav.js?v=20261028-1" defer></script>

<main class="mlr" id="meduc-roadmap">
    <section class="mlr-hero" aria-labelledby="roadmap-title">
        <div class="mlr-shell mlr-hero-inner">
            <div class="mlr-hero-copy">
                <p class="mlr-eyebrow">LỘ TRÌNH HỌC · MEDUC</p>
                <h1 id="roadmap-title">{$text.tieu_de_1|default:'TỪ CƠ BẢN.'|escape}<span>{$text.tieu_de_2|default:'ĐẾN CHUYÊN SÂU.'|escape}</span></h1>
                <p class="mlr-lead">Chọn đúng điểm bắt đầu. Học chắc nền tảng, rồi đi sâu từng chặng.</p>
                <div class="mlr-hero-actions"><a class="mlr-button" href="#cac-chang-hoc">Chọn chặng học <span aria-hidden="true">↓</span></a><a class="mlr-button mlr-button--secondary" href="/phuong-phap-hoc">Cách học tại MedUC</a></div>
            </div>
            <figure class="mlr-hero-picture">
                <img src="{$hero_picture|escape}" alt="Sinh viên Y cùng tìm hiểu tài liệu học tập" fetchpriority="high" decoding="async">
                <figcaption class="mlr-hero-badge"><strong>3 CHẶNG HỌC.</strong><span>Một hành trình học Y.</span></figcaption>
            </figure>
        </div>
    </section>

    <nav class="mlr-jump" aria-label="Các chặng trong lộ trình">
        <div class="mlr-shell">
            {foreach from = $stages item = stage}
                <a href="#chang-{$stage@iteration}">{if $stage@iteration == 4}<span aria-hidden="true">↗</span>{else}<span>{$stage@iteration|string_format:'%02d'}</span>{/if}{$stage.name|escape}</a>
            {/foreach}
        </div>
    </nav>

    <section class="mlr-paths" id="cac-chang-hoc" aria-labelledby="roadmap-stages-title">
        <div class="mlr-shell mlr-section-heading">
            <div><p class="mlr-eyebrow">ĐIỂM BẮT ĐẦU CỦA BẠN</p><h2 id="roadmap-stages-title">BẠN ĐANG Ở ĐÂU?<br><span>BẮT ĐẦU TỪ ĐÓ.</span></h2></div>
            <p>Chọn theo nền tảng hiện có.</p>
        </div>
        {foreach from = $stages item = stage key = stage_index}
            {if $stage_index < 3}
                {$copy = $path_copy[$stage_index]}
                {$picture = '/templates/app01/assets/meduc-v2/feedback/hoc-vien-meduc.jpg'}
                {if !empty($stage.image)}
                    {if $stage.image_source == 'cdn'}{$picture = "{CDN_URL}{$this->Utilities->getThumbs($stage.image, 720)}"}
                    {else}{$picture = $stage.image}{/if}
                {/if}
                {$link = $stage.url|default:'/khoa-hoc'|trim}
                {if !preg_match('/^(https?:)?\/\//', $link) && substr($link, 0, 1) != '/'}{$link = "/{$link}"}{/if}
                <article class="mlr-stage {if $stage_index == 1}mlr-stage--reverse{/if}" id="chang-{$stage@iteration}" aria-labelledby="stage-title-{$stage@iteration}">
                    <div class="mlr-shell mlr-stage-inner">
                        <figure class="mlr-stage-picture">
                            <img src="{$picture|escape}" alt="{$stage.name|escape} – hình ảnh học tập cùng MedUC" loading="lazy" decoding="async">
                            <figcaption><span class="mlr-stage-number">{$stage@iteration|string_format:'%02d'}</span><span>{$copy.photo_note|escape}</span></figcaption>
                        </figure>
                        <div class="mlr-stage-copy">
                            <p class="mlr-eyebrow">{$stage.name|escape} · {$stage.description_short|default:'LỘ TRÌNH MEDUC'|escape}</p>
                            <h3 id="stage-title-{$stage@iteration}">{$copy.title_1|escape}<span>{$copy.title_2|escape}</span></h3>
                            <dl class="mlr-stage-facts">
                                <div><dt>PHÙ HỢP VỚI</dt><dd>{$copy.audience|escape}</dd></div>
                                <div><dt>ĐIỂM BẮT ĐẦU</dt><dd>{$copy.entry|escape}</dd></div>
                                <div><dt>MỤC TIÊU</dt><dd>{$copy.goal|escape}</dd></div>
                            </dl>
                            <a class="mlr-stage-link" href="{$link|escape}">{$copy.button|escape}<span aria-hidden="true">→</span></a>
                        </div>
                    </div>
                </article>
            {/if}
        {/foreach}
    </section>

    <section class="mlr-practice" id="chang-4" aria-labelledby="roadmap-practice-title">
        <img class="mlr-practice-bg" src="/templates/app01/assets/meduc-v2/feedback/lop-lam-sang.jpg" alt="" loading="lazy" decoding="async">
        <div class="mlr-shell mlr-practice-inner">
            <p class="mlr-eyebrow">LUYỆN ĐỀ · Ở MỌI CHẶNG HỌC</p>
            <h2 id="roadmap-practice-title">HỌC ĐẾN ĐÂU.<br><span>LUYỆN ĐẾN ĐÓ.</span></h2>
            <p>Làm bài. Xem lời giải. Ôn phần chưa chắc.</p>
            <ol class="mlr-practice-flow" aria-label="Các bước luyện đề"><li>Chọn môn</li><li>Làm bài tập</li><li>Xem lời giải</li></ol>
            <a class="mlr-button" href="/khoa-chua-de">Chọn môn luyện thi <span aria-hidden="true">→</span></a>
        </div>
    </section>

    <section class="mlr-outro" aria-labelledby="roadmap-next-title">
        <div class="mlr-shell mlr-outro-inner">
            <div><p class="mlr-eyebrow">LỘ TRÌNH ĐI CÙNG PHƯƠNG PHÁP</p><h2 id="roadmap-next-title">BIẾT HỌC GÌ.<br><span>HIỂU CÁCH HỌC.</span></h2><p>Hiểu cách học. Gặp người đồng hành.</p></div>
            <div class="mlr-outro-links"><a class="mlr-button" href="/phuong-phap-hoc">Phương pháp học <span aria-hidden="true">→</span></a><a class="mlr-button mlr-button--secondary" href="/doi-ngu-giang-vien">Đội ngũ giảng viên <span aria-hidden="true">→</span></a></div>
        </div>
    </section>
</main>
{/strip}
