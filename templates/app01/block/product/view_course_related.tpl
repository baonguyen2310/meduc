{strip}
{* Related courses on the course page: a sideways row of compact course cards; the course being viewed is left out.
   Products: the block's product list settings (up to 200, newest first: scripts/meduc_v2_exam_prep_pages.sql), of which
   at most 12 of the same kind are shown. Text: tieu_de (the heading).
   Styles: assets/meduc-v2/classroom.css; previous/next buttons: assets/meduc-v2/rail.js. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$current_path = $this->getRequest()->getPath()}
{* An exam-prep course suggests other exam-prep courses; any other course suggests courses only. *}
{$current_kind = $this->Product->courseKind(PAGE_RECORD_ID)}
{$exam_prep = $current_kind == 'quiz'}
{$courses = []}
{if !empty($data_block.data)}
    {foreach from = $data_block.data item = course}
        {if empty($course.url) || "/{$course.url}" == $current_path}{continue}{/if}
        {* Shared year categories do not imply the same course type. *}
        {if $course.course_kind != $current_kind}{continue}{/if}
        {if count($courses) >= 12}{break}{/if}
        {$courses[] = $course}
    {/foreach}
{/if}

{if !empty($courses)}
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/rail.js?v=20261015" defer></script>
<div class="mrc" data-mrail>
    <div class="mrc-head">
        <h2 class="mrc-title">{if $exam_prep}Môn luyện thi khác{elseif !empty($text.tieu_de)}{$text.tieu_de|escape}{else}Khoá học liên quan{/if}</h2>
        <div class="mrc-controls">
            <button type="button" data-mrail-prev aria-label="Khoá học trước">←</button>
            <button type="button" data-mrail-next aria-label="Khoá học tiếp theo">→</button>
        </div>
    </div>
    <div class="mrc-rail" data-mrail-track tabindex="0" aria-label="Khoá học liên quan">
        {foreach from = $courses item = course}
            {$course_url = $this->Utilities->checkInternalUrl($course.url)}
            {$price = $course.price|default:0}
            {$old_price = 0}
            {if !empty($course.apply_special) && !empty($course.price_special)}
                {$price = $course.price_special}
                {if !empty($course.price) && $course.price > $course.price_special}{$old_price = $course.price}{/if}
            {/if}
            <a class="mrc-card" href="{$course_url|escape}">
                <span class="mrc-cover">
                    {if !empty($course.all_images[0])}
                        <img src="{CDN_URL}{$this->Utilities->getThumbs($course.all_images[0], 500)}" alt="" loading="lazy" decoding="async" />
                    {/if}
                </span>
                <span class="mrc-name">{$course.name|escape}</span>
                <span class="mrc-price">
                    {if $price > 0}<strong>{$price|number_format:0:',':'.'}đ</strong>{else}<strong>Liên hệ</strong>{/if}
                    {if $old_price > 0}<s>{$old_price|number_format:0:',':'.'}đ</s>{/if}
                </span>
            </a>
        {/foreach}
    </div>
</div>
{/if}
{/strip}
