{* The original MedUC payment images are served from the same origin so download works on desktop and mobile. *}
{$bank_context = $payment_purpose|default:'course'}
{$bank_order = $order_info|default:[]}
{$bank = $this->Checkout->bank($bank_context, $bank_order)}
<div class="mco-transfer" data-transfer-panel>
    <div class="mco-qr-tabs" role="tablist" aria-label="Mã QR thanh toán">
        <button type="button" role="tab" id="qr-bank-tab" aria-controls="qr-bank-panel" aria-selected="true" data-qr-tab="bank">Ngân hàng</button>
        {if !empty($bank.show_momo)}<button type="button" role="tab" id="qr-momo-tab" aria-controls="qr-momo-panel" aria-selected="false" tabindex="-1" data-qr-tab="momo">MoMo</button>{/if}
        {if !empty($allow_cod)}<button type="button" role="tab" id="qr-cod-tab" aria-controls="qr-cod-panel" aria-selected="false" tabindex="-1" data-qr-tab="cod">COD</button>{/if}
    </div>
    <div id="qr-bank-panel" class="mco-qr-panel{if !empty($bank.qr_compact)} mco-qr-panel--compact{/if}" role="tabpanel" aria-labelledby="qr-bank-tab" data-qr-panel="bank">
        <div class="mco-qr-image"><img src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/payment/{$bank.qr_file|escape}" alt="Mã QR {$bank.bank_name|default:'VietinBank'|escape} - {$bank.account_holder|default:'HKD MedUC'|escape}" width="{$bank.qr_width}" height="{$bank.qr_height}"></div>
        <details class="mco-payment-details"><summary>Thông tin chuyển khoản và tải QR</summary><div class="mco-bank-copy"><p class="mco-kicker">CHUYỂN KHOẢN NGÂN HÀNG</p><h3>{$bank.bank_name|default:'VietinBank'|escape}</h3><dl><div><dt>Chủ tài khoản</dt><dd>{$bank.account_holder|default:'HKD MedUC'|escape}</dd></div><div><dt>Số tài khoản</dt><dd><strong>{$bank.account_number|default:'0339308997'|escape}</strong><button type="button" class="mco-copy" data-copy="{$bank.account_number|default:'0339308997'|escape}" aria-label="Sao chép số tài khoản">Sao chép</button></dd></div>{if !empty($bank.bank_branch)}<div><dt>Chi nhánh</dt><dd>{$bank.bank_branch|escape}</dd></div>{/if}</dl><a class="mco-button mco-button--quiet" href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/payment/{$bank.qr_file|escape}" download="{$bank.qr_download|escape}"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12m-5-5 5 5 5-5M4 16v5h16v-5"/></svg>Tải mã QR</a></div></details>
    </div>
    {if !empty($bank.show_momo)}
    <div id="qr-momo-panel" class="mco-qr-panel" role="tabpanel" aria-labelledby="qr-momo-tab" data-qr-panel="momo" hidden>
        <div class="mco-qr-image mco-qr-image--momo"><img src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/payment/momo-qr.jpg" alt="Mã QR ví MoMo MedUC" width="380" height="376"></div>
        <details class="mco-payment-details"><summary>Thông tin chuyển khoản và tải QR</summary><div class="mco-bank-copy"><p class="mco-kicker">THANH TOÁN QUA VÍ</p><h3>MoMo</h3><dl><div><dt>Số điện thoại</dt><dd><strong>0339308997</strong><button type="button" class="mco-copy" data-copy="0339308997" aria-label="Sao chép số MoMo">Sao chép</button></dd></div></dl><a class="mco-button mco-button--quiet" href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/payment/momo-qr.jpg" download="MedUC-QR-MoMo.jpg"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v12m-5-5 5 5 5-5M4 16v5h16v-5"/></svg>Tải mã QR</a></div></details>
    </div>
    {/if}
    {if !empty($allow_cod)}<div id="qr-cod-panel" role="tabpanel" aria-labelledby="qr-cod-tab" data-qr-panel="cod" class="mco-cod-panel" hidden><strong>Thanh toán khi nhận sách</strong><p>Bạn thanh toán cho đơn vị giao hàng khi nhận sách. MedUC sẽ liên hệ xác nhận đơn hàng và phí vận chuyển.</p></div>{/if}
    <div class="mco-transfer-ref" data-transfer-reference><span>Nội dung chuyển khoản</span><strong data-payment-reference>{$payment_reference|default:''|escape}</strong><button type="button" class="mco-copy" data-copy-reference>Sao chép</button></div>
    <p class="mco-help" data-transfer-help>Quét mã bằng ứng dụng ngân hàng hoặc lưu QR vào thư viện ảnh. Nhập đúng số tiền và nội dung chuyển khoản hiển thị tại đây.</p>
</div>
