<div nh-order-info>
	{$this->element('breadcrumb', [
		'list_url' => [
			['title' => {__d('template', 'thong_tin_don_hang')}]
		]
	])}

	<div class="container">
	    {*<div class="mb-20">
	        <p class="font-bold color-black">Đăng ký sớm khóa học Virtual Assistant 101</p>
	        <p class="font-bold fs-18 text-primary">Ngày ra mắt: 10/12/2022</p>
	    </div>*}
		<div class="checkout-section">
			<form id="order-info" method="post">
				<div class="row">
					<div id="order-info-left" class="col-lg-7 col-md-6">
						{$this->element('../Order/element_order_info_left')}
					</div>

					<div id="order-info-right" class="col-lg-5 col-md-6">
						{$this->element('../Order/element_order_info_right')}
					</div>
				</div>
			</form>
		</div>
	</div>

	{if !empty($member_info)}
		{$this->element('../Order/update_address_modal')}
	{/if}

	{$this->element('../Order/list_coupon_modal')}
</div>