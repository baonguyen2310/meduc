{$recovery_id = $recovery_form_id|default:'ma-recovery'}
<form class="ma-form" data-ma-recovery action="/member/ajax-forgot-password" method="post">
    <div class="ma-field"><label for="{$recovery_id|escape}-email">Email đã đăng ký</label><div class="input-group ma-input"><input name="email" id="{$recovery_id|escape}-email" type="email" autocomplete="email" placeholder="ban@example.com" required maxlength="255"></div></div>
    <p class="ma-status" role="alert" hidden></p>
    <button type="submit" class="ma-submit">Gửi mã OTP <span aria-hidden="true">→</span></button>
    <p class="ma-help">Không còn truy cập được email? <a href="/lien-he-hop-tac">Liên hệ MedUC</a> để được hỗ trợ.</p>
    <p class="ma-switch"><a href="/member/login" data-ma-open="login">Quay lại đăng nhập</a></p>
</form>
