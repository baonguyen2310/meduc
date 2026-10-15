{strip}
{* Student feedback page: a full-width statement over a darkened photo ("MedUC always cares for its students"),
   leading into the students' own feedback below.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element.
   - anh_nen: the background photo (a path, a full URL, or {CDN_URL}/media/...).
   - nut / link_nut: the button (by default it jumps to the student videos, #phan-hoi). This block has no slider items. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$picture = ''}
{if !empty($text.anh_nen)}{$picture = $this->Utilities->replaceVariableSystem($text.anh_nen|trim)}{/if}

<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/feedback-page.css?v=20261015" rel="stylesheet">

<section class="mfb mfb-statement{if $picture == ''} mfb-statement--plain{/if}">
    {if $picture != ''}<img class="mfb-statement-bg" src="{$picture|escape}" alt="" loading="lazy" decoding="async" />{/if}
    <div class="mfb-shell mfb-statement-inner">
        {if !empty($text.tieu_de_phu)}<p class="mfb-kicker">{$text.tieu_de_phu|escape}</p>{/if}
        {if !empty($text.cau_chinh)}<blockquote class="mfb-statement-quote">{$text.cau_chinh|escape|nl2br}</blockquote>{/if}
        {if !empty($text.mo_ta)}<p class="mfb-statement-text">{$text.mo_ta|escape|nl2br}</p>{/if}
        {if !empty($text.ky_ten)}<p class="mfb-statement-sign">{$text.ky_ten|escape}</p>{/if}
        {if !empty($text.nut)}
            <a class="mfb-button mfb-button--outline" href="{if !empty($text.link_nut)}{$text.link_nut|escape}{else}#phan-hoi{/if}">{$text.nut|escape} <span aria-hidden="true">↓</span></a>
        {/if}
    </div>
</section>
{/strip}
