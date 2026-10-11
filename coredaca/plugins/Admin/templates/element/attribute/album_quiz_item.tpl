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
            <div class="col-lg-12 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang name = title_item}
                        <div class="form-group">
                            <label>
                                Tên câu hỏi
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
        </div>
        
        <div class="row">
            <div class="col-lg-12 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Mô tả câu hỏi
                            </label>

                            {assign var = key_description value = "description_{$k_lang}"}
                            <textarea name="" data-name="description_{$k_lang}" data-type="editor">{if !empty($album.$key_description)}{$album.$key_description}{/if}</textarea>
                        </div>
                    {/foreach}
                {/if}
            </div>
        </div>

        <div class="row" box-choose>
            <div class="col-lg-12 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Danh sách lựa chọn
                            </label>

                            <div class="input-group mb-5">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            01
                                        </div>
                                    </span>
                                </div>
                                {assign var = key_option_one value = "option_one_{$k_lang}"}
                                <input name="" data-name="option_one_{$k_lang}" value="{if !empty($album.$key_option_one)}{$album.$key_option_one}{/if}" class="form-control form-control-sm" type="text" placeholder="Lựa chọn 01">
                            </div>

                            <div class="input-group mb-5">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            02
                                        </div>
                                    </span>
                                </div>
                                {assign var = key_option_two value = "option_two_{$k_lang}"}
                                <input name="" data-name="option_two_{$k_lang}" value="{if !empty($album.$key_option_two)}{$album.$key_option_two}{/if}" class="form-control form-control-sm" type="text" placeholder="Lựa chọn 02">
                            </div>

                            <div class="input-group mb-5">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            03
                                        </div>
                                    </span>
                                </div>
                                {assign var = key_option_three value = "option_three_{$k_lang}"}
                                <input name="" data-name="option_three_{$k_lang}" value="{if !empty($album.$key_option_three)}{$album.$key_option_three}{/if}" class="form-control form-control-sm" type="text" placeholder="Lựa chọn 03">
                            </div>

                            <div class="input-group mb-5">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            04
                                        </div>
                                    </span>
                                </div>
                                {assign var = key_option_four value = "option_four_{$k_lang}"}
                                <input name="" data-name="option_four_{$k_lang}" value="{if !empty($album.$key_option_four)}{$album.$key_option_four}{/if}" class="form-control form-control-sm" type="text" placeholder="Lựa chọn 04">
                            </div>

                            <div class="input-group mb-5">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <div class="list-flags">
                                            05
                                        </div>
                                    </span>
                                </div>
                                {assign var = key_option_five value = "option_five_{$k_lang}"}
                                <input name="" data-name="option_five_{$k_lang}" value="{if !empty($album.$key_option_five)}{$album.$key_option_five}{/if}" class="form-control form-control-sm" type="text" placeholder="Lựa chọn 05">
                            </div>

                        </div>
                    {/foreach}
                {/if}
            </div>
        </div>

        <div class="row" box-answer>
            <div class="col-lg-12 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Đáp án
                            </label>

                            {assign var = key_answer value = "answer_{$k_lang}"}
                            <select name="" data-name="answer_{$k_lang}" class="form-control form-control-sm">
                                <option value="1" {if !empty($album.$key_answer) && $album.$key_answer=="1"}selected{/if}>1</option>
                                <option value="2" {if !empty($album.$key_answer) && $album.$key_answer=="2"}selected{/if}>2</option>
                                <option value="3" {if !empty($album.$key_answer) && $album.$key_answer=="3"}selected{/if}>3</option>
                                <option value="4" {if !empty($album.$key_answer) && $album.$key_answer=="4"}selected{/if}>4</option>
                                <option value="5" {if !empty($album.$key_answer) && $album.$key_answer=="5"}selected{/if}>5</option>
                            </select>
                        </div>
                    {/foreach}
                {/if}
            </div>
        </div>

        <div class="row" box-answer-detail>
            <div class="col-lg-12 col-12">
                {if !empty($languages)}
                    {foreach from = $languages item = language key = k_lang}
                        <div class="form-group">
                            <label>
                                Đáp án chi tiết
                            </label>

                            {assign var = key_answer_detail value = "answer_detail_{$k_lang}"}
                            <textarea name="" data-name="answer_detail_{$k_lang}" data-type="editor">{if !empty($album.$key_answer_detail)}{$album.$key_answer_detail}{/if}</textarea>
                        </div>
                    {/foreach}
                {/if}
            </div>
        </div>
        
        <div class="row d-none">
            <div class="col-xl-6 col-lg-6">
                <label>
                    File Video
                </label>
                <div class="row wrap-files">
                    <div class="col-xl-12 col-lg-12">
                        <input id="{$code}_{$index}_files" name="" data-name="files" value="{if !empty($album.files)}{htmlentities($album.files)}{/if}" type="hidden" input-attribute="{ALBUM_QUIZ}" input-attribute-type="files" input-attribute-code="{$code}" />
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
                        <input id="{$code}_{$index}_filestwo" name="" data-name="filestwo" value="{if !empty($album.filestwo)}{htmlentities($album.filestwo)}{/if}" type="hidden" input-attribute="{ALBUM_QUIZ}" input-attribute-type="files" input-attribute-code="{$code}" />
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