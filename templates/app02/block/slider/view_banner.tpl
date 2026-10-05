{strip}
{if !empty($data_block)}
	<div class="section-banner">
	    <div class="row">
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
    
    			<div class="{if !empty($data_extend.col)}{$data_extend.col}{/if}">
			        <div class="item-banner img_banner position-relative rounded-10">
			            <a href="{$url}" title="{if !empty($slider.name)}{$slider.name}{/if}">
			                
			                <span class="line line-top"></span> 
                            <span class="line line-right"></span> 
                            <span class="line line-bottom"></span> 
                            <span class="line line-left"></span>

    			            {$this->LazyLoad->renderImage([
                                'src' => $image_url, 
                                'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                'class' => 'img-fluid rti-abs-cover'
                            ])}
                        </a>
			        </div>
    			</div>
    		{/foreach}
	    </div>
	</div>
{/if}
{/strip}