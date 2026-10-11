{if !empty($code)}
	{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
    {assign var = files value = []}
    {if !empty($value)}
        {$files = $value|json_decode:1}
    {/if}

	<div class="row">
        <div class="col-xl-8 col-lg-8">
            <div class="wrap-files">
                <input id="{$code}" name="{$code}" value="{if !empty($files)}{htmlentities($files|@json_encode)}{/if}" type="hidden" input-attribute="files" />
                <div class="list-files">
                    {if !empty($files)}
                        {foreach from = $files item = file}
                            <a href="{CDN_URL}{$file}" class="kt-media kt-media--lg mr-20 item-file" data-file="{$file}" target="_blank">
                                {assign var = file_type value = {$this->UtilitiesAdmin->getTypeFileByUrl($file)}}
                                <i class="fa fa-file{if !empty($file_type)}-{$file_type}{/if}"></i>
                                <span class="btn-clear-file" title="{__d('admin', 'xoa_tep')}">
                                    <i class="fa fa-times"></i>
                                </span>
                            </a>
                        {/foreach}
                    {/if}
                </div>
            </div>
        </div>
        
        <div class="col-xl-2 col-lg-4">
            <span class="col-12 btn btn-sm btn-success btn-select-file" data-src="{CDN_URL}/filemanager/dialog.php?type=0&multiple=1&crossdomain=1&akey={$filemanager_access_key}&field_id={$code}&lang={LANGUAGE_ADMIN}" data-type="iframe">
                <i class="fa fa-file-alt"></i> 
                {__d('admin', 'chon_tep')}
            </span>
        </div>
    </div>
{/if}