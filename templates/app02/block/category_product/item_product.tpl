{strip}
{if !empty($categories)}
    {foreach from = $categories item = category}
        {assign var = image value = "{if !empty($category.image_avatar)}{CDN_URL}{$this->Utilities->replaceVariableSystem($category.image_avatar)}{/if}"}
        <div class="{if !empty($col)}{$col}{else}col-6 col-sm-6 col-md-4 col-lg-3{/if}">
            <div class="list_category mb-30">
                <div class="img_category position-relative rti-100 mb-10">
                    <a href="{if !empty($category.url)} {$this->Utilities->checkInternalUrl($category.url)}"{/if}>
                        {$this->LazyLoad->renderImage([
                            'src' => "{$image}", 
                            'alt' => $category.name, 
                            'class' => 'img-fluid rti-abs-cover'
                        ])}
                    </a>
                </div>
                <div class="item-title-category text-center font-weight-bold  mb-10 fs-md-10 fs-15 overflow-hidden px-15">
                    <a href="{if !empty($category.url)} {$this->Utilities->checkInternalUrl($category.url)}"{/if} class="color-main">
        				{$category.name|escape|truncate:80:" ..."}
        			</a>
                </div>
    		</div>
        </div>
    {/foreach}
{/if}
{/strip}