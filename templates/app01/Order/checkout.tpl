{strip}
{$this->element('../Order/meduc_assets')}
<main class="mco mco-unified mco-course-payment" data-order-checkout>
  <div class="mco-shell">
    <nav class="mco-breadcrumb" aria-label="Đường dẫn"><a href="/">Trang chủ</a><span>/</span><span>Thanh toán</span></nav>
    <header class="mco-checkout-heading"><p class="mco-kicker">MEDUC / THANH TOÁN</p><h1>Hoàn tất đăng ký.</h1></header>
    {if !empty($checkout_login_required)}
      <div class="mco-panel mco-auth-gate" data-checkout-login><p>Đăng nhập để tiếp tục thanh toán đơn hàng của bạn.</p><button class="mco-button mco-button--primary" type="button" data-ma-open="login">Đăng nhập / Đăng ký</button></div>
    {else}
      {$prices = $this->Checkout->prices($order_info)}
      <form class="mco-layout" data-order-payment-form data-payment-return="{$this->Checkout->paymentCatalog($order_info)|escape}">
        <div class="mco-main">
          <section class="mco-panel"><div class="mco-panel-heading"><h2>Thông tin của bạn</h2></div>{$this->element('../Order/meduc_contact', ['shipping_contact'=>false])}</section>
          <section class="mco-panel"><div class="mco-panel-heading"><h2>Sản phẩm đã chọn</h2><a href="/bang-bao-gia">Chọn thêm</a></div>
            {if !empty($prices.package.name)}<p class="mco-payment-note"><strong>{$prices.package.name|escape}</strong>{if !empty($prices.package.duration_months)} · Quyền học {$prices.package.duration_months} tháng, tính từ khi được duyệt.{/if}</p>{/if}
            {$this->element('../Order/meduc_products')}
          </section>
        </div>
        <aside class="mco-sidebar"><section class="mco-panel mco-payment">
          <div class="mco-panel-heading"><h2>Thanh toán</h2></div><p class="mco-order-code">Mã đơn <strong>{$order_info.code|escape}</strong></p>
          {$this->element('../Order/meduc_payment', ['payment_reference'=>$order_info.code, 'payment_purpose'=>'order', 'order_info'=>$order_info, 'allow_cod'=>false])}
          <div class="mco-checkout-total"><span>Tổng thanh toán</span><div><strong>{$prices.amount|number_format:0:',':'.'}đ</strong>{if $prices.original>$prices.amount}<del>{$prices.original|number_format:0:',':'.'}đ</del>{/if}</div></div>
          <p class="mco-payment-note">Sau khi chuyển khoản, nhấn hoàn tất để MedUC kiểm tra và xác nhận thanh toán.</p>
          <p class="mco-error" data-order-payment-error role="alert" hidden></p>
          <button type="submit" class="mco-button mco-button--primary mco-complete">Hoàn tất thanh toán</button>
        </section></aside>
        <input type="hidden" name="code" value="{$order_info.code|escape}"><input type="hidden" name="payment_gateway" value="bank"><input type="hidden" name="affiliateCode" id="affiliate-code">
      </form>
    {/if}
    <p class="mco-toast" role="status" aria-live="polite" data-checkout-status></p>
  </div>
</main>
{/strip}
