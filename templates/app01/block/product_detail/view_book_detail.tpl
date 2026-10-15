{strip}
{$product = $data_block.data|default:[]}
{if !empty($product)}
{$book_view = $this->loadHelper('Book')}
{$detail = $book_view->prepareDetail($product, !empty($data_init.product.check_quantity))}
{$first = $detail.items[0]|default:[]}
{$images = array_values($product.all_images|default:[])}
{$subject_ids = []}{$subject = []}
{foreach from = $product.categories item = category}{if in_array($category.id, [81,82,83,84,85,86]) && !empty($category.status)}{$subject_ids[] = $category.id}{if empty($subject)}{$subject = $category}{/if}{/if}{/foreach}
{$recommend_filter = ['id_categories' => [79], 'not_ids' => [$product.id], 'draft' => '0']}
{if !empty($subject_ids)}{$recommend_filter.id_categories = $subject_ids}{/if}
{$combo_books = json_decode($product.attributes.combo_products.value|default:'', true)|default:[]}
{if !empty($combo_books)}{$recommend_filter = ['ids' => $combo_books, 'not_ids' => [$product.id], 'draft' => '0']}{/if}
{$related_books = $this->Product->getProducts(['get_item' => true, 'get_categories' => true, {FILTER} => $recommend_filter, {SORT} => [{FIELD} => 'position', {SORT} => 'DESC'], 'limit' => 4])}
{$related_books = $book_view->asCatalog($related_books)}
{$course_ids = json_decode($product.attributes.combo_course.value|default:'', true)|default:[]}
{$courses = []}
{if !empty($course_ids)}{$courses = $this->Product->getProducts(['get_item' => true, {FILTER} => ['ids' => $course_ids, 'draft' => '0'], 'limit' => 12])}{/if}
{$courses = $book_view->asCatalog($courses)}
{$website = $this->Setting->getWebsiteInfo()}
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.css?v=20261015" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-detail.css?v=20261015" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-cart.js?v=20261015" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-detail.js?v=20261015" defer></script>

