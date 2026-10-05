{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<div class="container">
	<div class="row justify-content-center">
		<div class="col-xl-6 col-lg-8 col-md-10 col-sm-12 col-12">
			<div class="mb-60 rounded bg-white shadow-box7 p-30">
			    {$this->element('../Member/element_register_form')}	
			</div>
		</div>
	</div>	
</div>