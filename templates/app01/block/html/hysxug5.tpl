{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="logo">
    <a href="/">
        <img src="{CDN_URL}{$website_info.company_logo}" alt="{$website_info.website_name}" />
    </a>
</div>{/strip}