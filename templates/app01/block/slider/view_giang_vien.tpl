{strip}
{if !empty($data_block)}
	<div class="row g-5">
        <div class="col-lg-12">
            <div class="section-title text-center" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                	<h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)|nl2br}</h3>
                {/if}
            </div>
        </div>
    </div>
    <div class="row row--20">

        {foreach from = $data_block item = slider}			
			{assign var = image_source value = ''}
			{if !empty($slider.image) && !empty($slider.image_source)}
				{assign var = image_source value = $slider.image_source}
			{/if}

			{assign var = image_url value = ''}
			{if !empty($slider.image) && $image_source == 'cdn'}
				{assign var = image_url value = "{CDN_URL}{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 720)}"}
				{/if}
			{/if}

			{if !empty($slider.image) && $image_source == 'template'}
				{assign var = image_url value = "{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 720, 'template')}"}
				{/if}
			{/if}
			
            <div class="col-lg-3 col-md-6 col-sm-6 col-12 mt--30 {if !empty($slider.class_item)}{$slider.class_item}{/if}" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                    <div class="edu-instructor-grid edu-instructor-1 edu-instructor-1">
                        <div class="edu-instructor">
                            <div class="inner">
                                <div class="thumbnail">
                                    <img src="{$image_url}" alt="{if !empty($slider.name)}{$slider.name}{/if}" class="img-fluid" />
                                    {*$this->LazyLoad->renderImage([
                                        'src' => $image_url, 
                                        'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                        'class' => 'img-fluid',
                                        'delay' => 'all'
                                    ])*}
                                </div>
                            </div>
                        </div>
                        <div class="edu-instructor-info">
                            <h5 class="title">{if !empty($slider.name)}{$slider.name}{/if}</h5>
                            <span class="desc">{if !empty($slider.description)}{$slider.description|nl2br}{/if}</span>
                            {if !empty($slider.url)}
                                <div class="text-center">
                                    <a href="{$slider.url}" class="edu-btn btn-small px-30 btn-ani" target="_blank">
                                        Tìm hiểu khoá học
                                    </a>
                                </div>
                            {/if}
                        </div>
                    </div>
                </a>
            </div>
		{/foreach}

    </div>
{/if}
{/strip}