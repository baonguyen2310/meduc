{strip}{assign website_info value = $this->Setting->getWebsiteInfo()}

<ul class="social-list">
    {if !empty($data_extend['locale'][{LANGUAGE}]['facebook'])}
        <li>
            <a href="{$this->Block->getLocale('facebook', $data_extend)}" target="_blank" title="Facebook">
                <i class="fa-brands fa-facebook-f"></i>
            </a>
        </li>
    {/if}
    
    {if !empty($data_extend['locale'][{LANGUAGE}]['zalo'])}
        <li>
            <a href="{$this->Block->getLocale('zalo', $data_extend)}" target="_blank" title="Zalo">
                <i class="fa-solid fa-z"></i>
            </a>
        </li>
    {/if}
    
    {if !empty($data_extend['locale'][{LANGUAGE}]['youtube'])}
        <li>
            <a href="{$this->Block->getLocale('youtube', $data_extend)}" target="_blank" title="Youtube">
                <i class="fa-brands fa-youtube"></i>
            </a>
        </li>
    {/if}
    
    {if !empty($data_extend['locale'][{LANGUAGE}]['email'])}
        <li>
            <a href="mailto:{$this->Block->getLocale('email', $data_extend)}" target="_blank" title="Email">
                <i class="fa-solid fa-envelope"></i>
            </a>
        </li>
    {/if}
    
    {if !empty($data_extend['locale'][{LANGUAGE}]['phone'])}
        <li>
            <a href="tel:{$this->Block->getLocale('phone', $data_extend)}" target="_blank" title="Phone">
                <i class="fa-solid fa-phone"></i>
            </a>
        </li>
    {/if}
    
    {*if !empty($website_info.facebook)}
        <li>
            <a href="https://facebook.com/{$website_info.facebook}" target="_blank">
                <i class="fa-brands fa-facebook-f"></i>
            </a>
        </li>
    {/if}
    {if !empty($website_info.tiktok)}
        <li>
            <a href="https://tiktok.com/{$website_info.tiktok}" target="_blank">
                <i class="fa-brands fa-tiktok"></i>
            </a>
        </li>
    {/if}
    {if !empty($website_info.whatsapp)}
        <li>
            <a href="https://wa.me/{$website_info.whatsapp}" target="_blank">
                <i class="fa-brands fa-whatsapp"></i>
            </a>
        </li>
    {/if}
    {if !empty($website_info.instagram)}
        <li>
            <a href="https://instagram.com/{$website_info.instagram}" target="_blank">
                <i class="fa-brands fa-instagram"></i>
            </a>
        </li>
    {/if}
    {if !empty($website_info.linkedin)}
        <li>
            <a href="https://linkedin.com/in/{$website_info.linkedin}" target="_blank">
                <i class="fa-brands fa-linkedin-in"></i>
            </a>
        </li>
    {/if}
    {if !empty($website_info.twitter)}
        <li>
            <a href="https://twitter.com/{$website_info.twitter}" target="_blank">
                <i class="fa-brands fa-twitter"></i>
            </a>
        </li>
    {/if}
    {if !empty($website_info.youtube)}
        <li>
            <a href="https://youtube.com/@{$website_info.youtube}" target="_blank">
                <i class="fa-brands fa-youtube"></i>
            </a>
        </li>
    {/if*}
</ul>{/strip}