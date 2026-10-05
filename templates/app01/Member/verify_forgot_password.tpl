{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}
{assign var = email value = $this->Utilities->getParamsByKey('email')}
<div class="container">
	<div class="row justify-content-center">
		<div class="col-xl-5 col-lg-6 col-md-8 col-12">
			<div class="mb-60 rounded bg-white shadow-box7 p-30 session-login session-otp">
				<div class="color-hover font-weight-bold fs-28 mb-15">
			       {__d('template', 'quen_mat_khau')}
			    </div>
				<form nh-form="verify-forgot-password" action="/member/ajax-verify-forgot-password" method="post" autocomplete="off">
				    <div class="form-group {if !empty($email)}d-none{/if}">
				        <label for="email" class="font-weight-bold">
				            {__d('template', 'email')}: 
				            <span class="required">*</span>
				        </label>
				        <div class="input-login position-relative">
				        	<input name="email" type="text" class="form-control rounded" value="{if !empty($email)}{$email}{/if}">
				        	<div class="icon-input">
	                            <i class="iconsax isax-lg isax-sms"></i>
	                        </div>
				        </div>
				    </div>
				    <div class="form-group mb-50 position-relative ">
				    	<label for="email" class="font-weight-bold">
				            {__d('template', 'ma_xac_nhan')}: 
				            <span class="required">*</span>
				        </label>
                        <div class="input-opt d-flex align-items-center justify-content-between">
                            <input nh-otp="input" type="text" maxlength="1" />
                            <input nh-otp="input" type="text" maxlength="1" />
                            <input nh-otp="input" type="text" maxlength="1" />
                            <input nh-otp="input" type="text" maxlength="1" />
                            <input nh-otp="input" type="text" maxlength="1" />
                        </div>
                        <input nh-otp="verification" name="code" type="hidden"/>
                    </div>

	                <div class="form-group">
	                    <label for="new_password" class="font-weight-bold">
	                        {__d('template', 'mat_khau_moi')}
	                        <span class="required">*</span>
	                    </label>
	                    <div class="input-login position-relative">
	                        <input id="new_password" name="new_password" type="password" class="form-control rounded">
	                        <div class="icon-input">
	                            <i class="iconsax isax-lg isax-lock"></i>
	                        </div>
	                    </div>
	                </div>

	                <div class="form-group">
	                    <label for="password" class="font-weight-bold">
	                        {__d('template', 'nhap_lai_mat_khau_moi')}
	                        <span class="required">*</span>
	                    </label>
	                    <div class="input-login position-relative">
	                        <input id="re_password" name="re_password" type="password" class="form-control rounded">
	                        <div class="icon-input">
	                            <i class="iconsax isax-lg isax-lock"></i>
	                        </div>
	                    </div>
	                </div>
				    
				    <div class="form-group">
				        <span nh-btn-action="submit" class="btn btn-primary py-[15px] px-8 text-center w-100">
				            {__d('template', 'xac_nhan')}
				        </span>
				    </div>
				    <div nh-btn-action="resend-verify" class="btn bg-black text-white py-[15px] px-8 text-center w-100">
				        {__d('template', 'gui_lai_ma_xac_nhan')}?
				        <span class="ml-5" nh-countdown></span>
				    </div>
				</form>
			</div>
		</div>
	</div>	
</div>