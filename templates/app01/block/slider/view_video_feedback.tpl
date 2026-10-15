{strip}
{* Homepage student video feedback: three YouTube posters at a time that open in a pop-up player
   (the main branch's hero-light/assets/home-feedback.js).
   Videos: the block's slider items.
   - Link: a YouTube link or the 11-character video ID. Name: the video title. Mô tả: the subject line above the title.
   - Image: an optional poster; without one the YouTube thumbnail is used.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$videos = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {$video_id = $item.url|default:''|trim}
        {if !preg_match('/^[\w-]+$/', $video_id)}
            {$video_id = $video_id|regex_replace:'/^.*(?:[?&]v=|youtu\.be\/|\/shorts\/|\/embed\/|\/live\/)([\w-]+).*$/s':'$1'}
        {/if}
        {if strlen($video_id) != 11 || !preg_match('/^[\w-]+$/', $video_id)}{continue}{/if}

        {$poster = "https://i.ytimg.com/vi/{$video_id}/sddefault.jpg"}
        {if !empty($item.image)}
            {if $item.image_source == 'cdn'}
                {$poster = "{CDN_URL}{$this->Utilities->getThumbs($item.image, 720)}"}
            {else}
                {$poster = $item.image}
            {/if}
        {/if}

        {$title = 'Cảm nhận học viên MedUC'}
        {if !empty($item.name)}{$title = $item.name|trim}{/if}
        {$subject = 'Hành trình học Y'}
        {if !empty($item.description)}{$subject = $item.description|trim}{/if}

        {$videos[] = ['id' => $video_id, 'title' => $title, 'subject' => $subject, 'poster' => $poster]}
    {/foreach}
{/if}

{if !empty($videos)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/video-feedback.css?v=20261015-2" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/rail.js?v=20261015" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/video-feedback.js?v=20261015" defer></script>

<section class="mvd" data-mrail {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}aria-labelledby="mvd-title"{/if}>
    <div class="mvd-shell">
        <div class="mvd-heading">
            <div>
                {if !empty($text.tieu_de_phu)}<p class="mvd-kicker">{$text.tieu_de_phu|escape}</p>{/if}
                {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                    <h2 class="mvd-title" id="mvd-title">
                        {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                        {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                        {if !empty($text.tieu_de_dong_2)}<span>{$text.tieu_de_dong_2|escape}</span>{/if}
                    </h2>
                {/if}
            </div>
            {if !empty($text.mo_ta)}<p class="mvd-intro">{$text.mo_ta|escape}</p>{/if}
        </div>

        <div class="mvd-rail" data-mrail-track tabindex="0" aria-label="Video cảm nhận của học viên">
            {foreach from = $videos item = video}
                <article class="mvd-card">
                    {* Without JavaScript the poster is a plain link to YouTube; video-feedback.js opens it in the pop-up instead. *}
                    <a class="mvd-poster" href="https://www.youtube.com/watch?v={$video.id}" target="_blank" rel="noopener noreferrer" data-mvd-video="{$video.id}" data-mvd-title="{$video.title|escape}" aria-label="Phát video {$video.title|escape}: {$video.subject|escape}">
                        <img src="{$video.poster|escape}" alt="" loading="lazy" decoding="async" />
                        <span class="mvd-play" aria-hidden="true">▶</span>
                        <span class="mvd-corner" aria-hidden="true">MEDUC / HỌC VIÊN</span>
                    </a>
                    <div class="mvd-meta">
                        <span class="mvd-number" aria-hidden="true">{$video@iteration|string_format:'%02d'}</span>
                        <div>
                            <span class="mvd-subject">{$video.subject|escape}</span>
                            <h3 class="mvd-card-title">{$video.title|escape}</h3>
                        </div>
                    </div>
                </article>
            {/foreach}
        </div>

        <div class="mvd-footer">
            {if !empty($text.nut_xem_tat_ca)}
                <a class="mvd-all" href="{if !empty($text.link_xem_tat_ca)}{$text.link_xem_tat_ca|escape}{else}/phan-hoi-hoc-vien{/if}">{$text.nut_xem_tat_ca|escape} <span aria-hidden="true">↗</span></a>
            {/if}
            <div class="mvd-controls">
                <span class="mvd-counter" data-mrail-counter aria-live="polite"></span>
                <button type="button" data-mrail-prev aria-label="Xem video trước">←</button>
                <button type="button" data-mrail-next aria-label="Xem video tiếp theo">→</button>
            </div>
        </div>
    </div>

    <dialog class="mvd-dialog" aria-labelledby="mvd-dialog-title">
        <button type="button" class="mvd-close" aria-label="Đóng video">×</button>
        <div class="mvd-player"></div>
        <div class="mvd-dialog-info">
            <div>
                <span>VIDEO CẢM NHẬN · MEDUC</span>
                <h3 id="mvd-dialog-title"></h3>
            </div>
            <a href="https://www.youtube.com/" target="_blank" rel="noopener noreferrer">Mở trên YouTube ↗</a>
        </div>
    </dialog>
</section>
{/if}
{/strip}
