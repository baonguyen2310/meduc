{strip}
{$url = $this->Utilities->checkInternalUrl($book.url)}
{$price = $book.price|default:0}
{if !empty($book.apply_special) && !empty($book.price_special)}{$price = $book.price_special}{/if}
{$discount = 0}{if $book.price > $price && $price > 0}{$discount = round(($book.price - $price) * 100 / $book.price)}{/if}
{$subject = 'Sách Y khoa'}{$category_ids = []}{$category_names = []}
{foreach from = $book.categories item = category}{$category_ids[] = $category.id}{$category_names[] = $category.name}{/foreach}
{$category_search = implode(' ', $category_names)}{$category_filter = implode(',', $category_ids)}
{foreach from = $subject_ids item = subject_id}{if !empty($book.categories[$subject_id])}{$subject = $book.categories[$subject_id].name}{break}{/if}{/foreach}
{$cart_product = ['id' => $book.items[0].id|default:0, 'name' => $book.name, 'image' => $book.all_images[0]|default:'', 'quantity' => 1, 'price' => $book.price|default:0, 'price_special' => $price, 'url' => $url]}
<article class="mbc-card" data-book-card data-book-id="{$book.id}" data-book-search="{$book.name|escape} {$category_search|escape}" data-book-name="{$book.name|escape}" data-book-categories="{$category_filter|escape}" data-book-price="{$price}" data-book-order="{$book_index}">
    <a class="mbc-cover" href="{$url|escape}" aria-label="Xem sách {$book.name|escape}">
        {if !empty($book.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($book.all_images[0], 500)}" alt="Bìa sách {$book.name|escape}" loading="lazy" decoding="async">{else}<span class="mbc-cover-placeholder">MEDUC<span>{$book.name|escape}</span></span>{/if}
        {if $discount > 0}<span class="mbc-discount">Giảm {$discount}%</span>{/if}
    </a>
    <div class="mbc-card-body">
        <span class="mbc-subject">{$subject|escape}</span>
        <h3><a href="{$url|escape}" title="{$book.name|escape}">{$book.name|escape}</a></h3>
        <div class="mbc-prices">{if $price > 0}<strong>{$price|number_format:0:',':'.'}<small>đ</small></strong>{else}<strong class="mbc-price-contact">Liên hệ tư vấn</strong>{/if}{if $discount > 0}<del>{$book.price|number_format:0:',':'.'}đ</del>{/if}</div>
        <a class="mbc-detail" href="{$url|escape}">Xem chi tiết sách <span aria-hidden="true">→</span></a>
        {if $price > 0 && count($book.items) == 1 && !empty($book.items[0].id)}
            <button class="mbc-add" type="button" data-book-add data-book-product="{$cart_product|json_encode|escape}" aria-label="Thêm vào giỏ: {$book.name|escape}" hidden>Thêm vào giỏ <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 8h14l1 13H4L5 8Zm3 0V6a4 4 0 0 1 8 0v2"/></svg></button>
        {else}<a class="mbc-add" href="{$url|escape}">Chọn sách <span aria-hidden="true">→</span></a>{/if}
    </div>
</article>
{/strip}
