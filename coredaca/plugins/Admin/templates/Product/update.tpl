{assign var = url_list value = "{ADMIN_PATH}/product"}
{assign var = url_add value = "{ADMIN_PATH}/product/add"}
{assign var = url_edit value = "{ADMIN_PATH}/product/update"}
{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
{assign var = use_multiple_language value = {$this->LanguageAdmin->checkUseMultipleLanguage()}}
{assign var = list_languages value = $this->LanguageAdmin->getList()}

<div class="kt-subheader   kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {*if !empty($title_for_layout)}{$title_for_layout}{/if*}
                Thêm bản ghi
            </h3>
        </div>

        <div class="kt-subheader__toolbar">
            <a href="{$url_list}" class="btn btn-sm btn-secondary" btn-back-custom>
                {__d('admin', 'quay_lai_danh_sach')}
            </a>

            {*if empty($id) || !empty($product.draft)}
                <span class="btn btn-sm btn-dark btn-save-draft">
                    {__d('admin', 'luu_nhap')}
                </span>
            {/if*}

            <div class="btn-group">
                {if empty($id)}
                    {*<button data-link="{$url_edit}" data-update="1" id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                        <i class="la la-plus"></i>
                        Thêm mới (F1)
                    </button>*}
                    <span data-link="{$url_list}" type="button" class="btn btn-sm btn-brand btn-save" btn-custom>
                        <i class="la la-plus"></i>
                        Thêm mới
                    </span>
                {else}
                    <button id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                        <i class="la la-edit"></i>
                        {__d('admin', 'cap_nhat_thong_tin')} (F1)
                    </button>
                {/if}
                
                {*<button type="button" class="btn btn-brand btn-bold dropdown-toggle dropdown-toggle-split" data-toggle="dropdown"></button>
                <div class="dropdown-menu dropdown-menu-right">
                    <ul class="kt-nav p-0">
                        <li class="kt-nav__item">
                            <span data-link="{$url_add}" class="kt-nav__link btn-save">
                                <i class="kt-nav__link-icon flaticon2-medical-records"></i>
                                <span class="kt-nav__link-text">
                                    {__d('admin', 'luu_&_them_moi')}
                                </span>
                            </span>
                        </li>

                        <li class="kt-nav__item">
                            <span data-link="{$url_list}" class="kt-nav__link btn-save">
                                <i class="kt-nav__link-icon flaticon2-hourglass-1"></i>
                                <span class="kt-nav__link-text">
                                    {__d('admin', 'luu_&_quay_lai')}
                                </span>
                            </span>
                        </li>
                    </ul>
                </div>*}
            </div>
        </div>
    </div>
</div>

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <form id="main-form" action="{ADMIN_PATH}/product/save{if !empty($id)}/{$id}{/if}" method="POST" autocomplete="off">
        <div class="d-none">
            <input type="hidden" name="draft" value="">
            <input type="hidden" name="seo_score" value="" id="seo-score">
            <input type="hidden" name="keyword_score" value="" id="keyword-score">
        </div>

        {if !empty($id)}
            <div nh-anchor="thong_tin_cap_nhat" class="kt-portlet nh-portlet nh-active-hover position-relative">
                <div class="kt-portlet__head">
                    <div class="kt-portlet__head-label">
                        <h3 class="kt-portlet__head-title">
                            {__d('admin', 'thong_tin_cap_nhat')}
                        </h3>
                    </div>
                    {if !empty($product.url)}
                        <div class="kt-portlet__head-toolbar">
                            <a target="_blank" href="/{$product.url}" class="kt-link kt-font-bolder kt-link--info">
                                Xem thực tế
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
                                    {if !empty($product.draft)}
                                        <span class="kt-badge kt-badge--dark kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'ban_luu_nhap')}
                                        </span>
                                    {/if}

                                    {if isset($product.status) && $product.status == 1}
                                        <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'hoat_dong')}
                                        </span>
                                    {elseif ($product.draft == 1) || (isset($product.status) && $product.status == 0)}
                                        <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'ngung_hoat_dong')}
                                        </span>
                                    {elseif isset($product.status) && $product.status == -1}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'cho_duyet')}
                                        </span>
                                    {elseif isset($product.status) && $product.status == 2}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'ngung_kinh_doanh')}
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
                                        {if !empty($product.user_full_name)}
                                            {$product.user_full_name}
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
                                        {if !empty($product.created)}
                                            {$product.created}
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
                                        {if !empty($product.updated)}
                                            {$product.updated}
                                        {/if}
                                    </span>
                                </div>
                            </div>

                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'seo')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    {if !empty($product.seo_score) && $product.seo_score == 'success'}
                                        <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'tot')}
                                        </span>
                                    {elseif !empty($product.seo_score) && $product.seo_score == 'warning'}
                                        <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'binh_thuong')}
                                        </span>
                                    {elseif !empty($product.seo_score) && $product.seo_score == 'danger'}
                                        <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'chua_dat')}
                                        </span>
                                    {else}
                                        <span class="form-control-plaintext"><em>{__d('admin', 'chua_co')}</em></span>
                                    {/if}
                                </div>
                            </div>

                            <div class="form-group form-group-xs row">
                                <label class="col-lg-4 col-xl-4 col-form-label">
                                    {__d('admin', 'tu_khoa')}
                                </label>
                                <div class="col-lg-8 col-xl-8">
                                    <div class="kt-section__content kt-section__content--solid">
                                        {if !empty($product.keyword_score) && $product.keyword_score == 'success'}
                                            <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'tot')}
                                        </span>
                                        {elseif !empty($product.keyword_score) && $product.keyword_score == 'warning'}
                                            <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'binh_thuong')}
                                        </span>
                                        {elseif !empty($product.keyword_score) && $product.keyword_score == 'danger'}
                                            <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill mt-10">
                                            {__d('admin', 'chua_dat')}
                                        </span>
                                        {else}
                                            <span class="form-control-plaintext"><em>{__d('admin', 'chua_co')}</em></span>
                                        {/if}
                                    </div>
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

                            {assign var = all_name_content value = $this->ProductAdmin->getAllNameContent($id)}
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

                                                            <a href="{ADMIN_PATH}/product/update/{$product.id}?lang={$k_language}" class="pl-10">
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
                        Tên
                        <span class="kt-font-danger">*</span>
                    </label>
                    <input id="name" name="name" value="{if !empty($product.name)}{$product.name|escape}{/if}" class="form-control form-control-sm nh-format-link" type="text" maxlength="255">
                </div>

                <div class="form-group">
                    <label>
                        {__d('admin', 'duong_dan')}
                        <span class="kt-font-danger">*</span>
                    </label>
                    <div class="input-group flex-nowrap">
                        <div class="input-group-prepend">
                            <span class="input-group-text">
                                <i class="la la-link"></i>
                            </span>
                        </div>
                        <input name="link" value="{if !empty($product.url)}{$product.url}{/if}" data-link-id="{if !empty($product.url_id)}{$product.url_id}{/if}" type="text" class="form-control form-control-sm nh-link" maxlength="255">
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
                                    {TYPE} => {PRODUCT}, 
                                    {LANG} => $lang
                                ])}

                                {assign var = categories_selected value = []}
                                {if !empty($product.categories)}
                                    {foreach from = $product.categories item = category}
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
                        {$this->Form->select('main_category_id', $list_category_main, ['id' => 'main_category_id', 'empty' => {__d('admin', 'chon')}, 'default' => "{if !empty($product.main_category_id)}{$product.main_category_id}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker', 'data-placeholder' => "{__d('admin', 'chon_danh_muc')}"])}
                    </div>
                </div>
                                  

                <div class="row">
                    <div class="col-xl-6 col-lg-6 d-none">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'thuong_hieu')}
                            </label>
                            {assign var = list_brands value = $this->BrandAdmin->getListBrands()}

                            {assign var = search_brand value = false}
                            {if !empty($list_brands) && count($list_brands) > 7}
                                {$search_brand = true}                                        
                            {/if}
                            {$this->Form->select('brand_id', $list_brands, ['id' => 'brand_id', 'empty' => {__d('admin', 'chon')}, 'default' => "{if !empty($product.brand_id)}{$product.brand_id}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker', 'data-live-search' => $search_brand])}
                        </div>
                    </div>

                    <div class="col-xl-6 col-lg-6">
                        <div class="row">
                            <div class="col-xl-6 col-lg-6 d-none">
                                <div class="form-group">
                                    <label>
                                        {__d('admin', 'san_pham_noi_bat')}
                                    </label>
                                    <div class="kt-radio-inline mt-5">
                                        <label class="kt-radio kt-radio--tick kt-radio--success mr-20">
                                            <input type="radio" name="featured" value="1" {if !empty($product.featured)}checked{/if}> {__d('admin', 'co')}
                                            <span></span>
                                        </label>
                                        <label class="kt-radio kt-radio--tick kt-radio--danger">
                                            <input type="radio" name="featured" value="0" {if empty($product.featured)}checked{/if}> {__d('admin', 'khong')}
                                            <span></span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-xl-6 col-lg-6 d-none">
                                <div class="form-group">
                                    <label class="mb-10">
                                        {__d('admin', 'hien_thi_muc_luc')}
                                    </label>

                                    <div class="kt-radio-inline">
                                        <label class="kt-radio kt-radio--tick kt-radio--success">
                                            <input type="radio" name="catalogue" value="1" {if !empty($product.catalogue)}checked{/if}> 
                                            {__d('admin', 'co')}
                                            <span></span>
                                        </label>
                                        
                                        <label class="kt-radio kt-radio--tick kt-radio--danger">
                                            <input type="radio" name="catalogue" value="0" {if empty($product.catalogue)}checked{/if}> 
                                            {__d('admin', 'khong')}
                                            <span></span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>                        

                <div class="row d-none">
                    <div class="col-xl-3 col-lg-3">
                        <div class="form-group mb-0">
                            <label>
                                {__d('admin', 'vi_tri')}
                            </label>

                            <input name="position" value="{$position}" class="form-control form-control-sm" type="text">
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div nh-anchor="gia_va_phien_ban_san_pham" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Ảnh và giá
                    </h3>
                </div>
            </div>
            <div class="kt-portlet__body">
                {if !empty($list_attributes_special)}
                    {if !empty($attributes_id_selected)}
                        <a id="change-attribute" class="fw-400 mb-20" href="javascript:;">
                            {__d('admin', 'thay_doi_thuoc_tinh')}
                        </a>
                    {/if}

                    <div id="wrap-select-attribute" class="{if !empty($attributes_id_selected)}collapse{/if}">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'chon_thuoc_tinh_san_pham')}
                            </label>
                            <div class="row">
                                <div class="col-xl-8 col-lg-9">
                                    {$this->Form->select('select_attribute_item', $list_attributes_special, ['id' => 'select-attribute-item', 'empty' => null, 'default' => $attributes_id_selected, 'multiple' => 'multiple', 'class' => 'form-control kt-select2'])}
                                </div>

                                <div class="col-lg-3 col-xl-2">
                                    <button id="apply-attribute" class="col-md-12 btn btn-sm btn-brand" type="button">
                                        <i class="fa fa-check"></i>
                                        {__d('admin', 'ap_dung_thuoc_tinh')}
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="kt-separator kt-separator--space-lg kt-separator--border-solid mt-0 mb-20"></div>
                    </div>
                {/if}

                <div id="products-item-wrap" class="clearfix">
                    {$this->element('../Product/items')}
                </div>

                <input id="nh-item-product" name="items" type="hidden" value="" >
            </div>
        </div>

        <div nh-anchor="mo_ta_san_pham" class="kt-portlet nh-portlet nh-active-hover position-relative d-none">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'mo_ta_san_pham')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        {__d('admin', 'mo_ta_ngan')}
                    </label>                            
                    <div class="clearfix">
                        <textarea name="description" id="description" class="mce-editor-simple">{if !empty($product.description)}{$product.description}{/if}</textarea>
                    </div>
                </div>

                <div class="form-group">
                    <label>
                        {__d('admin', 'noi_dung')}
                    </label>
                    <div class="clearfix">
                        <textarea name="content" id="content" class="mce-editor">{if !empty($product.content)}{$product.content}{/if}</textarea>
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
                        {if !empty($product.tags)}
                            {foreach from = $product.tags item = tag key = k_tag}
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
        
        {if !empty($attributes_product)}
            <div nh-anchor="thuoc_tinh_mo_rong" class="kt-portlet nh-portlet nh-active-hover position-relative">
                <div class="kt-portlet__head">
                    <div class="kt-portlet__head-label">
                        <h3 class="kt-portlet__head-title">
                            {__d('admin', 'thuoc_tinh_mo_rong')}
                        </h3>
                    </div>
                </div>
                <div class="kt-portlet__body">
                    {foreach from = $attributes_product item = attribute key = attribute_id}
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

                            {if !empty($attribute.code) && !empty($product.attributes.{$attribute.code}.value)}
                                {$attribute.value = $product.attributes.{$attribute.code}.value}
                            {/if}

                            {$this->AttributeAdmin->generateInput($attribute, $lang)}
                        </div>
                    {/foreach}
                </div>
            </div>
        {/if}

        <div nh-anchor="thong_tin_khac" class="kt-portlet nh-portlet nh-active-hover position-relative d-none">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'thong_tin_khac')}
                    </h3>
                </div>
            </div>
            <div class="kt-portlet__body">
                <div class="form-group">
                    <label>
                        {__d('admin', 'tep_dinh_kem')}
                    </label>
                    <div class="row">                        
                        <div class="col-xl-8 col-lg-8">
                            <div class="wrap-files">
                                <input id="files" name="files" value="{if !empty($product.files)}{htmlentities($product.files|@json_encode)}{/if}" type="hidden" />
                                <div class="list-files">
                                    {if !empty($product.files)}
                                        {assign var = files value = $product.files}
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
                            <span class="col-lg-12 col-xl-12 btn btn-sm btn-success btn-select-file" data-src="{CDN_URL}/filemanager/dialog.php?type=0&crossdomain=1&akey={$filemanager_access_key}&field_id=files&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                <i class="fa fa-file-alt"></i> 
                                {__d('admin', 'chon_tep')}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label>
                        {__d('admin', 'duong_dan_video')}
                    </label>

                    <div class="row wrap-video">
                        <div class="col-xl-8 col-lg-8">
                            <input name="url_video" id="url_video" value="{if !empty($product.url_video)}{$product.url_video}{/if}" type="text" class="form-control form-control-sm">
                            <span class="form-text text-muted">
                                {__d('admin', 'voi_kieu_video_youtube_url_chi_dien_ma_video')} 
                                <img src="{ADMIN_PATH}/assets/media/note/upload_video.png" width="300px" />
                            </span>
                        </div>

                        <div class="col-xl-4 col-lg-4">
                            <div class="row">
                                <div class="col-xl-6 col-lg-12">
                                    {$this->Form->select('type_video', $this->ListConstantAdmin->listTypeVideo(), ['id' => 'type_video', 'empty' => null, 'default' => "{if !empty($product.type_video)}{$product.type_video}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker mb-10'])}
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
                
                <div class="row d-none">
                    <div class="col-xl-4 col-lg-4">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'can_nang')}
                            </label>
                            <div class="row">
                                <div class="col-8 pr-0">
                                    <input name="weight" value="{if !empty($product.weight)}{$product.weight}{/if}" class="form-control form-control-sm number-input" type="text">
                                </div>
                                <div class="col-4">
                                    {$this->Form->select('weight_unit', $weight_unit, ['empty' => null, 'default' => "{if !empty($product.weight_unit)}{$product.weight_unit}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker'])}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row d-none">
                    <div class="col-xl-4 col-lg-4">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'chieu_dai')}
                            </label>
                            <div class="row">
                                <div class="col-8 pr-0">
                                    <input name="length" value="{if !empty($product.length)}{$product.length}{/if}" class="form-control form-control-sm number-input" type="text">
                                </div>
                                <div class="col-4">
                                    {$this->Form->select('length_unit', $length_unit, ['empty' => null, 'default' => "{if !empty($product.length_unit)}{$product.length_unit}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker'])}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-4 col-lg-4">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'chieu_rong')}
                            </label>
                            <div class="row">
                                <div class="col-8 pr-0">
                                    <input name="width" value="{if !empty($product.width)}{$product.width}{/if}" class="form-control form-control-sm number-input" type="text">
                                </div>
                                <div class="col-4">
                                    {$this->Form->select('width_unit', $length_unit, ['empty' => null, 'default' => "{if !empty($product.width_unit)}{$product.width_unit}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker'])}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-4 col-lg-4">
                        <div class="form-group">
                            <label>
                                {__d('admin', 'chieu_cao')}
                            </label>
                            <div class="row">
                                <div class="col-8 pr-0">
                                    <input name="height" value="{if !empty($product.height)}{$product.height}{/if}" class="form-control form-control-sm number-input" type="text">
                                </div>
                                <div class="col-4">
                                    {$this->Form->select('height_unit', $length_unit, ['empty' => null, 'default' => "{if !empty($product.height_unit)}{$product.height_unit}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker'])}
                                </div>
                            </div>
                        </div>
                    </div>                    
                </div>
            </div>
        </div>

        <div nh-anchor="tu_khoa_seo" class="kt-portlet nh-portlet nh-active-hover position-relative">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'tu_khoa_seo')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">            
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
                        <input name="seo_title" value="{if !empty($product.seo_title)}{$product.seo_title|escape}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
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
                        <input name="seo_description" value="{if !empty($product.seo_description)}{$product.seo_description|escape}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
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
                        <input name="seo_keyword" id="seo_keyword" value="{if !empty($product.seo_keyword)}{$product.seo_keyword}{/if}" type="text" class="form-control form-control-sm tagify-input">
                    </div>
                    <span class="form-text text-muted">
                        {__d('admin', 'chi_ho_tro_{0}_tu_khoa_va_do_dai_moi_tu_khoa_khong_qua_{1}_ky_tu', [10, 45])}
                    </span>
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

<div id="popover-price-special" class="d-none">
    <div class="form-group">
        <label>
            {__d('admin', 'gia_dac_biet')}
        </label>
        <input id="price-special" value="" class="form-control form-control-sm number-input" type="text">

        <span class="form-text text-muted">
            {__d('admin', 'gia_ban_le_san_pham_cho_chuong_trinh_khuyen_mai')}
        </span>
    </div>

    <div class="form-group">
        <label>
            {__d('admin', 'ngay_khuyen_mai')}
        </label>
        
        <div class="input-group">
            <div class="input-group-prepend">
                <span class="input-group-text">
                    <i class="fa fa-calendar-alt w-20px"></i>
                </span>
            </div>

            <input id="date-special" value="" class="form-control form-control-sm date-ranger-picker fs-11" readonly="true" type="text" style="height: 35px;">

            <div id="delete-special-price" class="input-group-append" style="cursor: pointer;">
                <span class="input-group-text">
                    <i class="fa fa-times w-20px"></i>
                </span>
            </div>
        </div>
    </div>

    <div class="form-group mb-0">
        <button id="confirm-special-price" type="button" class="btn btn-sm btn-brand mr-5">
            {__d('admin', 'dong_y')}
        </button>

        <button id="cancel-special-price" type="button" class="btn btn-sm btn-secondary mr-5">
            {__d('admin', 'huy_bo')}
        </button>
    </div>
</div>