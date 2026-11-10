<main class="mco mco-unified" style="min-height:100vh"><div class="mco-shell" style="max-width:640px;padding-top:48px"><p class="mco-kicker">MEDUC / DUYỆT THANH TOÁN</p>
{if !$purchase}<section class="mco-panel"><h1 style="font:700 28px Arial">Liên kết không còn hiệu lực.</h1><p>Mở danh sách giao dịch trong trang admin để kiểm tra đơn hàng.</p><a href="/admin/order/list" class="mco-button mco-button--primary">Mở admin</a></section>
{else}<section class="mco-panel"><h1 style="font:700 28px/1.3 Arial">{if $approved}Đã duyệt và mở quyền.{else}Xác nhận đã nhận thanh toán.{/if}</h1><p class="mco-help">Mã đơn {$purchase.order_code|escape}</p>
<dl class="mco-totals"><div><dt>Người mua</dt><dd>{$purchase.full_name|escape}</dd></div><div><dt>Email</dt><dd>{$purchase.email|escape}</dd></div><div><dt>Gói mua</dt><dd>{$purchase.package_name|escape}</dd></div>{if $products}<div><dt>Môn học</dt><dd>{$products|escape}</dd></div>{/if}<div><dt>Số tiền</dt><dd>{$purchase.amount|number_format:0:',':'.'}đ</dd></div>{if $purchase.duration_months}<div><dt>Thời hạn</dt><dd>{$purchase.duration_months} tháng</dd></div>{/if}{if $purchase.credit_count}<div><dt>Lượt tải được cộng</dt><dd>{$purchase.credit_count} lượt</dd></div>{/if}</dl>
{if $error}<p class="mco-error" role="alert">{$error|escape}</p>{/if}
{if !$approved}<p class="mco-payment-note">Kiểm tra giao dịch ngân hàng trước khi xác nhận. Sau khi duyệt, hệ thống sẽ mở quyền hoặc cộng lượt tải cho người mua.</p>
{$this->Form->create(null,['type'=>'post'])}<button class="mco-button mco-button--primary mco-complete" type="submit">Xác nhận và mở quyền</button>{$this->Form->end()}
{else}<p class="mco-payment-note">Quyền sử dụng đã được cập nhật. Người mua nhận được email thông báo.</p>{/if}
<a class="mco-text-link" href="/admin/order/detail/{$purchase.order_id}">Xem đơn trong admin →</a></section>{/if}
</div></main>
