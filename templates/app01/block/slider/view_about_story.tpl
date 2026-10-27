{strip}
{* The original founder story is the slider description, preserved in full. Other copy and the portrait use this block's existing extended data. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$website = $this->Setting->getWebsiteInfo()}
{$meduc_brand = !empty($website.company_logo) && strpos($website.company_logo, '/templates/app01/assets/meduc-v2/brand/meduc-') === 0}
{$founder_photo = ''}
{if !empty($text.anh_nguoi_sang_lap)}{$founder_photo = $this->Utilities->replaceVariableSystem($text.anh_nguoi_sang_lap)}{/if}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/about-page.css?v=20261028-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/about-page.js?v=20261015" defer></script>

<main class="mab" id="meduc-about">
    <section class="mab-shell mab-hero" aria-labelledby="about-title">
        <div class="mab-hero-copy">
            <p class="mab-eyebrow">VỀ MEDUC <span aria-hidden="true">/</span> TỪ MỘT TRẢI NGHIỆM THẬT</p>
            <h1 id="about-title">{$text.hero_tieu_de_1|default:'HỌC Y CÓ'|escape}<span>{$text.hero_tieu_de_2|default:'NGƯỜI ĐỒNG HÀNH.'|escape}</span></h1>
            <p class="mab-hero-lead">{$text.hero_mo_ta|default:'MedUC ra đời từ sự thấu hiểu những khó khăn của người học Y. Bởi chính người sáng lập cũng từng chật vật, mất gốc và có lúc muốn dừng lại.'|escape}</p>
            <a class="mab-button mab-button--primary" href="#khoi-nguon">Khám phá câu chuyện <span aria-hidden="true">↓</span></a>
            <p class="mab-hero-note">Từ thấu hiểu người học, đến một nơi học Y cùng nhau.</p>
        </div>
        <figure class="mab-founder">
            <div class="mab-founder-photo">{if $founder_photo != ''}<img src="{$founder_photo|escape}" alt="{$text.nguoi_sang_lap|default:'BS Ngô Nghĩa Đức'|escape}, người sáng lập MedUC" fetchpriority="high" decoding="async" />{/if}</div>
            <figcaption><div><strong>{$text.nguoi_sang_lap|default:'BS Ngô Nghĩa Đức'|escape}</strong><span>Người sáng lập &amp; quản lý MedUC</span></div><span class="mab-founder-caption" aria-hidden="true">CÂU CHUYỆN<br>CỦA CHÚNG TÔI</span></figcaption>
        </figure>
    </section>

    <nav class="mab-chapters" aria-label="Các phần trong câu chuyện MedUC">
        <div class="mab-shell mab-chapters-inner">
            <span class="mab-chapters-label">CÂU CHUYỆN MEDUC</span>
            <div class="mab-chapters-links">
                <a href="#khoi-nguon" aria-current="location"><span>01</span> Khởi nguồn</a>
                <a href="#ten-goi"><span>02</span> Tên gọi</a>
                <a href="#tam-nhin"><span>03</span> Tầm nhìn &amp; sứ mệnh</a>
                <a href="#gia-tri"><span>04</span> Giá trị cốt lõi</a>
                <a href="#tuong-lai"><span>05</span> Tương lai</a>
            </div>
        </div>
    </nav>

    <section class="mab-section mab-shell mab-origin" id="khoi-nguon" aria-labelledby="origin-title" data-about-chapter>
        <div class="mab-origin-aside">
            <p class="mab-eyebrow">01 / SỰ HÌNH THÀNH</p>
            <h2 id="origin-title">BẮT ĐẦU TỪ<br><span>SỰ THẤU HIỂU.</span></h2>
            <p>Trước khi tạo nên MedUC,<br>chúng tôi cũng là người học.</p>
            <div class="mab-byline"><span aria-hidden="true">NĐ</span><div><strong>{$text.nguoi_sang_lap|default:'BS Ngô Nghĩa Đức'|escape}</strong><small>Người sáng lập MedUC</small></div></div>
        </div>
        <div class="mab-story">
            {foreach from = $data_block item = story}
                {if empty($story.description)}{continue}{/if}
                {foreach from = preg_split('/\R\s*\R/u', $story.description) item = paragraph key = paragraph_index}
                    {$paragraph = $paragraph|trim}
                    {if $paragraph == ''}{continue}{/if}
                    {if !empty($text.cau_hoi_khoi_nguon) && strpos($paragraph, $text.cau_hoi_khoi_nguon) !== false}
                        {$parts = explode($text.cau_hoi_khoi_nguon, $paragraph, 2)}
                        <p>{$parts[0]|regex_replace:'/[“"]\s*$/u':''|trim|escape}</p>
                        <blockquote><p>“{$text.cau_hoi_khoi_nguon|escape}”</p></blockquote>
                        <p>{$parts[1]|regex_replace:'/^[”"]\s*/u':''|trim|escape}</p>
                    {else}
                        <p{if $paragraph_index == 0} class="mab-story-opening"{/if}>{$paragraph|escape}</p>
                    {/if}
                {/foreach}
            {/foreach}
            <div class="mab-story-signoff"><span>MEDUC</span><p>Học Y bứt phá cùng ThS – BSNT.</p></div>
        </div>
    </section>

    <section class="mab-section mab-name" id="ten-goi" aria-labelledby="name-title" data-about-chapter>
        <div class="mab-shell">
            <div class="mab-section-heading">
                {if !empty($website.company_logo)}
                    <div class="mab-name-logo">
                        <img{if $meduc_brand} class="mab-name-wordmark--light"{/if} src="{$this->Utilities->getWebsiteImageUrl($website.company_logo)|escape}" alt="MedUC" loading="lazy" decoding="async" />
                        {if $meduc_brand}<img class="mab-name-wordmark--dark" src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/brand/meduc-khai-mo-dark.svg" alt="MedUC" loading="lazy" decoding="async" />{/if}
                    </div>
                {/if}
                <p class="mab-eyebrow">02 / MỘT CÁI TÊN, MỘT ĐỊNH HƯỚNG</p><h2 id="name-title">MEDUC<br><span>NGHĨA LÀ GÌ?</span></h2><p>MEDICAL · ULTIMATE · CENTER</p>
            </div>
            <div class="mab-name-grid">
                <article><span class="mab-letter">MED</span><h3>Medical</h3><p>{$text.ten_goi_med|default:'Chuyên sâu lĩnh vực Y khoa.'|escape}</p></article>
                <article><span class="mab-letter">U</span><h3>Ultimate</h3><p>{$text.ten_goi_u|default:'Cung cấp chất lượng cao cấp nhất.'|escape}</p></article>
                <article><span class="mab-letter">C</span><h3>Center</h3><p>{$text.ten_goi_c|default:'Trung tâm đào tạo toàn diện.'|escape}</p></article>
            </div>
        </div>
    </section>

    <section class="mab-section mab-shell" id="tam-nhin" aria-labelledby="vision-title" data-about-chapter>
        <div class="mab-section-heading"><p class="mab-eyebrow">03 / ĐIỀU MEDUC HƯỚNG TỚI</p><h2 id="vision-title">VỮNG KIẾN THỨC.<br><span>VỮNG BƯỚC NGHỀ Y.</span></h2></div>
        <div class="mab-vision-grid">
            <article><span class="mab-small-number">01 / TẦM NHÌN</span><h3>{$text.tam_nhin_tieu_de|default:'Một nơi học Y đáng tin cậy.'|escape}</h3><p>{$text.tam_nhin|default:''|escape}</p></article>
            <article><span class="mab-small-number">02 / SỨ MỆNH</span><h3>{$text.su_menh_tieu_de|default:'Trao kiến thức. Chia sẻ kinh nghiệm.'|escape}</h3><p>{$text.su_menh|default:''|escape}</p></article>
        </div>
    </section>

    <section class="mab-section mab-values" id="gia-tri" aria-labelledby="values-title" data-about-chapter>
        <div class="mab-shell">
            <div class="mab-values-heading"><div><p class="mab-eyebrow">04 / NHỮNG ĐIỀU MEDUC GIỮ VỮNG</p><h2 id="values-title">SÁU GIÁ TRỊ.<br><span>MỘT TINH THẦN.</span></h2></div><p>Những giá trị cốt lõi của MedUC,<br>trong giảng dạy và trong cách đồng hành.</p></div>
            <div class="mab-values-grid">
                {for $i = 1 to 6}
                    {$value_key = "gia_tri_{$i}"}
                    {if !empty($text.$value_key)}<article><span class="mab-small-number">0{$i}</span><h3>{$text.$value_key|escape}</h3></article>{/if}
                {/for}
            </div>
        </div>
    </section>

    <section class="mab-section mab-shell mab-future" id="tuong-lai" aria-labelledby="future-title" data-about-chapter>
        <div class="mab-section-heading"><p class="mab-eyebrow">05 / ĐỊNH HƯỚNG PHÁT TRIỂN</p><h2 id="future-title">KHÔNG NGỪNG HỌC HỎI.<br><span>KHÔNG NGỪNG PHÁT TRIỂN.</span></h2><p>{$text.tuong_lai_mo_ta|default:'Lấy người học làm trung tâm, tiếp tục đầu tư vào đội ngũ giảng viên và phương pháp dạy học là định hướng phát triển của MedUC.'|escape}</p></div>
        <div class="mab-future-grid">
            <article><span class="mab-small-number">01</span><h3>{$text.tuong_lai_1_tieu_de|default:'Đầu tư vào người dạy'|escape}</h3><p>{$text.tuong_lai_1|default:'Tiếp tục đầu tư vào giảng viên, chuyên môn và kinh nghiệm giảng dạy.'|escape}</p></article>
            <article><span class="mab-small-number">02</span><h3>{$text.tuong_lai_2_tieu_de|default:'Hoàn thiện cách học'|escape}</h3><p>{$text.tuong_lai_2|default:'Phát triển phương pháp dạy học, hệ thống kiến thức từ nền tảng đến chuyên sâu.'|escape}</p></article>
            <article><span class="mab-small-number">03</span><h3>{$text.tuong_lai_3_tieu_de|default:'Đồng hành cùng người học'|escape}</h3><p>{$text.tuong_lai_3|default:'Lắng nghe khó khăn của học viên, nâng cao chất lượng và dịch vụ hỗ trợ học tập.'|escape}</p></article>
        </div>
    </section>

    <section class="mab-outro">
        <div class="mab-shell mab-outro-inner">
            <div><p class="mab-eyebrow">BƯỚC TIẾP CÙNG MEDUC</p><h2>ĐI CÙNG NHAU.<br><span>TIẾN XA HƠN.</span></h2><p>Gặp gỡ người hướng dẫn và tìm lộ trình học phù hợp với bạn.</p></div>
            <div class="mab-outro-actions"><a class="mab-button mab-button--primary" href="/khoa-hoc">Học thử miễn phí <span aria-hidden="true">→</span></a><a class="mab-button mab-button--outline" href="/doi-ngu-giang-vien">Gặp gỡ đội ngũ <span aria-hidden="true">↗</span></a><a class="mab-feedback-link" href="/phan-hoi-hoc-vien">Lắng nghe cảm nhận của học viên <span aria-hidden="true">→</span></a>{if !empty($website.hotline)}<a class="mab-hotline" href="tel:{$website.hotline|escape}">Cần tư vấn? {$website.hotline|escape}</a>{/if}</div>
        </div>
    </section>
</main>
{/strip}
