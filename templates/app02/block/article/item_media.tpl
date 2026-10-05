{strip}
{if empty($is_slider)}
    <div class="{if !empty($col)}{$col}{else}col-12 col-sm-6 col-md-4 col-lg-4 col-xl-4{/if}">
{/if}

<article class="album-item mb-40">
    {if !empty($article.has_album)}
        {if !empty($article.image_avatar)}
            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
            {assign var = full_img value = "{CDN_URL}{$article.image_avatar}"}
        {else}
            {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {assign var = full_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
        {/if}

        <div nh-light-gallery class="inner-image ratio-3-2 wrp-effect-album">
            <a class="effect-image" href="{$full_img}" title="{if !empty($article.name)}{$article.name}{/if}">
                <img class="img-fluid" src="{$url_img}" alt="{if !empty($article.name)}{$article.name}{/if}">
            </a>
            {if !empty($article.images)}
                {foreach from = $article.images item = image}
                    <div class="d-none" data-src="{CDN_URL}{$image}">
                        <img src="{CDN_URL}{$this->Utilities->getThumbs($image, 150)}">
                    </div>
                {/foreach}
            {/if}
        </div>
    {elseif !empty($article.has_video)}
        {if !empty($article.image_avatar)}
            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
        {else}
            {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
        {/if}

        {if $article.type_video == {VIDEO_YOUTUBE}}
            <div nh-light-gallery class="inner-image ratio-3-2 wrp-effect-album">
                <a class="effect-video" href="https://www.youtube.com/watch?v={$article.url_video}" >
                    <img class="img-fluid" src="{$url_img}" alt="{if !empty($article.name)}{$article.name}{/if}">
                </a>
            </div>
        {/if}

        {if $article.type_video == {VIDEO_SYSTEM}}
            <div nh-light-gallery class="inner-image ratio-3-2 wrp-effect-album">
                <a class="effect-video" data-html="#video-product">
                    <img class="img-fluid" src="{$url_img}" alt="{if !empty($article.name)}{$article.name}{/if}">
                </a>
            </div>

            <div id="video-product" style="display:none;">
                <video class="lg-video-object lg-html5" controls preload="none">
                    <source src="{CDN_URL}{$article.url_video}" type="video/mp4">
                    Your browser does not support HTML5 video.
                </video>
            </div>
        {/if}
    {elseif !empty($article.has_file)}  
        {if !empty($article.image_avatar)}
            {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
        {else}
            {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
        {/if}

        <div class="inner-image ratio-3-2 wrp-effect-album">
            <a class="effect-file" href="{if !empty($article.url)}{$this->Utilities->checkInternalUrl($article.url)}{/if}" 
                title="{if !empty($article.name)}{$article.name}{/if}">
                <img class="img-fluid" src="{$url_img}" alt="{if !empty($article.name)}{$article.name}{/if}">
            </a>
        </div>
    {/if}
    
    <div class="inner-content">
        {if !empty($article.name)}   
            <h4 class="album-title">
                <a href="
                {if !empty($article.url)}
                    {$this->Utilities->checkInternalUrl($article.url)}
                {/if}">
                    {$article.name|escape|truncate:50:" ..."}
                </a>
            </h4>  
        {/if}

        <div class="album-entry-info">
            {if !empty($article.created)}
                <span class="post-date">{$this->Utilities->convertIntgerToDateString($article.created)}</span>
            {/if}

            {if !empty($article.categories)}
                <span class="album-category">
                    {foreach from = $article.categories item = category}
                        {if !empty($category.name)}
                            <a href="{$this->Utilities->checkInternalUrl($category.url)}">
                                {$category.name}
                                <span class="comma-item">, </span>
                            </a>
                        {/if}
                    {/foreach}
                </span>
            {/if}
        </div>

        {if !empty($article.description)}
            <div class="album-description">
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