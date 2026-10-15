{strip}
{* Student feedback page: the student benefits, each card led by a large figure (for example "75%").
   Benefits: the block's slider items. Mô tả ngắn: the large figure. Name: the title. Mô tả: the text.
   Link: the policy page; "nut_chinh_sach" labels it.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$perks = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {if !empty($item.name)}{$perks[] = $item}{/if}
    {/foreach}
{/if}

{if !empty($perks)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/feedback-page.css?v=20261015" rel="stylesheet">

<section class="mfb mfb-perks" {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}aria-labelledby="mfb-perks-title"{/if}>
    <div class="mfb-shell">
        <div class="mfb-heading">
            <div>
                {if !empty($text.tieu_de_phu)}<p class="mfb-kicker">{$text.tieu_de_phu|escape}</p>{/if}
                {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                    <h2 class="mfb-title" id="mfb-perks-title">
                        {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                        {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                        {if !empty($text.tieu_de_dong_2)}<span>{$text.tieu_de_dong_2|escape}</span>{/if}
                    </h2>
                {/if}
            </div>
            {if !empty($text.mo_ta)}<p class="mfb-intro">{$text.mo_ta|escape|nl2br}</p>{/if}
        </div>
        <div class="mfb-perk-grid">
            {foreach from = $perks item = perk}
                {$link = ''}
                {if !empty($perk.url)}
                    {$link = $perk.url|trim}
                    {if !preg_match('/^(https?:)?\/\//', $link) && substr($link, 0, 1) != '/'}{$link = "/{$link}"}{/if}
                {/if}
                <article class="mfb-perk">
                    {if !empty($perk.description_short)}<p class="mfb-perk-figure">{$perk.description_short|escape}</p>{/if}
                    <h3 class="mfb-perk-title">{$perk.name|escape}</h3>
                    {if !empty($perk.description)}<p class="mfb-perk-text">{$perk.description|escape|nl2br}</p>{/if}
                    {if $link != ''}
                        <a class="mfb-perk-link" href="{$link|escape}">{if !empty($text.nut_chinh_sach)}{$text.nut_chinh_sach|escape}{else}Xem chính sách{/if} <span aria-hidden="true">→</span></a>
                    {/if}
                </article>
            {/foreach}
        </div>
        {if !empty($text.ghi_chu)}<p class="mfb-note">{$text.ghi_chu|escape}</p>{/if}
    </div>
</section>
{/if}
{/strip}
