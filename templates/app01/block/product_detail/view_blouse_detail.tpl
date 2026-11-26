{strip}
{$product=$data_block.data|default:[]}
{if !empty($product)}{$detail=$this->loadHelper('Blouse')->prepare($product)}{$images=array_values($product.all_images|default:[])}
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.css?v=20261028-sticky" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-detail.css?v=20261015" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blouse.css?v=20261117-models" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-cart.js?v=20261117-blouse" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blouse-detail.js?v=20261117" defer></script>
<main class="mbd mbl-detail" id="blouse-detail" data-blouse-items="{$detail.items|json_encode|escape}" data-product-noun="áo blouse" data-cart-label="giỏ hàng">
    <nav class="mbd-shell mbd-breadcrumb" aria-label="Đường dẫn"><a href="/">Trang chủ</a><span>/</span><a href="/ao-blouse">Áo blouse</a></nav>
    <section class="mbd-shell mbd-hero" aria-labelledby="blouse-product-title">
        <div class="mbd-gallery"><div class="mbd-stage"><span class="mbd-stage-label">MEDUC / ÁO BLOUSE</span>{if !empty($images)}<a class="mbd-picture" data-blouse-photo-link href="{CDN_URL}{$images[0]|escape}" target="_blank" rel="noopener"><img data-blouse-photo src="{CDN_URL}{$this->Utilities->getThumbs($images[0],720)}" alt="{$product.name|escape}"></a>{else}<div class="mbd-picture-empty">ÁO BLOUSE<span>Ảnh sản phẩm đang cập nhật</span></div>{/if}</div>{if !empty($product.description)}<p class="mbl-size-help">{$product.description|escape}</p>{/if}
        {if count($images)>1}<div class="mbd-thumbnails" aria-label="Chọn ảnh áo blouse">{foreach from=$images item=image key=index}<button type="button" data-blouse-image="{CDN_URL}{$this->Utilities->getThumbs($image,720)}" data-blouse-full-image="{CDN_URL}{$image|escape}" aria-label="Xem ảnh {$index+1}" aria-pressed="{if $index==0}true{else}false{/if}"><img src="{CDN_URL}{$this->Utilities->getThumbs($image,150)}" alt="" loading="lazy"></button>{/foreach}</div>{/if}</div>
        <div class="mbd-copy"><p class="mbd-eyebrow">CHO SINH VIÊN Y KHOA</p><h1 id="blouse-product-title">{$product.name|escape}</h1>
            <div class="mbd-buy-box"><p class="mbd-buy-heading">CHỌN SIZE ÁO CỦA BẠN</p>
                {if !empty($detail.items)}<fieldset class="mbl-size-picker"><legend>Size áo <span aria-hidden="true">*</span></legend><div class="mbl-sizes">{foreach from=$detail.items item=item key=index}<button type="button" data-blouse-size="{$index}" aria-pressed="false" {if !$item.available}disabled{/if}>{$item.label|escape}{if !$item.available}<small>{if $item.current<=0}Chưa có giá{elseif $item.maximum==0}Hết hàng{else}Chưa mở bán{/if}</small>{/if}</button>{/foreach}</div></fieldset>
                <div class="mbd-price"><strong data-blouse-price>{if $detail.has_price}Chọn size để xem giá{else}Giá đang cập nhật{/if}</strong><del data-blouse-old hidden></del><span data-blouse-discount hidden></span></div>
                <p class="mbd-stock" data-blouse-stock role="status">{if $detail.has_price}Vui lòng chọn size trước khi thêm vào giỏ.{else}MedUC đang cập nhật giá và tình trạng của từng size.{/if}</p>
                <div class="mbd-order-controls" data-blouse-controls hidden><label class="mbd-quantity-label" for="blouse-quantity">Số lượng</label><div class="mbd-quantity"><button type="button" data-blouse-minus aria-label="Giảm số lượng áo">−</button><input id="blouse-quantity" type="number" min="1" step="1" value="1" inputmode="numeric" disabled><button type="button" data-blouse-plus aria-label="Tăng số lượng áo">+</button></div><button type="button" class="mbd-button mbd-buy-now" data-blouse-purchase="buy" disabled>Mua ngay <span aria-hidden="true">→</span></button><button type="button" class="mbd-button mbd-add-cart" data-blouse-purchase="add" disabled>Thêm vào giỏ hàng <span aria-hidden="true">+</span></button></div>
                {else}<p>Size và giá của mẫu áo này đang được cập nhật.</p>{/if}
                <noscript><p>Vui lòng bật JavaScript để chọn size và đặt mua.</p></noscript>
            </div>
            <p class="mbl-size-help">Xem bảng size trong thông tin sản phẩm trước khi chọn. Nếu chưa chắc size, hãy liên hệ MedUC để được tư vấn.</p>
        </div>
    </section>
    {if !empty($detail.sections)}<section class="mbd-shell mbl-information" aria-label="Thông tin áo blouse">{foreach from=$detail.sections item=section}<details class="mbd-promotion" open><summary>{$section.label|escape}<span aria-hidden="true">+</span></summary><div class="mbd-rich">{$section.html}</div></details>{/foreach}</section>{/if}
    <div class="mbc"><div class="mbc-cart-notice" data-book-cart-notice hidden><span role="status" aria-live="polite" data-book-cart-message></span><a href="/dat-hang">Xem giỏ hàng →</a><button type="button" aria-label="Đóng thông báo" data-book-cart-close>×</button></div></div>
</main>
{else}<div class="mbc mbc-empty"><h1>Chưa tìm thấy mẫu áo.</h1><a href="/ao-blouse">Xem các mẫu áo blouse →</a></div>{/if}
{/strip}
