{strip}

{if !empty($data_block.data)}
   <div class="row">
        {$this->element('../block/category_article/item_product', [
        	'categories' => $data_block.data,
        	'parent_id' => null
        ])}
    </div>
{/if}
{/strip}