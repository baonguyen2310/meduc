{strip}
{if !empty($data_block)}
    <div class="edu-feature-area mt-60 mb-45">
        <div class="container eduvibe-animated-shape">
            {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat'])}
                <div class="inner-icon-logo">
                    {$this->LazyLoad->renderImage([
                		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat', $data_extend))}", 
                		'delay' => 'all'
                	])}
                </div>
            {/if}
            <div class="row row--35 align-items-center">
                <div class="col-lg-6 col-12 order-2 order-lg-1">
                    <div class="inner mt_md--40 mt_sm--40">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                            <div class="section-title text-start" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                                <h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)}</h3>
                            </div>
                        {/if}
                        <div class="row">
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
                				
                				<div class="feature-list mt--15 mt_mobile--15" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                                    {*<div class="icon">
                                        {$this->LazyLoad->renderImage([
                                            'src' => $image_url, 
                                            'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                            'class' => 'img-fluid',
                                            'delay' => 'all'
                                        ])}
                                    </div>*}
                                    <div class="content">
                                        {if !empty($slider.name)}
                    				        <div class="title">
                    				            {$slider.name}
                    				        </div>
                				        {/if}
                				        {if !empty($slider.description)}
                				            <p>{$slider.description|nl2br}</p>
                				        {/if}
                                        
                                    </div>
                                </div>
                			{/foreach}
                        </div>
                    </div>
                </div>
    
                <div class="col-lg-6 col-12 order-1 order-lg-2">
                    <div class="feature-thumbnail">
                        <div class="main-image video-popup-wrapper video-popup-two">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['hinh_anh'])}
                            	{$this->LazyLoad->renderImage([
                            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('hinh_anh', $data_extend))}"
                            	])}
                            {/if}
                        </div>
                        <div class="circle-image">
                            <span></span>
                            <span></span>
                        </div>
                    </div>
                </div>
            </div>
    
        </div>
    </div>
{/if}
{/strip}