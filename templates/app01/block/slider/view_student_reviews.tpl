{strip}
{* Homepage student reviews: one review at a time, the quote on a card beside its picture
   (the main branch's hero-light/assets/home-testimonials.js, with room for review screenshots).
   Reviews: the block's slider items.
   - Name: the student. Mô tả: who they are, e.g. "Sinh viên Y khoa năm 2". Mô tả ngắn: the quote.
   - Image: a screenshot of the review (shown whole, never cropped; a click opens the full image) or a portrait.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}

{$reviews = []}
{if !empty($data_block)}
    {foreach from = $data_block item = item}
        {if empty($item.description_short)}{continue}{/if}
        {$picture = ''}
        {$picture_full = ''}
        {if !empty($item.image)}
            {if $item.image_source == 'cdn'}
                {$picture = "{CDN_URL}{$this->Utilities->getThumbs($item.image, 720)}"}
                {$picture_full = "{CDN_URL}{$item.image}"}
            {else}
                {$picture = $item.image}
                {$picture_full = $item.image}
            {/if}
        {/if}
        {$name = $item.name|default:''|trim}
        {$context = $item.description|default:''|trim}
        {$quote = $item.description_short|trim}

        {$reviews[] = ['name' => $name, 'context' => $context, 'quote' => $quote, 'picture' => $picture, 'picture_full' => $picture_full]}
    {/foreach}
{/if}
{$review_count = count($reviews)}

{if $review_count > 0}
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/reviews.css?v=20261015-2" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/reviews.js?v=20261015" defer></script>

<section class="mrv" {if !empty($text.tieu_de)}aria-labelledby="mrv-title"{/if}>
    <div class="mrv-shell">
        <div class="mrv-heading">
            {if !empty($text.tieu_de_phu)}<p class="mrv-kicker">{$text.tieu_de_phu|escape}</p>{/if}
            {if !empty($text.tieu_de)}<h2 class="mrv-title" id="mrv-title">{$text.tieu_de|escape}</h2>{/if}
            {if !empty($text.ghi_chu)}<p class="mrv-note">{$text.ghi_chu|escape}</p>{/if}
        </div>

        <div class="mrv-stage" aria-live="polite">
            {foreach from = $reviews item = review}
                <article class="mrv-slide{if $review.picture == ''} mrv-slide--text{/if}" {if !$review@first}hidden{/if}>
                    {if $review.picture != ''}
                        <a class="mrv-picture" href="{$review.picture_full|escape}" target="_blank" rel="noopener" aria-label="Xem ảnh gốc phản hồi của {$review.name|escape}">
                            <img src="{$review.picture|escape}" alt="Phản hồi của {$review.name|escape}" loading="lazy" decoding="async" />
                        </a>
                    {/if}
                    <div class="mrv-card">
                        <span class="mrv-quote-mark" aria-hidden="true">“</span>
                        <blockquote class="mrv-quote">{$review.quote|escape|nl2br}</blockquote>
                        <p class="mrv-byline">
                            {if $review.name != ''}<strong>{$review.name|escape}</strong>{/if}
                            {if $review.context != ''}<span>{$review.context|escape}</span>{/if}
                        </p>
                    </div>
                </article>
            {/foreach}
            {if $review_count > 1}
                <button type="button" class="mrv-arrow mrv-prev" aria-label="Phản hồi trước"><span aria-hidden="true">‹</span></button>
                <button type="button" class="mrv-arrow mrv-next" aria-label="Phản hồi tiếp theo"><span aria-hidden="true">›</span></button>
            {/if}
        </div>

        {if $review_count > 1}
            <div class="mrv-dots" aria-label="Chọn phản hồi">
                {foreach from = $reviews item = review}
                    <button type="button" class="mrv-dot" aria-label="Xem phản hồi {$review@iteration}" aria-current="{if $review@first}true{else}false{/if}"></button>
                {/foreach}
            </div>
        {/if}
    </div>
</section>
{/if}
{/strip}
