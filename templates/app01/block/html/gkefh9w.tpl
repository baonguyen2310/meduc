{strip}{*<style>
    .subscription .sub-wrap {
        background: #fff url({$this->Utilities->replaceVariableSystem($this->Block->getLocale('hinh_nen', $data_extend))}) no-repeat bottom center;
        background-size: cover;
    }
</style>*}

<section class="subscription">
    <div class="container">
        <div class="sub-wrap">
            <div class="inner-bg">
                {if !empty($data_extend['locale'][{LANGUAGE}]['hinh_nen'])}
                	{$this->LazyLoad->renderImage([
                		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('hinh_nen', $data_extend))}",
                		'delay' => 'all'
                	])}
                {/if}
            </div>
            {*<div class="inner-icons">
                {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat_1'])}
        	        <div class="inner-icon-logo-1">
            	        {$this->LazyLoad->renderImage([
                    		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat_1', $data_extend))}", 
                    		'delay' => 'all'
                    	])}
            	    </div>
        	    {/if}
        	    {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat_2'])}
            	    <div class="inner-icon-logo-2">
            	        {$this->LazyLoad->renderImage([
                    		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat_2', $data_extend))}", 
                    		'delay' => 'all'
                    	])}
            	    </div>
        	    {/if}
            </div>*}
            <div class="inner-main">
                <div class="row">
                    <div class="header">
                        <h2 class="title" data-sal="slide-up" data-sal-delay="100" data-sal-easing="ease-out-back" data-sal-duration="800">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
                            	{$this->Block->getLocale('tieu_de', $data_extend)|nl2br}
                            {/if}
                        </h2>
                        <p class="sub_title" data-sal="slide-up" data-sal-delay="200" data-sal-easing="ease-out-back" data-sal-duration="800">
                            {if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
                            	{$this->Block->getLocale('mo_ta', $data_extend)|nl2br}
                            {/if}
                        </p>
                    </div>
                </div>
                <form nh-form-contact="3HZO5VFWIK" action="/contact/send-info" method="POST" autocomplete="off" data-sal="slide-up" data-sal-delay="300" data-sal-easing="ease-out-back" data-sal-duration="800">
                    <div class="row">
                        <div class="col-md-6 col-sm-12">
                            <div class="form-group">
                                <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                                name="full_name" type="text" class="form-control" placeholder="{__d('template', 'ho_va_ten')} *">
                            </div>
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <div class="form-group">
                                <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                data-rule-phoneVN data-msg-phoneVN="{__d('template', 'so_dien_thoai_chua_chinh_xac')}" 
                                name="phone" type="text" class="form-control" placeholder="{__d('template', 'so_dien_thoai')} *">
                            </div>
                        </div>
                        <div class="col-md-12">
                            <div class="form-group">
                                <input required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                data-rule-maxlength="255" data-msg-maxlength="{__d('template', 'thong_tin_nhap_qua_dai')}" 
                                name="title" type="text" class="form-control" placeholder="{__d('template', 'tieu_de')} *">
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group">
                                <textarea required data-msg="{__d('template', 'vui_long_nhap_thong_tin')}" 
                                name="content" maxlength="500" placeholder="{__d('template', 'noi_dung')} *" rows="3"></textarea>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group text-center">
                                <span nh-btn-action="submit" class="edu-btn btn-ani">
                                    {__d('template', 'gui_yeu_cau')}
                                </span>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>{/strip}