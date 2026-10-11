{strip}
{if empty($is_slider)}
	<div class="col-lg-3 col-md-6 col-12">
{/if}

<article class="article-item">
    <div class="inner-image position-relative">
        <div class="featured-media">
            {if !empty($article.has_album)}
                <span data-toggle="tooltip" data-placement="top" title="{__d('template', 'co_anh')}">
                    <i class="iconsax isax-image"></i>
                </span>
            {/if}

            {if !empty($article.has_video)}
                <span data-toggle="tooltip" data-placement="top" title="{__d('template', 'co_video')}">
                    <i class="iconsax isax-video-play"></i>
                </span>
            {/if}
            
            {if !empty($article.has_file)}
                <span data-toggle="tooltip" data-placement="top" title="{__d('template', 'co_tai_lieu')}">
                    <i class="iconsax isax-folder-open"></i>
                </span>
            {/if}
        </div>
        <div class="rti-130">
            {if !empty($article.image_avatar)}
                {assign var = url_img value = "{CDN_URL}{$article.image_avatar}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}
        
            <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{if !empty($article.name)}{$article.name}{/if}">
                {$this->LazyLoad->renderImage([
                    'src' => $url_img, 
                    'alt' => "{if !empty($article.name)}{$article.name}{/if}", 
                    'class' => 'img-fluid rounded rti-abs-cover'
                ])}
            </a>
        </div>
        <div class="inner-content">
            {if !empty($article.name)}   
                <h4 class="article-title mb-5">
                    <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{$article.name}">
                        {$article.name|escape|truncate:55:" ..."}
                    </a>
                </h4>  
            {/if}
            <div class="date-view d-flex justify-content-between align-items-center">
                {if !empty($article.created)}
                    <span class="post-date color-white">
                        <span class="pr-5">
                            {date("H:i", $article.created)}
                        </span>- 
                        <span class="pl-5">
                            {date("d/m/Y", $article.created)}
                        </span>
                    </span>
                {/if}
                <a class="color-white" href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{$article.name}">
                    {__d('template', 'chi_tiet')} <i class="pl-5 iconsax isax-arrow-right-1"></i>
                </a>
            </div>
        </div>
    </div>
</article>

{if empty($is_slider)}
	</div>
{/if}
{/strip}