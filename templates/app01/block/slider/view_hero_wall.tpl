{strip}
{* Homepage hero: a wall of scrolling portraits behind the headline (MasterClass "variant_1" layout).
   Images: the block's slider items. Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$photos = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {if !empty($item.image)}
            {if $item.image_source == 'cdn'}
                {$photos[] = "{CDN_URL}{$this->Utilities->getThumbs($item.image, 500)}"}
            {else}
                {$photos[] = $item.image}
            {/if}
        {/if}
    {/foreach}
{/if}
{$photo_count = count($photos)}
{* Like MasterClass, column N starts N * step photos along the list, with step coprime to the photo count and
   about half of it, so neighbouring columns share as few faces as possible. *}
{$photo_step = 1}
{if $photo_count > 3}
    {$candidate = max(2, floor($photo_count / 2) - 1)}
    {while $candidate < $photo_count && $photo_step == 1}
        {$a = $candidate}
        {$b = $photo_count}
        {while $b != 0}
            {$r = $a % $b}
            {$a = $b}
            {$b = $r}
        {/while}
        {if $a == 1}{$photo_step = $candidate}{/if}
        {$candidate = $candidate + 1}
    {/while}
{/if}

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/hero.css?v=20261015" rel="stylesheet">

<section class="mhw">
    {if $photo_count > 0}
        <div class="mhw-wall" aria-hidden="true">
            {for $column = 0 to 8}
                <div class="mhw-column{if $column % 2 == 1} mhw-column--down{/if}" style="--mhw-delay: -{$column * 9}s">
                    <div class="mhw-track">
                        {* Two identical halves make the loop seamless. *}
                        {for $copy = 0 to 1}
                            {for $row = 0 to 5}
                                <div class="mhw-tile"><img src="{$photos[($column * $photo_step + $row) % $photo_count]|escape}" alt="" decoding="async" /></div>
                            {/for}
                        {/for}
                    </div>
                </div>
            {/for}
        </div>
    {/if}
    <div class="mhw-overlay" aria-hidden="true"></div>

    <div class="mhw-shell mhw-content">
        <div class="mhw-copy">
            {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                <h1 class="mhw-title">
                    {if !empty($text.tieu_de_dong_1)}<span class="mhw-line1">{$text.tieu_de_dong_1|escape}</span>{/if}
                    {if !empty($text.tieu_de_dong_2)}<span class="mhw-line2">{$text.tieu_de_dong_2|escape}</span>{/if}
                </h1>
            {/if}
            {if !empty($text.mo_ta)}
                <p class="mhw-subtitle">{$text.mo_ta|escape|nl2br}</p>
            {/if}
        </div>
        <div class="mhw-actions">
            {if !empty($text.dong_phu)}
                <p class="mhw-note">{$text.dong_phu|escape}</p>
            {/if}
            {* Two red buttons (nut_chinh, nut_chinh_2) and one grey button (nut_phu). *}
            {if !empty($text.nut_chinh) || !empty($text.nut_chinh_2) || !empty($text.nut_phu)}
                <div class="mhw-buttons">
                    {if !empty($text.nut_chinh)}
                        <a class="mhw-button mhw-button--primary" href="{if !empty($text.link_nut_chinh)}{$text.link_nut_chinh|escape}{else}/khoa-hoc{/if}">{$text.nut_chinh|escape}</a>
                    {/if}
                    {if !empty($text.nut_chinh_2)}
                        <a class="mhw-button mhw-button--primary" href="{if !empty($text.link_nut_chinh_2)}{$text.link_nut_chinh_2|escape}{else}/danh-sach-de-thi{/if}">{$text.nut_chinh_2|escape}</a>
                    {/if}
                    {if !empty($text.nut_phu)}
                        <a class="mhw-button mhw-button--secondary" href="{if !empty($text.link_nut_phu)}{$text.link_nut_phu|escape}{else}/sach-y-khoa{/if}">{$text.nut_phu|escape}</a>
                    {/if}
                </div>
            {/if}
            {if !empty($text.cam_ket)}
                <p class="mhw-guarantee">{$text.cam_ket|escape}</p>
            {/if}
        </div>
    </div>
</section>
{/strip}
