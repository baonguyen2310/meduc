{assign var = product value = []}
{if !empty($data_block.data)}
	{assign var = product value = $data_block.data}
{/if}

{assign var = first_item value = []}
{if !empty($product.items[0])}
	{assign var = first_item value = $product.items[0]}
{/if}

{if !empty($product)}
    {assign var = licensed value = false}
    {assign member_info value = $this->Member->getMemberInfo()}
    
    {if !empty($member_info.course)}
        {assign var = code_member value = $member_info.course}
        {if $code_member == "1"}
            {assign var = licensed value = true}
        {/if}
    {/if}
    
    <div nh-product-detail nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
        {if $licensed != true}
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
            <a id="product-agency-order" {if $has_item == 'true'}href="/order/info"{else}nh-btn-action="add-cart" nh-redirect="/order/info" href="javascript:;"{/if} class="btn btn-primary text-center">
                Đăng Ký Học
            </a>
        {/if}
    </div>
    
    <script>
        setTimeout(function myStopFunction() {
             document.getElementById("product-agency-order").click();
        }, 500);
        document.getElementById("product-agency-order").click();
    </script>
{/if}