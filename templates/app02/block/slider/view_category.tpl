{strip}
{if !empty($data_block)}
    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <h3 class="title-section-1 mb-20">
            {$this->Block->getLocale('tieu_de', $data_extend)}
        </h3>
    {/if}   
	<div class="section-category-product">
	    <div class="row">
	        {foreach from = $data_block item = slider}			
    			{assign var = image_source value = ''}
    			{if !empty($slider.image) && !empty($slider.image_source)}
    				{assign var = image_source value = $slider.image_source}
    			{/if}
    
    			{assign var = image_url value = ''}
    			{if !empty($slider.image) && $image_source == 'cdn'}
    				{assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 350)}"}
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
    			    <div class="item-category position-relative mb-10 rounded overflow-hidden {if !empty($slider.description)}{else}hover-on-img{/if}">
    			        <div class="wrp-effect-change-img img-category rounded ">
    			            <a href="{$url}" title="{if !empty($slider.name)}{$slider.name}{/if}">
        			            {$this->LazyLoad->renderImage([
                                    'src' => $image_url, 
                                    'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                    'class' => 'img-fluid'
                                ])}
                            </a>
                            {if !empty($slider.description)}
                                <div class="effect-change-img">
                                    <a href="{$url}" title="{if !empty($slider.name)}{$slider.name}{/if}">
                                        {$this->LazyLoad->renderImage([
                                            'src' => "{CDN_URL}{$slider.description}", 
                                            'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                            'class' => 'img-fluid'
                                        ])}
                                    </a>
                                </div>
                            {/if}
    			        </div>
    			        <div class="name-category text-center">
    			            {if !empty($slider.name)}
        			            <a href="{$url}" title="{if !empty($slider.name)}{$slider.name}{/if}" class="color-white fs-lg-18 fs-md-15 fs-10 font-weight-bold text-uppercase">
        			                {$slider.name}
        			            </a>
        			         {/if}
    			        </div>
    			    </div>
    			</div>
    		{/foreach}
	    </div>
		
	</div>
{/if}
{/strip}