{* Thêm hoặc sửa một ghi danh (CourseEnrollmentController::add / update). Thêm mới: chọn học viên (tìm theo tên, mã,
   điện thoại, email) và khóa học. Sửa: học viên và khóa học giữ nguyên; đổi hạn học, trạng thái, ghi chú.
   Lưu bằng assets/js/pages/course_enrollment.js. *}
{assign var = url_list value = "{ADMIN_PATH}/course-enrollment"}

<div class="kt-subheader kt-grid__item" id="kt_subheader">
    <div class="kt-container  kt-container--fluid ">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">
                {$title_for_layout}
            </h3>
        </div>

        <div class="kt-subheader__toolbar">
            <a href="{$url_list}" class="btn btn-sm btn-secondary">
                {__d('admin', 'quay_lai_danh_sach')}
            </a>
            <button type="submit" form="enrollment-form" class="btn btn-sm btn-brand">
                <i class="la la-{if empty($id)}plus{else}edit{/if}"></i>
                {if empty($id)}Ghi danh{else}{__d('admin', 'cap_nhat')}{/if}
            </button>
        </div>
    </div>
</div>

<div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
    <form id="enrollment-form" class="kt-form" action="{ADMIN_PATH}/course-enrollment/save{if !empty($id)}/{$id}{/if}" method="POST" autocomplete="off" data-list="{$url_list}">
        <div class="kt-portlet nh-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Học viên và khóa học
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="row">
                    <div class="col-lg-6">
                        <div class="form-group">
                            <label>Học viên <span class="kt-font-danger">*</span></label>
                            {if !empty($id)}
                                <div class="form-control-plaintext">
                                    <strong>{if !empty($enrollment.customer_name)}{$enrollment.customer_name|escape}{else}Học viên #{$enrollment.customer_id}{/if}</strong>
                                    <span class="text-muted">
                                        {if !empty($enrollment.customer_code)} · {$enrollment.customer_code|escape}{/if}
                                        {if !empty($enrollment.customer_phone)} · {$enrollment.customer_phone|escape}{/if}
                                        {if !empty($enrollment.customer_email)} · {$enrollment.customer_email|escape}{/if}
                                    </span>
                                </div>
                            {else}
                                <div class="nh-customer-pick" data-enrollment-customer>
                                    <input type="hidden" name="customer_id" value="">
                                    <div class="kt-input-icon kt-input-icon--left">
                                        <input type="text" class="form-control" data-enrollment-customer-search placeholder="Gõ tên, mã học viên (MEDUC…), số điện thoại hoặc email" autocomplete="off">
                                        <span class="kt-input-icon__icon kt-input-icon__icon--left"><span><i class="la la-search"></i></span></span>
                                    </div>
                                    <div class="list-group mt-5" data-enrollment-customer-results hidden></div>
                                    <div class="alert alert-secondary mt-10 mb-0 py-10" data-enrollment-customer-chosen hidden>
                                        <span data-enrollment-customer-label></span>
                                        <button type="button" class="btn btn-sm btn-link ml-auto" data-enrollment-customer-clear>Chọn học viên khác</button>
                                    </div>
                                </div>
                                <span class="form-text text-muted">Học viên cần có tài khoản trên website để vào học.</span>
                            {/if}
                        </div>
                    </div>

                    <div class="col-lg-6">
                        <div class="form-group">
                            <label>Khóa học <span class="kt-font-danger">*</span></label>
                            {if !empty($id)}
                                <div class="form-control-plaintext">
                                    <strong>{if !empty($enrollment.course_name)}{$enrollment.course_name|escape}{else}Khóa học #{$enrollment.product_id}{/if}</strong>
                                </div>
                            {else}
                                <select name="product_id" class="form-control">
                                    <option value="">-- Chọn khóa học --</option>
                                    {foreach from = $courses key = course_id item = course_name}
                                        <option value="{$course_id}" {if $enrollment.product_id == $course_id}selected{/if}>{$course_name|escape}</option>
                                    {/foreach}
                                </select>
                            {/if}
                        </div>
                    </div>
                </div>

                {if !empty($id)}
                    <p class="text-muted mb-0">
                        Nguồn:
                        {if $enrollment.source == 'order'}
                            đơn hàng {if !empty($enrollment.order_id)}<a href="{ADMIN_PATH}/order/detail/{$enrollment.order_id}" target="_blank">{if !empty($enrollment.order_code)}{$enrollment.order_code|escape}{else}#{$enrollment.order_id}{/if}</a>{/if}
                            (đơn bị hủy hoặc không còn thanh toán đủ thì ghi danh tự tạm khóa).
                        {else}
                            admin thêm{if !empty($enrollment.created_by_name)} ({$enrollment.created_by_name|escape}){/if}.
                        {/if}
                        {if !empty($enrollment.created)}Ghi danh ngày {date('d/m/Y', $enrollment.created)}.{/if}
                    </p>
                {/if}
            </div>
        </div>

        <div class="kt-portlet nh-portlet">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Quyền học
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="row">
                    <div class="col-lg-3 col-md-6">
                        <div class="form-group">
                            <label>Trạng thái</label>
                            <select name="status" class="form-control">
                                <option value="1" {if !isset($enrollment.status) || $enrollment.status == 1}selected{/if}>Đang học</option>
                                <option value="0" {if isset($enrollment.status) && $enrollment.status == 0}selected{/if}>Tạm khóa</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <div class="form-group">
                            <label>Hạn học</label>
                            <input type="date" name="expires_at" class="form-control" value="{if !empty($enrollment.expires_at)}{date('Y-m-d', $enrollment.expires_at)}{/if}">
                            <span class="form-text text-muted">Để trống nếu không giới hạn.</span>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="form-group">
                            <label>Ghi chú</label>
                            <textarea name="note" class="form-control" rows="3" maxlength="500" placeholder="Ví dụ: chuyển khoản ngày 12/10, học bù khóa trước…">{if !empty($enrollment.note)}{$enrollment.note|escape}{/if}</textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>
