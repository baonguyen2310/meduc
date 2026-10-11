{strip}
{if empty($is_slider)}
    <div class="{if !empty($col)}{$col}{else}col-lg-4 col-md-6 col-sm-6 col-12 mb-30{/if}">
{/if}

<div class="edu-blog blog-type-2 radius-small">
    <div class="inner">
        {if !empty($article.image_avatar)}
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
        </div>
        <div class="content">
            <div class="status-group">
                <span class="eduvibe-status status-05">
                    <i class="icon-price-tag-3-line"></i> 
                    {if !empty($article.categories)}
                        {foreach from = $article.categories item = category}
                            {if !empty($category.name)}
                                <span>{$category.name|escape}</span>
                            {/if}
                        {/foreach}
                    {/if}
                </span>
            </div>
            <h5 class="title">
                <a href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
                    {$article.name|escape}
                </a>
            </h5>
            <div class="blog-card-bottom">
                {if !empty($article.created)}
                    <ul class="blog-meta">
                        <li><i class="icon-calendar-2-line"></i> {$this->Utilities->convertIntgerToDateString($article.created)}</li>
                    </ul>
                {/if}
                <div class="read-more-btn">
                    <a class="btn-transparent" href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}">
                        Đọc thêm <i class="icon-arrow-right-line-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

{if empty($is_slider)}
	</div>
{/if}
{/strip}