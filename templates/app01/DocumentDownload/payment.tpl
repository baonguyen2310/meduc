{include file='../Order/meduc_assets.tpl'}
<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/document-downloads.css?v=20261028-2" rel="stylesheet">
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/document-downloads.js?v=20261028-2" defer></script>
<main class="mco mds-payment" data-document-payment="{$purchase_code|escape}">
  <div class="mco-shell">
    <p class="mco-kicker">MEDUC / TÀI LIỆU HỌC TẬP</p>
    <h1>MUA LƯỢT TẢI.</h1>
    <p class="mds-lead">9.999đ cho một lượt tải một tệp. Đọc trực tuyến vẫn miễn phí.</p>
    <p class="mds-notice" role="status" aria-live="polite" data-download-message>Đang kiểm tra lượt tải…</p>
    <div class="mds-login" data-download-login hidden><p>Đăng nhập tài khoản đã mua để tiếp tục.</p><button class="mds-button" type="button" data-ma-open="login">Đăng nhập / Đăng ký</button></div>
    <div class="mds-payment-grid" data-download-private hidden>
      <section class="mds-invoice" aria-labelledby="download-invoice-title">
        <p class="mco-kicker">MỘT TỆP / MỘT LƯỢT TẢI</p>
        <h2 id="download-invoice-title" data-download-title></h2>
        <p class="mds-filename" data-download-filename></p>
        <dl class="mds-order-facts"><div><dt>Mã đơn</dt><dd data-download-order></dd></div><div><dt>Giá lượt tải</dt><dd class="mds-price">9.999đ</dd></div><div><dt>Trạng thái</dt><dd data-download-state></dd></div></dl>
        <button class="mds-button" type="button" data-download-file hidden>Tải tệp đã mua ↓</button>
        <p class="mds-help">Sau khi thanh toán được xác nhận, lượt tải được giữ trong tài khoản cho đến khi sử dụng. Khi bắt đầu tải, bạn có thể thử lại trong 30 phút nếu mạng bị gián đoạn.</p>
        <a class="mds-back" data-download-back href="/tai-lieu-hoc-tap">← Về tài liệu</a>
      </section>
      <section class="mds-checkout" data-download-qr aria-labelledby="download-payment-title">
        <h2 id="download-payment-title">Thanh toán chuyển khoản</h2>
        {$order_info = ['total'=>9999,'debt'=>9999]}{$payment_reference = '—'}
        {include file='../Order/meduc_payment.tpl'}
        <button class="mds-button" type="button" data-download-transfer>Đã chuyển khoản</button>
        <p class="mds-help">MedUC sẽ kiểm tra giao dịch và xác nhận thủ công. Nút trên chỉ gửi thông báo, chưa mở quyền tải.</p>
      </section>
    </div>
  </div>
</main>
