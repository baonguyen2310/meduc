<form class="ma-form" data-ma-google-profile action="/member/complete-google-profile" method="post">
    <div class="ma-field"><label for="ma-google-email">Tài khoản Google</label><div class="input-group ma-input"><input id="ma-google-email" name="email" type="email" readonly autocomplete="email"></div></div>
    <div class="ma-field-grid">
        <div class="ma-field"><label for="ma-google-name">Họ và tên <span class="ma-required">*</span></label><div class="input-group ma-input"><input id="ma-google-name" name="full_name" type="text" autocomplete="name" required minlength="2" maxlength="255" placeholder="Nhập họ và tên"></div></div>
        <div class="ma-field"><label for="ma-google-phone">Số điện thoại <span class="ma-required">*</span></label><div class="input-group ma-input"><input id="ma-google-phone" name="phone" type="tel" autocomplete="tel" required maxlength="20" placeholder="Nhập số điện thoại"></div></div>
        <div class="ma-field"><label for="ma-google-school">Trường học <span class="ma-required">*</span></label><div class="input-group ma-input"><input id="ma-google-school" name="school_name" type="text" autocomplete="organization" required maxlength="255" placeholder="Nhập tên trường của bạn"></div></div>
        <div class="ma-field"><label for="ma-google-year">Năm sinh viên <span class="ma-required">*</span></label><div class="input-group ma-input"><select id="ma-google-year" name="student_year" required>
            <option value="">Chọn năm học</option>
            <option value="1">Sinh viên năm 1</option><option value="2">Sinh viên năm 2</option>
            <option value="3">Sinh viên năm 3</option><option value="4">Sinh viên năm 4</option>
            <option value="5">Sinh viên năm 5</option><option value="6">Sinh viên năm 6</option>
            <option value="graduate">Đã tốt nghiệp / Sau đại học</option>
        </select></div></div>
    </div>
    <input type="hidden" name="profile_token">
    <p class="ma-status" role="alert" hidden></p>
    <button type="submit" class="ma-submit">Hoàn tất và bắt đầu học <span aria-hidden="true">→</span></button>
    <p class="ma-switch"><button type="button" data-ma-view="login">Dùng tài khoản khác</button></p>
</form>
