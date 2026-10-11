<div class="kt-portlet kt-portlet--mobile kt-portlet--sortable mb-10 nh-template-portlet wrap-item {if !empty($album)}kt-portlet--collapse{/if}">
    <div class="kt-portlet__head p-5">
        <div class="kt-portlet__head-label ml-5">
            <h3 class="kt-portlet__head-title">
                {assign var = first_lang value = $languages|@key}
                {assign var = key_first_name value = "name_{$first_lang}"}
                
                {if !empty($album.$key_first_name)}
                    {$album.$key_first_name}
                {else}
                    New Item
                {/if}
            </h3>
        </div>

        <div class="kt-portlet__head-toolbar">
            <div class="kt-portlet__head-group">
                <span class="btn btn-sm btn-icon btn-danger btn-icon-md m-0 btn-delete-item">
                    <i class="la la-trash-o"></i>
                </span>

                <span class="btn btn-sm btn-icon btn-info btn-icon-md m-0 btn-toggle-item">
                    <i class="la la-angle-down"></i>
                </span>
            </div>
        </div>
    </div>

    <div class="kt-portlet__body p-10 " style="{if !empty($album)}display: none;{/if}">
        {assign var = key_code value = "code"}
        {assign var = code_random value = substr(md5(mt_rand()), 0, 10)}
        <input name="" data-name="code" value="{if !empty($album.$key_code)}{$album.$key_code}{else}{$code_random}{/if}" class="d-none" type="text">

        <div class="row">
            <div class="col-lg-6 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang name = title_item}
                        <div class="form-group">
                            <label>
                                {__d('admin', 'tieu_de')}
                                ({$language})
                                <span class="kt-font-danger">*</span>
                            </label>

                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            <i class="fa fa-align-left"></i>
                                        </div>
                                    </span>
                                </div>

                                {assign var = key_name value = "name_{$k_lang}"}
                                <input name="" data-name="name_{$k_lang}" value="{if !empty($album.$key_name)}{$album.$key_name}{/if}" class="form-control form-control-sm {if !empty($required)}required{/if} {if $smarty.foreach.title_item.first}item-name{/if}" type="text">

                                <div class="input-group-append">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$k_lang}.svg" alt="{$k_lang}" class="flag h-15px w-15px" />
                                        </div>
                                    </span>
                                </div>

                            </div>
                        </div>
                    {/foreach}
                {/if}
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Tiêu đề chương?
                            </label>

                            {assign var = key_chapter value = "chapter_{$k_lang}"}
                            <select name="" data-name="chapter_{$k_lang}" class="form-control form-control-sm">
                                <option value="n" {if !empty($album.$key_chapter) && $album.$key_chapter=="n"}selected{/if}>Không</option>
                                <option value="y" {if !empty($album.$key_chapter) && $album.$key_chapter=="y"}selected{/if}>Có</option>
                            </select>
                        </div>
                    {/foreach}
                {/if}
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Bài học thử?
                            </label>

                            {assign var = key_trial value = "trial_{$k_lang}"}
                            <select name="" data-name="trial_{$k_lang}" class="form-control form-control-sm">
                                <option value="n" {if !empty($album.$key_trial) && $album.$key_trial=="n"}selected{/if}>Không</option>
                                <option value="y" {if !empty($album.$key_trial) && $album.$key_trial=="y"}selected{/if}>Có</option>
                            </select>
                        </div>
                    {/foreach}
                {/if}
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Mã bài tập
                            </label>

                            <div class="input-group">
                                {assign var = key_quiz_id value = "quiz_id_{$k_lang}"}
                                <input name="" data-name="quiz_id_{$k_lang}" value="{if !empty($album.$key_quiz_id)}{$album.$key_quiz_id}{/if}" class="form-control form-control-sm" type="text" placeholder="Ví dụ: 40">
                            </div>
                        </div>
                    {/foreach}
                {/if}
            </div>
        </div>
        
        <div class="row">
            <div class="col-lg-12 col-12 d-none">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                {*__d('admin', 'mo_ta_ngan')*}
                                Danh sách học viên
                                ({$language})
                            </label>

                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            <i class="fa fa-file-alt w-20px"></i>
                                        </div>
                                    </span>
                                </div>

                                {assign var = key_description value = "description_{$k_lang}"}
                                <textarea name="" data-name="description_{$k_lang}" class="form-control" rows="5">{if !empty($album.$key_description)}{$album.$key_description}{/if}</textarea>

                                <div class="input-group-append">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$k_lang}.svg" alt="{$k_lang}" class="flag h-15px w-15px" />
                                        </div>
                                    </span>
                                </div>

                            </div>
                        </div>
                    {/foreach}
                {/if}
            </div>

            <div class="col-lg-12 col-md-12 col-sm-12 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                ID video youtube
                            </label>

                            <div class="input-group">
                                {assign var = key_youtube_id value = "youtube_id_{$k_lang}"}
                                <input name="" data-name="youtube_id_{$k_lang}" value="{if !empty($album.$key_youtube_id)}{$album.$key_youtube_id}{/if}" class="form-control form-control-sm" type="text" placeholder="Ví dụ: MvVYbNkP7Bg">
                            </div>
                        </div>
                    {/foreach}
                {/if}
            </div>
        </div>
        
        <div class="row">
            <div class="col-xl-6 col-lg-6">
                <label>
                    File Video
                </label>
                <div class="row wrap-files">
                    <div class="col-xl-12 col-lg-12">
                        <input id="{$code}_{$index}_files" name="" data-name="files" value="{if !empty($album.files)}{htmlentities($album.files)}{/if}" type="hidden" input-attribute="{ALBUM_IMAGE}" input-attribute-type="files" input-attribute-code="{$code}" />
                        <div class="list-files">
                            {if !empty($album.files)}
                                {assign var = files value = $album.files|@json_decode}
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
                    <div class="col-xl-12 col-lg-12 mt-10">
                        <span class="btn btn-sm btn-success btn-select-file" data-src="{CDN_URL}/filemanager/dialog.php?type=0&crossdomain=1&akey={$filemanager_access_key}&lang={LANGUAGE_ADMIN}&field_id={$code}_{$index}_files" data-type="iframe">
                            <i class="fa fa-file-alt"></i> 
                            Chọn video
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-xl-6 col-lg-6">
                <label>
                    File tài liệu
                </label>
                <div class="row wrap-files">
                    <div class="col-xl-12 col-lg-12">
                        <input id="{$code}_{$index}_filestwo" name="" data-name="filestwo" value="{if !empty($album.filestwo)}{htmlentities($album.filestwo)}{/if}" type="hidden" input-attribute="{ALBUM_IMAGE}" input-attribute-type="files" input-attribute-code="{$code}" />
                        <div class="list-files">
                            {if !empty($album.filestwo)}
                                {assign var = filestwo value = $album.filestwo|@json_decode}
                                {foreach from = $filestwo item = file}
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
                    <div class="col-xl-12 col-lg-12 mt-10">
                        <span class="btn btn-sm btn-success btn-select-file" data-src="{CDN_URL}/filemanager/dialog.php?type=0&crossdomain=1&akey={$filemanager_access_key}&lang={LANGUAGE_ADMIN}&field_id={$code}_{$index}_filestwo" data-type="iframe">
                            <i class="fa fa-file-alt"></i> 
                            {__d('admin', 'chon_tep')}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>