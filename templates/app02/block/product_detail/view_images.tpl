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

{assign var = attributes value = []}
{if !empty($product.attributes)}
	{assign var = attributes value = $product.attributes}
{/if}
{if !empty($product)}
	{strip}

	<div class="product-image-detail">
		<div class="row">
			<div class="col-lg-12 col-12 product-image-detail-top mb-lg-10 mb-0">
		        {assign var = config_slider value = [
					'slidesToShow' => 1,
					'slidesToScroll' => 1,
					'infinite' => false,
					'fade' => true,
					'arrows' => false,
					'asNavFor' => '.slider-thumbs'
		        ]}

		        <div nh-owl-slick="{htmlentities($config_slider|@json_encode)}" class="slider-main rounded-10 bg-white">
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
						'slidesToShow' => 5,
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
									'slidesToShow' => 4,
    								'slidesToScroll' => 1
								]
							],
							[
								'breakpoint' => 600,
								'settings' => [
									'vertical' => false,
									'slidesToShow' => 4,
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
								<div class="thumb-item rounded">
									<img class="img-fluid" src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}" alt="{if !empty($product.name)}{$product.name}{/if}">
								</div>
							{/foreach}
						{/if}
					</div>
				</div>
			{/if}
		</div>		        
    </div>
{/if}