{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<script src="{URL_TEMPLATE}assets/lib/chartjs/chart.js"></script>
<div class="container mb-60">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>

		<div class="col-12 col-md-9 col-lg-9">
			<div class="row mb-10">
				<div class="col-12 col-lg-6">
					<div class="rounded bg-white p-20">
						<div class="fs-18 font-weight-bold mb-15 color-teal">
							{__d('template', 'don_hang')}
						</div>

						<div class="row">
							<div class="col-12 col-lg-6">
								<div class="bg-light p-10 border-radius-15">
									<i class="fs-48 iconsax isax-dcube5 color-teal"></i>
									<div class="mt-5">
										{__d('template', 'don_hang_hoan_thanh')}
									</div>

									<div class="fs-22 font-weight-bold line-height-62">
										{if !empty($statistical.all_total_order_success)}
											{$statistical.all_total_order_success|number_format:0:".":","} 
										{else}
											0
										{/if}
										<span class="fs-14">vnd</span>
									</div>
								</div>
							</div>

							<div class="col-12 col-lg-6">
								<div class="bg-light p-10 border-radius-15">
									<i class="fs-48 iconsax isax-clipboard-close5 color-blue-black"></i>
									<div class="mt-5">
										{__d('template', 'don_hang_that_bai')}
									</div>
									<div class="fs-22 font-weight-bold line-height-62">
										{if !empty($statistical.all_total_order_failed)}
											{$statistical.all_total_order_failed|number_format:0:".":","} 
										{else}
											0
										{/if}
										<span class="fs-14">vnd</span>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				<div class="col-12 col-lg-6">
					<div class="rounded bg-white p-20">
						<div class="fs-18 font-weight-bold mb-15 color-teal">
							{__d('template', 'thu_hang')}
						</div>
						
						<div class="row">
							<div class="col-12 col-lg-6">
								<div class="bg-light p-10 border-radius-15 h-100">

									{assign var = rank_info value = []}
									{if !empty($statistical.rank)}
										{$rank_info = $statistical.rank}
									{/if}
									
									{assign var = image_rank value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
									{if !empty($rank_info.image)}
										{assign var = image_rank value = "{CDN_URL}{$rank_info.image}"}
									{/if}

									<img src="{$image_rank}" alt="{__d('template', 'thu_hang')}" class="img-fluid image-48x48">

					                <div class="mt-5">
										{__d('template', 'hien_tai_cua_ban')}:
										{if !empty($rank_info.name)}
											{$rank_info.name}
										{/if}
					                </div>

									<div class="fs-22 font-weight-bold line-height-62">
										{if !empty($rank_info.profit)}
											{$rank_info.profit}%
										{/if}
									</div>
								</div>
							</div>

							<div class="col-12 col-lg-6">
								<div class="bg-light p-10 border-radius-15">
									<img src="{URL_TEMPLATE}assets/img/icon/dollar-square.svg" alt="{__d('template', 'tong_hoa_hong_dat')}" class="img-fluid">

									<div class="mt-5">
										{__d('template', 'tong_hoa_hong_dat')}
					                </div>

									<div class="fs-22 font-weight-bold line-height-62">
										{if !empty($statistical.all_profit_point)}
											{$statistical.all_profit_point|number_format:0:".":","}
										{else}
											0
										{/if}

										<span class="fs-14">
											{__d('template', 'diem')}
										</span>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="rounded bg-white p-20 mb-10">
				<div class="d-flex justify-content-between">
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
			
			<div class="rounded bg-white p-20">
				<div class="d-flex justify-content-between">
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
			</div>
		</div>
	</div>	
</div>