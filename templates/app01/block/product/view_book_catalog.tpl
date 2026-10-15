{strip}
{$books = $data_block.data|default:[]}
{$text = $data_extend.locale[{LANGUAGE}]|default:[]}
{$categories = $this->Category->getCategories({PRODUCT}, {LANGUAGE}, [{FILTER} => ['parent_id' => 79]])}
{$subject_ids = [81, 82, 83, 84, 85, 86]}
{$stage_ids = [109, 110, 111]}
{$subjects = []}{$stages = []}{$category_lookup = []}{$category_name = 'Sách Y khoa'}
{foreach from = $categories item = category}
    {$category_lookup[$category.id] = $category}
    {if $category.id == PAGE_CATEGORY_ID}{$category_name = $category.name}{/if}
{/foreach}
{foreach from = $subject_ids item = category_id}{if !empty($category_lookup[$category_id])}{$subjects[$category_id] = $category_lookup[$category_id]}{/if}{/foreach}
{foreach from = $stage_ids item = category_id}{if !empty($category_lookup[$category_id])}{$stages[$category_id] = $category_lookup[$category_id]}{/if}{/foreach}
{$hero_books = []}
{foreach from = $books item = book}{if in_array($book.id, [83, 151, 190]) && !empty($book.all_images[0])}{$hero_books[] = $book}{/if}{/foreach}
{if count($hero_books) < 3}
    {$hero_books = []}
    {foreach from = $books item = book}{if !empty($book.all_images[0])}{$hero_books[] = $book}{/if}{if count($hero_books) == 3}{break}{/if}{/foreach}
{/if}
{$keyword = $this->getRequest()->getQuery('keyword')}{if !is_string($keyword)}{$keyword = ''}{/if}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.css?v=20261015" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-cart.js?v=20261015" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.js?v=20261015-2" defer></script>

