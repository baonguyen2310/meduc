{strip}
{$url = $this->Utilities->checkInternalUrl($product.url)}
{$price = $product.price|default:0}
{if !empty($product.apply_special) && !empty($product.price_special)}{$price = $product.price_special}{/if}
{$discount = 0}{if $product.price > $price && $price > 0}{$discount = round(($product.price - $price) * 100 / $product.price)}{/if}
{$category_name = 'Thiết bị y tế'}{$product_category_ids = []}{$category_names = []}
{foreach from = $product.categories item = category}{$product_category_ids[] = $category.id}{$category_names[] = $category.name}{/foreach}
{$category_search = implode(' ', $category_names)}{$category_filter = implode(',', $product_category_ids)}
{foreach from = $category_ids item = category_id}{if !empty($product.categories[$category_id])}{$category_name = $product.categories[$category_id].name}{break}{/if}{/foreach}
{$cart_product = ['id' => $product.items[0].id|default:0, 'name' => $product.name, 'image' => $product.all_images[0]|default:'', 'quantity' => 1, 'price' => $product.price|default:0, 'price_special' => $price, 'url' => $url]}
<article class="mbc-card" data-book-card data-book-id="{$product.id}" data-book-search="{$product.name|escape} {$category_search|escape}" data-book-name="{$product.name|escape}" data-book-categories="{$category_filter|escape}" data-book-price="{$price}" data-book-order="{$product_index}">
    <a class="mbc-cover" href="{$url|escape}" aria-label="Xem thiết bị {$product.name|escape}">
        {if !empty($product.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($product.all_images[0], 500)}" alt="{$product.name|escape}" loading="lazy" decoding="async">{else}<span class="mbc-cover-placeholder">MEDUC<span>{$product.name|escape}</span></span>{/if}
        {if $discount > 0}<span class="mbc-discount">Giảm {$discount}%</span>{/if}
    </a>
    <div class="mbc-card-body">
        <span class="mbc-subject">{$category_name|escape}</span>
        <h3><a href="{$url|escape}" title="{$product.name|escape}">{$product.name|escape}</a></h3>
        <div class="mbc-prices">{if $price > 0}<strong>{$price|number_format:0:',':'.'}<small>đ</small></strong>{else}<strong class="mbc-price-contact">Liên hệ tư vấn</strong>{/if}{if $discount > 0}<del>{$product.price|number_format:0:',':'.'}đ</del>{/if}</div>
        <a class="mbc-detail" href="{$url|escape}">Xem chi tiết thiết bị <span aria-hidden="true">→</span></a>
        {if $price > 0 && count($product.items) == 1 && !empty($product.items[0].id)}
            <button class="mbc-add" type="button" data-book-add data-book-product="{$cart_product|json_encode|escape}" aria-label="Thêm vào giỏ: {$product.name|escape}" hidden>Thêm vào giỏ <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 8h14l1 13H4L5 8Zm3 0V6a4 4 0 0 1 8 0v2"/></svg></button>
        {else}<a class="mbc-add" href="{$url|escape}">Chọn thiết bị <span aria-hidden="true">→</span></a>{/if}
    </div>
</article>
{/strip}
