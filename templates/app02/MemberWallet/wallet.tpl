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
			<div class="rounded bg-white p-15 h-100">
				<div class="header-point d-flex align-items-center justify-content-between border-bottom pb-10">
					<div class="number_point">
						<div class="point">
							<p class="mb-5">
							    {__d('template', 'diem_vi')}: 
								<span class="fs-19 font-weight-bold color-hover">
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

						<a href="/member/wallet/give-point" class="btn btn-default font-weight-bold py-7 px-20" nh-money-send>
							<i class="iconsax isax-2x color-hover isax-money-send pr-5"></i>
							{__d('template', 'chuyen_diem')}
						</a>
					</div>
				</div>
				<div class="history-point pb-20">
					<ul class="nav nav-tabs mt-0 mb-10 row">
					  	<li class="col-sm-6 col-12">
					  		<a class="font-weight-bold active" data-toggle="tab" nh-wallet-redirect>{__d('template', 'tat_ca_lich_su')}</a>
					  	</li>
					  	<li class="col-sm-3 col-12">
					  		<a class="font-weight-bold" data-toggle="tab" nh-wallet-redirect="1">{__d('template', 'da_nhan')}</a>
					  	</li>
					  	<li class="col-sm-3 col-12">
					  		<a class="font-weight-bold" data-toggle="tab" nh-wallet-redirect="0">{__d('template', 'da_dung')}</a>
					  	</li>
					</ul>
					<div class="tab-content">
					  	<div id="transaction_history" class="tab-pane fade show active">
						    {$this->element('../MemberWallet/element_wallet',['history'=> $history])}
					  	</div>
					</div>
				</div>	
			</div>
		</div>
	</div>	
</div>