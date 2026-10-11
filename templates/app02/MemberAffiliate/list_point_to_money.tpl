{assign var = plugins value = $this->Setting->getListPlugins()}

{if !empty($plugins.affiliate)}
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
				<form nh-form="list-order" action="/member/affiliate/list-point-tomoney" method="POST" autocomplete="off" class="h-100">
					<div class="rounded bg-white p-15 mb-10">
						<div class="d-flex justify-content-between align-items-stretch mb-15">
							<div class="fs-18 font-weight-bold">
								{__d("template", "lich_su_rut_tien")}
							</div>
							<div class="btn-add-member text-center">
			                    <a nh-affiliate="point-tomoney" href="javascript:;" class="btn bg-purple btn-1a color-white px-10 rounded">
			                    	<i class="iconsax isax-card-receive fs-16 mr-5"></i>
			                    	{__d('template', 'rut_tien')}
			                    </a>
			                </div>
						</div>
					
						<div nh-form="table-order" class="rounded bg-white mb-10">
						    {$this->element('../MemberAffiliate/list_point_to_money_element')}
						</div>
					</div>
				</form>
			</div>
		</div>	
	</div>
	{$this->element('../MemberAffiliate/point_tomoney_modal')}
{/if}
