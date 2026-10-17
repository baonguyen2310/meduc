{strip}
{$course_url = $this->Utilities->checkInternalUrl($course.url)}
{$current_price = $course.price|default:0}
{if !empty($course.apply_special) && !empty($course.price_special)}{$current_price = $course.price_special}{/if}
{$discount = 0}
{if !empty($course.apply_special) && $course.price > $current_price && $current_price > 0}{$discount = round(($course.price - $current_price) * 100 / $course.price)}{/if}
<article class="mcl-card" data-course-card data-course-id="{$course.id}" data-course-name="{$course.name|escape}" data-course-price="{$current_price}" data-course-order="{$course_index}" nh-product="{$course.id}" nh-product-item-id="{$course.items[0].id|default:''}">
    <a class="mcl-cover" href="{$course_url|escape}" aria-label="Xem khóa học {$course.name|escape}">
        {if !empty($course.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($course.all_images[0], 720)}" alt="Ảnh bìa {$course.name|escape}" loading="lazy" decoding="async" />{else}<span class="mcl-cover-placeholder">MEDUC<span>HỌC Y CÙNG NHAU.</span></span>{/if}
        {if $discount > 0}<span class="mcl-discount">Giảm {$discount}%</span>{/if}
    </a>
    <div class="mcl-card-copy">
        <h3><a href="{$course_url|escape}">{$course.name|escape}</a></h3>
        <div class="mcl-card-meta">{if $course.catalog_meta.chapters > 0}<span>{$course.catalog_meta.chapters} chương</span>{/if}{if $course.catalog_meta.lessons > 0}<span>{$course.catalog_meta.lessons} bài học</span>{/if}</div>
        {if !empty($course.catalog_meta.summary)}<p class="mcl-card-description">{$course.catalog_meta.summary|escape}</p>{/if}
    </div>
    <div class="mcl-card-enroll">
        <div class="mcl-price"><span class="mcl-price-label">Học phí</span>{if $current_price > 0}<strong>{$current_price|number_format:0:',':'.'} <small>{CURRENCY_UNIT}</small></strong>{else}<strong class="mcl-contact-price">Liên hệ tư vấn</strong>{/if}{if $discount > 0}<del>{$course.price|number_format:0:',':'.'} {CURRENCY_UNIT}</del>{/if}</div>
        {if $current_price > 0 && !empty($course.items[0].id)}
            <a class="mcl-register" {if in_array($course.id, $cart_product_ids)}href="/order/info"{else}href="{$course_url|escape}" nh-btn-action="add-cart" nh-redirect="/order/info"{/if} aria-label="Đăng ký học: {$course.name|escape}">Đăng ký học <span aria-hidden="true">→</span></a>
        {else}<a class="mcl-register" href="{$course_url|escape}">{if !empty($course.catalog_meta.exam_prep)}Xem lộ trình{else}Tìm hiểu khóa học{/if} <span aria-hidden="true">→</span></a>{/if}
    </div>
</article>
{/strip}
