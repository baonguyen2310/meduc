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
			<div class="">
				<h3 class="fs-24 mb-20">
					<b>
						{__d('template', 'ban_hang_cung_chung_toi')}
					</b>
				</h3>
				<div class="row">
					<div class="col-12 col-lg-6 mb-10">
						<div class="bg-gold color-white h-100 p-15 border-radius-10 d-flex align-items-start flex-column box-shadow">
							<div class="fs-18 font-weight-bold line-height-section-1 mb-10">
								{__d('template', 'gia_tang_thu_nhap_ca_nhan')}
							</div>

							<div class="separate-divide mb-10"></div>
							<div class="mb-30">
								{__d('template', 'gioi_thieu_khach_hang_mua_san_pham_su_dung_ma_gioi_thieu_ban_duoc_cung_cap_ban_se_nhan_duoc_%_gia_tri_don_hang')}
							</div>

							<a class="btn bg-hightlight color-white fs-14 py-5 px-20 rounded text-uppercase mt-auto" href="/member/affiliate/active">
								{__d('template', 'dang_ky')}
							</a>
						</div>
					</div>
					<div class="col-12 col-lg-6 mb-10">
						<div class="bg-hightlight color-white h-100 p-15 border-radius-10 d-flex align-items-start flex-column box-shadow">
							<div class="fs-18 font-weight-bold line-height-section-1 mb-10">
								{__d('template', 'thanh_toan_theo_dinh_ky')}
							</div>

							<div class="separate-divide mb-10"></div>
							<div class="mb-30">
								Ngày mùng 5 hàng tháng chúng tôi sẽ tự động thanh toán % hoa hồng đến tài khoản bạn cung cấp.
							</div>

							<a class="btn bg-dark btn-1b color-white fs-14 py-5 px-20 rounded text-uppercase mt-auto" href="/member/affiliate/active">
								{__d('template', 'dang_ky')}
							</a> 
						</div>
					</div>
				</div>
			</div>
			{*<div class="mt-10">
				{if !empty($affiliate_ranks)}
					{foreach from = $affiliate_ranks item = item}
						<div class="row space-10 mb-15">
							<div class="col-12 col-md-6 col-lg-4">
								<div class="position-relative rti-75 rounded bg-bronze">
									{assign var = image_rank value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
									{if !empty($item.image) && !empty($item.source) && $item.source == 'template'}
										{assign var = image_rank value = "{$item.image}"}
									{/if}

									{if !empty($item.image) && !empty($item.source) && $item.source == 'cdn'}
										{assign var = image_rank value = "{CDN_URL}{$item.image}"}
									{/if}

									{$this->LazyLoad->renderImage([
					                    'src' => "{$image_rank}", 
					                    'alt' => "{__d('template', 'thu_hang_dong')}", 
					                    'class' => 'img-fluid rti-abs-cover m-auto rti-abs-contain h-auto w-auto'
					                ])}
				                </div>
							</div>

							<div class="col-12 col-md-6 col-lg-8">
								<div class="rounded bg-white p-10 h-100">
									<div class="d-flex justify-content-between fs-18 color-hover font-weight-bold mb-5">
										<div>
											{__d('template', 'thu_hang')}: 
											{if !empty($item.name)}
												{$item.name}
											{/if}
										</div>

										<div>
											{__d('template', 'hoa_hong')}: 
											{if !empty($item.profit)}
												{$item.profit}%
											{/if}
										</div>
									</div>

									<div>
										{if !empty($item.description)}
											{$item.description}
										{/if}
									</div>
								</div>
							</div>
						</div>
					{/foreach}
				{/if}
			</div>*}
		</div>
	</div>	
</div>