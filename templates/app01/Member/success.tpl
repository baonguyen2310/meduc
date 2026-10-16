{$email = $this->Utilities->getParamsByKey('email')}
<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <p class="ma-eyebrow">TÀI KHOẢN MEDUC</p>
            <h1 id="ma-title">Chào mừng đến MedUC.</h1>
            <p class="ma-description">Tài khoản đã được đăng ký. Vui lòng kiểm tra email{if !empty($email)} <strong>{$email|escape}</strong>{/if} để nhận mã kích hoạt.</p>
            <a class="ma-submit" href="/member/verify-email{if !empty($email)}?email={$email|escape:'url'}{/if}">Kích hoạt tài khoản <span aria-hidden="true">→</span></a>
            <p class="ma-help">Nếu chưa thấy email, hãy kiểm tra mục Thư rác hoặc yêu cầu gửi lại mã ở bước tiếp theo.</p>
            <p class="ma-switch">Đã kích hoạt? <a href="/member/login">Đăng nhập</a></p>
        </section>
    </div>
</main>
