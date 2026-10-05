{strip}
<h3 class="title-section-1 mb-20">
	{$this->Block->getLocale('tieu_de', $data_extend)}
</h3>
<div class="view-small">
	{if !empty($data_block.data)}
		{foreach from = $data_block.data item = article key = k_article}
			{$this->element("../block/{$block_type}/item_small", ['article' => $article])}
		{/foreach}
    {else}
        {__d('template', 'khong_co_du_lieu')}
	{/if}
</div>
{/strip}