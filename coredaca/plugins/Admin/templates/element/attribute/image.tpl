
{if !empty($code)}
	{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
	{assign var = preview value = ''}

    {if !empty($value)}
        {$preview = "background-image: url('{CDN_URL}{$value}');background-size: contain;background-position: 50% 50%;"}
    {/if}
    
    <div class="clearfix">    	
	    <div class="kt-avatar kt-avatar--outline kt-avatar--circle- {if !empty($preview)}kt-avatar--changed{/if}">
	        <a {if !empty($value)}href="{CDN_URL}{$value}"{/if} target="_blank" class="kt-avatar__holder d-block" style="{$preview}"></a>
	        <label class="kt-avatar__upload btn-select-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'chon_anh')}" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id={$code}&lang={LANGUAGE_ADMIN}" data-type="iframe">
	            <i class="fa fa-pen"></i>
	        </label>
	        <span class="kt-avatar__cancel btn-clear-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'xoa_anh')}">
	            <i class="fa fa-times"></i>
	        </span>

	        <input id="{$code}" name="{$code}" value="{if !empty($value)}{htmlentities($value)}{/if}" type="hidden" input-attribute="image" />
	    </div>
    </div>
{/if}