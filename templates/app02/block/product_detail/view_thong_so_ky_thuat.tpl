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

{assign var = attributes value = []}
{if !empty($product.attributes)}
	{assign var = attributes value = $product.attributes}
{/if}
{if !empty($product)}
	{strip}
	{if !empty($attributes.thongso.value)}
    	<div class="bg-white rounded mb-10 py-10 px-15">
    	    {if !empty($attributes.thongso.name)}
                <div class="title-section-3">
                    {$attributes.thongso.name}
                </div>
            {/if}
        	{if !empty($attributes.thongso.value)}
            	<div class="thong-so-ky-thuat">
            	    {$attributes.thongso.value}
            	</div>
        	{/if}
    	</div>
	{/if}
{else}
	<p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}