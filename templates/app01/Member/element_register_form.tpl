<form class="ma ma-form" nh-form="member-register" id="member-register" action="/member/ajax-register" method="post">
    <div class="ma-field-grid">
        <div class="ma-field"><label for="ma-full-name">Họ và tên</label><div class="input-group ma-input"><input name="full_name" id="ma-full-name" type="text" autocomplete="name" placeholder="Nguyễn Văn An" required minlength="6" maxlength="255"></div></div>
        <div class="ma-field"><label for="ma-username">Tên đăng nhập</label><div class="input-group ma-input"><input name="username" id="ma-username" type="text" autocomplete="username" autocapitalize="none" spellcheck="false" placeholder="nguyenvanan" aria-describedby="ma-username-hint" required minlength="6" maxlength="255"></div></div>
        <div class="ma-field"><label for="ma-email">Email</label><div class="input-group ma-input"><input name="email" id="ma-email" type="email" autocomplete="email" placeholder="ban@example.com" required maxlength="255"></div></div>
        <div class="ma-field"><label for="ma-phone">Số điện thoại</label><div class="input-group ma-input"><input name="phone" id="ma-phone" type="tel" autocomplete="tel" inputmode="tel" placeholder="Nhập số điện thoại" required maxlength="11"></div></div>
        <div class="ma-field">
            <label for="password-register">Mật khẩu</label>
            <div class="input-group ma-input ma-input-password"><input name="password" id="password-register" type="password" autocomplete="new-password" placeholder="Tối thiểu 6 ký tự" required minlength="6" maxlength="255">{$this->element('../Member/auth_password_toggle', ['input_id' => 'password-register'])}</div>
        </div>
        <div class="ma-field">
            <label for="ma-verify-password">Nhập lại mật khẩu</label>
            <div class="input-group ma-input ma-input-password"><input name="verify_password" data-msg-required="Vui lòng nhập lại mật khẩu" id="ma-verify-password" type="password" autocomplete="new-password" placeholder="Nhập lại mật khẩu" required maxlength="255">{$this->element('../Member/auth_password_toggle', ['input_id' => 'ma-verify-password'])}</div>
        </div>
    </div>
    <p class="ma-hint" id="ma-username-hint">Tên đăng nhập gồm ít nhất 6 ký tự, chỉ dùng chữ cái không dấu và số.</p>
    <p class="ma-status" role="alert" hidden></p>
    <button type="submit" nh-btn-action="submit" class="ma-submit">Tạo tài khoản <span aria-hidden="true">→</span></button>
    <p class="ma-legal">Thông tin của bạn được bảo vệ theo <a href="/chinh-sach-bao-mat-thong-tin">Chính sách bảo mật</a> của MedUC.</p>
    <p class="ma-switch">Đã có tài khoản? <a href="/member/login">Đăng nhập</a></p>
</form>
