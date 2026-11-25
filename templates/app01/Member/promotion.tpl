{assign var=legacy_offers value=$this->Promotion->getPublicPromotions()}
<main class="mvp" data-voucher-center>
    <header class="mvp-title">
        <h1>Ưu đãi của tôi</h1>
    </header>

    <section class="mvp-online" aria-labelledby="mvp-online-title" data-online-dashboard>
        <div class="mvp-online-top">
            <div>
                <h2 id="mvp-online-title">Thưởng thời gian online</h2>
                <p>Dùng cho Khoá ôn kiến thức.</p>
            </div>
            <div class="mvp-clock">
                <span>Online tuần này</span>
                <strong data-online-total>—</strong>
            </div>
        </div>
        <progress data-online-meter aria-label="Tiến độ đến mốc thưởng tiếp theo" value="0" max="1" hidden></progress>
        <div class="mvp-online-meta">
            <p data-online-next>Đang tải thời gian online…</p>
            <p data-online-reset></p>
        </div>
        <ul class="mvp-milestones" data-online-milestones></ul>
    </section>

    <div class="mvp-groups">
        {foreach $voucher_groups as $group}
            <section class="mvp-group" aria-labelledby="mvp-group-{$group@iteration}">
                <h2 id="mvp-group-{$group@iteration}">{$group.title|escape}</h2>
                {if $group.offers || ($group@first && $legacy_offers)}
                    <ul class="mvp-offers">
                        {foreach $group.offers as $offer}
                            <li class="mvp-offer">
                                <strong class="mvp-discount">Giảm {if $offer.type == 'percent'}{$offer.value}%{else}{$offer.value|number_format:0:',':'.'}đ{/if}</strong>
                                <h3>{$offer.name|escape}</h3>
                                <p>{$offer.scope|escape}{if $offer.expiry_label} · Đến {$offer.expiry_label|escape}{/if}</p>
                                {if $offer.code}
                                    <div class="mvp-code"><code>{$offer.code|escape}</code><button type="button" data-copy-voucher="{$offer.code|escape}">Sao chép</button></div>
                                {elseif $offer.remaining_spend}
                                    <p class="mvp-remaining">Cần chi thêm {$offer.remaining_spend|number_format:0:',':'.'}đ</p>
                                    <p>Kỳ tích lũy {$offer.spend_label|escape}</p>
                                {/if}
                            </li>
                        {/foreach}
                        {if $group@first}
                            {$this->element('../Member/element_promotion', ['legacy_offers' => $legacy_offers])}
                        {/if}
                    </ul>
                {else}
                    <p class="mvp-empty">{$group.empty|escape}</p>
                {/if}
            </section>
        {/foreach}
    </div>
    <p class="mvp-status" role="status" data-voucher-notice></p>
</main>
