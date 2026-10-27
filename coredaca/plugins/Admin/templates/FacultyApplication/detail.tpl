<div class="kt-subheader kt-grid__item"><div class="kt-container kt-container--fluid"><div class="kt-subheader__main"><h3 class="kt-subheader__title">Hồ sơ ứng tuyển #{$row.id}</h3></div><div class="kt-subheader__toolbar"><a href="{ADMIN_PATH}/faculty-applications" class="btn btn-outline-brand">← Danh sách hồ sơ</a></div></div></div>
<div class="kt-container kt-container--fluid kt-grid__item kt-grid__item--fluid">
    {if $saved}<div class="alert alert-success" role="status">Đã lưu trạng thái và ghi chú hồ sơ.</div>{/if}
    <div class="row">
        <div class="col-lg-8"><div class="kt-portlet">
            <div class="kt-portlet__head"><div class="kt-portlet__head-label"><h3 class="kt-portlet__head-title">{$row.full_name|escape}</h3></div><div class="kt-portlet__head-toolbar"><span class="badge badge-info">{$labels[$row.status]|default:$row.status|escape}</span></div></div>
            <div class="kt-portlet__body">
                <dl class="row">
                    <dt class="col-sm-3">Email</dt><dd class="col-sm-9"><a href="mailto:{$row.email|escape}">{$row.email|escape}</a></dd>
                    <dt class="col-sm-3">Điện thoại</dt><dd class="col-sm-9">{$row.phone|escape}</dd>
                    <dt class="col-sm-3">Chuyên môn</dt><dd class="col-sm-9">{$row.specialty|escape}</dd>
                    <dt class="col-sm-3">Trình độ</dt><dd class="col-sm-9">{$row.qualification|escape}</dd>
                    <dt class="col-sm-3">Nơi công tác</dt><dd class="col-sm-9">{$row.workplace|default:'Chưa cung cấp'|escape}</dd>
                    <dt class="col-sm-3">Kinh nghiệm</dt><dd class="col-sm-9">{if $row.experience_years!==null}{$row.experience_years} năm{else}Chưa cung cấp{/if}</dd>
                    <dt class="col-sm-3">Ngày gửi</dt><dd class="col-sm-9">{$row.created|date_format:'%d/%m/%Y %H:%M'}</dd>
                    {if $row.portfolio_url}<dt class="col-sm-3">Liên kết hồ sơ</dt><dd class="col-sm-9" style="overflow-wrap:anywhere"><a href="{$row.portfolio_url|escape}" target="_blank" rel="noopener noreferrer">{$row.portfolio_url|escape}</a></dd>{/if}
                </dl>
                <h4 class="mt-4">Giới thiệu &amp; kinh nghiệm</h4><div class="border rounded p-4" style="white-space:pre-wrap;overflow-wrap:anywhere">{$row.introduction|escape}</div>
                <h4 class="mt-4">File đính kèm <small class="text-muted">({count($row.files)}/5)</small></h4>
                {foreach from=$row.files key=number item=file}<a href="{ADMIN_PATH}/faculty-applications/download/{$row.id}/{$number}" class="d-flex justify-content-between border rounded p-3 mb-2" style="gap:16px;overflow-wrap:anywhere"><span><i class="fas fa-paperclip mr-2"></i>{$file.original_name|escape}</span><span class="text-nowrap">{$file.size/1024|number_format:0} KB · Tải về ↓</span></a>{foreachelse}<p class="text-muted">Ứng viên không đính kèm file.</p>{/foreach}
            </div>
        </div></div>
        <div class="col-lg-4">
            <div class="kt-portlet"><div class="kt-portlet__head"><div class="kt-portlet__head-label"><h3 class="kt-portlet__head-title">Xử lý hồ sơ</h3></div></div><div class="kt-portlet__body">
                <form method="post" action="{ADMIN_PATH}/faculty-applications/review/{$row.id}">
                    <input type="hidden" name="_csrfToken" value="{$this->getRequest()->getAttribute('csrfToken')|escape}">
                    <div class="form-group"><label for="fa-review-status">Trạng thái</label><select id="fa-review-status" name="status" class="form-control">{foreach from=$labels key=key item=label}<option value="{$key}" {if $row.status==$key}selected{/if}>{$label}</option>{/foreach}</select></div>
                    <div class="form-group"><label for="fa-note">Ghi chú nội bộ</label><textarea id="fa-note" name="admin_note" class="form-control" rows="6" maxlength="5000" placeholder="Kết quả xem xét, lịch hẹn hoặc việc cần theo dõi">{$row.admin_note|escape}</textarea></div>
                    <button type="submit" class="btn btn-brand btn-block">Lưu xử lý</button>
                    {if $row.reviewed_at}<p class="small text-muted mt-3 mb-0">Cập nhật gần nhất: {$row.reviewed_at|date_format:'%d/%m/%Y %H:%M'}</p>{/if}
                </form>
            </div></div>
            <div class="kt-portlet"><div class="kt-portlet__body">
                <h4>Thông báo email</h4>
                <p class="{if $row.notification_status=='sent'}text-success{else}text-warning{/if}">{if $row.notification_status=='sent'}Đã gửi thông báo tới email quản trị.{elseif $row.notification_status=='failed'}Chưa gửi được email. Hồ sơ vẫn được lưu đầy đủ.{else}Thông báo đang được xử lý.{/if}</p>
                {if $row.notified_at}<p class="small text-muted">{$row.notified_at|date_format:'%d/%m/%Y %H:%M'}</p>{/if}
                {if $row.notification_status!='sent'}<form method="post" action="{ADMIN_PATH}/faculty-applications/notify/{$row.id}"><input type="hidden" name="_csrfToken" value="{$this->getRequest()->getAttribute('csrfToken')|escape}"><button type="submit" class="btn btn-outline-brand">Gửi lại thông báo</button></form>{/if}
            </div></div>
        </div>
    </div>
</div>
