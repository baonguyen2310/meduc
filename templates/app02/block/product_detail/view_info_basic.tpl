{assign var = product value = []}
{if !empty($data_block.data)}
	{assign var = product value = $data_block.data}
{/if}

{assign var = first_item value = []}
{if !empty($product.items[0])}
	{assign var = first_item value = $product.items[0]}
{/if}

{assign var = all_images value = []}
{if !empty($product.all_images)}
	{assign var = all_images value = $product.all_images}
{/if}

{assign var = attributes value = []}
{if !empty($product.attributes)}
	{assign var = attributes value = $product.attributes}
{/if}
{if !empty($product)}
	{strip}

	<ol data-toc="div.product-detail-footer" data-toc-headings="h2,h3,h4" class="mb-0"></ol>

	<div class="product-detail-head">
		<div nh-product-detail nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}" class="product-content-detail">

		    <div class="bg-white rounded-10 mb-10 py-10 px-15">
		        {if !empty($product.name)}
					<h2 class="product-title-detail  fs-16 fs-md-24 mb-5">
						{$product.name|escape}
		            </h2>
	            {/if}
                <div class="code-review-link d-flex align-items-center flex-nowrap align-items-center mb-5">
                    <div class="code fs-12 mr-15 mr-lg-25">
                        <span>
                            {__d('template', 'SKU')}: 
                        </span>
                        <span class="pl-5 font-weight-bold color-text" nh-label-code="{if !empty($first_item.code)}{$first_item.code}{/if}">
                        	{if !empty($first_item.code)}
                        		{$first_item.code}
                        	{/if}
                        </span>
                    </div>
                    {if !empty($product.brand_name)}
	                    <div class="brand-name mr-15 mr-lg-25">
	                        <span>
	                            {__d('template', 'thuong_hieu')}: 
	                        </span>
	                        <span class="pl-5 font-weight-bold color-text">
	                            {$product.brand_name}
	                        </span>
	                    </div>
		            {/if}
		            
		            {if !empty($attributes['baohanh'].value)}
	                    <div class="brand-name">
	                        <span >
	                            {__d('template', 'bao_hanh')}: 
	                        </span>
	                        <span class="pl-5 font-weight-bold color-text">
	                             {$attributes['baohanh'].value}
	                        </span>
	                    </div>
		            {/if}
		            
                </div>
                <div class="product-rating d-flex align-items-center flex-nowrap mb-10 pb-10 border-bottom">
	                <div class="star-rating">
	                    <span style="width:100%"></span>
	                </div>

	                <div class="review-link fs-12 fs-md-14">
	                    {if !empty($product.comment)}
	                        (<span class="count pr-5">
	                            {$product.comment|number_format:0:".":","}
	                        </span> 
	                        {__d('template', 'khach_hang_da_binh_luan')})
	                    {else}
	                        ({__d('template', 'chua_co_binh_luan_nao')})
	                    {/if}
	                </div>
	            </div>
	            <div class="price ">
	            	{if empty($first_item.apply_special) && !empty($first_item.price)}
		                <span nh-label-price="{$first_item.price}" class="price-amount fs-16 fs-md-24 color-main">
		                    <span nh-label-value>
		                        {$first_item.price|number_format:0:".":","}
		                    </span>                    
		                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
		                </span>
	                {/if}

	                {if !empty($first_item.apply_special) && !empty($first_item.price_special)}
	                	<span nh-label-price="{$first_item.price_special}" class="price-amount fs-14 fs-md-24 color-main">
		                    <span nh-label-value>
		                        {$first_item.price_special|number_format:0:".":","}
		                    </span>                    
		                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
		                </span>
	                {/if}

	                {if !empty($first_item.price) && !empty($first_item.apply_special)}
	                    <span nh-label-price-special="{$first_item.price}" class="price-amount old-price fs-14 fs-md-16 color-text">
	                        <span nh-label-value>
	                            {$first_item.price|number_format:0:".":","}
	                        </span>
	                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
	                    </span>
	                {/if}
	            </div>
		    </div>
		    
		    {if !empty($product.description)}
		        <div class="bg-white rounded-10 mb-10 py-10 px-15">
                    {$product.description}
		        </div>
            {/if}
            
            {if !empty($product.status == 2)}
            	<div  class="out-of-stock">
	                {__d('template', 'san_pham_ngung_kinh_doanh')}
	            </div>
	        {else}
	            {if !empty($product.attributes_item_apply)}
	                <div class="entire-attribute">
	                    {foreach from = $product.attributes_item_apply item = attribute key = attribute_id name = foreach_attribute}
	                        <div nh-attribute="{if !empty($attribute.code)}{$attribute.code}{/if}" class="list-attribute d-flex flex-column  bg-white rounded-10 mb-10 py-10 px-15 ">
	                            <div class="mb-10 d-flex align-items-center justify-content-between">
	                                {if !empty($attribute.name)}
		                                <p class="mb-0">
		                                    {$attribute.name}:
		                                </p>
		                            {/if}
                                    
	                                <a nh-btn-action="clear-attribute-option" class="reset-attribute effect-border-scale" href="javascript:;">
	                                    {__d('template', 'xoa')}
	                                </a>
	                            </div>
	                            
	                            {if !empty($attribute.options)}
	                                <div class="product-attribute-switch d-flex justify-content-start {if !empty($attribute.has_image)}image-switch{else}text-switch{/if}">
	                                    {foreach from = $attribute.options item = option key = attribute_option_id name = foreach_option}
	                                        {assign var = background_image value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
	                                        {if !empty($attribute.has_image) && !empty($option.image)}
	                                            {assign var = background_image value = "{CDN_URL}{$this->Utilities->getThumbs($option.image, 50)}"}
	                                        {/if}
	                                        
	                                        <div nh-attribute-option="{if !empty($option.code)}{$option.code}{/if}" class="inner-product-attribute" {if !empty($attribute.has_image)}style="background-image: url('{$background_image}'); background-color: #fff;background-repeat: no-repeat;background-size: contain;" data-toggle="tooltip" data-placement="top" title="" data-original-title="{if !empty($option.name)}{$option.name}{/if}"{/if} data-trigger="{if !empty($attribute.has_image) && !empty($option.image)}{CDN_URL}{$this->Utilities->getThumbs($option.image, 150)}{/if}">
	                                            {if !empty($option.name) && empty($attribute.has_image)}
	                                                {$option.name}
	                                            {/if}
	                                        </div>
	                                    {/foreach}
	                                </div>
	                            {/if}
	                        </div>
	                    {/foreach}
	                </div>
	            {/if}
	            <div class="entire-cart bg-white rounded-10  mb-10 py-10 px-15 {if isset($first_item.quantity_available) && $first_item.quantity_available <= 0 && !empty($data_init.product.check_quantity)}d-none{/if}">
	                {if !empty($first_item.price)}
                        <div class="quantity-buy d-flex flex-wrap flex-row justify-content-between">
		                    {$this->element('input_quantity')}
    
		                    <a nh-btn-action="add-cart" href="javascript:;" class="add-to-cart rounded">
			                    {__d('template', 'them_gio_hang')}
			                </a>
			                
			                <a nh-btn-action="add-cart" nh-redirect="/order/info" href="javascript:;" class="add-to-cart rounded bg-main">
			                    {__d('template', 'thanh_toan_ngay')}
			                </a>
		                </div>
                    {else}
                        <span class="fs-18 fs-lg-24 color-red font-weight-bold">
                            {__d('template', 'lien_he')}
                        </span>
                    {/if}
	            </div>

	            <div nh-quantity-product="out-stock" class="out-of-stock {if (isset($first_item.quantity_available) && $first_item.quantity_available > 0) || empty($data_init.product.check_quantity)}d-none{/if}">
	                {__d('template', 'san_pham_het_hang')}
	            </div>
            {/if}
		</div>
	</div>
{else}
	<p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}