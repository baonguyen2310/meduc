{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {$title_for_layout}]
	]
])}

<script src="{URL_TEMPLATE}assets/lib/chartjs/chart.js"></script>

{assign member_info value = $this->Member->getMemberInfo()}
<div class="container mb-60">
	<div class="row">
		<div class="col-12 col-md-3 col-lg-3">
			{$this->element('../Member/element_menu')}
		</div>
		
		<div class="col-12 col-md-9 col-lg-9">
			<div class="rounded bg-white shadow-box7 p-15 mb-10 h-100">
				<h4 class="color-black line-height-25 fs-24 mb-30">
					<strong>
						{$title_for_layout}
					</strong>
				</h4>
				<form nh-form="member-aff-bank" action="/member/aff/bank/save" method="post" autocomplete="off">
				    
				    <div class="row">
				        <div class="col-md-6 col-12">
        				    <div class="form-group">
        				        <label for="full_name">
        				            Tên ngân hàng:
        				            <span class="required">*</span>
        				        </label>
        				        <input name="bank_name" value="{if !empty($member.bank_name)}{htmlentities($member.bank_name)}{/if}" placeholder="Ví dụ: Agribank" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
        				    </div>
        				</div>
        			</div>
        			
        			<div class="row">
        			    <div class="col-md-6 col-12">
        				    <div class="form-group">
        				        <label for="full_name">
        				            Chủ tài khoản:
        				            <span class="required">*</span>
        				        </label>
        				        <input name="bank_fullname" value="{if !empty($member.bank_fullname)}{htmlentities($member.bank_fullname)}{/if}" placeholder="Ví dụ: LE VAN A" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
        				    </div>
        				</div>
        			</div>
        			
        			<div class="row">
        			    <div class="col-md-6 col-12">
        				    <div class="form-group">
        				        <label for="full_name">
        				            Số tài khoản:
        				            <span class="required">*</span>
        				        </label>
        				        <input name="bank_number" value="{if !empty($member.bank_number)}{htmlentities($member.bank_number)}{/if}" placeholder="Ví dụ: 0123456789" type="text" class="bg-white border form-control rounded input-hover" autocomplete="off">
        				    </div>
        				</div>
        			</div>
        			
        			<div class="row">
        			    <div class="col-md-12 col-12">
        				    <div class="form-group">
        				        <span nh-btn-action="submit" type="submit" class="btn btn-primary fs-14 py-10 px-20">
        				            {__d('template', 'cap_nhat')}
        				        </span>
        				    </div>
        				</div>
        			</div>
				</form>
			</div>
		</div>
	</div>	
</div>