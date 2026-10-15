{strip}
{* Homepage free consultation form, from the main branch's hero-light/assets/home-consult.js.
   The form is the site's contact form 3HZO5VFWIK (assets/js/contact.js validates and sends it to /contact/send-info),
   so requests keep arriving where the old "ĐĂNG KÝ NHẬN TƯ VẤN MIỄN PHÍ" block sent them.
   Text: the block's "Dữ liệu mở rộng" keys below; an empty key hides its element. This block has no slider items. *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{$form_code = '3HZO5VFWIK'}
{if !empty($text.ma_form)}{$form_code = $text.ma_form|trim}{/if}
{$required = __d('template', 'vui_long_nhap_thong_tin')}
{$too_long = __d('template', 'thong_tin_nhap_qua_dai')}

<link href="/templates/{CODE_TEMPLATE}/assets/meduc-v2/consult.css?v=20261015" rel="stylesheet">

<section class="mcs" {if !empty($text.tieu_de)}aria-labelledby="mcs-title"{/if}>
    <div class="mcs-shell">
        <div class="mcs-copy">
            {if !empty($text.tieu_de_phu)}<p class="mcs-kicker">{$text.tieu_de_phu|escape}</p>{/if}
            {if !empty($text.tieu_de)}<h2 class="mcs-title" id="mcs-title">{$text.tieu_de|escape}</h2>{/if}
            {if !empty($text.mo_ta)}<p class="mcs-description">{$text.mo_ta|escape|nl2br}</p>{/if}
        </div>
        <div class="mcs-form-wrap">
            {if !empty($text.gioi_thieu_form)}<p class="mcs-form-intro">{$text.gioi_thieu_form|escape}</p>{/if}
            <form class="mcs-form" nh-form-contact="{$form_code|escape}" action="/contact/send-info" method="POST" autocomplete="off">
                <div class="mcs-fields">
                    <div class="form-group">
                        <label for="mcs-full-name">Họ và tên <span aria-hidden="true">*</span></label>
                        <input id="mcs-full-name" required data-msg="{$required|escape}" data-rule-maxlength="255" data-msg-maxlength="{$too_long|escape}" name="full_name" type="text" class="form-control" autocomplete="name" placeholder="Nhập họ và tên của bạn">
                    </div>
                    <div class="form-group">
                        <label for="mcs-phone">Số điện thoại <span aria-hidden="true">*</span></label>
                        <input id="mcs-phone" required data-msg="{$required|escape}" data-rule-phoneVN data-msg-phoneVN="{__d('template', 'so_dien_thoai_chua_chinh_xac')}" name="phone" type="tel" class="form-control" autocomplete="tel" placeholder="Số điện thoại của bạn">
                    </div>
                    <div class="form-group mcs-wide">
                        <label for="mcs-title-field">Chủ đề cần tư vấn <span aria-hidden="true">*</span></label>
                        <input id="mcs-title-field" required data-msg="{$required|escape}" data-rule-maxlength="255" data-msg-maxlength="{$too_long|escape}" name="title" type="text" class="form-control" placeholder="Ví dụ: khóa học hoặc lộ trình ôn tập">
                    </div>
                    <div class="form-group mcs-wide">
                        <label for="mcs-content">Bạn muốn được tư vấn điều gì? <span aria-hidden="true">*</span></label>
                        <textarea id="mcs-content" required data-msg="{$required|escape}" name="content" maxlength="500" rows="3" class="form-control" placeholder="Chia sẻ điều bạn đang cần hỗ trợ"></textarea>
                    </div>
                </div>
                <button type="button" class="mcs-submit" nh-btn-action="submit">
                    {if !empty($text.nut_gui)}{$text.nut_gui|escape}{else}{__d('template', 'gui_yeu_cau')}{/if} <span aria-hidden="true">→</span>
                </button>
            </form>
        </div>
    </div>
</section>
{/strip}
