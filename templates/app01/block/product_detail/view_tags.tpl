{assign var = product value = []}
{if !empty($data_block.data)}
	{assign var = product value = $data_block.data}
{/if}

{if !empty($product)}
	{if !empty($product.tags)}
		<div class="bg-white rounded mb-10 py-10 px-15">
			{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                <div class="title-section-2">
                    <span>{$this->Block->getLocale('tieu_de', $data_extend)}</span>
                </div>
            {/if}
			<ul class="product-detail-tags">
			    {foreach from = $product.tags item = tag}
		        	{if !empty($tag.name)}
					    <li>
					        <a href="{if !empty($tag.url)}{TAG_PATH}/{$tag.url}{/if}">
					        	{$tag.name}
					        </a>
					    </li>
					{/if}
		        {/foreach}
			</ul>
		</div>
	{/if}
{/if}