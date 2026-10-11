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
		    {assign var = rank_info value = []}
			{if !empty($statistical.rank)}
				{$rank_info = $statistical.rank}
			{/if}
			
		    <div class="fs-18 font-weight-bold mb-15 color-purple">
				Link giới thiệu (Hoa hồng: {if !empty($rank_info.profit)}{$rank_info.profit}%){/if}
			</div>
			
			<div class="row mb-30">
				<div class="col-12 col-lg-12">
					<div class="bg-light p-10 border-radius-15">
						<div id="copyLinkAffiliate" class="fs-18 font-weight-bold line-height-62">
						    https://virtualassistant101.vn/?a={$member_info.code}
						</div>
						<button class="btn btn-primary py-2 px-20 fs-15" onclick="copyLink()">Copy Link</button>
					</div>
					{literal}
						<script>
					        const copyText = document.querySelector("#copyLinkAffiliate").innerText;
						    function copyLink() {
						        navigator.clipboard.writeText(copyText).then(function() {
                                  alert("Đã copy link thành công");
                                }, function(err) {
                                  console.error('Async: Could not copy text: ', err);
                                });
                            }
						</script>
					{/literal}
				</div>
			</div>
			
			<div class="mb-30">
				<div class="d-flex align-items-center justify-content-between">
					<div class="fs-18 font-weight-bold mb-15 color-hover">
						{__d('template', 'du_lieu_thang')}
					</div>

					{if !empty($list_month)}
						<div class="dropdown">
							{assign var = this_month value = $smarty.now|date_format:"%m"}
							<a class="btn btn-secondary dropdown-toggle" href="javascript:;" role="button" data-toggle="dropdown">
								{if !empty($list_month[$this_month])}
									{$list_month[$this_month]}
								{else}
									{__d('template', 'thang_1')}
								{/if}
							</a>

							<div class="dropdown-menu dropdown-menu-right">
								{foreach from = $list_month key = key item = month}
									<a filter-month="{$key}" class="dropdown-item" href="javascript:;">
										{$month}
									</a>
								{/foreach}
							</div>
						</div>
					{/if}
				</div>

				<div id="wrap-dashboard-statistic-element">
					{$this->element('../MemberAffiliate/load_statistic_month', ['statistical' => $statistical])}
				</div>
			</div>
		    
			<div class="fs-18 font-weight-bold mb-15 color-teal">
				{__d('template', 'tong_quan')}
			</div>
			
			<div class="row mb-30">
			    <div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-card-receive5 color-teal"></i>

						<div class="mt-5">
							{__d('template', 'tong_hoa_hong_dat')}
		                </div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($statistical.nam_money_order_success)}
								{$statistical.nam_money_order_success|number_format:0:".":","}
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
						<i class="fs-48 iconsax isax-d-cube-scan5 color-blue-light"></i>
						<div class="mt-5">
							Tổng đơn hàng
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($statistical.nam_total_order)}
								{$statistical.nam_total_order|number_format:0:".":","} 
							{else}
								0
							{/if}
							<span class="fs-14">đơn</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-d-cube-scan5 color-blue-light"></i>
						<div class="mt-5">
							Đơn hàng mới
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($statistical.nam_total_order_new)}
								{$statistical.nam_total_order_new|number_format:0:".":","} 
							{else}
								0
							{/if}
							<span class="fs-14">đơn</span>
						</div>
					</div>
				</div>
				
				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-dcube5 color-teal"></i>
						<div class="mt-5">
							Đơn hàng thành công
						</div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($statistical.nam_total_order_success)}
								{$statistical.nam_total_order_success|number_format:0:".":","} 
							{else}
								0
							{/if}
							<span class="fs-14">đơn</span>
						</div>
					</div>
				</div>

				<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15">
						<i class="fs-48 iconsax isax-clipboard-close5 color-blue-black"></i>
						<div class="mt-5">
							{__d('template', 'don_hang_that_bai')}
						</div>
						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($statistical.nam_total_order_cancel)}
								{$statistical.nam_total_order_cancel|number_format:0:".":","} 
							{else}
								0
							{/if}
							<span class="fs-14">đơn</span>
						</div>
					</div>
				</div>
				
				{*<div class="col-12 col-lg-3 mb-20">
					<div class="bg-light p-10 border-radius-15 h-100">
						{assign var = image_rank value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
						{if !empty($rank_info.image)}
							{assign var = image_rank value = "{CDN_URL}{$rank_info.image}"}
						{/if}

						<i class="fs-48 iconsax isax-percentage-square5 color-blue-black"></i>

		                <div class="mt-5">
							% hoa hồng/đơn
		                </div>

						<div class="fs-22 font-weight-bold line-height-62">
							{if !empty($rank_info.profit)}
								{$rank_info.profit}%
							{/if}
						</div>
					</div>
				</div>*}
			</div>
			
			{*<div class="mb-30">
				<div class="d-flex align-items-center justify-content-between">
					<div class="fs-18 font-weight-bold mb-15 color-blue">
						{__d('template', 'bieu_do_thang')}
					</div>

					{if !empty($list_month)}
						<div id="dropdown-month-chart-profit" class="dropdown">
							{assign var = this_month value = $smarty.now|date_format:"%m"}
							<a class="btn btn-secondary dropdown-toggle" href="javascript:;" role="button" data-toggle="dropdown">
								{if !empty($list_month[$this_month])}
									{$list_month[$this_month]}
								{else}
									{__d('template', 'thang_1')}
								{/if}
							</a>

							<div class="dropdown-menu dropdown-menu-right">
								{foreach from = $list_month key = key item = month}
									<a chart-month="{$key}" class="dropdown-item" href="javascript:;">
										{$month}
									</a>
								{/foreach}
							</div>
						</div>
					{/if}
				</div>

				<div id="wrap-load-chart-profit">
					{$this->element('../MemberAffiliate/chart_profit', ['chart_data' => $chart_data])}
				</div>
			</div>*}
		</div>
	</div>	
</div>