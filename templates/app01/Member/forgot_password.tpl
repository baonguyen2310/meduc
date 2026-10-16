<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <a class="ma-back" href="/member/login"><span aria-hidden="true">←</span> Quay lại đăng nhập</a>
            <p class="ma-eyebrow">KHÔI PHỤC TÀI KHOẢN / 01</p>
            <h1 id="ma-title">Quên mật khẩu?</h1>
            <p class="ma-description">Nhập email đã đăng ký. MedUC sẽ gửi mã xác nhận để bạn đặt lại mật khẩu.</p>
            <ol class="ma-steps" aria-label="Các bước khôi phục"><li aria-current="step"><span>1</span> Xác nhận email</li><li><span>2</span> Đặt mật khẩu mới</li></ol>
            <form class="ma-form" nh-form="forgot-password" action="/member/ajax-forgot-password" method="post">
                <div class="ma-field"><label for="ma-recovery-email">Email đã đăng ký</label><div class="input-group ma-input"><input name="email" id="ma-recovery-email" type="email" autocomplete="email" placeholder="ban@example.com" required maxlength="255"></div></div>
                <p class="ma-status" role="alert" hidden></p>
                <button type="submit" nh-btn-action="submit" class="ma-submit">Gửi mã xác nhận <span aria-hidden="true">→</span></button>
            </form>
            <p class="ma-help">Không còn truy cập được email? <a href="/lien-he-hop-tac">Liên hệ MedUC</a> để được hỗ trợ.</p>
        </section>
    </div>
</main>
