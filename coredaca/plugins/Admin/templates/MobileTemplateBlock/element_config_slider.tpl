{assign var = filemanager_access_key value = $this->SystemAdmin->getAccessKeyUpload()}
{assign var = filemanager_access_key_template value = $this->SystemAdmin->getAccessKeyUploadToMobileTemplate()}

{assign var = list_item value = []}
{if !empty($config_data.items)}
    {assign var = list_item value = $config_data.items}
{/if}

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
        <form id="data-config-form" action="{ADMIN_PATH}/mobile-app/block/save-data-config{if !empty($code)}/{$code}{/if}" method="POST" autocomplete="off">
            <div class="form-group">
                <span id="add-item" class="btn btn-sm btn-success">
                    <i class="fa fa-plus"></i>
                    {__d('admin', 'them_slider')}
                </span>
            </div>

            <div class="row">
                <div id="wrap-item-config" class="col-12">
                    {if !empty($list_item)}
                        {foreach from = $list_item item = item}
                            {$this->element("../MobileTemplateBlock/load_item_slider", [
                                'item' => $item,
                                'filemanager_access_key' => $filemanager_access_key,
                                'filemanager_access_key_template' => $filemanager_access_key_template
                            ])}
                        {/foreach}
                    {else}
                        {$this->element("../MobileTemplateBlock/load_item_slider", [
                            'item' => [],
                            'filemanager_access_key' => $filemanager_access_key,
                            'filemanager_access_key_template' => $filemanager_access_key_template
                        ])}
                    {/if}
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
                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'so_luong_tren_dong')}
                            <b>(Mobile)</b>
                        </label>            
                        <input name="number_on_line" value="{if !empty($config_layout.number_on_line)}{$config_layout.number_on_line}{else}1{/if}" class="form-control form-control-sm" type="number">
                    </div>
                </div>

                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'so_luong_tren_dong')}
                            <b>(Ipad/Tablet)</b>
                        </label>            
                        <input name="ipad_number_on_line" value="{if !empty($config_layout.ipad_number_on_line)}{$config_layout.ipad_number_on_line}{else}1{/if}" class="form-control form-control-sm" type="number">
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
                        <label>
                            Border Radius
                        </label>
                        <input name="border_radius" class="form-control form-control-sm number-input" type="text" value="{if !empty($config_layout.border_radius)}{$config_layout.border_radius}{/if}">
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-3 col-12">
                    <div class="form-group">
                        <label>
                            {__d('admin', 'dinh_dang')}
                        </label>
                        
                        {$this->Form->select('format', $this->MobileTemplateAdmin->listFormatItemSlider(), ['empty' => null, 'default' => "{if !empty($config_layout.format)}{$config_layout.format}{/if}", 'class' => 'form-control form-control-sm kt-selectpicker'])}
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
