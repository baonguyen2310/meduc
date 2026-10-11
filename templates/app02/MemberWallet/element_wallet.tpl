{if !empty($history)}
	{assign var = list_status value = [
		0 => {__d("template", "huy")},
		1 => {__d("template", "thanh_cong")},
		2 => {__d("template", "cho_duyet")}
	]}
	{foreach from = $history key = key item = item}
		<div class="border-bottom py-5 {if $item@last}border-bottom-0{/if}">
			<div class="row align-items-center">
				<div class="col-sm-6 col-12">
					{if !empty($item.description)}
    					{$item.description}
					{/if}
					{if isset($item.point_type) && $item.point_type == 0}
						<strong>
							(
							{__d('template', 'diem_thuong')}
							{if isset($item.status) && $item.status == 0}
							 - $list_status[$item.status]
							{/if}
							{if isset($item.status) && $item.status == 2}
							 - $list_status[$item.status]
							{/if}
							)
						</strong>
					{/if}
					{if !empty($item.action_type) && $item.action_type == 'give_point'}
						<span data-toggle="collapse" href="#collapseGivePoint" role="button" aria-expanded="false" aria-controls="collapseGivePoint" class="font-weight-bold">
							(
							{if !empty($item.action)}
								{__d('template', 'thong_tin_nguoi_tang')}
							{else}
								{__d('template', 'thong_tin_nguoi_nhan')}
							{/if}
							)
						</span>
						<div class="collapse" id="collapseGivePoint">
  							{if !empty($item.customer_related_code)}
								<p class="mb-0">
									<strong>{__d('template', 'ma_khach_hang')}: </strong>
									{$item.customer_related_code}
								</p>
							{/if}

							{if !empty($item.customer_related_name)}
								<p class="mb-0">
									<strong>{__d('template', 'ten_khach_hang')}: </strong>
									{$item.customer_related_name}
								</p>
							{/if}
  						</div>
					{/if}
				</div>

				<div class="col-sm-3 col-12">
					{if !empty($item.created)}
    					{$this->Utilities->convertIntgerToDateTimeString($item.created)}
    				{/if}
				</div>

				<div class="col-sm-3 col-12">
					{if !empty($item.point) && isset($item.action)}
						<div class="color-hover fs-19 font-weight-bold text-right">
							{if $item.action == 0}
								<span class="color-hover">
									- {$item.point|number_format:0:".":","}
								</span>
							{else if $item.action == 1}
								<span class="font-success">
									+ {$item.point|number_format:0:".":","}
								</span>
							{/if}

    					</div>
					{/if}
				</div>
    		</div>
    	</div>
	{/foreach}
	{$this->element('../Member/pagination', ['pagination' => $pagination])}
{else}
	<div class="p-30 text-center">
		<i>
			{__d('template', 'chua_co_thong_tin')}
		</i>
	</div>
{/if}