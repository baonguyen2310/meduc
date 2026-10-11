{strip}<div class="dc-checkout" dc-checkout>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-xl-9">
                <div class="title-section-2">
                    <span>Danh sách sản phẩm</span>
                </div>
                <div class="inner-products" product-list>
                    {*<div class="inner-product-item" data-id="82">
                        <div class="inner-image">
                            <img src="https://cdn.meduc.vn/media/z4711467102690_62148ff466fdb1b62469333044edf104.jpg" />
                        </div>
                        <div class="inner-content">
                            <div class="inner-name">
                                <a href="/mat-ket-noi-cuon-sach-kham-pha-nguyen-nhan-thuc-va-dua-ra-cac-giai-phap-bat-ngo-cho-tram-cam">
                                    'Mất kết nối'- Cuốn sách khám phá nguyên nhân thực và đưa ra các giải pháp bất ngờ cho trầm cảm
                                </a>
                            </div>
                            <div class="inner-price">
                                <div class="inner-price-new">
                                    <span>70000</span> <small>VND</small>
                                </div>
                                <div class="inner-price-old">
                                    <span>90000</span> <small>VND</small>
                                </div>
                            </div>
                            <div class="inner-quantity">
                                Số lượng: <span>3</span>
                            </div>
                            <div class="inner-delete" title="Xóa">
                                <i class="fa-regular fa-trash-can"></i>
                            </div>
                        </div>
                    </div>*}
                </div>
                <div class="inner-price-total">
                    <span>Tổng tiền:</span>
                    <strong price-total></strong>
                    <small>VND</small>
                </div>
                <form nh-form-contact="61CQ0U3H9I" action="/contact/send-info" method="POST" autocomplete="off">
                    <div class="title-section-2">
                        <span>Thông tin khách hàng</span>
                    </div>
                    <div class="inner-form">
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input required data-msg="Vui lòng nhập họ tên!" 
                                        data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                                        name="full_name" id="full_name" type="text" class="form-control" placeholder="{__d('template', 'ho_va_ten')} *">
                                </div>
                            </div>
                            
                            <div class="col-lg-6">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input required data-msg="Vui lòng nhập số điện thoại!" 
                                        data-rule-phoneVN data-msg-phoneVN="{__d('template', 'so_dien_thoai_chua_chinh_xac')}" 
                                        name="phone" id="phone" type="text" class="form-control" placeholder="{__d('template', 'so_dien_thoai')} *">
                                </div>
                            </div>
                            
                            <div class="col-lg-6">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input required data-msg="Vui lòng nhập email!" data-rule-email="true" data-msg-email="Vui lòng nhập đúng định dạng Email"
                                        name="email" id="email" type="email" class="form-control" placeholder="Email *">
                                </div>
                            </div>
                            
                            <div class="col-lg-12">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input required data-msg="Vui lòng nhập địa chỉ nhận hàng!" 
                                        data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                                        name="address" id="address" type="text" class="form-control" placeholder="Địa chỉ nhận hàng *">
                                </div>
                            </div>
    
                            <div class="col-lg-12">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <textarea name="note" id="note" maxlength="500" placeholder="Ghi chú (nếu có)" rows="3"></textarea>
                                </div>
                            </div>
                            
                            <div class="col-lg-12 d-none">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input required data-msg="Trống!" name="cartProducts" input-cart-products type="text" class="form-control" placeholder="Danh sách sản phẩm *">
                                </div>
                            </div>
                            
                            <div class="col-lg-12 d-none">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input required data-msg="Trống!" name="cartId" input-cart-id type="text" class="form-control" placeholder="Mã đơn hàng *">
                                </div>
                            </div>
                            
                            <div class="col-lg-12 d-none">
                                <div class="contact-field p-relative mb-30 form-group">
                                    <input name="affiliateCode" type="text" class="form-control" id="affiliate-code">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="title-section-2">
                        <span>Phương thức thanh toán</span>
                    </div>
                    <div class="inner-payment">
                        <div class="row">
                            <div class="col-xl-6">
                                <label for="payment-cod" class="inner-payment-item">
                                    <input type="radio" name="payment" id="payment-cod" value="cod" checked />
                                    <i class="fa-solid fa-hand-holding-dollar"></i>
                                    <span>Thanh toán khi nhận hàng</span>
                                </label>
                            </div>
                            <div class="col-xl-6">
                                <label for="payment-bank" class="inner-payment-item">
                                    <input type="radio" name="payment" id="payment-bank" value="bank" />
                                    <i class="fa-regular fa-credit-card"></i>
                                    <span>Thanh toán chuyển khoản</span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="inner-info-bank">
                        <div class="row">
                            <div class="col-xl-6 col-lg-12">
                                <div class="border rounded mb-10 p-15">
                                    <h3 class="color-black fs-md-16 fs-14 mb-10">
                                        Tài khoản ngân hàng
                                    </h3>
                        
                                    <div class="entry-bank fs-12">
                                        <div>
                                            <p class="mb-0 fs-12">Tên ngân hàng: <b>Viettinbank</b></p>
                                            <p class="mb-0 fs-12">Chủ tài khoản: <b>HKD MedUC</b></p>
                                            <p class="mb-10 fs-12">Số tài khoản: <b>0339308997</b></p>
                                            <div class="entry-bank fs-12 mb-10">
                                                <img nh-lazy="image" class="img-qr-code" alt="Thanh toán qua ví MoMo" src="https://cdn.meduc.vn/media/core/bank-qr-code.jpg" style="" />
                                            </div>
                                            <p class="mb-0 fs-12">
                                                Nội dung thanh toán:
                                                <span class="text-danger fw-bold inner-cart-id"></span>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-xl-6 col-lg-12">
                                <div class="border rounded mb-10 p-15">
                                    <h3 class="color-black fs-md-16 fs-14 mb-10">
                                        Thanh toán qua ví MoMo
                                    </h3>
                        
                                    <p class="mb-10 fs-12">Số điện thoại: <b>0339308997</b></p>
                        
                                    <div class="entry-bank fs-12 mb-10">
                                        <img nh-lazy="image" class="img-qr-code" alt="Thanh toán qua ví MoMo" src="https://cdn.meduc.vn/media/core/momo-qr-code.jpg" style="" />
                                    </div>
                        
                                    <p class="color-black fs-12 mb-10">
                                        Lời nhắn:
                                        <span class="text-danger fw-bold inner-cart-id"></span>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <p class="text-danger mb-10 fs-16">
		    		        Chỉ nhấn vào <strong>"ĐẶT HÀNG"</strong> khi đã chuyển khoản xong.
		    		    </p>
                    </div>
                    <div class="inner-submit">
                        <div class="form-group">
                            <span nh-btn-action="submit" class="rn-btn edu-btn w-100 btn-ani">
                                <span>ĐẶT HÀNG</span>
                            </span>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>{/strip}