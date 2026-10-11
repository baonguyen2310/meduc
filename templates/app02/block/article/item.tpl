{strip}
{if empty($is_slider)}
    <div class="{if !empty($col)}{$col}{else}col-12 col-sm-6 col-md-4 col-lg-4 col-xl-4{/if}">
{/if}

<article class="article-item mb-30">
    <div class="inner-image mb-15 position-relative">
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
        <div class="ratio-1-1">
            {if !empty($article.image_avatar)}
                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}
        
            <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{if !empty($article.name)}{$article.name}{/if}">
                {$this->LazyLoad->renderImage([
                    'src' => $url_img, 
                    'alt' => "{if !empty($article.name)}{$article.name}{/if}", 
                    'class' => 'img-fluid'
                ])}
            </a>
        </div>
    </div>
    <div class="inner-content">
        {if !empty($article.name)}   
            <h4 class="article-title">
                <a href="
                {if !empty($article.url)}
                    {$this->Utilities->checkInternalUrl($article.url)}
                {/if}">
                    {$article.name|escape|truncate:50:" ..."}
                </a>
            </h4>  
        {/if}

        <div class="article-entry-info">
            {if !empty($article.created)}
                <span class="post-date">
                    {$this->Utilities->convertIntgerToDateString($article.created)}
                </span>
            {/if}

            {if !empty($article.categories)}
                <span class="article-category">
                    {foreach from = $article.categories item = category}
                        {if !empty($category.name)}
                            <a href="{$this->Utilities->checkInternalUrl($category.url)}">
                                {$category.name|escape|truncate:50:" ..."}
                                <span class="comma-item">, </span>
                            </a>
                        {/if}
                    {/foreach}
                </span>
            {/if}
        </div>

        {if !empty($article.description)}
            <div class="article-description">
                {$article.description|strip_tags|truncate:150:" ..."}
            </div>
        {/if}

        <a class="read-more" href="
        {if !empty($article.url)}
            {$this->Utilities->checkInternalUrl($article.url)}
        {/if}">
            {__d('template', 'xem_them')}
        </a>
    </div>  
</article>

{if empty($is_slider)}
	</div>
{/if}
{/strip}