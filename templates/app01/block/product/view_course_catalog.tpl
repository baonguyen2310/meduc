{strip}
{* The standard product block supplies live prices, categories and items, including the existing staff-only visibility rules. *}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$catalog = $this->Product->prepareCourseCatalog($data_block.data|default:[], [102, 72, 103], PAGE_CATEGORY_ID, {LANGUAGE})}
{$cart_info = $this->Cart->getCartInfo()}
{$cart_product_ids = []}
{if !empty($cart_info.items)}{foreach from = $cart_info.items item = cart_item}{$cart_product_ids[] = $cart_item.product_id}{/foreach}{/if}
{$keyword = $this->getRequest()->getQuery('keyword')}
{if !is_string($keyword)}{$keyword = ''}{/if}
{$website = $this->Setting->getWebsiteInfo()}
{* Khóa luyện thi (/trac-nghiem, "Luyện thi" in the header): each course is a subject whose lesson holds its exams. *}
{$exam_prep = $catalog.exam_prep}
{$solution = $catalog.course_kind == 'exam_solution'}
{$hero_courses = []}{$hero_course_ids = []}
{if !$exam_prep && PAGE_CATEGORY_ID == 50}
    {foreach from = $catalog.groups item = hero_group}
        {foreach from = $hero_group.courses item = hero_course}
            {if !empty($hero_course.all_images[0]) && !in_array($hero_course.id, $hero_course_ids)}
                {$hero_courses[] = $hero_course}{$hero_course_ids[] = $hero_course.id}
            {/if}
            {if count($hero_courses) == 3}{break}{/if}
        {/foreach}
        {if count($hero_courses) == 3}{break}{/if}
    {/foreach}
{/if}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-catalog.css?v=20261029-course-types" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/catalog-heroes.css?v=20261029-solution" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-catalog.js?v=20261028-2" defer></script>

