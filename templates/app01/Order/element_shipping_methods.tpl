<div nh-wrap="shipping-method" class="card border rounded mb-10">
    <div class="card-header">
        <div class="btn d-flex justify-content-between align-items-center w-100">
            <span class="d-flex align-items-center" >
            	<i class="iconsax isax-2x isax-truck-fast color-hover"></i>
                <span class="pl-10">
                    {__d('template', 'phuong_thuc_van_chuyen')}
                </span>
            </span>
        </div>
    </div>
    {if !empty($shipping_methods)}
		{foreach from = $shipping_methods key = method_id item = method}
			{assign var = selected_method value = false}
			{if !empty($order_info.shipping_method_id) && $order_info.shipping_method_id == $method_id}
				{assign var = selected_method value = true}
			{/if}

			<div class="swich-change">
				<input class="form-check-input" name="shipping_method_id" value="{$method_id}" {if $selected_method}checked="true"{/if} nh-shipping-method="{$method_id}" id="shipping-method-{$method_id}" type="radio">
				<label class="d-flex align-items-center border rounded p-10 mx-15 mt-5 mb-15" for="shipping-method-{$method_id}">
					<div>
						{if !empty($method.name)}
							<strong>
								{$method.name}
							</strong>
						{/if}
						
						<div class="font-weight-normal">
							{__d('template', 'phi_van_chuyen')}: 

							{if !empty($method.fee)}
								{$method.fee|number_format:0:".":","}
								<span class="currency-symbol fs-12">
			                        {CURRENCY_UNIT_DEFAULT}
			                    </span>
							{else}
								0 {CURRENCY_UNIT_DEFAULT}
							{/if}
						</div>

						{if !empty($method.description)}
							<div class="font-weight-normal">
								{$method.description}
							</div>
						{/if}
					</div>

					<div class="ml-auto checked">
						<i class="iconsax isax-2x isax-tick-circle5"></i>
	                </div>
				</label>
			</div>
	    {/foreach}
	{else}
		<i class="p-15 fs-12">
            {__d('template', 'khong_co_phuong_thuc_nao_duoc_ap_dung')}
        </i>
    {/if}
</div>