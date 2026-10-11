{strip}
{if empty($is_slider)}
<div class="{if !empty($col)}{$col}{else}col-xl-3 col-lg-3 col-md-6 col-6 mb-20{/if}">
{/if}
    <div 
        class="edu-card card-type-1 radius-small product-item-book"
        nh-product="{if !empty($product.id)}{$product.id}{/if}"
        nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}"
        nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}"
    >
        <div class="inner">
            <div class="thumbnail">
                {if !empty($product['all_images'][0])}
                    {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][0], 500)}"}
                {else}
                    {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
                {/if}

                <a href="{$this->Utilities->checkInternalUrl($product.url)}" title="{$product.name}">
                    {*$this->LazyLoad->renderImage([
                        'src' => $url_img, 
                        'alt' => $product.name, 
                        'class' => 'w-100'
                    ])*}
                    <img src="{$url_img}" alt="{$product.name}" class="w-100" />
                </a>
                {if !empty($product.apply_special) && !empty($product.discount_percent)}
                    <div class="top-position status-group left-top">
                        <span class="eduvibe-status status-02">
                            <i class="fa-solid fa-bolt"></i> GIẢM -{$product.discount_percent}%
                        </span>
                    </div>
                {/if}
                
                {if !empty($type) && ($type == 'product-combo')}
                    {if !empty($product.items[0].apply_special) && !empty($product.items[0].discount_percent)}
                        <div class="top-position status-group left-top">
                            <span class="eduvibe-status status-02">
                                <i class="fa-solid fa-bolt"></i> GIẢM -{$product.items[0].discount_percent|round}%
                            </span>
                        </div>
                    {/if}
                {/if}
            </div>
            <div class="content">
                {if !empty($product.name)}
                    <h6 class="title">
                        <a href="{$this->Utilities->checkInternalUrl($product.url)}">
                            {$product.name|escape}
                        </a>
                    </h6>
                {/if}
                <div class="inner-price">
                    {if empty($product.apply_special) && !empty($product.price)}
                        <div class="price current-price">{$product.price|number_format:0:".":","}đ</div>
                    {/if}
    
                    {if !empty($product.apply_special) && !empty($product.price_special)}
                        <div class="price current-price">{$product.price_special|number_format:0:".":","}đ</div>
                    {/if}
                    
                    {if !empty($product.apply_special) && !empty($product.price)}
                        <div class="price old-price">{$product.price|number_format:0:".":","}đ</div>
                    {/if}
                    
                    {if !empty($type) && ($type == 'product-combo')}
                        {if empty($product.items[0].apply_special) && !empty($product.items[0].price)}
                            <div class="price current-price">{$product.items[0].price|number_format:0:".":","}đ</div>
                        {/if}
        
                        {if !empty($product.items[0].apply_special) && !empty($product.items[0].price_special)}
                            <div class="price current-price">{$product.items[0].price_special|number_format:0:".":","}đ</div>
                        {/if}
                        
                        {if !empty($product.items[0].apply_special) && !empty($product.items[0].price)}
                            <div class="price old-price">{$product.items[0].price|number_format:0:".":","}đ</div>
                        {/if}
                    {/if}
                </div>
                
                {*<div class="card-bottom">
                    {if !empty($product.attributes.motangan.value)}
                        <div class="inner-desc">
                            {$product.attributes.motangan.value}
                        </div>
                    {/if}
                </div>*}
            </div>
        </div>
    </div>
{if empty($is_slider)}
</div>
{/if}
{/strip}