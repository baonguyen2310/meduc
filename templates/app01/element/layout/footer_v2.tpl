{strip}
{* Site footer for every page with the new header (layout/default.tpl), after the main branch's hero-light/assets/home-footer.js.
   Logo, name, address, hotline and email: Admin > Settings > Website information.
   Link lists come from the old footer blocks, which stay editable in admin (Giao diện > Block):
   - "Footer - HỢP TÁC LIÊN KẾT" (6bcghom): the "Về chúng tôi" links.
   - "Footer - CHÍNH SÁCH WEBSITE" (fcm8r16): links added under "Liên hệ".
   - "List Social" (mv6ky0z): Facebook, Zalo and YouTube. "Coppyright HTML" (awlj4fk): copyright line and DMCA badge.
   The "Khám phá" links match the header menu. *}
{assign var = website_info value = $this->Setting->getWebsiteInfo()}
{$master_brand = !empty($website_info.company_logo) && strpos($website_info.company_logo, '/templates/app01/assets/meduc-v2/brand/meduc-master') === 0}
{$footer_blocks = []}
{if !empty($blocks)}{$footer_blocks = $blocks}{/if}

{$explore_links = [
    ['label' => 'Khóa học', 'url' => '/khoa-hoc'],
    ['label' => 'Phương pháp học', 'url' => '/phuong-phap-hoc'],
    ['label' => 'Luyện thi', 'url' => '/khoa-luyen-thi'],
    ['label' => 'Bảng xếp hạng', 'url' => '/class-rank'],
    ['label' => 'Sách Y khoa', 'url' => '/sach-y-khoa'],
    ['label' => 'Tài liệu học tập', 'url' => '/tai-lieu-hoc-tap'],
    ['label' => 'Blog', 'url' => '/blog'],
    ['label' => 'Thiết bị y tế', 'url' => '/thiet-bi-y-te']
]}

{* Slider items in the old footer blocks store page links without the leading slash, e.g. "gioi-thieu". *}
{$about_links = []}
{$contact_links = []}
{foreach from = ['6bcghom', 'fcm8r16'] item = source_code}
    {if !empty($footer_blocks[$source_code]['data_block'])}
        {foreach from = $footer_blocks[$source_code]['data_block'] item = item}
            {if empty($item.name) || empty($item.url)}{continue}{/if}
            {$url = $item.url|trim}
            {if !preg_match('/^(https?:|mailto:|tel:|\/)/', $url)}{$url = "/{$url}"}{/if}
            {$label = $item.name|trim}
            {$blank = !empty($item.blank_link)}
            {$link = ['label' => $label, 'url' => $url, 'blank' => $blank]}
            {if $source_code == '6bcghom'}{$about_links[] = $link}{else}{$contact_links[] = $link}{/if}
        {/foreach}
    {/if}
{/foreach}

{$social = []}
{if !empty($footer_blocks['mv6ky0z']['data_extend']['locale'][{LANGUAGE}])}
    {$social = $footer_blocks['mv6ky0z']['data_extend']['locale'][{LANGUAGE}]}
{/if}
{$legal = []}
{if !empty($footer_blocks['awlj4fk']['data_extend']['locale'][{LANGUAGE}])}
    {$legal = $footer_blocks['awlj4fk']['data_extend']['locale'][{LANGUAGE}]}
{/if}
{$copyright = ''}
{if !empty($legal.copyright)}{$copyright = $legal.copyright}{elseif !empty($website_info.copyright)}{$copyright = $website_info.copyright}{/if}

