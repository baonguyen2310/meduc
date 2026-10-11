{strip}
<div class="title-tab d-flex flex-column flex-sm-row justify-content-between align-items-center mb-30">
    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <h3 class="title-section mb-0">
            {$this->Block->getLocale('tieu_de', $data_extend)}
        </h3>
    {/if}
    <ul class="product-tab nav effect-nav mb-0">
        <li class="nav-item">
            <a class="nav-link active fs-12 fs-md-14" data-toggle="tab" href="#product-tab-1">
                {$this->Block->getLocale('tab_1', $data_extend)}
            </a>
        </li>
        {foreach from = $data_extend['block_tab'] key = key item = block_code}
            <li class="nav-item pl-15 pl-md-25">
                <a  nh-active-block="{$block_code}" class="nav-link fs-12 fs-md-16" data-toggle="tab" href="#product-{$key}">
                    {$this->Block->getLocale($key, $data_extend)}
                </a>
            </li>
        {/foreach} 
    </ul>
</div>

<div class="tab-content">
    <div id="product-tab-1" class="tab-pane active">
        {if !empty($data_block.data)}
            {if !empty($data_extend.slider)}
                <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                    {foreach from = $data_block.data item = product}
                        {$this->element("../block/{$block_type}/item", [
                            'product' => $product, 
                            'is_slider' => true
                        ])}
                    {/foreach} 
                </div>
            {else}
                <div class="row">
                    {foreach from = $data_block.data item = product}
                        {$this->element("../block/{$block_type}/item", [
                            'product' => $product, 
                            'col' => $col
                        ])}
                    {/foreach}
                </div>
            {/if}
        {else}
            {__d('template', 'khong_co_du_lieu')}
        {/if}
    </div>
    {foreach from = $data_extend['block_tab'] key = key item = block_code}
        <div id="product-{$key}" class="tab-pane fade">
            <div nh-block="{$block_code}" type-load="active"></div>
        </div>
    {/foreach}
</div>
{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}