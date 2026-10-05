{strip}<div class="border p-15 rounded my-20">
    <div class="fs-20 fw-bold color-main mb-10">ĐĂNG KÝ NHẬN EMAIL</div>
    <div class="fs-16 mb-20">Đăng ký để nhận những kiến thức về y khoa được gửi qua email từ MedUC (Hoàn toàn miễn phí)</div>
    
    <form nh-form-contact="PBOU5XGLKT" action="/contact/send-info" method="POST" autocomplete="off" class="rnt-contact-form rwt-dynamic-form row">
        <div class="row">
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                <div class="contact-field p-relative mb-30 form-group">
                    <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                        data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                        name="full_name" id="full_name" type="text" class="form-control" placeholder="{__d('template', 'ho_va_ten')} *">
                </div>
            </div>
            
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                <div class="contact-field p-relative mb-30 form-group">
                    <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                        data-rule-phoneVN data-msg-phoneVN="{__d('template', 'so_dien_thoai_chua_chinh_xac')}" 
                        name="phone" id="phone" type="text" class="form-control" placeholder="{__d('template', 'so_dien_thoai')} *">
                </div>
            </div>
            
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                <div class="contact-field p-relative mb-30 form-group">
                    <input required data-rule-email="true" data-msg-email="Vui lòng nhập đúng định dạng Email"
                        name="email" type="email" class="form-control" placeholder="Email *">
                </div>
            </div>
    
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                <div class="form-group">
                    <span nh-btn-action="submit" class="rn-btn edu-btn w-100">
                        <span>Gửi Yêu Cầu</span>
                    </span>
                </div>
            </div>
        </div>
    </form>
</div>{/strip}