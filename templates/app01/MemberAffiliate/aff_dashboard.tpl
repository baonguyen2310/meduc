{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<script src="{URL_TEMPLATE}assets/lib/chartjs/chart.js"></script>

{assign member_info value = $this->Member->getMemberInfo()}
<div class="container mb-60">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>

		<div class="col-12 col-md-9 col-lg-9">
			<div class="fs-18 font-weight-bold mb-15 color-teal">
				{__d('template', 'tong_quan')}
			</div>
			
			<div class="row mb-30">
			    <div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-money-recive color-teal"></i>

						<div class="mt-5">
							Tổng tiền hoa hồng
		                </div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($member.affiliate_amount)}
								{$member.affiliate_amount|number_format:0:".":","}
							{else}
								0
							{/if}

							<span class="fs-14">
								vnđ
							</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-money-time color-blue-light"></i>
						<div class="mt-5">
							Hoa hồng chưa thanh toán
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($member.affiliate_amount_unpaid)}
								{$member.affiliate_amount_unpaid|number_format:0:".":","}
							{else}
								0
							{/if}
							<span class="fs-14">
								vnđ
							</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-money-send color-teal"></i>
						<div class="mt-5">
							Hoa hồng đã thanh toán
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
						    {if !empty($member.affiliate_amount) && !empty($member.affiliate_amount_unpaid)}
                                {math 
                                    equation="a - b" 
                                    a=$member.affiliate_amount+0 
                                    b=$member.affiliate_amount_unpaid+0 
                                    assign=affiliate_amount_paid
                                }
                                {if isset($affiliate_amount_paid)}
                                    {$affiliate_amount_paid|number_format:0:".":","}
                                {else}
								    0
                                {/if}
                            {/if}
							<span class="fs-14">
								vnđ
							</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-percentage-circle color-blue-light"></i>
						<div class="mt-5">
							% Hoa hồng hiện tại
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($member.affiliate_percent)}
								{$member.affiliate_percent|number_format:1:".":","}
							{else}
								{$affiliate_percent_default|number_format:1:".":","}
							{/if}
							<span class="fs-14">
								%
							</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-menu-board color-blue-light"></i>
						<div class="mt-5">
							Số đơn Sách và TBYT
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($contacts)}
								{count($contacts)}
							{else}
								0
							{/if}
							<span class="fs-14">
							    đơn
							</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-menu-board color-blue-light"></i>
						<div class="mt-5">
							Số đơn Khóa học
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($orders)}
								{count($orders)}
							{else}
								0
							{/if}
							<span class="fs-14">
							    đơn
							</span>
						</div>
					</div>
				</div>
			</div>
			
			<div class="fs-18 font-weight-bold mb-15 color-teal">
				Danh sách đơn hàng Sách và Thiết bị y tế
			</div>
			
			<table class="table responsive-table mb-30 wrap-table">
        		<thead>
        			<tr>
        				<th class="text-center">Mã đơn hàng</th>
        				<th>Tổng tiền đơn hàng</th>
        				<th>% Hoa hồng</th>
        				<th>Hoa hồng</th>
        				<th>Trạng thái đơn hàng</th>
        				<th>Trạng thái chi trả</th>
        			</tr>
        		</thead>
        			<tbody>
        				{foreach from = $contacts item = item}
        					<tr>
        				        <td data-title="Mã đơn hàng">
        				        	{if !empty($item.value_decoded.cartId)}
        				        		<b>
        				        		    <a href="/dat-hang-thanh-cong?cartId={$item.value_decoded.cartId}" target="_blank">
        				        			    {$item.value_decoded.cartId}
        				        			</a>
        				        		</b>
        				        	{/if}
        				        	<br/>
        				        	{if !empty($item.created)}
        								<i class="fs-12">
        									{$this->Utilities->convertIntgerToDateTimeString($item.created)}
        								</i>
        							{/if}
        				        </td>
        
        				        <td data-title="Tổng tiền đơn hàng">
        				        	{if !empty($item.value_decoded.totalPrice)}
        								{$item.value_decoded.totalPrice|number_format:0:".":","} {CURRENCY_UNIT}
        							{/if}
        				        </td>
        
        				        <td data-title="% Hoa hồng">
        				        	{if !empty($item.value_decoded.affiliatePercent)}
        					        	<b>
        					        		{$item.value_decoded.affiliatePercent}%
        					        	</b>                                
                                    {/if}
        				        </td>
        				        
        				        <td data-title="Hoa hồng">
        				        	{if !empty($item.value_decoded.affiliateAmount)}
        								{$item.value_decoded.affiliateAmount|number_format:0:".":","} {CURRENCY_UNIT}
        							{/if}
        				        </td>
        				        
        				        <td data-title="Trạng thái đơn hàng">
        				        	{if !empty($item.value_decoded.orderStatus)}
                                        {if $item.value_decoded.orderStatus == "initial"}
                                            <span class="py-5 fs-13 fw-bold alert alert-danger">
                                                Khởi tạo
                                            </span>
                                        {/if}
                                        
                                        {if $item.value_decoded.orderStatus == "success"}
                                            <span class="py-5 fs-13 fw-bold alert alert-success">
                                                Thành công
                                            </span>
                                        {/if}
                                    {/if}
        				        </td>
        				        
        				        <td data-title="Trạng thái chi trả">
        				        	{if !empty($item.value_decoded.affiliatePaidStatus)}
                                        {if $item.value_decoded.affiliatePaidStatus == "unpaid"}
                                            <span class="py-5 fs-13 fw-bold alert alert-danger">
                                                Chưa trả
                                            </span>
                                        {/if}
                                        
                                        {if $item.value_decoded.affiliatePaidStatus == "paid"}
                                            <span class="py-5 fs-13 fw-bold alert alert-success">
                                                Đã trả
                                            </span>
                                        {/if}
                                    {/if}
        				        </td>
        				    </tr>
        				{/foreach}
        			</tbody>
        	</table>
        	
        	<div class="fs-18 font-weight-bold mb-15 color-teal">
				Danh sách đơn hàng Khóa học
			</div>
			
			<table class="table responsive-table mb-30 wrap-table">
        		<thead>
        			<tr>
        				<th class="text-center">Mã đơn hàng</th>
        				<th>Tổng tiền đơn hàng</th>
        				<th>% Hoa hồng</th>
        				<th>Hoa hồng</th>
        				<th>Trạng thái đơn hàng</th>
        				<th>Trạng thái chi trả</th>
        			</tr>
        		</thead>
        			<tbody>
        				{foreach from = $orders item = item}
        					<tr>
        				        <td data-title="Mã đơn hàng">
        				        	{if !empty($item.code)}
        				        		<b>
        				        			<a href="/order/success?code={$item.code}" target="_blank">
        				        			    {$item.code}
        				        			</a>
        				        		</b>
        				        	{/if}
        				        	<br/>
        				        	{if !empty($item.created)}
        								<i class="fs-12">
        									{$this->Utilities->convertIntgerToDateTimeString($item.created)}
        								</i>
        							{/if}
        				        </td>
        
        				        <td data-title="Tổng tiền đơn hàng">
        				        	{if !empty($item.total)}
        								{$item.total|number_format:0:".":","} {CURRENCY_UNIT}
        							{/if}
        				        </td>
        
        				        <td data-title="% Hoa hồng">
        				        	{if !empty($item.affiliatePercent)}
        					        	<b>
        					        		{$item.affiliatePercent}%
        					        	</b>                                
                                    {/if}
        				        </td>
        				        
        				        <td data-title="Hoa hồng">
        				        	{if !empty($item.affiliateAmount)}
        								{$item.affiliateAmount|number_format:0:".":","} {CURRENCY_UNIT}
        							{/if}
        				        </td>
        				        
        				        <td data-title="Trạng thái đơn hàng">
        				        	{if !empty($item.orderStatus)}
                                        {if $item.orderStatus == "initial"}
                                            <span class="py-5 fs-13 fw-bold alert alert-danger">
                                                Khởi tạo
                                            </span>
                                        {/if}
                                        
                                        {if $item.orderStatus == "success"}
                                            <span class="py-5 fs-13 fw-bold alert alert-success">
                                                Thành công
                                            </span>
                                        {/if}
                                    {/if}
        				        </td>
        				        
        				        <td data-title="Trạng thái chi trả">
        				        	{if !empty($item.affiliatePaidStatus)}
                                        {if $item.affiliatePaidStatus == "unpaid"}
                                            <span class="py-5 fs-13 fw-bold alert alert-danger">
                                                Chưa trả
                                            </span>
                                        {/if}
                                        
                                        {if $item.affiliatePaidStatus == "paid"}
                                            <span class="py-5 fs-13 fw-bold alert alert-success">
                                                Đã trả
                                            </span>
                                        {/if}
                                    {/if}
        				        </td>
        				    </tr>
        				{/foreach}
        			</tbody>
        	</table>
			
		</div>
	</div>	
</div>