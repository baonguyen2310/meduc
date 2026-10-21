{$email = $this->Utilities->getParamsByKey('email')}
<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <a class="ma-back" href="/member/login"><span aria-hidden="true">←</span> Quay lại đăng nhập</a>
            <p class="ma-eyebrow">KÍCH HOẠT TÀI KHOẢN</p>
            <h1 id="ma-title">Sẵn sàng bắt đầu.</h1>
            <p class="ma-description">Nhập mã xác nhận được gửi đến email để kích hoạt tài khoản MedUC của bạn.</p>
            <form class="ma-form" nh-form="verify-email" action="/member/ajax-verify-email" method="post">
                <div class="ma-field"><label for="ma-activation-email">Email đã đăng ký</label><div class="input-group ma-input"><input name="email" id="ma-activation-email" type="email" autocomplete="email" value="{$email|default:''|escape}" required maxlength="255"></div></div>
                <div class="ma-field"><label for="ma-activation-code">Mã OTP gồm 6 số</label><div class="input-group ma-input"><input name="code" id="ma-activation-code" type="text" inputmode="numeric" autocomplete="one-time-code" placeholder="Nhập mã trong email" required pattern="[0-9][0-9][0-9][0-9][0-9][0-9]" minlength="6" maxlength="6"></div></div>
                <p class="ma-status" role="alert" hidden></p>
                <button type="submit" nh-btn-action="submit" class="ma-submit">Xác thực và bắt đầu học <span aria-hidden="true">→</span></button>
                <div class="ma-resend"><span>Chưa nhận được mã?</span> <button type="button" nh-btn-action="resend-verify">Gửi lại mã <span nh-countdown aria-live="polite"></span></button></div>
            </form>
        </section>
    </div>
</main>
