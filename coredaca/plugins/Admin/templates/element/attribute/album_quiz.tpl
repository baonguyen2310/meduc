{assign var = languages value = $this->LanguageAdmin->getList()}
{assign var = filemanager_access_key value = $this->SystemAdmin->getAccessKeyUpload()}

{assign var = albums value = []}
{if !empty($value)}
    {$albums = $value|json_decode:1}
{/if}

<div attribute-code="{$code}" class="wrap-manager">
    <div class="list-item ui-sortable" id="wrap-item-config">
        {if !empty($albums)}
            {foreach from = $albums key = index item = album}
                {$this->element('Admin.attribute/album_quiz_item', [
                    'code' => $code,
                    'languages' => $languages,
                    'album' => $album,
                    'filemanager_access_key' => $filemanager_access_key,
                    'index' => $index
                ])}
            {/foreach}
        {else}
            {$this->element('Admin.attribute/album_quiz_item', [
                'code' => $code,
                'languages' => $languages,
                'album' => [],
                'filemanager_access_key' => $filemanager_access_key,
                'index' => 0
            ])}
        {/if}
    </div>
    <div class="form-group">
        <span id="add-item" class="btn btn-sm btn-success">
            <i class="fa fa-plus"></i>
            Thêm câu hỏi
        </span>
    </div>
</div>