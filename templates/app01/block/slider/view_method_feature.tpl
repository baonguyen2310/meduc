{strip}
{* Homepage teaching method ("Core Learning"), laid out like MasterClass's feature banner: a large picture or video
   that fades into the page, with the text beside it, and the method's key points underneath.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element.
   - anh: the large picture (a path, a full URL, or {CDN_URL}/media/...).
   - video: a YouTube link or video ID. With a video, "nut_video" plays it inside the large frame.
   - nut / link_nut: a link button, shown beside the video button or on its own.
   Key points: the block's slider items. Name: the title. Mô tả: the text. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$picture = ''}
{if !empty($text.anh)}{$picture = $this->Utilities->replaceVariableSystem($text.anh|trim)}{/if}

{$video_id = ''}
{if !empty($text.video)}
    {$video_id = $text.video|trim}
    {if !preg_match('/^[\w-]+$/', $video_id)}
        {$video_id = $video_id|regex_replace:'/^.*(?:[?&]v=|youtu\.be\/|\/shorts\/|\/embed\/|\/live\/)([\w-]+).*$/s':'$1'}
    {/if}
    {if strlen($video_id) != 11 || !preg_match('/^[\w-]+$/', $video_id)}{$video_id = ''}{/if}
{/if}
{if $picture == '' && $video_id != ''}{$picture = "https://i.ytimg.com/vi/{$video_id}/maxresdefault.jpg"}{/if}

{$points = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {if !empty($item.name)}{$points[] = $item}{/if}
    {/foreach}
{/if}

<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/method.css?v=20261015" rel="stylesheet">
{if $video_id != ''}
    <script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/method.js?v=20261015" defer></script>
{/if}

<section class="mcl" {if !empty($text.tieu_de)}aria-labelledby="mcl-title"{/if}>
    <div class="mcl-shell">
        <div class="mcl-banner{if $picture == ''} mcl-banner--text{/if}">
            {if $picture != ''}
                <div class="mcl-media">
                    <img src="{$picture|escape}" alt="" loading="lazy" decoding="async" />
                </div>
            {/if}
            <div class="mcl-copy">
                {if !empty($text.nhan)}<span class="mcl-pill">{$text.nhan|escape}</span>{/if}
                {if !empty($text.tieu_de)}<h2 class="mcl-title" id="mcl-title">{$text.tieu_de|escape}</h2>{/if}
                {if !empty($text.tieu_de_phu)}<p class="mcl-subtitle"><span>{$text.tieu_de_phu|escape}</span></p>{/if}
                {if !empty($text.mo_ta)}
                    <span class="mcl-dash" aria-hidden="true"></span>
                    <p class="mcl-text">{$text.mo_ta|escape|nl2br}</p>
                {/if}
                <div class="mcl-actions">
                    {if $video_id != ''}
                        {* Without JavaScript the button is a plain link to YouTube; method.js plays the video in the large frame. *}
                        <a class="mcl-button" href="https://www.youtube.com/watch?v={$video_id}" target="_blank" rel="noopener noreferrer" data-mcl-video="{$video_id}">
                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 4.5v15l12-7.5z" /></svg>
                            <span>{if !empty($text.nut_video)}{$text.nut_video|escape}{else}Xem video{/if}</span>
                        </a>
                    {/if}
                    {if !empty($text.nut)}
                        <a class="{if $video_id != ''}mcl-link{else}mcl-button{/if}" href="{if !empty($text.link_nut)}{$text.link_nut|escape}{else}/khoa-hoc{/if}">{$text.nut|escape} <span aria-hidden="true">→</span></a>
                    {/if}
                </div>
            </div>
            {if $video_id != ''}
                <div class="mcl-player" hidden>
                    <button type="button" class="mcl-close" aria-label="Đóng video">×</button>
                    <div class="mcl-frame"></div>
                </div>
            {/if}
        </div>

        {if !empty($points)}
            <ol class="mcl-points">
                {foreach from = $points item = point}
                    <li class="mcl-point">
                        <span class="mcl-point-number" aria-hidden="true">{$point@iteration|string_format:'%02d'}</span>
                        <h3 class="mcl-point-title">{$point.name|escape}</h3>
                        {if !empty($point.description)}<p class="mcl-point-text">{$point.description|escape|nl2br}</p>{/if}
                    </li>
                {/foreach}
            </ol>
        {/if}
    </div>
</section>
{/strip}
