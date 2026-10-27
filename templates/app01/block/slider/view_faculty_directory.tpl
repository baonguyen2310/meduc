{strip}
{* Dedicated faculty page. Items start from the homepage's gvrail list; their images, descriptions and credentials are editable in this block. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty.css?v=20261015-2" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/feedback-page.css?v=20261015" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-page.css?v=20261028-3" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-page.js?v=20261028-1" defer></script>

<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-application.css?v=20261028-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-application.js?v=20261028-1" defer></script>

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
    </section>

    <nav class="mft-section-nav" aria-label="Nội dung trang giảng viên" data-faculty-sections>
        <div class="mft-shell mft-section-links">
            <a href="#tieu-chuan-tuyen-chon" aria-current="location"><span class="mft-section-index" aria-hidden="true">01</span><strong>Tiêu chuẩn tuyển chọn</strong><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6"/></svg></a>
            <a href="#quy-trinh-tuyen-chon"><span class="mft-section-index" aria-hidden="true">02</span><strong>Quy trình tuyển chọn</strong><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6"/></svg></a>
            <a href="#doi-ngu"><span class="mft-section-index" aria-hidden="true">03</span><strong>Đội ngũ giảng viên</strong><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6"/></svg></a>
            <a href="#ung-tuyen"><span class="mft-section-index" aria-hidden="true">04</span><strong>Tham gia ứng tuyển</strong><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6"/></svg></a>
        </div>
    </nav>

    <section class="mfb mfb-perks mft-selection" id="tieu-chuan-tuyen-chon" aria-labelledby="faculty-standards-title">
        <div class="mfb-shell">
            <div class="mfb-heading">
                <div>
                    <p class="mfb-kicker">{$text.tuyen_chon_nhan|default:'TIÊU CHUẨN TUYỂN CHỌN'|escape}</p>
                    {$standards_title = $text.tuyen_chon_tieu_de|default:'Chọn người dạy. Chọn chất lượng.'}
                    {$standards_title_parts = explode('. ', $standards_title, 2)}
                    <h2 class="mfb-title" id="faculty-standards-title">{$standards_title_parts[0]|escape|upper}{if count($standards_title_parts) > 1}.<br><span>{$standards_title_parts[1]|escape|upper}</span>{/if}</h2>
                </div>
                <p class="mfb-intro">{$text.tuyen_chon_mo_ta|default:'MedUC không tuyển sinh viên hoặc bác sĩ vừa tốt nghiệp làm giảng viên. Chúng tôi lựa chọn những người có nền tảng chuyên môn, kinh nghiệm và khả năng truyền đạt phù hợp với người học.'|escape}</p>
            </div>
            <ol class="mfb-perk-grid mft-standards-cards">
                <li class="mfb-perk"><span class="mfb-perk-figure" aria-hidden="true">01</span><h3 class="mfb-perk-title">Nền tảng chuyên môn</h3><p class="mfb-perk-text">Hồ sơ đào tạo, bằng cấp và lĩnh vực chuyên môn được xem xét khi tuyển chọn.</p></li>
                <li class="mfb-perk"><span class="mfb-perk-figure" aria-hidden="true">02</span><h3 class="mfb-perk-title">Kinh nghiệm thực tế</h3><p class="mfb-perk-text">Kinh nghiệm giảng dạy, nghiên cứu hoặc thực hành giúp kiến thức gắn với nghề Y.</p></li>
                <li class="mfb-perk"><span class="mfb-perk-figure" aria-hidden="true">03</span><h3 class="mfb-perk-title">Khả năng đồng hành</h3><p class="mfb-perk-text">Giải thích rõ ràng, hướng dẫn có lộ trình và tận tâm giải đáp cho người học.</p></li>
            </ol>
        </div>
    </section>

    <section class="mft-process" id="quy-trinh-tuyen-chon" aria-labelledby="faculty-process-title">
        <div class="mft-shell">
            <div class="mft-process-heading">
                <div><p class="mft-kicker">TỪ HỒ SƠ ĐẾN BÀI GIẢNG</p><h2 id="faculty-process-title">QUY TRÌNH<br><span>TUYỂN CHỌN.</span></h2></div>
                <p>Đánh giá người dạy từ nền tảng chuyên môn, kinh nghiệm thực tế đến cách truyền đạt và đồng hành cùng học viên.</p>
            </div>
            <ol class="mft-process-steps">
                <li><span class="mft-process-number" aria-hidden="true">01</span><div class="mft-process-detail"><h3>Hồ sơ &amp; bằng cấp</h3><p>Xem xét chuyên ngành đào tạo, bằng cấp và kinh nghiệm giảng dạy hoặc thực hành.</p></div></li>
                <li><span class="mft-process-number" aria-hidden="true">02</span><div class="mft-process-detail"><h3>Trao đổi chuyên môn</h3><p>Trao đổi về kiến thức trọng tâm, cách tiếp cận môn học và những khó khăn thường gặp của sinh viên.</p></div></li>
                <li><span class="mft-process-number" aria-hidden="true">03</span><div class="mft-process-detail"><h3>Giảng dạy thử</h3><p>Đánh giá cách giải thích khái niệm, kết nối kiến thức với tình huống thực tế và giải đáp câu hỏi.</p></div></li>
                <li><span class="mft-process-number" aria-hidden="true">04</span><div class="mft-process-detail"><h3>Đồng hành &amp; cải tiến</h3><p>Lắng nghe phản hồi học viên, trao đổi với giảng viên để hoàn thiện nội dung và cách giảng dạy.</p></div></li>
            </ol>
        </div>
    </section>

    <section class="mgv mft-directory" id="doi-ngu" data-faculty-view="list" data-faculty-expanded="false" aria-labelledby="faculty-list-title">
        <div class="mft-shell mft-directory-heading">
            <div><p class="mgv-kicker">{$text.tieu_de_phu|default:'CON NGƯỜI MEDUC'|escape}</p><h2 class="mgv-title" id="faculty-list-title">{$text.tieu_de|default:'Đội Ngũ Giảng Viên Và Cố Vấn'|escape}</h2><p class="mft-directory-intro">Chọn một hồ sơ để xem chuyên môn, kinh nghiệm và bằng cấp.</p></div>
            {if !empty($data_block)}
                <div class="mft-directory-tools">
                    <span class="mft-directory-count" data-faculty-count aria-live="polite">{if count($data_block) > 6}6 / {/if}{count($data_block)} giảng viên &amp; cố vấn</span>
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
            {if count($data_block) > 6}
                <div class="mft-shell mft-load-more" data-faculty-more-wrap>
                    <button class="mft-button mft-button--primary" type="button" data-faculty-more aria-controls="faculty-list" aria-expanded="false">Xem thêm <span aria-hidden="true">↓</span></button>
                </div>
            {/if}
        {else}<p class="mft-shell mft-empty">Thông tin đội ngũ đang được cập nhật.</p>{/if}
    </section>

    <section class="mft-application" id="ung-tuyen" aria-labelledby="faculty-application-title">
        <div class="mft-shell mft-application-layout">
            <div class="mft-application-copy">
                <p class="mft-kicker">04 / THAM GIA ỨNG TUYỂN</p>
                <h2 id="faculty-application-title">Mang tri thức.<br><span>Truyền cảm hứng.</span></h2>
                <p class="mft-application-lead">Bạn có chuyên môn vững và tâm huyết với việc giảng dạy? Cùng MedUC giúp người học Y hiểu sâu hơn, học tốt hơn.</p>
                <ol class="mft-application-steps">
                    <li><div><strong>Chia sẻ chuyên môn</strong><p>Cho chúng tôi biết thế mạnh và kinh nghiệm của bạn.</p></div></li>
                    <li><div><strong>Gửi hồ sơ của bạn</strong><p>Đính kèm CV, bằng cấp hoặc tài liệu giới thiệu năng lực.</p></div></li>
                    <li><div><strong>Kết nối cùng MedUC</strong><p>Đội ngũ xem xét hồ sơ và liên hệ để trao đổi thêm.</p></div></li>
                </ol>
            </div>
            <div class="mft-application-card">
                <form action="/giang-vien/ung-tuyen" method="post" enctype="multipart/form-data" data-faculty-application-form>
                    <h3>Hồ sơ ứng tuyển</h3>
                    <p class="mft-application-note">Dấu * là thông tin bắt buộc.</p>
                    <input type="hidden" name="_csrfToken" value="{$this->getRequest()->getAttribute('csrfToken')|escape}">
                    <input type="hidden" name="submission_token" value="">
                    <div class="mft-application-hp" aria-hidden="true"><label for="fa-website">Để trống ô này</label><input id="fa-website" name="company_website" type="text" tabindex="-1" autocomplete="off"></div>
                    <div class="mft-application-message" role="alert" data-application-message></div>
                    <div class="mft-application-fields">
                        <div class="mft-application-field"><label for="fa-name">Họ và tên *</label><input id="fa-name" name="full_name" type="text" autocomplete="name" minlength="2" maxlength="160" placeholder="Họ tên của bạn" required></div>
                        <div class="mft-application-field"><label for="fa-email">Email *</label><input id="fa-email" name="email" type="email" autocomplete="email" maxlength="254" placeholder="Email liên hệ" required></div>
                        <div class="mft-application-field"><label for="fa-phone">Số điện thoại *</label><input id="fa-phone" name="phone" type="tel" autocomplete="tel" maxlength="30" placeholder="Số điện thoại liên hệ" required></div>
                        <div class="mft-application-field"><label for="fa-qualification">Trình độ chuyên môn *</label><select id="fa-qualification" name="qualification" required><option value="">Chọn trình độ</option><option>Thạc sĩ</option><option>Bác sĩ nội trú</option><option>Chuyên khoa I</option><option>Chuyên khoa II</option><option>Tiến sĩ</option><option>Khác</option></select></div>
                        <div class="mft-application-field mft-application-field--wide"><label for="fa-specialty">Chuyên môn / môn muốn giảng dạy *</label><input id="fa-specialty" name="specialty" type="text" maxlength="200" placeholder="Ví dụ: Giải phẫu, Sinh lý, Nội khoa…" required></div>
                        <div class="mft-application-field"><label for="fa-workplace">Nơi công tác <span>(không bắt buộc)</span></label><input id="fa-workplace" name="workplace" type="text" autocomplete="organization" maxlength="255" placeholder="Bệnh viện, trường hoặc đơn vị"></div>
                        <div class="mft-application-field"><label for="fa-experience">Số năm kinh nghiệm <span>(không bắt buộc)</span></label><input id="fa-experience" name="experience_years" type="number" min="0" max="60" step="1" placeholder="Số năm"></div>
                        <div class="mft-application-field mft-application-field--wide"><label for="fa-intro">Giới thiệu &amp; kinh nghiệm *</label><textarea id="fa-intro" name="introduction" rows="5" minlength="20" maxlength="5000" placeholder="Chia sẻ kinh nghiệm chuyên môn, giảng dạy và mong muốn khi đồng hành cùng MedUC…" required></textarea></div>
                        <div class="mft-application-field mft-application-field--wide"><label for="fa-portfolio">Liên kết hồ sơ / bài giảng <span>(không bắt buộc)</span></label><input id="fa-portfolio" name="portfolio_url" type="url" maxlength="500" placeholder="https://..."></div>
                        <div class="mft-application-field mft-application-field--wide">
                            <label for="fa-files">File đính kèm <span>(không bắt buộc)</span></label>
                            <div class="mft-application-upload" data-application-drop>
                                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 16V3m-5 5 5-5 5 5M4 15v5a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-5"/></svg>
                                <p>CV, bằng cấp hoặc hồ sơ chuyên môn<br>PDF, Word, JPG, PNG, WebP · Tối đa 5 file, 10 MB/file</p>
                                <input class="mft-application-file-input" id="fa-files" type="file" name="attachments[]" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.webp" multiple tabindex="-1" data-application-files>
                                <button type="button" class="mft-application-pick" data-application-pick>Chọn file đính kèm +</button>
                            </div>
                            <ul class="mft-application-files" data-application-file-list></ul>
                            <p class="mft-application-file-count" aria-live="polite" data-application-file-count>Đã chọn 0/5 file</p>
                        </div>
                    </div>
                    <p class="mft-application-privacy">Thông tin và hồ sơ của bạn chỉ được dùng để tiếp nhận, xem xét ứng tuyển và liên hệ trao đổi. <a href="/chinh-sach-bao-mat-thong-tin">Chính sách bảo mật</a>.</p>
                    <button type="submit" class="mft-button mft-button--primary mft-application-submit"><span data-application-submit-label style="font-size:14px">Gửi hồ sơ ứng tuyển</span><span aria-hidden="true">→</span></button>
                    <noscript><p>Vui lòng bật JavaScript để gửi hồ sơ và quản lý file đính kèm.</p></noscript>
                </form>
                <div class="mft-application-success" data-application-success hidden tabindex="-1" role="status">
                    <svg viewBox="0 0 48 48" aria-hidden="true"><circle cx="24" cy="24" r="21"/><path d="m14 24 7 7 14-15"/></svg>
                    <h3>Cảm ơn bạn đã ứng tuyển!</h3>
                    <p>MedUC đã nhận hồ sơ của bạn.<br>Đội ngũ sẽ xem xét và liên hệ qua email hoặc số điện thoại đã cung cấp.</p>
                    <span class="mft-application-reference" data-application-reference></span>
                </div>
            </div>
        </div>
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
