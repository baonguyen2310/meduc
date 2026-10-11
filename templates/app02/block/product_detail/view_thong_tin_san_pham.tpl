{assign var = product value = []}
{if !empty($data_block.data)}
	{assign var = product value = $data_block.data}
{/if}

{assign var = first_item value = []}
{if !empty($product.items[0])}
	{assign var = first_item value = $product.items[0]}
{/if}

{assign var = all_images value = []}
{if !empty($product.all_images)}
	{assign var = all_images value = $product.all_images}
{/if}
{if !empty($product)}
	{strip}
	{if !empty($product.content)}
		<div class="bg-white rounded mb-10 py-10 px-15 product-content">
		    <div class="items-prduct-content">
    			<div class="title-section-3">
    				{__d('template', 'thong_tin_san_pham')}
    			</div>
    			<div class="product-detail-footer content-product">
    				{$this->LazyLoad->renderContent($product.content)}
    			</div>
    			
    		</div>
    		<div class="load-more text-center">
                <a class="btn-view-all btn-show rounded" rel="nofolow">
                    {__d('template', 'xem_them')}
                    <i class="iconsax isax-arrow-right-3 pl-10"></i>
                </a>
                <a class="btn-view-all btn-hide rounded" rel="nofolow">
                    {__d('template', 'thu_gon')}
                    <i class="iconsax isax-arrow-right-3 pl-10"></i>
                </a>
            </div>
		</div>
	{/if}
    
{else}
	<p class="text-center font-danger mt-10">{__d('template', 'thong_tin_san_pham_khong_ton_tai')}</p>
{/if}