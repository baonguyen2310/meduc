{strip}
<div nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}" class="product-item clearfix">
    <div class="inner-image">

        {if !empty($product['all_images'][0])}
            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][0], 350)}"}
        {else}
            {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
        {/if}

        <a href="{if !empty($product.url)}{$this->Utilities->checkInternalUrl($product.url)}{/if}" 
            title="{if !empty($product.name)}{$product.name}{/if}">
            {$this->LazyLoad->renderImage([
                'src' => $url_img, 
                'alt' => "{if !empty($product.name)}{$product.name}{/if}",
                'class' => 'img-fluid'
            ])}
        </a>
    </div>

    <div class="inner-content">
        {if !empty($product.name)}
            <h4 class="product-title">
                <a href="{if !empty($product.url)}{$this->Utilities->checkInternalUrl($product.url)}{/if}">
                    {$product.name|escape}
                </a>
            </h4>
        {/if}
        
        {*<div class="rating-price">  
            <div class="star-rating">
                <span style="width:100%"></span>
            </div>

            <div class="price">
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
        </div>*}
    </div>      
</div>
{/strip}