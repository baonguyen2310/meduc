{strip}
<article class="article-item clearfix">
    <div class="inner-image">
        {if !empty($article.image_avatar)}
            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 150)}"}
        {else}
            {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
        {/if}

        <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" 
            title="{if !empty($article.name)}{$article.name}{/if}">
            {$this->LazyLoad->renderImage([
                'src' => $url_img, 
                'alt' => "{if !empty($article.name)}{$article.name}{/if}",
                'class' => 'img-fluid'
            ])}
        </a>
    </div>
    
    <div class="inner-content">

        {if !empty($article.name)}   
            <h4 class="article-title">
                <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
                    {$article.name|escape}
                </a>
            </h4>  
        {/if}

        <div class="article-entry-info">
            {if !empty($article.created)}
                <span class="post-date">
                    {$this->Utilities->convertIntgerToDateString($article.created)}
                </span>
            {/if}
        </div>
    </div>  
</article>
{/strip}