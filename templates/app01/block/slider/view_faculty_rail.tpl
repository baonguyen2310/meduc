{strip}
{* Homepage faculty rail: tall portrait cards that scroll sideways (the main branch's hero-light/assets/faculty.js).
   Cards: the block's slider items.
   - Name: "Ths, Bs: Nguyễn Thị Ý Nhi (Dạy Nội Khoa)"; the part in brackets becomes the subject badge, or "Mô tả ngắn" when set.
   - Mô tả: the two lines under the name. Link: the teacher's course.
   - An item without a link points to the team page and keeps its photo centred, because those photos are not course posters.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$team_url = '/doi-ngu-giang-vien'}
{if !empty($text.link_xem_tat_ca)}{$team_url = $text.link_xem_tat_ca}{/if}

{if !empty($data_block)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/faculty.css?v=20261022-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/rail.js?v=20261015" defer></script>

<section class="mgv" data-mrail {if !empty($text.tieu_de)}aria-labelledby="mgv-title"{/if}>
    <div class="mgv-heading">
        {if !empty($text.tieu_de_phu)}<p class="mgv-kicker">{$text.tieu_de_phu|escape}</p>{/if}
        {if !empty($text.tieu_de)}<h2 class="mgv-title" id="mgv-title">{$text.tieu_de|escape}</h2>{/if}
        {if !empty($text.mo_ta)}<p class="mgv-intro">{$text.mo_ta|escape}</p>{/if}
    </div>

    <div class="mgv-rail" data-mrail-track tabindex="0" aria-label="Giảng viên và cố vấn MedUC">
        {$this->element('faculty/cards', ['data_block' => $data_block, 'team_url' => $team_url, 'profile_mode' => false])}
    </div>

    <div class="mgv-footer">
        {if !empty($text.chu_cuoi)}<p class="mgv-note">{$text.chu_cuoi|escape}</p>{/if}
        <div class="mgv-footer-actions">
            {if !empty($text.nut_xem_tat_ca)}
                <a class="mgv-all" href="{$team_url|escape}">{$text.nut_xem_tat_ca|escape} <span aria-hidden="true">→</span></a>
            {/if}
            <div class="mgv-controls">
                <span class="mgv-counter" data-mrail-counter aria-live="polite"></span>
                <button type="button" data-mrail-prev aria-label="Xem giảng viên trước">←</button>
                <button type="button" data-mrail-next aria-label="Xem giảng viên tiếp theo">→</button>
            </div>
        </div>
    </div>
</section>
{/if}
{/strip}
