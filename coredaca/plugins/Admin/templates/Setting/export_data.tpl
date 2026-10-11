<div class="kt-subheader   kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {if !empty($title_for_layout)}{$title_for_layout}{/if}
            </h3>
        </div>

        <div class="kt-portlet__head-toolbar">
            <div class="kt-portlet__head-actions">
                {if !empty($migrate.done)}
                    <a href="/setting/export-data/categories" class="btn btn-sm btn-brand">
                        Tiếp tục
                        <i class="fa fa-angle-double-right"></i>
                    </a>
                {/if}
            </div>
        </div>
    </div>
</div>

<div class="kt-container kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <form id="main-form" action="{ADMIN_PATH}/setting/export-data/process" method="POST" autocomplete="off">
        <div class="kt-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'buoc_khoi_tao')}
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="form-group">
                    <label class="kt-font-bold text-danger">
                        {__d('admin', 'luu_y')}:
                    </label>
                    <span class="form-text text-muted">
                        - {__d('admin', 'thuc_hien_cac_buoc_export_theo_dung_thu_tu')} 
                    </span>

                    <span class="form-text text-muted">
                        - {__d('admin', 'so_ban_ghi_can_export_cang_it_thi_export_du_lieu_cang_nhanh')} 
                    </span>

                    <span class="form-text text-muted">
                        - {__d('admin', 'du_lieu_export_mau_duoc_luu_tam_trong_thu_muc_tmp_trong_qua_trinh_export_du_lieu_khong_duoc_xoa_cache_he_thong_de_tranh_xay_ra_loi_khi_export_du_lieu_mau')} 
                    </span>
                </div>

                <div class="row">
                    <div class="col-xl-6 col-lg-8">
                        <div class="kt-widget4 mt-20">
                            <div class="kt-widget4__item">
                                <span class="kt-widget4__icon">
                                    <i class="fa fa-folder-plus fs-14"></i>
                                </span>

                                <span class="kt-widget4__title kt-widget4__title--light">
                                    {__d('admin', 'khoi_tao_moi_quy_trinh_export_du_lieu')}
                                    {if !empty($migrate.initialization.status) && $migrate.initialization.status == "{SUCCESS}"}
                                        <i class="text-success fs-12 ml-10">
                                            {__d('admin', 'da_khoi_tao')}
                                        </i>
                                        <i class="fa fa-check-circle text-success fs-14"></i>
                                    {/if}

                                    {if !empty($migrate.initialization.status) && $migrate.initialization.status == "{ERROR}"}
                                        <i class="text-danger fs-12 ml-10">
                                            {__d('admin', 'xay_ra_loi')}
                                        </i>
                                        <i class="fa fa-window-close text-danger fs-14"></i>
                                    {/if}
                                </span>

                                <span class="kt-widget4__number kt-font-info">
                                    <span class="btn btn-sm btn-secondary btn-export-data" type="initialization">
                                        <i class="fa fa-check fs-14"></i>
                                        {__d('admin', 'thuc_hien')}
                                    </span>
                                </span>
                            </div>

                            <div class="kt-widget4__item">
                                <span class="kt-widget4__icon">
                                    <i class="fa fa-search fs-14"></i>
                                </span>

                                <span class="kt-widget4__title kt-widget4__title--light">
                                    {__d('admin', 'doc_thong_tin_du_lieu')}
                                    {if !empty($migrate.read_database.status) && $migrate.read_database.status == "{SUCCESS}"}
                                        <i class="text-success fs-12 ml-10">
                                            {__d('admin', 'da_thuc_hien')}
                                        </i>
                                        <i class="fa fa-check-circle text-success fs-14"></i>
                                    {/if}

                                    {if !empty($migrate.read_database.status) && $migrate.read_database.status == "{ERROR}"}
                                        <i class="text-danger fs-12 ml-10">
                                            {__d('admin', 'xay_ra_loi')}
                                        </i>
                                        <i class="fa fa-window-close text-danger fs-14"></i>
                                    {/if}
                                </span>

                                <span class="kt-widget4__number kt-font-info">
                                    <span class="btn btn-sm btn-secondary btn-export-data" type="read_database">
                                        <i class="fa fa-check fs-14"></i>
                                        {__d('admin', 'thuc_hien')}
                                    </span>
                                </span>
                            </div>

                            <div class="kt-widget4__item">
                                <span class="kt-widget4__icon">
                                    <i class="fa fa-flag-checkered fs-14"></i>
                                </span>

                                <span class="kt-widget4__title kt-widget4__title--light">
                                    {__d('admin', 'cau_hinh_du_lieu_export')}
                                    {if !empty($migrate.config_data.status) && $migrate.config_data.status == "{SUCCESS}"}
                                        <i class="text-success fs-12 ml-10">
                                            {__d('admin', 'da_thuc_hien')}
                                        </i>
                                        <i class="fa fa-check-circle text-success fs-14"></i>
                                    {/if}

                                    {if !empty($migrate.config_data.status) && $migrate.config_data.status == "{ERROR}"}
                                        <i class="text-danger fs-12 ml-10">
                                            {__d('admin', 'xay_ra_loi')}
                                        </i>
                                        <i class="fa fa-window-close text-danger fs-14"></i>
                                    {/if}
                                </span>

                                <span class="kt-widget4__number kt-font-info">
                                    <span id="btn-show-config-data" class="btn btn-sm btn-secondary">
                                        <i class="fa fa-check fs-14"></i>
                                        {__d('admin', 'thuc_hien')}
                                    </span>
                                </span>
                            </div>

                            <div class="kt-widget4__item">
                                <span class="kt-widget4__icon">
                                    <i class="fa fa-indent fs-14"></i>
                                </span>

                                <span class="kt-widget4__title kt-widget4__title--light">
                                    {__d('admin', 'cau_hinh_id_bat_dau_cho_du_lieu')}
                                    {if !empty($migrate.config_id.status) && $migrate.config_id.status == "{SUCCESS}"}
                                        <i class="text-success fs-12 ml-10">
                                            {__d('admin', 'da_thuc_hien')}
                                        </i>
                                        <i class="fa fa-check-circle text-success fs-14"></i>
                                    {/if}

                                    {if !empty($migrate.config_id.status) && $migrate.config_id.status == "{ERROR}"}
                                        <i class="text-danger fs-12 ml-10">
                                            {__d('admin', 'xay_ra_loi')}
                                        </i>
                                        <i class="fa fa-window-close text-danger fs-14"></i>
                                    {/if}
                                </span>

                                <span class="kt-widget4__number kt-font-info">
                                    <span id="btn-show-config-id" class="btn btn-sm btn-secondary">
                                        <i class="fa fa-eye fs-14"></i>
                                        {__d('admin', 'cau_hinh')}
                                    </span>
                                </span>
                            </div>

                            <div class="kt-widget4__item">
                                <span class="kt-widget4__icon">
                                    <i class="fa fa-cogs fs-14"></i>
                                </span>

                                <span class="kt-widget4__title kt-widget4__title--light">
                                    {__d('admin', 'cau_hinh_thong_tin_cdn')}
                                    {if !empty($migrate.config_cdn.status) && $migrate.config_cdn.status == "{SUCCESS}"}
                                        <i class="text-success fs-12 ml-10">
                                            {__d('admin', 'da_thuc_hien')}
                                        </i>
                                        <i class="fa fa-check-circle text-success fs-14"></i>
                                    {/if}

                                    {if !empty($migrate.config_cdn.status) && $migrate.config_cdn.status == "{ERROR}"}
                                        <i class="text-danger fs-12 ml-10">
                                            {__d('admin', 'xay_ra_loi')}
                                        </i>
                                        <i class="fa fa-window-close text-danger fs-14"></i>
                                    {/if}
                                </span>

                                <span class="kt-widget4__number kt-font-info">
                                    <span id="btn-show-config-cdn" class="btn btn-sm btn-secondary">
                                        <i class="fa fa-eye fs-14"></i>
                                        {__d('admin', 'cau_hinh')}
                                    </span>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<div id="config-data-modal" class="modal fade" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    {__d('admin', 'cau_hinh_du_lieu_export')}
                </h5>
                <button type="button" class="close" data-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                {assign var = config_data value = []}
                {if !empty($migrate.read_database.data)}
                    {assign var = config_data value = $migrate.read_database.data}
                {/if}

                {assign var = languages value = $this->LanguageAdmin->getList()}
                <label class="kt-font-bold">
                    {__d('admin', 'chon_ngon_ngu_cho_du_lieu_can_export')}
                </label>

                <div class="kt-checkbox-inline list-flags mb-20">
                    {foreach from=$languages item=name key=lang}
                        <label class="kt-checkbox kt-checkbox--tick kt-checkbox--success">
                            <input type="checkbox" name="languages[]" nh-config-lang value="{$lang}" {if $lang == LANGUAGE_ADMIN}checked{/if}> 
                            {$name}
                            <span></span>
                        </label>
                    {/foreach}
                </div>

                <div class="row">
                    <div class="col-sm-7">
                        <form id="config-data-form" action="{ADMIN_PATH}/setting/export-data/config-data" method="POST" autocomplete="off">

                            <table class="table table-bordered table-hover nh-table f0 mb-0">
                                <thead class="thead-light">
                                    <tr>
                                        <th>
                                            <label class="kt-checkbox kt-checkbox--bold kt-checkbox-inline ml-10">
                                                <input type="checkbox" class="check-all">
                                                <span></span>
                                            </label>
                                        </th>

                                        <th class="w-50">
                                            {__d('admin', 'muc_luc')}
                                        </th>

                                        <th class="w-20 text-center">
                                            {__d('admin', 'so_ban_ghi')}
                                        </th>

                                        <th class="w-20 text-center">
                                            {__d('admin', 'so_ban_ghi_export')}
                                        </th>
                                    </tr>
                                </thead>

                                {assign var = number_category_article value = 0}
                                {if !empty($config_data['number_category_article'])}
                                    {assign var = number_category_article value = $config_data['number_category_article']}
                                {/if}

                                {assign var = number_article value = 0}
                                {if !empty($config_data['number_article'])}
                                    {assign var = number_article value = $config_data['number_article']}
                                {/if}

                                {assign var = number_tag_article value = 0}
                                {if !empty($config_data['number_tag_article'])}
                                    {assign var = number_tag_article value = $config_data['number_tag_article']}
                                {/if}

                                {assign var = number_attribute_article value = 0}
                                {if !empty($config_data['number_attribute_article'])}
                                    {assign var = number_attribute_article value = $config_data['number_attribute_article']}
                                {/if}

                                {assign var = number_category_product value = 0}
                                {if !empty($config_data['number_category_product'])}
                                    {assign var = number_category_product value = $config_data['number_category_product']}
                                {/if}

                                {assign var = number_product value = 0}
                                {if !empty($config_data['number_product'])}
                                    {assign var = number_product value = $config_data['number_product']}
                                {/if}

                                {assign var = number_brand value = 0}
                                {if !empty($config_data['number_brand'])}
                                    {assign var = number_brand value = $config_data['number_brand']}
                                {/if}

                                {assign var = number_tag_product value = 0}
                                {if !empty($config_data['number_tag_product'])}
                                    {assign var = number_tag_product value = $config_data['number_tag_product']}
                                {/if}

                                {assign var = number_attribute_product value = 0}
                                {if !empty($config_data['number_attribute_product'])}
                                    {assign var = number_attribute_product value = $config_data['number_attribute_product']}
                                {/if}

                                {assign var = number_attribute_product_item value = 0}
                                {if !empty($config_data['number_attribute_product_item'])}
                                    {assign var = number_attribute_product_item value = $config_data['number_attribute_product_item']}
                                {/if}

                                <tbody>
                                    <tr>
                                        <td scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="categories[article_check]" class="check-single" type="checkbox" {if $number_category_article > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </td>

                                        <td>
                                            {__d('admin', 'danh_muc_bai_viet')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_danh_muc_bai_viet')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_category_article}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_category_article}" type="text" value="{$number_category_article}" name="categories[article_record]">
                                            </div>
                                        </td>      
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="articles[check]" class="check-single" type="checkbox" {if $number_article > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'bai_viet')} 
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_bai_viet')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_article}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_article}" type="text" value="{$number_article}" name="articles[record]">
                                            </div>
                                        </td>  
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="attributes[article_check]" class="check-single" type="checkbox" {if $number_attribute_article > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'thuoc_tinh_mo_rong_bai_viet')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_thuoc_tinh_mo_rong_cua_bai_viet')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_attribute_article}
                                        </td>

                                        <td class="align-middle">
                                            <span nh-show-attributes type="article" class="btn btn-sm btn-secondary w-100">
                                                <i class="fa fa-cog fs-14"></i>
                                                {__d('admin', 'cau_hinh')}
                                            </span>
                                        </td>  
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="tags[article_check]" class="check-single" type="checkbox" {if $number_tag_article > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>
                                        <td>
                                            {__d('admin', 'the_tag_bai_viet')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_the_tag_cua_bai_viet')}
                                            </span>
                                        </td>
                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_tag_article}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_tag_article}" type="text" value="{$number_tag_article}" name="tags[article_record]">
                                            </div>
                                        </td>  
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="categories[product_check]" class="check-single" type="checkbox" {if $number_category_product > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'danh_muc_san_pham')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_danh_muc_san_pham')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_category_product}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_category_product}" type="text" value="{$number_category_product}" name="categories[product_record]">
                                            </div>
                                        </td>
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="products[check]" class="check-single" type="checkbox" {if $number_product > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'san_pham')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_san_pham')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_product}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_product}" type="text" value="{$number_product}" name="products[record]">
                                            </div>
                                        </td>   
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="attributes[product_check]" class="check-single" type="checkbox" {if $number_attribute_product > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'thuoc_tinh_mo_rong_san_pham')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_thuoc_tinh_mo_rong_cua_san_pham')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_attribute_product}
                                        </td>

                                        <td class="align-middle">
                                            <span nh-show-attributes type="product" class="btn btn-sm btn-secondary w-100">
                                                <i class="fa fa-cog fs-14"></i>
                                                {__d('admin', 'cau_hinh')}
                                            </span>
                                        </td>  
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="attributes[product_check]" class="check-single" type="checkbox" {if $number_attribute_product > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'thuoc_tinh_mo_rong_phien_ban_san_pham')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_thuoc_tinh_mo_rong_cua_phien_ban_san_pham')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_attribute_product_item}
                                        </td>

                                        <td class="align-middle">
                                            <span nh-show-attributes type="product_item" class="btn btn-sm btn-secondary w-100">
                                                <i class="fa fa-cog fs-14"></i>
                                                {__d('admin', 'cau_hinh')}
                                            </span>
                                        </td>  
                                    </tr>
                                    
                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="brands[check]" class="check-single" type="checkbox" {if $number_brand > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>

                                        <td>
                                            {__d('admin', 'thuong_hieu')}
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_thuong_hieu')}
                                            </span>
                                        </td>

                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_brand}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_brand}" type="text" value="{$number_brand}" name="brands[record]">
                                            </div>
                                        </td>  
                                    </tr>

                                    <tr>
                                        <th scope="row">
                                            <label class="kt-checkbox kt-checkbox--tick kt-checkbox--danger ml-10 mb-1">
                                                <input name="tags[product_check]" class="check-single" type="checkbox" {if $number_tag_product > 0}checked{/if}>
                                                <span></span>
                                            </label>
                                        </th>
                                        <td>
                                            Thẻ Tag sản phẩm
                                            <span class="form-text text-muted">
                                                {__d('admin', 'export_du_lieu_the_tag_cua_san_pham')}
                                            </span>
                                        </td>
                                        <td class="align-middle text-center text-primary kt-font-bold">
                                            {$number_tag_product}
                                        </td>

                                        <td class="align-middle">
                                            <div class="form-group mb-0">
                                                <input class="form-control form-control-sm number-input text-left text-success kt-font-bold" nh-record-export nh-record-max="{$number_tag_product}" type="text" value="{$number_tag_product}" name="tags[product_record]">
                                            </div>
                                        </td>    
                                    </tr>
                                </tbody>
                            </table>
                        </form>
                    </div>

                    <div class="col-sm-5">
                        <div class="config-data-extend border h-100 d-none" nh-list-attributes>
                            <div class="listbox-title d-flex justify-content-between align-items-center">
                                <span class="title kt-font-bold">
                                    {__d('admin', 'cau_hinh_mo_rong')}
                                </span>

                                <span class="btn btn-sm btn-primary" nh-save-config-attributes>
                                    {__d('admin', 'luu_cau_hinh')}
                                </span>
                            </div>

                            <div class="listbox-content p-20"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">
                    {__d('admin', 'dong')}
                </button>
                
                <button id="btn-config-data" type="button" class="btn btn-sm btn-primary">
                    {__d('admin', 'cap_nhat')}
                </button>
            </div>
        </div>
    </div>
