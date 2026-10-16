<main class="ma ma-page" id="meduc-auth">
    <div class="ma-shell">
        {$this->element('../Member/auth_intro')}
        <section class="ma-panel" aria-labelledby="ma-title">
            <nav class="ma-tabs" aria-label="Tài khoản MedUC"><a href="/member/login" aria-current="page">Đăng nhập</a><a href="/member/register">Đăng ký</a></nav>
            <p class="ma-eyebrow">TIẾP TỤC HÀNH TRÌNH HỌC Y</p>
            <h1 id="ma-title">Chào mừng trở lại.</h1>
            <p class="ma-description">Đăng nhập để tiếp tục học và theo dõi tiến độ của bạn.</p>
            {$this->element('../Member/element_login_form', ['form_id' => 'meduc-login'])}
        </section>
    </div>
</main>
