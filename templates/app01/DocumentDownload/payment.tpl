{include file='../Order/meduc_assets.tpl'}
<script src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/document-downloads.js?v=20261112-unified-confirmation" defer></script>
<main class="mco mco-unified" data-document-payment="{$purchase_code|escape}">
  <div class="mco-shell">
    <nav class="mco-breadcrumb" aria-label="Đường dẫn"><a href="/tai-lieu-hoc-tap">Tài liệu học tập</a><span>/</span><span>Thanh toán</span></nav>
    <header class="mco-checkout-heading"><p class="mco-kicker">MEDUC / THANH TOÁN</p><h1>Hoàn tất mua lượt tải.</h1></header>
    <p class="mco-notice" role="status" aria-live="polite" data-download-message>Đang kiểm tra lượt tải…</p>
    <div class="mco-panel mco-auth-gate" data-download-login hidden><p>Đăng nhập để tiếp tục thanh toán.</p><button class="mco-button mco-button--primary" type="button" data-ma-open="login">Đăng nhập / Đăng ký</button></div>
    <form class="mco-layout" data-download-private hidden>
      <div class="mco-main">
        <section class="mco-panel"><div class="mco-panel-heading"><h2>Thông tin của bạn</h2></div>{include file='../Order/meduc_contact.tpl' shipping_contact=false}</section>
        <section class="mco-panel mds-invoice"><div class="mco-panel-heading"><h2>Gói lượt tải đã chọn</h2></div>
          <article class="mco-document-item"><h3 data-download-title></h3><p class="mco-help" data-download-filename></p><p class="mco-help" data-download-package-meta></p></article>
          <p class="mco-order-code">Mã đơn <strong data-download-order></strong></p><p class="mco-help" data-download-state></p>
          <button class="mco-button mco-button--primary" type="button" data-download-file hidden>Tải tệp đã mua</button>
          <p class="mco-help">Sau khi thanh toán được xác nhận, lượt tải được cộng vào tài khoản và dùng chung cho các tài liệu. Bạn có thể thử tải lại trong 30 phút nếu mạng gián đoạn.</p>
          <a class="mco-text-link" data-download-back href="/tai-lieu-hoc-tap">← Về tài liệu</a>
        </section>
      </div>
      <aside class="mco-sidebar" data-download-qr><section class="mco-panel mco-payment">
        <div class="mco-panel-heading"><h2>Thanh toán</h2></div>
        {$order_info = ['total'=>9999,'debt'=>9999]}{$payment_reference = '—'}
        {include file='../Order/meduc_payment.tpl' payment_purpose='document' allow_cod=false}
        <div class="mco-checkout-total"><span>Tổng thanh toán</span><div><strong data-download-amount></strong><del data-download-original hidden></del></div></div>
        <p class="mco-payment-note">Sau khi chuyển khoản, nhấn hoàn tất để MedUC kiểm tra và xác nhận thanh toán.</p>
        <button class="mco-button mco-button--primary mco-complete" type="submit" data-download-transfer>Hoàn tất thanh toán</button>
      </section></aside>
    </form>
    <p class="mco-toast" role="status" aria-live="polite" data-checkout-status></p>
  </div>
</main>
