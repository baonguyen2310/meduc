{strip}
{assign dethi value = false}
{if !empty($article.categories)}
    {foreach from = $article.categories item = category}
        {if !empty($category.id) && ($category.id == 54)}
            {assign dethi value = true}
        {/if}
    {/foreach}
{/if}
{if ($dethi == true)}
    {if empty($is_slider)}
        <div class="{if !empty($col)}{$col}{else}col-lg-6 col-md-6 col-sm-12 col-12 mb-30{/if}">
    {/if}
    
    <div class="quiz-item">
        {*{if !empty($article.image_avatar)}
            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 500)}"}
        {else}
            {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
        {/if}
        <div class="thumbnail">
            <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{if !empty($article.name)}{$article.name}{/if}">
                {$this->LazyLoad->renderImage([
                    'src' => $url_img, 
                    'alt' => "{if !empty($article.name)}{$article.name}{/if}"
                ])}
            </a>
        </div>*}
        <div class="inner-content">
            <h5 class="inner-title">
                {$article.name|escape}
            </h5>
            <div class="status-group mb-10">
                <span class="eduvibe-status status-05">
                    {if !empty($article.categories)}
                        {foreach from = $article.categories item = category}
                            {if !empty($category.name)}
                                <span>{$category.name|escape}</span>
                            {/if}
                        {/foreach}
                    {/if}
                </span>
            </div>
            <div class="blog-card-bottom">
                <ul class="blog-meta mb-10">
                    {if !empty($article.created)}
                        <li><i class="icon-calendar-2-line"></i> {$this->Utilities->convertIntgerToDateString($article.created)}</li>
                    {/if}
                    {if !empty($article.attributes.thoigianlambai.value)}
                        <li><i class="fa-regular fa-clock"></i> {$article.attributes.thoigianlambai.value} phút</li>
                    {/if}
                    {if !empty($article.attributes.danhsachcauhoi.value)}
                        {assign danhsachcauhoi value = $article.attributes.danhsachcauhoi.value|json_decode:1}
                        <li><i class="fa-regular fa-circle-question"></i> {$danhsachcauhoi|@count} câu hỏi</li>
                    {/if}
                </ul>
                
                {if !empty($article.url)}
    
    	            {assign var = url_article value = "https://meduc.vn/{$this->Utilities->checkInternalUrl($article.url)}"}
    	            <div class="social-share d-flex align-items-center flex-wrap mb-10">
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
                
                <div class="read-more-btn">
                    <a class="edu-btn btn-small w-100" href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
                        LÀM BÀI <i class="fa-regular fa-pen-to-square"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
    
    {if empty($is_slider)}
    	</div>
    {/if}
{/if}
{/strip}