{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<div class="container">
	<div class="row justify-content-center">
		<div class="col-md-5 col-12">
			<div class="mb-60 rounded bg-white shadow-box7 p-30 session-change session-otp">
				<div class="color-hover font-weight-bold fs-28 mb-15">
			       {__d('template', 'thay_doi_email')}
			    </div>
				<form nh-form="change-email" action="/member/ajax-change-email" method="post" autocomplete="off">
					{$this->element('../Member/element_change_verify')}

				    <div class="form-group">
				        <label for="new_email" class="font-weight-bold">
				            {__d('template', 'email_moi')}: 
				            <span class="required">*</span>
				        </label>
				        <div class="input-login position-relative">
				        	<input name="new_email" type="text" class="bg-white border form-control rounded input-hover">
				        	<div class="icon-input">
				        		<i class="iconsax isax-lg isax-sms"></i>
	                        </div>
				        </div>
				    </div>
				    <input type="hidden" name="type" value="email">
				    
				    <div class="form-group">
				        <span nh-btn-action="submit" class="btn btn-primary fs-14 py-10 px-10 mt-10 w-100">
				            {__d('template', 'xac_nhan')}
				        </span>
				    </div>
				</form>
			</div>
		</div>
	</div>	
</div>