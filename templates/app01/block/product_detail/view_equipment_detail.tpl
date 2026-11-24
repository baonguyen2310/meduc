{strip}
{$product = $data_block.data|default:[]}
{if !empty($product)}
    {$shop = $this->loadHelper('Book')}
    {$detail = $shop->prepareDetail($product, !empty($data_init.product.check_quantity), [
        'motakhoahoc' => 'Tính năng',
        'thongtinchitiet' => 'Thông tin chi tiết',
        'huongdansudung' => 'Hướng dẫn sử dụng',
        'thongsokythuat' => 'Thông số kỹ thuật',
        'videoreview' => 'Video review',
        'thongtinsach' => 'Thông tin bổ sung'
    ])}
    {$first = $detail.items[0]|default:[]}
    {$images = array_values($product.all_images|default:[])}
    {$category = []}
    {foreach from=$product.categories|default:[] item=entry}
        {if $entry.id != 80 && !empty($entry.status)}{$category = $entry}{break}{/if}
    {/foreach}
    {$companion_groups = []}
    {$links = [
        'combo_products' => ['title' => 'Thiết bị liên quan', 'id' => 'equipment-related', 'url' => '/thiet-bi-y-te'],
        'combo_course' => ['title' => 'Khóa học nên mua cùng', 'id' => 'equipment-courses', 'url' => '/khoa-hoc']
    ]}
    {foreach from=$links item=group key=attribute}
        {$ids = json_decode($product.attributes[$attribute].value|default:'', true)}
        {if is_array($ids) && !empty($ids)}
            {$items = $this->Product->getProducts([
                'get_item' => true,
                {FILTER} => ['ids' => $ids, 'not_ids' => [$product.id], 'draft' => '0'],
                'limit' => 12
            ])}
            {if !empty($items)}
                {$group.items = $shop->asCatalog($items)}
                {$companion_groups[] = $group}
            {/if}
        {/if}
    {/foreach}
    {$video = $product.url_video|default:''}
    {$youtube = $product.type_video == {VIDEO_YOUTUBE} && preg_match('/^[A-Za-z0-9_-]{11}$/D', $video)}
    {$local_video = $product.type_video == {VIDEO_SYSTEM} && !empty($video)}
    {$has_information = !empty($detail.sections) || $youtube || $local_video}

    <link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
    <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.css?v=20261028-sticky" rel="stylesheet">
    <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-detail.css?v=20261015" rel="stylesheet">
    <link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/equipment-detail.css?v=20261124" rel="stylesheet">
    <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-cart.js?v=20261117-catalog" defer></script>
    <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-detail.js?v=20261124-equipment" defer></script>

    <main class="mbd mbd-equipment" id="equipment-detail" data-book-items="{$detail.items|json_encode|escape}" data-book-name="{$product.name|escape}" data-product-noun="thiết bị" data-cart-label="giỏ hàng" data-stock-label="Thiết bị này">
        <nav class="mbd-shell mbd-breadcrumb" aria-label="Đường dẫn trang">
            <a href="/">Trang chủ</a><span aria-hidden="true">/</span><a href="/thiet-bi-y-te">Thiết bị y tế</a>
            {if !empty($category.url)}<span aria-hidden="true">/</span><a href="{$this->Utilities->checkInternalUrl($category.url)|escape}">{$category.name|escape}</a>{/if}
        </nav>
        <section class="mbd-shell mbd-hero" aria-labelledby="equipment-title">
            <div class="mbd-gallery">
                <div class="mbd-stage">
                    {if !empty($images)}
                        <button type="button" class="mbd-picture" data-book-main-zoom data-book-zoom="0" aria-label="Phóng to ảnh thiết bị">
                            <img data-book-main-image src="{CDN_URL}{$this->Utilities->getThumbs($images[0], 720)}" alt="{$product.name|escape}" fetchpriority="high" decoding="async">
                            <span class="mbd-zoom-icon" aria-hidden="true"><i class="fa-solid fa-magnifying-glass-plus"></i></span>
                        </button>
                        <div class="mbd-gallery-controls" data-book-gallery-controls hidden>
                            <button type="button" data-book-image-prev aria-label="Ảnh trước">←</button>
                            <span data-book-image-count aria-live="polite">01 / {count($images)|string_format:'%02d'}</span>
                            <button type="button" data-book-image-next aria-label="Ảnh tiếp theo">→</button>
                        </div>
                    {else}<p class="mbd-gallery-caption">Chưa có ảnh sản phẩm</p>{/if}
                </div>
                {if !empty($images)}
                    <div class="mbd-thumbnails{if count($images) == 1} mbd-single-thumbnail{/if}" role="group" aria-label="Chọn ảnh thiết bị">
                        {foreach from=$images item=image key=index}
                            <button type="button" data-book-image="{$index}" data-book-full-image="{CDN_URL}{$image|escape}" data-book-display-image="{CDN_URL}{$this->Utilities->getThumbs($image, 720)}" aria-pressed="{if $index == 0}true{else}false{/if}" aria-label="Xem ảnh {$index+1}">
                                <img src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}" alt="" loading="lazy" decoding="async">
                            </button>
                        {/foreach}
                    </div>
                {/if}
            </div>

            <div class="mbd-copy">
                <p class="mbd-eyebrow">{if !empty($category.name)}{$category.name|escape}{else}Thiết bị y tế{/if}</p>
                <h1 id="equipment-title">{$product.name|escape}</h1>
                {if !empty($product.rating) && !empty($product.rating_number)}
                    <p class="mbd-equipment-rating"><span aria-hidden="true">★</span> {$product.rating|number_format:1:',':'.'}/5 · {$product.rating_number|number_format:0:',':'.'} đánh giá</p>
                {/if}
                {if !empty($detail.summary)}<p class="mbd-lead">{$detail.summary|escape}</p>{/if}

                <div class="mbd-buy-box">
                    {if count($detail.items) > 1}
                        <label class="mbd-edition">Phiên bản
                            <select id="book-edition">
                                {foreach from=$detail.items item=item key=index}<option value="{$index}">{$item.label|escape}</option>{/foreach}
                            </select>
                        </label>
                    {/if}
                    <div class="mbd-price">
                        <strong data-book-current-price>{if !empty($first.current)}{$first.current|number_format:0:',':'.'}đ{else}Liên hệ tư vấn{/if}</strong>
                        <del data-book-old-price {if empty($first.discount)}hidden{/if}>{$first.price|default:0|number_format:0:',':'.'}đ</del>
                        <span data-book-discount {if empty($first.discount)}hidden{/if}>Giảm {$first.discount|default:0}%</span>
                    </div>
                    {if !empty($detail.items)}
                        <div class="mbd-order-controls" data-book-order-controls hidden>
                            <label class="mbd-quantity-label" for="book-quantity">Số lượng</label>
                            <div class="mbd-quantity">
                                <button type="button" data-book-quantity-minus aria-label="Giảm số lượng">−</button>
                                <input id="book-quantity" type="number" min="1" step="1" value="1" inputmode="numeric">
                                <button type="button" data-book-quantity-plus aria-label="Tăng số lượng">+</button>
                            </div>
                            <p class="mbd-stock" data-book-stock role="status" hidden></p>
                            <button type="button" class="mbd-button mbd-buy-now" data-book-purchase="buy">Mua ngay</button>
                            <button type="button" class="mbd-button mbd-add-cart" data-book-purchase="add">Thêm vào giỏ</button>
                        </div>
                        <noscript><p>Vui lòng bật JavaScript để mua thiết bị.</p></noscript>
                    {/if}
                </div>
                {if !empty($detail.promotion)}
                    <details class="mbd-promotion" open><summary>Ưu đãi <span aria-hidden="true">+</span></summary><div class="mbd-rich">{$detail.promotion}</div></details>
                {/if}
                <div class="mbd-store-links">
                    {foreach from=['facebook'=>'Facebook', 'shopee'=>'Shopee', 'tiktok'=>'TikTok'] item=label key=store}
                        {$enabled = "ban_tren_{$store}"}{$store_link = "link_{$store}"}
                        {if !empty($product.attributes[$enabled].value) && !empty($product.attributes[$store_link].value)}
                            <a href="{$product.attributes[$store_link].value|escape}" target="_blank" rel="noopener noreferrer">Mua qua {$label}</a>
                        {/if}
                    {/foreach}
                </div>
                {$member = $this->Member->getMemberInfo()}
                {if !empty($member.code)}
                    {$affiliate = preg_replace('/\?.*$/', '', $this->Utilities->getUrlCurrent())|cat:'?a='|cat:urlencode($member.code)}
                    <button type="button" class="mbd-affiliate" button-copy-link data-link="{$affiliate|escape}">Sao chép liên kết giới thiệu</button>
                {/if}
            </div>
        </section>

        {if $has_information || !empty($companion_groups)}
            <nav class="mbd-section-nav" aria-label="Nội dung chi tiết thiết bị"><div class="mbd-shell">
                {if $has_information}<a href="#equipment-information">Thông tin thiết bị</a>{/if}
                {foreach from=$companion_groups item=group}<a href="#{$group.id}">{$group.title}</a>{/foreach}
                <a href="#equipment-comments">Hỏi đáp</a>
            </div></nav>
        {/if}

        {if $has_information}
            <section class="mbd-shell mbd-information" id="equipment-information" aria-labelledby="equipment-information-title">
                <div class="mbd-section-heading"><h2 id="equipment-information-title">Thông tin <span>thiết bị</span></h2></div>
                {if !empty($detail.sections)}
                    <div class="mbd-tabs" role="tablist" aria-label="Thông tin thiết bị" data-book-tabs hidden>
                        {foreach from=$detail.sections item=section key=index}
                            <button type="button" role="tab" id="book-tab-{$section.code}" data-book-tab="{$section.code}" aria-controls="book-panel-{$section.code}" aria-selected="{if $index==0}true{else}false{/if}" tabindex="{if $index==0}0{else}-1{/if}">{$section.label|escape}</button>
                        {/foreach}
                    </div>
                    <div class="mbd-panels">
                        {foreach from=$detail.sections item=section}
                            <section class="mbd-panel" id="book-panel-{$section.code}" data-book-panel="{$section.code}" aria-labelledby="book-panel-title-{$section.code}">
                                <h3 id="book-panel-title-{$section.code}">{$section.label|escape}</h3>
                                <div class="mbd-rich">{$section.html}</div>
                            </section>
                        {/foreach}
                    </div>
                {/if}
                {if $youtube || $local_video}
                    <div class="mbd-panel mbd-rich">
                        {if $youtube}<iframe src="https://www.youtube-nocookie.com/embed/{$video|escape}" title="Video giới thiệu thiết bị" loading="lazy" allowfullscreen></iframe>
                        {else}<video src="{CDN_URL}{$video|escape}" controls playsinline preload="none"></video>{/if}
                    </div>
                {/if}
            </section>
        {/if}

        {foreach from=$companion_groups item=group}
            <section class="mbd-related" id="{$group.id}" aria-labelledby="{$group.id}-title"><div class="mbd-shell">
                <div class="mbd-section-heading"><h2 id="{$group.id}-title">{$group.title}</h2><a class="mbd-text-link" href="{$group.url}">Xem tất cả →</a></div>
                <div class="mbd-course-grid">
                    {foreach from=$group.items item=related}
                        {$sale = !empty($related.apply_special) && $related.price_special > 0 && $related.price_special < $related.price}
                        {$price = $related.price}
                        {if $sale}{$price = $related.price_special}{/if}
                        <article class="mbd-course-card">
                            <a href="{$this->Utilities->checkInternalUrl($related.url)|escape}">
                                {if !empty($related.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($related.all_images[0], 500)}" alt="" loading="lazy" decoding="async">{/if}
                                <div><h3>{$related.name|escape}</h3><p>{if $price > 0}{$price|number_format:0:',':'.'}đ{else}Liên hệ tư vấn{/if}{if $sale}<del>{$related.price|number_format:0:',':'.'}đ</del>{/if}</p></div>
                            </a>
                        </article>
                    {/foreach}
                </div>
            </div></section>
        {/foreach}

        <div class="mbc"><div class="mbc-cart-notice" data-book-cart-notice hidden>
            <span role="status" aria-live="polite" aria-atomic="true" data-book-cart-message></span><a href="/dat-hang">Xem giỏ hàng →</a><button type="button" aria-label="Đóng thông báo" data-book-cart-close>×</button>
        </div></div>
        <dialog class="mbd-dialog" id="book-image-dialog" aria-label="Ảnh thiết bị phóng to">
            <button type="button" class="mbd-dialog-close" data-book-dialog-close aria-label="Đóng ảnh phóng to">×</button>
            <button type="button" class="mbd-dialog-prev" data-book-dialog-prev aria-label="Ảnh trước">←</button>
            <img data-book-dialog-image alt="">
            <button type="button" class="mbd-dialog-next" data-book-dialog-next aria-label="Ảnh tiếp theo">→</button>
            <p data-book-dialog-caption></p>
        </dialog>
    </main>
{else}
    <div class="mbd mbd-missing"><p>Chưa tìm thấy thông tin thiết bị.</p><a href="/thiet-bi-y-te">Quay lại danh mục thiết bị</a></div>
{/if}
{/strip}
