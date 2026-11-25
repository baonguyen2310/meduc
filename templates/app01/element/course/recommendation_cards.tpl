{if !empty($recommendations.courses)}
<section class="meduc-course-picks" id="{$section_id|escape}" aria-labelledby="{$section_id|escape}-title" data-course-recommendations="{$recommendations.type|escape}">
    <header class="meduc-course-picks-heading">
        <h2 id="{$section_id|escape}-title">{$recommendations.title|escape}</h2>
        <a href="/khoa-hoc">Xem tất cả khoá ôn kiến thức <span aria-hidden="true">→</span></a>
    </header>
    <ul class="meduc-course-picks-grid">
        {foreach from=$recommendations.courses item=course}
            <li><a class="meduc-course-pick" href="{$course.url|escape}">
                {if !empty($course.image)}<img src="{CDN_URL}{$course.image|escape}" loading="lazy" decoding="async" alt="">{/if}
                <span class="meduc-course-pick-label"><span>{$course.name|escape}</span><span aria-hidden="true">→</span></span>
            </a></li>
        {/foreach}
    </ul>
</section>
{/if}
