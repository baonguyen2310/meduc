{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
	{strip}
	<div class="rbt-course-action-bottom">
        <div class="read-more-btn">
            <a href="/khoa-hoc" class="edu-btn w-100 text-center btn-ani">
                Tìm Hiểu Khóa Học
            </a>
        </div>
    </div>
	<article class="article-detail mb-30">
	    <div class="inner-bg-logo"></div>
	    <div class="inner-bg">
	        {if !empty($article_info.name)}
    			<h2 class="article-title-detail">
    				{$article_info.name|escape}
    			</h2>
    		{/if}
    
    		
    
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
    			    <div class="article-description box-content-detail">
    			    	{$article_info.description}
    			    </div>
    		    {/if}
    		    
    		    {if !empty($article_info.has_file)}
        		    <div class="entire-file">
        		    	{if !empty($article_info.files)}
        					{foreach from = $article_info.files item = file}
        						{*
        						{assign var = file_name value = $this->Utilities->getFileNameInUrl($file)}
        						<a href="{CDN_URL}{$this->Utilities->checkInternalUrl($file)}" download="{CDN_URL}{$this->Utilities->checkInternalUrl($file)}" class="btn btn-submit text-lowercase">
        							<i class="iconsax isax-export-1"></i> {__d('template', 'tai_xuong')} {urldecode($file_name)}
        						</a>*}
        						
        						{assign var = file_name value = $this->Utilities->getFileNameInUrl($file)}
        						
        						{if ($file_name|strstr:".pdf") || ($file_name|strstr:".PDF")}
        						    <div class="pdf-viewer" pdf-viewer data-file="https://meduc.vn/cdn{$this->Utilities->checkInternalUrl($file)}"></div>
        						{elseif $file_name|strstr:".pptx"}
        						    <div class="embed-powerpoint">
        						        <div class="inner-frame">
            						        <iframe src='https://view.officeapps.live.com/op/view.aspx?src=https://meduc.vn/cdn{$this->Utilities->checkInternalUrl($file)}' sandbox='allow-same-origin allow-scripts allow-popups allow-forms' referrerpolicy='strict-origin-when-cross-origin' frameborder='0' width='100%'></iframe>
            						    </div>
        						    </div>
        						{else}
        						    File không được hỗ trợ
        						{/if}
        					{/foreach}  
        				{/if}
        			</div>
        		{/if}
    		    
    		    {if !empty($article_info.content)}
    			    <div class="article-content box-content-detail">
    			    	{$this->LazyLoad->renderContent($article_info.content)}
    			    </div>
    		    {/if}
    	    </div>
	    </div>
	</article>
	
	<div class="article-pagi">
	    <button id="articlePrev"><i class="iconsax isax-arrow-left-2"></i> Bài trước</button>
	    <button id="articleNext">Bài tiếp <i class="iconsax isax-arrow-right-3"></i></button>
	</div>
	{/strip}
{/if}