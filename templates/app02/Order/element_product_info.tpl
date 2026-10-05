<div class="product-order-info-right bg-white rounded mb-10 p-15">
    <h3 class="color-black fs-md-20 fs-14 mb-0">
		<b>{__d('template', 'thong_tin_dat_hang')}</b>
	</h3>

	{if !empty($order_info.items)}
		{foreach from = $order_info.items item = item key = product_item_id name = item_each}
            {if !empty($item['images'][0])}
                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($item['images'][0], 150)}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}

            <div class="product-element-top row py-10 space-5">
                <div class="col-4 col-md-3">
                    <div class=" position-relative rti-66 bg-light">
            	        <a href="{$this->Utilities->checkInternalUrl($item.url)}">
                            <img class="img-fluid rti-abs-cover rti-abs-contain" src="{$url_img}" alt="{if !empty($item.name_extend)}{$item.name_extend}{/if}" />
                        </a>
                    </div>
                </div>
                
                <div class="col-8 col-md-9">
                    <div class="top-name-right">
                        <div class="name-element font-weight-bold">
                            <a href="{$this->Utilities->checkInternalUrl($item.url)}">
                                {if !empty($item.name_extend)}
    								{$item.name_extend|truncate:50:" ..."}
    							{/if}
                            </a>
                        </div>
                        <div>
                            {__d('template', 'so_luong')}: 
                            <span>
                                {if !empty($item.quantity)}
                                    {$item.quantity}
                                {else}
                                    1
                                {/if}
                            </span>
                        </div>
                       
                        <div class="price-quantity">
                            <span class="price-amount">
    							{if isset($item.total_item)}
    		            			{$item.total_item|number_format:0:".":","}
    		            			<span class="currency-symbol">
                                        {CURRENCY_UNIT}
                                    </span>
    		            		{/if}
    				        </span>
    					    
    					    {if !empty($item.default_total_item)}
    						    <span class="form-text text-muted fs-12 mt-0">
    						    	( {$item.default_total_item|number_format:0:".":","}
    						    	<span class="currency-symbol fs-12">
                                        {CURRENCY_UNIT_DEFAULT}
                                    </span>)
                                </span>
                            {/if}
                        </div>
                    </div>
                </div>
            </div>
        	    
        {/foreach}    
	{/if}
</div>