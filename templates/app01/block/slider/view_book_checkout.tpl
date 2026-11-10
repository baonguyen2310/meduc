{strip}
{$catalog = $this->Checkout->catalog()}
{$checkout_contact = []}
{$this->element('../Order/meduc_assets')}
<main class="mco mco-unified" id="meduc-checkout" data-book-checkout data-cdn="{CDN_URL}">
  <div class="mco-shell">
    <nav class="mco-breadcrumb" aria-label="Đường dẫn"><a href="/sach-y-khoa">Sách Y khoa</a><span>/</span><span>Thanh toán</span></nav>
    <header class="mco-checkout-heading"><p class="mco-kicker">MEDUC / THANH TOÁN</p><h1>Hoàn tất đặt sách.</h1></header>
    <div class="mco-empty" data-checkout-empty hidden><h2>Giỏ sách đang trống.</h2><p>Chọn sách để bắt đầu đặt hàng.</p><a class="mco-button mco-button--primary" href="/sach-y-khoa">Khám phá sách</a></div>
    <div class="mco-panel mco-auth-gate" data-checkout-login hidden><p>Đăng nhập để tiếp tục đặt sách. Các sản phẩm đã chọn vẫn được giữ trong giỏ.</p><button class="mco-button mco-button--primary" type="button" data-ma-open="login">Đăng nhập / Đăng ký</button></div>
    <p class="mco-error" role="alert" data-cart-error hidden></p>
    <form class="mco-layout" nh-form-contact="61CQ0U3H9I" action="/contact/send-info" method="post" data-checkout-form hidden>
      <div class="mco-main">
        <section class="mco-panel"><div class="mco-panel-heading"><h2>Thông tin nhận hàng</h2></div>{$this->element('../Order/meduc_contact', ['shipping_contact'=>true])}</section>
        <section class="mco-panel"><div class="mco-panel-heading"><h2>Sách đã chọn <span data-cart-count></span></h2><a href="/sach-y-khoa">Chọn thêm sách</a></div><div data-cart-products></div></section>
      </div>
      <aside class="mco-sidebar"><section class="mco-panel mco-payment">
        <div class="mco-panel-heading"><h2>Thanh toán</h2></div><p class="mco-order-code">Mã đơn <strong data-cart-code></strong></p>
        {$this->element('../Order/meduc_payment', ['payment_purpose'=>'book', 'allow_cod'=>true])}
        <div class="mco-checkout-total"><span>Tổng thanh toán</span><div><strong data-cart-total></strong><del data-cart-subtotal></del></div></div>
        <p class="mco-help">Phí vận chuyển được MedUC xác nhận khi liên hệ giao hàng.</p>
        <p class="mco-payment-note" data-payment-note></p>
        <button type="button" class="mco-button mco-button--primary mco-complete" nh-btn-action="submit" data-place-order>Hoàn tất thanh toán</button>
        <p class="mco-help">Bạn đồng ý với <a href="/dieu-kien-giao-dich-chung" target="_blank" rel="noopener">điều kiện giao dịch</a> và <a href="/chinh-sach-thanh-toan" target="_blank" rel="noopener">chính sách thanh toán</a> của MedUC.</p>
      </section></aside>
      <input type="hidden" name="payment" value="bank"><input type="hidden" name="cartProducts" data-cart-input><input type="hidden" name="cartId" data-cart-id-input><input type="hidden" name="cartTotal" data-cart-total-input><input type="hidden" name="affiliateCode" id="affiliate-code">
    </form>
    <noscript><p class="mco-panel">Vui lòng bật JavaScript để đăng nhập và đặt hàng.</p></noscript>
    <p class="mco-toast" role="status" aria-live="polite" data-checkout-status></p>
  </div>
  <script type="application/json" data-checkout-catalog>{$catalog|json_encode:15 nofilter}</script>
</main>
{/strip}
