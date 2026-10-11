{assign var = contact value = []}
{if !empty($order_info.contact)}
	{assign var = contact value = $order_info.contact}
{/if}

{$this->element('../Order/element_product_info')}	

<div class="billing-details mb-10 p-15 border rounded ">
    <div class="d-flex justify-content-between align-items-center mb-10">
        <h3 class="color-black fs-md-16 fs-14 mb-0">
			Thông tin khách hàng
		</h3>

		{*if !empty($member_info)}
			<a nh-address="list" href="javascript:;" class="color-hover">
				{__d('template', 'thay_doi')}
			</a>
		{/if*}
		
        {*if empty($member_info)}
			<p class="fs-md-14 fs-13 mb-0">
				{__d('template', 'ban_da_co_tai_khoan')}  
				<a nh-order-login href="javascript:;" class="color-hover font-danger">
					{__d('template', 'dang_nhap')}
				</a>
			</p>
		{/if*}
    </div>
    
	{if !empty($member_info)}
		{$this->element('../Order/contact_info',[
			'contact' => $member_info
		])}
	{else}
		<div class="inner-col-1">
			<div class="form-billing">
				<div class="form-group validate-form">									
					<input class="bg-white border form-control rounded input-hover" name="full_name" value="{if !empty($contact.full_name)}{$contact.full_name}{/if}" type="text"  placeholder="{__d('template', 'ho_va_ten')}">
				</div>

				<div class="row">
				    <div class="col-lg-8 col-12">
			        	<div class="form-group validate-form">
							<input class="bg-white border form-control rounded input-hover" name="email" value="{if !empty($contact.email)}{$contact.email}{/if}" type="text"  placeholder="{__d('template', 'email')}">
						</div>
			        </div>

			        <div class="col-lg-4 col-12">
			        	<div class="form-group validate-form">
							<input class="bg-white border form-control rounded input-hover" name="phone" value="{if !empty($contact.phone)}{$contact.phone}{/if}" type="text"  placeholder="{__d('template', 'so_dien_thoai')}">
						</div>
			        </div>
			    </div>
                {*
			    {assign var = city_id value = null}
                {if !empty($contact.city_id)}
                    {assign var = city_id value = $contact.city_id}
                {/if}

                {assign var = district_id value = null}
                {if !empty($contact.district_id)}
                    {assign var = district_id value = $contact.district_id}
                {/if}

                {assign var = ward_id value = null}
                {if !empty($contact.ward_id)}
                    {assign var = ward_id value = $contact.ward_id}
                {/if}

				<div class="row">
			        <div class="col-lg-6 col-12">
			            <div class="form-group validate-form">
			                {$this->Form->select('city_id', $this->Location->getListCitiesForDropdown(), ['id' => 'city_id', 'empty' => "-- {__d('template', 'tinh_thanh')} --", 'default' => $city_id, 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])}
			            </div>
			        </div>

			        <div class="col-lg-6 col-12">
			            <div class="form-group validate-form">
			                {$this->Form->select('district_id', $this->Location->getListDistrictForDropdown($city_id), ['id' => 'district_id', 'empty' => "-- {__d('template', 'quan_huyen')} --", 'default' => $district_id, 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])}
			            </div>
			        </div>
			    </div>	

			    <div class="row">
		            <div class="col-md-6 col-12">
		                <div class="form-group validate-form">
		                    {$this->Form->select('ward_id', $this->Location->getListWardForDropdown($district_id), ['id' => 'ward_id', 'empty' => "-- {__d('template', 'phuong_xa')} --", 'default' => $ward_id, 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])}
		                </div>
		            </div>
		            <div class="col-md-6 col-12">
		                <div class="form-group validate-form">
        					<input class="bg-white border form-control rounded input-hover" name="address" value="{if !empty($contact.address)}{$contact.address}{/if}" placeholder="{__d('template', 'so_nha_ngo_duong')}" type="text"  >
        				</div>
		            </div>
		        </div>*}						   
			</div>
		</div>
	{/if}

	<div class="inner-col-2">
		<div class="form-additional">
			<textarea class="bg-white border form-control rounded input-hover" placeholder="{__d('template', 'ghi_chu')}" name="note" rows="2" cols="5">{if !empty($contact.note)}{$contact.note}{/if}</textarea>
		</div>
	</div>
</div>