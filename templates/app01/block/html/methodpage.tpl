{strip}
{* Four editorial sections for /phuong-phap-hoc. Existing hero keys remain supported.
   Optional block copy/photos: anh_vi_sao, mo_ta_anh_vi_sao, anh_ap_dung, mo_ta_anh_ap_dung,
   ket_qua_nhan, ket_qua_tieu_de_1,
   ket_qua_tieu_de_2, ket_qua_mo_ta. The fourth section is provisional copy for CEO review. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$picture = $this->Utilities->replaceVariableSystem($text.anh|default:'/templates/app01/assets/meduc-v2/method/study-editorial.jpg')}
{$why_picture = $this->Utilities->replaceVariableSystem($text.anh_vi_sao|default:'/templates/app01/assets/meduc-v2/feedback/hoc-vien-meduc.jpg')}
{$apply_picture = $this->Utilities->replaceVariableSystem($text.anh_ap_dung|default:'/templates/app01/assets/meduc-v2/feedback/lop-lam-sang.jpg')}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/method-page.css?v=20261028-2" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/method-page.js?v=20261028-1" defer></script>

<main class="mmp" id="meduc-method">
    <section class="mmp-shell mmp-hero" aria-labelledby="method-title">
        <div class="mmp-hero-copy">
            <p class="mmp-eyebrow">PHƯƠNG PHÁP HỌC / MEDUC</p>
            <h1 id="method-title">{$text.tieu_de_1|default:'HỌC TỪ CỐT LÕI.'|escape}<span>{$text.tieu_de_2|default:'HIỂU ĐỂ ĐI XA.'|escape}</span></h1>
            <p class="mmp-lead">{$text.mo_ta|default:'Học Y bắt đầu từ điều cần hiểu: bản chất của vấn đề, mối liên hệ giữa các kiến thức và cách vận dụng vào từng câu hỏi, từng tình huống.'|escape}</p>
            <div class="mmp-actions"><a class="mmp-button mmp-button--primary" href="/khoa-hoc">Học thử miễn phí <span aria-hidden="true">→</span></a><a class="mmp-text-link" href="#vi-sao">Xem cách học <span aria-hidden="true">↓</span></a></div>
        </div>
        <figure class="mmp-hero-visual">
            <img src="{$picture|escape}" alt="{$text.mo_ta_anh|default:'Hình minh họa sinh viên trao đổi kiến thức y khoa'|escape}" fetchpriority="high" decoding="async" width="1024" height="1024">
            <figcaption><span>CORE LEARNING</span><p>Từ một câu hỏi.<br>Đến cả một khái niệm.</p></figcaption>
        </figure>
    </section>

    <nav class="mmp-jump" aria-label="Nội dung phương pháp học">
        <div class="mmp-shell mmp-jump-links">
            <a href="#vi-sao" aria-current="location"><span>01</span> Vì sao cần phương pháp</a>
            <a href="#core-learning"><span>02</span> Cách học MedUC</a>
            <a href="#cach-ap-dung"><span>03</span> Áp dụng vào buổi học</a>
            <a href="#dieu-dat-duoc"><span>04</span> Hiểu, giải thích, vận dụng</a>
        </div>
    </nav>

    <section class="mmp-shell mmp-section mmp-editorial" id="vi-sao" aria-labelledby="method-why-title">
        <figure class="mmp-photo mmp-photo--why">
            <img src="{$why_picture|escape}" alt="{$text.mo_ta_anh_vi_sao|default:'Học viên MedUC cùng đọc và trao đổi tài liệu'|escape}" loading="lazy" decoding="async" width="1600" height="1058">
            <figcaption>Kiến thức cần được kết nối.<br>Không chỉ được ghi nhớ.</figcaption>
        </figure>
        <div class="mmp-copy">
            <p class="mmp-eyebrow">01 / VÌ SAO CẦN PHƯƠNG PHÁP</p>
            <h2 id="method-why-title">HỌC RẤT NHIỀU.<br><span>ĐÃ THỰC SỰ HIỂU?</span></h2>
            <p>Kiến thức Y khoa rộng và nhiều chi tiết. Nhớ từng mảnh kiến thức có thể giúp bạn trả lời một câu quen, nhưng chưa đủ để lý giải khi cách hỏi thay đổi.</p>
            <p>Một phương pháp phù hợp giúp bạn nối các ý thành hệ thống, nhận ra phần chưa vững và biết cần học lại ở đâu.</p>
            <p class="mmp-pull">Bắt đầu bằng câu hỏi <strong>“Vì sao?”</strong><br>Để việc ghi nhớ có một nền tảng.</p>
        </div>
    </section>

    <section class="mmp-band" id="core-learning" aria-labelledby="method-core-title">
        <div class="mmp-shell mmp-section">
            <div class="mmp-core-heading">
                <div><p class="mmp-eyebrow">02 / CÁCH HỌC MEDUC</p><h2 id="method-core-title">CORE LEARNING.<br><span>HIỂU TỪ CỐT LÕI.</span></h2></div>
                <p>MedUC bắt đầu từ khái niệm và cơ chế. Từ khóa làm rõ ý chính, Mind Map kết nối các ý; câu hỏi và tình huống giúp bạn tập vận dụng.</p>
            </div>
            <ol class="mmp-core-grid" aria-label="Cách học Core Learning tại MedUC">
                <li><span class="mmp-core-number" aria-hidden="true">01</span><h3>Hiểu từ khái niệm và cơ chế</h3><p>Làm rõ bản chất và trả lời câu hỏi “vì sao”, để việc ghi nhớ chi tiết có một nền tảng.</p></li>
                <li><span class="mmp-core-number" aria-hidden="true">02</span><h3>Nắm ý chính bằng từ khóa</h3><p>Nhận ra những ý trọng tâm của bài học, thay vì ghi chép và học thuộc mọi chi tiết rời rạc.</p></li>
                <li><span class="mmp-core-number" aria-hidden="true">03</span><h3>Kết nối kiến thức bằng Mind Map</h3><p>Hệ thống các ý và mối liên hệ, nối phần đang học với những kiến thức bạn đã biết.</p></li>
                <li><span class="mmp-core-number" aria-hidden="true">04</span><h3>Vận dụng qua câu hỏi, tình huống</h3><p>Tập nhận diện dữ kiện và dùng kiến thức để lập luận, kể cả khi cách hỏi thay đổi.</p></li>
                <li><span class="mmp-core-number" aria-hidden="true">05</span><h3>Hiểu vì sao đúng, vì sao sai</h3><p>Đối chiếu lời giải cho từng lựa chọn để hiểu cách suy luận, thay vì chỉ ghi lại đáp án.</p></li>
                <li><span class="mmp-core-number" aria-hidden="true">06</span><h3>Ôn lại đúng phần chưa vững</h3><p>Từ câu sai và lịch sử làm bài, tìm phần cần học lại rồi tự giải thích bằng lời của mình.</p></li>
            </ol>
            <a class="mmp-text-link mmp-core-link" href="/doi-ngu-giang-vien">Gặp người đồng hành cùng bạn <span aria-hidden="true">→</span></a>
        </div>
    </section>

    <section class="mmp-shell mmp-section mmp-editorial" id="cach-ap-dung" aria-labelledby="method-apply-title">
        <figure class="mmp-photo mmp-photo--apply">
            <img src="{$apply_picture|escape}" alt="{$text.mo_ta_anh_ap_dung|default:'Sinh viên học và trao đổi trong buổi thực hành lâm sàng'|escape}" loading="lazy" decoding="async" width="1600" height="1058">
            <figcaption>Từ lời giảng.<br>Đến cách bạn tự lập luận.</figcaption>
        </figure>
        <div class="mmp-copy">
            <p class="mmp-eyebrow">03 / ÁP DỤNG VÀO BUỔI HỌC</p>
            <h2 id="method-apply-title">ĐỪNG CHỈ XEM.<br><span>HÃY TỰ LÝ GIẢI.</span></h2>
            <p>Học xong một ý, hãy tạm dừng và thử giải thích bằng lời của mình. Sau đó dùng bài tập để kiểm tra điều vừa hiểu.</p>
            <dl class="mmp-session">
                <div><dt>Khi xem bài giảng</dt><dd>Ghi từ khóa và mối liên hệ. Tự vẽ lại sơ đồ, thay vì chép mọi lời giảng.</dd></div>
                <div><dt>Khi làm bài tập</dt><dd>Trả lời trước khi xem lời giải. Đối chiếu cả lựa chọn đúng và những lựa chọn sai.</dd></div>
                <div><dt>Khi còn chưa chắc</dt><dd>Quay lại phần liên quan, xem lịch sử làm bài và ghi câu hỏi để trao đổi với giảng viên.</dd></div>
            </dl>
        </div>
    </section>

    <section class="mmp-outcomes" id="dieu-dat-duoc" aria-labelledby="method-outcome-title">
        <div class="mmp-shell">
            <div class="mmp-outcome-heading">
                <p class="mmp-eyebrow">{$text.ket_qua_nhan|default:'04 / ĐÍCH ĐẾN CỦA MỖI BÀI HỌC'|escape}</p>
                <h2 id="method-outcome-title">{$text.ket_qua_tieu_de_1|default:'HIỂU. GIẢI THÍCH.'|escape}<br><span>{$text.ket_qua_tieu_de_2|default:'VẬN DỤNG ĐƯỢC.'|escape}</span></h2>
                <p>{$text.ket_qua_mo_ta|default:'Học xong không chỉ là xem hết video. Đây là ba điều bạn có thể tự kiểm tra sau mỗi bài học.'|escape}</p>
            </div>
            <div class="mmp-outcome-grid">
                <article><span aria-hidden="true">01</span><h3>Hiểu</h3><p>Tôi có hiểu bản chất và mối liên hệ của kiến thức này không?</p></article>
                <article><span aria-hidden="true">02</span><h3>Giải thích</h3><p>Tôi có thể giải thích bằng lời của mình khi không nhìn tài liệu?</p></article>
                <article><span aria-hidden="true">03</span><h3>Vận dụng</h3><p>Gặp một câu hỏi khác, tôi có biết dùng kiến thức nào để lập luận không?</p></article>
            </div>
            <div class="mmp-outcome-footer"><p>Nếu chưa làm được, bạn đã tìm thấy phần cần quay lại.</p><a class="mmp-text-link" href="/phan-hoi-hoc-vien">Lắng nghe trải nghiệm học viên <span aria-hidden="true">→</span></a></div>
        </div>
    </section>

    <section class="mmp-shell mmp-outro" aria-labelledby="method-start-title">
        <div><p class="mmp-eyebrow">THỬ MỘT CÁCH HỌC MỚI</p><h2 id="method-start-title">BẮT ĐẦU TỪ<br><span>MỘT BÀI HỌC.</span></h2><p>Chọn môn bạn đang cần. Học thử và tự cảm nhận cách MedUC giải thích kiến thức.</p></div>
        <div class="mmp-outro-actions"><a class="mmp-button mmp-button--primary" href="/khoa-hoc">Học thử miễn phí <span aria-hidden="true">→</span></a><a class="mmp-text-link" href="/lo-trinh-hoc">Xem lộ trình học <span aria-hidden="true">→</span></a></div>
    </section>
</main>
{/strip}
