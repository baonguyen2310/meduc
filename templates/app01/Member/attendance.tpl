<div class="container mb-60 mt-70">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>
		<div class="col-12 col-md-9 col-lg-9">
			<div class="member-point rounded bg-white px-20 py-15 mb-15">
				<div class="d-flex align-items-center justify-content-between">
					<div class="number-point">
						<p class="mb-5">
							{__d('template', 'ban_co')}
						    <span class="fs-22 font-weight-bold color-orange">
						    	{if !empty($customer_point.point)}
						    		{$customer_point.point}
						    	{else}
						    		0
						    	{/if}
						    </span>
						    {__d('template', 'diem')}
						</p>
						<p class="mb-5">
							{if !empty($config_point.point_to_money)}
								{__d('template', 'moi_diem_tuong_ung_bang')}
								<span class="point_to_money font-weight-bold">
									{$config_point.point_to_money}
								</span>
								{__d('template', 'dong_vnd')}
							{/if}
						</p>
					</div>

					<div class="promotion-points text-right">
						<p class="mb-5">
							<span class="fs-19 font-weight-bold number_point_promition color-black">
								{if !empty($customer_point.point_promotion)}
									{$customer_point.point_promotion}
								{else}
						    		0
								{/if}
							</span>
							{__d('template', 'diem_khuyen_mai')}
						</p>
						<p class="mb-5">
							{__d('template', 'thoi_han_su_dung_diem_den_ngay')}
							<span class="point_to_money text-danger font-weight-bold">
								{if !empty($customer_point.expiration_time)}
									: {$this->Utilities->convertIntgerToDateString($customer_point.expiration_time)}
								{/if}
							</span>
						</p>
					</div>
				</div>
			</div>

			{if !empty($attendance)}
				<div class="member-attendance rounded bg-white px-20 py-15 mb-15">
					<h4 class="color-black font-weight-bold">
						{__d('template', 'diem_danh')}
					</h4>
					<div class="list-date" nh-attendance>
						<ul class="list-unstyled d-flex align-items-center justify-content-start mx--10 flex-wrap">
							{foreach from = $attendance key = key item = item}
								<li class="px-10 flex-3 flex-md-5 flex-lg-7 mb-20">
									<div {if $item.check}checked="checked"{else}attendance-tick="true"{/if} class="d-flex align-items-center justify-content-center flex-column bg-gray radius-10 px-5 py-15 color-gray" data-day="{$key + 1}" data-date="{if !empty($item.date)}{$item.date}{/if}" data-point="{if !empty($item.point)}{$item.point}{/if}">
										<span class="point fs-29 font-weight-bold">
											{if !empty($item.point)}
												+{$item.point}
											{/if}
										</span>
										<span class="date">
											{if !$item.is_today && !empty($item.date)}
												{date("d/m", $item.date)}
											{else}
												{__d('template', 'hom_nay')}
											{/if}
										</span>
									</div>
								</li>			
							{/foreach}
						</ul>
					</div>
				</div>
			{/if}
		</div>
	</div>	
</div>

{$this->element('../Member/modal_attendance_sucess')}
{$this->element('../Member/modal_attendance_error')}