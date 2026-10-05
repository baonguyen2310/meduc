{strip}
{if !empty($data_block)}
	<div class="list-banner">
		{foreach from = $data_block item = slider}			
			{assign var = image_source value = ''}
			{if !empty($slider.image) && !empty($slider.image_source)}
				{assign var = image_source value = $slider.image_source}
			{/if}

			{assign var = image_url value = ''}
			{if !empty($slider.image) && $image_source == 'cdn'}
				{assign var = image_url value = "{CDN_URL}{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 500)}"}
				{/if}
			{/if}

			{if !empty($slider.image) && $image_source == 'template'}
				{assign var = image_url value = "{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 500, 'template')}"}
				{/if}
			{/if}

			<div class="item text-center {if !empty($slider.class_item)}{$slider.class_item}{/if}">
			    <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
			        {$this->LazyLoad->renderImage([
                        'src' => $image_url, 
                        'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                        'class' => 'img-fluid mt-20',
                        'delay' => 'all'
                    ])}
			    </a>
			</div>
		{/foreach}
	</div>
{/if}
{/strip}