{strip}
{* Homepage learning path: the stages from foundation to advanced study, each with a picture, side by side on a timeline.
   Stages: the block's slider items.
   - Name: the stage title. Mô tả ngắn: the small label above it, e.g. "Năm 1 – Năm 2". Mô tả: the text.
   - Image: the stage picture; a stage without one shows its number on a dark panel. Stage links are omitted here; the single CTA opens the learning roadmap.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$stages = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {if !empty($item.name)}{$stages[] = $item}{/if}
    {/foreach}
{/if}

{if !empty($stages)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/learning-path.css?v=20261028-1" rel="stylesheet">

<section class="mlp" {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}aria-labelledby="mlp-title"{/if}>
    <div class="mlp-shell">
        <div class="mlp-heading">
            <div>
                {if !empty($text.tieu_de_phu)}<p class="mlp-kicker">{$text.tieu_de_phu|escape}</p>{/if}
                {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                    <h2 class="mlp-title" id="mlp-title">
                        {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                        {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                        {if !empty($text.tieu_de_dong_2)}<span>{$text.tieu_de_dong_2|escape}</span>{/if}
                    </h2>
                {/if}
            </div>
            <div class="mlp-intro">
                {if !empty($text.mo_ta)}<p>{$text.mo_ta|escape|nl2br}</p>{/if}
                <a class="mlp-all" href="/lo-trinh-hoc">Xem lộ trình học <span aria-hidden="true">→</span></a>
            </div>
        </div>

        <ol class="mlp-stages">
            {foreach from = $stages item = stage}
                {$picture = ''}
                {if !empty($stage.image)}
                    {if $stage.image_source == 'cdn'}
                        {$picture = "{CDN_URL}{$this->Utilities->getThumbs($stage.image, 720)}"}
                    {else}
                        {$picture = $stage.image}
                    {/if}
                {/if}
                {$number = $stage@iteration|string_format:'%02d'}

                <li class="mlp-stage">
                    <span class="mlp-dot" aria-hidden="true"></span>
                    <div class="mlp-picture{if $picture == ''} mlp-picture--empty{/if}">
                        {if $picture != ''}<img src="{$picture|escape}" alt="" loading="lazy" decoding="async" />{/if}
                        <span class="mlp-number" aria-hidden="true">{$number}</span>
                    </div>
                    {if !empty($stage.description_short)}<p class="mlp-label">{$stage.description_short|escape}</p>{/if}
                    <h3 class="mlp-stage-title">
                        {$stage.name|escape}
                    </h3>
                    {if !empty($stage.description)}<p class="mlp-text">{$stage.description|escape|nl2br}</p>{/if}
                </li>
            {/foreach}
        </ol>
    </div>
</section>
{/if}
{/strip}
