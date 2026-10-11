{assign var = sex value = [
	'male' => __d('template', 'nam'),
	'female' => __d('template', 'nu'),
	'other' => __d('template', 'khac')
]}

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
			<div class="rounded bg-white px-30 pt-55 h-100">
				<h4 class="color-black line-height-25">
					<strong>{__d('template', 'ho_so_cua_toi')}</strong>
					<span class="d-block">{__d('template', 'quan_ly_thong_tin_ho_so_de_bao_mat_tai_khoan')}</span>
				</h4>
				<ul class="member-categories-section list-unstyled mb-0">
					{if !empty($member.full_name)}
						<li class="d-flex justify-content-between py-5 mb-10">
							<span class="color-gray">{__d('template', 'ten')}</span>
							<span>
							    <strong>{$member.full_name}</strong>
							</span>
							
						</li>
					{/if}
					
					{if !empty($member.sex)}
						<li class="d-flex justify-content-between py-5 mb-10">
							<span class="color-gray">{__d('template', 'gioi_tinh')}</span>
							<span>
							    <strong>{$sex[$member.sex]}</strong>
							</span> 
						</li>
					{/if}
					
					{if !empty($member.birthday)}
						<li class="d-flex justify-content-between py-5 mb-10">
							<span class="color-gray">{__d('template', 'ngay_sinh')}</span>
							<span>
							    <strong>{$member.birthday}</strong>
							</span> 
						</li>
					{/if}
					
					{if !empty($member.email)}
						<li class="d-flex justify-content-between py-5 mb-10">
							<span class="color-gray">{__d('template', 'email')}</span>
							<span>
							    <strong>{$member.email}</strong>
							</span> 
						</li>
					{/if}
					{if !empty($member.phone)}
						<li class="d-flex justify-content-between py-5 mb-10">
							<span class="color-gray">{__d('template', 'so_dien_thoai')}</span>
							<span>
							    <strong>{$member.phone}</strong>
							</span> 
						</li>
					{/if}

					{if !empty($member.code)}
						<li class="d-flex justify-content-between py-5 mb-10">
							<span class="color-gray">{__d('template', 'ma_khach_hang')}</span>
							<span>
							    <strong>{$member.code}</strong>
							</span> 
						</li>
					{/if}
				</ul>
				<div class="text-right mb-30">
            		<a href="/member/change-password" class="btn bg-main btn-1a color-white fs-14 px-25 rounded mt-10">
            			{__d('template', 'thay_doi_mat_khau')}
            		</a>
            		<a href="/member/profile" class="btn bg-main btn-1a color-white fs-14 px-25 rounded mt-10">
            			{__d('template', 'sua_thong_tin')}
            		</a>
        		</div>
			</div>
		</div>
	</div>	
</div>