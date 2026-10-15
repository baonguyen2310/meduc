{strip}
{* Student feedback page: how MedUC looks after its students, as numbered points under a large heading.
   Points: the block's slider items. Name: the point's title. Mô tả: its text.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$points = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {if !empty($item.name)}{$points[] = $item}{/if}
    {/foreach}
{/if}

{if !empty($points)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/feedback-page.css?v=20261015" rel="stylesheet">

<section class="mfb mfb-care" {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}aria-labelledby="mfb-care-title"{/if}>
    <div class="mfb-shell">
        <div class="mfb-heading">
            <div>
                {if !empty($text.tieu_de_phu)}<p class="mfb-kicker">{$text.tieu_de_phu|escape}</p>{/if}
                {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                    <h2 class="mfb-title" id="mfb-care-title">
                        {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                        {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                        {if !empty($text.tieu_de_dong_2)}<span>{$text.tieu_de_dong_2|escape}</span>{/if}
                    </h2>
                {/if}
            </div>
            {if !empty($text.mo_ta)}<p class="mfb-intro">{$text.mo_ta|escape|nl2br}</p>{/if}
        </div>
        <ol class="mfb-care-grid">
            {foreach from = $points item = point}
                <li class="mfb-care-item">
                    <span class="mfb-care-number" aria-hidden="true">{$point@iteration|string_format:'%02d'}</span>
                    <h3 class="mfb-care-title">{$point.name|escape}</h3>
                    {if !empty($point.description)}<p class="mfb-care-text">{$point.description|escape|nl2br}</p>{/if}
                </li>
            {/foreach}
        </ol>
    </div>
</section>
{/if}
{/strip}
