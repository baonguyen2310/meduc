{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {__d('template', 'quan_ly_don_hang')}]
	]
])}
 
<div class="container mb-60">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>
		<div class="col-12 col-md-9 col-lg-9">
			<div class="rounded bg-white p-15 mb-10 h-100">
				{$this->element('../Member/element_promotion')}
			</div>
		</div>
	</div>	
</div>