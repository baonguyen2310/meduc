{strip}
{if !empty($data_block.data)}
<table class="table responsive-table">
    <thead>
        <tr>
            <th>{__d('template', 'anh')}</th>
            <th>{__d('template', 'bai_viet')}</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        {foreach from = $data_block.data item = article}
            {if !empty($article.image_avatar)}
                {assign var = url_img value = "{CDN_URL}{$this->Utilities->getThumbs($article.image_avatar, 350)}"}
            {else}
                {assign var = url_img value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}
            <tr>
                <th data-title="{__d('template', 'anh')}" scope="row" class="clearfix w-lg-40">
                    <a href="{$this->Utilities->checkInternalUrl($article.url)}" title="{$article.name}">
                        <div class="position-relative rti-25 w-25">
                            {$this->LazyLoad->renderImage([
                                'src' => $url_img, 
                                'alt' => $article.name, 
                                'class' => 'img-fluid rti-abs-cover'
                            ])}
                        </div>
                    </a>
                </th>

                <td data-title="{__d('template', 'bai_viet')}:">
                    {if !empty($article.name)}
                        <a href="{$this->Utilities->checkInternalUrl($article.url)}" title="{$article.name}">{$article.name}
                        </a>
                    {/if}
                </td>

                <td>
                    <span class="remove-item" wishlist-remove="{if !empty($article.id)}{$article.id}{/if}" wishlist-type="{ARTICLE}">
                        <i class="iconsax isax-lg isax-trash"></i>
                    </span>
                </td>
            </tr>
        {/foreach}
    </tbody>
</table>
{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}
{/strip}