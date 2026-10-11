{strip}
{if !empty($data_block)}
    <div class="about-why-choose">
        <div class="container">
            <div class="row">
                <div class="col-xl-6">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['hinh_anh'])}
                        <div class="inner-image">
                            {$this->LazyLoad->renderImage([
                        		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('hinh_anh', $data_extend))}",
                        		'delay' => 'all'
                        	])}
                        </div>
                    {/if}
                </div>
                <div class="col-xl-6">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="section-title mb--30" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                                    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_phu'])}
                                        <span class="pre-title">{$this->Block->getLocale('tieu_de_phu', $data_extend)}</span>
                                    {/if}
                                    <h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)}</h3>
                                </div>
                            </div>
                        </div>
                    {/if}
                    
                    {*<div class="inner-list">
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
            
            				<div class="item-item {if !empty($slider.class_item)}{$slider.class_item}{/if}">
            				    <div class="inner-icon">
            				        {$this->LazyLoad->renderImage([
                                        'src' => $image_url, 
                                        'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                        'class' => 'img-fluid',
                                        'delay' => 'all'
                                    ])}
            				    </div>
            				    <div class="inner-text">
            				        {if !empty($slider.name)}
                				        <div class="inner-title">
                				            {$slider.name}
                				        </div>
            				        {/if}
            				        {if !empty($slider.description)}
                				        <div class="inner-desc">
                				            {$slider.description}
                				        </div>
            				        {/if}
            				    </div>
            				</div>
            			{/foreach}
                	</div>*}
                	
                	<div class="accordion-style-1">
                        <div class="edu-accordion" id="accordionFAQs">
                            {foreach from = $data_block key = key item = slider}			
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
                				
                				{*<div class="edu-accordion-item">
                                    <div class="edu-accordion-header" id="headingOne">
                                        <button class="edu-accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                            Am I eligible for admission?
                                        </button>
                                    </div>
                                    <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne" data-bs-parent="#accordionFAQs">
                                        <div class="edu-accordion-body">
                                            Learning management system, combines a wide range of features to
                                            present
                                            a class setting without having the students come into a physical
                                            classroom. It all depends on the WordPress plugin you go with,
                                            but in
                                            general.
                                        </div>
                                    </div>
                                </div>*}
                				
                				<div class="edu-accordion-item {if !empty($slider.class_item)}{$slider.class_item}{/if}">
                                    <div class="edu-accordion-header" id="heading{$key}">
                                        <button class="edu-accordion-button {if $key > 0}collapsed{/if}" type="button" data-bs-toggle="collapse" data-bs-target="#collapse{$key}" aria-expanded="{if $key == 0}true{else}false{/if}" aria-controls="collapse{$key}">
                                            <div class="inner-icon">
                        				        {if !empty($image_url)}
                                                    <img src="{$image_url}" />
                                                {/if}
                        				    </div>
                        				    {if !empty($slider.name)}{$slider.name}{/if}
                                        </button>
                                    </div>
                                    <div id="collapse{$key}" class="accordion-collapse collapse {if $key == 0}show{/if}" aria-labelledby="heading{$key}" data-bs-parent="#accordionFAQs">
                                        <div class="edu-accordion-body">
                                            {if !empty($slider.description)}
                    				            {$slider.description|nl2br}
                    				        {/if}
                                        </div>
                                    </div>
                                </div>
                			{/foreach}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
{/if}
{/strip}