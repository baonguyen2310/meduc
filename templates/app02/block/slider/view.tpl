{strip}
{if !empty($data_block)}
	<div class="slider-section slider-bg">
		<div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
			{foreach from = $data_block item = slider}			
				{assign var = image_source value = ''}
				{if !empty($slider.image) && !empty($slider.image_source)}
					{assign var = image_source value = $slider.image_source}
				{/if}

				{assign var = image_url value = ''}
				{if !empty($slider.image) && $image_source == 'cdn'}
					{assign var = image_url value = "{CDN_URL}{$slider.image}"}
				{/if}

				{if !empty($slider.image) && $image_source == 'template'}
					{assign var = image_url value = "{$slider.image}"}
				{/if}
				
				{assign var = url value = '/'}
				{if !empty($slider.url)}
					{assign var = url value = $this->Utilities->checkInternalUrl($slider.url)}
				{/if}
				
				{assign var = ignore value = false}
				{if $slider@first}
					{assign var = ignore value = true}
				{/if}

				<div class="item {if !empty($slider.class_item)}{$slider.class_item}{/if}">
				    <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
				        {$this->LazyLoad->renderImage([
                            'src' => $image_url, 
                            'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                            'class' => 'img-fluid',
                            'ignore' => $ignore,
                            'delay' => 'all'
                        ])}
				    </a>
				</div>
			{/foreach}
		</div>
	</div>
{/if}
{/strip}