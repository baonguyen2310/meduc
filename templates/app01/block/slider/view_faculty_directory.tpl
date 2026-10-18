{strip}
{* Dedicated faculty page. Items start from the homepage's gvrail list; their images, descriptions and credentials are editable in this block. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty.css?v=20261015-2" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-page.css?v=20261018-4" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-page.js?v=20261018" defer></script>

<main class="mft" id="faculty-page">
    <section class="mft-hero" aria-labelledby="faculty-title">
        <div class="mft-shell mft-hero-layout">
            <div class="mft-hero-copy">
                <p class="mft-kicker">{$text.mo_dau_nhan|default:'ĐỘI NGŨ GIẢNG VIÊN MEDUC'|escape}</p>
                <h1 id="faculty-title">{$text.mo_dau_tieu_de_1|default:'NGƯỜI DẠY VỮNG VÀNG.'|escape}<span>{$text.mo_dau_tieu_de_2|default:'NGƯỜI HỌC VỮNG TIN.'|escape}</span></h1>
                <p class="mft-lead">{$text.mo_dau_mo_ta|default:'Một người thầy giỏi giúp bạn hiểu bản chất, kết nối kiến thức và tự tin hơn trên hành trình học Y.'|escape}</p>
                <a class="mft-button mft-button--primary" href="#doi-ngu">Gặp gỡ đội ngũ <span aria-hidden="true">↓</span></a>
            </div>
            <div class="mft-portraits" aria-hidden="true">
                {foreach from = $data_block item = teacher key = index}
                    {if $index > 2}{break}{/if}
                    {$photo = $teacher.image|default:''}
                    {if $photo == ''}{continue}{/if}
                    {if $teacher.image_source == 'cdn'}{$photo = "{CDN_URL}{$this->Utilities->getThumbs($teacher.image, 720)}"}{/if}
                    <div class="mft-portrait mft-portrait--{$index}"><img src="{$photo|escape}" alt="" decoding="async" fetchpriority="{if $index == 0}high{else}auto{/if}" /></div>
                {/foreach}
                <span class="mft-portrait-caption">CHUYÊN MÔN VỮNG. ĐỒNG HÀNH TẬN TÂM.</span>
            </div>
        </div>
        <div class="mft-shell mft-selection">
            <div class="mft-selection-intro">
                <p class="mft-kicker">{$text.tuyen_chon_nhan|default:'TIÊU CHUẨN TUYỂN CHỌN'|escape}</p>
                <h2>{$text.tuyen_chon_tieu_de|default:'Chọn người dạy. Chọn chất lượng.'|escape}</h2>
                <p>{$text.tuyen_chon_mo_ta|default:'MedUC không tuyển sinh viên hoặc bác sĩ vừa tốt nghiệp làm giảng viên. Chúng tôi lựa chọn những người có nền tảng chuyên môn, kinh nghiệm và khả năng truyền đạt phù hợp với người học.'|escape}</p>
            </div>
            <ol class="mft-standards">
                <li><span class="mft-standard-number">01</span><div><h3>Nền tảng chuyên môn</h3><p>Hồ sơ đào tạo, bằng cấp và lĩnh vực chuyên môn được xem xét khi tuyển chọn.</p></div></li>
                <li><span class="mft-standard-number">02</span><div><h3>Kinh nghiệm thực tế</h3><p>Kinh nghiệm giảng dạy, nghiên cứu hoặc thực hành giúp kiến thức gắn với nghề Y.</p></div></li>
                <li><span class="mft-standard-number">03</span><div><h3>Khả năng đồng hành</h3><p>Giải thích rõ ràng, hướng dẫn có lộ trình và tận tâm giải đáp cho người học.</p></div></li>
            </ol>
        </div>
    </section>

    <section class="mft-process" id="quy-trinh-tuyen-chon" aria-labelledby="faculty-process-title">
        <div class="mft-shell">
            <div class="mft-process-heading">
                <div><p class="mft-kicker">TỪ HỒ SƠ ĐẾN BÀI GIẢNG</p><h2 id="faculty-process-title">Quy trình tuyển chọn</h2></div>
                <p>Đánh giá người dạy từ nền tảng chuyên môn, kinh nghiệm thực tế đến cách truyền đạt và đồng hành cùng học viên.</p>
            </div>
            <ol class="mft-process-steps">
                <li><span class="mft-process-number" aria-hidden="true">01</span><div><h3>Hồ sơ &amp; bằng cấp</h3><p>Xem xét chuyên ngành đào tạo, bằng cấp và kinh nghiệm giảng dạy hoặc thực hành.</p></div></li>
                <li><span class="mft-process-number" aria-hidden="true">02</span><div><h3>Trao đổi chuyên môn</h3><p>Trao đổi về kiến thức trọng tâm, cách tiếp cận môn học và những khó khăn thường gặp của sinh viên.</p></div></li>
                <li><span class="mft-process-number" aria-hidden="true">03</span><div><h3>Giảng dạy thử</h3><p>Đánh giá cách giải thích khái niệm, kết nối kiến thức với tình huống thực tế và giải đáp câu hỏi.</p></div></li>
                <li><span class="mft-process-number" aria-hidden="true">04</span><div><h3>Đồng hành &amp; cải tiến</h3><p>Lắng nghe phản hồi học viên, trao đổi với giảng viên để hoàn thiện nội dung và cách giảng dạy.</p></div></li>
            </ol>
        </div>
    </section>

    <section class="mgv mft-directory" id="doi-ngu" data-faculty-view="list" aria-labelledby="faculty-list-title">
        <div class="mft-shell mft-directory-heading">
            <div><p class="mgv-kicker">{$text.tieu_de_phu|default:'CON NGƯỜI MEDUC'|escape}</p><h2 class="mgv-title" id="faculty-list-title">{$text.tieu_de|default:'Đội Ngũ Giảng Viên Và Cố Vấn'|escape}</h2><p class="mft-directory-intro">Chọn một hồ sơ để xem chuyên môn, kinh nghiệm và bằng cấp.</p></div>
            {if !empty($data_block)}
                <div class="mft-directory-tools">
                    <span class="mft-directory-count">{count($data_block)} giảng viên &amp; cố vấn</span>
                    <div class="mft-layout-switch" role="group" aria-label="Cách hiển thị đội ngũ giảng viên" data-faculty-layout-switch hidden>
                        <button type="button" data-faculty-layout="list" aria-pressed="true" aria-label="Dạng danh sách" aria-controls="faculty-list" title="Dạng danh sách"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="4" width="4" height="4" rx="1"/><rect x="3" y="10" width="4" height="4" rx="1"/><rect x="3" y="16" width="4" height="4" rx="1"/><path d="M11 6h10M11 12h10M11 18h10"/></svg></button>
                        <button type="button" data-faculty-layout="grid" aria-pressed="false" aria-label="Dạng lưới" aria-controls="faculty-list" title="Dạng lưới"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></svg></button>
                    </div>
                </div>
            {/if}
        </div>
        {if !empty($data_block)}
            <div class="mft-shell mft-grid" id="faculty-list">
                {$this->element('faculty/cards', ['data_block' => $data_block, 'profile_mode' => true])}
            </div>
        {else}<p class="mft-shell mft-empty">Thông tin đội ngũ đang được cập nhật.</p>{/if}
    </section>

    <section class="mft-shell mft-outro">
        <div><p class="mft-kicker">BƯỚC TIẾP CÙNG MEDUC</p><h2>Tìm người hướng dẫn.<br>Chọn hành trình của bạn.</h2></div>
        <a class="mft-button mft-button--primary" href="/khoa-hoc">Học thử miễn phí <span aria-hidden="true">→</span></a>
    </section>

    <dialog class="mft-modal" id="faculty-profile-dialog" aria-labelledby="mft-profile-title">
        <button class="mft-modal-close" type="button" data-faculty-close aria-label="Đóng hồ sơ" autofocus><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg></button>
        <div class="mft-dossier" data-faculty-content></div>
    </dialog>
</main>
{/strip}
