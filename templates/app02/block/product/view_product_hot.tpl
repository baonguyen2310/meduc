{strip}
{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <h3 class="title-section text-center">
        {$this->Block->getLocale('tieu_de', $data_extend)}
    </h3>
{/if}
<div class="product-hot">
    {if !empty($data_block.data)}
        <div class="row">
            <div class="col-lg-8 col-md-7 col-12 product-hot-left">
                
                <div class="row">
                    {$this->element("../block/{$block_type}/item_hot_left", [
                        'product' => $data_block['data'][0],
                        'col' => "col-lg-12 col-12"
                    ])}
                </div>
                
            </div>
            <div class="col-lg-4 col-md-5 col-12 product-hot-right">
                {if count($data_block.data) > 1}
                    <div class="row">
                        {foreach from = $data_block.data item = product}
                            {if $product@index gte 1}
                    			{$this->element("../block/{$block_type}/item_hot_right", [
                                    'product' => $product,
                                    'col' => "col-lg-12 col-6"
                                ])}
                    		{/if}
                        {/foreach}
                    </div>
                {/if}
                
            </div>
        </div>
    {else}
        {__d('template', 'khong_co_du_lieu')}
    {/if}
</div>


{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}