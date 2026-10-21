<div id="login-modal" class="modal fade ma-modal" tabindex="-1" role="dialog" aria-modal="true" aria-labelledby="ma-modal-title" aria-describedby="ma-modal-description" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content ma">
            <button type="button" class="ma-close" data-bs-dismiss="modal" aria-label="Đóng cửa sổ tài khoản"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18"/></svg></button>
            <div class="modal-body">
                <p class="ma-eyebrow">TÀI KHOẢN MEDUC</p>
                <h2 id="ma-modal-title">Chào mừng trở lại.</h2>
                <p class="ma-description" id="ma-modal-description">Đăng nhập để tiếp tục hành trình học Y.</p>
                <div class="ma-tabs ma-modal-tabs" role="tablist" aria-label="Đăng nhập hoặc đăng ký">
                    <button id="ma-tab-login" type="button" role="tab" data-ma-view="login" aria-selected="true" aria-controls="ma-panel-login">Đăng nhập</button>
                    <button id="ma-tab-register" type="button" role="tab" data-ma-view="register" aria-selected="false" aria-controls="ma-panel-register" tabindex="-1">Đăng ký</button>
                </div>
                <section id="ma-panel-login" role="tabpanel" data-ma-panel="login" aria-labelledby="ma-tab-login">
                    {$this->element('../Member/element_login_form', ['form_id' => 'meduc-login-modal'])}
                </section>
                <section id="ma-panel-register" role="tabpanel" data-ma-panel="register" aria-labelledby="ma-tab-register" hidden>
                    {$this->element('../Member/element_register_form', ['register_form_id' => 'meduc-register-modal'])}
                </section>
                <section data-ma-panel="forgot" aria-label="Khôi phục tài khoản" hidden>
                    {$this->element('../Member/element_recovery_form', ['recovery_form_id' => 'ma-modal-recovery'])}
                </section>
                <section data-ma-panel="reset" aria-label="Đặt lại mật khẩu" hidden>
                    {$this->element('../Member/element_reset_form', ['reset_form_id' => 'ma-modal-reset', 'reset_readonly' => true])}
                </section>
                <section data-ma-panel="verify" aria-label="Xác thực email đăng ký" hidden>
                    <form class="ma-form" data-ma-verify action="/member/ajax-verify-email" method="post">
                        <div class="ma-field"><label for="ma-modal-email">Email đã đăng ký</label><div class="input-group ma-input"><input id="ma-modal-email" name="email" type="email" autocomplete="email" readonly required maxlength="255"></div></div>
                        <div class="ma-field"><label for="ma-modal-code">Mã OTP gồm 6 số</label><div class="input-group ma-input"><input id="ma-modal-code" name="code" class="ma-otp-code" type="text" inputmode="numeric" autocomplete="one-time-code" placeholder="000000" required pattern="[0-9][0-9][0-9][0-9][0-9][0-9]" minlength="6" maxlength="6" aria-describedby="ma-otp-hint"></div></div>
                        <p class="ma-hint" id="ma-otp-hint">Mã có hiệu lực 10 phút. Hãy kiểm tra cả thư mục Spam và dùng mã trong email mới nhất.</p>
                        <p class="ma-status" role="alert" hidden></p>
                        <button type="submit" nh-btn-action="submit" class="ma-submit">Xác thực và bắt đầu học <span aria-hidden="true">→</span></button>
                        <div class="ma-resend"><span>Chưa nhận được mã?</span><button type="button" data-ma-resend>Gửi lại mã</button></div>
                        <p class="ma-switch"><button type="button" data-ma-view="login">Quay lại đăng nhập</button></p>
                    </form>
                </section>
            </div>
        </div>
    </div>
</div>
