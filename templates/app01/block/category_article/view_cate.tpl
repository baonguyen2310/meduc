{strip}
	<div class="row">
        <div class="col-lg-12 p-relative">
            <div class="section-title center-align mb-50 text-center">
                <h5>
                    {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                    	{$this->Block->getLocale('text_1', $data_extend)|nl2br}
                    {/if}
                </h5>
                <h2>
                    {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                    	{$this->Block->getLocale('text_2', $data_extend)|nl2br}
                    {/if}
                </h2>
            </div>
        </div>
    </div>

	{if !empty($data_block.data)}
	    <div class="team-area">
	        <div nh-menu="active">
	            <div class="row">
	                {$this->element('../block/category_article/item_cate', [
        	        	'categories' => $data_block.data,
        	        	'parent_id' => null
        	        ])}
    	        </div>
    	    </div>
	    </div>
	{/if}
{/strip}