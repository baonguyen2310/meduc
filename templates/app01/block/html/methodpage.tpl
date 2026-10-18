{strip}
{* Standalone explanation of MedUC's existing Core Learning approach. Hero copy/image use the normal block settings. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$website = $this->Setting->getWebsiteInfo()}
{$picture = $this->Utilities->replaceVariableSystem($text.anh|default:'/templates/app01/assets/meduc-v2/method/study-editorial.jpg')}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/method-page.css?v=20261018-2" rel="stylesheet">

<main class="mmp" id="meduc-method">
    <section class="mmp-shell mmp-hero" aria-labelledby="method-title">
        <div class="mmp-hero-copy">
            <p class="mmp-eyebrow">MEDUC / PHƯƠNG PHÁP HỌC</p>
            <h1 id="method-title">{$text.tieu_de_1|default:'HỌC TỪ CỐT LÕI.'|escape}<span>{$text.tieu_de_2|default:'HIỂU ĐỂ ĐI XA.'|escape}</span></h1>
            <p class="mmp-lead">{$text.mo_ta|default:'Học Y có rất nhiều điều cần nhớ. MedUC chọn bắt đầu từ điều cần hiểu: bản chất của vấn đề, mối liên hệ giữa các kiến thức và cách vận dụng vào từng câu hỏi, từng tình huống.'|escape}</p>
            <a class="mmp-button mmp-button--primary" href="#core-learning">Khám phá Core Learning <span aria-hidden="true">↓</span></a>
            <p class="mmp-hero-note">Hiểu sâu · Học có hệ thống · Chủ động luyện tập</p>
        </div>
        <figure class="mmp-hero-visual">
            <img src="{$picture|escape}" alt="Nhóm sinh viên cùng học và trao đổi kiến thức y khoa" fetchpriority="high" decoding="async" width="1024" height="1024">
            <figcaption><span>CORE LEARNING</span><p>Từ một câu hỏi.<br>Đến cả một khái niệm.</p><small>Phương pháp học tại MedUC</small></figcaption>
        </figure>
    </section>

    <nav class="mmp-jump" aria-label="Nội dung phương pháp học">
        <div class="mmp-shell"><a href="#vi-sao"><span>01</span> Vì sao cần phương pháp?</a><a href="#core-learning"><span>02</span> Cách học tại MedUC</a><a href="#cach-ap-dung"><span>03</span> Áp dụng vào buổi học</a></div>
    </nav>

    <section class="mmp-shell mmp-section" id="vi-sao" aria-labelledby="method-why-title">
        <div class="mmp-heading mmp-heading--split"><div><p class="mmp-eyebrow">01 / BẮT ĐẦU TỪ NGƯỜI HỌC</p><h2 id="method-why-title">HỌC RẤT NHIỀU.<br><span>ĐÃ HIỂU ĐƯỢC BAO NHIÊU?</span></h2></div><p>Đọc lại nhiều lần chưa chắc đã biết cách giải thích một vấn đề. Một phương pháp phù hợp giúp bạn biết mình đang học gì, vì sao kiến thức đó quan trọng và cần ôn lại ở đâu.</p></div>
        <div class="mmp-challenges">
            <article><span class="mmp-number">01</span><h3>Kiến thức nhiều, dễ rời rạc.</h3><p>Từ môn cơ sở đến lâm sàng, mỗi phần học có nhiều thuật ngữ và chi tiết. Nếu thiếu một khung kiến thức, bạn dễ nhớ từng mảnh nhưng khó kết nối thành bức tranh chung.</p></article>
            <article><span class="mmp-number">02</span><h3>Nhớ đáp án, chưa rõ bản chất.</h3><p>Một câu hỏi quen có thể làm đúng nhờ nhớ đáp án. Khi cách hỏi thay đổi, điều giúp bạn tiếp tục lập luận chính là khái niệm và cơ chế ở phía sau.</p></article>
            <article><span class="mmp-number">03</span><h3>Chưa biết mình hổng ở đâu.</h3><p>Học xong cần có bước tự kiểm tra. Từ câu sai hoặc phần chưa giải thích được, bạn mới xác định rõ điều cần học lại, thay vì ôn tất cả từ đầu.</p></article>
        </div>
    </section>

    <section class="mmp-core mmp-section" id="core-learning" aria-labelledby="method-core-title">
        <div class="mmp-shell">
            <div class="mmp-heading"><p class="mmp-eyebrow">02 / PHƯƠNG PHÁP TẠI MEDUC</p><h2 id="method-core-title">CORE LEARNING.<br><span>ĐI TỪ GỐC ĐẾN HIỂU.</span></h2><p>Core Learning là cách MedUC tổ chức việc dạy và học từ kiến thức cốt lõi. Từ khóa trọng tâm, Mind Map và tình huống lâm sàng giúp người học xây dựng mạch liên kết, rồi củng cố qua bài tập và lời giải.</p></div>
            <ol class="mmp-concept-flow" aria-label="Mạch tư duy khi học"><li><span>Đặt vấn đề</span><strong>Câu hỏi</strong></li><li><span>Tìm nền tảng</span><strong>Khái niệm</strong></li><li><span>Kết nối kiến thức</span><strong>Cơ chế &amp; liên hệ</strong></li><li><span>Tự kiểm chứng</span><strong>Vận dụng</strong></li></ol>
            <div class="mmp-principles">
                <article><span class="mmp-number">01 / HIỂU CỐT LÕI</span><div><h3>Bắt đầu bằng “vì sao”.</h3><p>Trước khi ghi nhớ một danh sách, hãy làm rõ khái niệm: đó là gì, có vai trò gì và liên hệ thế nào với kiến thức đã học. Từ khóa giúp nhận ra ý chính; phần giảng giải giúp hiểu mối quan hệ giữa các ý.</p><p class="mmp-takeaway">Sau khi học: bạn thử diễn đạt lại vấn đề bằng lời của mình.</p></div></article>
                <article><span class="mmp-number">02 / HỆ THỐNG HÓA</span><div><h3>Dùng Mind Map để nối các ý.</h3><p>Sơ đồ tư duy đi từ chủ đề trung tâm đến những nhánh kiến thức quan trọng. Mục tiêu là nhìn thấy cấu trúc và mối liên hệ, thay vì chỉ chép lại bài giảng thành một sơ đồ nhiều màu.</p><p class="mmp-takeaway">Khi ôn tập: từ một từ khóa, bạn có thể lần lại các ý liên quan.</p></div></article>
                <article><span class="mmp-number">03 / VẬN DỤNG</span><div><h3>Đưa kiến thức vào câu hỏi và tình huống.</h3><p>Qua bài tập và case lâm sàng, bạn tập nhận diện dữ kiện, liên hệ kiến thức và lý giải lựa chọn. Lời giải giúp quay lại khái niệm đang được hỏi và hiểu vì sao một lựa chọn đúng hoặc sai.</p><p class="mmp-takeaway">Khi chữa bài: ghi lại điều mình chưa hiểu, không chỉ ghi đáp án.</p></div></article>
            </div>
        </div>
    </section>

    <section class="mmp-shell mmp-section" id="cach-ap-dung" aria-labelledby="method-cycle-title">
        <div class="mmp-heading mmp-heading--split"><div><p class="mmp-eyebrow">03 / TỪ PHƯƠNG PHÁP ĐẾN THÓI QUEN</p><h2 id="method-cycle-title">MỘT BUỔI HỌC.<br><span>BỐN BƯỚC CHỦ ĐỘNG.</span></h2></div><p>Bạn có thể áp dụng chu trình này khi học cùng MedUC: chuẩn bị câu hỏi, hiểu bài, tự luyện tập và quay lại phần còn thiếu.</p></div>
        <ol class="mmp-cycle">
            <li><span class="mmp-step">01</span><span class="mmp-eyebrow">TRƯỚC KHI HỌC</span><h3>Xác định điều cần hiểu.</h3><p>Xem tên bài và các ý chính. Ghi lại phần chưa rõ hoặc kiến thức nền mình cần ôn lại.</p></li>
            <li><span class="mmp-step">02</span><span class="mmp-eyebrow">TRONG KHI HỌC</span><h3>Nghe để hiểu, ghi có chọn lọc.</h3><p>Theo dõi cách giảng viên giải thích. Ghi từ khóa, cơ chế và mối liên hệ; tự vẽ lại sơ đồ theo cách mình hiểu.</p></li>
            <li><span class="mmp-step">03</span><span class="mmp-eyebrow">SAU KHI HỌC</span><h3>Làm bài rồi đọc lời giải.</h3><p>Thử trả lời trước khi xem đáp án. Với câu sai hoặc còn phân vân, đối chiếu lời giải và tìm lại phần kiến thức liên quan.</p></li>
            <li><span class="mmp-step">04</span><span class="mmp-eyebrow">Ở LẦN ÔN TIẾP THEO</span><h3>Quay lại đúng chỗ còn hổng.</h3><p>Xem lịch sử làm bài, ôn những ý chưa chắc và thử làm lại. Đưa câu hỏi còn vướng đến giảng viên để được giải đáp.</p></li>
        </ol>
    </section>

    <section class="mmp-support">
        <div class="mmp-shell mmp-support-inner"><div><p class="mmp-eyebrow">CÓ PHƯƠNG PHÁP. CÓ NGƯỜI ĐỒNG HÀNH.</p><h2>NGƯỜI DẠY GIÚP BẠN<br><span>NHÌN RA MẠCH KIẾN THỨC.</span></h2><p>Phương pháp cần được thể hiện trong từng lời giảng và cách chữa bài. Đội ngũ Thạc sĩ, Bác sĩ nội trú tại MedUC đồng hành cùng người học qua kiến thức, kinh nghiệm và việc giải đáp thắc mắc.</p><a class="mmp-text-link" href="/doi-ngu-giang-vien">Gặp đội ngũ giảng viên <span aria-hidden="true">→</span></a></div><blockquote><p>“Điều quan trọng sau một bài học là bạn có thể hiểu, giải thích và biết cách vận dụng kiến thức ấy.”</p><cite>TINH THẦN HỌC TẬP TẠI MEDUC</cite></blockquote></div>
    </section>

    <section class="mmp-shell mmp-section mmp-faq" aria-labelledby="method-faq-title">
        <div><p class="mmp-eyebrow">TRƯỚC KHI BẮT ĐẦU</p><h2 id="method-faq-title">BẠN CÓ THỂ<br><span>ĐANG BĂN KHOĂN.</span></h2></div>
        <div class="mmp-faq-list">
            <details><summary>Tôi đang mất gốc thì nên bắt đầu thế nào?</summary><div><p>Bắt đầu từ phần kiến thức nền có liên quan đến môn đang học. Đi từng bài, làm rõ thuật ngữ và khái niệm trước khi chuyển sang câu hỏi phức tạp hơn. Bạn có thể trao đổi với MedUC để chọn điểm bắt đầu phù hợp.</p></div></details>
            <details><summary>Có cần biết vẽ Mind Map từ trước không?</summary><div><p>Không cần. Bạn có thể bắt đầu bằng một chủ đề và vài nhánh ý chính. Điều quan trọng là tự xác định được mối liên hệ giữa các ý và đọc lại được sơ đồ của mình.</p></div></details>
            <details><summary>Học như vậy có còn phải ghi nhớ không?</summary><div><p>Có. Kiến thức Y khoa vẫn cần được ghi nhớ và ôn tập. Core Learning đặt việc hiểu và hệ thống hóa làm nền cho bước ghi nhớ, sau đó dùng bài tập để kiểm tra và củng cố.</p></div></details>
            <details><summary>Tôi nên ưu tiên xem bài giảng hay làm bài tập?</summary><div><p>Hai phần bổ trợ cho nhau. Nếu chưa vững nền tảng, hãy học phần kiến thức trước rồi luyện tập. Nếu đã học qua môn, bạn có thể dùng bài tập để nhận ra phần chưa chắc và quay lại bài giảng tương ứng.</p></div></details>
        </div>
    </section>

    <section class="mmp-outro"><div class="mmp-shell mmp-outro-inner"><div><p class="mmp-eyebrow">BẮT ĐẦU TỪ MỘT CÁCH HỌC PHÙ HỢP</p><h2>HỌC CÓ ĐỊNH HƯỚNG.<br><span>TIẾN BỘ TỪNG BÀI.</span></h2><p>Chọn môn bạn cần học, xem lộ trình và tìm cách bắt đầu phù hợp với nền tảng hiện tại.</p></div><div class="mmp-outro-actions"><a class="mmp-button mmp-button--primary" href="/khoa-hoc">Tìm khóa học phù hợp <span aria-hidden="true">→</span></a>{if !empty($website.hotline)}<a class="mmp-button" href="tel:{$website.hotline|replace:' ':''|escape}">Nhận tư vấn miễn phí</a>{else}<a class="mmp-button" href="/gioi-thieu">Tìm hiểu về MedUC</a>{/if}</div></div></section>
</main>
{/strip}
