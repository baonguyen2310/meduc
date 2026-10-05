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
			<div nh-affiliate class="rounded bg-white p-15 mb-10 h-100">
			    {if !empty($affiliate)}
			    	<div class="row">
						{foreach from = $affiliate item = item}
							<div class="col-12 col-md-6">
						        <div class="item-address-member mb-15">
						            {if !empty($item.bank_name)}
		    				            <div class="font-weight-bold mb-10">
		    			        		    {__d('template', 'ten_ngan_hang')}: {$item.bank_name}
		    			        		</div>
		    			        	{/if}

		    			        	{if !empty($item.account_holder)}
		    					        <div class="mb-5">
		    					            {__d('template', 'chu_tai_khoan')}: {$item.account_holder}
		    					        </div>
		    			        	{/if}

		    			        	{if !empty($item.bank_branch)}
		    			        	    <div class="mb-5">
		    			        		    {__d('template', 'chi_nhanh')}: {$item.bank_branch}
		    			        		 </div>
		    			        	{/if}

		    			        	{if !empty($item.account_number)}
		    					        <div class="mb-5">
		    					            {__d('template', 'so_tai_khoan')}: {$item.account_number}
		    					        </div>
		    			        	{/if}

		    						<div class="d-flex justify-content-between">
		    							<div class="d-flex justify-content-end">
		    							    <a nh-affiliate="delete-bank" href="javascript:;" class="btn-sm btn btn-action color-hover font-weight-bold fs-14 fs-md-15" data-id="{if !empty($item.id)}{$item.id}{/if}">
		    							    	{__d('template', 'xoa')}
		    	                            </a>
		    								<a nh-affiliate="edit" data-affiliate="{htmlentities($item|@json_encode)}" href="javascript:;" class="btn-sm btn btn-action font-weight-bold  fs-14 fs-md-15" >
		    									{__d('template', 'sua')}
		    		                        </a>
		    		                        
		                                </div>
		    						</div>
						        </div>
					    	</div>
					    {/foreach}
				    </div>
				{else}
					<div>
						{__d('template', 'hien_chua_co_ngan_hang_nao_duoc_lien_ket')}
					</div>
			    {/if}
                <div class="btn-add-member mt-30">
                    <a nh-affiliate="add" href="javascript:;" class="btn bg-main btn-1a color-white fs-14 px-25 rounded">
                    	{__d('template', 'them_ngan_hang')}
                    </a>
                </div>
			</div>
			
		</div>
	</div>	
</div>
{$this->element('../Member/change_associate_bank_modal')}