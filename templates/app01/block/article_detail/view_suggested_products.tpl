{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
{strip}
	{if !empty($article_info.attributes.sanphamgoiy.value)}
	    <div class="producr-detail-combined product-text-left">
	        {$list_similar_product = $this->Product->getProducts([
            'filter' => [
                'ids' => json_decode($article_info.attributes.sanphamgoiy.value, true)
            ],
            'get_attributes' => true
        ])}
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <h3 class="title-section text-center">
                {$this->Block->getLocale('tieu_de', $data_extend)}
            </h3>
        {/if}
        <div nh-owl-slick="{if !empty($data_extend.slider_product)}{htmlentities($data_extend.slider_product|@json_encode)}{/if}">
    		{foreach from = $list_similar_product item = product}
    		    {assign var = product_first value = $product.items[0]}
                    <div
                        nh-product="{if !empty($product.id)}{$product.id}{/if}"
                        nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}"
                        nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}"
                        class="product-item"
                    >
                        <div class="inner-image">
                            <div class="wrp-effect-change-img ratio-custome">
                                {if !empty($product['all_images'][0])}
                                    {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][0], 350)}"}
                                {else}
                                    {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
                                {/if}
                
                                <a href="{$this->Utilities->checkInternalUrl($product.url)}" title="{$product.name}">
                                    {$this->LazyLoad->renderImage([
                                        'src' => $url_img, 
                                        'alt' => $product.name, 
                                        'class' => 'img-fluid rti-abs-cover'
                                    ])}
                                </a>
                
                                {if !empty($product['all_images'][1])}
                                    <div class="effect-change-img">
                                        <a href="{$this->Utilities->checkInternalUrl($product.url)}" title="{$product.name}">
                                            {$this->LazyLoad->renderImage([
                                                'src' => "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][1], 350)}", 
                                                'alt' => $product.name,
                                                'class' => 'img-fluid'
                                            ])}
                                        </a>
                                    </div>
                                {/if}
                            </div>
                        </div>
                        
                        <div class="inner-content">
                            {if !empty($product_first.apply_special) && !empty($product_first.discount_percent)}
                                <span class="inner-onsale">
                                    <i class="fa-solid fa-bolt"></i> GIẢM -{$product_first.discount_percent|string_format:"%.0f"}%
                                </span>
                            {/if}
                            
                            {if !empty($product.name)}
                                <h4 class="product-title">
                                    <a href="{$this->Utilities->checkInternalUrl($product.url)}">
                                        {$product.name|escape}
                                    </a>
                                </h4>
                            {/if}
                
                            <div class="product-rating-price">
                                <div class="price">                        
                                    <span class="price-amount">
                                        {if empty($product_first.apply_special) && !empty($product_first.price)}
                                            {$product_first.price|number_format:0:".":","}
                                            <span class="currency-symbol">{CURRENCY_UNIT}</span>
                                        {/if}
                
                                        {if !empty($product_first.apply_special) && !empty($product_first.price_special)}
                                            {$product_first.price_special|number_format:0:".":","}
                                            <span class="currency-symbol">{CURRENCY_UNIT}</span>
                                        {/if}
                                    </span>                        
                
                                    {if !empty($product_first.apply_special) && !empty($product_first.price)}
                                        <span class="price-amount old-price">
                                            {$product_first.price|number_format:0:".":","}
                                            <span class="currency-symbol">{CURRENCY_UNIT}</span>
                                        </span>
                                    {/if}
                                    
                                    {if empty($product_first.price)}
                                        <span class="price-amount">
                                            Liên hệ
                                        </span>
                                    {/if}
                                </div>
                            </div>
                            <div class="inner-rating">
                
                                {assign var = rating value = 0}
                                {if !empty($product.rating)}
                                    {assign var = rating value = $product.rating}
                                {/if}
                                {assign var = percen_rating value = ($rating/5)*100}
                                
                                <div class="star-rating">
                                    <span class="star-lg" style="width:{$percen_rating}%"></span>
                                </div>
                                
                                <div class="inner-number-rating">
                                    ({if !empty($product.rating_number)}
                                        {$product.rating_number}
                                    {else}
                                        0
                                    {/if})
                                </div>
                                
                            </div>
                        </div>
                    </div>
                {/foreach}
    		</div>
	    </div>
    {/if}
{/strip}
{/if}