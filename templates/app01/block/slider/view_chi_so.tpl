{strip}
{if !empty($data_block)}
	<div class="row g-5 hanger-line">
	    {foreach from = $data_block item = slider}			
			{assign var = image_source value = ''}
			{if !empty($slider.image) && !empty($slider.image_source)}
				{assign var = image_source value = $slider.image_source}
			{/if}

			{assign var = image_url value = ''}
			{if !empty($slider.image) && $image_source == 'cdn'}
				{assign var = image_url value = "{CDN_URL}{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 150)}"}
				{/if}
			{/if}

			{if !empty($slider.image) && $image_source == 'template'}
				{assign var = image_url value = "{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 150, 'template')}"}
				{/if}
			{/if}
			
			<!-- Start Single Counter  -->
            <div class="col-lg-3 col-md-6 col-sm-6 col-12 {if !empty($slider.class_item)}{$slider.class_item}{/if}">
                <div class="rbt-counterup rbt-hover-03 border-bottom-gradient">
                    <div class="top-circle-shape"></div>
                    <div class="inner">
                        <div class="rbt-round-icon">
                            {$this->LazyLoad->renderImage([
                                'src' => $image_url, 
                                'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                'class' => 'img-fluid',
                                'delay' => 'all'
                            ])}
                        </div>
                        <div class="content">
                            {if !empty($slider.name)}
                                <h3 class="counter">
                                    <span class="odometer" data-count="{$slider.name}">00</span>
                                </h3>
                            {/if}
                            {if !empty($slider.description)}
                                <span class="subtitle">{$slider.description}</span>
                            {/if}
                        </div>
                    </div>
                </div>
            </div>
            <!-- End Single Counter  -->
		{/foreach}
    </div>
{/if}
{/strip}