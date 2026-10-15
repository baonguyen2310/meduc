{strip}
{* Student feedback page: every student video in a grid, with subject filters and a "show more" button
   (the main branch's hero-light/feedback.html). It reuses the homepage video section's look and pop-up player
   (video-feedback.css and video-feedback.js); video-grid.js adds the filters and "show more".
   Videos: the block's slider items.
   - Link: a YouTube link or the 11-character video ID. Name: the title. Image: an optional poster.
   - Mô tả: the subject line, e.g. "Giải phẫu · Sau đại học"; the part before "·" becomes the filter.
   - Mô tả ngắn: the course page the video is about (shown as "Xem khoá học").
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. so_video_moi_lan: videos per page (6). *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$videos = []}
{$filters = []}
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
        {$filter = $subject|regex_replace:'/\s*·.*$/us':''|trim}
        {if !in_array($filter, $filters)}{$filters[] = $filter}{/if}
        {$course = ''}
        {if !empty($item.description_short)}
            {$course = $item.description_short|trim}
            {if !preg_match('/^(https?:)?\/\//', $course) && substr($course, 0, 1) != '/'}{$course = "/{$course}"}{/if}
        {/if}

        {$videos[] = ['id' => $video_id, 'title' => $title, 'subject' => $subject, 'filter' => $filter, 'poster' => $poster, 'course' => $course]}
    {/foreach}
{/if}
{$page_size = 6}
{if !empty($text.so_video_moi_lan) && $text.so_video_moi_lan|intval > 0}{$page_size = $text.so_video_moi_lan|intval}{/if}

{if !empty($videos)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/video-feedback.css?v=20261015-2" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/video-grid.css?v=20261015" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/video-feedback.js?v=20261015" defer></script>
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/video-grid.js?v=20261015" defer></script>

<section class="mvd mvd--grid" id="phan-hoi" data-mvd-grid data-mvd-page="{$page_size}" {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}aria-labelledby="mvd-grid-title"{/if}>
    <div class="mvd-shell">
        <div class="mvd-heading">
            <div>
                {if !empty($text.tieu_de_phu)}<p class="mvd-kicker">{$text.tieu_de_phu|escape}</p>{/if}
                {if !empty($text.tieu_de_dong_1) || !empty($text.tieu_de_dong_2)}
                    <h2 class="mvd-title" id="mvd-grid-title">
                        {if !empty($text.tieu_de_dong_1)}{$text.tieu_de_dong_1|escape}{/if}
                        {if !empty($text.tieu_de_dong_1) && !empty($text.tieu_de_dong_2)}<br />{/if}
                        {if !empty($text.tieu_de_dong_2)}<span>{$text.tieu_de_dong_2|escape}</span>{/if}
                    </h2>
                {/if}
            </div>
            {if !empty($text.mo_ta)}<p class="mvd-intro">{$text.mo_ta|escape|nl2br}</p>{/if}
        </div>

        {if count($filters) > 1}
            <div class="mvd-filters" role="group" aria-label="Lọc video theo môn học" hidden>
                <button type="button" data-mvd-filter="" aria-pressed="true">Tất cả</button>
                {foreach from = $filters item = filter}
                    <button type="button" data-mvd-filter="{$filter|escape}" aria-pressed="false">{$filter|escape}</button>
                {/foreach}
            </div>
        {/if}

        <div class="mvd-grid">
            {foreach from = $videos item = video}
                <article class="mvd-card" data-mvd-subject="{$video.filter|escape}">
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
                            {if $video.course != ''}<a class="mvd-course" href="{$video.course|escape}">Xem khoá học <span aria-hidden="true">→</span></a>{/if}
                        </div>
                    </div>
                </article>
            {/foreach}
        </div>

        <div class="mvd-grid-footer">
            <p class="mvd-status" aria-live="polite"></p>
            <button type="button" class="mvd-more" hidden>{if !empty($text.nut_xem_them)}{$text.nut_xem_them|escape}{else}Xem thêm video{/if}</button>
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
