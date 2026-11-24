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

{include file='../../element/layout/catalog_navigation.tpl' scope=parent}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/hero.css?v=20261124-stable-navigation" rel="stylesheet">

<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty-photos.js?v=20261105-portrait-framing" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/hero.js?v=20261124-stable-navigation" defer></script>

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
            <div class="mhw-buttons">
                {foreach from = $meduc_catalog_groups key = group_id item = group}
                    <div class="mhw-category">
                        <button class="mhw-button" type="button" aria-expanded="false" aria-controls="mhw-{$group_id|escape}-menu">
                            {$group.label|escape}
                            <svg class="mhw-chevron" aria-hidden="true"><use href="#mhi-icon-chevron" /></svg>
                        </button>
                        <nav class="mhw-category-menu" id="mhw-{$group_id|escape}-menu" aria-label="Danh mục {$group.label|escape}" hidden>
                            {foreach from = $group.items item = link}
                                <a href="{$link.url|escape}">
                                    <svg class="mhi-icon" aria-hidden="true"><use href="#mhi-icon-{$link.icon|escape}" /></svg>
                                    <span>{$link.label|escape}</span>
                                    <svg class="mhi-icon mhw-category-arrow" aria-hidden="true"><use href="#mhi-icon-arrow" /></svg>
                                </a>
                            {/foreach}
                        </nav>
                    </div>
                {/foreach}
            </div>
            {if !empty($text.cam_ket)}
                <p class="mhw-guarantee">{$text.cam_ket|escape}</p>
            {/if}
        </div>
    </div>
</section>
{/strip}
