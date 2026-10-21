{$login_id = $form_id|default:'meduc-login'}
{$social_login = $this->Setting->getSettingWebsite('social')}
<div class="ma ma-form-wrap">
    <form class="ma-form" nh-form="member-login" action="/member/ajax-login" method="post">
        <div class="ma-field">
            <label for="{$login_id|escape}-username">Tên đăng nhập hoặc email</label>
            <div class="input-group ma-input"><input name="username" id="{$login_id|escape}-username" type="text" autocomplete="username" autocapitalize="none" spellcheck="false" placeholder="Nhập tên đăng nhập hoặc email" required maxlength="255"></div>
        </div>
        <div class="ma-field">
            <div class="ma-label-row"><label for="{$login_id|escape}-password">Mật khẩu</label><a href="/member/forgot-password">Quên mật khẩu?</a></div>
            <div class="input-group ma-input ma-input-password">
                <input name="password" id="{$login_id|escape}-password" type="password" autocomplete="current-password" placeholder="Nhập mật khẩu của bạn" required>
                {$this->element('../Member/auth_password_toggle', ['input_id' => "{$login_id}-password"])}
            </div>
        </div>
        <p class="ma-status" role="alert" hidden></p>
        <button type="submit" nh-btn-action="submit" class="ma-submit">Đăng nhập <span aria-hidden="true">→</span></button>
        <input type="hidden" name="redirect" value="{if !empty($redirect)}{$redirect|escape}{/if}">
        {if !empty($social_login.facebook_app_id) && !empty($social_login.facebook_load_sdk)}
            <div class="ma-divider"><span>hoặc</span></div>
        {/if}
        {if !empty($social_login.facebook_app_id) && !empty($social_login.facebook_load_sdk)}
            <button type="button" nh-btn-login-social="facebook" class="ma-social"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 21v-8h3l.5-4H14V7c0-1 .3-2 2-2h2V1.5c-.7-.1-1.8-.3-3-.3-3 0-5 1.8-5 5V9H7v4h3v8Z"/></svg>Tiếp tục với Facebook</button>
        {/if}
    </form>
    <p class="ma-switch">Chưa có tài khoản? <a href="/member/register" data-ma-open="register">Đăng ký ngay</a></p>
</div>
