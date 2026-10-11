{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
    {if !empty($article_info.attributes.combo_course_in_doc.value)}
        <div class="combo-products">
            {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                <div class="combo-products-heading fs-18 text-center text-uppercase">
                    {$this->Block->getLocale('text_2', $data_extend)|nl2br}
                </div>
            {/if}
            <div class="combo-products-list">
                {$comboProducts = $this->Product->getProducts([
                    'filter' => [
                        'ids' => json_decode($article_info.attributes.combo_course_in_doc.value, true)
                    ],
                    'get_attributes' => true
                ])}
                
                <div class="row justify-content-center gy-3">
                    {foreach from = $comboProducts item = product}
                        <div class="col-xl-12 col-lg-12 col-md-12 col-12">
                            <div 
                                class="edu-card card-type-1 radius-small"
                            >
                                <div class="inner">
                                    <div class="thumbnail">
                                        {if !empty($product['all_images'][0])}
                                            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($product['all_images'][0], 720)}"}
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
                                        {if !empty($product.items[0].apply_special) && !empty($product.items[0].discount_percent)}
                                            <div class="top-position status-group left-top">
                                                <span class="eduvibe-status status-02">
                                                    <i class="fa-solid fa-bolt"></i> GIẢM -{$product.items[0].discount_percent|number_format:0:".":","}%
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
                                            {if empty($product.items[0].apply_special) && !empty($product.items[0].price)}
                                                <div class="price current-price">{$product.items[0].price|number_format:0:".":","} {CURRENCY_UNIT}</div>
                                            {/if}
                        
                                            {if !empty($product.items[0].apply_special) && !empty($product.items[0].price_special)}
                                                <div class="price current-price">{$product.items[0].price_special|number_format:0:".":","} {CURRENCY_UNIT}</div>
                                            {/if}
                                            
                                            {if !empty($product.items[0].apply_special) && !empty($product.items[0].price)}
                                                <div class="price old-price">{$product.items[0].price|number_format:0:".":","} {CURRENCY_UNIT}</div>
                                            {/if}
                                            
                                            {*<div class="inner-rating">
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                                <i class="fa-solid fa-star"></i>
                                            </div>*}
                                        </div>
                                        
                                        <div class="card-bottom">
                                            <a href="{$this->Utilities->checkInternalUrl($product.url)}" class="edu-btn btn-small btn-ani w-100">ĐĂNG KÝ & HỌC THỬ MIỄN PHÍ</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/foreach}
                </div>
            </div>
        </div>
    {/if}
{/if}