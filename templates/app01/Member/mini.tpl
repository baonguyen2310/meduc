{assign member_info value = $this->Member->getMemberInfo()}
<div class="dropdown show">
    {if !empty(DEVICE)}
	    <a class="btn-action-header" title="{__d('template', 'tai_khoan')}" href="javascript:;" role="button" id="member-info" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            <i class="iconsax isax-user"></i>
        </a>
    {else}
        <a class="btn btn-primary py-5 px-10 fs-15" title="{$member_info.full_name}" href="javascript:;" role="button" id="member-info" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            <i class="iconsax isax-user"></i>
            {*$member_info.full_name|truncate:15:'...':true:true*}
        </a>
	{/if}

    <div class="dropdown-menu dropdown-menu-right" aria-labelledby="member-info">
        <div class="dropdown-item border-bottom p-10">
            <i class="iconsax isax-lg isax-tag-user mr-5"></i>
            Mã học viên: {$member_info.code}
        </div>
        <a class="dropdown-item border-bottom p-10" href="/member/dashboard">
            <i class="iconsax isax-lg isax-tag-user mr-5"></i>
            Thông tin học viên
        </a>
        
        <a class="dropdown-item border-bottom p-10" href="/khoa-hoc-da-dang-ky">
            <i class="iconsax isax-lg isax-video-square mr-5"></i>
            Khóa học đang tham gia
        </a>
        
        <a class="dropdown-item border-bottom p-10" href="/cac-khoa-hoc-nen-mua">
            <i class="iconsax isax-lg isax-video-square mr-5"></i>
            Các khoá học nên mua
        </a>
        
        <a class="dropdown-item border-bottom p-10" href="/lich-su-lam-bai-tap">
            <i class="iconsax isax-lg isax-archive-book mr-5"></i>
            Lịch sử làm bài tập
        </a>
        
        <a class="dropdown-item border-bottom p-10" href="/member/aff/dashboard">
            <i class="iconsax isax-lg isax-note-2 mr-5"></i>
            Tiếp thị liên kết
        </a>
        
        {*<a class="dropdown-item border-bottom p-10" href="/member/order">
            <i class="iconsax isax-lg isax-clipboard-text mr-5"></i>
            {__d('template', 'quan_ly_don_hang')}
        </a>*}
        
        <a class="dropdown-item border-bottom p-10" href="/member/change-password">
            <i class="iconsax isax-lg isax-lock mr-5"></i>
            {__d('template', 'thay_doi_mat_khau')}
        </a>

        <a class="dropdown-item p-10" href="/member/logout" btn-logout>
            <i class="iconsax isax-lg isax-logout mr-5"></i>
            {__d('template', 'thoat')}
        </a>
    </div>
</div>