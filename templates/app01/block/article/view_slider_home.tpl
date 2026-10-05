{assign var = is_slider value = false}
{if !empty($data_extend['slider'])}
    {assign var = is_slider value = true}
{/if}

{assign var = element value = "item"}
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


<div class="row g-5">
    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        <div class="col-lg-6 col-md-6 col-12" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
            <div class="section-title text-start">
                {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de_phu'])}
                    <span class="pre-title">{$this->Block->getLocale('tieu_de_phu', $data_extend)|nl2br}</span>
                {/if}
                <h3 class="title">{$this->Block->getLocale('tieu_de', $data_extend)|nl2br}</h3>
            </div>
        </div>
    {/if}
    {if !empty($data_extend['locale'][{LANGUAGE}]['link_xem_them'])}
        <div class="col-lg-6 col-md-6 col-12">
            <div class="load-more-btn text-start text-md-end">
                <a class="edu-btn btn-ani" href="{$this->Block->getLocale('link_xem_them', $data_extend)|nl2br}">
                    Xem Thêm <i class="icon-arrow-right-line-right"></i>
                </a>
            </div>
        </div>
    {/if}
</div>

{if !empty($data_block.data)}
    <div class="mt--40 mb--50 edu-slick-button slick-activation-wrapper eduvibe-course-one-carousel eduvibe-course-carousel-page-with-dots">
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

<div class="shape-dot-wrapper shape-wrapper d-xl-block d-none">
    <div class="shape-image shape-image-1">
        <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-32.png" alt="Shape Thumb" />
    </div>
    <div class="shape-image shape-image-3">
        <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-27-01.png" alt="Shape Thumb" />
    </div>
</div>
{/strip}