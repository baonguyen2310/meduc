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
    {assign member_info value = $this->Member->getMemberInfo()}
	<div class="row">
	    <div class="col-xl-6 col-lg-6">
	        <!--Hình ảnh-->
        	<div class="product-image-detail mb-20">
        		<div class="row">
        			<div class="col-lg-12 col-12 product-image-detail-top">
        		        {assign var = config_slider value = [
        					'slidesToShow' => 1,
        					'slidesToScroll' => 1,
        					'infinite' => false,
        					'fade' => true,
        					'asNavFor' => '.slider-thumbs'
        		        ]}
        
        		        <div nh-owl-slick="{htmlentities($config_slider|@json_encode)}" class="slider-main">
        		            {if !empty($all_images)}
        		                {foreach from = $all_images item = image}
        		                    <div>
        		                    	<div class="inner-image">
        		                        	<img class="img-fluid" src="{CDN_URL}{$image}" alt="Ảnh sách">
        		                        </div>
        		                    </div>
        		                {/foreach}
        		            {/if}              
        		        </div>
        
        		        <div class="product-additional-action">
        		        	{if !empty($product.url_video) && !empty($product.type_video)}
        		        		{if $product.type_video == {VIDEO_YOUTUBE}}
        				        	<div nh-light-gallery>
        				        		<a href="https://www.youtube.com/watch?v={$product.url_video}" class="btn-addition-action youtube-video btn-video"></a>
        				        	</div>
        			        	{/if}
        
        			        	{if $product.type_video == {VIDEO_SYSTEM}}
        				        	<div nh-light-gallery>
        				        		<span class="btn-addition-action btn-video" data-html="#video-product"></span>
        				        	</div>
        
        				        	<div id="video-product" style="display:none;">
        							    <video class="lg-video-object lg-html5" controls preload="none">
        							        <source src="{CDN_URL}{$product.url_video}" type="video/mp4">
        							        Your browser does not support HTML5 video.
        							    </video>
        							</div>
        						{/if}
        					{/if}
        
        		        	{*if !empty($all_images)}
        			        	<div nh-light-gallery>
        			        		{if !empty($all_images[0])}
        				        		<a class="btn-addition-action btn-expand" href="{CDN_URL}{$all_images[0]}">
        				        			<img nh-lazy="image" data-src="{CDN_URL}{$this->Utilities->getThumbs($all_images[0], 150)}" class="d-none">
        				        		</a>
        			        		{/if}
        
        			        		{foreach from = $all_images key = k item = image}
        			        			{if $k > 0}
        				        			<div class="d-none" data-src="{CDN_URL}{$image}">
        					        			<img alt="{if !empty($product.name)}{$product.name}{/if}" src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}">
        					        		</div>
        			        			{/if}						        		
        			        		{/foreach}
        			        	</div>				        		
        		        	{/if*}
        		        </div>
        			</div>
        			{if $all_images|@count gt 1}
        				<div class="col-lg-12 col-12 mb-md-20">
        					{assign var = config_slider_thumbs value = [
        						'slidesToShow' => 6,
        						'slidesToScroll' => 1,
        						'vertical' => false,
        						'arrows' => true,
        						'asNavFor' => '.slider-main',
        						'focusOnSelect' => true,
        						'infinite' => false,
        						'responsive' => [
        							[
        								'breakpoint' => 992,
        								'settings' => [
        									'vertical' => false,
        									'slidesToShow' => 6,
            								'slidesToScroll' => 1
        								]
        							],
        							[
        								'breakpoint' => 600,
        								'settings' => [
        									'vertical' => false,
        									'slidesToShow' => 5,
            								'slidesToScroll' => 1
        								]
        							],
        							[
        								'breakpoint' => 480,
        								'settings' => [
        									'vertical' => false,
        									'slidesToShow' => 4,
            								'slidesToScroll' => 1
        								]
        							]
        						]
        			        ]}
        					<div nh-slider-thumbs nh-owl-slick="{htmlentities($config_slider_thumbs|@json_encode)}" class="slider-thumbs">
        						{if !empty($all_images)}
        							{foreach from = $all_images item = image}
        								<div class="thumb-item">
        									<img class="img-fluid" nh-lazy="image" data-src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}" alt="{if !empty($product.name)}{$product.name}{/if}">
        								</div>
        							{/foreach}
        						{/if}
        					</div>
        				</div>
        			{/if}
        		</div>		        
            </div>
        	<!--Hết Hình ảnh-->
	    </div>
	    <div class="col-xl-1 order-xl-0 col-lg-12 order-lg-1"></div>
	    <div class="col-xl-5 col-lg-6">
	        <!--Tiêu đề-->
        	{if !empty($product.name)}
            	<h2 class="product-title-detail">
            		{$product.name|escape}
                </h2>
            {/if}
            <!--Hết Tiêu đề-->
            
            <div class="inner-box">
                <div class="inner-star mb-20">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['so_sao'])}
                        <div class="inner-number">
                            {$this->Block->getLocale('so_sao', $data_extend)|nl2br}
                        </div>
                    {/if}
                    <div class="inner-rating">
                        <i class="fa-solid fa-star"></i>
                        <i class="fa-solid fa-star"></i>
                        <i class="fa-solid fa-star"></i>
                        <i class="fa-solid fa-star"></i>
                        <i class="fa-solid fa-star"></i>
                    </div>
                    {if !empty($data_extend['locale'][{LANGUAGE}]['so_danh_gia'])}
                        <div class="inner-number-2">
                            ({$this->Block->getLocale('so_danh_gia', $data_extend)|nl2br})
                        </div>
                    {/if}
                </div>
                
                {if !empty($product.attributes.khuyenmaiuudai.value)}
                    <div class="product-promotion">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                            <div class="product-promotion-heading">
                                <i class="fa-solid fa-gift"></i> {$this->Block->getLocale('text_1', $data_extend)|nl2br}
                            </div>
                        {/if}
                        <div class="product-promotion-content">
                            {$product.attributes.khuyenmaiuudai.value}
                        </div>
                    </div>
                {/if}
                
                <div class="price d-flex flex-wrap align-items-center mb-20">
                	{if empty($first_item.apply_special) && !empty($first_item.price)}
    	                <span nh-label-price="{$first_item.price}" class="price-amount fs-24">
    	                    <span nh-label-value>
    	                        {$first_item.price|number_format:0:".":","}
    	                    </span>                    
    	                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
    	                </span>
                    {/if}
    
                    {if !empty($first_item.apply_special) && !empty($first_item.price_special)}
                    	<span nh-label-price="{$first_item.price_special}" class="price-amount fs-24">
    	                    <span nh-label-value>
    	                        {$first_item.price_special|number_format:0:".":","}
    	                    </span>                    
    	                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
    	                </span>
                    {/if}
    
                    {if !empty($first_item.price) && !empty($first_item.apply_special)}
                        <span nh-label-price-special="{$first_item.price}" class="price-amount old-price fs-18">
                            <span nh-label-value>
                                {$first_item.price|number_format:0:".":","}
                            </span>
                            <span class="currency-symbol">{CURRENCY_UNIT}</span>
                        </span>
                    {/if}
                    
                    {if !empty($first_item.apply_special) && !empty($first_item.discount_percent)}
                        <div class="inner-discount ml-10">
                            -{$first_item.discount_percent|number_format:0:".":","}%
                        </div>
                    {/if}
                </div>
                
                <div class="entire-cart d-flex {if isset($first_item.quantity_available) && $first_item.quantity_available <= 0 && !empty($data_init.product.check_quantity)}d-none{/if}">
                    <div class="d-flex flex-wrap align-items-center mr-15">
                        {$this->element('input_quantity')}
                    </div>
                    <a dc-btn-action="add-cart" dc-redirect="/dat-hang" data-product="{if !empty($product)}{htmlentities($product|@json_encode)}{/if}" href="javascript:;" class="edu-btn btn-ani w-100 fs-16 py-5">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_4'])}{$this->Block->getLocale('text_4', $data_extend)|nl2br}{/if}
                    </a>
                    
                    <div class="rbt-course-action-bottom">
                        <h5 class="inner-title">{$product.name|escape}</h5>
                        
                        <div class="read-more-btn">
                            <button btn-add-cart-2 class="edu-btn w-100 text-center btn-ani">
                                {if !empty($data_extend['locale'][{LANGUAGE}]['text_4'])}{$this->Block->getLocale('text_4', $data_extend)|nl2br}{/if}
                            </button>
                        </div>
                        
                        <div class="read-more-btn mt--10">
                            <a href="/khoa-hoc" class="edu-btn w-100 text-center btn-ani">
                                Tìm Hiểu Khóa Học
                            </a>
                        </div>
                    </div>
                </div>
                
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
                
                {if !empty($product.attributes.combo_products.value)}
                    <div class="combo-products">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                            <div class="combo-products-heading fs-18 text-center text-uppercase">
                                {$this->Block->getLocale('text_2', $data_extend)|nl2br}
                            </div>
                        {/if}
                        <div class="combo-products-list">
                            {$comboProducts = $this->Product->getProducts([
                                'filter' => [
                                    'ids' => json_decode($product.attributes.combo_products.value, true)
                                ],
                                'get_attributes' => true
                            ])}
                            
                            {assign var = element value = "item_book"}
                            {if !empty($data_extend['element'])}
                                {assign var = element value = $data_extend['element']}
                            {/if}
                            
                            <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                                {foreach from = $comboProducts item = product}
                                    {$this->element("../block/product/{$element}", [
                                        'product' => $product, 
                                        'is_slider' => true,
                                        'type' => 'product-combo'
                                    ])}
                                {/foreach}
                            </div>
                        </div>
                    </div>
                {/if}
                
                {if !empty($product.attributes.combo_course.value)}
                    <div class="combo-products">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_3'])}
                            <div class="combo-products-heading fs-18 text-center text-uppercase">
                                {$this->Block->getLocale('text_3', $data_extend)|nl2br}
                            </div>
                        {/if}
                        <div class="combo-products-list">
                            {$comboProducts = $this->Product->getProducts([
                                'filter' => [
                                    'ids' => json_decode($product.attributes.combo_course.value, true)
                                ],
                                'get_attributes' => true
                            ])}
                            
                            {assign var = element value = "item"}
                            {if !empty($data_extend['element'])}
                                {assign var = element value = $data_extend['element']}
                            {/if}
                            
                            <div class="row justify-content-center gy-3">
                                {foreach from = $comboProducts item = product}
                                    <div class="col-xl-9 col-lg-10 col-md-12 col-12">
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
            </div>
	    </div>
	</div>
	
	<div class="product-detail-info mt-45">
    	<!--Hiển thị tabs-->
    	<div class="product-detail-footer mt-0">
    	    <ul class="nav" role="tablist">
    	        {if !empty($product.attributes.thongtinchitiet.value)}
            	  	<li class="nav-item">
            	  	    <a nh-to-anchor="thongtinchitiet" class="nav-link active" href="javascript:;">
            	    		{if !empty($data_extend['locale'][{LANGUAGE}]['muc_1'])}
                            	{$this->Block->getLocale('muc_1', $data_extend)|nl2br}
                            {/if}
            	    	</a>
            	  	</li>
        	  	{/if}
        	  	
        	  	{if !empty($product.attributes.videoreview.value)}
            	  	<li class="nav-item">
            	  	    <a nh-to-anchor="videoreview" class="nav-link" href="javascript:;">
            	    		{if !empty($data_extend['locale'][{LANGUAGE}]['muc_2'])}
                            	{$this->Block->getLocale('muc_2', $data_extend)|nl2br}
                            {/if}
            	    	</a>
            	  	</li>
        	  	{/if}
        	  	{if !empty($product.attributes.thongtinsach.value)}
            	  	<li class="nav-item">
            	  	    <a nh-to-anchor="thongtinsach" class="nav-link" href="javascript:;">
            	    		{if !empty($data_extend['locale'][{LANGUAGE}]['muc_3'])}
                            	{$this->Block->getLocale('muc_3', $data_extend)|nl2br}
                            {/if}
            	    	</a>
            	  	</li>
        	  	{/if}
        	  	
        	  	{if !empty($product.attributes.huongdansudung.value)}
        		  	<li class="nav-item">
        		  	    <a nh-to-anchor="huongdansudung" class="nav-link" href="javascript:;">
        		    		{if !empty($data_extend['locale'][{LANGUAGE}]['muc_4'])}
                            	{$this->Block->getLocale('muc_4', $data_extend)|nl2br}
                            {/if}
        		    	</a>
        		  	</li>
        	  	{/if}
        	  	{if !empty($product.attributes.thongsokythuat.value)}
        		  	<li class="nav-item">
        		  	    <a nh-to-anchor="thongsokythuat" class="nav-link" href="javascript:;">
        		    		{if !empty($data_extend['locale'][{LANGUAGE}]['muc_5'])}
                            	{$this->Block->getLocale('muc_5', $data_extend)|nl2br}
                            {/if}
        		    	</a>
        		  	</li>
        	  	{/if}
        	</ul>
    	</div>
    	<!--Hết Hiển thị tabs-->
    	
    	<!--Hiển thị nội dung chi tiết-->
    	{if !empty($product.attributes.thongtinchitiet.value)}
    	  	<div class="my-30 product-text-detail" nh-anchor="thongtinchitiet">
    	  	    <div class="title-section-2">
    				<span>
    					{if !empty($data_extend['locale'][{LANGUAGE}]['muc_1'])}
                        	{$this->Block->getLocale('muc_1', $data_extend)|nl2br}
                        {/if}
    				</span>
    			</div>
    			{if !empty($product.attributes.motangan.value)}
                    <div class="product-description-detail mb-15">
                        <div class="inner-content">
                            {$product.attributes.motangan.value}
                        </div>
                    </div>
                {/if}
    			<div>
    			    {$this->LazyLoad->renderContent($product.attributes.thongtinchitiet.value)}
    				{*$product.attributes.thongtinchitiet.value*}
    			</div>
    			<div class="text-center mt-20">
    			    <button btn-add-cart-2 class="edu-btn btn-ani">MUA SÁCH NGAY</button>
    			</div>
    	  	</div>
      	{/if}
      	
      	{if !empty($product.attributes.videoreview.value)}
    	  	<div class="my-30 product-text-detail" nh-anchor="videoreview">
    	  	    <div class="title-section-2">
    				<span>
    					{if !empty($data_extend['locale'][{LANGUAGE}]['muc_2'])}
                        	{$this->Block->getLocale('muc_2', $data_extend)|nl2br}
                        {/if}
    				</span>
    			</div>
    			<div>
    			    {$this->LazyLoad->renderContent($product.attributes.videoreview.value)}
    				{*$product.attributes.videoreview.value*}
    			</div>
    	  	</div>
      	{/if}
      	
      	{if !empty($product.attributes.thongtinsach.value)}
    	  	<div class="my-30 product-text-detail" nh-anchor="thongtinsach">
    	  	    <div class="title-section-2">
    				<span>
    					{if !empty($data_extend['locale'][{LANGUAGE}]['muc_3'])}
                        	{$this->Block->getLocale('muc_3', $data_extend)|nl2br}
                        {/if}
    				</span>
    			</div>
    			<div>
    				{$product.attributes.thongtinsach.value}
    			</div>
    	  	</div>
      	{/if}
      	
      	{if !empty($product.attributes.huongdansudung.value)}
      	    <div class="my-30 product-text-detail" nh-anchor="huongdansudung">
    	  	    <div class="title-section-2">
    				<span>
    					{if !empty($data_extend['locale'][{LANGUAGE}]['muc_4'])}
                        	{$this->Block->getLocale('muc_4', $data_extend)|nl2br}
                        {/if}
    				</span>
    			</div>
    			<div>
    				{$product.attributes.huongdansudung.value}
    			</div>
    	  	</div>
      	{/if}
      	
      	{if !empty($product.attributes.thongsokythuat.value)}
      	    <div class="my-30 product-text-detail" nh-anchor="thongsokythuat">
    	  	    <div class="title-section-2">
    				<span>
    					{if !empty($data_extend['locale'][{LANGUAGE}]['muc_5'])}
                        	{$this->Block->getLocale('muc_5', $data_extend)|nl2br}
                        {/if}
    				</span>
    			</div>
    			<div>
    				{$product.attributes.thongsokythuat.value}
    			</div>
    	  	</div>
      	{/if}
      	<!--Hết Hiển thị nội dung chi tiết-->
	</div>
{else}
	<p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}