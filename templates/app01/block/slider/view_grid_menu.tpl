{strip}
{if !empty($data_block)}
    <div class="row box_header" data-aos="fade-up" data-aos-duration="750" data-aos-easing="linear">
        <h2 class="box_title" data-sal="slide-up" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
            {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_1'])}
            	{$this->Block->getLocale('tieu_de_1', $data_extend)|nl2br}
            {/if}
        </h2>
        <h3 class="sub_title" data-sal="slide-up" data-sal-delay="400" data-sal-easing="ease-out-back" data-sal-duration="800">
            {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_2'])}
            	{$this->Block->getLocale('tieu_de_2', $data_extend)|nl2br}
            {/if}
        </h3>
    </div>
	<div class="row">
		{foreach from = $data_block key = key item = slider}			
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

			<div class="col-md-4 col-sm-12 {if !empty($slider.class_item)}{$slider.class_item}{/if}"  data-sal="slide-up" data-sal-delay="{($key + 5)}00" data-sal-easing="ease-out-back" data-sal-duration="800">
			    <div class="item" >
                    <h4 class="item_title">
                        <span>{if !empty($slider.name)}{$slider.name}{/if}</span>
                    </h4>
                    <div class="item_content">
                        <div class="image">
                            <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                                {$this->LazyLoad->renderImage([
                                    'src' => $image_url, 
                                    'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                    'class' => 'img-fluid',
                                    'delay' => 'all'
                                ])}
                            </a>
                        </div>

                    </div>
                    <a class="btn" {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                        Xem chi tiết
                    </a>
                </div>
			</div>
		{/foreach}
	</div>
{/if}
{/strip}