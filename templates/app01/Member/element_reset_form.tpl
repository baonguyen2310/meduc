{$reset_id = $reset_form_id|default:'ma-reset'}
<form class="ma-form" data-ma-reset action="/member/ajax-verify-forgot-password" method="post">
    <div class="ma-field"><label for="{$reset_id|escape}-email">Email khôi phục</label><div class="input-group ma-input"><input name="email" id="{$reset_id|escape}-email" type="email" autocomplete="email" value="{$reset_email|default:''|escape}" required maxlength="255"{if !empty($reset_readonly)} readonly{/if}></div></div>
    <div class="ma-field"><label for="{$reset_id|escape}-code">Mã OTP gồm 6 số</label><div class="input-group ma-input"><input name="code" id="{$reset_id|escape}-code" class="ma-otp-code" type="text" inputmode="numeric" autocomplete="one-time-code" placeholder="000000" required pattern="[0-9][0-9][0-9][0-9][0-9][0-9]" minlength="6" maxlength="6"></div><p class="ma-hint">Mã có hiệu lực 10 phút. Hãy dùng mã trong email mới nhất và kiểm tra cả thư mục Spam.</p></div>
    <div class="ma-field"><label for="{$reset_id|escape}-password">Mật khẩu mới</label><div class="input-group ma-input ma-input-password"><input name="new_password" id="{$reset_id|escape}-password" type="password" autocomplete="new-password" placeholder="Tối thiểu 6 ký tự" required minlength="6" maxlength="255">{$this->element('../Member/auth_password_toggle', ['input_id' => "{$reset_id}-password"])}</div></div>
    <div class="ma-field"><label for="{$reset_id|escape}-confirm">Nhập lại mật khẩu mới</label><div class="input-group ma-input ma-input-password"><input name="re_password" id="{$reset_id|escape}-confirm" type="password" autocomplete="new-password" placeholder="Nhập lại mật khẩu mới" required minlength="6" maxlength="255">{$this->element('../Member/auth_password_toggle', ['input_id' => "{$reset_id}-confirm"])}</div></div>
    <p class="ma-status" role="alert" hidden></p>
    <button type="submit" class="ma-submit">Lưu mật khẩu mới <span aria-hidden="true">→</span></button>
    <div class="ma-resend"><span>Chưa nhận được mã?</span><button type="button" data-ma-reset-resend>Gửi lại mã</button></div>
    <p class="ma-switch"><a href="/member/forgot-password" data-ma-open="forgot">Đổi email khôi phục</a></p>
</form>