</div>

<div id="config-id-modal" class="modal fade" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    {__d('admin', 'cau_hinh_id_du_lieu')}
                </h5>
                <button type="button" class="close" data-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                {assign var = config_id value = []}
                {if !empty($migrate.config_id.data)}
                    {assign var = config_id value = $migrate.config_id.data}
                {/if}

                <form id="config-id-form" action="/migrate-process/config-id/{$code}" method="POST" autocomplete="off">
                    <div class="alert alert-warning" role="alert">
                        <div class="alert-icon">
                            <i class="flaticon-warning"></i>
                        </div>

                        <div class="alert-text">
                            {__d('admin', 'luu_y_kiem_tra_id_trong_cac_bang_cua_database_sau_nay_se_import_du_lieu_dam_bao_rang_id_cau_hinh_cho_cac_bang_la_gia_tri_cao_nhat_hien_tai')}
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-xl-6 col-lg-8">
                            <div class="form-group">
                                <label>
                                    {__d('admin', 'id_bat_dau_cua_danh_muc')}
                                    <span class="kt-font-danger">*</span>
                                </label>

                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="fa fa-align-justify"></i>
                                        </span>
                                    </div>
                                    <input name="category_id_start" value="{if !empty($config_id.category_id_start)}{$config_id.category_id_start}{else}1000{/if}" class="form-control form-control-sm" type="number">
                                </div>
                            </div>

                            <div class="form-group">
                                <label>
                                    ID bắt đầu của bài viết
                                    <span class="kt-font-danger">*</span>
                                </label>

                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="fa fa-file-alt"></i>
                                        </span>
                                    </div>
                                    <input name="article_id_start" value="{if !empty($config_id.article_id_start)}{$config_id.article_id_start}{else}1000{/if}" class="form-control form-control-sm" type="number">
                                </div>
                            </div>

                            <div class="form-group">
                                <label>
                                    ID bắt đầu của sản phẩm
                                    <span class="kt-font-danger">*</span>
                                </label>

                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="fa fa-box-open"></i>
                                        </span>
                                    </div>
                                    <input name="product_id_start" value="{if !empty($config_id.product_id_start)}{$config_id.product_id_start}{else}1000{/if}" class="form-control form-control-sm" type="number">
                                </div>
                            </div>

                            <div class="form-group">
                                <label>
                                    ID bắt đầu của thương thiệu
                                    <span class="kt-font-danger">*</span>
                                </label>

                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="fab fa-dribbble-square"></i>
                                        </span>
                                    </div>
                                    <input name="brand_id_start" value="{if !empty($config_id.brand_id_start)}{$config_id.brand_id_start}{else}1000{/if}" class="form-control form-control-sm" type="number">
                                </div>
                            </div>

                            <div class="form-group">
                                <label>
                                    ID bắt đầu của thẻ Tag
                                    <span class="kt-font-danger">*</span>
                                </label>

                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="fa fa-tags"></i>
                                        </span>
                                    </div>
                                    <input name="tag_id_start" value="{if !empty($config_id.tag_id_start)}{$config_id.tag_id_start}{else}1000{/if}" class="form-control form-control-sm" type="number">
                                </div>
                            </div>

                            <div class="form-group">
                                <label>
                                    ID bắt đầu của thuộc tính mở rộng
                                    <span class="kt-font-danger">*</span>
                                </label>

                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">
                                            <i class="fa fa-indent"></i>
                                        </span>
                                    </div>
                                    <input name="attribute_id_start" value="{if !empty($config_id.attribute_id_start)}{$config_id.attribute_id_start}{else}1000{/if}" class="form-control form-control-sm" type="number">
                                </div>
                            </div>
                        </div>
                    </div>                    
                </form>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">
                    Đóng
                </button>
                
                <button id="btn-config-id" type="button" class="btn btn-sm btn-primary">
                    Cập nhật
                </button>
            </div>
        </div>
    </div>
