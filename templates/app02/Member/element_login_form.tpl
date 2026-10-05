{assign var = url_login value = '/member/ajax-login'}

<div class="session-login d-flex flex-column justify-content-between">
    <form nh-form="member-login" action="/member/ajax-login" method="post" autocomplete="off">
        {*<span nh-btn-login-social="google" class="btn-login-gg d-block text-center mb-10 border color-main rounded w-100 fs-16 font-weight-bold">
            {$this->LazyLoad->renderImage([
                'src' => "{URL_TEMPLATE}assets/img/icon/google2x.png", 
                'class' => 'img-fluid',
                'alt' => 'google'
            ])}
            {__d('template', 'dang_nhap_google')}
        </span>

        <span nh-btn-login-social="facebook" class="btn-login-gg d-block text-center mb-10 border color-main rounded w-100 fs-16 font-weight-bold">
            {$this->LazyLoad->renderImage([
                'src' => "{URL_TEMPLATE}assets/img/icon/facebook.svg", 
                'class' => 'img-fluid',
                'alt' => 'google'
            ])}
            {__d('template', 'dang_nhap_facebook')}
        </span>

        <p class="or text-center position-relative mb-15">
           <span class="px-5 bg-white position-relative"> {__d('template', 'hoac_tai_khoan')}</span>
        </p>*}

        <div class="form-group">
            <label for="username" class="font-weight-normal color-main">
                {__d('template', 'tai_khoan')} 
                <span class="required">*</span>
            </label>
            <div class="input-login position-relative">
                <input name="username" id="username" type="text" class="form-control rounded required">
                <div class="icon-input">
                    <i class="iconsax isax-lg isax-user"></i>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label for="password" class="font-weight-normal color-main">
                {__d('template', 'mat_khau')}
                <span class="required">*</span>
            </label>
            <div class="input-login position-relative">
                <input name="password" id="password" type="password" class="password form-control rounded required">
                    <span class="show-btn" nh-show-password>
                        <i class="iconsax isax-lg isax-eye"></i>
                    </span>
                    <div class="icon-input">
                        <i class="iconsax isax-lg isax-lock"></i>
                    </div>
            </div>
        </div>

        <button nh-btn-action="submit" class="btn btn-main btn-1a color-white bg-main w-100">
            {__d('template', 'dang_nhap')}
        </button>

        <a class="fs-14 d-block mt-5" href="/member/forgot-password">
            {__d('template', 'quen_mat_khau')} ?
        </a>
  

        <input type="hidden" name="redirect" value="{if !empty($redirect)}{$redirect}{/if}">
    </form>
    <div class="d-flex justify-content-center flex-wrap fs-14 mt-10">
        {__d('template', 'ban_chua_co_tai_khoan')}
        <a href="/member/register" class="color-main ml-5">
            <strong>{__d('template', 'dang_ky_ngay')}</strong>
        </a>
    </div>
</div>
