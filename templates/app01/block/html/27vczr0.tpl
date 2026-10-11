{strip}<div class="home-intro">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6 col-md-12 my-2">
                <iframe width="560" height="315" src="https://www.youtube.com/embed/{if !empty($data_extend['locale'][{LANGUAGE}]['id_video_youtube'])}{$this->Block->getLocale('id_video_youtube', $data_extend)}{/if}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
            </div>
            <div class="col-lg-6 col-md-12 my-2">
                <div class="inner-info">
                    <div class="inner-title" data-sal="slide-up" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                        	{$this->Block->getLocale('text_1', $data_extend)|nl2br}
                        {/if}
                    </div>
                    <div class="inner-sub-title" data-sal="slide-up" data-sal-delay="400" data-sal-easing="ease-out-back" data-sal-duration="800">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                        	{$this->Block->getLocale('text_2', $data_extend)|nl2br}
                        {/if}
                    </div>
                    <div class="inner-line" data-sal="slide-up" data-sal-delay="500" data-sal-easing="ease-out-back" data-sal-duration="800"></div>
                    <div class="inner-desc" data-sal="slide-up" data-sal-delay="600" data-sal-easing="ease-out-back" data-sal-duration="800">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_3'])}
                        	{$this->Block->getLocale('text_3', $data_extend)|nl2br}
                        {/if}
                    </div>
                    <div class="inner-name" data-sal="slide-up" data-sal-delay="700" data-sal-easing="ease-out-back" data-sal-duration="800">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_4'])}
                        	{$this->Block->getLocale('text_4', $data_extend)|nl2br}
                        {/if}
                    </div>
                    <div class="inner-company" data-sal="slide-up" data-sal-delay="800" data-sal-easing="ease-out-back" data-sal-duration="800">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_5'])}
                        	{$this->Block->getLocale('text_5', $data_extend)|nl2br}
                        {/if}
                    </div>
                    <a href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_nut_bam'])}{$this->Block->getLocale('link_nut_bam', $data_extend)}{/if}"
                        class="edu-btn btn-small px-30 btn-ani"
                        data-sal="slide-up"
                        data-sal-delay="900"
                        data-sal-easing="ease-out-back"
                        data-sal-duration="800"
                    >
                        {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}
                        	{$this->Block->getLocale('nut_bam', $data_extend)|nl2br}
                        {/if}
                    </a>
                    {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat'])}
                        <div class="inner-icon-logo">
                            {$this->LazyLoad->renderImage([
                        		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat', $data_extend))}", 
                        		'delay' => 'all'
                        	])}
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>{/strip}