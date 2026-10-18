{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="logo">
    <a href="/">
        <img src="{$this->Utilities->getWebsiteImageUrl($website_info.company_logo)}" alt="{$website_info.website_name}" />
    </a>
</div>{/strip}