{assign var = product value = []}
{if !empty($data_block.data)}
	{assign var = product value = $data_block.data}
{/if}

{assign var = first_item value = []}
{if !empty($product.items[0])}
	{assign var = first_item value = $product.items[0]}
{/if}

{assign var = all_images value = []}
{if !empty($product.all_images)}
	{assign var = all_images value = $product.all_images}
{/if}
{if !empty($product)}
    {assign var = licensed value = false}
    {assign member_info value = $this->Member->getMemberInfo()}
    {if !empty($member_info.code)}
        {assign var = code_member value = $member_info.code}
        {if !empty($product.attributes.danhsachtaikhoan.value)}
            {assign var = list_student value = $product.attributes.danhsachtaikhoan.value}
            
            {if strpos($list_student, $code_member) != false}
                {assign var = licensed value = true}
            {/if}
        {/if}
    {/if}
    
    {*if !empty($member_info.course)}
        {assign var = code_member value = $member_info.course}
        {if $code_member == "1"}
            {assign var = licensed value = true}
        {/if}
    {/if*}
    {*if !empty($all_images[0])}
        <div class="main-image thumbnail">
            <img class="radius-small" src="{CDN_URL}{$all_images[0]}" alt="{if !empty($product.name)}{$product.name}{/if}">
        </div>
    {/if*}
{/if}