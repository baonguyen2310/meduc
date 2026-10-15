{strip}
{* Homepage community figures ("Cùng nhau học Y tốt hơn"), from the main branch's hero-light/assets/home-impact.js.
   Figures: the block's slider items. Name: the number, e.g. 6000. Mô tả: what it counts.
   The numbers count up when the section scrolls into view (impact.js); without JavaScript they show as written.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$figures = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {$count = $item.name|default:''|regex_replace:'/[^0-9]/':''}
        {if $count == ''}{continue}{/if}
        {$label = $item.description|default:''|trim}
        {$figures[] = ['count' => $count, 'label' => $label]}
    {/foreach}
{/if}
{$figure_count = count($figures)}

{if $figure_count > 0}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/impact.css?v=20261015" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/impact.js?v=20261015" defer></script>

<section class="mim" {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}aria-labelledby="mim-title"{/if}>
    <div class="mim-shell">
        <div class="mim-heading">
            <div>
                {if !empty($text.tieu_de_phu)}<p class="mim-kicker">{$text.tieu_de_phu|escape}</p>{/if}
                {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                    <h2 class="mim-title" id="mim-title">
                        {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                        {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                        {if !empty($text.tieu_de_dong_2)}<em>{$text.tieu_de_dong_2|escape}</em>{/if}
                    </h2>
                {/if}
            </div>
            {if !empty($text.mo_ta)}<p class="mim-intro">{$text.mo_ta|escape}</p>{/if}
        </div>
        <div class="mim-grid" style="--mim-columns: {min($figure_count, 4)}" aria-label="Các chỉ số của MedUC">
            {foreach from = $figures item = figure}
                {$shown = $figure.count|number_format:0:',':'.'}
                <div class="mim-item">
                    <span class="mim-index">{$figure@iteration|string_format:'%02d'} / {$figure_count|string_format:'%02d'}</span>
                    <strong class="mim-number" aria-label="{$shown}+"><span class="mim-count" data-count="{$figure.count}" aria-hidden="true">{$shown}</span><span aria-hidden="true">+</span></strong>
                    <span class="mim-label">{$figure.label|escape}</span>
                </div>
            {/foreach}
        </div>
    </div>
</section>
{/if}
{/strip}
