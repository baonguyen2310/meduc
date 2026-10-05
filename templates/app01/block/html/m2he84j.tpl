{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="edu-contact-us-area eduvibe-contact-us edu-section-gap bg-color-white">
    <div class="container eduvibe-animated-shape">
        <div class="row g-5">
            <div class="col-lg-12">
                <div class="section-title text-center" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                    <span class="pre-title">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_1'])}
                        	{$this->Block->getLocale('text_1', $data_extend)|nl2br}
                        {/if}
                    </span>
                    <h3 class="title">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['text_2'])}
                        	{$this->Block->getLocale('text_2', $data_extend)|nl2br}
                        {/if}
                    </h3>
                </div>
            </div>
        </div>
        <div class="row g-5 mt--20">
            <div class="col-lg-6">
                <div class="contact-info pr--70 pr_lg--0 pr_md--0 pr_sm--0">
                    <div class="row g-5">
                        <!-- Start Contact Info  -->
                        {*<div class="col-lg-6 col-md-6 col-sm-6 col-12" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
                            <div class="contact-address-card-1 website">
                                <div class="inner">
                                    <div class="icon">
                                        <i class="ri-global-line"></i>
                                    </div>
                                    <div class="content">
                                        <h6 class="title">Website</h6>
                                        <p><a href="https://example.com" target="_blank">www.example.com</a></p>
                                    </div>
                                </div>
                            </div>
                        </div>*}
                        <!-- End Contact Info  -->

                        <!-- Start Contact Info  -->
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12" data-sal-delay="200" data-sal="slide-up" data-sal-duration="800">
                            <div class="contact-address-card-1 phone">
                                <div class="inner">
                                    <div class="icon">
                                        <i class="icon-Headphone"></i>
                                    </div>
                                    <div class="content">
                                        <h6 class="title">Điện thoại</h6>
                                        {if !empty($website_info.hotline)}
                                            <p><a>{$website_info.hotline}</a></p>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- End Contact Info  -->

                        <!-- Start Contact Info  -->
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12" data-sal-delay="250" data-sal="slide-up" data-sal-duration="800">
                            <div class="contact-address-card-1 email">
                                <div class="inner">
                                    <div class="icon">
                                        <i class="icon-mail-open-line"></i>
                                    </div>
                                    <div class="content">
                                        <h6 class="title">Email</h6>
                                        {if !empty($website_info.email)}
                                            <p><a>{$website_info.email}</a></p>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- End Contact Info  -->

                        <!-- Start Contact Info  -->
                        <div class="col-lg-6 col-md-6 col-sm-6 col-12" data-sal-delay="300" data-sal="slide-up" data-sal-duration="800">
                            <div class="contact-address-card-1 location">
                                <div class="inner">
                                    <div class="icon">
                                        <i class="icon-map-pin-line"></i>
                                    </div>
                                    <div class="content">
                                        <h6 class="title">Địa chỉ</h6>
                                        {if !empty($website_info.address)}
                                            <p>{$website_info.address}</p>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- End Contact Info  -->
                    </div>
                </div>
            </div>

            <div class="col-lg-6">
                <form nh-form-contact="3HZO5VFWIK" action="/contact/send-info" method="POST" autocomplete="off" class="rnt-contact-form rwt-dynamic-form row">
                    <div class="row">
                        <div class="col-lg-12">
                            <div class="contact-field p-relative mb-30 form-group">
                                <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                    data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                                    name="full_name" id="full_name" type="text" class="form-control" placeholder="{__d('template', 'ho_va_ten')} *">
                            </div>
                        </div>
                        
                        <div class="col-lg-12">
                            <div class="contact-field p-relative mb-30 form-group">
                                <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                    data-rule-phoneVN data-msg-phoneVN="{__d('template', 'so_dien_thoai_chua_chinh_xac')}" 
                                    name="phone" id="phone" type="text" class="form-control" placeholder="{__d('template', 'so_dien_thoai')} *">
                            </div>
                        </div>
                        
                        <div class="col-lg-12">
                            <div class="contact-field p-relative mb-30 form-group">
                                <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                    data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                                    name="title" id="title" type="text" class="form-control" placeholder="{__d('template', 'tieu_de')} *">
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="contact-field p-relative mb-30 form-group">
                                <textarea required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                    name="content" id="content" maxlength="500" placeholder="{__d('template', 'noi_dung')} *" rows="6"></textarea>
                            </div>
                            <div class="form-group">
                                <span nh-btn-action="submit" class="rn-btn edu-btn w-100">
                                    <span>Gửi Yêu Cầu</span>
                                </span>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="shape-dot-wrapper shape-wrapper d-xl-block d-none">
            <div class="shape-image scene shape-image-1">
                <span data-depth="-2.2">
                    <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-04-01.png" alt="Shape Thumb" />
                </span>
            </div>
            <div class="shape-image shape-image-2">
                <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-02-08.png" alt="Shape Thumb" />
            </div>
            <div class="shape-image shape-image-3">
                <img src="{URL_TEMPLATE}assets/eduvibe/images/shapes/shape-15.png" alt="Shape Thumb" />
            </div>
        </div>
    </div>
</div>
{if !empty($website_info.map)}
    <div class="edu-contact-map-area edu-section-gapBottom">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="google-map alignwide sal-animate" data-sal="slide-up" data-sal-delay="150" data-sal-duration="800">
                        {$website_info.map}
                    </div>
                </div>
            </div>
        </div>
    </div>
{/if}{/strip}