<footer class="mfo">
    <div class="mfo-main">
        <div class="mfo-grid">
            <div class="mfo-column">
                <h2 class="mfo-heading">Khám phá</h2>
                <nav aria-label="Khám phá">
                    {foreach from = $explore_links item = link}
                        <a href="{$link.url}">{$link.label}</a>
                    {/foreach}
                </nav>
            </div>
            {if !empty($about_links)}
                <div class="mfo-column">
                    <h2 class="mfo-heading">Về chúng tôi</h2>
                    <nav aria-label="Về chúng tôi">
                        {foreach from = $about_links item = link}
                            <a href="{$link.url|escape}" {if $link.blank}target="_blank" rel="noopener noreferrer"{/if}>{$link.label|escape}</a>
                        {/foreach}
                    </nav>
                </div>
            {/if}
            {if !empty($social.facebook) || !empty($social.zalo) || !empty($social.youtube)}
                <div class="mfo-column mfo-social">
                    <h2 class="mfo-heading">Kết nối</h2>
                    <nav aria-label="Kết nối">
                        {if !empty($social.facebook)}
                            <a href="{$social.facebook|escape}" target="_blank" rel="noopener noreferrer"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 8.5V6.8c0-.8.5-1.3 1.4-1.3H17V2.2C16.6 2.1 15.4 2 14.1 2 11.3 2 9.6 3.7 9.6 6.6v1.9H7V12h2.6v10H14V12h2.7l.4-3.5z" /></svg>Facebook</a>
                        {/if}
                        {if !empty($social.zalo)}
                            <a href="{$social.zalo|escape}" target="_blank" rel="noopener noreferrer"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 5h13.5v2.6L9 17h9.8v2.5H4.9v-2.6L14.4 7.5H5z" /></svg>Zalo</a>
                        {/if}
                        {if !empty($social.youtube)}
                            <a href="{$social.youtube|escape}" target="_blank" rel="noopener noreferrer"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M22 8.2c-.2-1.6-1-2.7-2.6-2.9C17 5 12 5 12 5s-5 0-7.4.3C3 5.5 2.2 6.6 2 8.2 1.8 9.4 1.8 12 1.8 12s0 2.6.2 3.8c.2 1.6 1 2.7 2.6 2.9C7 19 12 19 12 19s5 0 7.4-.3c1.6-.2 2.4-1.3 2.6-2.9.2-1.2.2-3.8.2-3.8s0-2.6-.2-3.8zM10 15V9l5.2 3z" /></svg>YouTube</a>
                        {/if}
                    </nav>
                </div>
            {/if}
            <div class="mfo-column">
                <h2 class="mfo-heading">Liên hệ</h2>
                <nav aria-label="Liên hệ">
                    {if !empty($website_info.hotline)}
                        <a href="tel:{$website_info.hotline|replace:' ':''|escape}">Hotline: {$website_info.hotline|escape}</a>
                    {/if}
                    {if !empty($website_info.email)}
                        <a href="mailto:{$website_info.email|escape}">Email: {$website_info.email|escape}</a>
                    {/if}
                    {foreach from = $contact_links item = link}
                        <a href="{$link.url|escape}" {if $link.blank}target="_blank" rel="noopener noreferrer"{/if}>{$link.label|escape}</a>
                    {/foreach}
                </nav>
            </div>
        </div>
    </div>

    <div class="mfo-bottom">
        <div class="mfo-brand{if $master_brand} mfo-brand--master{/if}">
            {if !empty($website_info.company_logo)}
                {if $master_brand}
                    <a href="/" class="mfo-master-logo" aria-label="MedUC Master — Trang chủ">
                        <img class="mfo-master-light" src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/brand/meduc-master-footer-light-v2.svg" alt="" aria-hidden="true" loading="lazy" />
                        <img class="mfo-master-dark" src="/templates/{CODE_TEMPLATE}/assets/meduc-v2/brand/meduc-master-footer-dark-v2.svg" alt="" aria-hidden="true" loading="lazy" />
                    </a>
                {else}
                    <a href="/" aria-label="Trang chủ"><img src="{$this->Utilities->getWebsiteImageUrl($website_info.company_logo)|escape}" alt="{if !empty($website_info.website_name)}{$website_info.website_name|escape}{else}MedUC{/if}" loading="lazy" /></a>
                {/if}
            {/if}
            <div>
                {if !empty($website_info.company_name)}<strong>{$website_info.company_name|escape}</strong>{/if}
                {if !empty($website_info.address)}<p>{$website_info.address|escape}</p>{/if}
            </div>
        </div>
        <div class="mfo-legal">
            {if $copyright != ''}<span>{$copyright|escape}</span>{/if}
            {if !empty($legal.logo_dmca)}
                <a class="mfo-dmca" href="{if !empty($legal.link_dmca)}{$legal.link_dmca|escape}{else}https://www.dmca.com/{/if}" target="_blank" rel="noopener noreferrer" aria-label="Chứng nhận bảo vệ nội dung DMCA">
                    <img src="{$this->Utilities->replaceVariableSystem($legal.logo_dmca)|escape}" alt="DMCA" loading="lazy" />
                </a>
            {/if}
        </div>
    </div>
</footer>
{/strip}
