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


{if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
    <h3 class="title-section text-left mb-40">
        {$this->Block->getLocale('tieu_de', $data_extend)}
    </h3>
{/if}

 {if !empty($data_block.data)}
    <div class="article-slide-list ">
        <div class="article-slide p-15 bg-white mb-15 rounded-10">
            {if count($data_block.data) > 1}
                <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                    {foreach from = $data_block.data item = $article}
                        {if $article@index gte 1 && $article@index lte 5}
                            {$this->element("../block/{$block_type}/item_slide_list", [
                                'article' => $article, 
                                'is_slider' => $is_slider,
                                'type_media' => $type_media
                            ])}
                        {/if}
                    {/foreach}
                </div>
            {/if}
        </div>
        <div class="article-list">
            {if count($data_block.data) > 5}
                <div class="row">
                    {foreach from = $data_block.data item = $article}
                        {if $article@index gte 5}
                            {$this->element("../block/{$block_type}/item_list", [
                                'article' => $article,
                                'col' => $col,
                                'type_media' => $type_media
                            ])}
                        {/if}
                    {/foreach}
                </div>
            {/if}
        </div>
    </div>
{else}
    {__d('template', 'khong_co_du_lieu')}
{/if}

{if !empty($block_config.has_pagination) && !empty($data_block[{PAGINATION}])}
    {$this->element('pagination', ['pagination' => $data_block[{PAGINATION}]])}
{/if}
{/strip}