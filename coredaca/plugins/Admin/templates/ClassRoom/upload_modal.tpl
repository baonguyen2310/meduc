{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}    
<div class="form-group">
    <label>
        {__d('admin', 'anh_chinh')}
    </label>
    <div class="clearfix">
        {assign var = bg_avatar value = ''}
        {if !empty($quiz.image_avatar)}
            {assign var = bg_avatar value = "background-image: url('{CDN_URL}{$quiz.image_avatar}');background-size: contain;background-position: 50% 50%;"}
        {/if}

        <div class="kt-avatar kt-avatar--outline kt-avatar--circle- {if !empty($bg_avatar)}kt-avatar--changed{/if}">
            <a {if !empty($quiz.image_avatar)}href="{CDN_URL}{$quiz.image_avatar}"{/if} target="_blank" class="kt-avatar__holder d-block" style="{$bg_avatar}"></a>
            <label class="kt-avatar__upload btn-select-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'chon_anh')}" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id=image_avatar&lang={LANGUAGE_ADMIN}" data-type="iframe">
                <i class="fa fa-pen"></i>
            </label>
            <span class="kt-avatar__cancel btn-clear-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'xoa_anh')}">
                <i class="fa fa-times"></i>
            </span>

            <input id="image_avatar" name="image_avatar" value="{if !empty($quiz.image_avatar)}{htmlentities($quiz.image_avatar)}{/if}" type="hidden" />
        </div>
    </div>
</div>

<div class="form-group">
    <label>
        {__d('admin', 'anh_san_pham')}
    </label>
    <div class="row mb-10 wrap-album collapse show">
        <div class="col-lg-9 col-xl-8">
            <input id="album" name="album" upload-id="{if !empty($quiz.id)}{$quiz.id}{/if}" value="{if !empty($quiz.images)}{htmlentities($quiz.images|@json_encode)}{/if}" type="hidden" />
            <div class="list-image-album">
				{if !empty($quiz.images)}                       
				    {foreach from = $quiz.images item = image}
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

        <div class="col-lg-3 col-xl-2">
            <div class="row">
                <span class="col-lg-12 btn-sm btn btn-success btn-select-image-album" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&lang={LANGUAGE_ADMIN}&field_id=album" data-type="iframe">
                    <i class="fa fa-images"></i> 
                    {__d('admin', 'chon_anh')}
                </span>
                <span class="col-lg-12 btn-sm btn btn-danger btn-quick-upload kt-margin-t-10">
                    <i class="fa fa-cloud-upload-alt"></i> 
                    {__d('admin', 'cap_nhat')}
                </span>
            </div>
        </div>
    </div>
</div>