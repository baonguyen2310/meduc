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
							{__d('template', 'nap_diem_thanh_cong')}
						</div>
					</div>
				</div>
				{if !empty($point_history)}
					<div class="notification text-center mt-30 pb-30 max-w-300 mx-auto">
						<div class="icon">
							<img src="{URL_TEMPLATE}/assets/img/member/check.png" alt="{__d('template', 'thanh_cong')}" width="64" height="64" />
							<p class="mb-5 mt-10">{__d('template', 'nap_diem_thanh_cong')}</p>
							<p>
								{__d('template', 'ban_da_nap_thanh_cong')}
								<span class="text-success font-weight-bold">
									{if !empty($point_history.point)}
										+{$point_history.point|number_format:0:".":","}
									{/if}
								</span>
								{__d('template', 'diem_vao_vi')}
							</p>
						</div>
						<div class="info text-left">
							<ul class="list-unstyled">
								<li class="d-flex justify-content-between mb-15">
									<span>{__d('template', 'ma_giao_dich')}</span>
									<span class="text-primary">
										{if !empty($info_payment.code)}
											{$info_payment.code}
										{/if}
									</span>
								</li>
								<li class="d-flex justify-content-between mb-15">
									<span>{__d('template', 'thanh_toan')}</span>
									<span class="text-success">
										{if !empty($info_payment.amount)}
											{$info_payment.amount|number_format:0:".":","}{CURRENCY_UNIT}
										{/if}
									</span>
								</li>
							</ul>
						</div>
						<div class="action pt-70">
							<a href="/member/wallet" class="btn btn-default btn-home-page mr-10">
								{__d('template', 'vi_cua_ban')}
							</a>
							<a href="/member/wallet/buy-point" class="btn btn-default btn-buy-point">
								{__d('template', 'giao_dich_moi')}
							</a>
						</div>
					</div>
				{/if}
			</div>
		</div>
	</div>	
</div>