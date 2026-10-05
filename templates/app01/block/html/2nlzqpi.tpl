{strip}<div class="box-mission">
    <div class="container">
        <div class="row g-5">
            <div class="col-lg-12">
                <div class="section-title text-center" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                    	<h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)|nl2br}</h3>
                    {/if}
                </div>
            </div>
        </div>
        <div class="row mt-30">
            <div class="col-lg-6">
                <div class="inner-box">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['anh_tam_nhin'])}
                    	{$this->LazyLoad->renderImage([
                    		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('anh_tam_nhin', $data_extend))}"
                    	])}
                    {/if}
                    <div class="inner-content inner-text-right">
                        <div class="inner-title" data-sal="slide-right" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                            	{$this->Block->getLocale('text_1', $data_extend)|nl2br}
                            {/if}
                        </div>
                        <div class="inner-desc" data-sal="slide-right" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                            	{$this->Block->getLocale('text_2', $data_extend)|nl2br}
                            {/if}
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="inner-box">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['anh_su_menh'])}
                    	{$this->LazyLoad->renderImage([
                    		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('anh_su_menh', $data_extend))}"
                    	])}
                    {/if}
                    <div class="inner-content inner-text-left">
                        <div class="inner-title" data-sal="slide-left" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['text_3'])}
                            	{$this->Block->getLocale('text_3', $data_extend)|nl2br}
                            {/if}
                        </div>
                        <div class="inner-desc" data-sal="slide-left" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['text_4'])}
                            	{$this->Block->getLocale('text_4', $data_extend)|nl2br}
                            {/if}
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-12">
                <div class="inner-box inner-image-auto">
                    {if !empty($data_extend['locale'][{LANGUAGE}]['anh_gia_tri_cot_loi'])}
                    	{$this->LazyLoad->renderImage([
                    		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('anh_gia_tri_cot_loi', $data_extend))}"
                    	])}
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>{/strip}