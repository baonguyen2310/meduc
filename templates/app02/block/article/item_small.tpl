{strip}
<article class="article-item d-flex clearfix">
    <div class="item-left">
        <div class="inner-image rounded overflow-hidden">
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
    </div>
    
    <div class="inner-content pl-15">

        {if !empty($article.name)}   
            <h4 class="article-title">
                <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
                    {$article.name|escape|truncate:100:" ..."}
                </a>
            </h4>  
        {/if}

        {if !empty($article.categories)}
            <span class="article-category bg-white rounded py-5 px-10 border">
                {foreach from = $article.categories item = category}
                    {if !empty($category.name)}
                        <a class="fs-11" href="{$this->Utilities->checkInternalUrl($category.url)}">
                            {$category.name|escape|truncate:50:" ..."}
                            <span class="comma-item">, </span>
                        </a>
                    {/if}
                {/foreach}
            </span>
        {/if}
    </div>  
</article>
{/strip}