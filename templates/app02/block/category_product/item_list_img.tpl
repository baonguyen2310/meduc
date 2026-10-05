{strip}
{if !empty($categories)}
    {foreach from = $categories item = category}
        <div class="col-6 col-md-6">
            {if !empty($category.image_avatar)}
                {assign var = image value = "{CDN_URL}{$this->Utilities->replaceVariableSystem($category.image_avatar)}"}
            {else}
                {assign var = image value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
            {/if}
            
            <div class="list_category bg-white position-relative">
                <div class="img_category position-relative mb-0 rti-100">
                    <a {if !empty($category.url)}href="{$this->Utilities->checkInternalUrl($category.url)}"{/if}>
                        {$this->LazyLoad->renderImage([
                            'src' => "{if !empty($image)}{$image}{/if}", 
                            'alt' => "{if !empty($category.name)}{$category.name}{/if}", 
                            'class' => 'img-fluid rti-abs-cover'
                        ])}
                    </a>
                </div>
                
                <div class="item-des-category text-center">
                    <div class="item-title-category">
                        <a {if !empty($category.url)}href="{$this->Utilities->checkInternalUrl($category.url)}"{/if} class="fs-19 fs-md-17 d-inline-block py-10 px-md-30 px-20 rounded-pill color-black text-uppercase">
            				{$category.name|escape|truncate:80:" ..."}
            			</a>
                    </div>
                    
                </div>
                
    		</div>
    	</div>
    {/foreach}
{/if}
{/strip}