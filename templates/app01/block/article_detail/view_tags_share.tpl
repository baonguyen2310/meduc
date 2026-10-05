{assign var = article_info value = []}
{if !empty($data_block.data)}
	{assign var = article_info value = $data_block.data}
{/if}
{if !empty($article_info)}
	{strip}
	<div class="article-entry-info mb-15">
	    <ul class="blog-meta">
	        {if !empty($article_info.created)}
            <li><i class="icon-calendar-2-line"></i> {$article_info.created}</li>
            {/if}
        </ul>

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
    
    {if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
        <div class="my-15 color-main fw-bold fs-14">
            {$this->Block->getLocale('mo_ta', $data_extend)|nl2br}
        </div>
    {/if}
	
	<div class="row border-top border-bottom align-items-center pt-10 pb-10">
    	<div class="col-12 col-md-7">
    		{if !empty($article_info.tags)}
	    		<div class="d-flex align-items-center flex-wrap">
	                <ul class="tags list-unstyled mb-0">
				        {foreach from = $article_info.tags item = tag}
				        	{if !empty($tag.name)}
							    <li>
							        <a href="{if !empty($tag.url)}{TAG_PATH}/{$tag.url}{/if}">
							        	{$tag.name}
							        </a>
							    </li>
							{/if}
				        {/foreach}
					</ul>
	    		</div>
    		{/if}
    	</div>
    	
    	<div class="col-12 col-md-5">
    		{if !empty($article_info.url)}

	            {assign var = url_article value = "{$this->Utilities->getUrlWebsite()}{$this->Utilities->checkInternalUrl($article_info.url)}"}
	            <div class="social-share d-flex align-items-center justify-content-end flex-wrap">
	                <span class="share-title">
	                    <b>{__d('template', 'chia_se')}: </b>
	                </span>
	                <div class="list-social">
                        <div class="btn-social facebook-icon">
                            <a href="javascript:;" nh-link-redirect="https://www.facebook.com/sharer/sharer.php?u={$url_article}" target="_blank" title="Facebook">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/facebook-f.svg", 
		                            'alt' => "{__d('template', 'facebook')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social twitter-icon">
                            <a href="javascript:;" nh-link-redirect="https://twitter.com/share?url={$url_article}" target="_blank" title="Twitter">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/twitter.svg", 
		                            'alt' => "{__d('template', 'twitter')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social google-icon">
                            <a href="javascript:;" nh-link-redirect="https://plus.google.com/share?url={$url_article}" target="_blank" title="Google+">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/google-plus.svg", 
		                            'alt' => "{__d('template', 'google')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social pinterest-icon">
                            <a href="javascript:;" nh-link-redirect="https://pinterest.com/pin/create/button/?url={$url_article}" target="_blank" title="Pinterest">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/pinterest-p.svg", 
		                            'alt' => "{__d('template', 'pinterest')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>

                        <div class="btn-social linkedin-icon">
                            <a href="javascript:;" nh-link-redirect="https://www.linkedin.com/shareArticle?mini=true&amp;url={$url_article}" target="_blank" title="LinkedIn">
                            	{$this->LazyLoad->renderImage([
		                            'src' => "{URL_TEMPLATE}assets/img/icon/linkedin.svg", 
		                            'alt' => "{__d('template', 'linkedin')}",
		                            'class' => 'img-fluid svg-white'
		                        ])}
                            </a>
                        </div>
                    </div>
	            </div>
            {/if}
    	</div>
    </div>
	{/strip}
{/if}