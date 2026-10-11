{strip}
{if !empty($data_block)}
    <div class="section-title text-center" data-sal-delay="150" data-sal="slide-up" data-sal-duration="800">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <h3 class="title">
                <img class="inner-icon" src="{CDN_URL}/media/core/logo/linh-vat-1.png" />
                {$this->Block->getLocale('tieu_de', $data_extend)|nl2br}
            </h3>
        {/if}
        {if !empty($data_extend['locale'][{LANGUAGE}]['mo_ta'])}
            <p>{$this->Block->getLocale('mo_ta', $data_extend)|nl2br}</p>
        {/if}
    </div>
	<div class="row g-5 mt--20">
	    {foreach from = $data_block item = slider}			
			{assign var = image_source value = ''}
			{if !empty($slider.image) && !empty($slider.image_source)}
				{assign var = image_source value = $slider.image_source}
			{/if}

			{assign var = image_url value = ''}
			{if !empty($slider.image) && $image_source == 'cdn'}
				{assign var = image_url value = "{CDN_URL}{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{CDN_URL}{$this->Utilities->getThumbs($slider.image, 50)}"}
				{/if}
			{/if}

			{if !empty($slider.image) && $image_source == 'template'}
				{assign var = image_url value = "{$slider.image}"}
				{if !empty(DEVICE)}
				    {assign var = image_url value = "{$this->Utilities->getThumbs($slider.image, 50, 'template')}"}
				{/if}
			{/if}
			
			{assign var = ignore value = false}
			{if $slider@first}
				{assign var = ignore value = true}
			{/if}
			
			<div class="col-lg-3 col-md-6 col-sm-6 col-6 {if !empty($slider.class_item)}{$slider.class_item}{/if}">
                <div class="edu-counterup">
                    <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                        <div class="inner">
                            <div class="icon">
                                {$this->LazyLoad->renderImage([
                                    'src' => $image_url, 
                                    'alt' => "{if !empty($slider.name)}{$slider.name}{/if}",
                                    'delay' => 'all'
                                ])}
                            </div>
                            <div class="content">
                                {if !empty($slider.name)}
                                    <h3 class="counter">
                                        <span class="odometer" data-count="{$slider.name}">00</span>+
                                    </h3>
                                {/if}
                                {if !empty($slider.description)}
                                    <span>{$slider.description}</span>
                                {/if}
                            </div>
                        </div>
                    </a>
                </div>
            </div>
		{/foreach}
	</div>
	
	<div class="row text-center mt--30">
	    {if !empty($data_extend['locale'][{LANGUAGE}]['link_group_facebook'])}
            <div class="col-lg-6 col-sm-6">
                <div class="load-more-btn mt--30">
                    <a class="edu-btn btn-ani" href="{$this->Block->getLocale('link_group_facebook', $data_extend)}" target="_blank">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam_facebook'])}
                            {$this->Block->getLocale('nut_bam_facebook', $data_extend)|nl2br}
                        {/if}
                    </a>
                </div>
            </div>
        {/if}
        {if !empty($data_extend['locale'][{LANGUAGE}]['link_group_zalo'])}
            <div class="col-lg-6 col-sm-6">
                <div class="load-more-btn mt--30">
                    <a class="edu-btn btn-ani" href="{$this->Block->getLocale('link_group_zalo', $data_extend)}" target="_blank">
                        {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam_zalo'])}
                            {$this->Block->getLocale('nut_bam_zalo', $data_extend)|nl2br}
                        {/if}
                    </a>
                </div>
            </div>
        {/if}
        {if !empty($data_extend['locale'][{LANGUAGE}]['nut_bam_email'])}
            <div class="col-lg-12 col-sm-12">
                <div class="load-more-btn mt--30">
                    <a class="edu-btn btn-ani" href="javascript:;" data-bs-toggle="modal" data-bs-target="#modalEmail">
                        {$this->Block->getLocale('nut_bam_email', $data_extend)|nl2br}
                    </a>
                </div>
            </div>
            
            <div class="modal fade modal-email" id="modalEmail" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-body">
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            <div class="inner-head">
                                <div class="inner-title">ĐĂNG KÝ NHẬN EMAIL</div>
                                <div class="inner-desc">Đăng ký để nhận những kiến thức về y khoa được gửi qua email từ MedUC (Hoàn toàn miễn phí)</div>
                            </div>
                            <form nh-form-contact="PBOU5XGLKT" action="/contact/send-info" method="POST" autocomplete="off" class="rnt-contact-form rwt-dynamic-form row">
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
                                            <input required data-rule-email="true" data-msg-email="Vui lòng nhập đúng định dạng Email"
                                                name="email" type="email" class="form-control" placeholder="Email *">
                                        </div>
                                    </div>
            
                                    <div class="col-lg-12">
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
                </div>
            </div>

        {/if}
    </div>
    
    
    <div class="box-contact-icons">
        {if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat_1'])}
	        <div class="inner-icon-logo-1">
    	        {$this->LazyLoad->renderImage([
            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat_1', $data_extend))}", 
            		'delay' => 'all'
            	])}
    	    </div>
	    {/if}
	    {*if !empty($data_extend['locale'][{LANGUAGE}]['icon_linh_vat_2'])}
    	    <div class="inner-icon-logo-2">
    	        {$this->LazyLoad->renderImage([
            		'src' => "{$this->Utilities->replaceVariableSystem($this->Block->getLocale('icon_linh_vat_2', $data_extend))}", 
            		'delay' => 'all'
            	])}
    	    </div>
	    {/if*}
    </div>
{/if}
{/strip}