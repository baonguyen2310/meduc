{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}
<div class="container mb-60">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>

		<div class="col-12 col-md-9 col-lg-9">
			<div class="rounded bg-white">
				<div class="header-point d-flex align-items-center justify-content-between px-15 pt-20">
					<div class="number_point">
						<div class="point">
							<p class="mb-5">
							    {__d('template', 'diem_vi')}: 
								<span class="fs-19 font-weight-bold color-orange">
							    	{if !empty($point_info.point)}
							    		{$point_info.point|number_format:0:".":","}
							    	{else}
							    		0
							    	{/if}
							    </span>
							</p>

							<p class="mb-5">
							    {__d('template', 'diem_thuong')}: 
								<span class="fs-16 font-weight-bold">
							    	{if !empty($point_info.point_promotion)}
							    		{$point_info.point_promotion|number_format:0:".":","}
							    	{else}
							    		0
							    	{/if}
							    </span>

							    {if !empty($point_info.expiration_time)}
									<small class="font-weight-bold text-muted">
										({__d('template', 'thoi_han_su_dung')}: 
										<span class="color-hover">
											{$this->Utilities->convertIntgerToDateString($point_info.expiration_time)})
										</span>
									</small>
								{/if}
							</p>
						</div>
					</div>

					<div class="recharge">
						<a href="/member/wallet/buy-point" class="btn btn-default font-weight-bold mr-10 py-7 px-20" nh-wallet>
							<i class="iconsax isax-2x color-hover isax-wallet-add pr-5"></i>
							{__d('template', 'nap_diem')}
						</a>
					</div>
				</div>

				<hr>
				<div class="session-otp session-change money-send px-20 pb-20">
					<form nh-form="give-point" id="give-point" method="post" autocomplete="off">
					    <div class="form-group">
					        <label for="code">
					            {__d('template', 'ma_nguoi_nhan')}
					            <span class="required">*</span>
					        </label>
					        <div class="input-login position-relative">
						        <input name="customer_code" type="text" class="bg-white border form-control rounded input-hover pr-6 required" placeholder="{__d('template', 'vi_du')}: CUS00000001">
						        <div class="icon-input">
					        		<i class="iconsax isax-lg isax-personalcard"></i>
		                        </div>
	                        </div>
					    </div>

					    <div class="form-group">
					        <label for="code">
					            {__d('template', 'so_diem')}
					            <span class="required">*</span>
					        </label>
					        <div class="input-login position-relative">
					        	<input name="point" nh-point-max="{if !empty($point_info.point)}{$point_info.point}{/if}" type="text" class="bg-white border form-control rounded input-hover pr-6 number-input" placeholder="{__d('template', 'so_diem')}" autocomplete="off">
					        	<div class="icon-input">
					        		<i class="iconsax isax-lg isax-coin-1"></i>
		                        </div>
					        </div>

					        <span class="form-text text-muted fs-12">
                                {__d('template', 'so_diem_phai_nho_hon_diem_trong_vi')}
                            </span>
					    </div>
				    	<div class="row">
				    		<div class="col-12 col-md-6">
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
				    		</div>
				    		<div class="col-12 col-md-6">
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
				    		</div>
				    	</div>
						<div class="row">
							<div class="col-6">
								<div class="form-group">
									<div class="input-group">
										<input nh-otp="verification" name="code" type="text" placeholder="{__d('template', 'vui_long_nhap_ma_xac_nhan')}" class="form-control form-control-sm input-hover px-15" />
										<div class="input-group-append">
									        <span nh-btn-action="get-verify" class="input-group-text input-group-main cursor-pointer">
												{__d('template', 'nhan_ma')}
									            <small class="ml-5" nh-countdown></small>
											</span>
									  	</div>
									</div>
								</div>
								<span nh-btn-action="submit" class="btn text-uppercase btn-submit btn-user px-30 w-100" >
							        {__d('template', 'xac_nhan')}
							    </span>
							</div>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>	
</div>