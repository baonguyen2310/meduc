{strip}
{if !empty($categories)}
	<ul class="category-highlight">
		{foreach from = $categories item = category}
			<li class="inner-item">
				<a {if !empty($category.url)}href="{$this->Utilities->checkInternalUrl($category.url)}"{/if}>
				    {if !empty($category.image_avatar)}
    				    {$this->LazyLoad->renderImage([
                            'src' => "{CDN_URL}{$this->Utilities->getThumbs($category.image_avatar, 350)}", 
                            'alt' => $category.name,
                            'class' => 'inner-image'
                        ])}
                    {/if}
					<h3 class="inner-title">{$category.name|escape}</h3>
				</a>
				{if !empty($category.children)}
					{$this->element('../block/category_article/item_highlight', [
						'categories' => $category.children,
						'parent_id' => $category.id
					])}
				{/if}
			</li>
		{/foreach}
	</ul>
{/if}
{/strip}