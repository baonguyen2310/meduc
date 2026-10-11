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
			<form nh-form="list-order" action="/member/affiliate/order" method="POST" autocomplete="off" class="h-100">
				<div class="rounded bg-white mb-10 p-15">
					<div class="d-flex justify-content-between form-inline">
						<div class="form-group">
							<label class="font-weight-normal mr-10">
								{__d('template', 'thoi_gian')}
							</label>
							<input nh-date data-date-end-date="0d" type="text" placeholder="{__d('template', 'tu_ngay')}" class="form-control form-control-sm input-hover mr-15" name="create_from" value="{if !empty($create_from)}{$create_from}{/if}">
							
							<input nh-date data-date-end-date="0d" type="text" placeholder="{__d('template', 'den_ngay')}" class="form-control form-control-sm input-hover" name="create_to" value="{if !empty($create_to)}{$create_to}{/if}" style="margin-left: -1px;">
						</div>
					
						<div class="d-flex">
							{$this->Form->select('group_status', $this->Order->getListStatusGroupOrder(), ['id' => 'group_status', 'empty' => "-- {__d('template', 'trang_thai')} --", 'class' => 'form-control form-control-sm selectpicker input-hover mr-10'])}
			                <button nh-btn-action="order-search" type="submit" class="btn btn-dark btn-sm d-flex align-items-center ml-5">
			                	<i class="iconsax isax-lg isax-search-normal-1"></i>
			                </button>
		                </div>
					</div>
				</div>
				
				<div class="rounded bg-white p-10">
					<div nh-form="table-order">
						{$this->element('../MemberAffiliate/list_affiliate_order_element')}					
					</div>
				</div>
			</form>
		</div>
	</div>	
</div>