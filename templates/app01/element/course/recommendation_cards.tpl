{if !empty($recommendations.courses) || !empty($recommendations.browse)}
{$academy = $recommendations.type == 'academy'}
<section class="meduc-course-picks{if $academy} meduc-course-picks--academy{/if}" id="{$section_id|escape}" aria-labelledby="{$section_id|escape}-title" data-course-recommendations="{$recommendations.type|escape}">
    <header class="meduc-course-picks-heading">
        <h2 id="{$section_id|escape}-title">{$recommendations.title|escape}</h2>
        {if !$academy}
            <a href="/khoa-hoc">Xem tất cả khoá ôn kiến thức <span aria-hidden="true">→</span></a>
        {elseif !empty($recommendations.browse)}
            <div class="meduc-course-picks-browse">
                {foreach from=$recommendations.browse item=link}
                    <a href="{$link.url|escape}">{$link.name|escape} <span aria-hidden="true">→</span></a>
                {/foreach}
            </div>
        {/if}
    </header>
    {if !empty($recommendations.courses)}
        <ul class="meduc-course-picks-grid">
            {foreach from=$recommendations.courses item=course}
                <li><a class="meduc-course-pick" href="{$course.url|escape}"{if $academy} data-course-kind="{$course.kind|escape}"{/if}>
                    {if !empty($course.image)}
                        <img src="{CDN_URL}{$course.image|escape}" loading="lazy" decoding="async" alt="">
                    {elseif $academy}
                        <span class="meduc-course-pick-art" aria-hidden="true"></span>
                    {/if}
                    <span class="meduc-course-pick-label">
                        <span class="meduc-course-pick-text">
                            {if $academy}<span class="meduc-course-pick-kind">{$course.kind_label|escape}</span>{/if}
                            <span>{$course.name|escape}</span>
                            {if !empty($course.price)}
                                <span class="meduc-course-pick-prices">
                                    <strong>{$course.price|number_format:0:',':'.'}đ</strong>
                                    {if $course.original_price > $course.price}<s>{$course.original_price|number_format:0:',':'.'}đ</s>{/if}
                                </span>
                            {/if}
                        </span>
                        <span class="meduc-course-pick-arrow" aria-hidden="true">→</span>
                    </span>
                </a></li>
            {/foreach}
        </ul>
    {/if}
</section>
{/if}
