{assign var=type_labels value=['answer'=>'Góp ý đáp án','exam'=>'Đóng góp đề ảnh','curriculum'=>'Góp ý lộ trình','general'=>'Góp ý khác']}
{assign var=status_labels value=['new'=>'Mới','reviewing'=>'Đang xem','accepted'=>'Đã tiếp nhận','rejected'=>'Không áp dụng']}
<div class="kt-subheader kt-grid__item" id="kt_subheader">
    <div class="kt-container kt-container--fluid">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">Đóng góp của học viên</h3>
            <span class="kt-subheader__separator kt-subheader__separator--v"></span>
            <span class="kt-subheader__desc">{$total} đóng góp</span>
        </div>
    </div>
</div>
<div class="kt-container kt-container--fluid kt-grid__item kt-grid__item--fluid">
    <div class="kt-portlet">
        <div class="kt-portlet__body">
            <form method="get" action="{ADMIN_PATH}/course-contributions" class="row align-items-end">
                <div class="col-md-3 mb-3"><label for="cc-status">Trạng thái</label><select id="cc-status" name="status" class="form-control">
                    <option value="all" {if $status=='all'}selected{/if}>Tất cả</option>
                    {foreach from=$status_labels key=key item=label}<option value="{$key}" {if $status==$key}selected{/if}>{$label}</option>{/foreach}
                </select></div>
                <div class="col-md-3 mb-3"><label for="cc-type">Loại góp ý</label><select id="cc-type" name="type" class="form-control">
                    <option value="all" {if $type=='all'}selected{/if}>Tất cả</option>
                    {foreach from=$type_labels key=key item=label}<option value="{$key}" {if $type==$key}selected{/if}>{$label}</option>{/foreach}
                </select></div>
                <div class="col-md-2 mb-3"><button class="btn btn-brand" type="submit">Lọc đóng góp</button></div>
            </form>
        </div>
    </div>
    {if empty($rows)}
        <div class="kt-portlet"><div class="kt-portlet__body"><p class="mb-0">Chưa có đóng góp trong bộ lọc này.</p></div></div>
    {/if}
    {foreach from=$rows item=row}
        <article class="kt-portlet" id="contribution-{$row.id}">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label"><h3 class="kt-portlet__head-title">#{$row.id} · {$type_labels[$row.type]|default:$row.type|escape}</h3></div>
                <div class="kt-portlet__head-toolbar"><span class="badge badge-info">{$status_labels[$row.status]|default:$row.status|escape}</span></div>
            </div>
            <div class="kt-portlet__body">
                <p><strong>{$row.full_name|default:'Học viên'|escape}</strong> · {$row.customer_code|escape} · {$row.email|escape} · {$row.created|date_format:'%d/%m/%Y %H:%M'}</p>
                <p>Khóa <a href="{ADMIN_PATH}/product/update/{$row.product_id}">#{$row.product_id}</a>{if $row.lesson_number} · Buổi {$row.lesson_number}{/if}{if $row.quiz_id} · Đề #{$row.quiz_id}{/if}{if $row.question_number} · Câu {$row.question_number}{/if}</p>
                {if $row.suggested_answer}<p><strong>Đáp án đề xuất:</strong> {$row.suggested_answer|escape}</p>{/if}
                <div class="border rounded p-3 mb-3" style="white-space:pre-wrap;overflow-wrap:anywhere">{$row.content|escape}</div>
                {if !empty($row.files)}
                    <div class="d-flex flex-wrap mb-3" style="gap:12px">
                        {foreach from=$row.files item=file key=number}
                            <a href="{ADMIN_PATH}/course-contributions/photo/{$row.id}/{$number}" target="_blank" rel="noopener noreferrer" aria-label="Mở ảnh đề {$number+1}">
                                <img src="{ADMIN_PATH}/course-contributions/photo/{$row.id}/{$number}" alt="Ảnh đề {$number+1}" loading="lazy" style="width:160px;height:120px;object-fit:cover;border-radius:8px;border:1px solid #ddd">
                            </a>
                        {/foreach}
                    </div>
                {/if}
                <form method="post" action="{ADMIN_PATH}/course-contributions/review/{$row.id}" class="row align-items-end">
                    <input type="hidden" name="_csrfToken" value="{$this->getRequest()->getAttribute('csrfToken')|escape}">
                    <div class="col-md-3 mb-2"><label for="status-{$row.id}">Xử lý</label><select id="status-{$row.id}" name="status" class="form-control">
                        {foreach from=$status_labels key=key item=label}<option value="{$key}" {if $row.status==$key}selected{/if}>{$label}</option>{/foreach}
                    </select></div>
                    <div class="col-md-7 mb-2"><label for="note-{$row.id}">Ghi chú nội bộ</label><input id="note-{$row.id}" name="admin_note" type="text" maxlength="5000" value="{$row.admin_note|escape}" class="form-control" placeholder="Lý do hoặc việc cần làm"></div>
                    <div class="col-md-2 mb-2"><button type="submit" class="btn btn-brand">Lưu xử lý</button></div>
                </form>
            </div>
        </article>
    {/foreach}
    {if $pages > 1}<nav aria-label="Trang đóng góp" class="mb-4">
        {if $page > 1}<a class="btn btn-outline-secondary" href="{ADMIN_PATH}/course-contributions?status={$status}&amp;type={$type}&amp;page={$page-1}">← Trang trước</a>{/if}
        <span class="mx-3">Trang {$page}/{$pages}</span>
        {if $page < $pages}<a class="btn btn-outline-secondary" href="{ADMIN_PATH}/course-contributions?status={$status}&amp;type={$type}&amp;page={$page+1}">Trang sau →</a>{/if}
    </nav>{/if}
</div>