<main class="mbd" id="book-detail" data-book-items="{$detail.items|json_encode|escape}" data-book-name="{$product.name|escape}">
    <nav class="mbd-shell mbd-breadcrumb" aria-label="Đường dẫn trang"><a href="/">Trang chủ</a><span aria-hidden="true">/</span><a href="/sach-y-khoa">Sách Y khoa</a>{if !empty($subject)}<span aria-hidden="true">/</span><a href="{$this->Utilities->checkInternalUrl($subject.url)|escape}">{$subject.name|escape}</a>{/if}</nav>
    <section class="mbd-shell mbd-hero" aria-labelledby="book-title">
        <div class="mbd-gallery">
            <div class="mbd-stage">
                <span class="mbd-stage-label">MEDUC / SÁCH Y KHOA</span>
                {if !empty($images)}
                    <button type="button" class="mbd-picture" data-book-main-zoom data-book-zoom="0" aria-label="Phóng to ảnh sách"><img data-book-main-image src="{CDN_URL}{$this->Utilities->getThumbs($images[0], 720)}" alt="Bìa sách {$product.name|escape}" decoding="async"><span class="mbd-zoom-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="10" cy="10" r="6.5"/><path d="m15 15 6 6M10 7v6M7 10h6"/></svg></span></button>
                    <div class="mbd-gallery-controls" data-book-gallery-controls hidden><button type="button" data-book-image-prev aria-label="Ảnh sách trước">←</button><span data-book-image-count aria-live="polite">01 / {count($images)|string_format:'%02d'}</span><button type="button" data-book-image-next aria-label="Ảnh sách tiếp theo">→</button></div>
                {else}<div class="mbd-picture-empty">MEDUC<span>SÁCH Y KHOA</span></div>{/if}
            </div>
            {if !empty($images)}<div class="mbd-thumbnails" role="group" aria-label="Chọn ảnh sách">{foreach from = $images item = image key = index}<button type="button" data-book-image="{$index}" data-book-full-image="{CDN_URL}{$image|escape}" data-book-display-image="{CDN_URL}{$this->Utilities->getThumbs($image, 720)}" aria-pressed="{if $index == 0}true{else}false{/if}" aria-label="Xem ảnh sách {$index+1}"><img src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}" alt="" loading="lazy" decoding="async"></button>{/foreach}</div><p class="mbd-gallery-caption">Chọn ảnh để xem gần hơn · {count($images)} hình ảnh</p>{/if}
        </div>
        <div class="mbd-copy">
            <p class="mbd-eyebrow">{if !empty($subject)}{$subject.name|escape}{else}SÁCH Y KHOA MEDUC{/if}</p>
            <h1 id="book-title">{$product.name|escape}</h1>
            {if !empty($detail.facts)}<dl class="mbd-facts">{foreach from = $detail.facts item = value key = label}<div><dt>{$label|escape}</dt><dd>{$value|escape}</dd></div>{/foreach}</dl>{/if}
            {if !empty($detail.summary)}<p class="mbd-lead">{$detail.summary|escape}</p>{/if}
            <div class="mbd-buy-box" id="book-buy">
                <p class="mbd-buy-heading">CHỌN SÁCH ĐỒNG HÀNH CÙNG BẠN</p>
                {if count($detail.items) > 1}<label class="mbd-edition">Ấn bản<select id="book-edition">{foreach from = $detail.items item = item key = index}<option value="{$index}">{$item.label|escape}</option>{/foreach}</select></label>{/if}
                <div class="mbd-price"><strong data-book-current-price>{if !empty($first.current)}{$first.current|number_format:0:',':'.'}đ{else}Liên hệ tư vấn{/if}</strong><del data-book-old-price {if empty($first.discount)}hidden{/if}>{$first.price|default:0|number_format:0:',':'.'}đ</del><span data-book-discount {if empty($first.discount)}hidden{/if}>Giảm {$first.discount|default:0}%</span></div>
                {if !empty($detail.items)}
                    <div class="mbd-order-controls" data-book-order-controls hidden>
                        <label class="mbd-quantity-label" for="book-quantity">Số lượng</label><div class="mbd-quantity"><button type="button" data-book-quantity-minus aria-label="Giảm số lượng sách">−</button><input id="book-quantity" type="number" min="1" step="1" value="1" inputmode="numeric"><button type="button" data-book-quantity-plus aria-label="Tăng số lượng sách">+</button></div>
                        <p class="mbd-stock" data-book-stock role="status" hidden></p>
                        <button type="button" class="mbd-button mbd-buy-now" data-book-purchase="buy">Mua sách ngay <span aria-hidden="true">→</span></button>
                        <button type="button" class="mbd-button mbd-add-cart" data-book-purchase="add">Thêm vào giỏ sách <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 8h14l1 13H4L5 8Zm3 0V6a4 4 0 0 1 8 0v2"/></svg></button>
                    </div>
                {/if}
                <noscript><p>Vui lòng bật JavaScript để chọn mua sách{if !empty($website.hotline)}, hoặc gọi <a href="tel:{$website.hotline|escape}">{$website.hotline|escape}</a>{/if} để được hỗ trợ.</p></noscript>
            </div>
            {if !empty($detail.promotion)}<details class="mbd-promotion" open><summary>Ưu đãi khi mua sách <span aria-hidden="true">+</span></summary><div class="mbd-rich">{$detail.promotion}</div></details>{/if}
            <div class="mbd-store-links">{foreach from = ['facebook'=>'Facebook', 'shopee'=>'Shopee', 'tiktok'=>'TikTok'] item = label key = store}{$enabled = "ban_tren_{$store}"}{$store_link = "link_{$store}"}{if !empty($product.attributes[$enabled].value) && !empty($product.attributes[$store_link].value)}<a href="{$product.attributes[$store_link].value|escape}" target="_blank" rel="noopener noreferrer">Mua qua {$label} ↗</a>{/if}{/foreach}</div>
            {$member = $this->Member->getMemberInfo()}
            {if !empty($member.code)}{$affiliate = preg_replace('/\?.*$/', '', $this->Utilities->getUrlCurrent())|cat:'?a='|cat:urlencode($member.code)}<button type="button" class="mbd-affiliate" button-copy-link data-link="{$affiliate|escape}">Sao chép liên kết giới thiệu ↗</button>{/if}
        </div>
    </section>

    <nav class="mbd-section-nav" aria-label="Nội dung chi tiết sách"><div class="mbd-shell">
        <a href="#book-information">Thông tin sách</a>{if count($images)>1}<a href="#book-photos">Ảnh sách</a>{/if}{if !empty($courses)}<a href="#book-courses">Khóa học nên mua cùng</a>{/if}{if !empty($related_books)}<a href="#book-related">{if !empty($combo_books)}Sách nên mua cùng{else}Sách cùng chủ đề{/if}</a>{/if}<a href="#book-comments">Hỏi đáp</a>
    </div></nav>

    <section class="mbd-shell mbd-information" id="book-information" aria-labelledby="book-information-title">
        <div class="mbd-section-heading"><div><p class="mbd-eyebrow">01 / KHÁM PHÁ CUỐN SÁCH</p><h2 id="book-information-title">ĐỌC GẦN HƠN.<br><span>HIỂU SÂU HƠN.</span></h2></div><p>Giới thiệu, thông tin và review để bạn chọn cuốn sách phù hợp.</p></div>
        {if !empty($detail.sections)}
            <div class="mbd-tabs" role="tablist" aria-label="Thông tin và review sách" data-book-tabs hidden>{foreach from = $detail.sections item = section key = index}<button type="button" role="tab" id="book-tab-{$section.code}" data-book-tab="{$section.code}" aria-controls="book-panel-{$section.code}" aria-selected="{if $index==0}true{else}false{/if}" tabindex="{if $index==0}0{else}-1{/if}">{$section.label|escape}</button>{/foreach}</div>
            <div class="mbd-panels">{foreach from = $detail.sections item = section}<section class="mbd-panel" id="book-panel-{$section.code}" data-book-panel="{$section.code}" aria-labelledby="book-panel-title-{$section.code}"><h3 id="book-panel-title-{$section.code}">{$section.label|escape}</h3><div class="mbd-rich">{$section.html}</div></section>{/foreach}</div>
        {else}<div class="mbd-content-empty"><p>Thông tin chi tiết đang được cập nhật. Bạn có thể xem ảnh sách{if !empty($website.hotline)} hoặc gọi <a href="tel:{$website.hotline|escape}">{$website.hotline|escape}</a>{/if} để được tư vấn về ấn bản.</p></div>{/if}
    </section>

    {if count($images)>1}<section class="mbd-photos" id="book-photos" aria-labelledby="book-photos-title"><div class="mbd-shell"><div class="mbd-section-heading"><div><p class="mbd-eyebrow">NHÌN GẦN HƠN</p><h2 id="book-photos-title">LẬT XEM.<br><span>TRƯỚC KHI CHỌN.</span></h2></div><p>Bìa sách, các góc chụp và trang bên trong qua hình ảnh từ MedUC.</p></div><div class="mbd-photo-grid">{foreach from = $images item = image key = index}{if $index>0 && $index<=6}<button type="button" class="mbd-photo" data-book-zoom="{$index}" aria-label="Phóng to ảnh sách {$index+1}"><span><img src="{CDN_URL}{$this->Utilities->getThumbs($image, 500)}" alt="Ảnh {$index+1} của {$product.name|escape}" loading="lazy" decoding="async"></span><strong>Ảnh {$index+1|string_format:'%02d'} <span aria-hidden="true">↗</span></strong></button>{/if}{/foreach}</div>{if count($images)>7}<button type="button" class="mbd-all-images" data-book-zoom="0">Xem toàn bộ {count($images)} ảnh →</button>{/if}</div></section>{/if}

    {if !empty($courses)}<section class="mbd-shell mbd-courses" id="book-courses" aria-labelledby="book-courses-title"><div class="mbd-section-heading"><div><p class="mbd-eyebrow">GỢI Ý TỪ MEDUC</p><h2 id="book-courses-title">KHÓA HỌC<br><span>NÊN MUA CÙNG.</span></h2></div><a class="mbd-text-link" href="/khoa-hoc">Xem tất cả khóa học →</a></div><div class="mbd-course-grid">{foreach from = $courses item = course}{$course_price=$course.price|default:0}{if !empty($course.apply_special) && !empty($course.price_special)}{$course_price=$course.price_special}{/if}<article class="mbd-course-card"><a href="{$this->Utilities->checkInternalUrl($course.url)|escape}">{if !empty($course.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($course.all_images[0], 500)}" alt="Ảnh khóa học {$course.name|escape}" loading="lazy">{/if}<div><h3>{$course.name|escape}</h3>{if $course_price>0}<p>{$course_price|number_format:0:',':'.'}đ</p>{/if}<span>Xem khóa học <span aria-hidden="true">→</span></span></div></a></article>{/foreach}</div></section>{/if}

    {if !empty($related_books)}<section class="mbd-related" id="book-related" aria-labelledby="book-related-title"><div class="mbd-shell"><div class="mbd-section-heading"><div><p class="mbd-eyebrow">TIẾP TỤC KHÁM PHÁ</p><h2 id="book-related-title">{if !empty($combo_books)}SÁCH<br><span>NÊN MUA CÙNG.</span>{else}CÙNG CHỦ ĐỀ.<br><span>THÊM GÓC NHÌN.</span>{/if}</h2></div><a class="mbd-text-link" href="/sach-y-khoa">Xem tất cả sách →</a></div><div class="mbc mbd-related-books"><div class="mbc-grid">{foreach from=$related_books item=book key=book_index}{$this->element('../block/product/item_book_catalog', ['book'=>$book,'book_index'=>$book_index,'subject_ids'=>[81,82,83,84,85,86]])}{/foreach}</div></div></div></section>{/if}

    <div class="mbc"><div class="mbc-cart-notice" data-book-cart-notice hidden><span role="status" aria-live="polite" aria-atomic="true" data-book-cart-message></span><a href="/dat-hang">Xem giỏ sách →</a><button type="button" aria-label="Đóng thông báo" data-book-cart-close>×</button></div></div>
    <dialog class="mbd-dialog" id="book-image-dialog" aria-label="Xem ảnh sách phóng to"><button type="button" class="mbd-dialog-close" data-book-dialog-close aria-label="Đóng ảnh phóng to">×</button><button type="button" class="mbd-dialog-prev" data-book-dialog-prev aria-label="Ảnh phóng to trước">←</button><img data-book-dialog-image alt=""><button type="button" class="mbd-dialog-next" data-book-dialog-next aria-label="Ảnh phóng to tiếp theo">→</button><p data-book-dialog-caption></p></dialog>
</main>
{else}<div class="mbd mbd-missing"><p>Chưa tìm thấy thông tin cuốn sách này.</p><a href="/sach-y-khoa">Quay lại danh sách sách →</a></div>{/if}
{/strip}
