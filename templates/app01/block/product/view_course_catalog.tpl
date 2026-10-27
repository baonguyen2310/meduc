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
{* Khóa luyện thi (/khoa-luyen-thi, "Luyện thi" in the header): each course is a subject whose lesson holds its exams. *}
{$exam_prep = $catalog.exam_prep}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-catalog.css?v=20261028-cards-2" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/course-catalog.js?v=20261028-2" defer></script>

<main class="mcl" id="course-catalog">
    <section class="mcl-shell mcl-hero" aria-labelledby="catalog-title">
        <div>
            <p class="mcl-eyebrow">{if $exam_prep}LUYỆN THI MEDUC / ĐỀ THI CÁC TRƯỜNG Y{else}KHÓA HỌC MEDUC / TỪ CƠ BẢN ĐẾN CHUYÊN SÂU{/if}</p>
            {if $exam_prep && PAGE_CATEGORY_ID != 125}
                <a class="mcl-back" href="/khoa-luyen-thi">← Tất cả môn luyện thi</a>
                <h1 class="mcl-category-title" id="catalog-title">{$catalog.category_name|escape}</h1>
            {elseif $exam_prep}
                <h1 id="catalog-title">LUYỆN ĐỀ THEO MÔN.<span>VỮNG VÀNG MÙA THI.</span></h1>
            {elseif PAGE_CATEGORY_ID == 50}
                <h1 id="catalog-title">{$text.tieu_de_1|default:'CHỌN KHÓA HỌC.'|escape}<span>{$text.tieu_de_2|default:'ĐÚNG CHẶNG ĐƯỜNG.'|escape}</span></h1>
            {else}
                <a class="mcl-back" href="/khoa-hoc">← Tất cả khóa học</a>
                <h1 class="mcl-category-title" id="catalog-title">{$catalog.category_name|escape}</h1>
            {/if}
        </div>
        {if $exam_prep}
            <div class="mcl-hero-detail"><p>Khám phá lộ trình luyện thi theo môn, từ chương và bài học đến phần tổng ôn. Bộ đề đang được MedUC chuẩn bị.</p><span><strong>{$catalog.total}</strong> môn luyện thi</span></div>
        {else}
            <div class="mcl-hero-detail"><p>{$text.mo_ta|default:'Tìm môn học phù hợp với năm học và mục tiêu của bạn. Xem lộ trình, chọn khóa học và bắt đầu cùng MedUC.'|escape}</p><span><strong>{$catalog.total}</strong> khóa học đang mở</span></div>
        {/if}
    </section>

    <nav class="mcl-year-nav" aria-label="Danh mục theo năm học">
        <div class="mcl-shell mcl-year-links">
            {if $exam_prep}<a href="/khoa-luyen-thi" {if PAGE_CATEGORY_ID == 125}aria-current="page"{/if}>Tất cả môn</a>
            {else}<a href="/khoa-hoc" {if PAGE_CATEGORY_ID == 50}aria-current="page"{/if}>Tất cả khóa học</a>{/if}
            {foreach from = $catalog.nav_groups item = category}
                <a href="{$this->Utilities->checkInternalUrl($category.url)|escape}" {if $catalog.selected_id == $category.id}aria-current="page"{/if}>{$category.name|escape}</a>
            {/foreach}
        </div>
    </nav>

    <section class="mcl-shell mcl-catalog-body" aria-label="Danh sách khóa học">
        <div class="mcl-tools" data-catalog-tools hidden>
            <label class="mcl-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="mcl-sr-only">Tìm khóa học trong danh sách</span><input type="search" id="catalog-search" placeholder="{if $exam_prep}Tìm môn hoặc module...{else}Tìm tên khóa học hoặc môn học...{/if}" value="{$keyword|escape}" autocomplete="off" /><button type="button" data-catalog-clear aria-label="Xóa từ khóa tìm kiếm" hidden>×</button></label>
            <label class="mcl-sort">Sắp xếp<select id="catalog-sort"><option value="default">Theo MedUC</option><option value="name">Tên A–Z</option><option value="price-up">Học phí thấp đến cao</option><option value="price-down">Học phí cao đến thấp</option></select></label>
        </div>
        <p class="mcl-result" role="status" aria-live="polite" aria-atomic="true" data-catalog-status {if $exam_prep}data-catalog-noun="môn luyện thi"{/if}>Hiển thị {$catalog.total} {if $exam_prep}môn luyện thi{else}khóa học đang mở{/if}</p>

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
        <div class="mcl-empty" data-catalog-empty {if $catalog.total > 0}hidden{/if}><span aria-hidden="true">↗</span><h2>Chưa tìm thấy khóa học phù hợp.</h2><p>Thử tên môn khác hoặc xem lại danh sách đầy đủ.</p><button type="button" data-catalog-reset hidden>Xóa tìm kiếm</button><a href="/khoa-hoc">Xem tất cả khóa học →</a></div>
        {if $catalog.total > 0}<p class="mcl-list-note">{if $exam_prep}Phân nhóm theo giai đoạn học; một môn có thể thuộc nhiều năm tùy chương trình của trường. Mỗi môn giữ nguyên lộ trình chương, bài học và phần tổng ôn.{else}Khóa học được xếp theo danh mục năm học của MedUC. Một khóa có thể thuộc nhiều nhóm.{/if}</p>{/if}
    </section>

    <section class="mcl-help"><div class="mcl-shell mcl-help-inner"><div><p class="mcl-eyebrow">CHƯA BIẾT BẮT ĐẦU TỪ ĐÂU?</p><h2>CÙNG TÌM LỘ TRÌNH<br><span>PHÙ HỢP VỚI BẠN.</span></h2><p>Chia sẻ môn học hoặc mục tiêu hiện tại để MedUC hỗ trợ bạn lựa chọn.</p></div><div>{if !empty($website.hotline)}<a class="mcl-register" href="tel:{$website.hotline|escape}">Nhận tư vấn <span aria-hidden="true">↗</span></a><span class="mcl-help-phone">{$website.hotline|escape}</span>{else}<a class="mcl-register" href="/gioi-thieu">Tìm hiểu về MedUC <span aria-hidden="true">→</span></a>{/if}</div></div></section>
</main>
{/strip}
