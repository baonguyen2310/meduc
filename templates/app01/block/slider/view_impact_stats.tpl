{strip}
{* Homepage connection panel from main:hero-light/assets/home-community.js.
   Keep the four figures, icons and URLs editable in the original contact slider block. *}
{$community_items = $this->Block->getSliderItems('3p9qz6e')}
{$platforms = ['YOUTUBE', 'NHÓM FACEBOOK', 'FACEBOOK', 'ZALO']}
{if !empty($community_items)}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Anton&display=swap" rel="stylesheet">
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/community.css?v=20261028-1" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/community.js?v=20261028-1" defer></script>
<section class="mhi-community" aria-labelledby="mhi-community-title">
    <div class="mhi-community-shell">
        <div class="mhi-community-panel">
            <div class="mhi-community-grid" aria-label="Cộng đồng MedUC trên các nền tảng">
                {foreach from = $community_items item = item key = index}
                    {$count = $item.name|default:''|regex_replace:'/[^0-9]/':''}
                    {if $count == '' || empty($item.url)}{continue}{/if}
                    {$shown = $count|number_format:0:',':'.'}
                    {$platform = $platforms[$index]|default:''}
                    {$image_url = $item.image|default:''}
                    {if !empty($image_url) && $item.image_source == 'cdn'}{$image_url = "{CDN_URL}{$image_url}"}{/if}
                    <a class="mhi-community-card" href="{$item.url|escape}" target="_blank" rel="noopener noreferrer" data-platform="{$index + 1}" aria-label="{$platform|escape}: {$shown}+ {$item.description|escape}">
                        <span class="mhi-community-card-top">
                            <span class="mhi-community-icon">{if !empty($image_url)}<img src="{$image_url|escape}" alt="" loading="lazy" decoding="async">{/if}</span>
                            <span class="mhi-community-card-arrow" aria-hidden="true">↗</span>
                        </span>
                        <span class="mhi-community-card-details">
                            <small>{$platform|escape}</small>
                            <strong aria-hidden="true"><span class="mhi-count-value" data-count="{$count}">{$shown}</span><span>+</span></strong>
                            <span>{$item.description|escape}</span>
                        </span>
                    </a>
                {/foreach}
            </div>
            <div class="mhi-community-copy">
                <p class="mhi-community-kicker">THÔNG TIN LIÊN HỆ · MEDUC</p>
                <h2 id="mhi-community-title">KẾT NỐI<br>CÙNG MEDUC.</h2>
                <p class="mhi-community-description">Theo dõi nội dung và trao đổi kiến thức Y khoa cùng cộng đồng MedUC trên YouTube, Facebook và Zalo.</p>
                <div class="mhi-community-actions">
                    {if !empty($community_items[1].url)}<a class="mhi-community-primary" href="{$community_items[1].url|escape}" target="_blank" rel="noopener noreferrer">Tham gia nhóm Facebook</a>{/if}
                    {if !empty($community_items[3].url)}<a class="mhi-community-secondary" href="{$community_items[3].url|escape}" target="_blank" rel="noopener noreferrer">Nhóm học tập Zalo <span aria-hidden="true">→</span></a>{/if}
                </div>
            </div>
        </div>
    </div>
</section>
{/if}
{/strip}
