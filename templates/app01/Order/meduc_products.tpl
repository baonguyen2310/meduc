{if !empty($order_info.items)}{foreach from=$order_info.items item=item}
<article class="mco-cart-item"><div class="mco-cart-picture">{if !empty($item.images[0])}<img src="{CDN_URL}{$item.images[0]|escape}" alt="">{else}MedUC{/if}</div><div class="mco-cart-copy"><h3>{$item.name_extend|default:$item.name|escape}</h3><div class="mco-item-prices"><strong>{$item.total_item|default:0|number_format:0:',':'.'} {CURRENCY_UNIT}</strong>{if !empty($item.price_old)}<del>{$item.price_old|number_format:0:',':'.'} {CURRENCY_UNIT}</del>{/if}</div></div></article>
{/foreach}{/if}
