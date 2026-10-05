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
    <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
        {foreach from = $data_block.data item = article}
            {$this->element("../block/{$block_type}/{$element}", [
                'article' => $article, 
                'is_slider' => $is_slider,
                'type_media' => $type_media
            ])}
        {/foreach} 
    </div>
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}
{/strip}