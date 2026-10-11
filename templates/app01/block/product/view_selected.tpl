{strip}

{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{assign var = element value = "item_selected"}
{if !empty($data_extend['element'])}
    {assign var = element value = $data_extend['element']}
{/if}
{if !empty($data_block.data)}
    {foreach from = $data_block.data item = product}
        {$this->element("../block/{$block_type}/{$element}", [
            'product' => $product,
            'col' => $col,
            'is_slider' => false
        ])}
    {/foreach}
{/if}
{/strip}