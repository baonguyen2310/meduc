<div class="container mb-60 mt-70">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>
		<div class="col-12 col-md-9 col-lg-9">
			<div class="rounded bg-white">
				<div class="header-point d-flex align-items-center justify-content-between px-15 pt-20">
					<div class="number_point">
						<div class="name-money-send-member font-weight-bold mb-10">
							{__d('template', 'tang_diem')}
						</div>
						<div class="point">
							<p class="mb-5">
							    {__d('template', 'diem_vi')}: 
								<span class="fs-19 font-weight-bold color-orange">
							    	{if !empty($customer_point.point)}
							    		{$customer_point.point}
							    	{else}
							    		0
							    	{/if}
							    </span>
							</p>
							<p class="mb-5">
							    {__d('template', 'diem_thuong')}: 
								<span class="fs-16 font-weight-bold">
							    	{if !empty($customer_point.point_promotion)}
							    		{$customer_point.point_promotion}
							    	{else}
							    		0
							    	{/if}
							    </span>

							    {if !empty($customer_point.expiration_time)}
									<span class="color-hover font-weight-bold">
										({__d('template', 'thoi_gian_su_dung_den')}: {$this->Utilities->convertIntgerToDateString($customer_point.expiration_time)})
									</span>
								{/if}
							</p>
						</div>
					</div>
					<div class="recharge">
						<a href="#" class="btn btn-default font-weight-bold mr-10 py-7 px-20" nh-wallet>
							<img src="{URL_TEMPLATE}/assets/img/member/empty-wallet-add.png" alt="{__d('template', 'vi_cua_ban')}" width="24" height="24" />
							{__d('template', 'nap_tien')}
						</a>
					</div>
				</div>
				<hr>
				<div class="money-send px-20 pb-20">
					<div class="row">
						<div class="col-sm-6 col-xs-12">
							<form nh-form="money_send" action="/member/ajax-money-send" method="post" autocomplete="off">
							    <div class="form-group">
							        <label for="code">
							            {__d('template', 'ma_nguoi_nhan')}
							            <span class="required">*</span>
							        </label>
							        <input name="code" id="code" type="text" class="bg-white border form-control rounded input-hover pr-6 required" placeholder="{__d('template', 'ma_nguoi_nhan')}">
							    </div>

							    <div class="form-group">
							        <label for="code">
							            {__d('template', 'so_diem')}
							            <span class="required">*</span>
							        </label>
							        <input number-max="{if !empty($customer_point.point)}{$customer_point.point}{else}0{/if}" nh-input-max id="point-promotion"  type="text" class="bg-white border form-control rounded input-hover pr-6 number-input" placeholder="{__d('template', 'so_diem')}" autocomplete="off">

							        <span class="form-text text-muted fs-12">
		                                {__d('template', 'so_diem_phai_nho_hon_diem_trong_vi')}
		                            </span>
							    </div>

							    <span nh-btn-action="submit" class="btn text-uppercase btn-submit btn-user w-100 mb-10" >
							        {__d('template', 'xac_nhan')}
							    </span>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>