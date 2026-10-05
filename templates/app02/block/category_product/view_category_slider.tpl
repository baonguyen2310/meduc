{strip}
<div class="py-30" nh-lazy="image-background" data-src="{URL_TEMPLATE}assets/media/template/bg_featured_category.jpg">
    <div class="container">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <div class="line-af mb-50 position-relative text-center">
                <h3 class="font-weight-bold fs-11 fs-lg-7 m-0 text-center text-uppercase title-section">
                    {$this->Block->getLocale('tieu_de', $data_extend)}
                </h3>
            </div>
        {/if}
        
        {if !empty($data_block.data)}
            <div nh-owl-slick="{if !empty($data_extend.slider)}{htmlentities($data_extend.slider|@json_encode)}{/if}">
                {$this->element('../block/category_product/item_list_img', [
                	'categories' => $data_block.data,
                	'parent_id' => null,
                	'is_slider' => true
                ])}
            </div>
        {/if}
    </div>
</div>

{/strip}