<div class="wrap-suggestion">
	{if !empty($products)}
	    <ul class="list-unstyled">
	        {foreach from = $products item = product}
	            {if !empty($product['image'])}
	                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['image'], 50)}"}
	            {else}
	                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
	            {/if}
	            
	            <li>
	                <a nh-btn-action="compare" data-product-id="{if !empty($product.id)}{$product.id}{/if}" class="media" href="javascript:;">
						<img src="{$url_img}" alt="{if !empty($product.name)}{$product.name}{/if}" class="img-fluid mr-10">
	                	<div class="media-body">
	                		{if !empty($product.name)}
	                    		<h5 class="suggest-name">
	                    			{$product.name|truncate:45:" ..."}
	                    		</h5>
	                		{/if}
	            			<div class="price suggest-price">
		                        <span class="price-amount">
		                            {if empty($product.apply_special) && !empty($product.price)}
		                                {$product.price|number_format:0:".":","}
		                                <span class="currency-symbol">{CURRENCY_UNIT}</span>
		                            {/if}

		                            {if !empty($product.apply_special) && !empty($product.price_special)}
		                                {$product.price_special|number_format:0:".":","}
		                                <span class="currency-symbol">{CURRENCY_UNIT}</span>
		                            {/if}
		                        </span>                        

		                        {if !empty($product.apply_special) && !empty($product.price)}
		                            <span class="price-amount old-price">
		                                {$product.price|number_format:0:".":","}
		                                <span class="currency-symbol">{CURRENCY_UNIT}</span>
		                            </span>
		                        {/if}
	            			</div>
	                	</div>
	                </a>
	            </li>
	        {/foreach}
	    </ul>
	{/if}
</div>