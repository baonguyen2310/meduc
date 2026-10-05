<div class="error-page text-center py-80">
	<i class="iconsax isax-warning-2"></i>
	<p class="color-main">
		{if !empty($message)}
			{$message}.
		{else}
			{__d('template', 'xin_loi_da_co_loi_he_thong_xay_ra_ban_vui_long_quay_lai_trang_chu')}.
		{/if}	
	</p>
	<a href="/">
		{__d('template', 'trang_chu')}
	</a>
</div>