{strip}
{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <h3 class="title-section border-bottom">
        {$this->Block->getLocale('tieu_de', $data_extend)}
    </h3>
{/if}

{if !empty($data_block.data)}
    <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
        {foreach from = $data_block.data item = product}
            {$this->element("../block/{$block_type}/item", [
                'product' => $product, 
                'is_slider' => true
            ])}
        {/foreach}
    </div>
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}
{/strip}