<main class="mcl" id="course-catalog" data-course-kind="{$catalog.course_kind|escape}">
    {if $exam_prep}
        <section class="mcl-catalog-hero mcl-catalog-hero--exam {if PAGE_CATEGORY_ID != 125}mcl-catalog-hero--category{/if}" aria-labelledby="catalog-title">
            <div class="mcl-shell">
                <p class="mcl-eyebrow mcl-exam-eyebrow"><span aria-hidden="true"></span> TRẮC NGHIỆM MEDUC / LUYỆN TẬP THEO MÔN</p>
                {if PAGE_CATEGORY_ID != 125}
                    <a class="mcl-back" href="/trac-nghiem">← Tất cả môn luyện thi</a>
                    <h1 class="mcl-catalog-title" id="catalog-title">{$catalog.category_name|escape}</h1>
                {else}
                    <h1 class="mcl-catalog-title" id="catalog-title">LUYỆN ĐỀ THEO MÔN.<span>VỮNG VÀNG MÙA THI.</span></h1>
                {/if}
                <p class="mcl-catalog-intro">Mỗi bài có 30 câu làm thử miễn phí. Đăng ký một lần để mở bài tập 2 của tất cả bài trong môn.</p>
                <div class="mcl-exam-hero-meta"><span><strong>{$catalog.total}</strong> môn luyện thi</span><span aria-hidden="true">/</span><a href="#course-listing">Chọn môn luyện thi <span aria-hidden="true">↓</span></a></div>
            </div>
        </section>
    {else}
        <section class="mcl-catalog-hero mcl-catalog-hero--course {if PAGE_CATEGORY_ID != 50 || (!$solution && empty($hero_courses))}mcl-catalog-hero--category{/if}" aria-labelledby="catalog-title">
            <div class="mcl-shell mcl-course-hero-inner">
                <div class="mcl-course-hero-copy">
                    <p class="mcl-eyebrow">{if $solution}KHOÁ CHỮA ĐỀ MEDUC / HIỂU ĐỀ · VỮNG CÁCH GIẢI{else}KHÓA HỌC MEDUC / TỪ CƠ BẢN ĐẾN CHUYÊN SÂU{/if}</p>
                    {if PAGE_CATEGORY_ID == 50}
                        <h1 class="mcl-catalog-title" id="catalog-title">{if $catalog.course_kind == 'exam_solution'}HIỂU CÁCH GIẢI.<span>VỮNG CÁCH LÀM.</span>{else}{$text.tieu_de_1|default:'CHỌN KHÓA HỌC.'|escape}<span>{$text.tieu_de_2|default:'ĐÚNG CHẶNG ĐƯỜNG.'|escape}</span>{/if}</h1>
                    {else}
                        <a class="mcl-back" href="/khoa-hoc">← Tất cả khóa học</a>
                        <h1 class="mcl-catalog-title" id="catalog-title">{$catalog.category_name|escape}</h1>
                    {/if}
                    <p class="mcl-catalog-intro">{if $solution}Theo dõi giảng viên phân tích từng câu, nhận diện kiến thức trọng tâm và hiểu cách xử lý đề. Học cách giải, rồi tự tin vận dụng.{else}{$text.mo_ta|default:'Tìm môn học phù hợp với năm học và mục tiêu của bạn. Xem lộ trình, chọn khóa học và bắt đầu cùng MedUC.'|escape}{/if}</p>
                    <div class="mcl-course-hero-actions"><a class="mcl-register" href="#course-listing">{if $solution}Luyện thi miễn phí{else}Học thử miễn phí{/if} <span aria-hidden="true">↓</span></a><span>{if $solution && $catalog.total == 0}Video chữa đề theo từng môn học{else}<strong>{$catalog.total}</strong> {if $solution}khoá chữa đề{else}khóa học{/if} đang mở{/if}</span></div>
                </div>
                {if $solution}
                    <div class="mcl-course-hero-art mcl-solution-art" aria-label="Học qua video chữa đề cùng giảng viên MedUC">
                        <span class="mcl-course-art-backdrop" aria-hidden="true"></span>
                        <div class="mcl-solution-paper mcl-solution-paper--question" aria-hidden="true"><span class="mcl-solution-step">01 / ĐỌC ĐÚNG ĐỀ</span><strong>Tìm từ khoá.<br>Hiểu câu hỏi.</strong><i></i><i></i><i></i><span class="mcl-solution-answer">A <b></b></span><span class="mcl-solution-answer is-chosen">B <b></b><em>✓</em></span><span class="mcl-solution-answer">C <b></b></span></div>
                        <div class="mcl-solution-paper mcl-solution-paper--method" aria-hidden="true"><span class="mcl-solution-step">02 / HIỂU CÁCH GIẢI</span><strong>Kết nối<br>kiến thức.</strong><span class="mcl-solution-path"><b>Câu hỏi</b><em>↓</em><b>Khái niệm</b><em>↓</em><b>Cách giải</b></span></div>
                        <div class="mcl-solution-photo"><img src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/feedback/lop-lam-sang.jpg" alt="Giảng viên MedUC hướng dẫn trong buổi học" fetchpriority="high" decoding="async"><div><span>HỌC QUA VIDEO CHỮA ĐỀ</span><strong>Hiểu cách làm.<br>Nhớ cách giải.</strong></div><span class="mcl-solution-play" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m9 6 9 6-9 6z"/></svg></span></div>
                        <span class="mcl-course-art-note"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m10 8 6 4-6 4Z"/></svg>XEM CÁCH GIẢI.<br>HIỂU CÁCH LÀM.</span>
                    </div>
                {elseif PAGE_CATEGORY_ID == 50 && !empty($hero_courses)}
                    <div class="mcl-course-hero-art" aria-label="Khám phá các khóa học MedUC">
                        <span class="mcl-course-art-backdrop" aria-hidden="true"></span>
                        {foreach from = $hero_courses item = hero_course key = hero_index}
                            <a class="mcl-course-hero-cover" href="{$this->Utilities->checkInternalUrl($hero_course.url)|escape}" aria-label="Xem khóa học {$hero_course.name|escape}"><img src="{CDN_URL}{$this->Utilities->getThumbs($hero_course.all_images[0], 720)}" alt="Ảnh bìa {$hero_course.name|escape}" {if $hero_index == 1}fetchpriority="high"{/if} decoding="async" /></a>
                        {/foreach}
                        <span class="mcl-course-art-note"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m10 8 6 4-6 4Z"/></svg>HỌC TỪ CƠ BẢN.<br>ĐẾN CHUYÊN SÂU.</span>
                    </div>
                {/if}
            </div>
        </section>
    {/if}

    <nav class="mcl-year-nav" aria-label="Danh mục theo năm học">
        <div class="mcl-shell mcl-year-links">
            {if $exam_prep}<a href="/trac-nghiem" {if PAGE_CATEGORY_ID == 125}aria-current="page"{/if}>Tất cả môn</a>
            {else}<a href="{$catalog.catalog_url|escape}" {if $catalog.selected_id == 50}aria-current="page"{/if}>{if $solution}Tất cả khoá chữa đề{else}Tất cả khóa học{/if}</a>{/if}
            {foreach from = $catalog.nav_groups item = category}
                <a href="{if $solution}/khoa-chua-de?nam={$category.id}{else}{$this->Utilities->checkInternalUrl($category.url)|escape}{/if}" {if $catalog.selected_id == $category.id}aria-current="page"{/if}>{$category.name|escape}</a>
            {/foreach}
        </div>
    </nav>

    <section class="mcl-shell mcl-catalog-body" id="course-listing" aria-label="Danh sách khóa học">
        <div class="mcl-tools" data-catalog-tools hidden>
            <label class="mcl-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="mcl-sr-only">Tìm khóa học trong danh sách</span><input type="search" id="catalog-search" placeholder="{if $exam_prep}Tìm môn hoặc module...{else}Tìm tên khóa học hoặc môn học...{/if}" value="{$keyword|escape}" autocomplete="off" /><button type="button" data-catalog-clear aria-label="Xóa từ khóa tìm kiếm" hidden>×</button></label>
            <label class="mcl-sort">Sắp xếp<select id="catalog-sort"><option value="default">Theo MedUC</option><option value="name">Tên A–Z</option><option value="price-up">Học phí thấp đến cao</option><option value="price-down">Học phí cao đến thấp</option></select></label>
        </div>
        <p class="mcl-result" role="status" aria-live="polite" aria-atomic="true" data-catalog-status {if $exam_prep}data-catalog-noun="môn luyện thi"{elseif $solution}data-catalog-noun="khoá chữa đề"{/if}>Hiển thị {$catalog.total} {if $exam_prep}môn luyện thi{else}khóa học đang mở{/if}</p>

        {foreach from = $catalog.groups item = group key = group_index}
            <section class="mcl-group" data-course-group data-course-group-id="{$group.id}" data-course-layout="list" aria-labelledby="course-group-{$group.id}">
                <div class="mcl-group-heading">
                    <span class="mcl-group-number">0{$group_index + 1}</span>
                    <div><p class="mcl-eyebrow">{if $exam_prep}KHÓA LUYỆN THI{elseif $group.id == 'other'}KHÁM PHÁ THÊM{else}LỘ TRÌNH THEO NĂM HỌC{/if}</p><h2 id="course-group-{$group.id}">{$group.name|escape}</h2></div>
                    <div class="mcl-group-actions">
                        <span class="mcl-group-count"><span data-group-count>{count($group.courses)}</span> {if $exam_prep}môn{else}khóa học{/if}</span>
                        <div class="mcl-layout-switch" role="group" aria-label="Cách hiển thị {$group.name|escape}" data-layout-switch hidden>
                            <button type="button" data-catalog-layout="list" aria-pressed="true" aria-label="Dạng danh sách: {$group.name|escape}" aria-controls="course-list-{$group.id}" title="Dạng danh sách"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="4" width="4" height="4" rx="1"/><rect x="3" y="10" width="4" height="4" rx="1"/><rect x="3" y="16" width="4" height="4" rx="1"/><path d="M11 6h10M11 12h10M11 18h10"/></svg></button>
                            <button type="button" data-catalog-layout="grid" aria-pressed="false" aria-label="Dạng lưới: {$group.name|escape}" aria-controls="course-list-{$group.id}" title="Dạng lưới"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></svg></button>
                        </div>
                    </div>
                </div>
                <div class="mcl-course-list" data-course-list id="course-list-{$group.id}">
                    {foreach from = $group.courses item = course key = course_index}
                        {$this->element('../block/product/item_course_horizontal', ['course' => $course, 'course_index' => $course_index, 'cart_product_ids' => $cart_product_ids])}
                    {/foreach}
                </div>
            </section>
        {/foreach}
        <div class="mcl-empty" data-catalog-empty {if $catalog.total > 0}hidden{/if}><span aria-hidden="true">↗</span><h2>{if $solution && $catalog.total == 0}Khoá chữa đề đang được cập nhật.{else}Chưa tìm thấy khóa học phù hợp.{/if}</h2><p>{if $solution && $catalog.total == 0}Các video chữa đề theo môn sẽ xuất hiện tại đây.{else}Thử tên môn khác hoặc xem lại danh sách đầy đủ.{/if}</p><button type="button" data-catalog-reset hidden>Xóa tìm kiếm</button><a href="{$catalog.catalog_url|escape}">{if $solution}Xem tất cả khoá chữa đề{else}Xem tất cả khóa học{/if} →</a></div>
        {if $catalog.total > 0}<p class="mcl-list-note">{if $exam_prep || $solution}32 môn được xếp theo năm sinh viên trong lộ trình MedUC version 1. Mỗi môn thuộc một năm học.{else}Khóa học được xếp theo danh mục năm học của MedUC. Một khóa có thể thuộc nhiều nhóm.{/if}</p>{/if}
    </section>

    <section class="mcl-help"><div class="mcl-shell mcl-help-inner"><div><p class="mcl-eyebrow">CHƯA BIẾT BẮT ĐẦU TỪ ĐÂU?</p><h2>CÙNG TÌM LỘ TRÌNH<br><span>PHÙ HỢP VỚI BẠN.</span></h2><p>Chia sẻ môn học hoặc mục tiêu hiện tại để MedUC hỗ trợ bạn lựa chọn.</p></div><div>{if !empty($website.hotline)}<a class="mcl-register" href="tel:{$website.hotline|escape}">Nhận tư vấn <span aria-hidden="true">↗</span></a><span class="mcl-help-phone">{$website.hotline|escape}</span>{else}<a class="mcl-register" href="/gioi-thieu">Tìm hiểu về MedUC <span aria-hidden="true">→</span></a>{/if}</div></div></section>
</main>
{/strip}
