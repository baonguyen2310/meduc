{strip}
<div nh-comment="{htmlentities($block_config|@json_encode)}" nh-anchor="comment" class="comment-section">
	{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <div class="title-section-2">
            <span>{$this->Block->getLocale('tieu_de', $data_extend)}</span>
        </div>
    {/if}

	<div nh-comment-info class="customer-info d-none">
		<span nh-comment-change-info>
			<i class="iconsax isax-lg isax-edit mr-5"></i>
            <span nh-comment-fullname></span>
		</span>
	</div>

	<div class="edit-comment">
		<textarea nh-input-comment placeholder="{__d('template', 'moi_ban_de_lai_binh_luan')}"></textarea>	
		{*<div class="box-comment">			
			<label>
				<span nh-trigger-upload>
					<i class="iconsax isax-lg isax-camera"></i>
				</span>
			</label>
			<input nh-input-comment-images name="files[]" type="file" class="d-none" accept="image/jpeg, image/png" multiple="multiple">
		</div>*}

		<span nh-btn-send-comment class="btn btn-primary py-5 px-6 fs-13 mt-15">
			Gửi câu hỏi
		</span>
	</div>

	<b class="total-comment">
    	<span nh-total-comment></span> 
    	DANH SÁCH CÂU HỎI
    </b>

    <ul nh-list-comment class="list-comment"></ul>
</div>
{/strip}