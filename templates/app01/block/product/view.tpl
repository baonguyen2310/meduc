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
    <div class="row">
        <div class="col-lg-12">
            <div class="section-title text-center mb--30" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_phu'])}
                <span class="pre-title">{$this->Block->getLocale('tieu_de_phu', $data_extend)|nl2br}</span>
                {/if}
                <h3 class="title">
                    <img class="inner-icon" src="{CDN_URL}/media/core/logo/linh-vat-1.png" />
                    {$this->Block->getLocale('tieu_de', $data_extend)|nl2br}
                    </h3>
            </div>
        </div>
    </div>
{/if}

{if !empty($data_block.data)}
    <div class="row g-4 mt--10">
        {foreach from = $data_block.data item = product}
            {$this->element("../block/{$block_type}/{$element}", [
                'product' => $product,
                'col' => $col,
                'is_slider' => false
            ])}
        {/foreach} 
    </div>
    {if !empty($data_extend['locale'][{LANGUAGE}]['link_xem_them'])}
        <div class="load-more-btn">
            <a class="edu-btn" href="{$this->Block->getLocale('link_xem_them', $data_extend)}">
                Xem thêm <i class="icon-arrow-right-line-right"></i>
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