{strip}
{* Student feedback page, opening: "students are the core of MedUC", the page's heading beside a photo of MedUC students.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element.
   - anh: the photo (a path, a full URL, or {CDN_URL}/media/...). so_noi_bat / chu_noi_bat: the badge on the photo.
   - nut_chinh / link_nut_chinh: the red button (by default it jumps to the student videos, #phan-hoi).
   - nut_phu / link_nut_phu: the grey button. This block has no slider items. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$picture = ''}
{if !empty($text.anh)}{$picture = $this->Utilities->replaceVariableSystem($text.anh|trim)}{/if}

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/feedback-page.css?v=20261015" rel="stylesheet">

<section class="mfb mfb-hero">
    <div class="mfb-shell mfb-hero-grid{if $picture == ''} mfb-hero-grid--text{/if}">
        <div class="mfb-hero-copy">
            {if !empty($text.tieu_de_phu)}<p class="mfb-kicker">{$text.tieu_de_phu|escape}</p>{/if}
            {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                <h1 class="mfb-hero-title">
                    {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                    {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                    {if !empty($text.tieu_de_dong_2)}<span>{$text.tieu_de_dong_2|escape}</span>{/if}
                </h1>
            {/if}
            {if !empty($text.mo_ta)}<p class="mfb-hero-lead">{$text.mo_ta|escape|nl2br}</p>{/if}
            {if !empty($text.nut_chinh) || !empty($text.nut_phu)}
                <div class="mfb-hero-actions">
                    {if !empty($text.nut_chinh)}
                        <a class="mfb-button mfb-button--primary" href="{if !empty($text.link_nut_chinh)}{$text.link_nut_chinh|escape}{else}#phan-hoi{/if}">{$text.nut_chinh|escape}</a>
                    {/if}
                    {if !empty($text.nut_phu)}
                        <a class="mfb-button mfb-button--secondary" href="{if !empty($text.link_nut_phu)}{$text.link_nut_phu|escape}{else}/khoa-hoc{/if}">{$text.nut_phu|escape}</a>
                    {/if}
                </div>
            {/if}
        </div>
        {if $picture != ''}
            <figure class="mfb-hero-picture">
                <img src="{$picture|escape}" alt="{if !empty($text.mo_ta_anh)}{$text.mo_ta_anh|escape}{/if}" fetchpriority="high" />
                {if !empty($text.so_noi_bat) || !empty($text.chu_noi_bat)}
                    <figcaption class="mfb-badge">
                        {if !empty($text.so_noi_bat)}<strong>{$text.so_noi_bat|escape}</strong>{/if}
                        {if !empty($text.chu_noi_bat)}<span>{$text.chu_noi_bat|escape}</span>{/if}
                    </figcaption>
                {/if}
            </figure>
        {/if}
    </div>
</section>
{/strip}
