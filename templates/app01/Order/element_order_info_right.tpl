{assign var = coupon_info value = []}
{if !empty($order_info.coupon)}
	{assign var = coupon_info value = $order_info.coupon}
{/if}

{assign var = config_point value = $this->Setting->getSettingWebsite('point')}

{assign var = point_to_money value = 1}
{if !empty($config_point.point_to_money)}
	{assign var = point_to_money value = $config_point.point_to_money}
{/if}

{assign var = point_promotion_max value = 1}
{if !empty($member_info.point_promotion)}
	{assign var = point_promotion_max value = $member_info.point_promotion}
{/if}

{assign var = point_max value = 1}
{if !empty($member_info.point)}
	{assign var = point_max value = $member_info.point}
{/if}

{assign var = status_pay_by_point value = 0}
{if !empty($config_point.pay_by_point)}
	{assign var = status_pay_by_point value = $config_point.pay_by_point}
{/if}

{assign var = plugins value = $this->Setting->getListPlugins()}

<div class="order-review">
	<div class="entry-order-review">
		<div class="cart-drop-botoom">
		   <div id="accordion-order">
		   		{if !empty($plugins.promotion)}
			        <div class="card border rounded mb-10">
			            <div class="card-header">
			                <div class="btn fs-13 d-flex justify-content-between align-items-center w-100" data-bs-toggle="collapse" data-bs-target="#coupon-panel" aria-expanded="true">
			                    <span class="d-flex align-items-center" >
			                    	<i class="iconsax isax-2x color-hover isax-ticket"></i>
			                        <span class="pl-10">
			                            {__d('template', 'phieu_giam_gia')}
			                        </span>
			                    </span>

			                    <span class="d-flex align-items-center" >
			                    	{if !empty($coupon_info.coupon)}
				                        <strong class="pr-5 font-success">
				                            {$coupon_info.coupon}
				                        </strong>
				                    {/if}
			                        <span >
			                            <i class="iconsax isax-arrow-down-1"></i>
			                        </span>
			                    </span>
			                </div>
			            </div>
			    
			            <div id="coupon-panel" class="collapse" data-bs-parent="#accordion-order">
			                <div class="p-15">
	                			<div class="form-group mb-10">
				                    <input id="order-coupon-code" value="{if !empty($coupon_info.coupon)}{$coupon_info.coupon}{/if}" type="text" class="bg-white border form-control rounded input-hover" placeholder="{__d('template', 'nhap_phieu_giam_gia')}" >
			                    </div>
			                    {if !empty($coupon_info.total)}
		                            <small class="font-weight-bold font-success mb-10 d-block">
			                    		{__d('template', 'chiet_khau')}:
			                    		{$coupon_info.total|number_format:0:".":","} {CURRENCY_UNIT}
			                    	</small>
		                        {/if}

			                    <span nh-btn-action="apply-coupon" class="btn btn-primary py-5 fs-14 px-25 mb-15 w-100 rounded">
			                        {__d('template', 'ap_dung')}
			                    </span>

			                    <div class="d-flex justify-content-between align-items-center mb-5">
			                    	<a class="btn fs-13 border border-hover" href="javascript:;" nh-btn-action="list-coupon">
			                    		<i class="iconsax isax-ticket"></i>
				                        {__d('template', 'lay_phieu_giam_gia')}
				                    </a>
				                    {if !empty($coupon_info.coupon)}
				                    	<a href="javascript:;" nh-btn-action="delete-coupon" class="color-hover">
					                        {__d('template', 'huy_phieu_giam_gia')}
					                    </a>
				                    {/if}
			                    </div>
			                </div>
			            </div>
			        </div>
			        <input name="coupon" value="{if !empty($coupon_info.coupon)}{$coupon_info.coupon}{/if}" type="hidden">
			        <input name="promotion_id" value="{if !empty($coupon_info.promotion_id)}{$coupon_info.promotion_id}{/if}" type="hidden">
		       	{/if}

				{if !empty($plugins.affiliate)}
			        <div class="card border rounded mb-10 d-none">
			            <div class="card-header">
			                <div class="btn d-flex justify-content-between align-items-center w-100" data-toggle="collapse" data-target="#affiliate-panel" aria-expanded="true">
			                    <span class="d-flex align-items-center" >
			                    	<i class="iconsax isax-2x color-hover isax-bookmark-2"></i>
			                        <span class="pl-10">
			                            {__d('template', 'ma_gioi_thieu')}
			                        </span>
			                    </span>

			                    <span class="d-flex align-items-center" >
			                    	{if !empty($order_info.affiliate.affiliate_code)}
				                        <strong class="pr-5 font-success">
				                            {$order_info.affiliate.affiliate_code}
				                        </strong>
				                    {/if}
			                        <span >
			                            <i class="iconsax isax-arrow-down-1"></i>
			                        </span>
			                    </span>
			                </div>
			            </div>
			    
			            <div id="affiliate-panel" class="collapse" data-parent="#accordion-order">
			                <div class="p-15">
	                			<div class="form-group mb-10">
				                    <input id="affiliate-code" value="" type="text" class="bg-white border form-control rounded input-hover" placeholder="{__d('template', 'nhap_ma_gioi_thieu')}" >
			                    </div>

			                    <span nh-btn-action="apply-affiliate" class="btn btn-primary w-full text-center">
			                        {__d('template', 'ap_dung')}
			                    </span>
			                    
			                    <a href="javascript:;" nh-btn-action="delete-affiliate" class="color-hover mt-5 d-block">
			                        {__d('template', 'huy_ap_dung_ma_gioi_thieu')}
			                    </a>

			                    {*if !empty($order_info.affiliate.total_affiliate)}
			                    	<a href="javascript:;" nh-btn-action="delete-affiliate" class="color-hover mt-5 d-block">
				                        {__d('template', 'huy_ap_dung_ma_gioi_thieu')}
				                    </a>
			                    {/if*}
			                </div>
			            </div>
			        </div>
		        {/if}

		       	{if !empty($plugins.point) && !empty($status_pay_by_point)}
			        <div class="card border rounded mb-10">
			            <div class="card-header">
			                <div class="btn collapsed d-flex justify-content-between align-items-center w-100" data-toggle="collapse" data-target="#point-panel">
			                    <span class="d-flex align-items-center" >
			                    	<i class="iconsax isax-2x color-hover isax-gift"></i>
			                        <span class="pl-10">
			                            {__d('template', 'su_dung_diem_tang')}
			                        </span>
			                    </span>

			                    <span class="d-flex align-items-center" >
			                    	<strong class="pr-5 color-hover">
			                            {if !empty($order_info.point.point_promotion)}
			                            	- {$order_info.point.point_promotion|number_format:0:".":","} {__d('template', 'diem')}
			                            {/if}
			                        </strong>

			                        <span >
			                            <i class="iconsax isax-arrow-down-1"></i>
			                        </span>
			                    </span>
			                </div>
			            </div>

			            <div id="point-panel" class="collapse" data-parent="#accordion-order">
			                <div class="p-15">
			                	{if empty($member_info)}
		                			<p class="mb-0">
		                				<a nh-order-login href="javascript:;" class="">
		                					{__d('template', 'dang_nhap_de_su_dung_chuc_nang')}
		                				</a>
		                			</p>
		                		{else}
			                    	<div class="d-flex justify-content-between align-items-center mb-5">
				                    	<small class="text-muted font-weight-bold">
				                    		{__d('template', 'so_diem_hien_co')}: 
				                    		{if !empty($member_info.point_promotion)}
				                    			{$member_info.point_promotion|number_format:0:".":","}
				                    		{else}
				                    			0
				                    		{/if}
				                    		{__d('template', 'diem')}
				                    	</small>

				                    	{if !empty($member_info.expiration_time)}
					                    	<small class="text-muted color-hover font-weight-bold">
					                    		{__d('template', 'han_dung')}: {$this->Utilities->convertIntgerToDateString($member_info.expiration_time)}
					                    	</small>
				                    	{/if}
				                    </div>
				                    <div class="input-group mb-10 ">
					                    <input nh-point-money="{$point_to_money}" nh-point-max="{$point_promotion_max}" id="point-promotion" value="{if !empty($order_info.point.point_promotion)}{$order_info.point.point_promotion|number_format:0:".":","}{/if}" type="text" class="bg-white border form-control rounded input-hover pr-6 number-input" placeholder="" autocomplete="off">
					                    <div class="input-group-append">
											<span class="input-group-text input-group-main">
												<span class="number-input point-to-money">
													{if !empty($config_point.point_to_money) && !empty($order_info.point.point_promotion)}
														{math assign = total_point_promotion equation = 'x*y' x = $config_point.point_to_money y = $order_info.point.point_promotion} 
														{$total_point_promotion|number_format:0:".":","}
													{else}
														0
													{/if}
												</span>
												<small>{CURRENCY_UNIT_DEFAULT}</small>
											</span>
										</div>
				                    </div>

				                    <div class="row">
				                    	<div class="col-6">
				                    		<span nh-btn-action="apply-point-promotion" class="btn bg-main btn-1a color-white py-10 fs-16 fs-14 px-25 mb-15 w-100 rounded">
						                        {__d('template', 'ap_dung')}
						                    </span>
				                    	</div>
				                    	<div class="col-6">
				                    		<span nh-btn-action="apply-point-promotion-all" class="d-inline-block py-10 fs-16 fs-14 cursor-pointer btn-1b">
						                        {__d('template', 'mua_ngay_bang_diem')}
						                    </span>
				                    	</div>
				                    </div>

				                    {if !empty($order_info.point.point_promotion)}
				                    	<a href="javascript:;" nh-btn-action="delete-point-promotion" class="color-hover mt-5 d-inline-block">
					                        {__d('template', 'huy_ap_dung_diem')}
					                    </a>
				                    {/if}
			                    {/if}
			                </div>
			            </div>
			        </div>

			        <div class="card border rounded mb-10">
			            <div class="card-header">
			                <div class="btn collapsed d-flex justify-content-between align-items-center w-100" data-toggle="collapse" data-target="#point-wallet">
			                    <span class="d-flex align-items-center" >
			                    	<i class="iconsax isax-2x color-hover isax-wallet-check"></i>
			                        <span class="pl-10">
			                            {__d('template', 'su_dung_diem_vi')}
			                        </span>
			                    </span>

			                    <span class="d-flex align-items-center" >
			                    	<strong class="pr-5 color-hover">
			                            {if !empty($order_info.point.point)}
			                            	- {$order_info.point.point|number_format:0:".":","} {__d('template', 'diem')}
			                            {/if}
			                            
			                        </strong>
			                        <span >
			                            <i class="iconsax isax-arrow-down-1"></i>
			                        </span>
			                    </span>
			                </div>
			            </div>

			            <div id="point-wallet" class="collapse" data-parent="#accordion-order">
			                <div class="p-15">
			                	{if empty($member_info)}
		                			<p class="mb-0">
		                				<a nh-order-login href="javascript:;" class="">
		                					{__d('template', 'dang_nhap_de_su_dung_chuc_nang')}
		                				</a>
		                			</p>
		                		{else}
			                    	<div class="d-flex justify-content-between align-items-center mb-5">
				                    	<small class="text-muted font-weight-bold">
				                    		{__d('template', 'so_diem_hien_co')}: 
				                    		{if !empty($member_info.point)}
				                    			{$member_info.point|number_format:0:".":","}
				                    		{else}
				                    			0
				                    		{/if}
				                    		{__d('template', 'diem')}
				                    	</small>
				                    </div>
				                    <div class="input-group mb-10 ">
					                    <input nh-point-money="{$point_to_money}" nh-point-max="{$point_max}" id="wallet" value="{if !empty($order_info.point.point)}{$order_info.point.point|number_format:0:".":","}{/if}" type="text" class="bg-white border form-control rounded input-hover pr-6 number-input" placeholder="" autocomplete="off">
					                    <div class="input-group-append">
											<span class="input-group-text input-group-main">
												<span class="number-input point-to-money">
													{if !empty($config_point.point_to_money) && !empty($order_info.point.point)}
														{math assign = total_point equation = 'x*y' x = $config_point.point_to_money y = $order_info.point.point} 
														{$total_point|number_format:0:".":","}
													{else}
														0
													{/if}
												</span>
												<small>{CURRENCY_UNIT_DEFAULT}</small>
											</span>
										</div>
				                    </div>
				                    <div class="row">
				                    	<div class="col-6">
				                    		<span nh-btn-action="apply-wallet" class="btn bg-main btn-1a color-white py-10 fs-16 fs-14 px-25 w-100 rounded">
						                        {__d('template', 'ap_dung')}
						                    </span>
				                    	</div>
				                    	<div class="col-6">
				                    		<span nh-btn-action="apply-wallet-all" class="d-inline-block py-10 fs-16 fs-14 cursor-pointer btn-1b">
						                        {__d('template', 'mua_ngay_bang_diem')}
						                    </span>
				                    	</div>
				                    </div>
				                    
				                    {if !empty($order_info.point.point)}
				                    	<a href="javascript:;" nh-btn-action="delete-wallet" class="color-hover mt-5 d-inline-block">
					                        {__d('template', 'huy_ap_dung_diem')}
					                    </a>
				                    {/if}
		                		{/if}
			                </div>
			            </div>
			        </div>
		       	{/if}
		    </div>
		</div>

		{if !empty($show_shipping)}
			{$this->element('../Order/element_shipping_methods')}
        {/if}
        
		{$this->element('../Order/element_items')}
		
		<div>						    
			<span nh-btn-action="create-order" class="edu-btn w-100 text-center">
                Đến bước thanh toán
            </span>
            {*<a title="{__d('template', 'quay_lai_gio_hang')}" class="order-back fs-14 d-flex align-items-center color-main mt-15" href="/order/cart-info">
    			<i class="iconsax isax-arrow-left mr-5"></i>
    			{__d('template', 'quay_lai_gio_hang')}
    		</a>*}
		</div>
	</div>
</div>


