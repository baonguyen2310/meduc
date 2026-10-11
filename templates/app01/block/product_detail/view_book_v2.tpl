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
	{strip}
	<div class="product-detail-order">
	    <div class="inner-box">
	        {if !empty($all_images)}
                {foreach from = $all_images item = image key = key}
                    {if {$key == 1}}
                        <div class="inner-image">
                        	<img class="img-fluid" nh-lazy="image" data-src="{CDN_URL}{$image}" alt="Ảnh sách">
                        </div>
                    {/if}
                {/foreach}
            {/if}
            {if !empty($product.name)}
            	<div class="inner-title">
            		{$product.name|escape}
                </div>
            {/if}
            
            <div class="inner-star">
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
            
            <div class="price d-flex flex-wrap align-items-center mt-5 mb-5">
            	{if empty($first_item.apply_special) && !empty($first_item.price)}
	                <span nh-label-price="{$first_item.price}" class="price-amount fs-14 fs-md-16 color-hover">
	                    <span nh-label-value>
	                        {$first_item.price|number_format:0:".":","}
	                    </span>                    
	                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
	                </span>
                {/if}

                {if !empty($first_item.apply_special) && !empty($first_item.price_special)}
                	<span nh-label-price="{$first_item.price_special}" class="price-amount fs-14 fs-md-16">
	                    <span nh-label-value>
	                        {$first_item.price_special|number_format:0:".":","}
	                    </span>                    
	                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
	                </span>
                {/if}

                {*if !empty($first_item.price) && !empty($first_item.apply_special)}
                    <span nh-label-price-special="{$first_item.price}" class="price-amount old-price fs-14 fs-md-16">
                        <span nh-label-value>
                            {$first_item.price|number_format:0:".":","}
                        </span>
                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
                    </span>
                {/if*}
                
                {if !empty($first_item.apply_special) && !empty($first_item.discount_percent)}
                    <div class="inner-discount ml-10 fs-12">
                        -{$first_item.discount_percent|number_format:0:".":","}%
                    </div>
                {/if}
            </div>
            
            <div class="inner-buttons">
                {if !empty($product.attributes.ban_tren_tiktok.value) && ($product.attributes.ban_tren_tiktok.value == 1)}
                    <a href="{if !empty($product.attributes.link_tiktok.value)}{$product.attributes.link_tiktok.value}{/if}" target="_blank" class="inner-button inner-tiktok">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['mua_tiktok'])}
                        	{$this->Block->getLocale('mua_tiktok', $data_extend)|nl2br}
                        {/if}
                    </a>
                {/if}
                {if !empty($product.attributes.ban_tren_facebook.value) && ($product.attributes.ban_tren_facebook.value == 1)}
                    <a href="{if !empty($product.attributes.link_facebook.value)}{$product.attributes.link_facebook.value}{/if}" target="_blank" class="inner-button inner-facebook">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['mua_facebook'])}
                        	{$this->Block->getLocale('mua_facebook', $data_extend)|nl2br}
                        {/if}
                    </a>
                {/if}
                {if !empty($product.attributes.ban_tren_shopee.value) && ($product.attributes.ban_tren_shopee.value == 1)}
                    <a href="{if !empty($product.attributes.link_shopee.value)}{$product.attributes.link_shopee.value}{/if}" target="_blank" class="inner-button inner-shopee">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['mua_shopee'])}
                        	{$this->Block->getLocale('mua_shopee', $data_extend)|nl2br}
                        {/if}
                    </a>
                {/if}
            </div>
            
            <div class="entire-cart {if isset($first_item.quantity_available) && $first_item.quantity_available <= 0 && !empty($data_init.product.check_quantity)}d-none{/if}">
                <div class="d-flex flex-wrap align-items-center mb-15">
                    {$this->element('input_quantity')}
                </div>
                <a dc-btn-action="add-cart" dc-redirect="/dat-hang" data-product="{if !empty($product)}{htmlentities($product|@json_encode)}{/if}" href="javascript:;" class="edu-btn btn-small btn-ani w-100">
                    <i class="iconsax isax-bag-2"></i> Mua hàng
                </a>
            </div>
            
            {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat'])}
                <div class="inner-icon-logo">
                    {$this->LazyLoad->renderImage([
                		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat', $data_extend))}", 
                		'delay' => 'all'
                	])}
                </div>
            {/if}
	    </div>
	</div>
	<div class="product-detail-info">
	    
    	
    	<!--Tiêu đề-->
    	{if !empty($product.name)}
        	<h2 class="product-title-detail">
        		{$product.name|escape}
            </h2>
        {/if}
        <!--Hết Tiêu đề-->
    	
    	<!--Hình ảnh-->
    	<div class="product-image-detail">
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
    		                        	<img class="img-fluid" nh-lazy="image" data-src="{CDN_URL}{$image}" alt="Ảnh sách">
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
    						'slidesToShow' => 8,
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