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
    {assign var = licensed value = false}
    {assign member_info value = $this->Member->getMemberInfo()}
    {if !empty($member_info.code)}
        {assign var = code_member value = $member_info.code}
        {assign var = listClassRoom value = $this->Member->getListClassRoomByCustomerId($code_member)}
        
        {foreach from = $listClassRoom item = classRoom}
            {if $classRoom.product_id == $product.id}
                {assign var = licensed value = true}
                {break}
            {/if}
        {/foreach}
    {/if}
    
    <div class="inner-head">
        {if !empty($product.name)}
            <div class="course-details-content">
                <h1 class="title">
                    {$product.name|escape}
                </h1>
            </div>
        {/if}
        
        {assign var = rating value = 0}
        {if !empty($product.rating)}
            {assign var = rating value = $product.rating}
        {/if}
        {assign var = percen_rating value = ($rating/5)*100}
        <div class="product-rating d-flex align-items-center flex-nowrap mb-15">
            <div class="star-rating">
                <span style="width:{$percen_rating}%"></span>
            </div>
            <div class="inner-number-rating ml-10">
                {if !empty($product.rating_number)}{$product.rating_number}{else}0{/if} đánh giá
                
                (<i class="icon-draft-line"></i> {if !empty($product.comment)}{$product.comment|number_format:0:".":","}{else}0{/if} bình luận)
            </div>
        </div>
        
        {if !empty($product.attributes.motangan.value)}
            <div class="course-details-card course-details-desc mb-20">
                <div class="course-content">
                    {$product.attributes.motangan.value}
                </div>
            </div>
        {/if}
        
        {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat'])}
            <div class="inner-icon-logo">
                {$this->LazyLoad->renderImage([
            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat', $data_extend))}", 
            		'delay' => 'all'
            	])}
            </div>
        {/if}
    </div>
{/if}