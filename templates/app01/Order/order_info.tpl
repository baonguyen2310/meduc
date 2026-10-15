{strip}
{$this->element('../Order/meduc_assets')}
<div class="mco mco-course-info" nh-order-info><div class="mco-shell">
    <nav class="mco-breadcrumb" aria-label="Đường dẫn"><a href="/khoa-hoc">Khóa học</a><span>/</span><span>Đăng ký học</span></nav>
    <header class="mco-heading"><div><p class="mco-kicker">MEDUC / ĐĂNG KÝ KHÓA HỌC</p><h1>ĐẦU TƯ CHO<br><span>HÀNH TRÌNH HỌC Y.</span></h1><p>Kiểm tra khóa học và thông tin trước khi thanh toán.</p></div><ol class="mco-steps" aria-label="Các bước đăng ký"><li aria-current="step"><b>01</b>Thông tin</li><li><b>02</b>Thanh toán</li><li><b>03</b>Hoàn tất</li></ol></header>
    <form id="order-info" method="post" class="mco-layout"><div id="order-info-left" class="mco-main">{$this->element('../Order/element_order_info_left')}</div><aside class="mco-sidebar"><div class="mco-summary"><p class="mco-kicker">TÓM TẮT ĐĂNG KÝ</p><h2>Hành trình của bạn.</h2><div id="order-info-right">{$this->element('../Order/element_order_info_right')}</div></div><div class="mco-support"><span>Cần hỗ trợ đăng ký?</span><a href="tel:0339308997">0339 308 997 ↗</a><p>MedUC đồng hành cùng bạn.</p></div></aside></form>
    {if !empty($member_info)}{$this->element('../Order/update_address_modal')}{/if}{$this->element('../Order/list_coupon_modal')}
</div></div>
{/strip}
