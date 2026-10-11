{strip}
{if !empty($data_block)}
    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <h3 class="title-section-1">
        	{$this->Block->getLocale('tieu_de', $data_extend)}
        </h3>
    {/if}
	<div class="box-list-menu">
		{foreach from = $data_block item = slider}			
    		{assign var = image_source value = ''}
    		{if !empty($slider.image) && !empty($slider.image_source)}
    			{assign var = image_source value = $slider.image_source}
    		{/if}
    
    		{assign var = image_url value = ''}
    		{if !empty($slider.image) && $image_source == 'cdn'}
    			{assign var = image_url value = "{CDN_URL}{$slider.image}"}
    			{if !empty(DEVICE)}
    			    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 350)}"}
    			{/if}
    		{/if}
    
    		{if !empty($slider.image) && $image_source == 'template'}
    			{assign var = image_url value = "{$slider.image}"}
    			{if !empty(DEVICE)}
    			    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 350, 'template')}"}
    			{/if}
    		{/if}
    
    		<a class="inner-item {if !empty($slider.class_item)}{$slider.class_item}{/if}" {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
		        {$this->LazyLoad->renderImage([
                    'src' => $image_url, 
                    'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                    'class' => 'inner-icon',
                    'delay' => 'all'
                ])}
                
                <span class="inner-title">
                    {if !empty($slider.name)}{$slider.name}{/if}
                </span>
                
                <i class="fa-solid fa-angles-right"></i>
		    </a>
    	{/foreach}
	</div>
{/if}
{/strip}