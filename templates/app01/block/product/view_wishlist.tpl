{strip}
{if !empty($data_block.data)}
<table class="table responsive-table">
    <thead>
        <tr>
            <th>{__d('template', 'san_pham')}</th>
            <th>{__d('template', 'gia')}</th>
            <th></th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        {foreach from = $data_block.data item = product}
            {if !empty($product['all_images'][0])}
                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][0], 350)}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}
            <tr>
                <th scope="row" class="clearfix w-lg-40">
                    <a class="d-flex align-items-center" href="{$this->Utilities->checkInternalUrl($product.url)}" title="{$product.name}">
                        <div class="float-left position-relative rti-25 w-25">
                            {$this->LazyLoad->renderImage([
                                'src' => $url_img, 
                                'alt' => $product.name, 
                                'class' => 'img-fluid rti-abs-cover'
                            ])}
                        </div>
                        {if !empty($product.name)}
                            <div class="float-left pl-15 w-75">
                                {$product.name|escape|truncate:50:" ..."}
                            </div>
                        {/if}
                    </a>
                </th>

                <td data-title="{__d('template', 'gia')}:">
                    <div class="price">&nbsp;                        
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
                </td>

                <td data-title="&nbsp;" nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($product.items[0])}{$product.items[0].id}{/if}">
                    {if !empty($product.total_quantity_available) || empty($data_init.product.check_quantity)}
                        {if !empty($product.attributes_item_special) && ($product.number_item gte 2)}
                            <a class="btn-product-action" href="{$this->Utilities->checkInternalUrl($product.url)}">
                                <i class="iconsax isax-lg isax-shopping-cart"></i> {__d('template', 'chon_thuoc_tinh')}
                            </a>
                        {else}
                            <a nh-btn-action="add-cart" class="btn-product-action" href="javascript:;">
                                <i class="iconsax isax-lg isax-shopping-cart"></i> {__d('template', 'them_gio_hang')}
                            </a>                    
                        {/if}
                    {else}
                        <a class="btn-product-action" href="{$this->Utilities->checkInternalUrl($product.url)}">
                            <i class="iconsax isax-lg isax-eye"></i> {__d('template', 'xem_chi_tiet')}
                        </a>
                    {/if}    
                    {if isset($product.total_quantity_available) && $product.total_quantity_available <= 0 && !empty($data_init.product.check_quantity)}
                        <div class="font-danger">
                            ({__d('template', 'het_hang')})
                        </div>
                    {/if} 
                </td>

                <td>
                    <span class="remove-item" wishlist-remove="{if !empty($product.id)}{$product.id}{/if}" wishlist-type="{PRODUCT}">
                        <i class="iconsax isax-lg isax-trash"></i>
                    </span>
                </td>
            </tr>
        {/foreach}
    </tbody>
</table>
{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}
{/strip}