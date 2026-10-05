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
            <div class="row">
                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'so_danh_gia_hien_thi')}
                        </label>            
                        <input name="{NUMBER_RECORD}" value="{if !empty($config_data[{NUMBER_RECORD}])}{$config_data[{NUMBER_RECORD}]}{else}20{/if}" class="form-control form-control-sm" type="number" max="200">
                        <span class="form-text text-muted">
                            {__d('admin', 'so_luong_danh_gia_hien_thi_trong_1_trang')}
                        </span>
                    </div>
                </div>

                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'sap_xep_theo')}
                        </label>
                        {$this->Form->select("{SORT_FIELD}", $this->TemplateAdmin->getListSortFieldOfRating(), ['empty' => "{__d('admin', 'chon')}", 'default' => "{if !empty($config_data[{SORT_FIELD}])}{$config_data[{SORT_FIELD}]}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker'])}
                    </div>
                </div>
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
                <div class="col-lg-6 col-12"></div>
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
                    <div class="form-group mb-15">
                        <label>
                            <strong>{__d('admin', 'khoang_cach_item')}</strong>
                        </label>
                        <div class="row">
                            <div class="col">
                                <div class="form-group">
                                    <label>
                                        Gridview Padding Top
                                    </label>
                                    <input name="gridview_padding_top" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.gridview_padding_top)}{$config_layout.gridview_padding_top}{/if}">
                                </div>
                                <div class="form-group">
                                    <label>
                                        Item Line Spacing
                                    </label>
                                    <input name="item_line_spacing" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.item_line_spacing)}{$config_layout.item_line_spacing}{/if}">
                                </div>
                            </div>
                            <div class="col">
                                <div class="form-group">
                                    <label>
                                        Margin Left Right
                                    </label>
                                    <input name="margin_left_right_item" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.margin_left_right_item)}{$config_layout.margin_left_right_item}{/if}">
                                </div>
                            </div>
                        </div>
                    </div>
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


