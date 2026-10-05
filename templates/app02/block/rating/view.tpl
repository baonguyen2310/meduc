{strip}
<div nh-rating="{htmlentities($block_config|@json_encode)}" nh-anchor="rating">
	<div class="title-section-3">
		<span>
			{__d('template', 'khach_hang_danh_gia')}
		</span>
	</div>

	{$this->element('../block/rating/form')}

	<ul nh-list-rating class="rating-list"></ul>
</div>
{/strip}