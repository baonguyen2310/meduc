{$email = $this->Utilities->getParamsByKey('email')}
<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <a class="ma-back" href="/member/forgot-password"><span aria-hidden="true">←</span> Đổi email khôi phục</a>
            <p class="ma-eyebrow">KHÔI PHỤC TÀI KHOẢN / 02</p>
            <h1 id="ma-title">Một bước nữa thôi.</h1>
            <p class="ma-description">Nhập mã xác nhận từ email và chọn mật khẩu mới cho tài khoản của bạn.</p>
            <ol class="ma-steps" aria-label="Các bước khôi phục"><li class="ma-step-done"><span>✓</span> Xác nhận email</li><li aria-current="step"><span>2</span> Đặt mật khẩu mới</li></ol>
            <form class="ma-form" nh-form="verify-forgot-password" action="/member/ajax-verify-forgot-password" method="post">
                <div class="ma-field"><label for="ma-reset-email">Email đã đăng ký</label><div class="input-group ma-input"><input name="email" id="ma-reset-email" type="email" autocomplete="email" value="{$email|default:''|escape}" required maxlength="255"{if !empty($email)} readonly{/if}></div></div>
                <div class="ma-field"><label for="ma-reset-code">Mã xác nhận</label><div class="input-group ma-input"><input name="code" id="ma-reset-code" class="ma-code" type="text" inputmode="numeric" autocomplete="one-time-code" placeholder="Nhập mã trong email" aria-required="true" maxlength="20"></div><p class="ma-hint">Kiểm tra cả mục Thư rác nếu chưa thấy email.</p></div>
                <div class="ma-field"><label for="new_password">Mật khẩu mới</label><div class="input-group ma-input ma-input-password"><input id="new_password" name="new_password" type="password" autocomplete="new-password" placeholder="Tối thiểu 6 ký tự" required minlength="6" maxlength="255">{$this->element('../Member/auth_password_toggle', ['input_id' => 'new_password'])}</div></div>
                <div class="ma-field"><label for="re_password">Nhập lại mật khẩu mới</label><div class="input-group ma-input ma-input-password"><input id="re_password" name="re_password" data-msg-required="Vui lòng nhập lại mật khẩu mới" type="password" autocomplete="new-password" placeholder="Nhập lại mật khẩu mới" required maxlength="255">{$this->element('../Member/auth_password_toggle', ['input_id' => 're_password'])}</div></div>
                <p class="ma-status" role="alert" hidden></p>
                <button type="submit" nh-btn-action="submit" class="ma-submit">Lưu mật khẩu mới <span aria-hidden="true">→</span></button>
                <div class="ma-resend"><span>Chưa nhận được mã?</span> <button type="button" nh-btn-action="resend-verify">Gửi lại mã <span nh-countdown aria-live="polite"></span></button></div>
            </form>
        </section>
    </div>
</main>
