{strip}
{$this->element('../Order/meduc_assets')}
{$message=$this->Utilities->getParamsByKey('message')}
{$contact=$order_info.contact|default:[]}
{capture assign=payment_reference}{$contact.full_name|default:''}{foreach from=$order_info.items item=item} _ {$item.name}{/foreach}{/capture}
<main class="mco mco-course-payment"><div class="mco-shell">
<nav class="mco-breadcrumb" aria-label="Đường dẫn"><a href="/khoa-hoc">Khóa học</a><span>/</span><span>Thanh toán</span></nav>
<header class="mco-heading"><div><p class="mco-kicker">MEDUC / THANH TOÁN KHÓA HỌC</p><h1>SẴN SÀNG CHO<br><span>BƯỚC TIẾP THEO.</span></h1><p>Quét mã QR hoặc chuyển khoản để hoàn tất đăng ký.</p></div><ol class="mco-steps" aria-label="Các bước đăng ký"><li><b>01</b>Thông tin</li><li aria-current="step"><b>02</b>Thanh toán</li><li><b>03</b>Hoàn tất</li></ol></header>
{if !empty($message)}<p class="mco-error" role="alert">{$message|escape}</p>{/if}
<div class="mco-layout"><div class="mco-main"><section class="mco-panel"><div class="mco-panel-heading"><h2><span>01</span>Khóa học đăng ký</h2></div>{$this->element('../Order/meduc_products')}</section>
<section class="mco-panel"><div class="mco-panel-heading"><h2><span>02</span>Phương thức thanh toán</h2></div>
<form id="form-checkout" method="post"><nav class="mco-gateways" aria-label="Phương thức thanh toán">{foreach from=$payment_gateway item=gateway key=code name=gateways}<a nh-gateway-item="{$code|escape}" href="#payment-{$code|escape}" class="{if $smarty.foreach.gateways.first}active{/if}"><img src="{URL_TEMPLATE}assets/img/payment/{$code|escape}.png" alt="">{$gateway.name|default:$code|escape}</a>{/foreach}</nav>
{foreach from=$payment_gateway item=gateway key=code name=panels}<div id="payment-{$code|escape}" data-gateway-panel="{$code|escape}" class="tab-pane {if $smarty.foreach.panels.first}active{/if}">
{if $code == {BANK}}{$this->element('../Order/meduc_payment', ['payment_reference'=>$payment_reference])}{elseif !empty($gateway.content)}<p class="mco-help">{$gateway.content|strip_tags|escape}</p>{/if}
<div class="mco-confirm"><p class="mco-payment-note">{if $code == {BANK}}Chỉ nhấn “Hoàn tất thanh toán” sau khi đã chuyển khoản. MedUC sẽ kiểm tra và xác nhận thanh toán của bạn.{else}Tiếp tục để thanh toán qua {$gateway.name|default:$code|escape}.{/if}</p><button type="button" class="mco-button mco-button--primary" nh-btn-action="checkout">Hoàn tất thanh toán <span aria-hidden="true">→</span></button></div>
</div>{/foreach}
<input type="hidden" name="payment_gateway" value=""><input type="hidden" name="affiliateCode" id="affiliate-code"><input type="hidden" name="code" value="{$order_info.code|default:''|escape}"></form></section></div>
<aside class="mco-sidebar"><div class="mco-summary"><p class="mco-kicker">THÔNG TIN ĐĂNG KÝ</p><h2>Hành trình của bạn.</h2><p class="mco-order-code">Mã đơn <strong>{$order_info.code|default:''|escape}</strong></p><div class="mco-totals">{$this->element('../Order/element_items')}</div><div class="mco-contact-summary"><strong>{$contact.full_name|default:''|escape}</strong><p>{$contact.phone|default:''|escape}</p><p>{$contact.email|default:''|escape}</p>{if !empty($order_info.note)}<p>{$order_info.note|escape}</p>{/if}</div></div><div class="mco-support"><span>Cần hỗ trợ thanh toán?</span><a href="tel:0339308997">0339 308 997 ↗</a><p>MedUC đồng hành cùng bạn.</p></div></aside></div>
<p class="mco-toast" role="status" aria-live="polite" data-checkout-status></p>
</div></main>
{/strip}
