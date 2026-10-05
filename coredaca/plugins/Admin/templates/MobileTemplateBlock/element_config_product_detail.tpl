<div class="kt-portlet nh-portlet">
    <div class="kt-portlet__head">
        <div class="kt-portlet__head-label">
            <h3 class="kt-portlet__head-title">
                <i class="fa fa-database mr-5"></i>
                {__d('admin', 'cau_hinh_du_lieu')}
            </h3>
        </div>
    </div>

    <div class="kt-portlet__body">
        <form action="{ADMIN_PATH}/mobile-app/block/save-data-config{if !empty($code)}/{$code}{/if}" method="POST" autocomplete="off">
            {assign var = data_type value = ''}
            {if !empty($config_data[{DATA_TYPE}])}
                {assign var = data_type value = $config_data[{DATA_TYPE}]}
            {/if}

            <div class="row">
                <div class="col-lg-6 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'lay_du_lieu_theo')}
                        </label>
                        <select id="{DATA_TYPE}" name="{DATA_TYPE}" class="form-control form-control-sm kt-selectpicker">                            
                            <option value="{BY_PAGE_ID}" {if $data_type == {BY_PAGE_ID}}selected="true"{/if}>
                                {__d('admin', 'tu_dong_theo_trang')}
                            </option>

                            <option value="{PRODUCT}" {if $data_type == {PRODUCT}}selected="true"{/if}>
                                {__d('admin', 'chon_san_pham')}
                            </option>
                        </select>
                    </div>
                </div>
            </div>

            {assign var = data value = []}
            {if !empty($config_data.data_ids)}
                {assign var = data value = $config_data.data_ids}
            {/if}

            <div id="wrap-view-data">
                {if !empty($data_type)}
                    {$this->element("../MobileTemplateBlock/load_view_data", ['data_type' => $data_type, 'block_type' => $type, 'data' => $data])}
                {/if}
            </div>

            <div class="kt-separator kt-separator--space-lg kt-separator--border-solid mt-10 mb-20"></div>

            <div class="form-group mb-0">
                <div class="btn-group">
                    <button type="button" class="btn btn-sm btn-brand btn-save">
                        {__d('admin', 'luu_cau_hinh')}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="kt-portlet nh-portlet">
    <div class="kt-portlet__head">
        <div class="kt-portlet__head-label">
            <h3 class="kt-portlet__head-title">
                <i class="fa fa-tablet-alt mr-5"></i>
                {__d('admin', 'cau_hinh_giao_dien')}
            </h3>
        </div>
    </div>

    <div class="kt-portlet__body">
        <form action="{ADMIN_PATH}/mobile-app/block/save-layout-config{if !empty($code)}/{$code}{/if}" method="POST" autocomplete="off">
            <div class="row">
                <div class="col-lg-6 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'tieu_de_hien_thi')}
                        </label>
                        <input name="title" value="{if !empty($config_layout.title)}{$config_layout.title}{/if}" class="form-control form-control-sm" type="text">
                    </div>
                </div>
                
                <div class="col-lg-6 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'mau_block')} (color_block)
                        </label>
                        <div class="input-group">
                            <span>
                                <input type="hidden" class="js-minicolors-select" value="{if !empty($config_layout.color_block)}{$config_layout.color_block}{/if}">
                            </span>
                            <input name="color_block" value="{if !empty($config_layout.color_block)}{$config_layout.color_block}{/if}" class="form-control form-control-sm js-minicolors-input" data-position="bottom left" type="text">
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'ti_le_chieu_cao_anh')}
                        </label>

                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <i class="fa fa-arrows-alt-v"></i>
                                </span>
                            </div>
                            <input name="image_height" value="{if !empty($config_layout.image_height)}{$config_layout.image_height}{/if}" class="form-control form-control-sm" type="number">
                        </div>            
                    </div>
                </div>

                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'ti_le_chieu_rong_anh')}
                        </label>

                        <div class="input-group">
                            <div class="input-group-prepend">
                                <span class="input-group-text">
                                    <i class="fa fa-arrows-alt-h"></i>
                                </span>
                            </div>
                            <input name="image_width" value="{if !empty($config_layout.image_width)}{$config_layout.image_width}{/if}" class="form-control form-control-sm" type="number">
                        </div>            
                    </div>
                </div>

                <div class="col-lg-6 col-12">
                    <div class="form-group">
                        <label class="col-form-label">
                            {__d('admin', 'mau_item')} (color_item)
                        </label>
                        <input name="color_item" value="{if !empty($config_layout.color_item)}{$config_layout.color_item}{/if}" class="form-control form-control-sm js-minicolors" data-position="bottom left" type="text" maxlength="100">
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6 col-12"></div>
                <div class="col-lg-6 col-12">
                    <div class="form-group">
                        <label>
                            Border Radius
                        </label>
                        <input name="border_radius" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.border_radius)}{$config_layout.border_radius}{/if}">
                    </div>
                </div>
            </div>

            <div class="kt-separator kt-separator--space-lg kt-separator--border-solid mt-10 mb-20"></div>

            <div class="row">
                <div class="col-md">
                    <div class="form-group mb-15">
                        <label>
                            <strong>{__d('admin', 'khoang_cach_block')}</strong>
                        </label>
                        <div class="row">
                            <div class="col">
                                <div class="form-group">
                                    <label>
                                        Padding Top
                                    </label>
                                    <input name="padding_top_block" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.padding_top_block)}{$config_layout.padding_top_block}{/if}">
                                </div>

                                <div class="form-group">
                                    <label>
                                        Padding Bottom
                                    </label>
                                    <input name="padding_bottom_block" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.padding_bottom_block)}{$config_layout.padding_bottom_block}{/if}">
                                </div>
                            </div>
                            <div class="col">
                                <div class="form-group">
                                    <label>
                                        Padding Left Right
                                    </label>
                                    <input name="padding_left_right_block" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.padding_left_right_block)}{$config_layout.padding_left_right_block}{/if}">
                                </div>

                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <div class="form-group">
                                    <label>
                                        Margin Top
                                    </label>
                                    <input name="margin_top_block" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.margin_top_block)}{$config_layout.margin_top_block}{/if}">
                                </div>

                                <div class="form-group">
                                    <label>
                                        Margin Bottom
                                    </label>
                                    <input name="margin_bottom_block" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.margin_bottom_block)}{$config_layout.margin_bottom_block}{/if}">
                                </div>
                            </div>
                            <div class="col">
                                <div class="form-group">
                                    <label>
                                        Margin Left Right
                                    </label>
                                    <input name="margin_left_right_block" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.margin_left_right_block)}{$config_layout.margin_left_right_block}{/if}">
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md">
                </div>
            </div>

            <div class="form-group mb-0">
                <div class="btn-group">
                    <button type="button" class="btn btn-sm btn-brand btn-save">
                        {__d('admin', 'luu_cau_hinh')}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
