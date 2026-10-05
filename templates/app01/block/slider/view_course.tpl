{strip}
{if !empty($data_block)}
    <div class="bg-cover bg-no-repeat bg-center section-padding section-18" {if !empty($data_extend['locale'][{LANGUAGE}]['background'])}style="background-image: url({$this->Utilities->replaceVariableSystem($this->Block->getLocale('background', $data_extend))});"{/if}>
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
            <div class="inner-list">
                {foreach from = $data_block item = slider}
                    <div class="inner-box">
                        <div class="inner-title">
                            {if !empty($slider.name)}{$slider.name}{/if}
                        </div>
                        <div class="inner-desc">
                            {if !empty($slider.description)}{$slider.description|nl2br}{/if}
                        </div>
                    </div>
                {/foreach}
            </div>
            <div class="pt-8 text-center" {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}data-text-button="{$this->Block->getLocale('nut_bam', $data_extend)}"{/if} nh-block="w8y3ejx" type-load="document-ready"></div>
        </div>
    </div>
{/if}
{/strip}