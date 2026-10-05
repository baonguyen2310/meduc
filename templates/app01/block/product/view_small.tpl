{strip}
{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <h3 class="title-section-1">
        {$this->Block->getLocale('tieu_de', $data_extend)}
    </h3>
{/if}
{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_2'])}
    <div class="title-section-2">
        <span>{$this->Block->getLocale('tieu_de_2', $data_extend)}</span>
    </div>
{/if}
<div class="view-small">
    {if !empty($data_block.data)}
        {foreach from = $data_block.data item = product}
            {$this->element("../block/{$block_type}/item_small", ['product' => $product])}
        {/foreach}
    {else}
        {__d('template', 'khong_co_du_lieu')}
    {/if}
</div>
{/strip}