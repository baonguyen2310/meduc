{strip}
{$contact=$order_info.contact|default:[]}
<section class="mco-panel"><div class="mco-panel-heading"><h2><span>01</span>Khóa học đã chọn</h2><a href="/khoa-hoc">Xem khóa học ↗</a></div>{$this->element('../Order/meduc_products')}</section>
<section class="mco-panel"><div class="mco-panel-heading"><h2><span>02</span>Thông tin học viên</h2></div>
{if !empty($member_info)}{$this->element('../Order/contact_info',['contact'=>$member_info])}
{else}<div class="mco-fields">
<div class="mco-field mco-field--full form-group"><label for="course-full-name">Họ và tên <span>*</span></label><input id="course-full-name" name="full_name" autocomplete="name" value="{$contact.full_name|default:''|escape}" placeholder="Họ và tên học viên"></div>
<div class="mco-field form-group"><label for="course-email">Email <span>*</span></label><input id="course-email" type="email" name="email" autocomplete="email" value="{$contact.email|default:''|escape}" placeholder="you@example.com"></div>
<div class="mco-field form-group"><label for="course-phone">Số điện thoại <span>*</span></label><input id="course-phone" type="tel" name="phone" autocomplete="tel" value="{$contact.phone|default:''|escape}" placeholder="Số điện thoại liên hệ"></div>
</div>{/if}
<div class="mco-field form-group" style="margin-top:20px!important"><label for="course-note">Ghi chú <small>(không bắt buộc)</small></label><textarea id="course-note" name="note" rows="3" maxlength="500" placeholder="Lời nhắn dành cho MedUC...">{$contact.note|default:''|escape}</textarea></div>
<p class="mco-help">MedUC sẽ dùng thông tin này để liên hệ và hỗ trợ đăng ký khóa học.</p></section>
{/strip}
