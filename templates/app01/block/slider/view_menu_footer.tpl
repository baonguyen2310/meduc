{assign website_info value = $this->Setting->getWebsiteInfo()}

{if !empty($data_block)}
    <div class="edu-footer-widget quick-link-widget">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <h5 class="widget-title">{$this->Block->getLocale('tieu_de', $data_extend)}</h5>
        {/if}
        <div class="inner">
            {if !empty($data_extend['locale'][{LANGUAGE}]['type'])}
                {if !empty($website_info.phone)}
                    <p class="mb-20">
                        <i class="icon-Double-arrow mr-10"></i> Hotline: <span>{$website_info.phone}</span>
                    </p>
                {/if}
                
               {if !empty($website_info.email)}
                    <p class="mb-20">
                        <i class="icon-Double-arrow mr-10"></i> Email: <span>{$website_info.email}</span>
                    </p>
                {/if}
                
                <p class="mb-20">
                    <i class="icon-Double-arrow mr-10"></i> Website: <a href="https://meduc.vn/" class="text-white">https://meduc.vn</a>
                </p>
            {/if}
            
            <ul class="footer-link link-hover">
                {foreach from = $data_block item = slider}
                    <li {if !empty($slider.class_item)}class="{$slider.class_item}"{/if}>
                        <a
    				        {if !empty($slider.url)}href="{$slider.url}"{/if}
    				        title="{if !empty($slider.name)}{$slider.name}{/if}"
    				        {if !empty($slider.blank_link)}target="_blank"{/if}
    				    >
    				        <i class="icon-Double-arrow"></i> {if !empty($slider.name)}{$slider.name}{/if}
    				    </a>
                    </li>
                {/foreach}
            </ul>
        </div>
    </div>
{/if}