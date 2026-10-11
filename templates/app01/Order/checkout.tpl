{$this->element('breadcrumb', [
	'list_url' => [
		['title' => {__d('template', 'thanh_toan')}]
	]
])}
{assign var = message value = $this->Utilities->getParamsByKey('message')}
<div class="container">
	<div class="payment-section ">
		<div class="row">
			<div class="col-md-7">
				{if !empty($message)}
					<div class="alert alert-danger" role="alert">
					  	{$message}
					</div>
				{/if}

				{$this->element('../Order/element_product_info')}

			    <div class="order-review border rounded mb-10 p-15">
					<div class="entry-order-review mb-0 ">
						<h3 class="color-black fs-md-16 fs-14 mb-10">
							{__d('template', 'thong_tin_khach_hang')}
						</h3>
						{$this->element('../Order/element_contact')}
					</div>			
				</div>

				<div class="payment-method border rounded mb-10 p-15">
				    
					<form id="form-checkout" action="" method="post">
						<div class="d-flex align-content-stretch flex-wrap ">
							{if !empty($payment_gateway)}
								<ul class="nav w-100" role="tablist">
									{foreach from = $payment_gateway item = $gateway key = code name = each_nav}
									    <li class="nav-item clearfix mb-10">
									        <a nh-gateway-item="{$code}" href="#{$code}" class="nav-link color-black d-flex  align-items-center border px-15  {if $smarty.foreach.each_nav.first}active{/if}" data-toggle="tab" role="tab">
									        	<div class="inner-icon position-relative  mr-15">
									        		<img class="img-fluid rti-abs-contain" src="{URL_TEMPLATE}assets/img/payment/{$code}.png" alt="{$code}" /> 
									        	</div>
									        	<div class="inner-label text-left">
									        		{if !empty($gateway.name)}
									        			{$gateway.name|truncate:50:" ..."}
									        		{/if}
									        		
									        		{if !empty($gateway.content)}
        										        <div class="content-payment fs-14 font-weight-normal">
        								        			{$gateway.content|truncate:100:" ..."}
        								        		</div>
        							        		{/if}
									        	</div>
									        	
									    	</a>
									    </li>
								    {/foreach}
								</ul>

								<div class="tab-content w-100">
									{foreach from = $payment_gateway item = $gateway key = code name = each_tab}
									    <div id="{$code}" class="tab-pane {if $smarty.foreach.each_tab.first}active{/if}" role="tabpanel">
									    	{if $code == {BANK}}
									    		{assign var = list_bank value = []}
									    		{if !empty($gateway.config)}
									    			{assign var = list_bank value = $gateway.config}
									    		{/if}

									    		{if !empty($list_bank)}
    									    		<div class="color-main fw-bold">
                                                        "Đã có hơn 500 học viên đăng kí học , hãy để Meduc giúp bạn Vững chuyên môn"
                                                    </div>
									    		    <p class="text-black font-weight-bold mb-10 fs-13">
									    		        Vui lòng thanh toán bằng cách chuyển khoản ngân hàng hoặc Momo theo thông tin bên dưới.
									    		    </p>
									    		    <div class="row">
									    		        <div class="col-xl-6 col-lg-12">
									    		            <div class="border rounded mb-10 p-15">
									    		                <h3 class="color-black fs-md-16 fs-14 mb-10">
            												    	{__d('template', 'tai_khoan_ngan_hang')}
            												    </h3>
            
            											    	<div class="entry-bank fs-12">
            											    		{foreach from = $list_bank item = bank key = key name = each_bank}
            											    		    <div>
            											    		        {if !empty($bank.bank_name)}
            											    		            <p class="mb-0 fs-12">
            											    		                {__d('template', 'ten_ngan_hang')}: <b>{$bank.bank_name}</b>
            											    		            </p>
            											    		        {/if}
            											    		        {if !empty($bank.bank_branch)}
            											    		            <p class="mb-0 fs-12">
            											    		                {__d('template', 'chi_nhanh')}: <b>{$bank.bank_branch}</b>
            											    		            </p>
            											    		        {/if}
            											    		        {if !empty($bank.account_holder)}
            											    		            <p class="mb-0 fs-12">
            											    		                {__d('template', 'chu_tai_khoan')}: <b>{$bank.account_holder}</b>
            											    		            </p>
            											    		        {/if}
            											    		        {if !empty($bank.account_number)}
            											    		            <p class="mb-10 fs-12">
            											    		                {__d('template', 'so_tai_khoan')}: <b>{$bank.account_number}</b>
            											    		            </p>
            											    		        {/if}
                											    		     <div class="entry-bank fs-12 mb-10">
                            											        {$this->LazyLoad->renderImage([
                                                                                    'src' => "{CDN_URL}/media/core/bank-qr-code.jpg", 
                                                                                    'alt' => "Thanh toán qua ví MoMo",
                                                                                    'class' => 'img-qr-code'
                                                                                ])}
                            											    </div>
            											    		        {if !empty($order_info.code)}
                            										    	    {assign var = contact value = []}
                            										    	    {if !empty($order_info.contact)}
                            										    	        {assign var = contact value = $order_info.contact}
                            										    	    {/if}
                            										    	    <p class="mb-0 fs-12">
            															            Nội dung thanh toán:
            															            {*<span class="text-danger fw-bold">{$order_info.code}_{$contact.phone}</span>*}
            															            <span class="text-danger fw-bold">
                            												            {$order_info.contact.full_name}
                            												            {foreach from = $order_info.items item = item}
                            												                _ {$item.name}
                            												            {/foreach}
                            												        </span>
            															        </p>
                            										    	{/if}
            											    		    </div>
            														{/foreach}
            											    	</div>
									    		            </div>
									    		        </div>
									    		        <div class="col-xl-6 col-lg-12">
									    		            <div class="border rounded mb-10 p-15">
									    		                <h3 class="color-black fs-md-16 fs-14 mb-10">
                											    	Thanh toán qua ví MoMo
                											    </h3>
                											    
                											    <p class="mb-10 fs-12">
										    		                Số điện thoại: <b>0339308997</b>
										    		            </p>
                											    
                											    <div class="entry-bank fs-12 mb-10">
                											        {$this->LazyLoad->renderImage([
                                                                        'src' => "{CDN_URL}/media/core/momo-qr-code.jpg", 
                                                                        'alt' => "Thanh toán qua ví MoMo",
                                                                        'class' => 'img-qr-code'
                                                                    ])}
                											    </div>
                											    
                											    {if !empty($order_info.code)}
                										    	    {assign var = contact value = []}
                										    	    {if !empty($order_info.contact)}
                										    	        {assign var = contact value = $order_info.contact}
                										    	    {/if}
                										    		<p class="color-black fs-12 mb-10">
                												    	Lời nhắn: 
                												        <span class="text-danger fw-bold">
                												            {$order_info.contact.full_name}
                												            {foreach from = $order_info.items item = item}
                												                _ {$item.name}
                												            {/foreach}
                												        </span>
                												    </p>
                										    	{/if}
									    		            </div>
									    		        </div>
									    		    </div>
									    		    <p class="text-danger mb-10 fs-16">
									    		        Chỉ nhấn vào <strong>"Hoàn tất thanh toán"</strong> khi đã chuyển khoản xong.
									    		    </p>
										    	{/if}
									    	{/if}
                                            
							        		<div class="mt--20">
												<span nh-btn-action="checkout" class="edu-btn w-100 text-center">
							                        Hoàn tất thanh toán
							                    </span>
											</div>
									    </div>
								    {/foreach}
								</div>
							{/if}
						</div>
						<input name="payment_gateway" value="" type="hidden">
						<input name="affiliateCode" value="" type="hidden" id="affiliate-code">
						<input name="code" value="{if !empty($order_info.code)}{$order_info.code}{/if}" type="hidden">
					</form>
				</div>
			</div>
			
			<div class="col-md-5">
				<div class="order-review mb-0">
					<div class="entry-order-review ">
						{$this->element('../Order/element_items')}
					</div>
				</div>	
			</div>
		</div>
	</div>	
</div>
