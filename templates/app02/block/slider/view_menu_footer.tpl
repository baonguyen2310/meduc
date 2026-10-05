{strip}
{if !empty($data_block)}
    {assign links value = $this->Block->getLocale('link', $data_extend)}
    <div class="footer-menu-section">
        {if !empty($data_extend['locale'][{LANGUAGE}]['tieu_de'])}
            <div class="title-footer">
                {$this->Block->getLocale('tieu_de', $data_extend)}
            </div>
        {/if}
        <ul class="list-unstyled">
            {foreach from = $data_block item = slider}
				
				{assign var = url value = '/'}
				{if !empty($slider.url)}
					{assign var = url value = $this->Utilities->checkInternalUrl($slider.url)}
				{/if}
				
				<li class="{if !empty($slider.class_item)}{$slider.class_item}{/if}">
                    <a {if !empty($slider.url)}href="{$slider.url}"{/if} title="{if !empty($slider.name)}{$slider.name}{/if}" {if !empty($slider.blank_link)}target="_blank"{/if}>
                        {if !empty($slider.name)}{$slider.name}{/if}
                    </a>
                </li>
			{/foreach}
        </ul>
    </div>
{/if}
{/strip}