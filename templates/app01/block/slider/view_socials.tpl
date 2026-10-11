{strip}
{if !empty($data_block)}
    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_2'])}
        <div class="title-section-2">
            <span>{$this->Block->getLocale('tieu_de_2', $data_extend)}</span>
        </div>
    {/if}
	<div class="product-content-detail">
		<div class="inner-info-contact">
		    <div class="row g-3 mt--20">
		        {foreach from = $data_block item = slider}			
    				{assign var = image_source value = ''}
    				{if !empty($slider.image) && !empty($slider.image_source)}
    					{assign var = image_source value = $slider.image_source}
    				{/if}
    
    				{assign var = image_url value = ''}
    				{if !empty($slider.image) && $image_source == 'cdn'}
    					{assign var = image_url value = "{CDN_URL}{$slider.image}"}
    					{if !empty(DEVICE)}
    					    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 250)}"}
    					{/if}
    				{/if}
    
    				{if !empty($slider.image) && $image_source == 'template'}
    					{assign var = image_url value = "{$slider.image}"}
    					{if !empty(DEVICE)}
    					    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 250, 'template')}"}
    					{/if}
    				{/if}
    				
    				{assign var = ignore value = false}
    				{if $slider@first}
    					{assign var = ignore value = true}
    				{/if}
                    {if !empty($slider.url)}
        				<div class="col-lg-6 col-md-6 col-sm-6 col-6 mt-0 mb-20 {if !empty($slider.class_item)}{$slider.class_item}{/if}">
        				    <div class="edu-counterup p-15">
            				    <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
            				        <div class="inner">
            				            <div class="icon mb-10">
            				                {$this->LazyLoad->renderImage([
                                                'src' => $image_url, 
                                                'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                                'class' => 'img-fluid',
                                                'delay' => 'all'
                                            ])}
            				            </div>
            				            <div class="content">
            				                <span>{if !empty($slider.name)}{$slider.name}{/if}</span>
            				            </div>
            				        </div>
            				    </a>
        				    </div>
        				</div>
    				{/if}
    			{/foreach}
		    </div>
		</div>
	</div>
{/if}
{/strip}