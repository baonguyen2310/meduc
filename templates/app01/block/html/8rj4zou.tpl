{strip}<div class="about-intro">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-11 col-12">
                <div class="inner-main">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['hinh_anh'])}
                    	{$this->LazyLoad->renderImage([
                    		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('hinh_anh', $data_extend))}", 
                    		'class' => 'inner-image'
                    	])}
                    {/if}
                    
                    {if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
                        <div class="inner-desc">
                            {$this->Block->getLocale('mo_ta', $data_extend)|nl2br}
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>{/strip}