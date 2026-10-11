{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="contact-fixed">
    <div class="contact-fixed__button show">
        <i class="iconsax isax-messages-15"></i>
        {__d('template', 'lien_he')}
    </div>
    <div class="contact-fixed__close">
        <i class="iconsax isax-add"></i>
    </div>
    <div class="contact-fixed__pulsation"></div>
    <div class="contact-fixed__pulsation"></div>
    
    <div class="contact-fixed__list">
        {if !empty($website_info.facebook)}
            <a class="contact-fixed__item" href="https://m.me/{$website_info.facebook}" target="_blank">
                <span class="contact-fixed__item-icon">
                    {$this->LazyLoad->renderImage([
                        'src' => "{URL_TEMPLATE}assets/media/icon/messenger.svg", 
                        'class' => 'img-fluid'
                    ])}
                </span>
                <span class="contact-fixed__item-title">
                    Messenger
                </span>
            </a>
        {/if}
        {if !empty($website_info.zalo)}
            <a class="contact-fixed__item" href="http://zalo.me/{$website_info.zalo}" target="_blank">
                <span class="contact-fixed__item-icon">
                    {$this->LazyLoad->renderImage([
                        'src' => "{URL_TEMPLATE}assets/media/icon/zalo.svg", 
                        'class' => 'img-fluid'
                    ])}
                </span>
                <span class="contact-fixed__item-title">
                    Zalo
                </span>
            </a>
        {/if}
        {if !empty($website_info.phone)}
            <a class="contact-fixed__item" href="tel:{$website_info.phone}" target="_blank">
                <span class="contact-fixed__item-icon">
                    {$this->LazyLoad->renderImage([
                        'src' => "{URL_TEMPLATE}assets/media/icon/phone.svg", 
                        'class' => 'img-fluid'
                    ])}
                </span>
                <span class="contact-fixed__item-title">
                    Gọi Ngay
                </span>
            </a>
        {/if}
    </div>
</div>




<div class="rn-progress-parent rn-backto-top-active">
    <svg class="rn-back-circle svg-inner" width="100%" height="100%" viewBox="-1 -1 102 102">
        <path d="M50,1 a49,49 0 0,1 0,98 a49,49 0 0,1 0,-98" style="transition: stroke-dashoffset 10ms linear 0s; stroke-dasharray: 307.919, 307.919; stroke-dashoffset: 149.503;"></path>
    </svg>
</div>{/strip}