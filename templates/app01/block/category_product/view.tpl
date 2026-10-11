{strip}
<h3 class="title-section-1">
	{$this->Block->getLocale('tieu_de', $data_extend)}
</h3>

{if !empty($data_block.data)}
    <div nh-menu="active">
        {$this->element('../block/category_product/item', [
        	'categories' => $data_block.data,
        	'parent_id' => null
        ])}
    </div>
{/if}
{/strip}