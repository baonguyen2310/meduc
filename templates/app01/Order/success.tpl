{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {__d('template', 'don_hang_thanh_cong')}]
	]
])}

<div class="container">
	<div class="order-section">
	    {assign website_info value = $this->Setting->getWebsiteInfo()}
	    
		<div class="alert alert-success text-center mb-30" role="alert">
		  	Cảm ơn bạn đã đăng ký khóa học!
		  	{if !empty($website_info.phone)}Vui lòng liên hệ đến sđt <strong>{$website_info.phone}</strong> để được kích hoạt khóa học sớm nhất.{/if}
		  	{if !empty($order_info.code)}
		  		<strong>{__d('template', 'ma_don_hang')}: {$order_info.code}</strong>
		  	{/if}
		</div>

		{assign var = contact value = []}
		{if !empty($order_info.contact)}
			{assign var = contact value = $order_info.contact}
		{/if}

		<div class="order-info mb-15">
			<div class="order-item border rounded p-15">
				<h3 class="font-weight-bold fs-20 mb-10 color-black">
					Thông tin khách hàng
				</h3>
				{if !empty($contact.full_name)}
					<div class="mb-3">
						{__d('template', 'ho_va_ten')}: <b>{$contact.full_name}</b>
					</div>
				{/if}

				{if !empty($contact.phone)}
					<div class="mb-3">
						{__d('template', 'so_dien_thoai')}: <b>{$contact.phone}</b>
					</div>
				{/if}

				{if !empty($contact.email)}
					<div class="mb-3">
						{__d('template', 'email')}: <b>{$contact.email}</b>
					</div>
				{/if}

				{if !empty($contact.full_address)}
					<div class="mb-3">
						{__d('template', 'dia_chi')}: <b>{$contact.full_address}</b>
					</div>
				{/if}
				{if !empty($order_info.note)}
					<div class="mb-3">
						{__d('template', 'ghi_chu')}: <b>{$order_info.note}</b>
					</div>
				{/if}
			</div>
		</div>

		<div class="row">
			<div class="col-lg-7 col-md-6">
				{$this->element('../Order/element_product_info')}
			</div>
			<div class="col-lg-5 col-md-6">
				{$this->element('../Order/element_items')}
			</div>
		</div>
	</div>
</div>