{strip}
<div nh-comment="{htmlentities($block_config|@json_encode)}" nh-anchor="comment" class="comment-section">
	<div class="title-section-3">
		<span> 
			{__d('template', 'binh_luan')}
		</span>
	</div>

	<div nh-comment-info class="customer-info d-none">
		<span nh-comment-change-info>
			<i class="iconsax isax-lg isax-edit mr-5"></i>
            <span nh-comment-fullname></span>
		</span>
	</div>

	<div class="edit-comment">
		<textarea nh-input-comment placeholder="{__d('template', 'moi_ban_de_lai_binh_luan')}"></textarea>	
		<div class="box-comment">			
			<label>
				<span nh-trigger-upload>
					<i class="iconsax isax-lg isax-camera"></i>
				</span>
			</label>
			<input nh-input-comment-images name="files[]" type="file" class="d-none" accept="image/jpeg, image/png" multiple="multiple">
		</div>

		<span nh-btn-send-comment class="btn btn-dark">
			{__d('template', 'gui_binh_luan')}
		</span>
	</div>

	<b class="total-comment">
    	<span nh-total-comment></span> 
    	{__d('template', 'binh_luan')}
    </b>

    <ul nh-list-comment class="list-comment"></ul>
</div>
{/strip}