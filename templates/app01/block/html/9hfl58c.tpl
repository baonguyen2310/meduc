{strip}{*assign var = urlCurrent value = $this->Utilities->getUrlCurrent()}
{assign var = slug value = $this->Utilities->checkInternalUrlTwo({$urlCurrent})*}
{assign var = slug value = $this->Utilities->getUrlPathTwo()}

{assign var = data value = $this->Utilities->getAllArticleFromSlug({$slug})}

{if !empty($data)}
    <div class="category-topic-button" id="categoryTopicButton">
        <i class="iconsax isax-menu-1"></i>
    </div>
    <div class="category-topic" id="categoryTopic">
        <ul>
            {foreach from = $data["data"] item = item}
                <li>
                    <a class="inner-title">{$item.name}</a>
                    {if !empty($item.arts)}
                        <ul>
                            {foreach from = $item.arts item = art}
                                <li data-url="{$art.Links.url}">
                                    <a href="{$art.Links.url}" class="inner-title-2 {if ($slug == $art.Links.url)}active{/if}">{$art.ArticlesContent.name}</a>
                                </li>
                            {/foreach}
                        </ul>
                    {/if}
                </li>
            {/foreach}
        </ul>
    </div>
    <div class="category-topic-overlay" id="categoryTopicOverlay">
        <span class="close-sidebar effect-rotate icon-close"><i class="iconsax isax-add"></i></span>
    </div>
{/if}{/strip}