{strip}
<div
    nh-product="{if !empty($product.id)}{$product.id}{/if}"
    nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}"
    nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}"
>
    {assign var = cart_info value = $this->Cart->getCartInfo()}
    {assign var = has_item value = 'false'}
    {if !empty($cart_info['items'])}
    	{assign var = items value = $cart_info['items']}
        {foreach from = $items item = item}
            {if $item.product_id == $product.id}
                {assign var = has_item value = 'true'}
            {/if}
        {/foreach}
    {/if}
    <a id="product-pre-order" {if $has_item == 'true'}href="/order/info"{else}nh-btn-action="add-cart" nh-redirect="/order/info" href="javascript:;"{/if} class="d-none" data-button-buy>
        ĐĂNG KÝ NGAY
    </a>
    <script>
        setTimeout(
            function myStopFunction() {
  document.getElementById("product-pre-order").click();
}, 300);
        console.log(document.getElementById("product-pre-order"));
        document.getElementById("product-pre-order").click();
        console.log("OK")
    </script>
</div>
{/strip}