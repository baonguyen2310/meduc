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
{if !empty($product)}
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
    
    <div class="eduvibe-sidebar course-details-sidebar product-detail-head__fixed" nh-product-detail nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
        <div class="inner">
            <div class="eduvibe-widget">
                {if !empty($product.attributes.videogioithieu.value)}
                    {assign var = videogioithieu value = $product.attributes.videogioithieu.value}
                    <div class="video-area">
                        <div class="thumbnail video-popup-wrapper" nh-light-gallery>
                            <a href="https://www.youtube.com/watch?v={$videogioithieu}">
                                <img class="radius-small w-100" nh-lazy="image" data-src="https://i.ytimg.com/vi/{$videogioithieu}/hqdefault.jpg">
                                <span class="video-play-btn position-to-top video-popup-activation">
                                    <span class="play-icon course-details-video-popup"></span>
                                </span>
                            </a>
                        </div>
                    </div>
                {/if}
                
                {if $licensed != true}
                    <div class="price d-flex flex-wrap align-items-center justify-content-between mt--10">
    	            	{if empty($first_item.apply_special) && !empty($first_item.price)}
    		                <span nh-label-price="{$first_item.price}" class="price-amount fs-16 fs-md-20 color-hover">
    		                    <span nh-label-value>
    		                        {$first_item.price|number_format:0:".":","}
    		                    </span>                    
    		                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
    		                </span>
    	                {/if}
    
    	                {if !empty($first_item.apply_special) && !empty($first_item.price_special)}
    	                	<span nh-label-price="{$first_item.price_special}" class="price-amount fs-18 fs-md-20">
    		                    <span nh-label-value>
    		                        {$first_item.price_special|number_format:0:".":","}
    		                    </span>                    
    		                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
    		                </span>
    	                {/if}
    
    	                {if !empty($first_item.price) && !empty($first_item.apply_special)}
    	                    <span nh-label-price-special="{$first_item.price}" class="price-amount old-price fs-14 fs-md-16">
    	                        <span nh-label-value>
    	                            {$first_item.price|number_format:0:".":","}
    	                        </span>
    	                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
    	                    </span>
    	                {/if}
    	                
    	                {if empty($first_item.price)}
    	                    <span nh-label-price-special="{$first_item.price}" class="price-amount fs-18 fs-md-23">
    	                        Liên hệ
    	                    </span>
    	                {/if}
    	            </div>
        		{/if}
        		
        		{if $licensed == true}
                    {if !empty($product.attributes.tailieudinhkem.value)}
                        {assign var = tailieudinhkem value = $product.attributes.tailieudinhkem.value|json_decode:1}
                        <h3 class="fs-18 mt--35 mb-0">Tài liệu chung</h3>
                        <div>
                            {foreach from = $tailieudinhkem item = file}
                                {assign var = file_name value = $this->Utilities->getFileNameInUrl($file)}
                                <div class="my-5">
                                    <a href="{CDN_URL}{$this->Utilities->checkInternalUrl($file)}" download="{CDN_URL}{$this->Utilities->checkInternalUrl($file)}" target="_blank" class="bg-primary py-1 fs-10 text-white px-2 rounded d-block mb-5 text-center">
                                        <i class="fas fa-file-download text-18 mr-10"></i> {urldecode($file_name)}
                                    </a>
                                </div>
                            {/foreach}
                        </div>
                    {/if}
                {/if}
        		
                <div class="eduvibe-widget-details mt--35">
                    <div class="widget-content">
                        <ul>
                            {if !empty($product.attributes.thongtingiangvien.value)}
                                {$thongtingiangvien = $this->Article->getArticles([
                                    'filter' => [
                                        'ids' => json_decode($product.attributes.thongtingiangvien.value, true)
                                    ],
                                    'get_attributes' => true
                                ])}
                                <li style="align-items: center;">
                                    <span>
                                        <i class="fa-solid fa-user-doctor"></i> Giảng viên
                                    </span>
                                    <span>
                                        <img 
                                            src="{CDN_URL}{$thongtingiangvien[0].image_avatar}" 
                                            style="
                                                width: 66px;
                                                aspect-ratio: 1/1;
                                                border-radius: 50%;
                                                object-fit: cover;
                                                margin-right: 6px;
                                            "
                                        />
                                        {$thongtingiangvien[0].name}
                                    </span>
                                </li>
                            {/if}
                            
                            {if !empty($product.attributes.thoiluong.value)}
                                <li>
                                    <span><i class="icon-time-line"></i> Thời lượng</span>
                                    <span>{$product.attributes.thoiluong.value}</span>
                                </li>
                            {/if}
                
                            {*<li>
                                <span><i class="icon-user-2"></i> Số lượng học viên</span><span>89</span>
                            </li>*}
                
                            {if !empty($product.attributes.soluongbaihoc.value)}
                                <li>
                                    <span><i class="icon-draft-line"></i> Số lượng bài học</span><span>{$product.attributes.soluongbaihoc.value}</span>
                                </li>
                            {/if}
                            
                            {if !empty($product.attributes.soluongbaitap.value)}
                                <li>
                                    <span><i class="icon-draft-line"></i> Số lượng bài tập</span><span>{$product.attributes.soluongbaitap.value}</span>
                                </li>
                            {/if}
                            
                            {if !empty($product.attributes.tailieudinhkem.value)}
                                {assign var = tailieudinhkem value = $product.attributes.tailieudinhkem.value|json_decode:1}
                                <li>
                                    <span><i class="icon-draft-line"></i> Tài liệu</span><span>{$tailieudinhkem|@count}</span>
                                </li>
                            {/if}
                            {if !empty($product.attributes.sohuu.value)}
                                <li>
                                    <span><i class="icon-calendar-2-line"></i> Sở hữu</span><span>{$product.attributes.sohuu.value}</span>
                                </li>
                            {/if}
                        </ul>
                        
                        {if $licensed != true}
                            {assign var = cart_info value = $this->Cart->getCartInfo()}
                            {assign var = has_item value = 'false'}
                            {if !empty($cart_info['items'])}
                            	{assign var = items value = $cart_info['items']}
                                {foreach from = $items item = item}
                                    {if $item.product_id == $product.id}
                                        {assign var = has_item value = 'true'}
                                    {/if}
                                {/foreach}
                            {/if}
                            
                            {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                                <div class="color-main fw-bold text-center">
                                    {$this->Block->getLocale('text_2', $data_extend)|nl2br}
                                </div>
                            {/if}
                            
                            <div class="read-more-btn mt--15">
                                <a {if $has_item == 'true'}href="/order/info"{else}nh-btn-action="add-cart" nh-redirect="/order/info" href="javascript:;"{/if} class="edu-btn w-100 text-center btn-ani">
                                    Đăng Ký Học
                                </a>
                            </div>
                            
                            {*if !empty($data_extend['locale'][{LANGUAGE}]['hien_nut_facebook']) && ($data_extend['locale'][{LANGUAGE}]['hien_nut_facebook'] == "yes")}
                                {assign website_info value = $this->Setting->getWebsiteInfo()}
                                {if !empty($website_info.facebook)}
                                    <div class="read-more-btn mt--15">
                                        <a href="https://m.me/{$website_info.facebook}" class="edu-btn edu-btn-blue w-100 text-center" target="_blank">
                                            Tư Vấn Trên Facebook
                                        </a>
                                    </div>
                                {/if}
                            {/if*}
                            {if !empty($data_extend['locale'][{LANGUAGE}]['link_zalo'])}
                            	<div class="read-more-btn mt--15 mb--15">
                                    <a href="{$this->Block->getLocale('link_zalo', $data_extend)}" class="edu-btn edu-btn-blue w-100 text-center" target="_blank">
                                        Tư Vấn Trên Zalo
                                    </a>
                                </div>
                            {/if}
                            
                            <div class="rbt-course-action-bottom" nh-product-detail nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
                                <h5 class="inner-title">{$product.name|escape}</h5>
                                
                                <div class="read-more-btn">
                                    <a {if $has_item == 'true'}href="/order/info"{else}nh-btn-action="add-cart" nh-redirect="/order/info" href="javascript:;"{/if} class="edu-btn w-100 text-center btn-ani">
                                        Đăng Ký Học
                                    </a>
                                </div>
                            </div>
                        {/if}
                        
                        {assign var = url_product value = "{$this->getRequest()->scheme()}://{$this->getRequest()->host()}/{$product.url}"}
                        
                        {if !empty($member_info.code)}
                            <div class="read-more-btn mt--15">
                                <a 
                                    href="javascript:;"
                                    button-copy-link
                                    data-link="{$url_product}?a={$member_info.code}"
                                    class="edu-btn edu-btn-blue w-100 text-center"
                                >
                                    Copy Link Affiliate
                                </a>
                            </div>
                        {/if}
                        
                        <div class="read-more-btn mt--30 text-center">
                            <div class="eduvibe-post-share">
                                <span>Share: </span>
                                <a href="https://www.facebook.com/sharer/sharer.php?u={$url_product}" target="_blank" title="Chia sẻ lên Facebook">
                                    <i class="fab fa-facebook-f"></i>
                                </a>
    
                                <a href="https://twitter.com/share?url={$url_product}" target="_blank" title="Chia sẻ lên Twitter">
                                    <i class="fab fa-twitter"></i>
                                </a>
    
                                <a href="https://pinterest.com/pin/create/button/?url={$url_product}" target="_blank" title="Chia sẻ lên Pinterest">
                                    <i class="fab fa-pinterest-p"></i>
                                </a>
    
                                <a href="https://www.linkedin.com/shareArticle?mini=true&amp;url={$url_product}" target="_blank" title="Chia sẻ lên LinkedIn">
                                    <i class="fab fa-linkedin-in"></i>
                                </a>
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div nh-product-detail nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}">
        {if $licensed != true}
            <div class="modal fade modal-trial" id="modalTrial" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title fs-18">
                                Khóa học: {$product.name|escape}
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="inner-main">
                                <div class="fs-16 fw-500">Vui lòng đăng ký khóa học để xem các video tiếp theo!</div>
                                <div class="read-more-btn mx-30 mt--15 mb--15">
                                    <a {if $has_item == 'true'}href="/order/info"{else}nh-btn-action="add-cart" nh-redirect="/order/info" href="javascript:;"{/if} class="edu-btn w-100 text-center btn-ani">
                                        Đăng Ký Học
                                    </a>
                                </div>
                                {*if !empty($data_extend['locale'][{LANGUAGE}]['hien_nut_facebook']) && ($data_extend['locale'][{LANGUAGE}]['hien_nut_facebook'] == "yes")}
                                    {assign website_info value = $this->Setting->getWebsiteInfo()}
                                    {if !empty($website_info.facebook)}
                                        <div class="read-more-btn mx-30 mt--15 mb--15">
                                            <a href="https://m.me/{$website_info.facebook}" class="edu-btn edu-btn-blue w-100 text-center" target="_blank">
                                                Tư Vấn Trên Facebook
                                            </a>
                                        </div>
                                    {/if}
                                {/if*}
                                {if !empty($data_extend['locale'][{LANGUAGE}]['link_zalo'])}
                                	<div class="read-more-btn mx-30 mt--15 mb--15">
                                        <a href="{$this->Block->getLocale('link_zalo', $data_extend)}" class="edu-btn edu-btn-blue w-100 text-center" target="_blank">
                                            Tư Vấn Trên Zalo
                                        </a>
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        {/if}
    </div>
{/if}