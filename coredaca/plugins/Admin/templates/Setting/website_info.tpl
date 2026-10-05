{assign var = filemanager_access_key value = {$this->SystemAdmin->getAccessKeyUpload()}}
<div class="kt-subheader kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {if !empty($title_for_layout)}{$title_for_layout}{/if}
            </h3>
        </div>

        <div class="kt-subheader__toolbar">
            <div class="btn-group">
                <button id="btn-save" type="button" class="btn btn-sm btn-brand btn-save" shortcut="112">
                    <i class="la la-edit"></i>
                    {__d('admin', 'cap_nhat')} (F1)
                </button>
            </div>
        </div>
    </div>
</div>

<div class="kt-container kt-container--fluid kt-grid__item kt-grid__item--fluid">
    <form id="main-form" action="{ADMIN_PATH}/setting/save/{$group}" method="POST" autocomplete="off">
        <div class="kt-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'thong_tin_chinh')}
                    </h3>
                </div>

                {if !empty($languages)}
                    <div class="kt-portlet__head-toolbar">
                        <ul class="nav nav-tabs border-0" role="tablist">
                            {foreach from=$languages key=code item=item}
                                {if !empty($item)}
                                    <li class="nav-item">
                                        <a id="add-item" class="btn btn-sm btn-default {if !empty($code) && !empty($lang) && $code == $lang}active{/if} list-flags {if !$item@last}mr-10{/if}" data-toggle="tab" href="#kt_tab_setting_{$code}" role="tab" aria-selected="false">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$code}.svg" alt="{$item}" class="flag mr-5">
                                            {$item}
                                        </a>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>

            <!--begin::Form-->
            <div class="kt-form">
                <div class="kt-portlet__body">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="tab-content">
                                {foreach from=$languages key=code item=item}
                                    {if !empty($code)}
                                        <div class="tab-pane {if !empty($code) && !empty($lang) && $code == $lang}active{/if}" id="kt_tab_setting_{$code}" role="tabpanel">
                                            <div class="row">
                                                <div class="col-lg-12">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'ten_website')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-globe-americas"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_website_name" value="{if !empty($website_info[$code].website_name)}{$website_info[$code].website_name}{/if}" class="form-control form-control-sm" type="text" maxlength="255">
                                                        </div>
                                                    </div>

                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'ten_cong_ty')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-city"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_company_name" value="{if !empty($website_info[$code].company_name)}{$website_info[$code].company_name}{/if}" class="form-control form-control-sm" type="text" maxlength="255">
                                                        </div>
                                                    </div>

                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'hotline')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-headset"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_hotline" value="{if !empty($website_info[$code].hotline)}{$website_info[$code].hotline}{/if}" type="text" class="form-control form-control-sm phone-input">
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'so_dien_thoai')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-phone"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_phone" value="{if !empty($website_info[$code].phone)}{$website_info[$code].phone}{/if}" type="text" class="form-control form-control-sm phone-input">
                                                        </div>
                                                    </div>

                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'email')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-envelope"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_email" value="{if !empty($website_info[$code].email)}{$website_info[$code].email}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
                                                        </div>
                                                    </div>

                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'dia_chi')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-map"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_address" value="{if !empty($website_info[$code].address)}{$website_info[$code].address}{/if}" class="form-control form-control-sm" type="text" maxlength="255">
                                                        </div>
                                                    </div>

                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Bản đồ (Nhúng iframe)
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-map"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_map" value='{if !empty($website_info[$code].map)}{$website_info[$code].map}{/if}' class="form-control form-control-sm" type="text">
                                                        </div>
                                                    </div>

                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            {__d('admin', 'copyright')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-copyright"></i>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_copyright" value="{if !empty($website_info[$code].copyright)}{$website_info[$code].copyright}{/if}" class="form-control form-control-sm" type="text" maxlength="255">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    {/if}
                                {/foreach}
                            </div>
                        </div>

                        <div class="col-lg-6">
                            <div class="row">
                                <div class="col-lg-3">
                                    <div class="form-group">
                                        <label class="w-100">
                                            {__d('admin', 'favicon')}
                                        </label>
                                        {assign var = bg_favicon value = ''}
                                        {if !empty($website_info[$lang].favicon)}
                                            {assign var = bg_favicon value = "background-image: url('{CDN_URL}{$website_info[$lang].favicon}');;background-size: contain;background-position: 50% 50%;"}
                                        {/if}
                                        <div class="kt-avatar kt-avatar--outline kt-avatar--circle- {if !empty($bg_favicon)}kt-avatar--changed{/if}">
                                            <a {if !empty($website_info[$lang].favicon)}href="{CDN_URL}{$website_info[$lang].favicon}"{/if} target="_blank" class="kt-avatar__holder kt-favicon d-block" style="{$bg_favicon}"></a>
                                            <label class="kt-avatar__upload btn-select-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'chon_anh')}" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id=favicon&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                                <i class="fa fa-pen"></i>
                                            </label>
                                            <span class="kt-avatar__cancel btn-clear-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'xoa_anh')}">
                                                <i class="fa fa-times"></i>
                                            </span>

                                            <input id="favicon" name="favicon" value="{if !empty($website_info[$lang].favicon)}{htmlentities($website_info[$lang].favicon)}{/if}" type="hidden" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-9">
                                    <div class="form-group">
                                        <label class="w-100">{__d('admin', 'logo_cong_ty')}</label>
                                        {assign var = bg_logo value = ''}
                                        {if !empty($website_info[$lang].company_logo)}
                                            {assign var = bg_logo value = "background-image: url('{CDN_URL}{$website_info[$lang].company_logo}');background-size: contain;background-position: 50% 50%;"}
                                        {/if}
                                        <div class="kt-avatar kt-avatar--outline kt-avatar--circle- {if !empty($bg_logo)}kt-avatar--changed{/if}">
                                            <a {if !empty($website_info[$lang].company_logo)}href="{CDN_URL}{$website_info[$lang].company_logo}"{/if} target="_blank" class="kt-avatar__holder d-block" style="{$bg_logo}"></a>
                                            <label class="kt-avatar__upload btn-select-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'chon_anh')}" data-src="{CDN_URL}/filemanager/dialog.php?type=1&crossdomain=1&akey={$filemanager_access_key}&field_id=company_logo&lang={LANGUAGE_ADMIN}" data-type="iframe">
                                                <i class="fa fa-pen"></i>
                                            </label>
                                            <span class="kt-avatar__cancel btn-clear-image" data-toggle="kt-tooltip" data-original-title="{__d('admin', 'xoa_anh')}">
                                                <i class="fa fa-times"></i>
                                            </span>

                                            <input id="company_logo" name="company_logo" value="{if !empty($website_info[$lang].company_logo)}{htmlentities($website_info[$lang].company_logo)}{/if}" type="hidden" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--end::Form-->
        </div>
        
        <div class="kt-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Affiliate
                    </h3>
                </div>

                {if !empty($languages)}
                    <div class="kt-portlet__head-toolbar">
                        <ul class="nav nav-tabs border-0" role="tablist">
                            {foreach from=$languages key=code item=item}
                                {if !empty($item)}
                                    <li class="nav-item">
                                        <a id="add-item" class="btn btn-sm btn-default {if !empty($code) && !empty($lang) && $code == $lang}active{/if} list-flags {if !$item@last}mr-10{/if}" data-toggle="tab" href="#kt_tab_setting_social_{$code}" role="tab" aria-selected="false">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$code}.svg" alt="{$item}" class="flag mr-5">
                                            {$item}
                                        </a>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>

            <!--begin::Form-->
            <div class="kt-form">
                <div class="kt-portlet__body">
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="tab-content">
                                {foreach from=$languages key=code item=item}
                                    {if !empty($code)}
                                        <div class="tab-pane {if !empty($code) && !empty($lang) && $code == $lang}active{/if}" id="kt_tab_setting_social_{$code}" role="tabpanel">
                                            <div class="row">
                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Hoa hồng
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <input name="{$code}_affiliate_percent" value="{if !empty($website_info[$code].affiliate_percent)}{$website_info[$code].affiliate_percent}{/if}" type="text" class="form-control form-control-sm">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    %</span>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    {/if}
                                {/foreach}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--end::Form-->
        </div>

        <div class="kt-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Mạng xã hội
                    </h3>
                </div>

                {if !empty($languages)}
                    <div class="kt-portlet__head-toolbar">
                        <ul class="nav nav-tabs border-0" role="tablist">
                            {foreach from=$languages key=code item=item}
                                {if !empty($item)}
                                    <li class="nav-item">
                                        <a id="add-item" class="btn btn-sm btn-default {if !empty($code) && !empty($lang) && $code == $lang}active{/if} list-flags {if !$item@last}mr-10{/if}" data-toggle="tab" href="#kt_tab_setting_social_{$code}" role="tab" aria-selected="false">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$code}.svg" alt="{$item}" class="flag mr-5">
                                            {$item}
                                        </a>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>

            <!--begin::Form-->
            <div class="kt-form">
                <div class="kt-portlet__body">
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="tab-content">
                                {foreach from=$languages key=code item=item}
                                    {if !empty($code)}
                                        <div class="tab-pane {if !empty($code) && !empty($lang) && $code == $lang}active{/if}" id="kt_tab_setting_social_{$code}" role="tabpanel">
                                            <div class="row">
                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Zalo
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"
                                                                        width="15" height="15"
                                                                        viewBox="0 0 50 50"
                                                                        style=" fill:#74788d;"><path d="M 9 4 C 6.2504839 4 4 6.2504839 4 9 L 4 41 C 4 43.749516 6.2504839 46 9 46 L 41 46 C 43.749516 46 46 43.749516 46 41 L 46 9 C 46 6.2504839 43.749516 4 41 4 L 9 4 z M 9 6 L 15.580078 6 C 12.00899 9.7156859 10 14.518083 10 19.5 C 10 24.66 12.110156 29.599844 15.910156 33.339844 C 16.030156 33.549844 16.129922 34.579531 15.669922 35.769531 C 15.379922 36.519531 14.799687 37.499141 13.679688 37.869141 C 13.249688 38.009141 12.97 38.430859 13 38.880859 C 13.03 39.330859 13.360781 39.710781 13.800781 39.800781 C 16.670781 40.370781 18.529297 39.510078 20.029297 38.830078 C 21.379297 38.210078 22.270625 37.789609 23.640625 38.349609 C 26.440625 39.439609 29.42 40 32.5 40 C 36.593685 40 40.531459 39.000731 44 37.113281 L 44 41 C 44 42.668484 42.668484 44 41 44 L 9 44 C 7.3315161 44 6 42.668484 6 41 L 6 9 C 6 7.3315161 7.3315161 6 9 6 z M 33 15 C 33.55 15 34 15.45 34 16 L 34 25 C 34 25.55 33.55 26 33 26 C 32.45 26 32 25.55 32 25 L 32 16 C 32 15.45 32.45 15 33 15 z M 18 16 L 23 16 C 23.36 16 23.700859 16.199531 23.880859 16.519531 C 24.050859 16.829531 24.039609 17.219297 23.849609 17.529297 L 19.800781 24 L 23 24 C 23.55 24 24 24.45 24 25 C 24 25.55 23.55 26 23 26 L 18 26 C 17.64 26 17.299141 25.800469 17.119141 25.480469 C 16.949141 25.170469 16.960391 24.780703 17.150391 24.470703 L 21.199219 18 L 18 18 C 17.45 18 17 17.55 17 17 C 17 16.45 17.45 16 18 16 z M 27.5 19 C 28.11 19 28.679453 19.169219 29.189453 19.449219 C 29.369453 19.189219 29.65 19 30 19 C 30.55 19 31 19.45 31 20 L 31 25 C 31 25.55 30.55 26 30 26 C 29.65 26 29.369453 25.810781 29.189453 25.550781 C 28.679453 25.830781 28.11 26 27.5 26 C 25.57 26 24 24.43 24 22.5 C 24 20.57 25.57 19 27.5 19 z M 38.5 19 C 40.43 19 42 20.57 42 22.5 C 42 24.43 40.43 26 38.5 26 C 36.57 26 35 24.43 35 22.5 C 35 20.57 36.57 19 38.5 19 z M 27.5 21 C 27.39625 21 27.29502 21.011309 27.197266 21.03125 C 27.001758 21.071133 26.819727 21.148164 26.660156 21.255859 C 26.500586 21.363555 26.363555 21.500586 26.255859 21.660156 C 26.148164 21.819727 26.071133 22.001758 26.03125 22.197266 C 26.011309 22.29502 26 22.39625 26 22.5 C 26 22.60375 26.011309 22.70498 26.03125 22.802734 C 26.051191 22.900488 26.079297 22.994219 26.117188 23.083984 C 26.155078 23.17375 26.202012 23.260059 26.255859 23.339844 C 26.309707 23.419629 26.371641 23.492734 26.439453 23.560547 C 26.507266 23.628359 26.580371 23.690293 26.660156 23.744141 C 26.819727 23.851836 27.001758 23.928867 27.197266 23.96875 C 27.29502 23.988691 27.39625 24 27.5 24 C 27.60375 24 27.70498 23.988691 27.802734 23.96875 C 28.487012 23.82916 29 23.22625 29 22.5 C 29 21.67 28.33 21 27.5 21 z M 38.5 21 C 38.39625 21 38.29502 21.011309 38.197266 21.03125 C 38.099512 21.051191 38.005781 21.079297 37.916016 21.117188 C 37.82625 21.155078 37.739941 21.202012 37.660156 21.255859 C 37.580371 21.309707 37.507266 21.371641 37.439453 21.439453 C 37.303828 21.575078 37.192969 21.736484 37.117188 21.916016 C 37.079297 22.005781 37.051191 22.099512 37.03125 22.197266 C 37.011309 22.29502 37 22.39625 37 22.5 C 37 22.60375 37.011309 22.70498 37.03125 22.802734 C 37.051191 22.900488 37.079297 22.994219 37.117188 23.083984 C 37.155078 23.17375 37.202012 23.260059 37.255859 23.339844 C 37.309707 23.419629 37.371641 23.492734 37.439453 23.560547 C 37.507266 23.628359 37.580371 23.690293 37.660156 23.744141 C 37.739941 23.797988 37.82625 23.844922 37.916016 23.882812 C 38.005781 23.920703 38.099512 23.948809 38.197266 23.96875 C 38.29502 23.988691 38.39625 24 38.5 24 C 38.60375 24 38.70498 23.988691 38.802734 23.96875 C 39.487012 23.82916 40 23.22625 40 22.5 C 40 21.67 39.33 21 38.5 21 z"></path>
                                                                    </svg>
                                                                    <span>&ensp;zalo.me/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_zalo" value="{if !empty($website_info[$code].zalo)}{$website_info[$code].zalo}{/if}" type="text" class="form-control form-control-sm phone-input">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            WhatsApp
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fab fa-whatsapp"></i>
                                                                    <span>&ensp;wa.me/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_whatsapp" value="{if !empty($website_info[$code].whatsapp)}{$website_info[$code].whatsapp}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Facebook
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fab fa-facebook"></i>
                                                                    <span>&ensp;facebook.com/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_facebook" value="{if !empty($website_info[$code].facebook)}{$website_info[$code].facebook}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Tiktok
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <svg style="height: 15px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><!-- Font Awesome Pro 5.15.4 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) --><path style="fill:#74788d;" d="M448,209.91a210.06,210.06,0,0,1-122.77-39.25V349.38A162.55,162.55,0,1,1,185,188.31V278.2a74.62,74.62,0,1,0,52.23,71.18V0l88,0a121.18,121.18,0,0,0,1.86,22.17h0A122.18,122.18,0,0,0,381,102.39a121.43,121.43,0,0,0,67,20.14Z"/></svg>
                                                                    <span>&ensp;tiktok.com/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_tiktok" value="{if !empty($website_info[$code].tiktok)}{$website_info[$code].tiktok}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Instagram
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fab fa-instagram"></i>
                                                                    <span>&ensp;instagram.com/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_instagram" value="{if !empty($website_info[$code].instagram)}{$website_info[$code].instagram}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Twitter
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fab fa-twitter"></i>
                                                                    <span>&ensp;twitter.com/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_twitter" value="{if !empty($website_info[$code].twitter)}{$website_info[$code].twitter}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Linkedin
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fab fa-linkedin-in"></i>
                                                                    <span>&ensp;linkedin.com/in/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_linkedin" value="{if !empty($website_info[$code].linkedin)}{$website_info[$code].linkedin}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Youtube
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fab fa-youtube"></i>
                                                                    <span>&ensp;youtube.com/c/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_youtube" value="{if !empty($website_info[$code].youtube)}{$website_info[$code].youtube}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    {/if}
                                {/foreach}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--end::Form-->
        </div>

        <div class="kt-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Link trang thương mại điện tử
                    </h3>
                </div>

                {if !empty($languages)}
                    <div class="kt-portlet__head-toolbar">
                        <ul class="nav nav-tabs border-0" role="tablist">
                            {foreach from=$languages key=code item=item}
                                {if !empty($item)}
                                    <li class="nav-item">
                                        <a id="add-item" class="btn btn-sm btn-default {if !empty($code) && !empty($lang) && $code == $lang}active{/if} list-flags {if !$item@last}mr-10{/if}" data-toggle="tab" href="#kt_tab_setting_ecommerce_{$code}" role="tab" aria-selected="false">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$code}.svg" alt="{$item}" class="flag mr-5">
                                            {$item}
                                        </a>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>

            <!--begin::Form-->
            <div class="kt-form">
                <div class="kt-portlet__body">
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="tab-content">
                                {foreach from=$languages key=code item=item}
                                    {if !empty($code)}
                                        <div class="tab-pane {if !empty($code) && !empty($lang) && $code == $lang}active{/if}" id="kt_tab_setting_ecommerce_{$code}" role="tabpanel">
                                            <div class="row">
                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Shopee
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fas fa-cart-plus"></i>
                                                                    <span>&ensp;shopee.vn/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_shopee" value="{if !empty($website_info[$code].shopee)}{$website_info[$code].shopee}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Lazada
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fas fa-cart-plus"></i>
                                                                    <span>&ensp;lazada.vn/shop/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_lazada" value="{if !empty($website_info[$code].lazada)}{$website_info[$code].lazada}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Tiki
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fas fa-cart-plus"></i>
                                                                    <span>&ensp;tiki.vn/cua-hang/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_tiki" value="{if !empty($website_info[$code].tiki)}{$website_info[$code].tiki}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-6">
                                                    <div class="form-group row">
                                                        <label class="col-lg-10">
                                                            Sendo
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text" style="width: auto;">
                                                                    <i class="fas fa-cart-plus"></i>
                                                                    <span>&ensp;sendo.vn/shop/</span>
                                                                </span>
                                                            </div>
                                                            <input name="{$code}_sendo" value="{if !empty($website_info[$code].sendo)}{$website_info[$code].sendo}{/if}" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    {/if}
                                {/foreach}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--end::Form-->
        </div>

        <div class="kt-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        {__d('admin', 'chi_nhanh')}
                    </h3>
                </div>

                {if !empty($languages)}
                    <div class="kt-portlet__head-toolbar">
                        <ul class="nav nav-tabs border-0" role="tablist">
                            {foreach from=$languages key=code item=item}
                                {if !empty($item)}
                                    <li class="nav-item">
                                        <a id="add-item" class="btn btn-sm btn-default {if !empty($code) && !empty($lang) && $code == $lang}active{/if} list-flags {if !$item@last}mr-10{/if}" data-toggle="tab" href="#kt_tab_sub_branch_{$code}" role="tab" aria-selected="false">
                                            <img src="{ADMIN_PATH}{FLAGS_URL}{$code}.svg" alt="{$item}" class="flag mr-5">
                                            {$item}
                                        </a>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>

            <div class="kt-form">
                <div class="kt-portlet__body">
                    <div class="tab-content">
                        {foreach from=$languages key=code item=item}
                            {if !empty($code)}
                                <div class="tab-pane {if !empty($code) && !empty($lang) && $code == $lang}active{/if}" id="kt_tab_sub_branch_{$code}" role="tabpanel">
                                    <div class="kt_repeater">
                                        <div class="row" data-repeater-list="sub_branch[{$code}]">
                                            {if !empty($sub_branch) && !empty($sub_branch[$code])}
                                                {foreach from = $sub_branch[$code] key = key item = item}
                                                    <div class="col-lg-6 pb-20" data-repeater-item>
                                                        <div class="form-group row">
                                                            <label class="col-lg-12">
                                                                {__d('admin', 'ten_co_so')}
                                                            </label>
                                                            <div class="input-group col-lg-10">
                                                                <div class="input-group-prepend">
                                                                    <span class="input-group-text">
                                                                        <i class="fa fa-store"></i>
                                                                    </span>
                                                                </div>
                                                                <input name="sub_name" value="{if !empty($item.sub_name)}{$item.sub_name}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-lg-12">
                                                                {__d('admin', 'so_dien_thoai')}
                                                            </label>
                                                            <div class="input-group col-lg-10">
                                                                <div class="input-group-prepend">
                                                                    <span class="input-group-text">
                                                                        <i class="fa fa-phone"></i>
                                                                    </span>
                                                                </div>
                                                                <input name="sub_phone" value="{if !empty($item.sub_phone)}{$item.sub_phone}{/if}" type="text" class="form-control form-control-sm phone-input">
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-lg-12">
                                                                {__d('admin', 'email')}
                                                            </label>
                                                            <div class="input-group col-lg-10">
                                                                <div class="input-group-prepend">
                                                                    <span class="input-group-text">
                                                                        <i class="fa fa-envelope"></i>
                                                                    </span>
                                                                </div>
                                                                <input name="sub_email" value="{if !empty($item.sub_email)}{$item.sub_email}{/if}" type="text" class="form-control form-control-sm">
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-lg-12">
                                                                {__d('admin', 'dia_chi')}
                                                            </label>
                                                            <div class="input-group col-lg-10">
                                                                <div class="input-group-prepend">
                                                                    <span class="input-group-text">
                                                                        <i class="fa fa-map"></i>
                                                                    </span>
                                                                </div>
                                                                <input name="sub_address" value="{if !empty($item.sub_address)}{$item.sub_address}{/if}" type="text" class="form-control form-control-sm" maxlength="255">
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-lg-12">
                                                                Bản đồ
                                                            </label>
                                                            <div class="input-group col-lg-10">
                                                                <div class="input-group-prepend">
                                                                    <span class="input-group-text">
                                                                        <i class="fa fa-map"></i>
                                                                    </span>
                                                                </div>
                                                                <input name="sub_map" value='{if !empty($item.sub_map)}{$item.sub_map}{/if}' type="text" class="form-control form-control-sm">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label></label>
                                                            <div class="text-left">
                                                                <a href="javascript:;" data-repeater-delete="" class="btn-sm btn btn-label-danger btn-bold">
                                                                    <i class="la la-trash-o"></i>
                                                                    {__d('admin', 'xoa')}
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                {/foreach}
                                            {else}
                                                <div class="col-lg-6 pb-20" data-repeater-item>
                                                    <div class="form-group row">
                                                        <label class="col-lg-12">
                                                            {__d('admin', 'ten_co_so')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-store"></i>
                                                                </span>
                                                            </div>
                                                            <input name="sub_name" value="" type="text" class="form-control form-control-sm" maxlength="255">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row">
                                                        <label class="col-lg-12">
                                                            {__d('admin', 'so_dien_thoai')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-phone"></i>
                                                                </span>
                                                            </div>
                                                            <input name="sub_phone" value="" type="text" class="form-control form-control-sm phone-input">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row">
                                                        <label class="col-lg-12">
                                                            {__d('admin', 'email')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-envelope"></i>
                                                                </span>
                                                            </div>
                                                            <input name="sub_email" value="" type="text" class="form-control form-control-sm">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row">
                                                        <label class="col-lg-12">
                                                            {__d('admin', 'dia_chi')}
                                                        </label>
                                                        <div class="input-group col-lg-10">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text">
                                                                    <i class="fa fa-map"></i>
                                                                </span>
                                                            </div>
                                                            <input name="sub_address" value="" type="text" class="form-control form-control-sm" maxlength="255">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label></label>
                                                        <div class="text-left">
                                                            <a href="javascript:;" data-repeater-delete="" class="btn-sm btn btn-label-danger btn-bold">
                                                                <i class="la la-trash-o"></i>
                                                                {__d('admin', 'xoa')}
                                                            </a>
                                                        </div>
                                                    </div>
                                                </div>

                                            {/if}
                                        </div>

                                        <div class="form-group form-group-last">
                                            <a href="javascript:;" data-repeater-create class="btn btn-sm btn-brand">
                                                <i class="la la-plus"></i>{__d('admin', 'them_moi_chi_nhanh')}
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            {/if}
                        {/foreach}
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>