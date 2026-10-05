{assign var = url_list value = "{ADMIN_PATH}/class-room"}
{assign var = url_add value = "{ADMIN_PATH}/class-room/add"}
{assign var = url_edit value = "{ADMIN_PATH}/class-room/update"}
{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
{assign var = use_multiple_language value = {$this->LanguageAdmin->checkUseMultipleLanguage()}}
{assign var = list_languages value = $this->LanguageAdmin->getList()}

<div class="kt-subheader   kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {if !empty($title_for_layout)}{$title_for_layout}{/if}
            </h3>
        </div>

        <div class="kt-subheader__toolbar">
            {if !empty($url_list)}
                <a href="{$url_list}" class="btn btn-sm btn-secondary">
                    {__d('admin', 'quay_lai_danh_sach')}
                </a>
            {/if}

            {if !empty($url_edit) || !empty($url_add)}
                <div class="btn-group">
                    {if empty($id)}
                        <button data-link="{$url_edit}" data-update="1" id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                            <i class="la la-plus"></i>
                            {__d('admin', 'them_moi')} (F1)
                        </button>
                    {else}
                        <button id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                            <i class="la la-edit"></i>
                            {__d('admin', 'cap_nhat')} (F1)
                        </button>
                    {/if}
                    
                    <button type="button" class="btn btn-brand dropdown-toggle dropdown-toggle-split" data-toggle="dropdown"></button>
                    <div class="dropdown-menu dropdown-menu-right">
                        <ul class="kt-nav p-0">

                            {if !empty($url_add)}
                                <li class="kt-nav__item">
                                    <span data-link="{$url_add}" class="kt-nav__link btn-save">
                                        <i class="kt-nav__link-icon flaticon2-medical-records"></i>
                                        <span class="kt-nav__link-text">
                                            {__d('admin', 'luu_&_them_moi')}
                                        </span>
                                    </span>
                                </li>
                            {/if}

                            {if !empty($url_list)}
                                <li class="kt-nav__item">
                                    <span data-link="{$url_list}" class="kt-nav__link btn-save">
                                        <i class="kt-nav__link-icon flaticon2-hourglass-1"></i>
                                        <span class="kt-nav__link-text">
                                            {__d('admin', 'luu_&_quay_lai')}
                                        </span>
                                    </span>
                                </li>
                            {/if}
                        </ul>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <form id="main-form" action="{ADMIN_PATH}/class-room/save{if !empty($id)}/{$id}{/if}" method="POST" autocomplete="off">
        {if !empty($classRoom.id)}
            <div nh-anchor="thong_tin_cap_nhat" class="kt-portlet nh-portlet nh-active-hover position-relative">
                <div class="kt-portlet__head">
                    <div class="kt-portlet__head-label">
                        <h3 class="kt-portlet__head-title">
                            {__d('admin', 'thong_tin_cap_nhat')}
                        </h3>
                    </div>
                </div>

                <div class="kt-portlet__body pb-0">
                    <div class="row">
                        <div class="col-lg-6 col-xs-6">
                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'trang_thai')}
                                </label>

                                <div class="col-lg-8 col-xl-8">
                                    {if isset($classRoom.status) && $classRoom.status == 1}
                                        <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'hoat_dong')}
                                        </span>
                                    {elseif isset($classRoom.status) && $classRoom.status == 0}
                                        <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'khong_hoat_dong')}
                                        </span>   
                                    {elseif isset($classRoom.status) && $classRoom.status == -1}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'cho_duyet')}
                                        </span>   
                                    {/if}
                                </div>
                            </div>

                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'thoi_gian_tao')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    <span class="form-control-plaintext kt-font-bolder">
                                        {if !empty($classRoom.created)}
                                            {$classRoom.created}
                                        {/if}
                                    </span>
                                </div>
                            </div>

                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'cap_nhat_moi')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    <span class="form-control-plaintext kt-font-bolder">
                                        {if !empty($classRoom.updated)}
                                            {$classRoom.updated}
                                        {/if}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        {/if}

        <div nh-anchor="thong_tin_co_ban" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'thong_tin_co_ban')}
                    </h3>
                </div>
            </div>
            
            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        Tên lớp học
                         <span class="kt-font-danger">*</span>
                    </label>
                    <input name="name" value="{if !empty($classRoom.name)}{$classRoom.name|escape}{/if}" class="form-control form-control-sm nh-format-link" type="text" maxlength="255">
                </div>
                <div id="wrap-category" class="row">
                    <div class="col-lg-12">
                        <div class="form-group">
                            <label>
                                Khóa học
                                <span class="kt-font-danger">*</span>
                            </label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <i class="fa fa-align-justify w-20px"></i>
                                    </span>
                                </div>
                                {assign var = courses value = $this->CategoryAdmin->getListCourse()}

                                {assign var = course_selected value = ""}
                                {if !empty($classRoom.product_id)}
                                    {$course_selected = $classRoom.product_id}
                                {/if}

                                {$this->Form->select('product_id', $courses, ['id' => 'product_id', 'empty' => null, 'default' => $course_selected, 'class' => 'form-control'])}
                            </div>
                        </div>
                    </div>
                </div>
                

                <div class="row d-none">
                    <div class="col-xl-2 col-lg-3">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'vi_tri')}
                            </label>
                            <input name="position" value="{$position}" class="form-control form-control-sm" type="text">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        {*<div nh-anchor="media" class="kt-portlet nh-portlet nh-active-hover position-relative d-none">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'media')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        {__d('admin', 'anh_chinh')}
                    </label>
                    <div class="clearfix">
                        {assign var = bg_avatar value = ''}
                        {if !empty($classRoom.image_avatar)}
                            {assign var = bg_avatar value = "background-image: url('{CDN_URL}{$classRoom.image_avatar}');background-size: contain;background-position: 50% 50%;"}
                        {/if}

                        <div class="kt-avatar kt-avatar--outline kt-avatar--circle- {if !empty($bg_avatar)}kt-avatar--changed{/if}">
                            <a {if !empty($classRoom.image_avatar)}href="{CDN_URL}{$classRoom.image_avatar}"{/if} target="_blank" class="kt-avatar__holder d-block" style="{$bg_avatar}"></a>
                            <label class="kt-avatar__upload btn-select-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'chon_anh')}" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id=image_avatar&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                <i class="fa fa-pen"></i>
                            </label>
                            <span class="kt-avatar__cancel btn-clear-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'xoa_anh')}">
                                <i class="fa fa-times"></i>
                            </span>

                            <input id="image_avatar" name="image_avatar" value="{if !empty($classRoom.image_avatar)}{htmlentities($classRoom.image_avatar)}{/if}" type="hidden" />
                        </div>
                    </div>
                </div>

                <div class="form-group d-none">
                    <label>
                        {__d('admin', 'album_anh')}
                    </label>
                    <div class="row wrap-album">
                        <div class="col-xl-8 col-lg-8">
                            <input id="images" name="images" value="{if !empty($classRoom.images)}{htmlentities($classRoom.images|@json_encode)}{/if}" type="hidden" />
                            <div class="clearfix mb-5 list-image-album">
                                {if !empty($classRoom.images)}
                                    {foreach from = $classRoom.images item = image}
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
                            <span class="col-12 btn btn-sm btn-success btn-select-image-album" data-src="{CDN_URL}/filemanager/dialog.php?type=1&multiple=1&crossdomain=1&akey={$filemanager_access_key}&field_id=images&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                <i class="fa fa-images"></i> 
                                {__d('admin', 'chon_anh_album')}
                            </span>
                        </div>
                    </div>                            
                </div>

                <div class="form-group d-none">
                    <label>
                        {__d('admin', 'tep_dinh_kem')}
                    </label>
                    <div class="row">
                        <div class="col-xl-8 col-lg-8">
                            <div class="wrap-files">
                                <input id="files" name="files" value="{if !empty($classRoom.files)}{htmlentities($classRoom.files|@json_encode)}{/if}" type="hidden" />
                                <div class="list-files">                                
                                    {if !empty($classRoom.files)}
                                        {foreach from = $classRoom.files item = file}
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
                            <span class="col-12 btn btn-sm btn-success btn-select-file" data-src="{CDN_URL}/filemanager/dialog.php?type=0&multiple=1&crossdomain=1&akey={$filemanager_access_key}&field_id=files&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                <i class="fa fa-file-alt"></i> 
                                {__d('admin', 'chon_tep')}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="form-group d-none">
                    <label>
                        {__d('admin', 'duong_dan_video')}
                    </label>

                    <div class="row wrap-video">
                        <div class="col-xl-8 col-lg-8">
                            <input name="url_video" id="url_video" value="{if !empty($classRoom.url_video)}{$classRoom.url_video}{/if}" type="text" class="form-control form-control-sm">
                            <span class="form-text text-muted">
                                {__d('admin', 'voi_kieu_video_youtube_url_chi_dien_ma_video')} 
                                <img src="{ADMIN_PATH}/assets/media/note/upload_video.png" width="300px" />
                            </span>
                        </div>

                        <div class="col-xl-4 col-lg-4">
                            <div class="row">
                                <div class="col-xl-6 col-lg-12">
                                    {$this->Form->select('type_video', $this->ListConstantAdmin->listTypeVideo(), ['id' => 'type_video', 'empty' => null, 'default' => "{if !empty($classRoom.type_video)}{$classRoom.type_video}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker mb-10'])}
                                </div>

                                <div class="col-xl-6 col-lg-12">
                                    <span class="col-12 btn btn-sm btn-success d-none btn-select-video" data-src="{CDN_URL}/filemanager/dialog.php?type=3&crossdomain=1&akey={$filemanager_access_key}&field_id=url_video&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                        <i class="fa fa fa-photo-video"></i> 
                                        {__d('admin', 'chon_video')}
                                    </span>
                                </div>
                            </div>                                    
                        </div>                                
                    </div>
                </div>
            </div>
        </div>*}

        <div nh-anchor="thanh_vien" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Thành viên
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        Danh sách thành viên
                    </label>                            
                    <div class="clearfix">
                        <textarea name="users" id="users" class="mce-editor-simple">
                            {if !empty($classRoom.users)}{$classRoom.users}{/if}
                        </textarea>
                    </div>
                </div>
            </div>
        </div>

        <div nh-anchor="mo_ta_bai_viet" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Mô tả lớp học
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        {__d('admin', 'mo_ta_ngan')}
                    </label>
                    <div class="clearfix">
                        <textarea name="description" id="description" class="mce-editor-simple">
                            {if !empty($classRoom.description)}{$classRoom.description}{/if}
                        </textarea>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>