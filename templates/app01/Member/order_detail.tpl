{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<div class="container mb-60">
	<div class="row ">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>
		<div class="col-12 col-md-9 col-lg-9">
			<div class="rounded bg-white shadow-box7 p-15 mb-10 h-100">
				<div class="title-section-2 color-black font-weight-bold fs-16 mb-30 text-uppercase pb-10 border-bottom">
					<span>{__d('template', 'don_hang')} {if !empty($order.code)}- {$order.code}{/if}</span>
				</div>
				<h5 class="color-main mb-10">
					<b>
						{__d('template', 'thong_tin_ca_nhan')}
					</b>
				</h5>

				<div class="row">
					<div class="col-12 col-sm-6">
						{if !empty($order.contact.full_name)}
							<p class="color-black mb-5">
								<b>{__d('template', 'ho_va_ten')}:</b> {$order.contact.full_name}
							</p>
						{/if}

						{if !empty($order.contact.phone)}
							<p class="color-black mb-5">
								<b>{__d('template', 'so_dien_thoai')}:</b> {$order.contact.phone}
							</p>
						{/if}

						{if !empty($order.contact.email)}
							<p class="color-black mb-5">
								<b>{__d('template', 'email')}:</b> {$order.contact.email}
							</p>
						{/if}

						{if !empty($order.contact.full_address)}
							<p class="color-black mb-5">
								<b>{__d('template', 'dia_chi')}:</b> {$order.contact.full_address}
							</p>
						{/if}
					</div>	
					<div class="col-12 col-sm-6">
						{if !empty($order.status)}
							<p class="color-black mb-5">
							    <b>{__d('template', 'trang_thai')}: </b>
								{assign var = list_status_order value = $this->Order->getListStatusOrder()}
								<span>{$list_status_order[$order.status]}</span>
							</p>
						{/if}

						{if !empty($order.note)}
							<p class="color-black mb-5">
							    <b>{__d('template', 'ghi_chu')}: </b>{$order.note}
						    </p>
						{/if}
					</div>		
				</div>
				<div class="title-section-2 mt-30 color-black font-weight-bold fs-16 mb-30 text-uppercase pb-10 border-bottom">
					<span>{__d('template', 'thong_tin_san_pham')}</span>
				</div>
				<table class="table responsive-table mb-0">
					<thead>
				        <tr>
				            <th>{__d('template', 'san_pham')}</th>
				            <th>{__d('template', 'gia')}</th>
				            <th>{__d('template', 'so_luong')}</th>
				            <th class="text-right">{__d('template', 'tien')}</th>
				        </tr>
				    </thead>
					<tbody>
						{if !empty($order.items)}
							{foreach from = $order.items item = item}
								<tr class="cart_item">
						            <th scope="row">
						            	{if !empty($item['images'][0])}
							                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($item['images'][0], 50)}"}
							            {else}
							                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
							            {/if}
						                <a href="{$this->Utilities->checkInternalUrl($item.url)}">
						                	<img class="img-fluid mr-10" src="{$url_img}" alt="{if !empty($item.name_extend)}{$item.name_extend}{/if}" />

						                	{if !empty($item.name_extend)}
						                		{$item.name_extend}
						                	{/if}
						                </a>
						            </th>

						            <td data-title="{__d('template', 'gia')}">
						            	<span class="fs-16">
						            		{if !empty($item.price)}
								                <span>
								                	{$item.price|number_format:0:".":","}
								                </span>
							                {/if}
						            		<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
						            	</span>
						            </td>

						            <td data-title="{__d('template', 'so_luong')}">
						            	{if !empty($item.quantity)}
							                <span>
							                	{$item.quantity|number_format:0:".":","}
							                </span>
						                {/if}
						            </td>

						            <td data-title="{__d('template', 'tien')}" class="text-right">
						            	<span class="fs-16">
						            		{if !empty($item.total_item)}
								                <span>
								                	{$item.total_item|number_format:0:".":","}
								                </span>
							                {/if}
											<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
						                </span>
						            </td>
						        </tr>
							{/foreach}
						{/if}
					</tbody>
					<tfoot>
						{if !empty($order.shipping_fee_customer)}
							<tr>
								<td colspan="3">
									<strong class="fs-14">
										{__d('template', 'phi_van_chuyen')}
									</strong>
								</td>
								<td class="text-right">
									<span class="fs-16">
					            		+ {$order.shipping_fee_customer|number_format:0:".":","}
						            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
					            	</span>
								</td>
							</tr>
						{/if}
						{if !empty($order.total_coupon)}
							<tr>
								<td colspan="3">
									<strong class="fs-14">
										{__d('template', 'phieu_giam_gia')}
									</strong>
								</td>
								<td class="text-right">
									<span class="fs-16">
					            		- {$order.total_coupon|number_format:0:".":","}
						            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
					            	</span>
								</td>
							</tr>
						{/if}
						
						{if !empty($order.total_affiliate)}
							<tr>
								<td colspan="3">
									<strong class="fs-14">
										{__d('template', 'ma_gioi_thieu')}
									</strong>
								</td>
								<td class="text-right">
									<span class="fs-16">
					            		- {$order.total_affiliate|number_format:0:".":","}
						            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
					            	</span>
								</td>
							</tr>
						{/if}

						{if !empty($order.total_vat)}
							<tr>
								<td colspan="3">
									<strong class="fs-14">
										VAT
									</strong>
								</td>
								<td class="text-right">
									<span class="fs-16">
					            		+ {$order.total_vat|number_format:0:".":","}
						            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
					            	</span>
								</td>
							</tr>
						{/if}
						<tr class="color-hover fs-14 bg-gray">
							<td colspan="3"><b>{__d('template', 'tong_tien')}</b></td>
							<td class="text-right">
								<b>
									<span class="fs-16">
					            		{if !empty($order.total)}
					            			{$order.total|number_format:0:".":","}
					            		{/if}
						            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
					            	</span>
								</b>
							</td>
						</tr>
						{if !empty($order.point_promotion_paid) || !empty($order.point_paid)}
							{if !empty($order.point_promotion_paid)}
								<tr>
									<td colspan="3">
										<strong class="fs-14">
											{__d('template', 'thanh_toan_bang_diem_khuyen_mai')}
										</strong>
									</td>
									<td class="text-right">
										<span class="fs-16">
						            		- {$order.point_promotion_paid|number_format:0:".":","}
							            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
						            	</span>
									</td>
								</tr>
							{/if}
							{if !empty($order.point_paid)}
								<tr>
									<td colspan="3">
										<strong class="fs-14">
											{__d('template', 'thanh_toan_bang_diem_vi')}
										</strong>
									</td>
									<td class="text-right">
										<span class="fs-16">
						            		- {$order.point_paid|number_format:0:".":","}
							            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
						            	</span>
									</td>
								</tr>
							{/if}
							{if !empty($order.debt)}
								<tr>
									<td colspan="3">
										<strong class="fs-14 color-hover">
											{__d('template', 'con_phai_thanh_toan')}
										</strong>
									</td>
									<td class="text-right">
										<span class="fs-16 color-hover">
						            		{$order.debt|number_format:0:".":","}
							            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
						            	</span>
									</td>
								</tr>
							{/if}

							{if !empty($order.paid)}
								<tr>
									<td colspan="3">
										<strong class="fs-14 text-success">
											{__d('template', 'da_thanh_toan')}
										</strong>
									</td>
									<td class="text-right">
										<span class="fs-16 text-success">
						            		{$order.paid|number_format:0:".":","}
							            	<span class="currency-symbol">{CURRENCY_UNIT_DEFAULT}</span>
						            	</span>
									</td>
								</tr>
							{/if}
						{/if}
					</tfoot>
				</table>
			</div>
		</div>
	</div>	
</div>