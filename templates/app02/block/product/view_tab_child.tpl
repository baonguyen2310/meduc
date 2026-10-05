{if !empty($data_block.data)}
	{if !empty($data_extend.slider)}
	    <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}" class="">
	        {foreach from = $data_block.data item = product}
	            {$this->element("../block/{$block_type}/item", [
	            	'product' => $product, 
	            	'is_slider' => true
	            ])}
	        {/foreach} 
	    </div>
	{else}
	    <div class="row">
	        {foreach from = $data_block.data item = product}
	            {$this->element("../block/{$block_type}/item", [
	            	'product' => $product, 
	            	'is_slider' => false
	            ])}
	        {/foreach} 
	    </div>
	{/if}
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}