{strip}

{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{assign var = element value = "item_da_dang_ky"}
{if !empty($data_extend['element'])}
    {assign var = element value = $data_extend['element']}
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <div class="box-head">
        <h3 class="inner-title">
            <span class="inner-icon">
                {$this->LazyLoad->renderImage([
                    'src' => "{CDN_URL}/media/core/logo/icon-leaf.svg", 
                    'alt' => "{$this->Block->getLocale('tieu_de', $data_extend)}"
                ])}
            </span>
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

{if !empty($data_block.data)}
    <div class="row g-5" data-course-license>
        {foreach from = $data_block.data item = product}
            {$this->element("../block/{$block_type}/{$element}", [
                'product' => $product,
                'col' => $col,
                'is_slider' => false
            ])}
        {/foreach} 
    </div>
    {if !empty($data_extend['locale'][{LANGUAGE}]['link_xem_them'])}
        <div class="text-center mt-10">
            <a href="{$this->Block->getLocale('link_xem_them', $data_extend)}" class="button-main-outline">
                <span>Xem thêm</span> <i class="fa-solid fa-angle-down"></i>
            </a>
        </div>
    {/if}
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}

{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}