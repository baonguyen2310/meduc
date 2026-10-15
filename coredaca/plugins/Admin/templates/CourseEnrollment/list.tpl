{* Ghi danh khóa học: học viên mới được học khóa trên website (CourseEnrollmentController). Lọc bằng địa chỉ (?keyword=…),
   các nút Tạm khóa / Mở lại / Xóa dùng assets/js/pages/course_enrollment.js. *}
{assign var = url_list value = "{ADMIN_PATH}/course-enrollment"}
{assign var = source_labels value = ['order' => 'Đơn hàng', 'admin' => 'Admin thêm']}

<div class="kt-subheader kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {$title_for_layout}
            </h3>
            <span class="kt-subheader__separator kt-subheader__separator--v"></span>
            <span class="kt-subheader__desc">{$total|number_format:0:',':'.'} học viên</span>
        </div>
        <div class="kt-subheader__toolbar">
            <a href="{ADMIN_PATH}/course-enrollment/add{if !empty($filter.product_id)}?product_id={$filter.product_id}{/if}" class="btn btn-sm btn-brand">
                <i class="la la-plus"></i>
                Ghi danh học viên
            </a>
        </div>
    </div>
</div>

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <div class="kt-portlet nh-portlet">
        <div class="kt-portlet__body">
            <form class="kt-form" method="GET" action="{$url_list}">
                <div class="row align-items-center">
                    <div class="col-lg-3 col-md-6 mb-10">
                        <div class="kt-input-icon kt-input-icon--left">
                            <input name="keyword" value="{$filter.keyword|escape}" type="text" class="form-control form-control-sm" placeholder="Tên, mã học viên, điện thoại, email..." autocomplete="off">
                            <span class="kt-input-icon__icon kt-input-icon__icon--left">
                                <span><i class="la la-search"></i></span>
                            </span>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-10">
                        <select name="product_id" class="form-control form-control-sm">
                            <option value="">-- Mọi khóa học --</option>
                            {foreach from = $courses key = course_id item = course_name}
                                <option value="{$course_id}" {if $filter.product_id == $course_id}selected{/if}>{$course_name|escape}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-10">
                        <select name="status" class="form-control form-control-sm">
                            <option value="">-- Trạng thái --</option>
                            <option value="1" {if $filter.status === 1}selected{/if}>Đang học</option>
                            <option value="0" {if $filter.status === 0}selected{/if}>Tạm khóa</option>
                        </select>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-10">
                        <select name="source" class="form-control form-control-sm">
                            <option value="">-- Nguồn --</option>
                            {foreach from = $source_labels key = source_code item = source_label}
                                <option value="{$source_code}" {if $filter.source == $source_code}selected{/if}>{$source_label}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-10">
                        <button type="submit" class="btn btn-sm btn-brand">
                            <i class="la la-filter"></i>
                            Lọc
                        </button>
                        {if $filter.keyword != '' || $filter.product_id != '' || $filter.status !== '' || $filter.source != ''}
                            <a href="{$url_list}" class="btn btn-sm btn-secondary">Bỏ lọc</a>
                        {/if}
                    </div>
                </div>
            </form>
            <p class="kt-font-sm text-muted mb-0 mt-5">
                Học viên mua khóa và thanh toán đủ được ghi danh tự động. Học viên cũ vẫn học qua mục Lớp học, không cần ghi danh lại.
            </p>
        </div>

        <div class="kt-portlet__body kt-portlet__body--fit">
            {if empty($enrollments)}
                <div class="text-center text-muted p-40">
                    {if $total == 0 && $filter.keyword == '' && $filter.product_id == '' && $filter.status === '' && $filter.source == ''}
                        Chưa có học viên nào được ghi danh.
                    {else}
                        Không có ghi danh nào khớp bộ lọc.
                    {/if}
                </div>
            {else}
                <div class="table-responsive">
                    <table class="table table-hover mb-0 nh-course-enrollments">
                        <thead class="thead-light">
                            <tr>
                                <th>Học viên</th>
                                <th>Khóa học</th>
                                <th>Nguồn</th>
                                <th class="text-nowrap">Hạn học</th>
                                <th class="text-nowrap">Trạng thái</th>
                                <th>Ghi danh</th>
                                <th class="text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach from = $enrollments item = item}
                                {$expired = !empty($item.expires_at) && $item.expires_at <= $now}
                                <tr data-id="{$item.id}">
                                    <td>
                                        <a href="{ADMIN_PATH}/customer/detail/{$item.customer_id}" class="kt-font-bold" target="_blank">{if !empty($item.customer_name)}{$item.customer_name|escape}{else}Học viên #{$item.customer_id}{/if}</a>
                                        <div class="kt-font-sm text-muted">
                                            {if !empty($item.customer_code)}{$item.customer_code|escape}{/if}
                                            {if !empty($item.customer_phone)} · {$item.customer_phone|escape}{/if}
                                            {if !empty($item.customer_email)} · {$item.customer_email|escape}{/if}
                                        </div>
                                    </td>
                                    <td>{if !empty($item.course_name)}{$item.course_name|escape}{else}Khóa học #{$item.product_id}{/if}</td>
                                    <td>
                                        {if $item.source == 'order'}
                                            Đơn hàng
                                            {if !empty($item.order_id)}<a href="{ADMIN_PATH}/order/detail/{$item.order_id}" target="_blank">{if !empty($item.order_code)}{$item.order_code|escape}{else}#{$item.order_id}{/if}</a>{/if}
                                        {else}
                                            Admin{if !empty($item.created_by_name)} · {$item.created_by_name|escape}{/if}
                                        {/if}
                                    </td>
                                    <td>{if !empty($item.expires_at)}{date('d/m/Y', $item.expires_at)}{else}<span class="text-muted">Không thời hạn</span>{/if}</td>
                                    <td class="text-nowrap">
                                        {if $item.status != 1}
                                            <span class="kt-badge kt-badge--warning kt-badge--inline kt-badge--pill">Tạm khóa</span>
                                        {elseif $expired}
                                            <span class="kt-badge kt-badge--danger kt-badge--inline kt-badge--pill">Hết hạn</span>
                                        {else}
                                            <span class="kt-badge kt-badge--success kt-badge--inline kt-badge--pill">Đang học</span>
                                        {/if}
                                        {if !empty($item.note)}<div class="kt-font-sm text-muted mt-5 text-wrap" style="min-width: 160px">{$item.note|escape|truncate:80}</div>{/if}
                                    </td>
                                    <td class="text-nowrap">{if !empty($item.created)}{date('d/m/Y', $item.created)}{/if}</td>
                                    <td class="text-right text-nowrap">
                                        <a href="{ADMIN_PATH}/course-enrollment/update/{$item.id}" class="btn btn-sm btn-clean btn-icon btn-icon-md" title="Sửa">
                                            <i class="la la-edit"></i>
                                        </a>
                                        {if $item.status == 1}
                                            <button type="button" class="btn btn-sm btn-clean btn-icon btn-icon-md" data-enrollment-status="0" title="Tạm khóa">
                                                <i class="la la-lock"></i>
                                            </button>
                                        {else}
                                            <button type="button" class="btn btn-sm btn-clean btn-icon btn-icon-md" data-enrollment-status="1" title="Mở lại">
                                                <i class="la la-unlock"></i>
                                            </button>
                                        {/if}
                                        <button type="button" class="btn btn-sm btn-clean btn-icon btn-icon-md" data-enrollment-delete title="Xóa">
                                            <i class="la la-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>

                {if $pages > 1}
                    {$query = ['keyword' => $filter.keyword, 'product_id' => $filter.product_id, 'status' => $filter.status, 'source' => $filter.source]}
                    <div class="kt-pagination kt-pagination--brand p-20">
                        <ul class="kt-pagination__links">
                            {for $number = 1 to $pages}
                                {if $number == 1 || $number == $pages || ($number >= $page - 2 && $number <= $page + 2)}
                                    <li class="{if $number == $page}kt-pagination__link--active{/if}">
                                        <a href="{$url_list}?{http_build_query(array_merge($query, ['page' => $number]))}">{$number}</a>
                                    </li>
                                {elseif $number == $page - 3 || $number == $page + 3}
                                    <li><span class="p-10">…</span></li>
                                {/if}
                            {/for}
                        </ul>
                        <div class="kt-pagination__toolbar">
                            <span class="pagination__desc">Trang {$page}/{$pages}</span>
                        </div>
                    </div>
                {/if}
            {/if}
        </div>
    </div>
</div>
