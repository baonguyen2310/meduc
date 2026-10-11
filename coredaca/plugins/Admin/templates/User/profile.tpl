{assign var = url_list value = "{ADMIN_PATH}/user"}
{assign var = url_edit value = "{ADMIN_PATH}/user/profile"}

{$this->element('Admin.page/content_head')}

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <div id="wrap-profile" class="kt-portlet kt-portlet--tabs">
        <div class="kt-portlet__head">
            <div class="kt-portlet__head-toolbar">
                <ul class="nav nav-tabs nav-tabs-space-xl nav-tabs-line nav-tabs-bold nav-tabs-line-3x nav-tabs-line-brand" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active" data-toggle="tab" href="#info-user" role="tab">
                            <i class="fa fa-user-alt"></i> {__d('admin', 'thong_tin_tai_khoan')}
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-toggle="tab" href="#change-password" role="tab">
                            <i class="fa fa-user-lock"></i> {__d('admin', 'thay_doi_mat_khau')}
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-toggle="tab" href="#setting-user" role="tab">
                            <i class="fa fa-user-cog"></i> {__d('admin', 'thiet_lap')}
                        </a>
                    </li>
                </ul>
            </div>
        </div>
        <div class="kt-portlet__body">
            <div class="tab-content">
                <div class="tab-pane active" id="info-user" role="tabpanel">
                    <form id="profile-form" action="{ADMIN_PATH}/user/profile-save" method="POST" autocomplete="off">
                        {$this->element('../User/profile_form')}
                    </form>
                </div>
                <div class="tab-pane" id="change-password" role="tabpanel">
                    <form id="change-password-form" action="{ADMIN_PATH}/user/profile-change-pass" method="POST" autocomplete="off">
                        {$this->element('../User/profile_change_password_form')}
                    </form>
                </div>
                <div class="tab-pane" id="setting-user" role="tabpanel">
                    <div class="kt-form kt-form--label-right">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
