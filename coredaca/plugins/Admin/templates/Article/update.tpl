{assign var = url_list value = "{ADMIN_PATH}/article"}
{assign var = url_add value = "{ADMIN_PATH}/article/add"}
{assign var = url_edit value = "{ADMIN_PATH}/article/update"}
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
                <a href="{$url_list}" class="btn btn-sm btn-secondary" btn-back-custom>
                    {__d('admin', 'quay_lai_danh_sach')}
                </a>
            {/if}

            {*if empty($id) || !empty($article.draft)}
                <span class="btn btn-sm btn-dark btn-save-draft">
                    {__d('admin', 'luu_nhap')}
                </span>
            {/if*}

            {if !empty($url_edit) || !empty($url_add)}
                <div class="btn-group">
                    {if empty($id)}
                        {*<button data-link="{$url_edit}" data-update="1" id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                            <i class="la la-plus"></i>
                            {__d('admin', 'them_moi')} (F1)
                        </button>*}
                        <span data-link="{$url_list}" type="button" class="btn btn-sm btn-brand btn-save" btn-custom>
                            <i class="la la-plus"></i>
                            Thêm mới
                        </span>
                    {else}
                        <button id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                            <i class="la la-edit"></i>
                            {__d('admin', 'cap_nhat')} (F1)
                        </button>
                    {/if}
                    
                    {*<button type="button" class="btn btn-brand dropdown-toggle dropdown-toggle-split" data-toggle="dropdown"></button>
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
                    </div>*}
                </div>
            {/if}
        </div>
    </div>
