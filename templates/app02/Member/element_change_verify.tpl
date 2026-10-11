<div class="form-group">
	{if !empty($member.email)}
		<div class="entry-choose-verify mb-15">
			<input name="type_verify" id="verify-email" checked="checked" value="email" class="form-check-input" type="radio" >
            <label class="d-flex align-items-center mb-0 inner-verify border rounded p-10" for="verify-email">
                <div class="icon-left text-center mr-15">
                    <i class="iconsax color-white isax-lg isax-sms"></i>
                </div>
                
                <div>
                    <p class="mb-0">
                        <b>{__d('template', 'lay_ma_xac_nhan_qua_email')}</b>
                    </p>
                    <p class="mb-0 fs-12 font-weight-normal">
                    	<span class="color-hover">
                    		{__d('template', 'email')}: {$member.email}
                    	</span>
                    </p>
                </div>
                <div class="icon-right ml-auto">
                    <i class="iconsax isax-2x isax-tick-circle5"></i>
                </div>
            </label>
		</div>
	{/if}
    
    {assign var = sms_usage value = $this->Setting->checkSmsBrandUsage()}
	{if !empty($member.phone) && $sms_usage}
		<div class="entry-choose-verify  mb-15">
			<input name="type_verify" id="verify-phone" {if empty($member.email)}checked="checked"{/if} value="phone" class="form-check-input" type="radio" >
            <label class="d-flex align-items-center mb-0 inner-verify border rounded p-10" for="verify-phone">
                <div class="icon-left text-center mr-15">
                    <i class="iconsax color-white isax-lg isax-call-calling"></i>
                </div>
                
                <div class="text-forgot">
                    <p class="mb-0">
                        <b>{__d('template', 'lay_ma_xac_nhan_qua_dien_thoai')}</b>
                    </p>
                    <p class="mb-0 fs-12 font-weight-normal">
                    	<span class="color-hover">
                    		{__d('template', 'so_dien_thoai')}: {$member.phone}
                    	</span>
                    </p>
                </div>
                <div class="icon-right ml-auto">
                    <i class="iconsax isax-2x isax-tick-circle5"></i>
                </div>
            </label>
		</div>
	{/if}
	<div class="form-group">
        <span nh-btn-action="get-verify" class="btn btn-main btn-1a color-white bg-main w-100">
            {__d('template', 'nhan_ma')}
            <small class="ml-5" nh-countdown></small>
        </span>
    </div>
</div>

<div class="form-group mb-20 position-relative ">
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