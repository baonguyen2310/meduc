{strip}
{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <h3 class="title-section-1">
    	{$this->Block->getLocale('tieu_de', $data_extend)}
    </h3>
{/if}
<ul class="view-link">
	{if !empty($data_block.data)}
		{foreach from = $data_block.data item = article key = k_article}
			{$this->element("../block/{$block_type}/item_link", ['article' => $article])}
		{/foreach}
    {else}
        {__d('template', 'khong_co_du_lieu')}
	{/if}
</ul>

{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}