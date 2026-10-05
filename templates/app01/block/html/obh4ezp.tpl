{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<div class="edu-footer-widget quick-link-widget">
    {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <h5 class="widget-title">{$this->Block->getLocale('tieu_de', $data_extend)}</h5>
        {/if}
    {/if}
    {if !empty($website_info.facebook)}
    	<iframe 
    	    nh-lazy="iframe"
    	    delay="all"
    	    data-src="https://www.facebook.com/plugins/page.php?href=https%3A%2F%2Fwww.facebook.com%2F{$website_info.facebook}&tabs=timeline&width=270&height=130&small_header=false&adapt_container_width=true&hide_cover=false&show_facepile=true&appId=269675293903570"
    	    width="270" height="130" style="border:none;overflow:hidden" scrolling="no" 
    	    frameborder="0" allowfullscreen="true" allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share">
    	</iframe>
	{/if}
</div>{/strip}