</div>

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <form id="main-form" action="{ADMIN_PATH}/article/save{if !empty($id)}/{$id}{/if}" method="POST" autocomplete="off">
        <div class="d-none">
            <input type="hidden" name="draft" value="">
            <input type="hidden" name="seo_score" value="" id="seo-score">
            <input type="hidden" name="keyword_score" value="" id="keyword-score">
        </div>

        {if !empty($article.id)}
            <div nh-anchor="thong_tin_cap_nhat" class="kt-portlet nh-portlet nh-active-hover position-relative">
                <div class="kt-portlet__head">
                    <div class="kt-portlet__head-label">
                        <h3 class="kt-portlet__head-title">
                            {__d('admin', 'thong_tin_cap_nhat')}
                        </h3>
                    </div>

                    {if !empty($article.url)}
                        <div class="kt-portlet__head-toolbar">
                            <a target="_blank" href="/{$article.url}" class="kt-link kt-font-bolder kt-link--info">
                                {__d('admin', 'xem_bai_viet')}
                            </a>
                        </div>
                    {/if}
                </div>

                <div class="kt-portlet__body pb-0">
                    <div class="row">
                        <div class="col-lg-6 col-xs-6">
                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'trang_thai')}
                                </label>

                                <div class="col-lg-8 col-xl-8">
                                    {if !empty($article.draft)}
                                        <span class="kt-badge kt-badge--dark kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'ban_luu_nhap')}
                                        </span>
                                    {/if}

                                    {if isset($article.status) && $article.status == 1}
                                        <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'hoat_dong')}
                                        </span>
                                    {elseif isset($article.status) && $article.status == 0}
                                        <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'khong_hoat_dong')}
                                        </span>   
                                    {elseif isset($article.status) && $article.status == -1}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'cho_duyet')}
                                        </span>   
                                    {/if}
                                </div>
                            </div>

                            <div class="form-group form-group-xs row d-none">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'nguoi_tao')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    <span class="form-control-plaintext kt-font-bolder">
                                        {if !empty($article.user_full_name)}
                                            {$article.user_full_name}
                                        {/if}
                                    </span>
                                </div>
                            </div>

                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'thoi_gian_tao')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    <span class="form-control-plaintext kt-font-bolder">
                                        {if !empty($article.created)}
                                            {$article.created}
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
                                        {if !empty($article.updated)}
                                            {$article.updated}
                                        {/if}
                                    </span>
                                </div>
                            </div>
                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'seo')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    {if !empty($article.seo_score) && $article.seo_score == 'success'}
                                        <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'tot')}
                                        </span>
                                    {elseif !empty($article.seo_score) && $article.seo_score == 'warning'}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'binh_thuong')}
                                        </span>
                                    {elseif !empty($article.seo_score) && $article.seo_score == 'danger'}
                                        <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'chua_dat')}
                                        </span>
                                    {else}
                                        <span class="form-control-plaintext">
                                            <em>{__d('admin', 'chua_co')}</em>
                                        </span>
                                    {/if}
                                </div>
                            </div>
                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'tu_khoa')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    {if !empty($article.keyword_score) && $article.keyword_score == 'success'}
                                        <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'tot')}
                                        </span>
                                    {elseif !empty($article.keyword_score) && $article.keyword_score == 'warning'}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'binh_thuong')}
                                        </span>
                                    {elseif !empty($article.keyword_score) && $article.keyword_score == 'danger'}
                                        <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'chua_dat')}
                                        </span>
                                    {else}
                                        <span class="form-control-plaintext">
                                            <em>{__d('admin', 'chua_co')}</em>
                                        </span>
                                    {/if}
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6 col-xs-6">  
                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'ngon_ngu_hien_tai')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    <span class="form-control-plaintext kt-font-bolder">
                                        <div class="list-flags">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$lang}.svg" alt="{$lang}" class="flag mr-10" />
                                            {if !empty($list_languages[$lang])}
                                                {$list_languages[$lang]}
                                            {/if}
                                        </div>
                                    </span>
                                </div>
                            </div>
                            
                            {assign var = all_name_content value = $this->ArticleAdmin->getAllNameContent($id)}
                            {if !empty($use_multiple_language) && !empty($list_languages) }
                                <div class="form-group form-group-xs row">
                                    <label class="col-lg-4 col-xl-4 col-form-label">
                                        {__d('admin', 'sua_ban_dich')}
                                    </label>
                                    <div class="col-lg-12 col-xs-12">
                                        <table class="table table-bordered mb-10">
                                            <tbody>
                                                {foreach from = $list_languages key = k_language item = language}
                                                    <tr>
                                                        <td class="w-90">
                                                            <div class="list-flags d-inline mr-5">
                                                                <img src="{ADMIN_PATH}{FLAGS_URL}{$k_language}.svg" alt="{$k_language}" class="flag" />
                                                            </div>
                                                            {$language}: 
                                                            <i>
                                                                {if !empty($all_name_content[$k_language])}
                                                                    {$all_name_content[$k_language]|truncate:100:" ..."}
                                                                {else}
                                                                    <span class="kt-font-danger fs-12">
                                                                        {__d('admin', 'chua_nhap')}
                                                                    </span>
                                                                {/if}
                                                            </i>

                                                            <a href="{ADMIN_PATH}/article/update/{$article.id}?lang={$k_language}" class="pl-10">
                                                                <i class="fa fa-pencil-alt"></i>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                {/foreach}
                                            </tbody>
                                        </table>
                                    </div>                                            
                                </div>
                            {/if}
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
                        {__d('admin', 'tieu_de')}
                         <span class="kt-font-danger">*</span>
                    </label>
                    <input name="name" value="{if !empty($article.name)}{$article.name|escape}{/if}" class="form-control form-control-sm nh-format-link" type="text" maxlength="255">
                </div>

                <div class="form-group">
                    <label>
                        {__d('admin', 'duong_dan')}
                        <span class="kt-font-danger">*</span>
                    </label>
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">
                                <i class="la la-link"></i>
                            </span>
                        </div>
                        <input name="link" value="{if !empty($article.url)}{$article.url}{/if}" data-link-id="{if !empty($article.url_id)}{$article.url_id}{/if}" type="text" class="form-control form-control-sm nh-link" maxlength="255">
                    </div>
                </div>
                <div id="wrap-category" class="row">
                    <div class="col-lg-12">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'danh_muc')}
                                <span class="kt-font-danger">*</span>
                            </label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <i class="fa fa-align-justify w-20px"></i>
                                    </span>
                                </div>
                                {assign var = categories value = $this->CategoryAdmin->getListCategoriesForDropdown([
                                    {TYPE} => {ARTICLE}, 
                                    {LANG} => $lang
                                ])}

                                {assign var = categories_selected value = []}
                                {if !empty($article.categories)}
                                    {foreach from = $article.categories item = category}
                                        {$categories_selected[] = $category.id}
                                    {/foreach}
                                {/if}

                                {$this->Form->select('categories', $categories, ['id' => 'categories', 'empty' => null, 'default' => $categories_selected, 'class' => 'form-control kt-select-multiple', 'multiple' => 'multiple', 'data-placeholder' => "{__d('admin', 'chon_danh_muc')}"])}
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-3 d-none">
                        <label>
                            {__d('admin', 'danh_muc_chinh')}
                        </label>
                        {$this->Form->select('main_category_id', $list_category_main, ['id' => 'main_category_id', 'empty' => {__d('admin', 'chon')}, 'default' => "{if !empty($article.main_category_id)}{$article.main_category_id}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker', 'data-placeholder' => "{__d('admin', 'chon_danh_muc')}"])}
                    </div>
                </div>
                

                <div class="row">
                    <div class="col-xl-6 col-lg-6 d-none">
                        <div class="form-group">
                            <label class="mb-10">
                                {__d('admin', 'bai_noi_bat')}
                            </label>
                            <div class="kt-radio-inline">
                                <label class="kt-radio kt-radio--tick kt-radio--success">
                                    <input type="radio" name="featured" value="1" {if !empty($article.featured)}checked{/if}> 
                                    {__d('admin', 'co')}
                                    <span></span>
                                </label>
                                <label class="kt-radio kt-radio--tick kt-radio--danger">
                                    <input type="radio" name="featured" value="0" {if empty($article.featured)}checked{/if}> 
                                    {__d('admin', 'khong')}
                                    <span></span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-6 col-lg-6">
                        <div class="form-group">
                            <label class="mb-10">
                                {__d('admin', 'hien_thi_muc_luc')}
                            </label>

                            <div class="kt-radio-inline">
                                <label class="kt-radio kt-radio--tick kt-radio--success">
                                    <input type="radio" name="catalogue" value="1" {if !empty($article.catalogue)}checked{/if}> 
                                    {__d('admin', 'co')}
                                    <span></span>
                                </label>
                                
                                <label class="kt-radio kt-radio--tick kt-radio--danger">
                                    <input type="radio" name="catalogue" value="0" {if empty($article.catalogue)}checked{/if}> 
                                    {__d('admin', 'khong')}
                                    <span></span>
                                </label>
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
        
        <div nh-anchor="media" class="kt-portlet nh-portlet nh-active-hover position-relative">
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
                        {if !empty($article.image_avatar)}
                            {assign var = bg_avatar value = "background-image: url('{CDN_URL}{$article.image_avatar}');background-size: contain;background-position: 50% 50%;"}
                        {/if}

                        <div class="kt-avatar kt-avatar--outline kt-avatar--circle- {if !empty($bg_avatar)}kt-avatar--changed{/if}">
                            <a {if !empty($article.image_avatar)}href="{CDN_URL}{$article.image_avatar}"{/if} target="_blank" class="kt-avatar__holder d-block" style="{$bg_avatar}"></a>
                            <label class="kt-avatar__upload btn-select-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'chon_anh')}" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id=image_avatar&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                <i class="fa fa-pen"></i>
                            </label>
                            <span class="kt-avatar__cancel btn-clear-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'xoa_anh')}">
                                <i class="fa fa-times"></i>
                            </span>

                            <input id="image_avatar" name="image_avatar" value="{if !empty($article.image_avatar)}{htmlentities($article.image_avatar)}{/if}" type="hidden" />
                        </div>
                    </div>
                </div>

                <div class="form-group d-none">
                    <label>
                        {__d('admin', 'album_anh')}
                    </label>
                    <div class="row wrap-album">
                        <div class="col-xl-8 col-lg-8">
                            <input id="images" name="images" value="{if !empty($article.images)}{htmlentities($article.images|@json_encode)}{/if}" type="hidden" />
                            <div class="clearfix mb-5 list-image-album">
                                {if !empty($article.images)}
                                    {foreach from = $article.images item = image}
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

                <div class="form-group">
                    <label>
                        {__d('admin', 'tep_dinh_kem')}
                    </label>
                    <div class="row">
                        <div class="col-xl-8 col-lg-8">
                            <div class="wrap-files">
                                <input id="files" name="files" value="{if !empty($article.files)}{htmlentities($article.files|@json_encode)}{/if}" type="hidden" />
                                <div class="list-files">                                
                                    {if !empty($article.files)}
                                        {foreach from = $article.files item = file}
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
                            <input name="url_video" id="url_video" value="{if !empty($article.url_video)}{$article.url_video}{/if}" type="text" class="form-control form-control-sm">
                            <span class="form-text text-muted">
                                {__d('admin', 'voi_kieu_video_youtube_url_chi_dien_ma_video')} 
                                <img src="{ADMIN_PATH}/assets/media/note/upload_video.png" width="300px" />
                            </span>
                        </div>

                        <div class="col-xl-4 col-lg-4">
                            <div class="row">
                                <div class="col-xl-6 col-lg-12">
                                    {$this->Form->select('type_video', $this->ListConstantAdmin->listTypeVideo(), ['id' => 'type_video', 'empty' => null, 'default' => "{if !empty($article.type_video)}{$article.type_video}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker mb-10'])}
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
        </div>

        <div nh-anchor="mo_ta_bai_viet" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'mo_ta_bai_viet')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        {__d('admin', 'mo_ta_ngan')}
                    </label>                            
                    <div class="clearfix">
                        <textarea name="description" id="description" class="mce-editor-simple">{if !empty($article.description)}{$article.description}{/if}</textarea>
                    </div>
                </div>

                <div class="form-group">
                    <label>
                        {__d('admin', 'noi_dung')}
                    </label>
                    <div class="clearfix">
                        <textarea name="content" id="content" class="mce-editor">{if !empty($article.content)}{$article.content}{/if}</textarea>
                    </div>
                </div>

                <div class="form-group">
                    <label>
                        {__d('admin', 'the_bai_viet')}
                    </label>
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">
                                <i class="la la-tags"></i>
                            </span>
                        </div>
                        {assign var = tags value = []}
                        {if !empty($article.tags)}
                            {foreach from = $article.tags item = tag key = k_tag}
                                {$tags[$k_tag] = $tag.name}
                            {/foreach}
                        {/if}
                        <input name="tags" id="tags" value="{if !empty($tags)}{htmlentities($tags|@json_encode)}{/if}" type="text" class="form-control form-control-sm tagify-input">
                    </div>
                    <span class="form-text text-muted">
                        {__d('admin', 'chi_ho_tro_{0}_the_va_do_dai_moi_the_khong_qua_{1}_ky_tu', [10, 45])}
                    </span>
                </div>

            </div>
        </div>

        {if !empty($all_attributes)}
            <div nh-anchor="thuoc_tinh_mo_rong" class="kt-portlet nh-portlet nh-active-hover position-relative">
                <div class="kt-portlet__head">
                    <div class="kt-portlet__head-label">
                        <h3 class="kt-portlet__head-title">
                            {__d('admin', 'thuoc_tinh_mo_rong')}
                        </h3>
                    </div>
                </div>

                <div class="kt-portlet__body">
                    {foreach from = $all_attributes item = attribute key = attribute_id}
                        <div class="form-group" data-attribute-code="{$attribute.code}">
                            <label>
                                {if !empty($attribute.name)}
                                    {$attribute.name}
                                {/if}
                                {if !empty($attribute.required)}
                                    <span class="kt-font-danger">*</span>
                                {/if}
                            </label>

                            {if !empty($all_options.{$attribute_id})}
                                {$attribute.options = $all_options.{$attribute_id}}
                            {/if}

                            {if !empty($attribute.code) && !empty($article.attributes.{$attribute.code}.value)}
                                {$attribute.value = $article.attributes.{$attribute.code}.value}
                            {/if}

                            {$this->AttributeAdmin->generateInput($attribute, $lang)}
                        </div>
                    {/foreach}
                </div>
            </div>
        {/if}

        <div nh-anchor="tu_khoa_seo" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'thong_tin_seo')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">      
                <div class="row">
                    <div class="col-11">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'tieu_de_seo')}
                            </label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <i class="la la-list-alt"></i>
                                    </span>
                                </div>
                                <input name="seo_title" value="{if !empty($article.seo_title)}{$article.seo_title|escape}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
                            </div>
                            <div id="progress-bar-title" class="progress mt-10">
                                <div class="progress-bar progress-bar-striped"></div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>
                                {__d('admin', 'mo_ta_seo')}
                            </label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <i class="la la-file-text"></i>
                                    </span>
                                </div>
                                <input name="seo_description" value="{if !empty($article.seo_description)}{$article.seo_description|escape}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
                            </div>
                            <div id="progress-bar-description" class="progress mt-10">
                                <div class="progress-bar progress-bar-striped"></div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>
                                {__d('admin', 'tu_khoa_seo')}
                            </label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">
                                        <i class="la la-tags"></i>
                                    </span>
                                </div>

                                <input name="seo_keyword" id="seo_keyword" value="{if !empty($article.seo_keyword)}{$article.seo_keyword}{/if}" type="text" class="form-control form-control-sm tagify-input">
                            </div>
                            <span class="form-text text-muted">
                                {__d('admin', 'chi_ho_tro_{0}_tu_khoa_va_do_dai_moi_tu_khoa_khong_qua_{1}_ky_tu', [10, 45])}
                            </span>
                        </div>
                    </div>
                </div>      
            </div>
        </div>

        <div class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'phan_tich_bai_viet_va_tu_khoa')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div id="nh-analysis" class="form-group row">
                    <div class="col-xl-12 col-lg-12 all-analysis"></div>
                </div>
            </div>
        </div>
    </form>
</div>