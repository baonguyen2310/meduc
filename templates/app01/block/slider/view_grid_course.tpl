{strip}
{if !empty($data_block)}
    <div class="section-title text-center" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <h3 class="title">
                <img class="inner-icon" src="{CDN_URL}/media/core/logo/linh-vat-1.png" />
                {$this->Block->getLocale('tieu_de', $data_extend)|nl2br}
                </h3>
        {/if}
        {if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
            <p>{$this->Block->getLocale('mo_ta', $data_extend)|nl2br}</p>
        {/if}
    </div>
	<div class="mt-30" data-sal="slide-up" data-sal-delay="400" data-sal-easing="ease-out-back" data-sal-duration="800">
		<div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
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

				<div class="item {if !empty($slider.class_item)}{$slider.class_item}{/if}">
				    <div class="single-event event-1">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['anh_nen'])}
                        	{$this->LazyLoad->renderImage([
                        		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('anh_nen', $data_extend))}", 
                        		'alt' => "{__d('template', 'alt_image')}",
                        		'class' => 'event-bg',
                        		'delay' => 'all'
                        	])}
                        {/if}
                        <div class="event-content">
                            <p class="event-type">{if !empty($slider.description)}{$slider.description}{/if}</p>
                    
                            <div class="event-details">
                                <h3>{if !empty($slider.name)}{$slider.name}{/if}</h3>
                                <p>{if !empty($slider.description_short)}{$slider.description_short}{/if}</p>
                            </div>
                    
                            <a {if !empty($slider.url)}href="{$slider.url}"{/if} {if !empty($slider.blank_link)}target="_blank"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" class="edu-btn btn-small px-20">
                                {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}
                                	{$this->Block->getLocale('nut_bam', $data_extend)|nl2br}
                                {/if}
                            </a>
                        </div>
                        <div class="event-img">
                            {$this->LazyLoad->renderImage([
                                'src' => $image_url, 
                                'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                'delay' => 'all'
                            ])}
                        </div>
                    </div>
				</div>
			{/foreach}
		</div>
	</div>
	{if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat'])}
	    <div class="inner-icon">
	        <div class="inner-icon-logo">
    	        {$this->LazyLoad->renderImage([
            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat', $data_extend))}", 
            		'delay' => 'all'
            	])}
    	    </div>
	    </div>
    {/if}
{/if}
{/strip}