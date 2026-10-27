{strip}
{$course_url = $this->Utilities->checkInternalUrl($course.url)}
{$preview_label = "Học thử miễn phí"}
{if $course.catalog_meta.exam_prep}{$preview_label = "Luyện thi miễn phí"}{/if}
{$current_price = $course.price|default:0}
{if !empty($course.apply_special) && !empty($course.price_special)}{$current_price = $course.price_special}{/if}
<article class="mcl-card" data-course-card data-course-id="{$course.id}" data-course-name="{$course.name|escape}" data-course-price="{$current_price}" data-course-order="{$course_index}" nh-product="{$course.id}" nh-product-item-id="{$course.items[0].id|default:''}">
    <a class="mcl-cover" href="{$course_url|escape}" aria-label="Xem khóa học {$course.name|escape}">
        {if !empty($course.all_images[0])}<img src="{CDN_URL}{$this->Utilities->getThumbs($course.all_images[0], 720)}" alt="Ảnh bìa {$course.name|escape}" loading="lazy" decoding="async" />{else}<span class="mcl-cover-placeholder">MEDUC<span>HỌC Y CÙNG NHAU.</span></span>{/if}
    </a>
    <div class="mcl-card-copy">
        <h3><a href="{$course_url|escape}">{$course.name|escape}</a></h3>
        <div class="mcl-card-meta">{if $course.catalog_meta.chapters > 0}<span>{$course.catalog_meta.chapters} chương</span>{/if}{if $course.catalog_meta.lessons > 0}<span>{$course.catalog_meta.lessons} bài học</span>{/if}</div>
        {if !empty($course.catalog_meta.summary)}<p class="mcl-card-description">{$course.catalog_meta.summary|escape}</p>{/if}
        <a class="mcl-register" data-course-preview href="{$course_url|escape}{if strpos($course_url, '?') === false}?{else}&amp;{/if}bai={$course.catalog_meta.preview_lesson}&amp;tab={$course.catalog_meta.preview_tab}" aria-label="{$preview_label}: {$course.name|escape}">{$preview_label} <span aria-hidden="true">→</span></a>
    </div>
</article>
{/strip}
