{strip}
<div nh-rating="{htmlentities($block_config|@json_encode)}" nh-anchor="rating">
	{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <div class="title-section-2">
            <span>{$this->Block->getLocale('tieu_de', $data_extend)}</span>
        </div>
    {/if}

	{$this->element('../block/rating/form')}

	<ul nh-list-rating class="rating-list"></ul>
</div>
{/strip}