{strip}
{if !empty($data_block)}
<div class="eduvibe-about-one-team edu-team-area edu-section-gap team-area-shape-position bg-image bg-image--8 paralax-area">
    <div class="wrapper">
        <div class="container eduvibe-animated-shape">
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
    				
    				<div class="col-lg-3 col-md-6 col-sm-6 col-12 mt--45 {if !empty($slider.class_item)}{$slider.class_item}{/if}" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                        <div class="edu-instructor-grid edu-instructor-1 edu-instructor-1">
                            <div class="edu-instructor">
                                <div class="inner">
                                    <div class="thumbnail">
                                        {$this->LazyLoad->renderImage([
                                            'src' => $image_url, 
                                            'alt' => "{if !empty($slider.name)}{$slider.name}{/if}"
                                        ])}
                                    </div>
                                </div>
                            </div>
                            <div class="edu-instructor-info">
                                {if !empty($slider.name)}
                                    <h5 class="title">{$slider.name}</h5>
                                {/if}
                                {if !empty($slider.description)}
                                    <p class="fs-13">{$slider.description}</p>
                                {/if}
                                {if !empty($slider.description_short)}
                                    <p class="fs-11">{$slider.description_short}</p>
                                {/if}
                            </div>
                        </div>
                    </div>
    			{/foreach}
            </div>

            <div class="shape-dot-wrapper shape-wrapper d-xl-block d-none">
                <div class="shape-image shape-image-4">
                    <img src="{CDN_URL}/media/core/icons/icon-ran.png" alt="Shape Thumb" />
                </div>
            </div>
        </div>
    </div>
</div>
{/if}
{/strip}