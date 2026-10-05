{strip}<a class="btn-action-header search-trigger" href="javascript:;">
    <i class="iconsax isax-search-normal-1"></i>
</a>

{assign var = form_url value = $this->Block->getLocale('duong_dan_tim_kiem', $data_extend)}
<div class="edu-search-popup">
    <div class="close-button">
        <button class="close-trigger"><i class="ri-close-line"></i></button>
    </div>
    <div class="inner">
        <form class="search-form" action="{$form_url}" method="get" autocomplete="off">
            <input nh-auto-suggest="{PRODUCT}" name="keyword" placeholder="{__d('template', 'tu_khoa_tim_kiem')}" type="text" class="eduvibe-search-popup-field" value="{$this->Utilities->getParamsByKey('keyword')}">
            <button nh-btn-submit class="submit-button"><i class="icon-search-line"></i></button>
        </form>
    </div>
</div>{/strip}