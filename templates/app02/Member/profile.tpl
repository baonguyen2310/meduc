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
			<div class="rounded bg-white p-15 mb-10 h-100">
				<h4 class="color-black line-height-25 mb-30">
					<strong>
						{__d('template', 'sua_thong_tin')}
					</strong>
				</h4>
				<form nh-form="member-profile" action="/member/save-profile" method="post" autocomplete="off">
				    <div class="form-group">
				        <label for="full_name">
				            {__d('template', 'ho_va_ten')}: 
				            <span class="required">*</span>
				        </label>
				        <input name="full_name" value="{if !empty($member.full_name)}{htmlentities($member.full_name)}{/if}" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
				    </div>

				    <div class="row">
				        <div class="col-md-6 col-12">
				            <div class="form-group">
				                <label for="birthday">
				                    {__d('template', 'ngay_sinh')}: 
				                </label>
				                <input nh-date name="birthday" value="{if !empty($member.birthday)}{$member.birthday}{/if}" type="text" autocomplete="off" data-date-end-date="0d" class="bg-white border form-control rounded input-hover" placeholder="dd/mm/yyyy">
				            </div>
				        </div>

				        <div class="col-md-6 col-12">
				            <div class="form-group">
				                <label for="phone">
				                    {__d('template', 'gioi_tinh')}: 
				                </label>
				                <select name="sex" class="form-control form-control-sm selectpicker input-hover">
				                	<option value="other">
				                		-- {__d('template', 'gioi_tinh')} --
				                	</option>

				                	<option {if !empty($member.sex) && $member.sex == 'male'}selected{/if} value="male">
				                		{__d('template', 'nam')}
				                	</option>

				                	<option {if !empty($member.sex) && $member.sex == 'female'}selected{/if} value="female">
				                		{__d('template', 'nu')}
				                	</option>
				                </select>
				            </div>
				        </div>
				    </div>

				    <div class="row">
				        <div class="col-md-6 col-12">
				            <div class="form-group">
				                <label>
				                    {__d('template', 'email')}: 
				                </label>
				                {if !empty($member.email)}
				                	<div>
				                		{$member.email}
				                		<small>
						                	<a class="font-danger" href="/member/change-email">
						                		({__d('template', 'chinh_sua')})
						                	</a>
					                	</small>
				                	</div>
				                	<input name="email" type="hidden" {if !empty($member.email)}value="{$member.email}"{/if}>
				                {else}
				                	<input name="email" type="text" autocomplete="off" class="bg-white border form-control rounded input-hover">
				                {/if}
				            </div>
				        </div>
				        <div class="col-md-6 col-12">
				            <div class="form-group">
				                <label>
				                    {__d('template', 'so_dien_thoai')}: 
				                </label>
				                {if !empty($member.phone)}
				                	<div>
				                		{$member.phone}
				                		<small>
					                		<a class="font-danger" href="/member/change-phone">
						                		({__d('template', 'chinh_sua')})
						                	</a>
					                	</small>
				                	</div>
				                	<input name="phone" type="hidden" {if !empty($member.phone)}value="{$member.phone}"{/if}>
				                {else}
				                	<input name="phone" type="text" autocomplete="off" class="bg-white border form-control rounded input-hover">
				                {/if}
				            </div>
				        </div>
				    </div>
				    <div class="form-group">
				        <span nh-btn-action="submit" type="submit" class="btn bg-main btn-1a color-white fs-14 px-25 rounded text-uppercase">
				            {__d('template', 'cap_nhat')}
				        </span>
				    </div>
				</form>
			</div>
		</div>
	</div>	
</div>