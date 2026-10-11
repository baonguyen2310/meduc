{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<div class="container">
	<div class="row justify-content-center">
		<div class="col-md-6 col-12">
			<div class="mb-60 rounded bg-white shadow p-30">
			    {$this->element('../Member/element_register_form')}	
			</div>
		</div>
	</div>	
</div>