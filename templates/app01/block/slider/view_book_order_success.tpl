{strip}
{$order = $this->Checkout->confirmation()}
{$this->element('../Order/meduc_assets')}
<main class="mco" id="meduc-order-confirmation"><div class="mco-shell"><section class="mco-success">
    {if !empty($order)}
        <p class="mco-kicker">MEDUC / ĐÃ NHẬN ĐƠN HÀNG</p><h1>CẢM ƠN BẠN.<br><span>MEDUC ĐÃ NHẬN THÔNG TIN.</span></h1><p>MedUC sẽ liên hệ xác nhận đơn hàng{if $order.payment == 'bank'} và kiểm tra khoản thanh toán của bạn{/if}.</p>
        <div class="mco-panel"><div class="mco-panel-heading"><h2>Đơn hàng {$order.cartId|escape}</h2></div><p>{$order.full_name|escape} · {$order.phone|escape}</p><p>{$order.address|escape}</p><dl class="mco-totals">{foreach from = $order.cartProducts|json_decode:true item = item}<div><dt>{$item.name|escape} × {$item.quantity}</dt><dd>{$item.total|number_format:0:',':'.'} ₫</dd></div>{/foreach}<div class="mco-total"><dt>Tổng tiền sản phẩm</dt><dd>{$order.totalPrice|number_format:0:',':'.'} ₫</dd></div></dl><p class="mco-help">Phương thức: {if $order.payment == 'bank'}Chuyển khoản / MoMo{else}Thanh toán khi nhận hàng{/if}. Phí vận chuyển được MedUC xác nhận sau.</p></div>
        <script>{literal}try{const cart=JSON.parse(sessionStorage.getItem('cart'));if(cart&&cart.cartId==={/literal}{$order.cartId|json_encode:15 nofilter}{literal}){sessionStorage.removeItem('cart');document.querySelectorAll('[nh-mini-cart-book-quantity]').forEach(counter=>{counter.textContent='0';});}}catch(_){}{/literal}</script>
    {else}<p class="mco-kicker">MEDUC / THÔNG TIN ĐƠN HÀNG</p><h1>MEDUC LUÔN<br><span>SẴN SÀNG HỖ TRỢ.</span></h1><p>Thông tin đơn hàng không có trong phiên trình duyệt này. Liên hệ MedUC và cung cấp mã đơn hàng để được kiểm tra.</p>{/if}
    <div class="mco-success-actions"><a class="mco-button mco-button--primary" href="/sach-y-khoa">Tiếp tục khám phá sách <span aria-hidden="true">→</span></a><a class="mco-button mco-button--quiet" href="tel:0339308997">Gọi MedUC · 0339 308 997</a></div>
</section></div></main>
{/strip}
