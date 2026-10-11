{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
	{strip}
	<article class="article-detail mb-30">
		{if !empty($article_info.name)}
			<h2 class="article-title-detail">
				{$article_info.name|escape}
			</h2>
		{/if}

		<div class="article-entry-info mb-15">
	        {if !empty($article_info.categories)}
		        {foreach from = $article_info.categories item = category}
		        	{if !empty($category.name)}
				        <span class="article-category">
				            <a href="{$this->Utilities->checkInternalUrl($category.url)}">
				            	{$category.name|escape}
				            	<span class="comma-item">, </span>
				            </a>
				        </span>
			        {/if}
		        {/foreach}
	        {/if}
	    </div>

	    {if !empty($article_info.images)}
		    <div class="article-image-detail mb-30 overflow-hidden">
		    	<div class="position-relative">
			    	{assign var = config_slider value = [
						'slidesToShow' => 1,
						'slidesToScroll' => 1,
						'infinite' => false,
						'fade' => true,
						'asNavFor' => '.slider-thumbs'
			        ]}
				    <div nh-owl-slick="{htmlentities($config_slider|@json_encode)}" class="mb-10 slider-main">
				        {foreach from = $article_info.images item = image}
				            <div>
				            	<div class="inner-image ratio-3-2">
				            		{$this->LazyLoad->renderImage([
						                'src' => "{CDN_URL}{$image}", 
						                'alt' => "{if !empty($article_info.name)}{$article_info.name}{/if}", 
						                'class' => 'img-fluid'
						            ])}
				                </div>
				            </div>
				        {/foreach}     
				    </div>

		    		<div class="product-additional-action">
			        	{if !empty($article_info.url_video) && !empty($article_info.type_video)}
			        		{if $article_info.type_video == {VIDEO_YOUTUBE}}
					        	<div nh-light-gallery>
					        		<a href="https://www.youtube.com/watch?v={$article_info.url_video}" class="btn-addition-action youtube-video btn-video"></a>
					        	</div>
				        	{/if}

				        	{if $article_info.type_video == {VIDEO_SYSTEM}}
					        	<div nh-light-gallery>
					        		<span class="btn-addition-action btn-video" data-html="#video-product"></span>
					        	</div>

					        	<div id="video-product" style="display:none;">
								    <video class="lg-video-object lg-html5" controls preload="none">
								        <source src="{CDN_URL}{$article_info.url_video}" type="video/{$article_info.url_video|pathinfo:$smarty.const.PATHINFO_EXTENSION}">
								        Your browser does not support HTML5 video.
								    </video>
								</div>
							{/if}
						{/if}

			        	{if !empty( $article_info.images)}
				        	<div nh-light-gallery>
				        		{if !empty( $article_info.images[0])}
					        		<a class="btn-addition-action btn-expand" href="{CDN_URL}{$article_info.images[0]}">
					        			<img alt="{if !empty($article_info.name)}{$article_info.name}{/if}" src="{CDN_URL}{$this->Utilities->getThumbs( $article_info.images[0], 150)}" class="d-none">
					        		</a>
				        		{/if}

				        		{foreach from =  $article_info.images key = k item = image}
				        			{if $k > 0}
					        			<div class="d-none" data-src="{CDN_URL}{$image}">
						        			<img alt="{if !empty($article_info.name)}{$article_info.name}{/if}" src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}">
						        		</div>
				        			{/if}						        		
				        		{/foreach}
				        	</div>				        		
			        	{/if}
			        </div>
		    	</div>

		    	{if count($article_info.images) >= 2}
				    {assign var = config_slider_thumbs value = [
						'slidesToShow' => 4,
						'slidesToScroll' => 1,
						'infinite' => false,
						'asNavFor' => '.slider-main',
						'focusOnSelect' => true,
						'responsive' => [
							[
								'breakpoint' => 1024,
								'settings' => [
									'slidesToShow' => 3,
    								'slidesToScroll' => 1
								]
							],
							[
								'breakpoint' => 600,
								'settings' => [
									'slidesToShow' => 2,
    								'slidesToScroll' => 1
								]
							],
							[
								'breakpoint' => 480,
								'settings' => [
									'slidesToShow' => 2,
    								'slidesToScroll' => 1
								]
							]
						]
			        ]}

			        <div nh-owl-slick="{htmlentities($config_slider_thumbs|@json_encode)}" class="slider-thumbs">
						{if !empty($article_info.images)}
							{foreach from = $article_info.images item = image}
								<div class="thumb-item">
									<img class="img-fluid" src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}" alt="{if !empty($article_info.name)}{$article_info.name}{/if}">
								</div>
							{/foreach}
						{/if}
					</div>
				{/if}
		    </div>
	    {/if} 

	    {if !empty($article_info.url_video) && !empty($article_info.type_video)}
		    <div class="mb-30">
		        {if $article_info.type_video == {VIDEO_YOUTUBE}}
		            <div class="ratio-3-2">
		                <iframe nh-lazy="iframe" data-src="https://www.youtube.com/embed/{$article_info.url_video}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
		            </div>                   
		        {/if}

		        {if $article_info.type_video == {VIDEO_SYSTEM}}
		        	<div class="ratio-3-2">
		        		<video nh-lazy="video" data-src="{CDN_URL}{$article_info.url_video}|video/{$article_info.url_video|pathinfo:$smarty.const.PATHINFO_EXTENSION}" controls></video>
		        	</div>	            
		        {/if}
		    </div>
	    {/if}

		<div {if !empty($article_info.catalogue)}nh-table-content="content"{/if}>
		    {if !empty($article_info.description)}
			    <div class="article-description">
			    	{$article_info.description}
			    </div>
		    {/if}
		    
		    {if !empty($article_info.content)}
			    <div class="article-content">
			    	{$this->LazyLoad->renderContent($article_info.content)}
			    </div>
		    {/if}
	    </div>

	    {if !empty($article_info.has_file)}
		    <div class="entire-file">
		    	{if !empty($article_info.files)}
					{foreach from = $article_info.files item = file}
						{assign var = file_name value = $this->Utilities->getFileNameInUrl($file)}
						<a href="{CDN_URL}{$this->Utilities->checkInternalUrl($file)}" download="{CDN_URL}{$this->Utilities->checkInternalUrl($file)}" class="btn btn-submit text-lowercase">
							<i class="iconsax isax-export-1"></i> {__d('template', 'tai_xuong')} {urldecode($file_name)}
						</a>
					{/foreach}  
				{/if}
			</div>
		{/if}
	</article>
	{/strip}
{/if}