{strip}
{if !empty($categories)}
	{foreach from = $categories item = category}
    	<li class="{if !empty($category.children)}has-child{/if}">
    		<a {if !empty($category.url)}href="{$this->Utilities->checkInternalUrl($category.url)}"{/if}>
    			{$category.name|escape}
    		</a>
    		{if !empty($category.children)}
    			{$this->element('../block/category_quiz/item_cate', [
    				'categories' => $category.children,
    				'parent_id' => $category.id
    			])}
    		{/if}
    	</li>
    {/foreach}
{/if}
{/strip}