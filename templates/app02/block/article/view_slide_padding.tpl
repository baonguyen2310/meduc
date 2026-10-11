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
    <div class="title-tab d-flex align-items-center justify-content-between pb-md-10 pb-0 mb-15 mb-md-30">
        <h3 class="title-section text-left mb-0">
            {$this->Block->getLocale('tieu_de', $data_extend)}
        </h3>
        <a class="font-weight-bold color-main " href="{if !empty($data_extend['locale'][{LANGUAGE}]['url'])}{$this->Block->getLocale('url', $data_extend)}{else}#{/if}">
            {__d('template', 'xem_tat_ca')} <i class="pl-5 iconsax isax-arrow-right-1"></i>
        </a>
    </div>
{/if}

{if !empty($data_block.data)}
    <div class="slide-padding" nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
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