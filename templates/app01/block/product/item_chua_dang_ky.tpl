{strip}

{assign var = licensed value = false}
{assign member_info value = $this->Member->getMemberInfo()}
{if !empty($member_info.code)}
    {assign var = code_member value = $member_info.code}
    {assign var = listClassRoom value = $this->Member->getListClassRoomByCustomerId($code_member)}
    
    {foreach from = $listClassRoom item = classRoom}
        {if $classRoom.product_id == $product.id}
            {assign var = licensed value = true}
            {break}
        {/if}
    {/foreach}
{/if}

{if $licensed == false}
    {if empty($is_slider)}
    <div class="{if !empty($col)}{$col}{else}col-xl-3 col-lg-3 col-md-6 col-6 mb-20{/if}">
    {/if}
        <div 
            class="edu-card card-type-1 radius-small"
            nh-product="{if !empty($product.id)}{$product.id}{/if}"
            nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}"
            nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}"
        >
            <div class="inner">
                <div class="thumbnail">
                    {if !empty($product['all_images'][0])}
                        {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][0], 350)}"}
                    {else}
                        {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
                    {/if}
    
                    <a href="{$this->Utilities->checkInternalUrl($product.url)}" title="{$product.name}">
                        {$this->LazyLoad->renderImage([
                            'src' => $url_img, 
                            'alt' => $product.name, 
                            'class' => 'w-100'
                        ])}
                    </a>
                    {if !empty($product.apply_special) && !empty($product.discount_percent)}
                        <div class="top-position status-group left-top">
                            <span class="eduvibe-status status-02">
                                <i class="fa-solid fa-bolt"></i> GIẢM -{$product.discount_percent}%
                            </span>
                        </div>
                    {/if}
                </div>
                <div class="content">
                    {if !empty($product.name)}
                        <h6 class="title">
                            <a href="{$this->Utilities->checkInternalUrl($product.url)}">
                                {$product.name|escape|truncate:50:" ..."}
                            </a>
                        </h6>
                    {/if}
                    
                    <div class="price-list price-style-01">
                        {if empty($product.apply_special) && !empty($product.price)}
                            <div class="price current-price">{$product.price|number_format:0:".":","} {CURRENCY_UNIT}</div>
                        {/if}
    
                        {if !empty($product.apply_special) && !empty($product.price_special)}
                            <div class="price current-price">{$product.price_special|number_format:0:".":","} {CURRENCY_UNIT}</div>
                        {/if}
                        
                        {if !empty($product.apply_special) && !empty($product.price)}
                            <div class="price old-price">{$product.price|number_format:0:".":","} {CURRENCY_UNIT}</div>
                        {/if}
                        
                        <div class="inner-rating">
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                        </div>
                    </div>
                    
                    <div class="card-bottom">
                        <a href="{$this->Utilities->checkInternalUrl($product.url)}" class="edu-btn btn-small btn-ani w-100">ĐĂNG KÝ & HỌC THỬ MIỄN PHÍ</a>
                    </div>
                </div>
            </div>
        </div>
    {if empty($is_slider)}
    </div>
    {/if}
{/if}

{/strip}