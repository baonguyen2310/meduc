{strip}
{$equipment = $data_block.data|default:[]}
{$categories = $this->Category->getCategories({PRODUCT}, {LANGUAGE}, [{FILTER} => ['parent_id' => 80]])}
{$category_name = 'Thiết bị y tế'}{$category_ids = []}
{foreach from = $categories item = category}
    {$category_ids[] = $category.id}
    {if $category.id == PAGE_CATEGORY_ID}{$category_name = $category.name}{/if}
{/foreach}
{$hero_equipment = []}
{foreach from = $equipment item = product}
    {if !empty($product.all_images[0])}{$hero_equipment[] = $product}{/if}
    {if count($hero_equipment) == 3}{break}{/if}
{/foreach}
{$keyword = $this->getRequest()->getQuery('keyword')}{if !is_string($keyword)}{$keyword = ''}{/if}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.css?v=20261028-sticky" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/equipment-catalog.css?v=20261117" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-cart-20261126.js" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.js?v=20261117-catalog" defer></script>

<main class="mbc mec" id="equipment-catalog-page" data-shop-catalog data-product-label="thiết bị" data-product-noun="thiết bị" data-cart-label="giỏ hàng">
    <section class="mbc-hero {if PAGE_CATEGORY_ID != 80}mbc-hero--category{/if}" aria-labelledby="equipment-title">
        <div class="mbc-shell mbc-hero-inner">
            <div class="mbc-hero-copy">
                <p class="mbc-eyebrow">MEDUC / THIẾT BỊ CHO SINH VIÊN Y</p>
                {if PAGE_CATEGORY_ID == 80}<h1 id="equipment-title">THIẾT BỊ Y TẾ.<span>CHO SINH VIÊN Y.</span></h1>
                {else}<a href="/thiet-bi-y-te" class="mbc-back">← Tất cả thiết bị y tế</a><h1 id="equipment-title">{$category_name|escape}</h1>{/if}
                <p class="mbc-hero-intro">Thiết bị phục vụ học tập, thực hành kỹ năng và đi lâm sàng của sinh viên Y khoa. Xem thông tin sản phẩm và chọn thiết bị phù hợp với môn học của bạn.</p>
                <div class="mbc-hero-actions"><a class="mbc-button" href="#equipment-catalog">Khám phá thiết bị <span aria-hidden="true">↓</span></a><span><strong>{count($equipment)}</strong> thiết bị đang mở bán</span></div>
            </div>
            {if PAGE_CATEGORY_ID == 80 && !empty($hero_equipment)}
                <div class="mbc-hero-art" aria-label="Thiết bị y tế tại MedUC">
                    <span class="mbc-art-backdrop" aria-hidden="true"></span>
                    {foreach from = $hero_equipment item = product}<a class="mbc-hero-book mec-hero-device" href="{$this->Utilities->checkInternalUrl($product.url)|escape}" aria-label="Xem thiết bị {$product.name|escape}"><img src="{CDN_URL}{$this->Utilities->getThumbs($product.all_images[0], 500)}" alt="{$product.name|escape}" decoding="async"></a>{/foreach}
                    <span class="mbc-art-note"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3v5a5 5 0 0 0 10 0V3M5 3H3m12 0h2M10 13v3a5 5 0 0 0 10 0v-2"/><circle cx="20" cy="11" r="2"/></svg>PHỤC VỤ HỌC TẬP.<br>HỖ TRỢ THỰC HÀNH.</span>
                </div>
            {/if}
        </div>
    </section>

    <nav class="mbc-topics" aria-label="Danh mục thiết bị y tế"><div class="mbc-shell mbc-topic-links">
        <a href="/thiet-bi-y-te" {if PAGE_CATEGORY_ID == 80}aria-current="page"{/if}>Tất cả thiết bị</a>
        {foreach from = $categories item = category}<a href="{$this->Utilities->checkInternalUrl($category.url)|escape}" {if PAGE_CATEGORY_ID == $category.id}aria-current="page"{/if}>{$category.name|escape}</a>{/foreach}
    </div></nav>

    <section class="mbc-shell mbc-catalog" id="equipment-catalog" aria-labelledby="equipment-catalog-title">
        <div class="mbc-section-heading"><div><p class="mbc-eyebrow">DANH MỤC THIẾT BỊ</p><h2 id="equipment-catalog-title">TÌM THIẾT BỊ<br><span>BẠN CẦN.</span></h2></div><p>Chọn thiết bị theo nhu cầu học tập và thực hành. Tra cứu tên sản phẩm, xem thông tin và giá trước khi chọn mua.</p></div>
        <div class="mbc-tools" data-book-tools hidden>
            <label class="mbc-search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></svg><span class="mbc-sr-only">Tìm thiết bị</span><input type="search" id="book-search" placeholder="Tìm theo tên hoặc loại thiết bị..." value="{$keyword|escape}" autocomplete="off"><button type="button" data-book-clear aria-label="Xóa từ khóa" hidden>×</button></label>
            <label class="mbc-select">Loại thiết bị<select id="book-stage"><option value="all">Tất cả loại thiết bị</option>{foreach from = $categories item = category}<option value="{$category.id}">{$category.name|escape}</option>{/foreach}</select></label>
            <label class="mbc-select">Sắp xếp<select id="book-sort"><option value="default">Theo MedUC</option><option value="name">Tên A–Z</option><option value="price-up">Giá thấp đến cao</option><option value="price-down">Giá cao đến thấp</option></select></label>
        </div>
        <div class="mbc-result-row"><p role="status" aria-live="polite" aria-atomic="true" data-book-status>Hiển thị {count($equipment)} thiết bị</p><a href="/dat-hang">Giỏ hàng của bạn <span aria-hidden="true">↗</span></a></div>
        <div class="mbc-grid" data-book-grid>
            {foreach from = $equipment item = product key = product_index}{$this->element('../block/product/item_equipment_catalog', ['product' => $product, 'product_index' => $product_index, 'category_ids' => $category_ids])}{/foreach}
        </div>
        <div class="mbc-empty" data-book-empty {if !empty($equipment)}hidden{/if}><span aria-hidden="true">↗</span><h3>Chưa có thiết bị phù hợp.</h3><p>Thử từ khóa khác hoặc xem thêm danh mục thiết bị.</p><button type="button" data-book-reset hidden>Xóa bộ lọc</button><a href="/thiet-bi-y-te">Xem tất cả thiết bị →</a></div>
        <button type="button" class="mbc-more" data-book-more hidden>Xem thêm thiết bị <span aria-hidden="true">↓</span></button>
    </section>

    <aside class="mbc-next"><div class="mbc-shell mbc-next-inner"><div><p class="mbc-eyebrow">KHÁM PHÁ THÊM CÙNG MEDUC</p><h2>THÊM KIẾN THỨC.<br><span>THÊM GÓC NHÌN.</span></h2><p>Tham khảo sách Y khoa theo môn học, củng cố kiến thức trước mỗi buổi thực hành và đi lâm sàng.</p></div><a class="mbc-button" href="/sach-y-khoa">Khám phá sách Y khoa <span aria-hidden="true">→</span></a></div></aside>
    <div class="mbc-cart-notice" data-book-cart-notice hidden><span role="status" aria-live="polite" aria-atomic="true" data-book-cart-message></span><a href="/dat-hang">Xem giỏ hàng →</a><button type="button" aria-label="Đóng thông báo" data-book-cart-close>×</button></div>
</main>
{/strip}
