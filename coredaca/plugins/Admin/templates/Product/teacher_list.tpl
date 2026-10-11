<div class="kt-subheader kt-grid__item" id="kt_subheader">
    <div class="kt-container kt-container--fluid">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">Khóa học của tôi</h3>
        </div>
    </div>
</div>

<div class="kt-container kt-container--fluid kt-grid__item kt-grid__item--fluid">
    <div class="kt-portlet">
        <div class="kt-portlet__head">
            <div class="kt-portlet__head-label">
                <h3 class="kt-portlet__head-title">Danh sách khóa học được phân công</h3>
            </div>
        </div>
        <div class="kt-portlet__body">
            {if empty($assigned_courses)}
                <p class="mb-0">Bạn chưa được phân công khóa học nào.</p>
            {else}
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead><tr><th>Khóa học</th><th>Trạng thái</th><th></th></tr></thead>
                        <tbody>
                            {foreach from=$assigned_courses item=course}
                                <tr>
                                    <td>{$course.name|escape}</td>
                                    <td>{if $course.status == 1}Đang mở{else}Đã tắt{/if}</td>
                                    <td class="text-right"><a href="{ADMIN_PATH}/product/detail/{$course.id}">Xem chi tiết</a></td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>
            {/if}
        </div>
    </div>
</div>
