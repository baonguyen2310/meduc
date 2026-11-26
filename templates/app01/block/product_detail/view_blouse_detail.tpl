{strip}
{$product=$data_block.data|default:[]}
{if !empty($product)}{$detail=$this->loadHelper('Blouse')->prepare($product)}{$gallery=$detail.gallery}
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-catalog.css?v=20261028-sticky" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-detail.css?v=20261015" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blouse-20261126.css" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/book-cart-20261126.js" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/blouse-detail-20261126.js" defer></script>
<main class="mbd mbl-detail" id="blouse-detail" data-blouse="{$detail.payload|json_encode|escape}" data-product-noun="áo blouse" data-cart-label="giỏ hàng">
    <nav class="mbd-shell mbd-breadcrumb" aria-label="Đường dẫn"><a href="/">Trang chủ</a><span>/</span><a href="/ao-blouse">Áo blouse</a></nav>
    <section class="mbd-shell mbd-hero" aria-labelledby="blouse-product-title">
        <div class="mbd-gallery">
            <div class="mbd-stage"><span class="mbd-stage-label">MEDUC / ÁO BLOUSE</span>{if !empty($gallery)}<a class="mbd-picture" data-blouse-photo-link href="{$gallery[0].full|escape}" target="_blank" rel="noopener"><img data-blouse-photo src="{$gallery[0].large|escape}" alt="{$product.name|escape}"></a>{else}<div class="mbd-picture-empty">ÁO BLOUSE<span>Ảnh sản phẩm đang cập nhật</span></div>{/if}</div>
            <div class="mbd-thumbnails" data-blouse-thumbnails aria-label="Chọn ảnh áo blouse"{if count($gallery)<2} hidden{/if}>{foreach from=$gallery item=image key=index}<button type="button" data-blouse-image="{$image.large|escape}" data-blouse-full-image="{$image.full|escape}" aria-label="Xem ảnh {$index+1}" aria-pressed="{if $index==0}true{else}false{/if}"><img src="{$image.small|escape}" alt="" loading="lazy"></button>{/foreach}</div>
            {if !empty($product.description)}<p class="mbl-size-help">{$product.description|escape}</p>{/if}
        </div>
        <div class="mbd-copy"><p class="mbd-eyebrow">ÁO BLOUSE · CHO SINH VIÊN Y KHOA</p><h1 id="blouse-product-title">{$product.name|escape}</h1>
            <div class="mbd-price mbl-price"><strong data-blouse-price>{if $detail.has_price}Chọn mẫu để xem giá{else}Giá đang cập nhật{/if}</strong><del data-blouse-old hidden></del><span data-blouse-discount hidden></span></div>
            <p class="mbl-price-extra" data-blouse-extra hidden></p>
            <div class="mbd-buy-box mbl-buy-box">
                {if !empty($detail.items)}
                    {foreach from=$detail.attributes item=attribute}
                        <fieldset class="mbl-option mbl-option--{$attribute.kind}" data-blouse-attribute="{$attribute.id}">
                            <legend><span>{$attribute.label|escape}</span>{if $attribute.kind!='size'}<strong data-blouse-chosen></strong>{/if}{if $attribute.kind=='size' && $detail.size_guide}<a href="#blouse-size-guide" data-blouse-size-guide>Bảng size</a>{/if}</legend>
                            <div class="mbl-choices">{foreach from=$attribute.options item=option}{if $attribute.kind=='color' && $option.swatch}<button type="button" class="mbl-swatch" data-blouse-option="{$option.id}" aria-pressed="false" aria-label="{$option.name|escape}" title="{$option.name|escape}" style="--mbl-swatch:{$option.swatch}" disabled><span aria-hidden="true"></span></button>{else}<button type="button" class="mbl-choice" data-blouse-option="{$option.id}" aria-pressed="false" disabled>{$option.name|escape}<small data-blouse-note></small></button>{/if}{/foreach}</div>
                        </fieldset>
                    {/foreach}
                    {if $detail.embroidery_fee>0}
                        <div class="mbl-embroidery">
                            <label for="blouse-embroidery">Thêu tên <span>(tùy chọn)</span></label>
                            <input id="blouse-embroidery" type="text" data-blouse-embroidery maxlength="{$detail.embroidery_max}" placeholder="Tên thêu trên ngực trái" autocomplete="off" spellcheck="false" aria-describedby="blouse-embroidery-help blouse-embroidery-error">
                            <p id="blouse-embroidery-help">Thêu tên: +{$detail.embroidery_fee|number_format:0:',':'.'}đ / áo · tối đa {$detail.embroidery_max} ký tự.</p>
                            <p class="mbl-embroidery-error" id="blouse-embroidery-error" data-blouse-embroidery-error role="alert" hidden></p>
                        </div>
                    {/if}
                    <p class="mbd-stock" data-blouse-stock role="status">{if $detail.has_price}Chọn đủ mẫu và size trước khi đặt mua.{else}MedUC đang cập nhật giá và tình trạng của từng mẫu.{/if}</p>
                    <div class="mbd-order-controls" data-blouse-controls hidden><label class="mbd-quantity-label" for="blouse-quantity">Số lượng</label><div class="mbd-quantity"><button type="button" data-blouse-minus aria-label="Giảm số lượng áo">−</button><input id="blouse-quantity" type="number" min="1" step="1" value="1" inputmode="numeric" disabled><button type="button" data-blouse-plus aria-label="Tăng số lượng áo">+</button></div><button type="button" class="mbd-button mbd-buy-now" data-blouse-purchase="buy" disabled>Đặt mua <span aria-hidden="true">→</span></button><button type="button" class="mbd-button mbd-add-cart" data-blouse-purchase="add" disabled>Thêm vào giỏ hàng <span aria-hidden="true">+</span></button></div>
                {else}<p>Mẫu, size và giá của áo này đang được cập nhật.</p>{/if}
                <noscript><p>Vui lòng bật JavaScript để chọn mẫu và đặt mua.</p></noscript>
            </div>
            <p class="mbl-size-help">{if $detail.size_guide}Xem <a href="#blouse-size-guide">bảng size</a> trước khi chọn.{else}Xem bảng size trong thông tin sản phẩm trước khi chọn.{/if} Nếu chưa chắc size, hãy liên hệ MedUC để được tư vấn.</p>
        </div>
    </section>
    {if !empty($detail.sections)}<section class="mbd-shell mbl-information" aria-label="Thông tin áo blouse">{foreach from=$detail.sections item=section}<details class="mbd-promotion"{if $section.code=='thongsokythuat'} id="blouse-size-guide"{/if} open><summary>{$section.label|escape}<span aria-hidden="true">+</span></summary><div class="mbd-rich">{$section.html}</div></details>{/foreach}</section>{/if}
    <div class="mbc"><div class="mbc-cart-notice" data-book-cart-notice hidden><span role="status" aria-live="polite" data-book-cart-message></span><a href="/dat-hang">Xem giỏ hàng →</a><button type="button" aria-label="Đóng thông báo" data-book-cart-close>×</button></div></div>
</main>
{else}<div class="mbc mbc-empty"><h1>Chưa tìm thấy mẫu áo.</h1><a href="/ao-blouse">Xem các mẫu áo blouse →</a></div>{/if}
{/strip}
