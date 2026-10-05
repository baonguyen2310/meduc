{if !empty($code)}
	{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
	{assign var = images value = []}
	{if !empty($value)}
		{$images = $value|json_decode:1}
	{/if}

	<div class="row wrap-album">
	    <div class="col-xl-8 col-lg-8">
	        <input id="{$code}" name="{$code}" value="{if !empty($value)}{htmlentities($value)}{/if}" type="hidden" input-attribute="images" />
	        <div class="clearfix mb-5 list-image-album">
	            {if !empty($images)}
	                {foreach from = $images item = image}
	                    <a href="{CDN_URL}{$image}" target="_blank" class="kt-media kt-media--lg mr-10 position-relative item-image-album" data-image="{$image}">
	                        <img src="{CDN_URL}{$image}">
	                        <span class="btn-clear-image-album" title="{__d('admin', 'xoa_anh')}">
	                            <i class="fa fa-times"></i>
	                        </span>
	                    </a>
	                {/foreach}
	            {/if}
	        </div>
	    </div>
	    <div class="col-xl-2 col-lg-4">
	        <span class="col-12 btn btn-sm btn-success btn-select-image-album" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id={$code}&lang={LANGUAGE_ADMIN}" data-type="iframe">
	            <i class="fa fa-images"></i> 
	            {__d('admin', 'chon_anh')}
	        </span>
	    </div>
	</div>
{/if}