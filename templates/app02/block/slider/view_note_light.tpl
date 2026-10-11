{strip}
{if !empty($data_block)}
    <div class="note-light bg-white rounded-10 py-10 px-15">
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
			<a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
    			<div class="note-content d-flex align-items-center">
                    <div class="note-icon mr-10 fs-24">
                        {$this->LazyLoad->renderImage([
                            'src' => $image_url, 
                            'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                            'class' => 'img-fluid'
                        ])}
                    </div>
                    {if !empty($slider.name)}
                        <div class="note-title fs-14 fs-xl-16">
                            {$slider.name}
                        </div>
                    {/if}
                </div>
            </a>
		{/foreach}
    </div>
{/if}
{/strip}