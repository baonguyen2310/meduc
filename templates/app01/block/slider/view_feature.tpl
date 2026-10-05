{strip}
{if !empty($data_block)}
    <div class="feature-area bg-cover bg-no-repeat bg-center section-padding section-5" {if !empty($data_extend['locale'][{LANGUAGE}]['background'])}style="background-image: url({$this->Utilities->replaceVariableSystem($this->Block->getLocale('background', $data_extend))});"{/if}>
        <div class="container">
            <div class="text-center">
                <div class="column-title">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                    	{$this->Block->getLocale('text_1', $data_extend)|nl2br}<span> </span>
                    {/if}
                    <span class="shape-bg">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                        	{$this->Block->getLocale('text_2', $data_extend)|nl2br}
                        {/if}
                    </span>
                </div>
            </div>
            <div class="grid lg:grid-cols-4 md:grid-cols-2 sm:grid-cols-2 grid-cols-2 gap-5 pt-10">
                {foreach from = $data_block item = slider}			
    				{assign var = image_source value = ''}
    				{if !empty($slider.image) && !empty($slider.image_source)}
    					{assign var = image_source value = $slider.image_source}
    				{/if}
    
    				{assign var = image_url value = ''}
    				{if !empty($slider.image) && $image_source == 'cdn'}
    					{assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 150)}"}
    				{/if}
    				
    				<div class="bg-white shadow-box rounded-[8px] px-15 py-25 group hover:bg-primary transition duration-150 hover:-translate-y-1">
                        <div
                            class="h-[72px] w-[72px] rounded-full flex flex-col items-center justify-center text-secondary bg-green-paste mb-15 text-5xl group-hover:bg-black group-hover:bg-opacity-[0.1] group-hover:text-white transition duration-150"
                        >
                            <img src="{$image_url}" alt="{if !empty($slider.name)}{$slider.name}{/if}" style="width:50px;height:50px;object-fit:contain;" />
                        </div>
                        <h4 class="lg:text-2xl text-[22px] leading-[30px] mb-4 transition duration-150 group-hover:text-white inner-title">
                            {if !empty($slider.name)}{$slider.name}{/if}
                        </h4>
                        <div class="transition duration-150 group-hover:text-white inner-desc">
                            {if !empty($slider.description)}{$slider.description}{/if}
                        </div>
                    </div>
    			{/foreach}
            </div>
        </div>
    </div>
{/if}
{/strip}