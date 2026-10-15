{strip}
{$catalog = $this->Checkout->catalog()}
{$this->element('../Order/meduc_assets')}
<main class="mco" id="meduc-checkout" data-book-checkout data-cdn="{CDN_URL}">
    <div class="mco-shell">
        <nav class="mco-breadcrumb" aria-label="Đường dẫn"><a href="/sach-y-khoa">Sách Y khoa</a><span aria-hidden="true">/</span><span>Thanh toán</span></nav>
        <header class="mco-heading"><div><p class="mco-kicker">MEDUC / ĐẶT HÀNG</p><h1>THÊM TRI THỨC.<br><span>TIẾP HÀNH TRÌNH.</span></h1><p>Kiểm tra giỏ hàng và hoàn tất thông tin của bạn.</p></div><ol class="mco-steps" aria-label="Các bước đặt hàng"><li><b>01</b>Giỏ hàng</li><li aria-current="step"><b>02</b>Thanh toán</li><li><b>03</b>Hoàn tất</li></ol></header>
        <div class="mco-empty" data-checkout-empty hidden><svg viewBox="0 0 48 48" aria-hidden="true"><path d="M9 13h30l-3 27H12L9 13Zm8 0V9a7 7 0 0 1 14 0v4"/></svg><p class="mco-kicker">GIỎ HÀNG CỦA BẠN</p><h2>CHƯA CÓ CUỐN SÁCH NÀO.</h2><p>Chọn sách hoặc thiết bị Y tế để bắt đầu đặt hàng.</p><a class="mco-button mco-button--primary" href="/sach-y-khoa">Khám phá sách <span aria-hidden="true">→</span></a><a class="mco-text-link" href="/thiet-bi-y-te">Xem thiết bị Y tế ↗</a></div>
        <p class="mco-error" role="alert" data-cart-error hidden></p>
        <form class="mco-layout" nh-form-contact="61CQ0U3H9I" action="/contact/send-info" method="post" data-checkout-form hidden>
            <div class="mco-main">
                <section class="mco-panel"><div class="mco-panel-heading"><h2><span>01</span>Giỏ hàng của bạn</h2><a href="/sach-y-khoa">Chọn thêm sách ↗</a></div><div data-cart-products></div></section>
                <section class="mco-panel"><div class="mco-panel-heading"><h2><span>02</span>Thông tin nhận hàng</h2></div><div class="mco-fields">
                    <div class="mco-field mco-field--full form-group"><label for="full_name">Họ và tên <span>*</span></label><input id="full_name" name="full_name" autocomplete="name" required maxlength="255" data-msg="Vui lòng nhập họ và tên." placeholder="Họ và tên người nhận"></div>
                    <div class="mco-field form-group"><label for="phone">Số điện thoại <span>*</span></label><input id="phone" name="phone" type="tel" autocomplete="tel" required data-rule-phoneVN="true" data-msg="Vui lòng nhập số điện thoại hợp lệ." placeholder="Số điện thoại liên hệ"></div>
                    <div class="mco-field form-group"><label for="email">Email <span>*</span></label><input id="email" name="email" type="email" autocomplete="email" required maxlength="255" data-msg="Vui lòng nhập email hợp lệ." placeholder="you@example.com"></div>
                    <div class="mco-field mco-field--full form-group"><label for="address">Địa chỉ nhận hàng <span>*</span></label><input id="address" name="address" autocomplete="street-address" required maxlength="255" data-msg="Vui lòng nhập địa chỉ nhận hàng." placeholder="Số nhà, đường, phường/xã, tỉnh/thành phố"></div>
                    <div class="mco-field mco-field--full form-group"><label for="note">Ghi chú <small>(không bắt buộc)</small></label><textarea id="note" name="note" rows="3" maxlength="500" placeholder="Lời nhắn dành cho MedUC..."></textarea></div>
                </div></section>
                <section class="mco-panel"><div class="mco-panel-heading"><h2><span>03</span>Phương thức thanh toán</h2></div>
                    <div class="mco-methods"><label><input type="radio" name="payment" value="bank" checked><span><strong>Chuyển khoản / MoMo</strong><small>Quét mã QR hoặc chuyển khoản thủ công</small></span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 8h18v13H3V8Zm0 4h18M7 17h4M4 8l8-5 8 5"/></svg></label><label><input type="radio" name="payment" value="cod"><span><strong>Thanh toán khi nhận hàng</strong><small>Thanh toán trực tiếp cho đơn vị giao hàng</small></span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 5h12v13H2V5Zm12 5h4l4 4v4h-8M5 18a2 2 0 1 0 4 0m7 0a2 2 0 1 0 4 0"/></svg></label></div>
                    {$this->element('../Order/meduc_payment')}
                </section>
            </div>
            <aside class="mco-sidebar"><div class="mco-summary"><p class="mco-kicker">TÓM TẮT ĐƠN HÀNG</p><h2>Hành trình của bạn.</h2><p class="mco-order-code">Mã đơn <strong data-cart-code></strong></p><dl class="mco-totals"><div><dt>Sản phẩm <span data-cart-count></span></dt><dd data-cart-subtotal></dd></div><div data-cart-discount-row hidden><dt>Tiết kiệm</dt><dd class="mco-saving" data-cart-discount></dd></div><div><dt>Phí vận chuyển</dt><dd>MedUC xác nhận sau</dd></div><div class="mco-total"><dt>Tổng tiền sản phẩm</dt><dd data-cart-total></dd></div></dl><p class="mco-payment-note" data-payment-note>Chỉ nhấn “Đặt hàng” sau khi đã chuyển khoản. MedUC sẽ kiểm tra và xác nhận thanh toán.</p><button type="button" class="mco-button mco-button--primary" nh-btn-action="submit" data-place-order>Đặt hàng <span aria-hidden="true">→</span></button><p class="mco-help">Bằng việc đặt hàng, bạn đồng ý với <a href="/dieu-kien-giao-dich-chung" target="_blank" rel="noopener">điều kiện giao dịch</a> và <a href="/chinh-sach-thanh-toan" target="_blank" rel="noopener">chính sách thanh toán</a> của MedUC.</p></div><div class="mco-support"><span>Cần hỗ trợ đặt hàng?</span><a href="tel:0339308997">0339 308 997 <span aria-hidden="true">↗</span></a><p>MedUC đồng hành cùng bạn.</p></div></aside>
            <input type="hidden" name="cartProducts" data-cart-input><input type="hidden" name="cartId" data-cart-id-input><input type="hidden" name="cartTotal" data-cart-total-input><input type="hidden" name="affiliateCode" id="affiliate-code">
        </form>
        <noscript><p class="mco-panel">Vui lòng bật JavaScript để xem giỏ hàng và đặt hàng.</p></noscript>
        <p class="mco-toast" role="status" aria-live="polite" data-checkout-status></p>
    </div>
    <script type="application/json" data-checkout-catalog>{$catalog|json_encode:15 nofilter}</script>
</main>
{/strip}
