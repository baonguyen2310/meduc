{strip}
{if empty($is_slider)}
<div class="{if !empty($col)}{$col}{else}col-lg-3 col-md-6 col-6{/if}">
{/if}
    <div nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}" class="product-item">
        <div class="inner-image wrp-effect-change-img rti-100">
            <div class="product-status">
                {if !empty($product.apply_special) && !empty($product.discount_percent)}
                    <span class="onsale">
                        -{$product.discount_percent}%
                    </span>
                {/if}
                
                {if !empty($product.featured)}
                    <span class="featured">
                        {__d('template', 'noi_bat')}
                    </span>
                {/if}
                
                {if isset($product.total_quantity_available) && $product.total_quantity_available <= 0 && !empty($data_init.product.check_quantity)}
                    <span class="out-stock">
                        {__d('template', 'het_hang')}
                    </span>
                {/if}
            </div>
            {if !empty($product['all_images'][0])}
                {assign var = url_img value = "{CDN_URL}{$product['all_images'][0]}"}
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
                            'src' => "{CDN_URL}{$product['all_images'][1]}", 
                            'alt' => $product.name,
                            'class' => 'img-fluid'
                        ])}
                    </a>
                </div>
            {/if}

            {if !empty($product.attributes_item_apply)}
                <div class="product-quick-shop">
                    <a nh-btn-action="close-quick-shop" class="quick-shop-close icon-close">
                        <i class="iconsax isax-add"></i>
                    </a>
                    <div class="entry-quick-shop">
                        <div class="d-flex align-items-center flex-column h-100 justify-content-center">                            
                            <div class="entire-attribute text-center">
                                {foreach from = $product.attributes_item_apply item = attribute key = attribute_id name = foreach_attribute}
                                    <div nh-attribute="{if !empty($attribute.code)}{$attribute.code}{/if}" class="list-attribute">
                                        {if !empty($attribute.name)}
                                            <label>
                                                {$attribute.name}:
                                            </label>
                                        {/if}

                                        {if !empty($attribute.options)}
                                            <div class="product-attribute-switch d-flex justify-content-center flex-wrap {if !empty($attribute.has_image)}image-switch{else}text-switch{/if}">
                                                {foreach from = $attribute.options item = option key = attribute_option_id name = foreach_option}

                                                    {assign var = background_image value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
                                                    {if !empty($attribute.has_image) && !empty($option.image)}
                                                        {assign var = background_image value = "{CDN_URL}{$this->Utilities->getThumbs($option.image, 50)}"}
                                                    {/if}
                                                    
                                                    <div 
                                                        nh-attribute-option="{if !empty($option.code)}{$option.code}{/if}" 
                                                        class="inner-product-attribute" 
                                                        nh-lazy="image-background" 
                                                        {if !empty($attribute.has_image)}
                                                            data-src="{$background_image}"
                                                            data-toggle="tooltip" data-placement="top" title="" 
                                                            data-original-title="{if !empty($option.name)}{$option.name}{/if}"
                                                        {/if}>

                                                        {if !empty($option.name) && empty($attribute.has_image)}
                                                            {$option.name}
                                                        {/if}
                                                    </div>
                                                {/foreach}
                                            </div>
                                        {/if}

                                        {if $smarty.foreach.foreach_attribute.last}
                                            <a nh-btn-action="clear-attribute-option" class="reset-attribute effect-border-scale" href="javascript:;">
                                                {__d('template', 'xoa')}
                                            </a>
                                        {/if}
                                    </div>
                                {/foreach}
                            </div>

                            <div class="entire-cart d-flex flex-column align-items-center flex-wrap {if empty($product.items[0].quantity_available) && !empty($data_init.product.check_quantity)}d-none{/if}">
                                {$this->element('input_quantity')}

                                <a nh-btn-action="add-cart" href="javascript:;" class="add-to-cart added_to_cart effect-shadow">
                                    <i class="iconsax isax-shopping-cart"></i>
                                </a>
                            </div>

                            <div nh-quantity-product="out-stock" class="out-of-stock {if !empty($product.items[0].quantity_available) || empty($data_init.product.check_quantity)}d-none{/if}">
                                {__d('template', 'san_pham_het_hang')}
                            </div>
                        </div>
                    </div>
                </div>
            {/if}

            <div class="product-action">
                <a nh-btn-action="wishlist" wishlist-id="{if !empty($product.id)}{$product.id}{/if}" wishlist-type="{PRODUCT}" class="btn-product-action" href="javascript:;" data-toggle="tooltip" data-placement="top" title="{__d('template', 'yeu_thich')}">
                    <i class="iconsax isax-heart"></i>
                </a>

                {if !empty($product.total_quantity_available) || empty($data_init.product.check_quantity)}
                    <a nh-btn-action="{if !empty($product.attributes_item_special) && ($product.number_item gte 2)}select-option{else}add-cart{/if}" class="btn-product-action" href="javascript:;" data-toggle="tooltip" data-placement="top" title="{if !empty($product.attributes_item_special) && ($product.number_item gte 2)}{__d('template', 'chon_thuoc_tinh')}{else}{__d('template', 'them_gio_hang')}{/if}">
                        <i class="iconsax isax-shopping-cart"></i>
                    </a>                    
                {else}
                    <a class="btn-product-action" href="{$this->Utilities->checkInternalUrl($product.url)}" data-toggle="tooltip" data-placement="top" title="{__d('template', 'xem_chi_tiet')}">
                        <i class="iconsax isax-shopping-cart"></i>
                    </a>
                {/if}

                <a nh-btn-action="quick-view" data-product-id="{if !empty($product.id)}{$product.id}{/if}" class="btn-product-action" href="javascript:;" data-toggle="tooltip" data-placement="top" title="{__d('template', 'xem_nhanh')}">
                    <i class="iconsax isax-eye"></i>
                </a>
            </div>
        </div>
        
        <div class="inner-content">
            

            {if !empty($product.name)}
                <h4 class="product-title">
                    <a href="{$this->Utilities->checkInternalUrl($product.url)}">
                        {$product.name|escape|truncate:50:" ..."}
                    </a>
                </h4>
            {/if}

            <div class="product-rating-price">
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
            </div>   
            
            {if !empty($product.categories)}
                <div class="product-category">
                    {foreach from = $product.categories item = category}
                        {if !empty($category.status)}
                            <a {if !empty($category.url)}href="{$this->Utilities->checkInternalUrl($category.url)}"{/if}>
                                {if !empty($category.name)}
                                    {$category.name|escape|truncate:50:" ..."}
                                {/if}
                                <span class="comma-item">, </span>
                            </a>
                        {/if}
                    {/foreach} 
                </div>
            {/if}
        </div>      
    </div>
{if empty($is_slider)}
</div>
{/if}
{/strip}