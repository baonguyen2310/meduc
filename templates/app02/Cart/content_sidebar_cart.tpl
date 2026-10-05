{strip}
{assign var = cart_info value = $this->Cart->getCartInfo()}
{assign var = items value = []}
{assign var = total_quantity value = 0}

{if !empty($cart_info.total_quantity)}
	{assign var = total_quantity value = $cart_info.total_quantity}
{/if}
{if !empty($cart_info['items'])}
	{assign var = items value = $cart_info['items']}
{/if}

<div class="box-minicart " nh-total-quantity-cart="{$total_quantity}">
	<ul class="cart-list list-unstyled mb-0 px-0">
		{if !empty($items)}
			{foreach from = $items item = item key = product_item_id}
				<li nh-cart-item="{$product_item_id}" nh-cart-item-quantity="{if !empty($item.quantity)}{$item.quantity}{/if}" class="cart-item clearfix mb-10">
					<div class="row">
					    <div class="col-lg-4 col-4">
					        <div class="inner-image bg-white">
        						{if !empty($item['images'][0])}
        			                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($item['images'][0], 150)}"}
        			            {else}
        			                {assign var = url_img value = "{URL_TEMPLATE}/assets/img/no-image.png"}
        			            {/if}
        
        				        <a href="{$this->Utilities->checkInternalUrl($item.url)}" title="{if !empty($item.name_extend)}{$item.name_extend}{/if}">
        				            <img class="img-fluid" src="{$url_img}" alt="{if !empty($item.name_extend)}{$item.name_extend}{/if}">
        				        </a>
        				    </div>
					    </div>
					    <div class="col-lg-8 col-8">
					        <div class="inner-content position-relative">
        				    	{if !empty($item.name_extend)}
        			                <a class="product-title mr-5" href="{$this->Utilities->checkInternalUrl($item.url)}">
        			                    {$item.name_extend|escape|truncate:50:" ..."}
        			                </a>
        		                {/if}
        
        			            <div class="quantity">
        			            	<span class="mr-5">
        				            	{if isset($item.quantity)}
        				            		{$item.quantity}
        				            	{/if}
        				            </span>
        			            	x
        			            	<span class="price-amount ml-5">
        			            		{if isset($item.price)}
        			            			{$item.price|number_format:0:".":","}
        			            			<span class="currency-symbol">{CURRENCY_UNIT}</span>
        			            		{/if}
        			            		{if !empty($item.default_price)}
        								    <span class="d-inline form-text text-muted ml-5 fs-12">
        								    	( {$item.default_price|number_format:0:".":","} 
        								    	<span class="currency-symbol fs-12">{CURRENCY_UNIT_DEFAULT}</span> )
        			                        </span>
        			                    {/if}
        			            	</span>
        			            </div>
        			            <div class="btn-delete-save">
			                        <a href="javascript:;" class="color-red" nh-remove-item-cart="{if !empty($product_item_id)}{$product_item_id}{/if}" >
			                           <i class="iconsax isax-close-circle"></i>
			                        </a>
        			            </div>
        			    	</div>
					    </div>
					</div>
				</li>
			{/foreach}
		{else}
			<li class="empty text-center">
				<i class="iconsax isax-bag-cross-1"></i>
				<div class="empty-cart">
					{__d('template', 'chua_co_san_pham_nao_trong_gio_hang')}
				</div>
			</li>
		{/if}
	</ul>

	{if !empty($items)}
		<div class="entire-bottom-minicart px-0 border-top mt-15 pt-10">
			<div class="total-price mb-10 d-flex justify-content-between align-items-center">
				<label class="mb-0 font-weight-normal fs-15">{__d('template', 'thanh_tien')}: </label>
				<p class="price-amount mb-0">
	        		{if isset($cart_info.total)}
	            		{$cart_info.total|number_format:0:".":","}
	            		<span class="currency-symbol">{CURRENCY_UNIT}</span>

	            		{if !empty($cart_info.total_default)}
						    <span class="form-text text-muted fs-12">
						    	( {$cart_info.total_default|number_format:0:".":","} 
						    	<span class="currency-symbol fs-12">{CURRENCY_UNIT_DEFAULT}</span> )
	                        </span>
	                    {/if}
	            	{/if}
	        	</p>
			</div>
			
			<div class="mini-cart-btn mt-5">
				<a href="/order/cart-info" class="btn-cart-info btn-submit d-block text-uppercase">
					{__d('template', 'xem_gio_hang')}
				</a>
			</div>
		</div>
	{/if}
</div>
{/strip}