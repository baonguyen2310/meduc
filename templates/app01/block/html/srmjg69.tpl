{strip}{if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam'])}
    <div class="text-center my-30">
        <div class="read-more-btn" data-sal-delay="450" data-sal="slide-up" data-sal-duration="800">
            <a class="edu-btn btn-ani" href="{if !empty($data_extend['locale'][{LANGUAGE}]['link_nut_bam'])}{$this->Block->getLocale('link_nut_bam', $data_extend)}{/if}">
                {$this->Block->getLocale('nut_bam', $data_extend)|nl2br} <i class="icon-arrow-right-line-right"></i>
            </a>
        </div>
    </div>
{/if}{/strip}