<main class="mbc" id="book-catalog-page">
    <section class="mbc-hero {if PAGE_CATEGORY_ID != 79}mbc-hero--category{/if}" aria-labelledby="books-title">
        <div class="mbc-shell mbc-hero-inner">
            <div class="mbc-hero-copy">
                <p class="mbc-eyebrow">MEDUC / THƯ VIỆN SÁCH Y KHOA</p>
                {if PAGE_CATEGORY_ID == 79}<h1 id="books-title">{$text.tieu_de_1|default:'MỞ SÁCH.'|escape}<span>{$text.tieu_de_2|default:'MỞ THÊM GÓC NHÌN.'|escape}</span></h1>
                {else}<a href="/sach-y-khoa" class="mbc-back">← Tất cả sách Y khoa</a><h1 id="books-title">{$category_name|escape}</h1>{/if}
                <p class="mbc-hero-intro">{$text.mo_ta|default:'Từ kiến thức nền tảng đến những ca lâm sàng. Tìm cuốn sách phù hợp với môn học và chặng đường của bạn.'|escape}</p>
                <div class="mbc-hero-actions"><a class="mbc-button" href="#book-catalog">Khám phá sách <span aria-hidden="true">↓</span></a><span><strong>{count($books)}</strong> đầu sách đang mở</span></div>
            </div>
            {if PAGE_CATEGORY_ID == 79 && !empty($hero_books)}
                <div class="mbc-hero-art" aria-label="Một góc kệ sách MedUC">
                    <span class="mbc-art-backdrop" aria-hidden="true"></span>
                    {foreach from = $hero_books item = book}<a class="mbc-hero-book" href="{$this->Utilities->checkInternalUrl($book.url)|escape}" aria-label="Xem sách {$book.name|escape}"><img src="{CDN_URL}{$this->Utilities->getThumbs($book.all_images[0], 500)}" alt="Bìa sách {$book.name|escape}" decoding="async" /></a>{/foreach}
                    <span class="mbc-art-note"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 6C8 4 5 4 2 5v14c3-1 6-1 10 1 4-2 7-2 10-1V5c-3-1-6-1-10 1Zm0 0v14"/></svg>HỌC SÂU HƠN.<br>MỖI NGÀY.</span>
                </div>
            {/if}
        </div>
    </section>

    <nav class="mbc-topics" aria-label="Danh mục sách theo môn"><div class="mbc-shell mbc-topic-links">
        <a href="/sach-y-khoa" {if PAGE_CATEGORY_ID == 79}aria-current="page"{/if}>Tất cả sách</a>
        {foreach from = $subjects item = category}<a href="{$this->Utilities->checkInternalUrl($category.url)|escape}" {if PAGE_CATEGORY_ID == $category.id}aria-current="page"{/if}>{$category.name|escape}</a>{/foreach}
    </div></nav>

    <section class="mbc-shell mbc-catalog" id="book-catalog" aria-labelledby="book-catalog-title">
        <div class="mbc-section-heading"><div><p class="mbc-eyebrow">DANH MỤC ĐANG MỞ</p><h2 id="book-catalog-title">TÌM CUỐN SÁCH<br><span>BẠN CẦN.</span></h2></div><p>Tra cứu theo tên sách, môn học hoặc năm học. Xem thông tin và chọn những cuốn sách cho hành trình học Y của bạn.</p></div>
        <div class="mbc-tools" data-book-tools hidden>
            <label class="mbc-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="mbc-sr-only">Tìm sách</span><input type="search" id="book-search" placeholder="Tìm sách theo tên hoặc môn học..." value="{$keyword|escape}" autocomplete="off"><button type="button" data-book-clear aria-label="Xóa từ khóa" hidden>×</button></label>
            <label class="mbc-select">Năm học<select id="book-stage"><option value="all">Tất cả năm học</option>{foreach from = $stages item = category}<option value="{$category.id}">{$category.name|escape}</option>{/foreach}</select></label>
            <label class="mbc-select">Sắp xếp<select id="book-sort"><option value="default">Theo MedUC</option><option value="name">Tên A–Z</option><option value="price-up">Giá thấp đến cao</option><option value="price-down">Giá cao đến thấp</option></select></label>
        </div>
        <div class="mbc-result-row"><p role="status" aria-live="polite" aria-atomic="true" data-book-status>Hiển thị {count($books)} đầu sách</p><a href="/dat-hang">Giỏ sách của bạn <span aria-hidden="true">↗</span></a></div>
        <div class="mbc-grid" data-book-grid>
            {foreach from = $books item = book key = book_index}{$this->element('../block/product/item_book_catalog', ['book' => $book, 'book_index' => $book_index, 'subject_ids' => $subject_ids])}{/foreach}
        </div>
        <div class="mbc-empty" data-book-empty {if !empty($books)}hidden{/if}><span aria-hidden="true">↗</span><h3>Chưa tìm thấy sách phù hợp.</h3><p>Thử một tên sách khác hoặc bỏ bộ lọc năm học.</p><button type="button" data-book-reset hidden>Xóa bộ lọc</button><a href="/sach-y-khoa">Xem tất cả sách →</a></div>
        <button type="button" class="mbc-more" data-book-more hidden>Xem thêm sách <span aria-hidden="true">↓</span></button>
    </section>

    <aside class="mbc-next"><div class="mbc-shell mbc-next-inner"><div><p class="mbc-eyebrow">TIẾP TỤC HỌC CÙNG MEDUC</p><h2>ĐỌC SÁCH.<br><span>RỒI HỌC SÂU HƠN.</span></h2><p>Kết nối kiến thức trong sách với bài giảng và thực hành qua các khóa học tại MedUC.</p></div><a class="mbc-button" href="/khoa-hoc">Khám phá khóa học <span aria-hidden="true">→</span></a></div></aside>
    <div class="mbc-cart-notice" data-book-cart-notice hidden><span role="status" aria-live="polite" aria-atomic="true" data-book-cart-message></span><a href="/dat-hang">Xem giỏ sách →</a><button type="button" aria-label="Đóng thông báo" data-book-cart-close>×</button></div>
</main>
{/strip}
