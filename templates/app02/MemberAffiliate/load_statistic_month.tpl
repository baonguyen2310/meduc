<div class="row">
	<div class="col-12 col-lg-3">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-d-cube-scan5 color-blue-light"></i>
			<div class="mt-5">
				{__d('template', 'tong_don')}
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

	<div class="col-12 col-lg-3">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-d-rotate5 color-hover"></i>
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

	<div class="col-12 col-lg-3">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-coin-15 color-blue"></i>
			<div class="mt-5">
				{__d('template', 'hoa_hong')}
			</div>
			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_profit_point)}
					{$statistical.month_profit_point|number_format:0:".":","}
				{else}
					0
				{/if}

				<span class="fs-14">
					{__d('template', 'diem')}
				</span>
			</div>
		</div>
	</div>

	<div class="col-12 col-lg-3">
		<div class="bg-light p-10 border-radius-15">
			<i class="fs-48 iconsax isax-card-receive5 color-teal"></i>
			<div class="mt-5">
				{__d('template', 'tam_tinh')}
			</div>
			<div class="fs-26 font-weight-bold line-height-62">
				{if !empty($statistical.month_profit_money)}
					{$statistical.month_profit_money|number_format:0:".":","}
				{else}
					0
				{/if}

				<span class="fs-14">
					vnd
				</span>
			</div>
		</div>
	</div>
</div>