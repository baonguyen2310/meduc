{assign var = is_slider value = false}
{if !empty($data_extend['slider'])}
    {assign var = is_slider value = true}
{/if}

{assign var = element value = "item_search"}
{if !empty($data_extend['element'])}
    {assign var = element value = {$data_extend['element']}}
{/if}

{assign var = col value = ""}
{if !empty($data_extend['col'])}
    {assign var = col value = $data_extend['col']}
{/if}

{assign var = type_media value = ""}
{if !empty($data_extend['type_media'])}
    {assign var = type_media value = $data_extend['type_media']}
{/if}

{strip}
{assign var = category_info value = $this->Category->getInfoCategory(PAGE_CATEGORY_ID, ARTICLE)}
{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <div class="row">
        <div class="col-lg-12">
            <div class="section-title text-center mb--30" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_phu'])}
                <span class="pre-title">{$this->Block->getLocale('tieu_de_phu', $data_extend)|nl2br}</span>
                {/if}
                <h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)|nl2br}</h3>
            </div>
        </div>
    </div>
{/if}

{if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
    <div class="row align-items-center">
        <div class="col-lg-12">
            <div class="section-title center-align mb-50 text-center wow fadeInDown animated" data-animation="fadeInDown" data-delay=".4s">
                {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                    <h5>
                        {$this->Block->getLocale('text_1', $data_extend)}
                    </h5>
                {/if}
                <h2>
                    {$this->Block->getLocale('text_2', $data_extend)}
                </h2>
            </div>
        </div>
    </div>
{/if}

{if !empty($data_block.data)}
    <div class="row">
        {foreach from = $data_block.data item = article}
            {$this->element("../block/{$block_type}/{$element}", [
                'article' => $article,
                'is_slider' => $is_slider,
                'col' => $col,
                'type_media' => $type_media
            ])}
        {/foreach}
    </div>
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}

{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}