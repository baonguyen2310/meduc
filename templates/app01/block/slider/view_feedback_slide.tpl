{if !empty($data_block)}
    <div class="section-padding bg-no-repeat bg-cover section-10" {if !empty($data_extend['locale'][{LANGUAGE}]['background'])}style="background-image: url({$this->Utilities->replaceVariableSystem($this->Block->getLocale('background', $data_extend))});"{/if}>
        <div class="container">
            {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                <div class="text-2xl font-bold text-black mb-20">
                    {$this->Block->getLocale('text_1', $data_extend)|nl2br}
                </div>
            {/if}
            {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                <div class="mini-title mb-20">
                    {$this->Block->getLocale('text_2', $data_extend)|nl2br}
                </div>
            {/if}
            
            <div class="feedback-list">
                <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                    {foreach from = $data_block item = slider}			
        				{assign var = image_source value = ''}
        				{if !empty($slider.image) && !empty($slider.image_source)}
        					{assign var = image_source value = $slider.image_source}
        				{/if}
        
        				{assign var = image_url value = ''}
        				{if !empty($slider.image) && $image_source == 'cdn'}
        					{assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 500)}"}
        				{/if}
        
        				<a href="{CDN_URL}{$slider.image}" class="inner-item js-feedback {if !empty($slider.class_item)}{$slider.class_item}{/if}">
        				    <div class="inner-box p-0">
        				        <div class="inner-image">
        				            {$this->LazyLoad->renderImage([
                                        'src' => $image_url, 
                                        'alt' => "{if !empty($slider.name)}{$slider.name}{/if}", 
                                        'class' => 'img-fluid'
                                    ])}
        				        </div>
        				    </div>
        				</a>
        			{/foreach}
        		</div>
    		</div>
    		
    		{if !empty($data_extend['locale'][{LANGUAGE}]['text_3'])}
                <div class="block text-primary text-2xl font-bold mt-8">
                    {$this->Block->getLocale('text_3', $data_extend)|nl2br}
                </div>
            {/if}
    		
    		{if !empty($data_extend['locale'][{LANGUAGE}]['text_4'])}
                <p class="mt-30 text-black">
            	    {$this->Block->getLocale('text_4', $data_extend)|nl2br}
            	</p>
            {/if}
            
            {if !empty($data_extend['locale'][{LANGUAGE}]['text_5'])}
                <p class="mt-10 text-black">
            	    {$this->Block->getLocale('text_5', $data_extend)|nl2br}
            	</p>
            {/if}
            
        </div>
    </div>
{/if}