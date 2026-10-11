{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="copyright-area">
    <div class="container">
        <div class="row">
            <div class="col-lg-12">
                {*if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                	<div class="inner-name">{$this->Block->getLocale('text_1', $data_extend)|nl2br}</div>
                {/if}
                {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                	<div class="inner-desc">{$this->Block->getLocale('text_2', $data_extend)|nl2br}</div>
                {/if*}
                {if !empty($data_extend['locale'][{LANGUAGE}]['copyright'])}
                	<div class="inner-copyright">{$this->Block->getLocale('copyright', $data_extend)|nl2br}</div>
                {/if}
                <div class="inner-images">
                	{if !empty($data_extend['locale'][{LANGUAGE}]['logo_dmca'])}
                	    <a href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_dmca'])}{$this->Block->getLocale('link_dmca', $data_extend)}{/if}" target="_blank">
                	        {$this->LazyLoad->renderImage([
                        		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('logo_dmca', $data_extend))}",
                        		'delay' => 'all'
                        	])}
                	    </a>
                    {/if}
                    {*if !empty($data_extend['locale'][{LANGUAGE}]['logo_bocongthuong'])}
                	    <a href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_bocongthuong'])}{$this->Block->getLocale('link_bocongthuong', $data_extend)}{/if}" target="_blank">
                	        {$this->LazyLoad->renderImage([
                        		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('logo_bocongthuong', $data_extend))}",
                        		'delay' => 'all'
                        	])}
                	    </a>
                    {/if*}
                </div>
            </div>
        </div>
    </div>
</div>{/strip}