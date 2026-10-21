<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <p class="ma-eyebrow">KHÔI PHỤC TÀI KHOẢN / 01</p>
            <h1 id="ma-title">Quên mật khẩu?</h1>
            <p class="ma-description">Nhập email đã đăng ký. MedUC sẽ gửi mã OTP để bạn đặt lại mật khẩu.</p>
            {$this->element('../Member/element_recovery_form', ['recovery_form_id' => 'ma-page-recovery'])}
        </section>
    </div>
</main>
