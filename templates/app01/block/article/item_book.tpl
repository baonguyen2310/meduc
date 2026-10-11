{strip}
{if empty($is_slider)}
    <div class="{if !empty($col)}{$col}{else}col-lg-4 col-md-6 col-sm-6 col-12 mb-30{/if}">
{/if}

<div 
    class="edu-card card-type-1 radius-small product-item-book"
>
    <div class="inner">
        <div class="thumbnail">
            {if !empty($article.image_avatar)}
                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}

            <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{if !empty($article.name)}{$article.name}{/if}">
                {$this->LazyLoad->renderImage([
                    'src' => $url_img, 
                    'alt' => "{if !empty($article.name)}{$article.name}{/if}",
                    'class' => 'w-100'
                ])}
            </a>
        </div>
        <div class="content">
            {if !empty($article.name)}
                <h6 class="title">
                    <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" title="{if !empty($article.name)}{$article.name}{/if}">
                        {$article.name|escape}
                    </a>
                </h6>
            {/if}
            <div class="card-bottom">
                {if !empty($article.description)}
                    <div class="inner-desc">
                        {$article.description}
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

{if empty($is_slider)}
	</div>
{/if}
{/strip}