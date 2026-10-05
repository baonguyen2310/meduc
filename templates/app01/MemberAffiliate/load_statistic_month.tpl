<div class="row">
    <div class="col-12 col-lg-3 mb-20">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-card-receive5 color-teal"></i>
			<div class="mt-5">
				Tổng hoa hồng đạt
			</div>
			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_total_order_success)}
					{$statistical.month_total_order_success|number_format:0:".":","}
				{else}
					0
				{/if}

				<span class="fs-14">
					vnd
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

			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_number_order)}
					{$statistical.month_number_order|number_format:0:".":","} 
				{else}
					0
				{/if}

				<span class="fs-14">
					{__d('template', 'don')}
				</span>
			</div>
		</div>
	</div>
	
	<div class="col-12 col-lg-3 mb-20">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-d-cube-scan5 color-blue-light"></i>
			<div class="mt-5">
				Đơn hàng mới
			</div>

			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_number_order_new)}
					{$statistical.month_number_order_new|number_format:0:".":","} 
				{else}
					0
				{/if}

				<span class="fs-14">
					{__d('template', 'don')}
				</span>
			</div>
		</div>
	</div>

	<div class="col-12 col-lg-3 mb-20">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-dcube5 color-teal"></i>
			<div class="mt-5">
				Đơn hàng thành công
			</div>
			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_number_order_success)}
					{$statistical.month_number_order_success|number_format:0:".":","}
				{else}
					0
				{/if}

				<span class="fs-14">
					{__d('template', 'don')}
				</span>
			</div>
		</div>
	</div>

	<div class="col-12 col-lg-3 mb-20">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-clipboard-close5 color-blue-black"></i>
			<div class="mt-5">
				{__d('template', 'don_hang_that_bai')}
			</div>
			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_number_order_failed)}
					{$statistical.month_number_order_failed|number_format:0:".":","}
				{else}
					0
				{/if}
				<span class="fs-14">
					{__d('template', 'don')}
				</span>
			</div>
		</div>
	</div>
</div>