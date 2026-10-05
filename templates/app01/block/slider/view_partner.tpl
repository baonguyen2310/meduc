{strip}
{if !empty($data_block)}
    <div class="brand-area pt-60 pb-60" style="background-color: #0c2957;">
        <div class="container">
            <div class="row brand-active">
                {foreach from = $data_block item = slider}			
    				{assign var = image_source value = ''}
    				{if !empty($slider.image) && !empty($slider.image_source)}
    					{assign var = image_source value = $slider.image_source}
    				{/if}
    
    				{assign var = image_url value = ''}
    				{if !empty($slider.image) && $image_source == 'cdn'}
    					{assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 250)}"}
    				{/if}
    				
    				<div class="col-xl-2 {if !empty($slider.class_item)}{$slider.class_item}{/if}">
                        <div class="single-brand">
                            <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                                {$this->LazyLoad->renderImage([
                                    'src' => $image_url, 
                                    'alt' => "{if !empty($slider.name)}{$slider.name}{/if}"
                                ])}
                            </a>
                        </div>
                    </div>
    			{/foreach}
            </div>
        </div>
    </div>
{/if}
{/strip}