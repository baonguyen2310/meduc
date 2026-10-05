{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<div class="container">
	<div class="row justify-content-center">
		<div class="col-md-5 col-12">
			<div class="mb-60 rounded bg-white shadow p-30 session-password">
				<div class="color-hover font-weight-bold fs-28 mb-15">
			       {__d('template', 'quen_mat_khau')}
			    </div>
				<form nh-form="forgot-password" action="/member/ajax-forgot-password" method="post" autocomplete="off">
					<div class="form-group forgot-email d-flex align-items-center mb-15 p-10 rounded">
                       <div class="icon-input text-center mr-15">
                       		<i class="iconsax color-white isax-lg isax-sms"></i>
                        </div>
                        
                        <div class="text-forgot">
                            <p class="mb-0 color-main">
                                <b>{__d('template', 'khoi_phuc_mat_khau_qua_email')}</b>
                            </p>
                            <p class="mb-0 fs-12">
                            	{__d('template', 'ma_se_gui_qua_email_ban_dang_ky_de_thay_doi_mat_khau')}
                            </p>
                        </div>
                        
                        <div class="icon-right ml-15">
                        	<i class="iconsax isax-2x isax-tick-circle5"></i>
                        </div>
                   </div>
				    <div class="form-group">
				        <label for="email" class="font-weight-normal color-main">
				            {__d('template', 'email')}: 
				            <span class="required">*</span>
				        </label>
				        <div class="input-login position-relative">
				        	<input name="email" type="text" class="form-control rounded">
				        	<div class="icon-input">
	                            <i class="iconsax isax-lg isax-sms"></i>
	                        </div>
				        </div>
				    </div>
				    
				    <div class="form-group">
				        <span nh-btn-action="submit" class="btn btn-main btn-1a color-white bg-main rounded btn-user w-100">
				            {__d('template', 'xac_nhan')}
				        </span>
				    </div>
				</form>
			</div>
		</div>
	</div>	
</div>