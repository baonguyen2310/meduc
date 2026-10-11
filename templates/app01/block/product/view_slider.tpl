{strip}
{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{assign var = element value = "item"}
{if !empty($data_extend['element'])}
    {assign var = element value = $data_extend['element']}
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <div class="box-head">
        <h3 class="inner-title">
            <span class="inner-title-main">
                {$this->Block->getLocale('tieu_de', $data_extend)}
            </span>
        </h3>
        <div class="inner-dir"></div>
        {if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
            <div class="inner-desc">
                {$this->Block->getLocale('mo_ta', $data_extend)}
            </div>
        {/if}
    </div>
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_2'])}
    <div class="title-section-2">
        <span>
            {$this->Block->getLocale('tieu_de_2', $data_extend)}
        </span>
    </div>
{/if}

{if !empty($data_block.data)}
    <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
        {foreach from = $data_block.data item = product}
            {$this->element("../block/{$block_type}/{$element}", [
                'product' => $product, 
                'is_slider' => true
            ])}
        {/foreach}
    </div>
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}
{/strip}