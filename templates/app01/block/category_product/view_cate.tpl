{foreach from = $breadcrumb item = item name = breadcrumb_each}
    {if $smarty.foreach.breadcrumb_each.last}
        <h3 class="title-section-1">{$item.name|escape}</h3>
    {/if}
{/foreach}
{*<h3 class="title-section-1">
	{$this->Block->getLocale('tieu_de', $data_extend)}
</h3>*}

{if !empty($data_block.data)}
    <ul class="categories-section list-unstyled">
        {$this->element('../block/category_product/item_cate', [
        	'categories' => $data_block.data,
        	'parent_id' => null
        ])}
    </ul>
{/if}

{assign member_info value = $this->Member->getMemberInfo()}
{assign var = url value = $this->Utilities->getUrlCurrent()}

{if !empty($member_info.code)}
    <div class="read-more-btn mt--15" style="max-width: 400px">
        <a 
            href="javascript:;"
            button-copy-link
            data-link="{$url}?a={$member_info.code}"
            class="edu-btn edu-btn-blue w-100 text-center"
        >
            Copy Link Affiliate
        </a>
    </div>
{/if}