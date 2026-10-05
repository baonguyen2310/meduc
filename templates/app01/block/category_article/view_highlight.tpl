{strip}
	{if !empty($data_block.data)}
	    <div nh-menu="active">
	        {$this->element('../block/category_article/item_highlight', [
	        	'categories' => $data_block.data,
	        	'parent_id' => null
	        ])}
	    </div>
	{/if}
{/strip}