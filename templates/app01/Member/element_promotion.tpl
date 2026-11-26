{foreach $legacy_offers as $offer}
    <li class="mvp-offer">
        {if !empty($offer.value.value_discount) && !empty($offer.value.type_value_discount)}
            <strong class="mvp-discount">Giảm {if $offer.value.type_value_discount == 'percent'}{$offer.value.value_discount|escape}%{else}{$offer.value.value_discount|number_format:0:',':'.'}đ{/if}</strong>
        {/if}
        <h3>{$offer.name|default:''|escape}</h3>
        {if !empty($offer.condition_description)}
            {foreach $offer.condition_description as $condition}<p>{$condition|escape}</p>{/foreach}
        {/if}
        {if !empty($offer.code)}
            <div class="mvp-code"><code>{$offer.code|escape}</code><button type="button" data-copy-voucher="{$offer.code|escape}">Sao chép</button></div>
        {/if}
    </li>
{/foreach}
