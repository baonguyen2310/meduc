{$email = $this->Utilities->getParamsByKey('email')}
<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <p class="ma-eyebrow">KHÔI PHỤC TÀI KHOẢN / 02</p>
            <h1 id="ma-title">Đặt mật khẩu mới.</h1>
            <p class="ma-description">Nhập mã OTP từ email và chọn mật khẩu mới. Hoàn tất xong, bạn có thể đăng nhập ngay trong popup.</p>
            {$this->element('../Member/element_reset_form', ['reset_form_id' => 'ma-page-reset', 'reset_email' => $email])}
        </section>
    </div>
</main>
