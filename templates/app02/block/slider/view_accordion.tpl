{strip}
{if !empty($data_block)}
    <div class="cart-drop-botoom">
        <div id="accordion">
            {foreach from = $data_block key = key item = slider}			
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
    			
    			<div class="card bg-white rounded  mb-10 ">
                    <div class="card-header" id="heading{$key}">
                        <button class="btn btn-link collapsed d-flex justify-content-between align-items-center w-100" data-toggle="collapse" data-target="#collapse{$key}" aria-expanded="{if $key == 0}true{else}false{/if}" aria-controls="collapse{$key}">
                            <span class="d-flex align-items-center" >
                                <div class="icon-card">
                                   {$this->LazyLoad->renderImage([
                                        'src' => $image_url, 
                                        'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                        'class' => 'img-fluid'
                                    ])}
                               </div>
                                <span class="pl-15 fs-14 fs-xl-16 color-black">
                                    {if !empty($slider.name)}
                                        {$slider.name}
                                    {/if}
                                </span>
                            </span>
                            <i class="iconsax isax-arrow-right-3"></i>
                        </button>
                    </div>
                    <div id="collapse{$key}" class="collapse {if $key == 0}show{/if}" aria-labelledby="heading{$key}" data-parent="#accordion">
                        <div class="card-body mx-15 mb-10 p-10">
                            {if !empty($slider.description)}
                                {$slider.description}
                            {/if}
                        </div>
                    </div>
                </div>
    		{/foreach}
        </div>
    </div>
{/if}
{/strip}