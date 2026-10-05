{strip}
{if !empty($data_block)}
	<div class="row">
		{foreach from = $data_block item = slider}			
			{assign var = image_source value = ''}
			{if !empty($slider.image) && !empty($slider.image_source)}
				{assign var = image_source value = $slider.image_source}
			{/if}

			{assign var = image_url value = ''}
			{if !empty($slider.image) && $image_source == 'cdn'}
				{assign var = image_url value = "{CDN_URL}{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 720)}"}
				{/if}
			{/if}

			{if !empty($slider.image) && $image_source == 'template'}
				{assign var = image_url value = "{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 720, 'template')}"}
				{/if}
			{/if}
			
			{assign var = ignore value = false}
			{if $slider@first}
				{assign var = ignore value = true}
			{/if}
			
			<div class="col-12 mb-15 {if !empty($slider.class_item)}{$slider.class_item}{/if}">
                <article class="article-highlight">
                    <div class="inner-image">
                        <div class="featured-media"></div>
                        <div class="inner-avatar">
                            <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                                {$this->LazyLoad->renderImage([
                                    'src' => $image_url, 
                                    'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                    'class' => 'zoom-image',
                                    'delay' => 'all'
                                ])}
                            </a>
                        </div>
                    </div>
                    <div class="inner-content">
                        <h4 class="inner-title">
                            <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                                {if !empty($slider.name)}{$slider.name}{/if}
                            </a>
                        </h4>
                        {if !empty($slider.description)}
                            <div class="inner-desc">
                                {$slider.description}
                            </div>
                        {/if}
                    </div>
                </article>
            </div>
		{/foreach}
	</div>
{/if}
{/strip}