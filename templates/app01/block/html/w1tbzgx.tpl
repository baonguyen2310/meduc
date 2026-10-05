{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="edu-footer-widget quick-link-widget">
    <address>
        {if !empty($website_info.company_name)}
            <h5 class="widget-title">{$website_info.company_name}</h5>
        {/if}
        
        {if !empty($website_info.address)}
            <p>
                <span>{$website_info.address}</span>
            </p>
        {/if}
    </address>
</div>{/strip}