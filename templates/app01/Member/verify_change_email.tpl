{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}
{assign var = email value = $this->Utilities->getParamsByKey('email')}
<div class="container">
	<div class="row justify-content-center">
		<div class="col-md-6 col-12">
			<div class="mb-60 rounded bg-white shadow p-30 session-login session-otp">
				<div class="color-hover font-weight-bold fs-28 mb-15">
			       {__d('template', 'thay_doi_email')}
			    </div>
				<form nh-form="vertify-change-email" action="/member/ajax-vertify-change-email" method="post" autocomplete="off">
				    <div class="form-group {if !empty($email)}d-none{/if}">
				        <label for="email" class="font-weight-normal color-main">
				            {__d('template', 'email')}: 
				            <span class="required">*</span>
				        </label>
				        <div class="input-login position-relative">
				        	<input name="email" type="text" class="bg-white border form-control rounded input-hover" value="{if !empty($email)}{$email}{/if}">
				        	<div class="icon-input">
				        		<i class="iconsax isax-lg isax-sms"></i>
	                        </div>
				        </div>
				    </div>
				    <div class="form-group mb-50 position-relative ">
				    	<label class="font-weight-normal color-main">
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
	                    <label for="new_email" class="font-weight-normal color-main">
	                        {__d('template', 'email_moi')}
	                        <span class="required">*</span>
	                    </label>
	                    <div class="input-login position-relative">
	                        <input id="new_email" name="new_email" type="text" class="bg-white border form-control rounded input-hover">
	                        <div class="icon-input">
	                            <i class="iconsax isax-lg isax-sms"></i>
	                        </div>
	                    </div>
	                </div>
				    
				    <div class="form-group">
				        <span nh-btn-action="submit" class="btn btn-main btn-1a color-white bg-main w-100">
				            {__d('template', 'xac_nhan')}
				        </span>
				    </div>
				    <div nh-btn-action="resend-verify" class="btn btn-outline-dark rounded btn-user w-100">
				        {__d('template', 'gui_lai_ma_xac_nhan')}?
				        <span class="ml-5" nh-countdown></span>
				    </div>
				</form>
			</div>
		</div>
	</div>	
</div>