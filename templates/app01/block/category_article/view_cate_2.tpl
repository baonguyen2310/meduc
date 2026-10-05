{strip}
	{foreach from = $breadcrumb item = item name = breadcrumb_each}
        {if $smarty.foreach.breadcrumb_each.last}
            <h3 class="title-section-1">{$item.name|escape}</h3>
        {/if}
    {/foreach}

	{if !empty($data_block.data)}
	    <ul class="categories-section list-unstyled">
            {$this->element('../block/category_article/item_cate_2', [
	        	'categories' => $data_block.data,
	        	'parent_id' => null
	        ])}
        </ul>
	{/if}
{/strip}