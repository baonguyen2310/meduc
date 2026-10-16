<div id="login-modal" class="modal fade ma-modal" tabindex="-1" role="dialog" aria-modal="true" aria-labelledby="ma-modal-title" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content ma">
            <button type="button" class="ma-close" data-bs-dismiss="modal" aria-label="Đóng đăng nhập"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18"/></svg></button>
            <div class="modal-body">
                <p class="ma-eyebrow">TÀI KHOẢN MEDUC</p>
                <h2 id="ma-modal-title">Chào mừng trở lại.</h2>
                <p class="ma-description">Đăng nhập để tiếp tục hành trình học Y.</p>
                {$this->element('../Member/element_login_form', ['form_id' => 'meduc-login-modal'])}
            </div>
        </div>
    </div>
</div>
