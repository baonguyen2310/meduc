<div class="kt-header__topbar">

    <!--begin: Quick panel toggler -->
    <div class="kt-header__topbar-item kt-header__topbar-item--quick-panel d-none" data-toggle="kt-tooltip" title="{__d('admin', 'thong_bao')}" data-placement="bottom">
        <span class="kt-header__topbar-icon kt-pulse kt-pulse--brand" id="kt_quick_panel_toggler_btn">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="24px" height="24px" viewBox="0 0 24 24" version="1.1" class="kt-svg-icon">
                <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                    <rect x="0" y="0" width="24" height="24" />
                    <rect fill="#000000" x="4" y="4" width="7" height="7" rx="1.5" />
                    <path d="M5.5,13 L9.5,13 C10.3284271,13 11,13.6715729 11,14.5 L11,18.5 C11,19.3284271 10.3284271,20 9.5,20 L5.5,20 C4.67157288,20 4,19.3284271 4,18.5 L4,14.5 C4,13.6715729 4.67157288,13 5.5,13 Z M14.5,4 L18.5,4 C19.3284271,4 20,4.67157288 20,5.5 L20,9.5 C20,10.3284271 19.3284271,11 18.5,11 L14.5,11 C13.6715729,11 13,10.3284271 13,9.5 L13,5.5 C13,4.67157288 13.6715729,4 14.5,4 Z M14.5,13 L18.5,13 C19.3284271,13 20,13.6715729 20,14.5 L20,18.5 C20,19.3284271 19.3284271,20 18.5,20 L14.5,20 C13.6715729,20 13,19.3284271 13,18.5 L13,14.5 C13,13.6715729 13.6715729,13 14.5,13 Z" fill="#000000" opacity="0.3" />
                </g>
            </svg>
            <span class="kt-pulse__ring"></span>
        </span>
    </div>

    <!--end: Quick panel toggler -->

    <!--begin: Language bar -->
    <div class="kt-header__topbar-item kt-header__topbar-item--langs">
        {assign var = list_language value = $this->LanguageAdmin->getList()}
        {assign var = default_language value = $this->LanguageAdmin->getDefaultLanguage()}

        {if !empty($list_language)}
            <div class="kt-header__topbar-wrapper" data-toggle="dropdown" data-offset="10px,0px">
                <span data-toggle="kt-tooltip" title="{if !empty($list_language[$lang])}{$list_language[$lang]}{/if}" data-placement="bottom" class="kt-header__topbar-icon {if $default_language != $lang}kt-pulse kt-pulse--danger{/if}">
                    <img src="{ADMIN_PATH}{FLAGS_URL}{$lang}.svg" alt="{if !empty($list_language[$lang])}{$list_language[$lang]}{/if}" />
                    <span class="kt-pulse__ring"></span>
                </span>
            </div>
            {if $list_language|@count gte 2}
                <div class="dropdown-menu dropdown-menu-fit dropdown-menu-right dropdown-menu-anim dropdown-menu-top-unround">
                    <ul class="kt-nav kt-margin-t-10 kt-margin-b-10">
                        {foreach from = $list_language key = key item = item}
                            {assign var = url_lang value = $this->SystemAdmin->getUrlVars('lang', {$key})}
                            <li class="kt-nav__item {if $lang eq $key}kt-nav__item--active{/if}">
                                <a href="{$url_lang}" class="kt-nav__link nh-is-default">
                                    <span class="kt-nav__link-icon">
                                        <img src="{ADMIN_PATH}{FLAGS_URL}{$key}.svg" alt="{$item}" />
                                    </span>
                                    <span class="kt-nav__link-text">{$item}</span>
                                </a>
                            </li>
                        {/foreach}
                    </ul>
                </div>
            {/if}
        {/if}
    </div>
    <!--end: Language bar -->

    <!--begin: User Bar -->
    <div class="kt-header__topbar-item kt-header__topbar-item--user">
        <div class="kt-header__topbar-wrapper" data-toggle="dropdown" data-offset="0px,0px">
            <div class="kt-header__topbar-user">
                <span class="kt-header__topbar-welcome kt-hidden-mobile">
                    {__d('admin', 'xin_chao')},
                </span>
                <span class="kt-header__topbar-username kt-hidden-mobile">
                    {if !empty($auth_user.full_name)}
                        {preg_replace("/\s.*$/","", $auth_user.full_name)}
                    {/if}
                </span>
                {* <img class="kt-hidden" alt="Pic" src="{ADMIN_PATH}/assets/media/users/300_25.jpg" /> *}

                <!--use below badge element instead the user avatar to display username's first letter(remove kt-hidden class to display it) -->
                <span class="kt-badge kt-badge--username kt-badge--unified-success kt-badge--lg kt-badge--rounded kt-badge--bold">
                    {if !empty($auth_user.full_name)}
                        {mb_substr($auth_user.full_name, 0, 1, 'UTF-8')}
                    {/if}
                </span>
            </div>
        </div>
        <div class="dropdown-menu dropdown-menu-fit dropdown-menu-right dropdown-menu-anim dropdown-menu-top-unround dropdown-menu-xl">

            <!--begin: Head -->
            <div class="kt-user-card kt-user-card--skin-dark kt-notification-item-padding-x" style="background-image: url({ADMIN_PATH}/assets/media/misc/bg-1.jpg)">
                <div class="kt-user-card__avatar">
                    {* <img class="kt-hidden" alt="Pic" src="{ADMIN_PATH}/assets/media/users/300_25.jpg" /> *}

                    <!--use below badge element instead the user avatar to display username's first letter(remove kt-hidden class to display it) -->
                    <span class="kt-badge kt-badge--lg kt-badge--rounded kt-badge--bold kt-font-success">
                        {if !empty($auth_user.full_name)}
                            {mb_substr($auth_user.full_name, 0, 1, 'UTF-8')}
                        {/if}
                    </span>
                </div>
                <div class="kt-user-card__name">
                    {if !empty($auth_user.full_name)}
                        {$auth_user.full_name}
                    {/if}
                </div>
            </div>

            <!--end: Head -->

            <!--begin: Navigation -->
            <div class="kt-notification">
                <a href="{ADMIN_PATH}/user/profile" class="kt-notification__item">
                    <div class="kt-notification__item-icon">
                        <i class="flaticon2-calendar-3 kt-font-success"></i>
                    </div>
                    <div class="kt-notification__item-details">
                        <div class="kt-notification__item-title kt-font-bold">
                            {__d('admin', 'thong_tin_tai_khoan')}
                        </div>
                    </div>
                </a>
                <div class="kt-notification__custom kt-space-between">
                    <a href="{ADMIN_PATH}/logout" class="btn btn-label btn-label-brand btn-sm btn-bold">
                        {__d('admin', 'dang_xuat')}
                    </a>
                </div>
            </div>

            <!--end: Navigation -->
        </div>
    </div>

    <!--end: User Bar -->
</div>