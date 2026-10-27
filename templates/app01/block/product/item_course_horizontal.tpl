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
        <a class="mcl-register" href="{$course_url|escape}" aria-label="Học thử miễn phí: {$course.name|escape}">Học thử miễn phí <span aria-hidden="true">→</span></a>
    </div>
</article>
{/strip}
