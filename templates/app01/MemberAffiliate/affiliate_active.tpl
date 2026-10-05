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
			<div class="rounded bg-white">
				<h3 class="bg-black color-white title-affiliate fs-16 font-weight-bold mb-0">
					{__d('template', 'kich_hoat_tai_khoan_doi_tac')}
				</h3>

				<div class="pt-30">
					{if empty($member.is_partner_affiliate)}
						<h4 class="color-black fs-20">
							<strong>{__d('template', 'thong_tin_ca_nhan')}</strong>
						</h4>
						<div class="row">
							<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    {__d('template', 'ho_va_ten')}: 
					                </label>

					                {if !empty($member.full_name)}
					                	<input readonly placeholder="{$member.full_name}" type="text" class="form-control rounded" autocomplete="off">
					                {else}
					                	{__d('template', 'chua_co_thong_tin')} 
				                		<a class="font-danger" href="/member/profile">
				                			({__d('template', 'cap_nhap')})
				                		</a>
					                {/if}
					            </div>
							</div>

							<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    Email: 
					                </label>
				                	<div>
				                		{if !empty($member.email)}
				                			<input readonly placeholder="{$member.email}" type="text" class="form-control rounded" autocomplete="off">
				                		{else}
				                			{__d('template', 'chua_co_thong_tin')} 
				                			<a class="font-danger" href="/member/profile">
				                				({__d('template', 'cap_nhap')})
				                			</a>
				                		{/if}
									</div>
					            </div>
							</div>
						</div>

						<div class="row">
							<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    {__d('template', 'so_dien_thoai')}: 
					                </label>
				                	<div>
				                		{if !empty($member.phone)}
				                			<input readonly placeholder="{$member.phone}" type="text" class="form-control rounded" autocomplete="off">
				                		{else}
				                			{__d('template', 'chua_co_thong_tin')} 
				                			<a class="font-danger" href="/member/profile">
				                				({__d('template', 'cap_nhap')})
				                			</a>
				                		{/if}
									</div>
					            </div>
							</div>

							{*<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    {__d('template', 'dia_chi')}: 
					                </label>
				                	<div>
				                		{if !empty($member.address)}
				                			<input readonly placeholder="{$member.address}" type="text" class="form-control rounded" autocomplete="off">
				                		{else}
				                			{__d('template', 'chua_co_thong_tin')} 
				                			<a class="font-danger" href="/member/address">
				                				({__d('template', 'cap_nhap')})
				                			</a>
				                		{/if}
									</div>
					            </div>
							</div>*}
						</div>

						{*<div class="row">
							<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    {__d('template', 'tinh_thanh')}: 
					                </label>
				                	<div>
				                		{if !empty($member.city_name)}
				                			<input readonly placeholder="{$member.city_name}" type="text" class="form-control rounded" autocomplete="off">
				                		{else}
				                			{__d('template', 'chua_co_thong_tin')} 
				                			<a class="font-danger" href="/member/address">
				                				({__d('template', 'cap_nhap')})
				                			</a>
				                		{/if}
									</div>
					            </div>	
							</div>

							<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    {__d('template', 'quan_huyen')}: 
					                </label>
				                	<div>
				                		{if !empty($member.district_name)}
				                			<input readonly placeholder="{$member.district_name}" type="text" class="form-control rounded" autocomplete="off">
				                		{else}
				                			{__d('template', 'chua_co_thong_tin')} 
				                			<a class="font-danger" href="/member/address">
				                				({__d('template', 'cap_nhap')})
				                			</a>
				                		{/if}
									</div>
					            </div>
							</div>
						</div>*}

						{*<div class="row">
							<div class="col-6">
								<div class="form-group">
					                <label class="font-weight-normal">
					                    {__d('template', 'phuong_xa')}: 
					                </label>
				                	<div>
				                		{if !empty($member.ward_name)}
				                			<input readonly placeholder="{$member.ward_name}" type="text" class="form-control rounded" autocomplete="off">
				                		{else}
				                			{__d('template', 'chua_co_thong_tin')} 
				                			<a class="font-danger" href="/member/address">
				                				({__d('template', 'cap_nhap')})
				                			</a>
				                		{/if}
									</div>
					            </div>
							</div>
						</div>*}

						<form nh-form="process-active" action="/member/affiliate/process-active" method="post" autocomplete="off">
							{*<h4 class="color-black line-height-25">
								<strong>{__d('template', 'thong_tin_cmnd_cccd')}</strong>
							</h4>
							<div class="row">
								<div class="col-6">
									<div class="form-group">
						                <label class="font-weight-normal">
						                    {__d('template', 'ho_va_ten_cmnd_cccd')}: 
						                </label>
						                <input name="identity_card_name" type="text" class="bg-white border form-control rounded input-hover" value="{if !empty($member.identity_card_name)}{$member.identity_card_name}{/if}">
						            </div>
								</div>

								<div class="col-6">
									<div class="form-group">
						                <label class="font-weight-normal">
						                    CMND/CCCD: 
						                </label>
					                	<input name="identity_card_id" value="{if !empty($member.identity_card_id)}{$member.identity_card_id}{/if}" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
						            </div>
								</div>
							</div>
							<div class="row">
								<div class="col-6">
									<div class="form-group">
						                <label class="font-weight-normal">
						                    {__d('template', 'ngay_cap')}: 
						                </label>
						                <input nh-date name="identity_card_date" type="text" data-date-end-date="0d" class="form-control rounded input-hover" value="{if !empty($member.identity_card_date)}{$member.identity_card_date}{/if}" placeholder="dd/mm/yyyy">
						            </div>
								</div>
								<div class="col-6">
									<div class="form-group">
						                <label class="font-weight-normal">
						                    {__d('template', 'noi_cap')}: 
						                </label>
						                <input name="identity_card_where" type="text" class="bg-white border form-control rounded input-hover" value="{if !empty($member.identity_card_where)}{$member.identity_card_where}{/if}">
						            </div>
								</div>
							</div>*}
							<h4 class="color-black fs-20">
								<strong>{__d('template', 'thong_tin_ngan_hang')}</strong>
							</h4>
					    	<div class="row">
					    		<div class="col-6">
					    			<div class="form-group">
								        <label for="bank_key" class="font-weight-normal">
								            {__d('template', 'ten_ngan_hang')}: 
								        </label>
								        <input name="bank_key" value="{if !empty($affiliate.bank_key)}{$affiliate.bank_key}{/if}" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
								        {*$this->Form->select('bank_key', $this->Member->getListBank(), ['id' => 'bank_key', 'empty' => "-- {__d('template', 'ten_ngan_hang')} --", 'default' => "", 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])*}
							        </div>
					    		</div>

					    		<div class="col-6">
								    <div class="form-group">
								        <label for="bank_branch" class="font-weight-normal">
								            {__d('template', 'chi_nhanh')}: 
								        </label>
								        <input name="bank_branch" value="{if !empty($affiliate.bank_branch)}{$affiliate.bank_branch}{/if}" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
								    </div>
					    		</div>
					    	</div>

					    	<div class="row">
					    		<div class="col-6">
					    			<div class="form-group">
								        <label for="account_holder" class="font-weight-normal">
								            {__d('template', 'chu_tai_khoan')}: 
								        </label>
								        <input name="account_holder" value="{if !empty($affiliate.account_holder)}{$affiliate.account_holder}{/if}" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
								    </div>
					    		</div>

					    		<div class="col-6">
					    			<div class="form-group">
								        <label for="account_number" class="font-weight-normal">
								            {__d('template', 'so_tai_khoan')}: 
								        </label>
								        <input name="account_number" value="{if !empty($affiliate.account_number)}{$affiliate.account_number}{/if}" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
								    </div>
					    		</div>
					    	</div>

						    <div class="row">
						    	<div class="col-6">
						    		<a href="/member/dashboard" class="btn bg-light py-10 px-20 fs-15 w-100 text-center">
							            {__d('template', 'huy_dang_ky')}
							        </a>
						    	</div>
						    	
						    	<div class="col-6">
						    		<span nh-btn-action="submit" class="btn btn-primary py-10 px-20 fs-15 w-100 text-center">
							            ĐĂNG KÝ
							        </span>
						    	</div>
						    </div>
						</form>
					{elseif $member.is_partner_affiliate == 2}
						{__d('template', 'dang_cho_quan_tri_xet_duyet')}
					{else}
						{__d('template', 'ban_hien_dang_la_doi_tac_cua_chung_toi')}
					{/if}
				</div>
			</div>
		</div>
	</div>	
</div>