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

	<ol data-toc="div.product-detail-footer" data-toc-headings="h2,h3,h4" class="mb-0"></ol>

	<div class="product-detail-head">
		<div class="row">
			<div class="col-lg-6">
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
					                        	<img class="img-fluid" src="{CDN_URL}{$image}" alt="{if !empty($product.name)}{$product.name}{/if}">
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

					        	{if !empty($all_images)}
						        	<div nh-light-gallery>
						        		{if !empty($all_images[0])}
							        		<a class="btn-addition-action btn-expand" href="{CDN_URL}{$all_images[0]}">
							        			<img alt="{if !empty($product.name)}{$product.name}{/if}" src="{CDN_URL}{$this->Utilities->getThumbs($all_images[0], 150)}" class="d-none">
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
					        	{/if}
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
												<img class="img-fluid" src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}" alt="{if !empty($product.name)}{$product.name}{/if}">
											</div>
										{/foreach}
									{/if}
								</div>
							</div>
						{/if}
					</div>		        
			    </div>
			</div>

			<div class="col-lg-6">
				<div nh-product-detail nh-product="{if !empty($product.id)}{$product.id}{/if}" nh-product-item-id="{if !empty($first_item)}{$first_item.id}{/if}" nh-product-attribute-special="{if !empty($product.attributes_item_special)}{htmlentities($product.attributes_item_special|@json_encode)}{/if}" class="product-content-detail">

                    {if !empty($product.name)}
    					<h2 class="product-title-detail">
    						{$product.name|escape}
    		            </h2>
    	            {/if}
    	            
    	            {assign var = rating value = 0}
                    {if !empty($product.rating)}
                        {assign var = rating value = $product.rating}
                    {/if}
                    {assign var = percen_rating value = ($rating/5)*100}
    	            {*<div class="product-rating d-flex align-items-center flex-nowrap">
    	                <div class="star-rating">
    	                    <span style="width:{$percen_rating}%"></span>
    	                </div>
    	                <div class="inner-number-rating">
    	                    {if !empty($product.rating_number)}{$product.rating_number}{else}0{/if} đánh giá
    	                </div>
    	            </div>*}
                    
                    {if !empty($product.attributes.motangan.value)}
		                <div class="product-description-detail mb-15">
		                    {*<div class="inner-title">
		                        Mô tả ngắn
		                    </div>*}
		                    <div class="inner-content">
		                        {$product.attributes.motangan.value}
		                    </div>
		                </div>
	                {/if}
                    
                    <div class="price">
		            	{if empty($first_item.apply_special) && !empty($first_item.price)}
			                <span nh-label-price="{$first_item.price}" class="price-amount fs-16 fs-md-21 color-hover">
			                    <span nh-label-value>
			                        {$first_item.price|number_format:0:".":","}
			                    </span>                    
			                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
			                </span>
		                {/if}

		                {if !empty($first_item.apply_special) && !empty($first_item.price_special)}
		                	<span nh-label-price="{$first_item.price_special}" class="price-amount fs-14 fs-md-23">
			                    <span nh-label-value>
			                        {$first_item.price_special|number_format:0:".":","}
			                    </span>                    
			                    <span class="currency-symbol">{CURRENCY_UNIT}</span>
			                </span>
		                {/if}

		                {if !empty($first_item.price) && !empty($first_item.apply_special)}
		                    <span nh-label-price-special="{$first_item.price}" class="price-amount old-price fs-14 fs-md-21">
		                        <span nh-label-value>
		                            {$first_item.price|number_format:0:".":","}
		                        </span>
		                        <span class="currency-symbol">{CURRENCY_UNIT}</span>
		                    </span>
		                {/if}
		            </div>
		            
		            {if !empty($product.status == 2)}
		            	<div  class="out-of-stock">
			                {__d('template', 'san_pham_ngung_kinh_doanh')}
			            </div>
			        {else}
			            {if !empty($product.attributes_item_apply)}
			                <div class="entire-attribute">
			                    {foreach from = $product.attributes_item_apply item = attribute key = attribute_id name = foreach_attribute}
			                        <div nh-attribute="{if !empty($attribute.code)}{$attribute.code}{/if}" class="list-attribute d-flex flex-column  bg-white rounded mb-10 py-10 px-15 ">
			                            <div class="mb-10 d-flex align-items-center justify-content-between">
			                                {if !empty($attribute.name)}
    			                                <p class="mb-0">
    			                                    {$attribute.name}:
    			                                </p>
    			                            {/if}
                                            
    		                                <a nh-btn-action="clear-attribute-option" class="reset-attribute effect-border-scale" href="javascript:;">
    		                                    {__d('template', 'xoa')}
    		                                </a>
			                            </div>
			                            
			                            {if !empty($attribute.options)}
			                                <div class="product-attribute-switch d-flex justify-content-start {if !empty($attribute.has_image)}image-switch{else}text-switch{/if}">
			                                    {foreach from = $attribute.options item = option key = attribute_option_id name = foreach_option}
			                                        {assign var = background_image value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
			                                        {if !empty($attribute.has_image) && !empty($option.image)}
			                                            {assign var = background_image value = "{CDN_URL}{$this->Utilities->getThumbs($option.image, 50)}"}
			                                        {/if}
			                                        
			                                        <div nh-attribute-option="{if !empty($option.code)}{$option.code}{/if}" class="inner-product-attribute" {if !empty($attribute.has_image)}style="background-image: url('{$background_image}'); background-color: #fff;background-repeat: no-repeat;background-size: contain;" data-toggle="tooltip" data-placement="top" title="" data-original-title="{if !empty($option.name)}{$option.name}{/if}"{/if} data-trigger="{if !empty($attribute.has_image) && !empty($option.image)}{CDN_URL}{$this->Utilities->getThumbs($option.image, 150)}{/if}">
			                                            {if !empty($option.name) && empty($attribute.has_image)}
			                                                {$option.name}
			                                            {/if}
			                                        </div>
			                                    {/foreach}
			                                </div>
			                            {/if}
			                        </div>
			                    {/foreach}
			                </div>
			            {/if}
			            <div class="entire-cart {if isset($first_item.quantity_available) && $first_item.quantity_available <= 0 && !empty($data_init.product.check_quantity)}d-none{/if}">
			                <div class="d-flex flex-wrap align-items-center mb-15">
			                    <div class="fs-16 fw-700 color-main mr-20">
			                        CÒN HÀNG
			                    </div>
			                    {$this->element('input_quantity')}
			                </div>
			                
			                <div class="row mt-30">
			                    <div class="col-lg-6 mb-15">
			                        <a dc-btn-action="add-cart" dc-redirect="/dat-hang" data-product="{if !empty($product)}{htmlentities($product|@json_encode)}{/if}" href="javascript:;" class="button-buy-now btn-ani">
        			                    <i class="iconsax isax-bag-2"></i> Mua hàng
        			                </a>
			                    </div>
			                    <div class="col-lg-6 mb-15">
			                        {if !empty($data_extend['locale'][{LANGUAGE}]['fanpage'])}
    			                        <a href="{$this->Block->getLocale('fanpage', $data_extend)}" class="edu-btn edu-btn-blue w-100 text-center fs-16" target="_blank">
            			                    Tư Vấn Trên Facebook
            			                </a>
        			                {/if}
			                    </div>
			                </div>
			            </div>

			            <div nh-quantity-product="out-stock" class="out-of-stock {if (isset($first_item.quantity_available) && $first_item.quantity_available > 0) || empty($data_init.product.check_quantity)}d-none{/if}">
			                {__d('template', 'san_pham_het_hang')}
			            </div>
			            
			            <div class="inner-info-contact">
			                <div class="row g-3 mt--20">
			                    {if !empty($data_extend['locale'][{LANGUAGE}]['youtube'])}
    			                    <div class="col-lg-3 col-md-3 col-sm-6 col-6 mt-0 mb-20">
                                        <div class="edu-counterup p-15">
                                            <a href="{$this->Block->getLocale('youtube', $data_extend)}" target="_blank">
                                                <div class="inner">
                                                    <div class="icon mb-10">
                                                        <img src="https://cdn.meduc.vn/media/core/icons/youtube.png" style="">
                                                    </div>
                                                    <div class="content">
                                                        <span>Youtube</span>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                {/if}
                                {if !empty($data_extend['locale'][{LANGUAGE}]['group_facebook'])}
    			                    <div class="col-lg-3 col-md-3 col-sm-6 col-6 mt-0 mb-20">
                                        <div class="edu-counterup p-15">
                                            <a href="{$this->Block->getLocale('group_facebook', $data_extend)}" target="_blank">
                                                <div class="inner">
                                                    <div class="icon mb-10">
                                                        <img src="https://cdn.meduc.vn/media/pngtree-friends-group-users-team-blue-dotted-line-line-icon-png-image_1655482.jpg" style="">
                                                    </div>
                                                    <div class="content">
                                                        <span>Group FB</span>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                {/if}
                                {if !empty($data_extend['locale'][{LANGUAGE}]['fanpage'])}
    			                    <div class="col-lg-3 col-md-3 col-sm-6 col-6 mt-0 mb-20">
                                        <div class="edu-counterup p-15">
                                            <a href="{$this->Block->getLocale('fanpage', $data_extend)}" target="_blank">
                                                <div class="inner">
                                                    <div class="icon mb-10">
                                                        <img src="https://cdn.meduc.vn/media/core/icons/facebook.png" style="">
                                                    </div>
                                                    <div class="content">
                                                        <span>Fanpage FB</span>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                {/if}
                                {if !empty($data_extend['locale'][{LANGUAGE}]['group_zalo'])}
    			                    <div class="col-lg-3 col-md-3 col-sm-6 col-6 mt-0 mb-20">
                                        <div class="edu-counterup p-15">
                                            <a href="{$this->Block->getLocale('group_zalo', $data_extend)}" target="_blank">
                                                <div class="inner">
                                                    <div class="icon mb-10">
                                                        <img src="https://cdn.meduc.vn/media/core/icons/icon-zalo.svg" style="">
                                                    </div>
                                                    <div class="content">
                                                        <span>Group Zalo</span>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>
                                    </div>
                                {/if}
			                </div>
			            </div>
		            {/if}
				</div>
			</div>
		</div>
	</div>
	
	<div class="product-detail-footer">
	    <ul class="nav" role="tablist">
	        {if !empty($product.attributes.motakhoahoc.value)}
        	  	<li class="nav-item">
        	  	    <a class="nav-link active" data-toggle="pill" href="#motakhoahoc" role="tab" aria-controls="motakhoahoc" aria-selected="true">
        	    		Thông tin chi tiết
        	    	</a>
        	  	</li>
    	  	{/if}
    	  	{if !empty($product.attributes.huongdansudung.value)}
    		  	<li class="nav-item">
    		  	    <a nh-to-anchor="huongdansudung" class="nav-link" href="javascript:;">
    		    		Hướng dẫn sử dụng
    		    	</a>
    		  	</li>
    	  	{/if}
    	  	{if !empty($product.attributes.thongsokythuat.value)}
    		  	<li class="nav-item">
    		  	    <a nh-to-anchor="thongsokythuat" class="nav-link" href="javascript:;">
    		    		Thông số kỹ thuật
    		    	</a>
    		  	</li>
    	  	{/if}
    	</ul>
	</div>
	
	{if !empty($product.attributes.motakhoahoc.value)}
	  	<div class="my-30 product-text-detail" nh-anchor="motakhoahoc">
			<div>
				{$product.attributes.motakhoahoc.value}
			</div>
	  	</div>
  	{/if}
  	{if !empty($product.attributes.huongdansudung.value)}
  	    <div class="my-30 product-text-detail" nh-anchor="huongdansudung">
	  	    <div class="title-section-2">
				<span>
					Hướng dẫn sử dụng
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
					Thông số kỹ thuật
				</span>
			</div>
			<div>
				{$product.attributes.thongsokythuat.value}
			</div>
	  	</div>
  	{/if}
{else}
	<p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}