</div>

<div id="config-cdn-modal" class="modal fade" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    {__d('admin', 'cau_hinh_thong_tin_cdn')}
                </h5>
                <button type="button" class="close" data-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                {assign var = config_cdn value = []}
                {if !empty($migrate.config_cdn.data)}
                    {assign var = config_cdn value = $migrate.config_cdn.data}
                {/if}

                <form id="config-cdn-form" action="/migrate-process/config-general/{$code}" method="POST" autocomplete="off">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'duong_dan_cdn_hien_tai')}
                            <span class="kt-font-danger">*</span>
                        </label>

                        <div class="input-group mb-5">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <i class="fa fa-images"></i>
                                </span>
                            </div>
                            <input name="url_website" value="{if !empty($config_general.url_website)}{$config_general.url_website}{/if}" class="form-control form-control-sm" type="text" placeholder="Ví dụ: https://cdn001.com">                            
                        </div>
                    </div>

                    <div class="form-group">
                        <label>
                            {__d('admin', 'duong_dan_cdn_moi')}
                            <span class="kt-font-danger">*</span>
                        </label>

                        <div class="input-group mb-5">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <i class="fa fa-images"></i>
                                </span>
                            </div>
                            <input name="url_cdn" value="{if !empty($config_general.url_cdn)}{$config_general.url_cdn}{/if}" class="form-control form-control-sm" type="text" placeholder="Ví dụ: https://cdn001.com">                            
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">
                    {__d('admin', 'dong')}
                </button>
                
                <button id="btn-config-cdn" type="button" class="btn btn-sm btn-primary">
                    {__d('admin', 'cap_nhat')}
                </button>
            </div>
        </div>
    </div>
</div>