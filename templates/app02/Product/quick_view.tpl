
{strip}
<a href="javascript:;" class="quickview-close effect-rotate icon-close fs-48" data-dismiss="modal">
    <i class="iconsax isax-add"></i>
</a>
<div class="row no-gutters">
    <div class="col-lg-6 col-12">
        <div class="product-image-detail">
            {assign var = config_owl_quickview value = [
                'slidesToShow' => 1,
                'slidesToScroll' => 1,
                'arrows' => true
            ]}
            <div nh-owl-slick="{htmlentities($config_owl_quickview|@json_encode)}" class="slider-main">
                {if !empty($product.all_images)}
                    {foreach from = $product.all_images item = image}
                    <div>
                        <div class="inner-image rti-100 position-relative">
                            <img class="img-fluid rti-abs-cover" src="{CDN_URL}{$image}">
                        </div>
                    </div>
                    {/foreach}
                {/if}

                {if !empty($product.url_video) && !empty($product.type_video)}
                    {if $product.type_video == {VIDEO_YOUTUBE}}
                    <div>
                        <div class="inner-iframe rti-100 position-relative">
                            <iframe class="rti-abs-cover" src="https://www.youtube.com/embed/{$product.url_video}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                    </div>                    
                    {/if}

                    {if $product.type_video == {VIDEO_SYSTEM}}
                    <div>
                        <div class="inner-video position-relative rti-100">
                            <video controls class="rti-abs-contain rti-abs-cover">
                                <source src="{CDN_URL}{$product.url_video}" type="video/mp4">
                            </video>
                        </div>
                    </div>
                    {/if}
                {/if}                
            </div>
        </div>
    </div>

    <div class="col-lg-6 col-12">
        {assign var = first_item value = []}
        {if !empty($product.items.0)}
            {assign var = first_item value = $product.items.0}
        {/if}

        <div nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item.id)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}" class="quickview-info product-content-detail">
            <h1 class="product-title-detail font-weight-bold fs-21 mb-5">
                {if !empty($product.name)}
                    {$product.name|escape}
                {/if}
            </h1>

            <div class="product-rating d-flex align-items-center flex-nowrap">
                <div class="star-rating mr-15">
                    <span style="width:100%"></span>
                </div>
                <div class="review-link">
                    {if !empty($product.comment)}
                        (<span class="count">
                            {$product.comment|number_format:0:".":","}
                        </span> 
                        {__d('template', 'khach_hang_da_binh_luan')})
                    {else}
                        ({__d('template', 'chua_co_binh_luan_nao')})
                    {/if}
                </div>
            </div>

            <div class="price mb-15">
                {if empty($first_item.apply_special) && !empty($first_item.price)}
                    <span nh-label-price="{$first_item.price}" class="price-amount">
                        <span nh-label-value>
                            {$first_item.price|number_format:0:".":","}
                        </span>                    
                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
                    </span>
                {/if}
                
                {if !empty($first_item.apply_special) && !empty($first_item.price_special)}
                    <span nh-label-price="{$first_item.price_special}" class="price-amount">
                        <span nh-label-value>
                            {$first_item.price_special|number_format:0:".":","}
                        </span>                    
                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
                    </span>
                {/if}

                {if !empty($first_item.price) && !empty($first_item.apply_special)}
                    <span nh-label-price-special="{$first_item.price}" class="price-amount old-price">
                        <span nh-label-value>
                            {$first_item.price|number_format:0:".":","}
                        </span>
                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
                    </span>
                {/if}
            </div>
            
            <div class="product-meta">
                {if !empty($first_item.code)}
                    <div class="code">
                        <label>
                            <b>{__d('template', 'ma_san_pham')}: </b>
                        </label>
                        <span nh-label-code="{if !empty($first_item.code)}{$first_item.code}{/if}">
                            {if !empty($first_item.code)}
                                {$first_item.code}
                            {/if}
                        </span>
                    </div>
                {/if}

                {if !empty($product.categories)}
                    <div class="product-category">
                        <label>
                            <b>{__d('template', 'danh_muc')}: </b> 
                        </label>

                        {foreach from = $product.categories item = category}
                            <a href="/{if !empty($category.url)}{$category.url}{/if}" class="fs-13 ml-5">
                                {if !empty($category.name)}
                                    {$category.name|escape}
                                {/if}
                                <span class="comma-item">, </span>
                            </a>
                        {/foreach}
                    </div>
                {/if}
            </div>

            <hr />
   
            {if !empty($product.attributes_item_apply)}
                <div class="entire-attribute">
                    {foreach from = $product.attributes_item_apply item = attribute key = attribute_id name = foreach_attribute}
                        <div nh-attribute="{if !empty($attribute.code)}{$attribute.code}{/if}" class="list-attribute d-flex align-items-center flex-nowrap">
                            {if !empty($attribute.name)}
                                <label>
                                    <b>
                                        {$attribute.name}:
                                    </b>
                                </label>
                            {/if}

                            {if !empty($attribute.options)}
                                <div class="product-attribute-switch d-flex justify-content-start {if !empty($attribute.has_image)}image-switch{else}text-switch{/if}">
                                    {foreach from = $attribute.options item = option key = attribute_option_id name = foreach_option}
                                        {assign var = background_image value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
                                        {if !empty($attribute.has_image) && !empty($option.image)}
                                            {assign var = background_image value = "{CDN_URL}{$this->Utilities->getThumbs($option.image, 50)}"}
                                        {/if}
                                        
                                        <div nh-attribute-option="{if !empty($option.code)}{$option.code}{/if}" class="inner-product-attribute" {if !empty($attribute.has_image)}style="background-image: url('{$background_image}');" data-toggle="tooltip" data-placement="top" title="" data-original-title="{if !empty($option.name)}{$option.name}{/if}"{/if}>
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
            {/if}
            
            {if !empty($product.price)}
                <div class="entire-cart d-flex flex-wrap {if empty($first_item.quantity_available) && !empty($data_init.product.check_quantity)}d-none{/if}">
                    {$this->element('input_quantity')}
    
                    <a nh-btn-action="add-cart" href="javascript:;" class="add-to-cart bg-main btn-1a color-white d-inline-block font-weight-bold py-10 rounded text-center text-uppercase w-100">
                        {__d('template', 'them_gio_hang')}
                    </a>
                </div>
            {else}
                <span class="fs-16 fs-lg-20 color-red font-weight-bold">
                    {__d('template', 'lien_he')}
                </span>
            {/if}

            <div nh-quantity-product="out-stock" class="out-of-stock {if !empty($first_item.quantity_available) || empty($data_init.product.check_quantity)}d-none{/if}">
                {__d('template', 'san_pham_het_hang')}
            </div>

            <hr />

            <div class="product-description mb-20">
                {if !empty($product.description)}
                    {$product.description}
                {/if}
            </div>

            {if !empty($product.url)}
                {assign var = url_product value = "{$this->getRequest()->scheme()}://{$this->getRequest()->host()}/{$product.url}"}
                <div class="social-share d-flex align-items-center flex-wrap">
                    <span class="share-title">
                        <label>
                            <b>{__d('template', 'chia_se')}: </b>
                        </label>
                    </span>

                    <div class="list-social">
                        <div class="btn-social facebook-icon">
                            <a href="https://www.facebook.com/sharer/sharer.php?u={$url_product}" target="_blank" title="Facebook">
                                {$this->LazyLoad->renderImage([
                                    'src' => "{URL_TEMPLATE}assets/img/icon/facebook-f.svg", 
                                    'alt' => "{__d('template', 'facebook')}",
                                    'class' => 'img-fluid svg-white'
                                ])}
                            </a>
                        </div>

                        <div class="btn-social twitter-icon">
                            <a href="https://twitter.com/share?url={$url_product}" target="_blank" title="Twitter">
                                {$this->LazyLoad->renderImage([
                                    'src' => "{URL_TEMPLATE}assets/img/icon/twitter.svg", 
                                    'alt' => "{__d('template', 'twitter')}",
                                    'class' => 'img-fluid svg-white'
                                ])}
                            </a>
                        </div>

                        <div class="btn-social google-icon">
                            <a href="https://plus.google.com/share?url={$url_product}" target="_blank" title="Google+">
                                {$this->LazyLoad->renderImage([
                                    'src' => "{URL_TEMPLATE}assets/img/icon/google-plus.svg", 
                                    'alt' => "{__d('template', 'google')}",
                                    'class' => 'img-fluid svg-white'
                                ])}
                            </a>
                        </div>

                        <div class="btn-social pinterest-icon">
                            <a href="https://pinterest.com/pin/create/button/?url={$url_product}" target="_blank" title="Pinterest">
                                {$this->LazyLoad->renderImage([
                                    'src' => "{URL_TEMPLATE}assets/img/icon/pinterest-p.svg", 
                                    'alt' => "{__d('template', 'pinterest')}",
                                    'class' => 'img-fluid svg-white'
                                ])}
                            </a>
                        </div>

                        <div class="btn-social linkedin-icon">
                            <a href="https://www.linkedin.com/shareArticle?mini=true&amp;url={$url_product}" target="_blank" title="LinkedIn">
                                {$this->LazyLoad->renderImage([
                                    'src' => "{URL_TEMPLATE}assets/img/icon/linkedin.svg", 
                                    'alt' => "{__d('template', 'linkedin')}",
                                    'class' => 'img-fluid svg-white'
                                ])}
                            </a>
                        </div>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>
{/strip}