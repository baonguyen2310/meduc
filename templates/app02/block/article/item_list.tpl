{strip}
<div class="{if !empty($col)}{$col}{else}col-12 col-sm-6 col-md-4 col-lg-4 col-xl-4{/if}">
    <article class="article-item bg-white rounded-10 mb-10">
    <div class="inner-image rounded-10 mb-10 position-relative">
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
        <div class="position-relative rti-75">
            {if !empty($article.image_avatar)}
                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}
        
            <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{if !empty($article.name)}{$article.name}{/if}">
                {$this->LazyLoad->renderImage([
                    'src' => $url_img, 
                    'alt' => "{if !empty($article.name)}{$article.name}{/if}", 
                    'class' => 'img-fluid rti-abs-cover '
                ])}
            </a>
        </div>
    </div>
    <div class="inner-content px-10">
        {if !empty($article.name)}   
            <h4 class="article-title font-weight-normal">
                <a class="fs-14" href="
                {if !empty($article.url)}
                    {$this->Utilities->checkInternalUrl($article.url)}
                {/if}">
                    {$article.name|escape|truncate:50:" ..."}
                </a>
            </h4>  
        {/if}
    </div>  
</article>
</div>
{/strip}