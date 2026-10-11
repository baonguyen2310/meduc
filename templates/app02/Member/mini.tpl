{assign member_info value = $this->Member->getMemberInfo()}
<div class="dropdown show">
    <a class="btn-action-header" href="javascript:;" role="button" id="member-info" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        {$member_info.username|truncate:10:'..':true:true}
    </a>
    <div class="dropdown-menu dropdown-menu-right" aria-labelledby="member-info">
        <a class="dropdown-item border-bottom p-10" href="/member/dashboard">
            <i class="iconsax isax-lg isax-tag-user mr-5"></i>
            {__d('template', 'thong_tin_ca_nhan')}
        </a>
        
        <a class="dropdown-item border-bottom p-10" href="/member/order">
            <i class="iconsax isax-lg isax-clipboard-text mr-5"></i>
            {__d('template', 'quan_ly_don_hang')}
        </a>
        
        <a class="dropdown-item border-bottom p-10" href="/member/change-password">
            <i class="iconsax isax-lg isax-lock mr-5"></i>
            {__d('template', 'thay_doi_mat_khau')}
        </a>

        <a class="dropdown-item p-10" href="/member/logout">
            <i class="iconsax isax-lg isax-logout mr-5"></i>
            {__d('template', 'thoat')}
        </a>
    </div>
</div>