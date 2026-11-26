<div class="kt-subheader kt-grid__item">
    <div class="kt-container kt-container--fluid">
        <div class="kt-subheader__main">
            <h3 class="kt-subheader__title">Đơn Shop trước đây</h3>
        </div>
        <div class="kt-subheader__toolbar">
            <a href="{ADMIN_PATH}/order" class="btn btn-sm btn-outline-brand">Danh sách đơn hàng</a>
        </div>
    </div>
</div>

<div class="kt-container kt-container--fluid kt-grid__item">
    <div class="kt-portlet">
        <div class="kt-portlet__body">
            {if !empty($history_detail)}
                <div class="pb-4 mb-4 border-bottom">
                    <h4>Đơn {$history_detail.cartId|default:'–'|escape}</h4>
                    <p>{$history_detail.full_name|default:''|escape} · {$history_detail.phone|default:''|escape}</p>
                    <p>{$history_detail.address|default:''|escape}</p>
                    {if !empty($history_detail.items)}
                        <ul class="mb-3">
                            {foreach $history_detail.items as $item}
                                <li>{$item.name|default:'Sản phẩm đã lưu'|escape} × {$item.quantity|default:0|intval}</li>
                            {/foreach}
                        </ul>
                    {/if}
                    <p>Trạng thái đã lưu · {$history_detail.archive_status|escape}</p>
                    {if $history_detail.linked_order_id}
                        <a class="btn btn-sm btn-brand mr-2" href="{ADMIN_PATH}/order/detail/{$history_detail.linked_order_id|intval}">Mở đơn đối soát</a>
                    {elseif $history_detail.archive_open}
                        <button type="button" class="btn btn-sm btn-brand mr-2" data-shop-history-import
                            data-link="{ADMIN_PATH}/order/import-shop-history/{$history_detail.id|intval}">Chuyển đơn để đối soát</button>
                        <p class="text-danger" role="alert" data-shop-history-error hidden></p>
                    {/if}
                    <a href="{$history_url|escape}&amp;page={$history_page|intval}">Đóng chi tiết</a>
                </div>
            {/if}
            <p class="text-muted mb-3">{$history_total|intval} đơn lưu trữ. Trạng thái hiển thị lấy từ đơn cũ. Việc thu tiền cần đối chiếu với chứng từ.</p>
            <form method="get" action="{ADMIN_PATH}/order" class="form-inline mb-4">
                <input type="hidden" name="view" value="shop-history">
                <input type="search" name="keyword" class="form-control mr-2" value="{$history_keyword|escape}"
                    aria-label="Tìm trong đơn Shop trước đây" placeholder="Mã đơn hoặc người nhận">
                <button type="submit" class="btn btn-brand">Tìm đơn</button>
            </form>
            <div class="table-responsive">
                <table class="table">
                    <thead><tr><th>Mã đơn</th><th>Ngày đặt</th><th>Người nhận</th><th>Tổng tiền</th><th>Phương thức</th><th>Trạng thái đã lưu</th></tr></thead>
                    <tbody>
                        {foreach $history_rows as $row}
                            <tr>
                                <td><a href="{$history_url|escape}&amp;page={$history_page|intval}&amp;history_id={$row.id|intval}">{$row.cartId|default:'Xem đơn'|escape}</a></td>
                                <td>{$row.created_label|escape}</td>
                                <td>{$row.full_name|default:'–'|escape}</td>
                                <td>{$row.totalPrice|default:0|number_format:0:',':'.'} đ</td>
                                <td>{if $row.payment|default:'' == 'cod'}COD{elseif $row.payment|default:'' == 'bank'}Chuyển khoản{else}–{/if}</td>
                                <td>{$row.archive_status|escape}</td>
                            </tr>
                        {foreachelse}
                            <tr><td colspan="6">Không tìm thấy đơn phù hợp.</td></tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
            <nav class="d-flex align-items-center" aria-label="Trang đơn Shop trước đây">
                {if $history_previous}<a class="btn btn-sm btn-outline-secondary mr-3" href="{$history_url|escape}&amp;page={$history_previous|intval}">Trang trước</a>{/if}
                <span>Trang {$history_page|intval} / {$history_pages|intval}</span>
                {if $history_next}<a class="btn btn-sm btn-outline-secondary ml-3" href="{$history_url|escape}&amp;page={$history_next|intval}">Trang sau</a>{/if}
            </nav>
        </div>
    </div>
</div>
{literal}
<script>
document.addEventListener('DOMContentLoaded', function () {
    const button = document.querySelector('[data-shop-history-import]');
    if (!button) return;
    button.addEventListener('click', function () {
        if (!window.confirm('Đưa hồ sơ này vào sổ đơn để đối soát thanh toán?')) return;
        const error = document.querySelector('[data-shop-history-error]');
        error.hidden = true;
        button.disabled = true;
        nhMain.callAjax({url: button.dataset.link, data: {import_order: '1'}})
            .done(function (response) {
                if (response.code === _SUCCESS) {
                    location.assign(response.data.url);
                } else {
                    error.textContent = response.message || 'Chưa chuyển được đơn.';
                    error.hidden = false;
                }
            }).fail(function () {
                error.textContent = 'Chưa kết nối được. Vui lòng tải lại và thử lại.';
                error.hidden = false;
            }).always(function () { button.disabled = false; });
    });
});
</script>
{/literal}
