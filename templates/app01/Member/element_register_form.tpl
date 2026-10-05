{assign var = sex value = [
    'male' => __d('template', 'nam'),
    'female' => __d('template', 'nu'),
    'other' => __d('template', 'khac')
]}
<div class="session-login d-flex flex-column justify-content-between">
    <div class="fw-bold fs-24 mb-15">
       Đăng ký tài khoản
    </div>
    <form nh-form="member-register" id="member-register" action="/member/ajax-register" method="post" autocomplete="off">
        <div class="row">
            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="full_name" class="font-weight-bold">
                        {__d('template', 'ho_va_ten')} 
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="full_name" type="text" class="form-control rounded input-hover" placeholder="Ví dụ: Lê Văn A">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-user"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="username" class="font-weight-bold">
                        Tên đăng nhập
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="username" type="text" class="form-control rounded input-hover" placeholder="Ví dụ: levana">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-user"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="email" class="font-weight-bold">
                        {__d('template', 'email')} 
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="email" type="text" class="form-control rounded input-hover">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-sms"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="phone" class="font-weight-bold">
                        {__d('template', 'so_dien_thoai')} 
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="phone" type="text" class="form-control rounded input-hover">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-call-calling"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="password" class="font-weight-bold">
                        {__d('template', 'mat_khau')}
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="password" id="password-register" type="password" class="form-control rounded input-hover">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-lock"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="password" class="font-weight-bold">
                        {__d('template', 'xac_nhan_mat_khau')}
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="verify_password" id="password-register" type="password" class="form-control rounded input-hover">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-lock"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {*<div class="row">
            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="city_id" class="font-weight-normal color-main">
                        {__d('template', 'tinh_thanh')} 
                        <span class="required">*</span>
                    </label>
                    {$this->Form->select('city_id', $this->Location->getListCitiesForDropdown(), ['id' => 'city_id', 'empty' => "-- {__d('template', 'tinh_thanh')} --", 'default' => '', 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])}
                </div>
            </div>

            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="district_id" class="font-weight-normal color-main">
                        {__d('template', 'quan_huyen')} 
                        <span class="required">*</span>
                    </label>
                    {$this->Form->select('district_id', $this->Location->getListDistrictForDropdown(), ['id' => 'district_id', 'empty' => "-- {__d('template', 'quan_huyen')} --", 'default' => '', 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])}
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="ward_id" class="font-weight-normal color-main">
                        {__d('template', 'phuong_xa')}
                    </label>
                    {$this->Form->select('ward_id', $this->Location->getListWardForDropdown(), ['id' => 'ward_id', 'empty' => "-- {__d('template', 'phuong_xa')} --", 'default' => '', 'class' => 'form-control selectpicker input-hover', 'data-size' => 10, 'data-live-search' => true])}
                </div>
            </div>
            <div class="col-md-6 col-sm-6 col-12">
                <div class="form-group">
                    <label for="address" class="font-weight-normal color-main">
                        {__d('template', 'dia_chi')} 
                        <span class="required">*</span>
                    </label>
                    <div class="input-login position-relative">
                        <input name="address" type="text" class="form-control rounded input-hover">
                        <div class="icon-input">
                            <i class="iconsax isax-lg isax-map"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>*}
        <button nh-btn-action="submit" class="rn-btn edu-btn w-100 mb--10">
            {__d('template', 'dang_ky')}
        </button>
    </form>
    <div class="d-flex justify-content-center flex-wrap fs-14 mt-10">
        {__d('template', 'ban_da_co_tai_khoan')}
        <a href="/member/login" class="color-main ml-5">
            <strong>{__d('template', 'dang_nhap')}</strong>
        </a>
    </div>
</div>