{strip}
{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}
<div class="section-fash-sale py-lg-40 py-md-30 py-20" nh-lazy="image-background" data-src="{if !empty($data_extend.background)}{$this->Utilities->replaceVariableSystem($data_extend.background)}{/if}" >
    <div class="container">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <div class="title_sale d-flex flex-row align-items-center justify-content-between mb-lg-30 mb-15">
                <div class="title d-flex align-items-center">
                    <h3 class="title-section mr-md-20 mr-10 mb-0">
                        {$this->Block->getLocale('tieu_de', $data_extend)}
                    </h3>
                    {*<div class="time overflow-hidden py-10 px-10">
                        <span class="pr-5 fs-16">
                            {$this->Block->getLocale('ket_thuc', $data_extend)}:
                        </span>
                        <span id="time_sale_all_product" nh-time-end="{if !empty($data_extend.time)}{$data_extend.time}{/if}"></span>
                    </div>*}
                </div>
                
                <a class="color-hover fs-12 fs-md-16 " href="{if !empty($data_extend['locale'][{LANGUAGE}]['url'])}{$this->Block->getLocale('url', $data_extend)}{else}#{/if}">
                    {__d('template', 'xem_tat_ca')} <i class="pl-5 iconsax isax-arrow-right-1"></i>
                </a>
            </div>
        {/if}
        
        {if !empty($data_block.data)}
            {if empty(DEVICE)}
                <div class="content-fash-sale">
                    <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                        {foreach from = $data_block.data item = product}
                            {$this->element("../block/{$block_type}/item", [
                                'product' => $product, 
                                'is_slider' => true
                            ])}
                        {/foreach}
                    </div>
                </div>
            {/if}
            {if !empty(DEVICE)}
                <div class="view-product content-fash-sale">
                    <div class="row">
                        {foreach from = $data_block.data item = product}
                            {$this->element("../block/{$block_type}/item", [
                                'product' => $product, 
                                'col' => $col,
                                'is_slider' => false
                            ])}
                        {/foreach} 
                    </div>
                </div>
            {/if}
        {else}
            {__d('template', 'khong_co_du_lieu')}
        {/if}
    </div>
</div>

{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}