{strip}
{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <h3 class="title-section text-center mb-10">
        {$this->Block->getLocale('tieu_de', $data_extend)}
    </h3>
{/if}
{if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
    <p class="description-section text-center mb-lg-30 mb-20">
        {$this->Block->getLocale('mo_ta', $data_extend)}
    </p>
{/if}

{if !empty($data_block.data)}
    <div class="view-product">
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
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}

{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}