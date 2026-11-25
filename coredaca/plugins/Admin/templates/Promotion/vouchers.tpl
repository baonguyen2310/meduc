<div class="kt-subheader kt-grid__item">
    <div class="kt-container kt-container--fluid">
        <h3 class="kt-subheader__title">Mã ưu đãi MedUC</h3>
        <a class="btn btn-outline-brand" href="{ADMIN_PATH}/promotion">Chương trình khuyến mãi</a>
    </div>
</div>
<div class="kt-container kt-container--fluid">
    {if $saved}<p class="alert alert-success" role="status">Đã lưu chương trình ưu đãi.</p>{/if}
    {if !$ready}
        <p class="alert alert-warning">Chưa cài đặt bảng dữ liệu ưu đãi.</p>
    {else}
        <section class="kt-portlet">
            <div class="kt-portlet__body">
                <h4>{if !empty($row.id)}Chỉnh sửa chương trình{else}Tạo chương trình{/if}</h4>
                {if $error}<p class="alert alert-danger" role="alert">{$error|escape}</p>{/if}
                <form id="meduc-voucher-campaign" action="{ADMIN_PATH}/promotion/vouchers" method="post">
                    <input type="hidden" name="_csrfToken" value="{$this->getRequest()->getAttribute('csrfToken')|escape}">
                    <input type="hidden" name="id" value="{$row.id|default:0|escape}">
                    <div class="form-row">
                        <label class="form-group col-lg-4">Tên chương trình<input class="form-control" name="name" maxlength="160" value="{$row.name|default:''|escape}" required></label>
                        <label class="form-group col-lg-4">Loại mã
                            {if !empty($row.id)}<input type="hidden" name="kind" value="{$row.kind|escape}">{/if}
                            <select class="form-control" name="kind" {if !empty($row.id)}disabled{/if}>{foreach $kinds as $key => $label}<option value="{$key|escape}" {if $key==$row.kind}selected{/if}>{$label|escape}</option>{/foreach}</select>
                        </label>
                        <label class="form-group col-lg-4">Áp dụng cho
                            <select class="form-control" name="scope">{foreach $scopes as $key => $label}<option value="{$key|escape}" {if $key==$row.scope}selected{/if}>{$label|escape}</option>{/foreach}</select>
                        </label>
                    </div>
                    <div class="form-row">
                        <label class="form-group col-md-3">Hình thức giảm<select class="form-control" name="discount_type"><option value="fixed">Số tiền (đ)</option><option value="percent" {if $row.discount_type=='percent'}selected{/if}>Phần trăm</option></select></label>
                        <label class="form-group col-md-3">Mức giảm<input class="form-control" name="discount_value" type="number" min="1" value="{$row.discount_value|default:''|escape}" required></label>
                        <label class="form-group col-md-3">Ngày bắt đầu dùng<input class="form-control" name="starts_at" type="date" value="{$row.starts_at|default:''|escape}" required></label>
                        <label class="form-group col-md-3">Ngày cuối dùng<input class="form-control" name="ends_at" type="date" value="{$row.ends_at|default:''|escape}"></label>
                    </div>
                    <div class="form-row">
                        <label class="form-group col-md-4">Mã áp dụng cho mã chung hoặc giới thiệu<input class="form-control" name="code" maxlength="32" value="{$row.code|default:''|escape}"></label>
                        <label class="form-group col-md-4">Mã đối tác giới thiệu<input class="form-control" name="partner_code" maxlength="64" value="{$row.partner_code|default:''|escape}"></label>
                        <label class="form-group col-md-4">Số phút cần tích lũy mỗi tuần<input class="form-control" name="study_minutes" type="number" min="1" max="10080" value="{$row.study_minutes|default:''|escape}"><small class="form-text text-muted">Mã chỉ dùng cho Khoá ôn kiến thức trong tuần nhận mã.</small></label>
                    </div>
                    <fieldset class="border rounded p-3 mb-3">
                        <legend class="w-auto h6 px-2">Điều kiện khách hàng thân thiết</legend>
                        <p class="text-muted">Hệ thống cộng số tiền thực trả theo ngày xác nhận đơn. Với đơn cũ thiếu ngày xác nhận, hệ thống dùng ngày giao dịch hoặc ngày đặt đơn đã lưu.</p>
                        <div class="form-row">
                            <label class="form-group col-md-4">Ngưỡng chi tiêu (đ)<input class="form-control" name="required_spend" type="number" min="1" value="{$row.required_spend|default:''|escape}"></label>
                            <label class="form-group col-md-4">Tích lũy từ ngày<input class="form-control" name="spend_from" type="date" value="{$row.spend_from|default:''|escape}"></label>
                            <label class="form-group col-md-4">Tích lũy đến hết ngày<input class="form-control" name="spend_until" type="date" value="{$row.spend_until|default:''|escape}"></label>
                        </div>
                    </fieldset>
                    <label class="d-block mb-3"><input type="checkbox" name="active" value="1" {if !empty($row.active)}checked{/if}> Bật chương trình</label>
                    <button class="btn btn-brand" type="submit">Lưu chương trình</button>
                    {if !empty($row.id)}<a href="{ADMIN_PATH}/promotion/vouchers" class="btn btn-link">Tạo mã mới</a>{/if}
                </form>
                {literal}<script>
                    (() => {
                        const form = document.getElementById('meduc-voucher-campaign');
                        const kind = form.querySelector('select[name="kind"]');
                        const scope = form.elements.scope;
                        function updateScope() {
                            const study = kind.value === 'study';
                            if (study) scope.value = 'knowledge';
                            for (const option of scope.options) option.disabled = study && option.value !== 'knowledge';
                        }
                        kind.addEventListener('change', updateScope);
                        updateScope();
                    })();
                </script>{/literal}
            </div>
        </section>
        <section class="kt-portlet">
            <div class="kt-portlet__body table-responsive">
                <table class="table">
                    <thead><tr><th>Chương trình</th><th>Loại</th><th>Phạm vi</th><th>Ngày dùng</th><th>Trạng thái</th><th></th></tr></thead>
                    <tbody>
                        {foreach $campaigns as $campaign}
                            <tr>
                                <td>{$campaign.name|escape}{if $campaign.code}<div>{$campaign.code|escape}</div>{/if}
                                    {if $campaign.kind=='referral' && $campaign.partner_code}<a href="/?a={$campaign.partner_code|escape:'url'}" target="_blank" rel="noopener">Mở link giới thiệu</a>{/if}
                                </td>
                                <td>{$kinds[$campaign.kind]|escape}</td>
                                <td>{$scopes[$campaign.scope]|escape}</td>
                                <td>{$campaign.starts_at|escape}{if $campaign.ends_at} – {$campaign.ends_at|escape}{/if}</td>
                                <td>{if $campaign.active}Đã bật{else}Đã tắt{/if}</td>
                                <td><a href="{ADMIN_PATH}/promotion/vouchers?edit={$campaign.id}">Sửa</a></td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </section>
    {/if}
</div>
