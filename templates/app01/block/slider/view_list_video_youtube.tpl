{strip}
{if !empty($data_block)}
<div class="row g-5 mt--25">
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
		
		{assign var = ignore value = false}
		{if $slider@first}
			{assign var = ignore value = true}
		{/if}

        <div class="col-lg-4 col-md-6 col-sm-6 col-12 {if !empty($slider.class_item)}{$slider.class_item}{/if}" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
            <div class="service-card service-card-1 radius-small">
                <div class="inner">
                    <div class="thumbnail">
                        <a {if !empty($slider.url)}href="https://www.youtube.com/watch?v={$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                            <img class="w-100" src="https://img.youtube.com/vi/{$slider.url}/sddefault.jpg" alt="{if !empty($slider.name)}{$slider.name}{/if}">
                        </a>
                    </div>
                    <div class="content">
                        <h6 class="title"><a {if !empty($slider.url)}href="https://www.youtube.com/watch?v={$slider.url}"{/if} {if !empty($slider.blank_link)}target="_blank"{/if}>{if !empty($slider.name)}{$slider.name}{/if}</a></h6>
                        {if !empty($slider.description)}
                            <p class="description">{$slider.description}</p>
                        {/if}
                        <div class="read-more-btn mt--20">
                            <a class="btn-transparent" {if !empty($slider.url)}href="https://www.youtube.com/watch?v={$slider.url}"{/if} {if !empty($slider.blank_link)}target="_blank"{/if}>
                                Xem Ngay <i class="icon-arrow-right-line-right"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
	{/foreach}
</div>

    {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}
        <div class="text-center mt-40">
            <div class="read-more-btn" data-sal-delay="450" data-sal="slide-up" data-sal-duration="800">
                <a class="edu-btn btn-ani" href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_nut_bam'])}{$this->Block->getLocale('link_nut_bam', $data_extend)}{/if}">
                    {$this->Block->getLocale('nut_bam', $data_extend)|nl2br} <i class="icon-arrow-right-line-right"></i>
                </a>
            </div>
        </div>
    {/if}
{/if}
{/strip}