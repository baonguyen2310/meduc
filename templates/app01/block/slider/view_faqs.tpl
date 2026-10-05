{strip}
{if !empty($data_block)}
    <div class="course-details-card mt--40" nh-anchor="cauhoithuonggap">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <div class="title-section-2">
                <span>{$this->Block->getLocale('tieu_de', $data_extend)}</span>
            </div>
        {/if}
        
        <div class="accordion-style-1">
            <div class="edu-accordion">
                {foreach from = $data_block key = key item = slider}			
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
    				
    				{assign var = ignore value = false}
    				{if $slider@first}
    					{assign var = ignore value = true}
    				{/if}
    				
    				<div class="edu-accordion-item">
                        <div class="edu-accordion-header" id="heading{$key}">
                            <button class="edu-accordion-button {if ($key != 0)}collapsed{/if}" type="button" data-bs-toggle="collapse" data-bs-target="#collapse{$key}" aria-expanded="{if ($key == 0)}true{else}false{/if}" aria-controls="collapse{$key}">
                                {if !empty($slider.name)}{$slider.name}{/if}
                            </button>
                        </div>
                        <div id="collapse{$key}" class="accordion-collapse collapse {if ($key == 0)}show{/if}" aria-labelledby="heading{$key}">
                            <div class="edu-accordion-body">
                                {if !empty($slider.description)}{$slider.description|nl2br}{/if}
                            </div>
                        </div>
                    </div>
    			{/foreach}
            </div>
        </div>
    </div>
{/if}
{/strip}