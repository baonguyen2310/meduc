<div class="kt-subheader kt-grid__item"><div class="kt-container kt-container--fluid"><div class="kt-subheader__main"><h3 class="kt-subheader__title">Ứng tuyển giảng viên</h3><span class="kt-subheader__separator kt-subheader__separator--v"></span><span class="kt-subheader__desc">{$total} hồ sơ</span></div></div></div>
<div class="kt-container kt-container--fluid kt-grid__item kt-grid__item--fluid">
    <div class="kt-portlet"><div class="kt-portlet__body">
        <form method="get" action="{ADMIN_PATH}/faculty-applications" class="row align-items-end">
            <div class="col-md-5 mb-3"><label for="fa-search">Tìm hồ sơ</label><input id="fa-search" type="search" name="q" value="{$search|escape}" maxlength="160" placeholder="Họ tên, email, điện thoại hoặc chuyên môn" class="form-control"></div>
            <div class="col-md-3 mb-3"><label for="fa-status">Trạng thái</label><select id="fa-status" name="status" class="form-control"><option value="all">Tất cả</option>{foreach from=$labels key=key item=label}<option value="{$key}" {if $status==$key}selected{/if}>{$label}</option>{/foreach}</select></div>
            <div class="col-md-3 mb-3"><button type="submit" class="btn btn-brand">Lọc hồ sơ</button></div>
        </form>
        <div class="table-responsive"><table class="table table-hover"><thead><tr><th>Ứng viên</th><th>Chuyên môn</th><th>Liên hệ</th><th>Hồ sơ</th><th>Trạng thái</th><th>Ngày gửi</th><th></th></tr></thead><tbody>
            {foreach from=$rows item=row}<tr>
                <td><strong>{$row.full_name|escape}</strong><div class="text-muted">#{$row.id} · {$row.qualification|escape}</div></td>
                <td>{$row.specialty|escape}<div class="text-muted">{$row.workplace|escape}</div></td>
                <td>{$row.email|escape}<div>{$row.phone|escape}</div></td>
                <td>{$row.file_count} file<div class="small {if $row.notification_status=='sent'}text-success{else}text-warning{/if}">{if $row.notification_status=='sent'}Đã gửi email{elseif $row.notification_status=='failed'}Gửi email chưa thành công{else}Đang gửi email{/if}</div></td>
                <td><span class="badge {if $row.status=='new'}badge-danger{elseif $row.status=='accepted'}badge-success{else}badge-secondary{/if}">{$labels[$row.status]|default:$row.status|escape}</span></td>
                <td>{$row.created|date_format:'%d/%m/%Y %H:%M'}</td>
                <td><a class="btn btn-sm btn-outline-brand" href="{ADMIN_PATH}/faculty-applications/detail/{$row.id}">Xem hồ sơ</a></td>
            </tr>{foreachelse}<tr><td colspan="7" class="text-center p-5 text-muted">Chưa có hồ sơ ứng tuyển trong bộ lọc này.</td></tr>{/foreach}
        </tbody></table></div>
        {if $pages>1}<nav aria-label="Trang hồ sơ" class="mt-3">
            {if $page>1}<a class="btn btn-outline-secondary" href="{ADMIN_PATH}/faculty-applications?{$query_string|escape}&amp;page={$page-1}">← Trang trước</a>{/if}
            <span class="mx-3">Trang {$page}/{$pages}</span>
            {if $page<$pages}<a class="btn btn-outline-secondary" href="{ADMIN_PATH}/faculty-applications?{$query_string|escape}&amp;page={$page+1}">Trang sau →</a>{/if}
        </nav>{/if}
    </div></div>
</div>
